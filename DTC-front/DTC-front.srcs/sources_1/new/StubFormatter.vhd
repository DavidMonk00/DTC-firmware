----------------------------------------------------------------------------------
-- Company: Imperial College London
-- Engineer: David Monk
--
-- Create Date: 05/07/2019 02:16:21 PM
-- Design Name:
-- Module Name: StubFormatter - Behavioral
-- Project Name: DTC Front End
-- Target Devices: KU15P
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Revision 0.1 - Addded Documentation
-- Additional Comments:
--
----------------------------------------------------------------------------------

-- Standard library imports
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Project specific imports
use work.data_types.all;
use work.FunkyMiniBus.all;
use work.utilities_pkg.all;


entity StubFormatter is
    GENERIC (
        index : integer
    );
    PORT(
        -- Input Ports --
        clk : in std_logic;
        header : in tDTCInHeader;
        stub_in : in tDTCInStub;
        bus_in : in tFMBus(0 to 71);

        -- Output Ports --
        stub_out : out tStub := NullStub;
        bus_out : out tFMBus(0 to 71)
    );
end StubFormatter;

architecture Behavioral of StubFormatter is
    signal word_number : unsigned(3 downto 0) := (others => '0');
    signal strip_number : std_logic_vector(17 downto 0) := (others => '0');
    signal pos_lut_out : std_logic_vector(17 downto 0) := (others => '0');
    signal clk_bus : std_logic := '0';
    signal tmp_buff : tNonLUTBuf := NullNonLUTBuff;

    -- Constants required for FunkyMiniBus
    constant x : integer := bus_out'low + index;
    subtype A is natural range x + index to x + index;

begin

-- Concatenate stub ID and stub strip to form 11 bit address4
strip_number(10 downto 0) <= std_logic_vector(stub_in.id) & std_logic_vector(stub_in.strip);


-- Entity to call LUT and read address generated from strip_number
PosLutInstance : ENTITY work.GenPromClocked
    GENERIC MAP(
      FileName => "A_PosLutLow_11to18.mif" ,
      BusName  => "A/PosLutA" & INTEGER'IMAGE( index )
    )
    PORT MAP(
        -- Input Ports --
        clk => clk ,
        AddressIn => strip_number(10 downto 0),
        BusIn => bus_in(A),
        BusClk => clk_bus,

        -- Output Ports --
        DataOut => pos_lut_out(17 downto 0),
        BusOut => bus_out(A)
    );

-- Process to use LUT data to produce r, phi, z coordinates to the stubs. This
-- process should be a zero clock process as it is simply routing the output of
-- the LUT. Output should be timed such that the stub is assosciated with the
-- correct lookup.
pFormat : process(clk)
begin
    if rising_edge(clk) then
        if (stub_in.valid = '1') then
            -- Buffer data not needed for LUTs
            tmp_buff.valid <= stub_in.valid;
            tmp_buff.bx <= (header.boxcar_number(4 downto 0) + stub_in.offset) mod 18;
            tmp_buff.bend <= stub_in.bend;


            -- Current calculations are a placeholder for LUTs, which are not
            -- fully implemented yet.
            stub_out.valid <= tmp_buff.valid;
            stub_out.bx <= tmp_buff.bx;
            stub_out.bend <= tmp_buff.bend;

            -- Require LUT
            stub_out.r <= unsigned(pos_lut_out(11 downto 0));
            stub_out.z <= unsigned(pos_lut_out(11 downto 0));
            stub_out.phi <= unsigned(pos_lut_out(16 downto 0));
            stub_out.alpha <= unsigned(pos_lut_out(3 downto 0));
            stub_out.layer <= unsigned(pos_lut_out(1 downto 0));
            stub_out.nonant <= unsigned(pos_lut_out(1 downto 0));
        else
            stub_out <= NullStub;
        end if;
    end if;
end process;

-- Not entirely sure what this is for... I guess it is calculating how many
-- word frames are in the boxcar.
word_number <= shift_right(header.stub_count, 1)(3 downto 0);

end Behavioral;
