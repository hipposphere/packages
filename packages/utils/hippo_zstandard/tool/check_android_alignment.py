"""Check Android ELF PT_LOAD segments before publishing native artifacts."""

import argparse
from pathlib import Path
import struct

PAGE_SIZE = 16 * 1024


def check(path: Path) -> None:
    data = path.read_bytes()
    if data[:4] != b"\x7fELF" or data[5:6] != b"\x01":
        raise ValueError("expected a little-endian Android ELF library")
    if data[4] == 2:
        phoff = struct.unpack_from("<Q", data, 32)[0]
        phsize, phnum = struct.unpack_from("<HH", data, 54)
        layout = "<IIQQQQQQ"
        offset_index, address_index = 2, 3
    elif data[4] == 1:
        phoff = struct.unpack_from("<I", data, 28)[0]
        phsize, phnum = struct.unpack_from("<HH", data, 42)
        layout = "<IIIIIIII"
        offset_index, address_index = 1, 2
    else:
        raise ValueError("unsupported ELF class")
    if phsize < struct.calcsize(layout):
        raise ValueError("invalid ELF program-header size")

    alignments = []
    for index in range(phnum):
        header = struct.unpack_from(layout, data, phoff + index * phsize)
        if header[0] != 1:  # PT_LOAD
            continue
        alignment = header[7]
        alignments.append(alignment)
        if alignment < PAGE_SIZE or alignment & (alignment - 1):
            raise ValueError(f"PT_LOAD {index} has incompatible alignment {alignment}")
        if (header[offset_index] - header[address_index]) % PAGE_SIZE:
            raise ValueError(f"PT_LOAD {index} offset/address are not 16 KB congruent")
    if not alignments:
        raise ValueError("no ELF load segments")
    print(f"PASS {path}: {len(alignments)} load segments, alignment {min(alignments)}+")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("libraries", type=Path, nargs="+")
    args = parser.parse_args()
    failed = False
    for path in args.libraries:
        try:
            check(path)
        except (OSError, ValueError, IndexError, struct.error) as error:
            print(f"FAIL {path}: {error}")
            failed = True
    raise SystemExit(1 if failed else 0)


if __name__ == "__main__":
    main()
