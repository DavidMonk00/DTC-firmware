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
-- Revision 0.1 - Added Documentation
-- REvision 0.2 - Code Review: 20190531
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
        bus_in : in tFMBusArray;
        link_index : in unsigned(4 downto 0);

        -- Output Ports --
        stub_out : out tStub := NullStub;
        bus_out : out tFMBusArray
    );
end StubFormatter;

architecture Behavioral of StubFormatter is
    signal word_number : unsigned(3 downto 0) := (others => '0');
    signal address : std_logic_vector(17 downto 0) := (others => '0');
    signal pos_lut_out : std_logic_vector(53 downto 0) := (others => '0');
    signal clk_bus : std_logic := '0';
    signal tmp_buff : tNonLUTBuf := NullNonLUTBuff;

    -- Constants required for FunkyMiniBus
    constant x : integer := bus_out(0)'low + index;
    subtype A is natural range x + 0 to x + 0;

begin

-- Concatenate stub ID and stub strip to form 11 bit address
address(7 downto 0) <= std_logic_vector(link_index) & std_logic_vector(stub_in.row(10 downto 8)); -- Highest 3 bits are assumed to be the FE ID - No idea if this is correct as I didn't make the specifications


gPromClocked : for i in 0 to 2 generate
    PosLutInstance0 : ENTITY work.GenPromClocked
        GENERIC MAP(
          FileName => "random_" & INTEGER'IMAGE(i) & ".mif",
          BusName  => "A/PosLutA" & INTEGER'IMAGE( index )
        )
        PORT MAP(
            -- Input Ports --
            clk => clk ,
            AddressIn => address(10 downto 0),
            BusIn => bus_in(i)(A),
            BusClk => clk_bus,

            -- Output Ports --
            DataOut => pos_lut_out(18*i + 17 downto 18*i),
            BusOut => bus_out(i)(A)
        );
end generate;


-- Process to use LUT data to produce r, phi, z coordinates to the stubs. This
-- process should be a zero clock process as it is simply routing the output of
-- the LUT. Output should be timed such that the stub is assosciated with the
-- correct lookup.
pFormat : process(clk)
begin
    if rising_edge(clk) then
        -- Buffer data not needed for LUTs
        tmp_buff.valid <= stub_in.valid;
        tmp_buff.bx <= (header.boxcar_number(4 downto 0) + stub_in.bx(2 downto 0)) mod 18;
        tmp_buff.bend <= stub_in.bend;
        if (tmp_buff.valid = '1') then
            -- Read buffer values
            stub_out.header.bx <= tmp_buff.bx;
            stub_out.payload.valid <= tmp_buff.valid;
            stub_out.payload.bend <= tmp_buff.bend;

            -- Require LUT
            stub_out.header.nonant <= pos_lut_out(1 downto 0);
            stub_out.payload.r <= unsigned(pos_lut_out(13 downto 2));
            stub_out.payload.z <= signed(pos_lut_out(25 downto 14));
            stub_out.payload.phi <= signed(pos_lut_out(42 downto 26));
            stub_out.payload.alpha <= signed(pos_lut_out(45 downto 42));
            stub_out.payload.layer <= unsigned(pos_lut_out(47 downto 46));
            stub_out.payload.barrel <= pos_lut_out(48);
            stub_out.payload.module <= pos_lut_out(49);

        else
            stub_out <= NullStub;
        end if;
    end if;
end process;

-- Not entirely sure what this is for... I guess it is calculating how many
-- word frames are in the boxcar.
word_number <= shift_right(header.stub_count, 1)(3 downto 0);

end Behavioral;
