import getopt
import sys

# ROM size in bytes
ROM_SIZE = 2**16
DATA_WIDTH = 32

NUM_ENTRIES = ROM_SIZE // (DATA_WIDTH//8)

def main(argv):
    inputfile = ''
    outputfile = ''
    opts, args = getopt.getopt(argv,"hi:o:",["ifile=","ofile="])
    for opt, arg in opts:
        if opt == '-h':
            print ('test.py -i <inputfile> -o <outputfile>')
            sys.exit()
        elif opt in ("-i", "--ifile"):
            inputfile = arg
        elif opt in ("-o", "--ofile"):
            outputfile = arg

    with open(outputfile, "w") as init_file, open(inputfile, "rb") as hex_file:
        init_file.write("@00000000\n")

        while True:
            hex_bytes = hex_file.read(4)
            if len(hex_bytes) == 0:
                break

            val = int.from_bytes(hex_bytes, byteorder="little")
            init_file.write(f"{val:x}\n")

            if len(hex_bytes) < 4:
                break
        
        print("Done!")

if __name__ == "__main__":
    main(sys.argv[1:])