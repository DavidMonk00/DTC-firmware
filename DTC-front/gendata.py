import numpy as np

source_path = "/home/dmonk/Firmware/DTC-firmware/" \
              "DTC-front/DTC-front.sim/sim_1/behav/modelsim/source.txt"

mif_path = "/home/dmonk/Firmware/DTC-firmware/" \
           "DTC-front/mifs/"


def genRandomStubs():
    word_count = 8
    boxcar_count = 3655
    stub_count = 16
    loops = 5

    print("Output:")
    with open(source_path, "w") as f:
        for loop in range(loops):
            for boxcar in range(boxcar_count):
                for word in range(word_count):
                    header = format(boxcar*8, '012b') + \
                             format(stub_count, '06b')
                    payload = "1" + ("").join([str(
                        np.random.randint(low=0, high=2)) for i in range(22)
                    ])
                    payload += "1" + ("").join([str(
                        np.random.randint(low=0, high=2)) for i in range(22)
                    ])
                    data = format(int(header + payload, 2), '016x')
                    print(data)
                    f.write(data + "\n")


def genMif():
    width = 52
    depth = 11

    with open(mif_path + "random.mif", 'w') as f:
        for i in range(int(2**depth)):
            word = "0x{0:0{1}X}".format(
                np.random.randint(low=0, high=2**width),
                int(np.ceil(width/4.0)))
            f.write(word + "\n")


def main():
    genMif()


if __name__ == '__main__':
    main()
