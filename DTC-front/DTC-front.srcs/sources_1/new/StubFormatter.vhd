----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 05/07/2019 02:16:21 PM
-- Design Name:
-- Module Name: StubFormatter - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.data_types.all;
USE work.FunkyMiniBus.ALL;
USE WORK.utilities_pkg.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity StubFormatter is
    GENERIC (
        index : integer
    );
    PORT(
        clk : in std_logic;
        header : in tDTCInHeader;
        stub_in : in tDTCInStub;
        BusIn : in tFMBus(0 to 71);

        stub_out : out tStub := NullStub;
        BusOut : out tFMBus(0 to 71)
    );
end StubFormatter;

architecture Behavioral of StubFormatter is
    signal word_number : unsigned(3 downto 0) := (others => '0');
    SIGNAL StripNumber , PosLutOut : STD_LOGIC_VECTOR( 17 DOWNTO 0 ) := (OTHERS=>'0');
    SIGNAL BusClk         : STD_LOGIC     := '0';

    CONSTANT x : INTEGER := BusOut'LOW + index;
    SUBTYPE A IS NATURAL RANGE x + index TO x + index;

begin

StripNumber(10 downto 0) <= std_logic_vector(stub_in.id) & std_logic_vector(stub_in.strip);

PosLutInstance : ENTITY work.GenPromClocked
    GENERIC MAP(
      FileName => "A_PosLutLow_11to18.mif" ,
      BusName  => "A/PosLutA" & INTEGER'IMAGE( index )
    )
    PORT MAP(
      clk       => clk ,
      AddressIn => StripNumber( 10 DOWNTO 0 ) ,
      DataOut   => PosLutOut( 17 DOWNTO 0 ) ,
      BusIn     => BusIn( A ) ,
      BusOut    => BusOut( A ) ,
      BusClk    => BusClk
    );

pFormat : process(clk)
variable bx_tmp : unsigned(11 downto 0) := (others =>'0');
begin
    if rising_edge(clk) then
        if (stub_in.valid = '1') then
            stub_out.valid <= stub_in.valid;
            stub_out.bx <= (header.boxcar_number(4 downto 0) + stub_in.offset) mod 18;
            stub_out.r(7 downto 0) <= stub_in.id + stub_in.strip;
            stub_out.z(7 downto 0) <= stub_in.id - stub_in.strip;
            stub_out.phi(10 downto 0) <= (stub_in.id * stub_in.strip);
            stub_out.bend <= stub_in.bend;
        else
            stub_out <= NullStub;
        end if;
    end if;
end process;

word_number <= shift_right(header.stub_count, 1)(3 downto 0);

end Behavioral;
