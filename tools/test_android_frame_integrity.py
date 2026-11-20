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
    assert accepted(indexed[:33] + palette + indexed[33:]), "indexed PNG with palette rejected"
    indexed_one_bit = header[:8] + bytes((1, 3)) + header[10:]
    indexed_one_bit_png = good[:8] + chunk(b"IHDR", indexed_one_bit) + good[33:]
    oversized_palette = chunk(b"PLTE", bytes((0, 0, 255, 255, 255, 255, 0, 0, 0)))
    assert not accepted(indexed_one_bit_png[:33] + oversized_palette + indexed_one_bit_png[33:]), "indexed palette exceeds bit depth"
    grayscale_header = header[:9] + bytes((0,)) + header[10:]
    grayscale = good[:8] + chunk(b"IHDR", grayscale_header) + good[33:]
    assert not accepted(grayscale[:33] + palette + grayscale[33:]), "grayscale PNG with forbidden palette accepted"
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
    print("PASS: PNG integrity, RGB/RGBA scanlines, palette ordering, indexed/grayscale format and corruption fixtures")


if __name__ == "__main__":
    main()
