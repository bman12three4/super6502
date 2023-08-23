#!/usr/bin/python

import sys

def main() -> None:
    if len(sys.argv) < 2:
        print("Please supply a filename")
        return
    filename = sys.argv[1]
    print(filename)
    with open(filename, "rb") as file:
        print(file.read(1))

if __name__ == "__main__":
    main()