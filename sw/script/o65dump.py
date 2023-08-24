#!/usr/bin/python

import sys
import io

class O65():

    header: dict[str, int] = {}
    options: list[(int, int, bytes)] = []
    text: bytes
    data: bytes
    undef_ref_cnt: int
    text_reloc: list[(int, int, int)] = []
    data_reloc: list[(int, int, int)] = []
    exports: list[(str, int, int)] = []

    def __init__(self, filename: str) -> None:
        with open(filename, "rb") as _file:
            self.header["no_c64"]   = int.from_bytes(_file.read(2))
            self.header["magic"]    = int.from_bytes(_file.read(3))
            self.header["version"]  = int.from_bytes(_file.read(1))
            self.header["mode"]     = int.from_bytes(_file.read(2), byteorder="little")
            self.header["tbase"]    = int.from_bytes(_file.read(2), byteorder="little")
            self.header["tlen"]     = int.from_bytes(_file.read(2), byteorder="little")
            self.header["dbase"]    = int.from_bytes(_file.read(2), byteorder="little")
            self.header["dlen"]     = int.from_bytes(_file.read(2), byteorder="little")
            self.header["bbase"]    = int.from_bytes(_file.read(2), byteorder="little")
            self.header["blen"]     = int.from_bytes(_file.read(2), byteorder="little")
            self.header["zbase"]    = int.from_bytes(_file.read(2), byteorder="little")
            self.header["zlen"]     = int.from_bytes(_file.read(2), byteorder="little")
            self.header["stack"]    = int.from_bytes(_file.read(2), byteorder="little")

            olen = int.from_bytes(_file.read(1))
            while olen != 0:
                otype = int.from_bytes(_file.read(1))
                obytes = _file.read(olen - 2)
                self.options.append((olen, otype, obytes))
                olen = int.from_bytes(_file.read(1))

            self.text = _file.read(self.header["tlen"])
            self.data = _file.read(self.header["dlen"])

            self.undef_ref_cnt = _file.read(2)

            self.text_reloc = self._parse_reloc(_file)
            self.data_reloc = self._parse_reloc(_file)

            export_count = int.from_bytes(_file.read(2), byteorder="little")
            for _ in range(export_count):
                name: bytearray = bytearray()
                data = 0
                while True:
                    data = _file.read(1)
                    if data != b"\x00":
                        name.extend(data)
                    else:
                        break
                segment = int.from_bytes(_file.read(1))
                value = int.from_bytes(_file.read(2), byteorder="little")
                self.exports.append((name.decode(), segment, value))

    def _parse_reloc(self, fd: io.BufferedReader) -> list[(int, int, int)]:
        reloc: list[(int, int, int)] = []
        offset = fd.read(1)
        while offset != b'\x00':
            offset_val = 0
            while offset == b'\xff':
                offset = fd.read(1)
                offset_val += int.from_bytes(offset) - 1
            offset_val += int.from_bytes(offset)
            typebyte = int.from_bytes(fd.read(1))
            lobyte = None
            if typebyte & 0x40:
                lobyte = int.from_bytes(fd.read(1))
            reloc.append((offset_val, typebyte, lobyte))
            offset = fd.read(1)
        return reloc


def main() -> None:
    if len(sys.argv) < 2:
        print("Please supply a filename")
        return
    filename = sys.argv[1]
    print(filename)
    o65 = O65(filename)
    for item, value in o65.header.items():
        print(f"{item}:\t{value:x}")
    
    for option in o65.options:
        print(f"Type: {option[1]}, Data: {option[2]}")

    with open("text.bin", "wb") as textfile:
        textfile.write(o65.text)

    for item in o65.exports:
        print(f"Name: {item[0]} Addr: {item[2]:#x}")

if __name__ == "__main__":
    main()

