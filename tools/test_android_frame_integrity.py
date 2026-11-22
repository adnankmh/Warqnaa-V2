#!/usr/bin/env python3
"""Regression checks for the Android smoke-test screenshot integrity gate."""
import pathlib
import struct
import subprocess
import tempfile
import zlib

ROOT = pathlib.Path(__file__).resolve().parents[1]
SCRIPT = (ROOT / "tools/android_emulator_smoke.sh").read_text()
START = SCRIPT.index("valid_frame() {\npython3 - \"$1\" <<'PY'\n") + len("valid_frame() {\npython3 - \"$1\" <<'PY'\n")
END = SCRIPT.index("\nPY\n}", START)
VALIDATOR = SCRIPT[START:END]


def chunk(name, data):
    body = name + data
    return struct.pack(">I", len(data)) + body + struct.pack(">I", zlib.crc32(body) & 0xffffffff)


def png():
    header = struct.pack(">IIBBBBB", 320, 390, 8, 2, 0, 0, 0)
    # A legitimate PNG stream with sufficient size to pass the smoke size gate.
    raw = b"".join(b"\x00" + b"\x00" * (320 * 3) for _ in range(390))
    data = zlib.compress(raw, level=0)
    return b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", header) + chunk(b"IDAT", data) + chunk(b"IEND", b"")


def accepted(data):
    with tempfile.TemporaryDirectory() as directory:
        path = pathlib.Path(directory) / "frame.png"
        path.write_bytes(data)
        return subprocess.run(["python3", "-c", VALIDATOR, str(path)], capture_output=True).returncode == 0


def main():
    good = png()
    assert accepted(good), "valid PNG rejected"
    # A valid landscape image is not acceptable evidence for the portrait Android smoke run.
    landscape_header = struct.pack(">IIBBBBB", 390, 320, 8, 2, 0, 0, 0)
    landscape = good[:8] + chunk(b"IHDR", landscape_header) + good[33:]
    assert not accepted(landscape), "landscape frame accepted as portrait evidence"
    assert not accepted(good[:-12]), "truncated PNG accepted"
    assert not accepted(good[:29] + b"\x00\x00\x00\x00" + good[33:]), "bad IHDR CRC accepted"
    assert not accepted(b"\x89PNG\r\n\x1a\n" + b"X" * 20000), "fake PNG accepted"
    assert not accepted(good[:16] + b"\x00" * 8 + good[24:]), "zero dimensions accepted"
    # Alter compressed pixel bytes without changing IHDR or the IEND trailer.
    idat_start = 33
    idat_size = struct.unpack(">I", good[idat_start:idat_start + 4])[0]
    assert idat_size > 10
    corrupted = bytearray(good)
    corrupted[idat_start + 8 + 10] ^= 0x01
    assert not accepted(bytes(corrupted)), "corrupted IDAT CRC accepted"
    # A well-formed IHDR and IEND alone must not pass without pixel data.
    header_only = good[:33] + chunk(b"IEND", b"")
    assert not accepted(header_only), "PNG without IDAT accepted"
    # Reject appended data after the terminal PNG chunk.
    assert not accepted(good + b"TRAILER"), "trailing bytes accepted"
    # IEND must have a zero-length payload and an intact CRC, even when IDAT is valid.
    nonempty_iend = good[:-12] + chunk(b"IEND", b"extra")
    assert not accepted(nonempty_iend), "nonempty IEND accepted"
    damaged_iend = bytearray(good)
    damaged_iend[-1] ^= 1
    assert not accepted(bytes(damaged_iend)), "IEND with invalid CRC accepted"
    # A second IHDR after IDAT is forbidden even when all CRCs are valid.
    duplicated_header = good[:-12] + chunk(b"IHDR", good[16:29]) + good[-12:]
    assert not accepted(duplicated_header), "duplicate IHDR accepted"
    # IEND before pixel data is forbidden, even with a valid CRC.
    premature_end = good[:33] + chunk(b"IEND", b"") + good[33:-12]
    assert not accepted(premature_end), "premature IEND accepted"
    # IDAT chunks may be split, but must remain adjacent.
    idat_body = good[41:41 + idat_size]
    split = good[:33] + chunk(b"IDAT", idat_body[:100]) + chunk(b"IDAT", idat_body[100:]) + good[-12:]
    assert accepted(split), "consecutive IDAT chunks rejected"
    # PNG permits zero-length IDAT chunks; valid Android captures must not fail on them.
    with_empty_idat = good[:33] + chunk(b"IDAT", b"") + good[33:]
    assert accepted(with_empty_idat), "legal zero-length IDAT chunk rejected"
    interrupted = good[:33] + chunk(b"IDAT", idat_body[:100]) + chunk(b"tEXt", bytes((107, 0, 118))) + chunk(b"IDAT", idat_body[100:]) + good[-12:]
    assert not accepted(interrupted), "noncontiguous IDAT accepted"
    unknown_critical = good[:33] + chunk(b"ABCD", b"unsupported") + good[33:]
    assert not accepted(unknown_critical), "unknown critical PNG chunk accepted"
    # CRC-correct chunks still need legal four-letter PNG type names and a clear reserved bit.
    for kind in (b"ab1d", b"abcD", b"aBcd"):
        malformed = good[:33] + chunk(kind, b"payload") + good[33:]
        assert not accepted(malformed), f"invalid PNG chunk name {kind!r} accepted"
    # Empty IDAT chunks are legal only when some image data exists.
    no_pixels = good[:33] + chunk(b"IDAT", b"") + good[-12:]
    assert not accepted(no_pixels), "empty-only IDAT stream accepted as screenshot"
    # A valid CRC around corrupt compressed bytes must not pass as screenshot evidence.
    invalid_stream = good[:33] + chunk(b"IDAT", b"not-a-zlib-stream" * 1000) + good[-12:]
    assert not accepted(invalid_stream), "CRC-valid but invalid zlib stream accepted"
    # A legitimate compressed stream followed by junk is not a single valid IDAT stream.
    trailing_stream = good[:33] + chunk(b"IDAT", idat_body + b"junk") + good[-12:]
    assert not accepted(trailing_stream), "trailing compressed stream bytes accepted"
    # A valid zlib member followed by a second member is not one PNG image stream.
    concatenated_zlib = good[:33] + chunk(b"IDAT", idat_body + zlib.compress(b"extra")) + good[-12:]
    assert not accepted(concatenated_zlib), "concatenated zlib members accepted"
    # A CRC-correct IDAT may still contain a broken Adler-32 checksum.
    # Rebuild the PNG chunk CRC so the validator must inspect the zlib trailer.
    broken_adler = bytearray(idat_body)
    broken_adler[-1] ^= 1
    assert not accepted(good[:33] + chunk(b"IDAT", bytes(broken_adler)) + good[-12:]), "invalid Adler-32 accepted"
    # A truncated compressed stream with a valid outer PNG CRC is incomplete,
    # even when the decompressor can return a prefix of the image pixels.
    truncated_stream = idat_body[:-2]
    assert not accepted(good[:33] + chunk(b"IDAT", truncated_stream) + good[-12:]), "truncated zlib stream accepted"
    # Ancillary metadata must not bypass CRC checks even when the pixels are valid.
    metadata = bytearray(chunk(b"tEXt", b"note\x00valid"))
    metadata[-1] ^= 1
    invalid_metadata = good[:33] + bytes(metadata) + good[33:]
    assert not accepted(invalid_metadata), "corrupt ancillary CRC accepted"
    # Valid ancillary text is allowed both before and after IDAT, without weakening CRC validation.
    valid_text = chunk(b"tEXt", b"capture\x00android")
    assert accepted(good[:33] + valid_text + good[33:]), "valid pre-IDAT text rejected"
    assert accepted(good[:-12] + valid_text + good[-12:]), "valid post-IDAT text rejected"
    damaged_post_text = bytearray(valid_text)
    damaged_post_text[-1] ^= 1
    assert not accepted(good[:-12] + bytes(damaged_post_text) + good[-12:]), "corrupt post-IDAT text CRC accepted"
    # RGB screenshots may carry an optional palette before the pixel stream.
    palette = chunk(b"PLTE", bytes((0, 0, 255)))
    assert accepted(good[:33] + palette + good[33:]), "valid optional palette rejected"
    assert not accepted(good[:33] + palette + palette + good[33:]), "duplicate palette accepted"
    assert not accepted(good[:-12] + palette + good[-12:]), "late palette accepted"
    assert not accepted(good[:33] + chunk(b"PLTE", bytes((0, 1))) + good[33:]), "malformed palette accepted"
    # IHDR fields must describe a legal PNG pixel format, not merely have valid CRCs.
    header = good[16:29]
    for label, replacement in (
        ("unsupported color type", header[:9] + bytes((1,)) + header[10:]),
        ("invalid RGB bit depth", header[:8] + bytes((4,)) + header[9:]),
        ("unsupported compression", header[:10] + bytes((1,)) + header[11:]),
        ("unsupported filter", header[:11] + bytes((1,)) + header[12:]),
        ("unsupported interlace", header[:12] + bytes((2,))),
    ):
        invalid = good[:8] + chunk(b"IHDR", replacement) + good[33:]
        assert not accepted(invalid), f"{label} accepted"
    # Indexed-color PNG requires PLTE; grayscale PNG must not contain it.
    indexed_header = header[:9] + bytes((3,)) + header[10:]
    indexed = good[:8] + chunk(b"IHDR", indexed_header) + good[33:]
    assert not accepted(indexed), "indexed PNG without required palette accepted"
    # A valid indexed palette is accepted; a palette larger than 2**bit_depth is not.
    # The RGB IDAT payload cannot be reused for indexed color: an indexed8 row
    # contains one byte per pixel, not three. Construct a real indexed stream.
    indexed_stride = 1 + 320
    indexed_raw = (b"\\x00" + b"\\x00" * 320) * 390
    indexed_valid = (
        indexed[:33] + palette
        + chunk(b"IDAT", zlib.compress(indexed_raw, level=0))
        + indexed[-12:]
    )
    assert accepted(indexed_valid), "indexed PNG with palette rejected"
    # The original RGB scanlines must be rejected even with a valid palette.
    assert not accepted(indexed[:33] + palette + indexed[33:]), "RGB-sized indexed scanlines accepted"
    indexed_one_bit = header[:8] + bytes((1, 3)) + header[10:]
    indexed_one_bit_png = good[:8] + chunk(b"IHDR", indexed_one_bit) + good[33:]
    oversized_palette = chunk(b"PLTE", bytes((0, 0, 255, 255, 255, 255, 0, 0, 0)))
    assert not accepted(indexed_one_bit_png[:33] + oversized_palette + indexed_one_bit_png[33:]), "indexed palette exceeds bit depth"
    grayscale_header = header[:9] + bytes((0,)) + header[10:]
    grayscale = good[:8] + chunk(b"IHDR", grayscale_header) + good[33:]
    assert not accepted(grayscale[:33] + palette + grayscale[33:]), "grayscale PNG with forbidden palette accepted"
    # Grayscale Android captures need complete scanlines and legal row filters too.
    gray_raw = (bytes((0,)) + bytes((0,)) * 320) * 390
    gray_prefix = good[:8] + chunk(b"IHDR", grayscale_header)
    def gray_frame(raw):
        return gray_prefix + chunk(b"IDAT", zlib.compress(raw, level=0)) + good[-12:]
    assert accepted(gray_frame(gray_raw)), "valid grayscale8 frame rejected"
    assert not accepted(gray_frame(gray_raw[:-321])), "grayscale8 missing row accepted"
    bad_gray = bytearray(gray_raw)
    bad_gray[195 * 321] = 5
    assert not accepted(gray_frame(bad_gray)), "grayscale8 illegal middle-row filter accepted"
    # Android evidence may also use 16-bit grayscale or 8-bit grayscale+alpha.
    # Verify complete scanlines and filters for both supported PNG formats.
    for label, depth, color_type, channels in (
        ("Grayscale16", 16, 0, 1),
        ("GrayscaleAlpha8", 8, 4, 2),
        ("GrayscaleAlpha16", 16, 4, 2),
    ):
        alternate_header = header[:8] + bytes((depth, color_type)) + header[10:]
        alternate_prefix = good[:8] + chunk(b"IHDR", alternate_header)
        alternate_stride = 1 + 320 * channels * (depth // 8)
        alternate_raw = (bytes((0,)) * alternate_stride) * 390
        def alternate_frame(raw):
            return alternate_prefix + chunk(b"IDAT", zlib.compress(raw, level=0)) + good[-12:]
        assert accepted(alternate_frame(alternate_raw)), f"valid {label} rejected"
        assert not accepted(alternate_frame(alternate_raw[:-alternate_stride])), f"{label} missing row accepted"
        assert not accepted(alternate_frame(alternate_raw + alternate_raw[:alternate_stride])), f"{label} extra row accepted"
        invalid_alternate = bytearray(alternate_raw)
        invalid_alternate[195 * alternate_stride] = 5
        assert not accepted(alternate_frame(invalid_alternate)), f"{label} illegal middle filter accepted"
        assert not accepted(alternate_frame(alternate_raw[:-1])), f"{label} partial row accepted"
        adaptive_alternate = bytearray(alternate_raw)
        for row_index in range(390):
            adaptive_alternate[row_index * alternate_stride] = row_index % 5
        assert accepted(alternate_frame(adaptive_alternate)), f"{label} adaptive filters rejected"
        for row_index in (0, 389):
            invalid_edge = bytearray(adaptive_alternate)
            invalid_edge[row_index * alternate_stride] = 5
            assert not accepted(alternate_frame(invalid_edge)), f"{label} invalid edge filter on row {row_index} accepted"
    # CRC-correct and zlib-valid data can still be invalid PNG scanlines.
    rgb_stride = 320 * 3 + 1
    # Keep scanline fixtures above the independent screenshot-size threshold.
    raw_rgb = zlib.decompress(idat_body)
    assert len(raw_rgb) == rgb_stride * 390
    missing_row = good[:33] + chunk(b"IDAT", zlib.compress(raw_rgb[:-rgb_stride], level=0)) + good[-12:]
    assert not accepted(missing_row), "RGB screenshot with missing row accepted"
    extra_row = good[:33] + chunk(b"IDAT", zlib.compress(raw_rgb + raw_rgb[:rgb_stride], level=0)) + good[-12:]
    assert not accepted(extra_row), "RGB screenshot with extra row accepted"
    bad_filter = bytearray(raw_rgb)
    bad_filter[0] = 5  # PNG permits only filters 0 through 4.
    illegal_filter = good[:33] + chunk(b"IDAT", zlib.compress(bad_filter, level=0)) + good[-12:]
    assert not accepted(illegal_filter), "CRC-valid screenshot with invalid row filter accepted"
    # Detect partial RGB final scanlines and illegal filters at the bottom edge.
    partial_rgb = good[:33] + chunk(b"IDAT", zlib.compress(raw_rgb[:-1], level=0)) + good[-12:]
    assert not accepted(partial_rgb), "RGB screenshot with partial final row accepted"
    last_rgb_filter = bytearray(raw_rgb)
    last_rgb_filter[-rgb_stride] = 5
    invalid_last_rgb = good[:33] + chunk(b"IDAT", zlib.compress(last_rgb_filter, level=0)) + good[-12:]
    assert not accepted(invalid_last_rgb), "RGB screenshot with invalid final-row filter accepted"
    # Android encoders may emit RGBA8 rather than RGB8; enforce the same scanline contract.
    rgba_header = header[:9] + bytes((6,)) + header[10:]
    rgba_raw = b"".join(b"\x00" + b"\x00" * (320 * 4) for _ in range(390))
    rgba_prefix = good[:8] + chunk(b"IHDR", rgba_header)
    rgba = rgba_prefix + chunk(b"IDAT", zlib.compress(rgba_raw, level=0)) + good[-12:]
    assert accepted(rgba), "valid RGBA screenshot rejected"
    rgba_stride = 320 * 4 + 1
    assert not accepted(rgba_prefix + chunk(b"IDAT", zlib.compress(rgba_raw[:-rgba_stride], level=0)) + good[-12:]), "RGBA screenshot with missing row accepted"
    invalid_rgba_filter = bytearray(rgba_raw)
    invalid_rgba_filter[rgba_stride] = 5
    assert not accepted(rgba_prefix + chunk(b"IDAT", zlib.compress(invalid_rgba_filter, level=0)) + good[-12:]), "RGBA screenshot with invalid filter accepted"
    # RGBA captures with an extra complete row must be rejected even when CRC and zlib are valid.
    extra_rgba_row = rgba_prefix + chunk(b"IDAT", zlib.compress(rgba_raw + rgba_raw[:rgba_stride], level=0)) + good[-12:]
    assert not accepted(extra_rgba_row), "RGBA screenshot with extra row accepted"
    # Reject a partial final RGBA row even when the zlib stream and CRC are correct.
    partial_rgba = rgba_prefix + chunk(b"IDAT", zlib.compress(rgba_raw[:-1], level=0)) + good[-12:]
    assert not accepted(partial_rgba), "RGBA screenshot with partial final row accepted"
    # Validate filter bytes on the final row, not only the first or second row.
    last_rgba_filter = bytearray(rgba_raw)
    last_rgba_filter[-rgba_stride] = 5
    bad_last_row = rgba_prefix + chunk(b"IDAT", zlib.compress(last_rgba_filter, level=0)) + good[-12:]
    assert not accepted(bad_last_row), "RGBA screenshot with invalid final-row filter accepted"
    # All five legal PNG row filters must remain accepted in both RGB8 and RGBA8 captures.
    # Pixel bytes are zero, so these streams are structurally valid regardless of filter choice.
    for filter_type in range(5):
        for label, prefix, raw, stride in (
            ("RGB", good[:33], raw_rgb, rgb_stride),
            ("RGBA", rgba_prefix, rgba_raw, rgba_stride),
        ):
            filtered = bytearray(raw)
            for offset in range(0, len(filtered), stride):
                filtered[offset] = filter_type
            candidate = prefix + chunk(b"IDAT", zlib.compress(filtered, level=0)) + good[-12:]
            assert accepted(candidate), f"legal PNG filter {filter_type} rejected for {label}"
    # Adaptive 8-bit PNG row filters are legal; corrupted filter bytes are not.
    for label, prefix, raw, stride in (
        ("RGB8", good[:33], raw_rgb, rgb_stride),
        ("RGBA8", rgba_prefix, rgba_raw, rgba_stride),
    ):
        adaptive = bytearray(raw)
        for row_index in range(390):
            adaptive[row_index * stride] = row_index % 5
        candidate = prefix + chunk(b"IDAT", zlib.compress(adaptive, level=0)) + good[-12:]
        assert accepted(candidate), f"{label} adaptive row filters rejected"
        for row_index in (0, 195, 389):
            corrupted_filter = bytearray(adaptive)
            corrupted_filter[row_index * stride] = 5
            invalid = prefix + chunk(b"IDAT", zlib.compress(corrupted_filter, level=0)) + good[-12:]
            assert not accepted(invalid), f"{label} invalid filter on row {row_index} accepted"
    # 16-bit Android PNG captures must meet the same complete-row and filter contracts.
    for label, color_type, channels in (("RGB16", 2, 3), ("RGBA16", 6, 4)):
        header16 = header[:8] + bytes((16, color_type)) + header[10:]
        prefix16 = good[:8] + chunk(b"IHDR", header16)
        stride16 = 320 * channels * 2 + 1
        raw16 = (b"\x00" * stride16) * 390
        def frame16(raw):
            return prefix16 + chunk(b"IDAT", zlib.compress(raw, level=0)) + good[-12:]
        assert accepted(frame16(raw16)), f"valid {label} screenshot rejected"
        assert not accepted(frame16(raw16[:-stride16])), f"{label} missing row accepted"
        assert not accepted(frame16(raw16 + raw16[:stride16])), f"{label} extra row accepted"
        bad16 = bytearray(raw16)
        bad16[-stride16] = 5
        assert not accepted(frame16(bad16)), f"{label} invalid final filter accepted"
        # A CRC-correct, zlib-valid 16-bit capture with a partial final row is invalid.
        assert not accepted(frame16(raw16[:-1])), f"{label} partial final row accepted"
        # Reject invalid filter bytes at the first and a middle scanline too;
        # checking only the last row would miss partially corrupted captures.
        for row_index in (0, 195):
            invalid_middle = bytearray(raw16)
            invalid_middle[row_index * stride16] = 5
            assert not accepted(frame16(invalid_middle)), (
                f"{label} illegal filter on row {row_index} accepted"
            )
        # Legal filters may vary by row in a single PNG; avoid rejecting real
        # Android encoders that choose filters adaptively.
        adaptive = bytearray(raw16)
        for row_index in range(390):
            adaptive[row_index * stride16] = row_index % 5
        assert accepted(frame16(adaptive)), f"{label} mixed legal filters rejected"
        # Exercise every legal filter at 16-bit depth, including the final scanline.
        for filter_type in range(5):
            filtered16 = bytearray(raw16)
            for offset in range(0, len(filtered16), stride16):
                filtered16[offset] = filter_type
            assert accepted(frame16(filtered16)), f"{label} legal filter {filter_type} rejected"
    # Indexed8 PNG evidence must carry a palette and complete, legal scanlines.
    indexed8_header = header[:9] + bytes((3,)) + header[10:]
    indexed8_prefix = good[:8] + chunk(b"IHDR", indexed8_header) + palette
    indexed8_stride = 321
    indexed8_raw = (b"\x00" * indexed8_stride) * 390
    def indexed8_frame(raw):
        return indexed8_prefix + chunk(b"IDAT", zlib.compress(raw, level=0)) + good[-12:]
    assert accepted(indexed8_frame(indexed8_raw)), "valid indexed8 screenshot rejected"
    assert not accepted(indexed8_frame(indexed8_raw[:-indexed8_stride])), "indexed8 missing row accepted"
    assert not accepted(indexed8_frame(indexed8_raw + indexed8_raw[:indexed8_stride])), "indexed8 extra row accepted"
    assert not accepted(indexed8_frame(indexed8_raw[:-1])), "indexed8 partial row accepted"
    adaptive_indexed = bytearray(indexed8_raw)
    for row_index in range(390):
        adaptive_indexed[row_index * indexed8_stride] = row_index % 5
    assert accepted(indexed8_frame(adaptive_indexed)), "indexed8 adaptive filters rejected"
    for row_index in (0, 195, 389):
        invalid_indexed = bytearray(indexed8_raw)
        invalid_indexed[row_index * indexed8_stride] = 5
        assert not accepted(indexed8_frame(invalid_indexed)), f"indexed8 illegal filter on row {row_index} accepted"
    # Packed indexed screenshots use ceil(width * bit_depth / 8) bytes per row.
    # Check valid frames and truncated rows for all legal packed depths.
    for depth in (1, 2, 4):
        packed_header = header[:8] + bytes((depth, 3)) + header[10:]
        packed_prefix = good[:8] + chunk(b"IHDR", packed_header) + palette
        packed_stride = 1 + (320 * depth + 7) // 8
        packed_raw = bytes(packed_stride * 390)
        def packed_frame(raw):
            return packed_prefix + chunk(b"IDAT", zlib.compress(raw, level=0)) + good[-12:]
        assert accepted(packed_frame(packed_raw)), f"valid indexed{depth} rejected"
        assert not accepted(packed_frame(packed_raw[:-packed_stride])), f"indexed{depth} missing row accepted"
        assert not accepted(packed_frame(packed_raw + packed_raw[:packed_stride])), f"indexed{depth} extra row accepted"
        corrupt_filter = bytearray(packed_raw)
        corrupt_filter[195 * packed_stride] = 5
        assert not accepted(packed_frame(corrupt_filter)), f"indexed{depth} illegal filter accepted"
    # Grayscale8 also needs explicit first/last-row and extra/partial-row coverage.
    for row_index in (0, 389):
        invalid_gray_edge = bytearray(gray_raw)
        invalid_gray_edge[row_index * 321] = 5
        assert not accepted(gray_frame(invalid_gray_edge)), f"grayscale8 illegal edge filter on row {row_index} accepted"
    assert not accepted(gray_frame(gray_raw + gray_raw[:321])), "grayscale8 extra row accepted"
    assert not accepted(gray_frame(gray_raw[:-1])), "grayscale8 partial row accepted"
    print("PASS: PNG integrity, RGB/RGBA 8/16-bit scanlines, palette ordering, indexed/grayscale format and corruption fixtures")


if __name__ == "__main__":
    main()
