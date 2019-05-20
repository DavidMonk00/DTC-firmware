import numpy as np

source_path = "/home/dmonk/Firmware/DTC-firmware/" \
              "DTC-front/DTC-front.sim/sim_1/behav/modelsim/source.txt"

word_length = 64
word_count = 8
boxcar_count = 3655
stub_count = 16
loops = 5


def main():
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


if __name__ == '__main__':
    main()
