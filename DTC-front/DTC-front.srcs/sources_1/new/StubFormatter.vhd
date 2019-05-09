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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity StubFormatter is
    PORT(
        clk : in std_logic;
        header : in tDTCInHeader;
        stub_in : in tDTCInStub;
        stub_out : out tStub := NullStub
    );
end StubFormatter;

architecture Behavioral of StubFormatter is
    signal word_number : unsigned(3 downto 0) := (others => '0');

begin
pFormat : process(clk)
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
