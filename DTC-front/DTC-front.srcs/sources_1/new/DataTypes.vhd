--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;


package data_types is
    constant stubs_per_word : integer := 2;
    constant stub_width : integer := 23;

    type tDTCInWord is record
        header : std_logic_vector(17 downto 0);
        word_1 : std_logic_vector(22 downto 0);
        word_2 : std_logic_vector(22 downto 0);
    end record;

    constant NullDTCInWord : tDTCInWord := ((others => '0'), (others => '0'), (others => '0'));


    type tDTCInHeader is record
        boxcar_number : unsigned(11 downto 0);
        stub_count    : unsigned(5 downto 0);
    end record;

    constant NullDTCInHeader : tDTCInHeader := ((others => '0'), (others => '0'));


    type tDTCInStub is record
        valid   : boolean;
        offset  : unsigned(2 downto 0);
        id      : unsigned(2 downto 0);
        strip   : unsigned(7 downto 0);
        bend    : unsigned(3 downto 0);
    end record;

    constant NullDTCInStub : tDTCInStub := (false, (others => '0'), (others => '0'), (others => '0'), (others => '0'));

    type tUnconstrainedDTCInStubArray is array(integer range <>) of tDTCInStub;
    subtype tDTCInStubArray is tUnconstrainedDTCInStubArray(0 to stubs_per_word - 1);
    constant NullDTCInStubArray : tDTCInStubArray := (others => NullDTCInStub);


    type tStub is record
        valid   : boolean;
        bx      : unsigned(4 downto 0);
        r       : unsigned(11 downto 0);
        z       : unsigned(13 downto 0);
        phi     : unsigned(14 downto 0);
        bend    : unsigned(3 downto 0);
    end record;

    constant NullStub : tStub := (false, (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));

    type tUnconstrainedStubArray is array(integer range <>) of tStub;
    subtype tStubArray is tUnconstrainedStubArray(0 to stubs_per_word - 1);
    constant NullStubArray : tStubArray := (others => NullStub);

end package data_types;
