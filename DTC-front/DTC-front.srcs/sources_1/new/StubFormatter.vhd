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

-- Concatenate stub ID and stub strip to form 11 bit address4
address(7 downto 0) <= std_logic_vector(link_index) & std_logic_vector(stub_in.id);


-- Entity to call LUT and read address generated from address
PosLutInstance0 : ENTITY work.GenPromClocked
    GENERIC MAP(
      FileName => "random_0.mif" ,
      BusName  => "A/PosLutA" & INTEGER'IMAGE( index )
    )
    PORT MAP(
        -- Input Ports --
        clk => clk ,
        AddressIn => address(10 downto 0),
        BusIn => bus_in(0)(A),
        BusClk => clk_bus,

        -- Output Ports --
        DataOut => pos_lut_out(17 downto 0),
        BusOut => bus_out(0)(A)
    );

PosLutInstance1 : ENTITY work.GenPromClocked
    GENERIC MAP(
      FileName => "random_1.mif" ,
      BusName  => "A/PosLutA" & INTEGER'IMAGE( index )
    )
    PORT MAP(
        -- Input Ports --
        clk => clk ,
        AddressIn => address(10 downto 0),
        BusIn => bus_in(1)(A),
        BusClk => clk_bus,

        -- Output Ports --
        DataOut => pos_lut_out(35 downto 18),
        BusOut => bus_out(1)(A)
    );

PosLutInstance2 : ENTITY work.GenPromClocked
    GENERIC MAP(
      FileName => "random_2.mif" ,
      BusName  => "A/PosLutA" & INTEGER'IMAGE( index )
    )
    PORT MAP(
        -- Input Ports --
        clk => clk ,
        AddressIn => address(10 downto 0),
        BusIn => bus_in(2)(A),
        BusClk => clk_bus,

        -- Output Ports --
        DataOut => pos_lut_out(53 downto 36),
        BusOut => bus_out(2)(A)
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
            stub_out.z <= signed(pos_lut_out(23 downto 12));
            stub_out.phi <= signed(pos_lut_out(40 downto 24));
            stub_out.alpha <= signed(pos_lut_out(43 downto 40));
            stub_out.layer <= unsigned(pos_lut_out(45 downto 44));
            stub_out.nonant <= unsigned(pos_lut_out(47 downto 46));
        else
            stub_out <= NullStub;
        end if;
    end if;
end process;

-- Not entirely sure what this is for... I guess it is calculating how many
-- word frames are in the boxcar.
word_number <= shift_right(header.stub_count, 1)(3 downto 0);

end Behavioral;
