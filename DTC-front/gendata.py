import numpy as np

source_path = "/home/dmonk/Firmware/DTC-firmware/" \
              "DTC-front/DTC-front.sim/sim_1/behav/modelsim/source.txt"

mif_path = "/home/dmonk/Firmware/DTC-firmware/" \
           "DTC-front/mifs/"


bram_width = 18


class LogicVector:
    """
    Class that simulates a VHDL std_logic_vector with a few extra useful
    functions, such as the ability to randomise the bits.
    """
    def __init__(self, width, data=0):
        self.width = width
        self.data = data
        assert(len(bin(data)[2:]) <= width)

    def __repr__(self):
        return "0x{0:0{1}X}".format(self.data, int(np.ceil(self.width/4)))

    def __getitem__(self, index):
        """
        Returns the bit at the given index, with 0th index reuslting in least
        significant bit.
        """
        return int(format(self.data, '0%db' % self.width)[::-1][index][::-1])

    def randomise(self):
        """
        Randomises all of the bits in the vector. Returns null.
        """
        self.data = np.random.randint(low=0, high=2**self.width)

    def bits(self):
        """
        Return the bit array of the vector, with 0th index being the most
        significant bit.
        """
        return format(self.data, '0%db' % self.width)


class Stub:
    """
    Class for describing the stub data required to construct MIF files. Does
    not contain all of the data fields in a real stub.
    """
    def __init__(self):
        """
        Initialises stub with null vectors for each data field.
        """
        self.r = LogicVector(12)
        self.z = LogicVector(12)
        self.phi = LogicVector(17)
        self.alpha = LogicVector(4)
        self.bend = LogicVector(4)
        self.layer = LogicVector(2)
        self.nonant = LogicVector(2)
        self.width = 54

    def randomiseValues(self):
        """
        Randomises each data field in accordance with the randomise function of
        the logic vector.
        """
        self.r.randomise()
        self.z.randomise()
        self.phi.randomise()
        self.alpha.randomise()
        self.bend.randomise()
        self.layer.randomise()
        self.nonant.randomise()

    def __generateBitStream(self):
        """
        Returns a concatenation of all the data fields as bit arrays.
        """
        return self.nonant.bits() + self.layer.bits() + self.bend.bits() + \
            self.alpha.bits() + self.phi.bits() + self.z.bits() + self.r.bits()

    def generateMifWords(self):
        """
        Generate the words required for the Memory Initialisation Files to be
        loaded into Vivado. These must then be saved into the correct file by a
        different function.
        """
        bits = self.__generateBitStream()
        words = [
            "0x{0:0{1}X}".format(
                int(bits[i*bram_width:i*bram_width+bram_width], 2),
                int(np.ceil(bram_width/4))
            ) for i in range(int(np.ceil(self.width/bram_width)))
        ]
        return words

    def __repr__(self):
        """
        Returns a formatted summary of the stub.
        """
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


def genRandomDTCInStubs():
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
    """
    Generate a series of MIF files using random stubs as the content.
    """
    mifs = ["" for i in range(int(np.ceil(54/18)))]
    stubs = [Stub() for i in range(2048)]
    for stub in stubs:
        stub.randomiseValues()
        print(stub)
        words = stub.generateMifWords()
        for i in range(len(mifs)):
            mifs[i] += (words[i] + "\n")
    for i in range(len(mifs)):
        with open(mif_path + "random_%d.mif" % i, "w") as f:
            f.write(mifs[i])


def main():
    genMif()


if __name__ == '__main__':
    main()
