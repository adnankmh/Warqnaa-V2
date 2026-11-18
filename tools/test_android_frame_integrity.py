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
    print("PASS: valid PNG and seven corruption/boundary fixtures")


if __name__ == "__main__":
    main()
