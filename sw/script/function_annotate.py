from io import TextIOWrapper
from typing import List
from dataclasses import dataclass

@dataclass
class VCDVar():
    width: int
    index: int
    name: str

    def __repr__(self) -> str:
        return f"$var wire {self.width} {self.index} {self.name} $end\n"

class VCDHeader():
    lines: List[str]

    dumpon: str
    vcdvars: List[VCDVar]
    date: str
    timescale: str
    scope: str

    addridx: int

    def __init__(self):
        self.lines = []
        self.vcdvars = []

    def parse(self):
        for line in self.lines:
            if "$var" in line:
                tokens = line.split()
                self.vcdvars.append(VCDVar(int(tokens[2]), int(tokens[3]), tokens[4]))
                if "cpu_addr" in line:
                    self.addridx = int(line.split()[3])
            if "$date" in line:
                self.date = line
            if "$timescale" in line:
                self.timescale = line
            if "$scope" in line:
                self.scope = line
            if "$dumpon" in line:
                self.dumpon = line

    def fprint(self, file: TextIOWrapper):
        file.write(self.dumpon)
        file.write(self.date)
        file.write(self.timescale)
        file.write(self.scope)
        for var in self.vcdvars:
            file.write(str(var))
        file.write("$upscope $end\n")
        file.write("$enddefinitions $end\n")

    


class VCDNodes():
    lines: List[str]

    vals: List[str]

    addridx: str

    def __init__(self):
        self.lines = []
        self.vals = []

    def parse(self):
        for line in self.lines:
            if "$dumpvars" not in line and "$end" not in line and "#" not in line:
                self.vals.append(line)

    def fprintf(self, file: TextIOWrapper):
        file.write("#0\n")
        file.write("$dumpvars\n")
        for val in self.vals:
            file.write(val)
        file.write("$end\n")

class VCDValueChange():
    lines: List[str]

    def __init__(self):
        self.lines = []

    def get_addr(self, addridx: int) -> int | None:
        for line in self.lines:
            split = line.split()
            if len(split) > 1:
                if int(split[1]) == addridx:
                    # print(split[0][1:])
                    return int(split[0][1:], 2)
                    # print(f"{addr:x}")
        


VCDFILE = "la0_waveform.vcd"
OUTFILE = "output.vcd"
EXPORTFILE = "exports.txt"

NAME_LEN = 256

def main():

    exports: List[tuple[int, str]] = []

    with open(EXPORTFILE, "r") as exportfile:
        for line in exportfile:
            splits = line.split()
            exports.append((int(splits[1], 16), splits[0]))

    header = VCDHeader()
    nodes = VCDNodes()
    vcds: List[VCDValueChange] = []

    with open(VCDFILE, "r") as file:

        # Header
        while True:
            line = file.readline()
            header.lines.append(line)
            tokens = line.split()
            if "$enddefinitions" in tokens:
                break

        # Node info
        while True:
            line = file.readline()
            nodes.lines.append(line)
            tokens = line.split()
            if "$end" in tokens:
                break

        # Values
        node = VCDValueChange()
        while True:
            line = file.readline()
            if line == "":
                vcds.append(node)
                break
            tokens = line.split()
            if "#" in tokens[0]:
                vcds.append(node)
                node = VCDValueChange()

            node.lines.append(line)


    vcdvars: List[VCDVar] = []
    for var in vcdvars:
        print(var)
    
    header.parse()

    idx = len(header.vcdvars)

    header.vcdvars.append(VCDVar(
        NAME_LEN,
        idx,
        "function"
    ))

    nodes.lines.append(f"b{'0'*256} {idx}\n")

    nodes.parse()

    print(header.addridx)

    with open(OUTFILE, "w") as wfile:
        header.fprint(wfile)

        nodes.fprintf(wfile)

        for vcd in vcds:
            addr = vcd.get_addr(header.addridx)
            if addr is not None:
                name = getName(addr, exports)
                name_bytes = name[0:256//8].encode()
                name_int = int.from_bytes(name_bytes)
                print(f"{addr} -> {name_bytes} -> {name_int} -> {name_int:b}")
                wfile.write(f"b{name_int:0256b} {idx}\n")
            for line in vcd.lines:
                wfile.write(line)

def getName(addr: int, exports: List[tuple[int, str]]) -> str:
    name = ""
    for export in exports:
        if addr >= export[0]:
            name = export[1]
        else:
            break
    return name

if __name__ == "__main__":
    main()