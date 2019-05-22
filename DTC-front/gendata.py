import numpy as np

source_path = "/home/dmonk/Firmware/DTC-firmware/" \
              "DTC-front/DTC-front.sim/sim_1/behav/modelsim/source.txt"

mif_path = "/home/dmonk/Firmware/DTC-firmware/" \
           "DTC-front/mifs/"


bram_width = 18


class LogicVector:
    def __init__(self, width, data=0):
        self.width = width
        self.data = data
        assert(len(bin(data)[2:]) <= width)

    def __repr__(self):
        return "0x{0:0{1}X}".format(self.data, int(np.ceil(self.width/4)))

    def __getitem__(self, index):
        return int(format(self.data, '0%db' % self.width)[::-1][index][::-1])

    def randomise(self):
        self.data = np.random.randint(low=0, high=2**self.width)

    def bits(self):
        return format(self.data, '0%db' % self.width)


class Stub:
    def __init__(self):
        self.r = LogicVector(12)
        self.z = LogicVector(12)
        self.phi = LogicVector(17)
        self.alpha = LogicVector(4)
        self.bend = LogicVector(4)
        self.layer = LogicVector(2)
        self.nonant = LogicVector(2)
        self.width = 54

    def randomiseValues(self):
        self.r.randomise()
        self.z.randomise()
        self.phi.randomise()
        self.alpha.randomise()
        self.bend.randomise()
        self.layer.randomise()
        self.nonant.randomise()

    def __generateBitStream(self):
        return self.nonant.bits() + self.layer.bits() + self.bend.bits() + \
               self.alpha.bits() + self.phi.bits() + self.z.bits() + \
               self.r.bits()

    def generateMifWords(self):
        bits = self.__generateBitStream()
        words = [
            "0x{0:0{1}X}".format(
                int(bits[i*bram_width:i*bram_width+bram_width], 2),
                int(np.ceil(bram_width/4))
            ) for i in range(int(np.ceil(self.width/bram_width)))
        ]
        return words

    def __repr__(self):
        s = "--- Stub Values ---\n"
        s += "r      : width = %02d | value = %s\n" % (self.r.width, self.r)
        s += "z      : width = %02d | value = %s\n" % (self.z.width, self.z)
        s += "phi    : width = %02d | value = %s\n" % (self.phi.width,
                                                       self.phi)
        s += "alpha  : width = %02d | value = %s\n" % (self.alpha.width,
                                                       self.alpha)
        s += "bend   : width = %02d | value = %s\n" % (self.bend.width,
                                                       self.bend)
        s += "layer  : width = %02d | value = %s\n" % (self.layer.width,
                                                       self.layer)
        s += "nonant : width = %02d | value = %s\n" % (self.nonant.width,
                                                       self.nonant)
        s += "-------------------\n"
        return s


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
    mifs = ["" for i in range(int(np.ceil(54/18)))]
    stubs = [Stub() for i in range(2048)]
    for stub in stubs:
        stub.randomiseValues()
        print(stub)
        words = stub.generateMifWords()
        for i in range(len(mifs)):
            mifs[i] += (words[i] + "\n")
    print(mifs)


if __name__ == '__main__':
    main()
