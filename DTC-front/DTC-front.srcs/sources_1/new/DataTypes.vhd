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

-- Project specific imports
use work.FunkyMiniBus.all;
use work.utilities_pkg.all;

package data_types is
    constant link_count : integer := 36;

    type tLinksIn is array(integer range 0 to link_count - 1) of std_logic_vector(63 downto 0);
    constant NullLinksIn : tLinksIn := (others => (others => '0'));

    -- Constants relating to CIC input word
    constant stubs_per_word : integer := 2;
    constant stub_width : integer := 23;

    -- Input CIC header format as described in most recent DTC Interface Document
    type tDTCInHeader is record
        boxcar_number : unsigned(11 downto 0);
        stub_count    : unsigned(5 downto 0);
    end record;
    constant NullDTCInHeader : tDTCInHeader := ((others => '0'), (others => '0'));

    type tDTCInHeaderArray is array(integer range 0 to link_count -1) of tDTCInHeader;
    constant NullDTCInHeaderArray : tDTCInHeaderArray := (others => NullDTCInHeader);

    -- Input CIC stub format as described in most recent DTC Interface Document
    type tDTCInStub is record
        valid   : std_logic;
        offset  : unsigned(2 downto 0);
        id      : unsigned(2 downto 0);
        strip   : signed(7 downto 0);
        bend    : signed(3 downto 0);
    end record;

    constant NullDTCInStub : tDTCInStub := ('0',
                                            (others => '0'), (others => '0'),
                                            (others => '0'), (others => '0'));

    type tUnconstrainedDTCInStubArray is array(integer range <>) of tDTCInStub;
    subtype tDTCInWordStubArray is tUnconstrainedDTCInStubArray(0 to stubs_per_word - 1);
    constant NullDTCInWordStubArray : tDTCInWordStubArray := (others => NullDTCInStub);
    subtype tDTCInStubArray is tUnconstrainedDTCInStubArray(0 to link_count*stubs_per_word - 1);
    constant NullDTCInStubArray : tDTCInStubArray := (others => NullDTCInStub);


    -- Stub format as described in most recent DTC Interface Document
    type tStub is record
        valid   : std_logic;
        bx      : unsigned(4 downto 0);
        r       : unsigned(11 downto 0);
        z       : signed(11 downto 0);
        phi     : signed(16 downto 0);
        alpha   : signed(3 downto 0);
        bend    : signed(3 downto 0);
        layer   : unsigned(1 downto 0);
        nonant  : unsigned(1 downto 0);
    end record;

    constant NullStub : tStub := ('0',
                                  (others => '0'), (others => '0'),
                                  (others => '0'), (others => '0'),
                                  (others => '0'), (others => '0'),
                                  (others => '0'), (others => '0'));

    type tUnconstrainedStubArray is array(integer range <>) of tStub;
    subtype tStubWordArray is tUnconstrainedStubArray(0 to stubs_per_word - 1);
    constant NullStubWordArray : tStubWordArray := (others => NullStub);
    subtype tStubArray is tUnconstrainedStubArray(0 to link_count*stubs_per_word - 1);
    constant NullStubArray : tStubArray := (others => NullStub);

    type tUnsconstrainedLUTArray is array(integer range <>) of std_logic_vector(17 downto 0);
    subtype tLUTArray is tUnsconstrainedLUTArray(0 to stubs_per_word -1);
    constant NullLUTArray : tLUTArray := (others => (others => '0'));


    type tNonLUTBuf is record
        valid   : std_logic;
        bx      : unsigned(4 downto 0);
        bend    : signed(3 downto 0);
    end record;

    constant NullNonLUTBuff : tNonLUTBuf := ('0', (others => '0'), (others => '0'));

    type tLinkLUT is array (0 to 2*36 - 1) of integer range 0 to 2*36 - 1;

    constant cLinkLUT : tLinkLUT := (
        0,  1,  2,  3,  4,  5,  6,  7,  8,  9,
        10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
        20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
        30, 31, 32, 33, 34, 35, 36, 37, 38, 39,
        40, 41, 42, 43, 44, 45, 46, 47, 48, 49,
        50, 51, 52, 53, 54, 55, 56, 57, 58, 59,
        60, 61, 62, 63, 64, 65, 66, 67, 68, 69,
        70, 71
    );

    type tUnconstrainedFMBusArray is array(integer range <>) of tFMBus(0 to stubs_per_word*link_count - 1);
    subtype tFMBusArray is tUnconstrainedFMBusArray(0 to 2);

    type tCorrectionMatrix is array(integer range 0 to 5) of integer range -16 to 15;
    constant NullCorrectionMatrix : tCorrectionMatrix := (others => 0);
    constant testCorrectionMatrix : tCorrectionMatrix := (
        0, 1, 2, 3, 4, 5
    );

end package data_types;
