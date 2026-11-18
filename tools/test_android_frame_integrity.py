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
    # Indexed-color PNG requires PLTE; grayscale PNG must not contain it.\n    indexed_header = header[:9] + bytes((3,)) + header[10:]\n    indexed = good[:8] + chunk(b"IHDR", indexed_header) + good[33:]\n    assert not accepted(indexed), "indexed PNG without required palette accepted"\n    grayscale_header = header[:9] + bytes((0,)) + header[10:]\n    grayscale = good[:8] + chunk(b"IHDR", grayscale_header) + good[33:]\n    assert not accepted(grayscale[:33] + palette + grayscale[33:]), "grayscale PNG with forbidden palette accepted"\n    print("PASS: PNG integrity, palette ordering, indexed/grayscale format and corruption fixtures")


if __name__ == "__main__":
    main()
