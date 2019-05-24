----------------------------------------------------------------------------------
-- Company: Imperial College London
-- Engineer: David Monk
--
-- Create Date: 05/07/2019 11:42:21 AM
-- Design Name:
-- Module Name: DataTypes - Behavioral
-- Project Name: DTC Front End
-- Target Devices: KU15P
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Revision 0.1 - Added Documentation
-- Additional Comments:
--
----------------------------------------------------------------------------------


-- Standard library imports
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


package data_types is
    -- Constants relating to CIC input word
    constant stubs_per_word : integer := 2;
    constant stub_width : integer := 23;

    -- Input CIC header format as described in most recent DTC Interface Document
    type tDTCInHeader is record
        boxcar_number : unsigned(11 downto 0);
        stub_count    : unsigned(5 downto 0);
    end record;

    constant NullDTCInHeader : tDTCInHeader := ((others => '0'), (others => '0'));

    -- Input CIC stub format as described in most recent DTC Interface Document
    type tDTCInStub is record
        valid   : std_logic;
        offset  : unsigned(2 downto 0);
        id      : unsigned(2 downto 0);
        strip   : unsigned(7 downto 0);
        bend    : unsigned(3 downto 0);
    end record;

    constant NullDTCInStub : tDTCInStub := ('0',
                                            (others => '0'), (others => '0'),
                                            (others => '0'), (others => '0'));

    type tUnconstrainedDTCInStubArray is array(integer range <>) of tDTCInStub;
    subtype tDTCInStubArray is tUnconstrainedDTCInStubArray(0 to stubs_per_word - 1);
    constant NullDTCInStubArray : tDTCInStubArray := (others => NullDTCInStub);


    -- Stub format as described in most recent DTC Interface Document
    type tStub is record
        valid   : std_logic;
        bx      : unsigned(4 downto 0);
        r       : unsigned(11 downto 0);
        z       : unsigned(11 downto 0);
        phi     : unsigned(16 downto 0);
        alpha   : unsigned(3 downto 0);
        bend    : unsigned(3 downto 0);
        layer   : unsigned(1 downto 0);
        nonant  : unsigned(1 downto 0);
    end record;

    constant NullStub : tStub := ('0',
                                  (others => '0'), (others => '0'),
                                  (others => '0'), (others => '0'),
                                  (others => '0'), (others => '0'),
                                  (others => '0'), (others => '0'));

    type tUnconstrainedStubArray is array(integer range <>) of tStub;
    subtype tStubArray is tUnconstrainedStubArray(0 to stubs_per_word - 1);
    constant NullStubArray : tStubArray := (others => NullStub);

    type tUnsconstrainedLUTArray is array(integer range <>) of std_logic_vector(17 downto 0);
    subtype tLUTArray is tUnsconstrainedLUTArray(0 to stubs_per_word -1);
    constant NullLUTArray : tLUTArray := (others => (others => '0'));


    type tNonLUTBuf is record
        valid   : std_logic;
        bx      : unsigned(4 downto 0);
        bend    : unsigned(3 downto 0);
    end record;

    constant NullNonLUTBuff : tNonLUTBuf := ('0', (others => '0'), (others => '0'));

end package data_types;
