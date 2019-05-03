----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 05/01/2019 03:16:15 PM
-- Design Name:
-- Module Name: top - Behavioral
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
use IEEE.NUMERIC_STD;
use STD.TEXTIO.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
    PORT(
        clk : IN std_logic
    );
end top;

architecture Behavioral of top is
    signal counter : integer := 0;
    signal links_out : std_logic_vector(63 downto 0);

begin
process(clk)
begin
    if rising_edge(clk) then
        counter <= counter + 1;
    end if;
end process;

LinkGeneratorInstance : entity work.LinkGenerator
  port map(
    clk => clk,
    links_out => links_out
  );

end Behavioral;
