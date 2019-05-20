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
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use work.data_types.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
    PORT(
        clk : IN std_logic;
        data_in : IN std_logic_vector(63 downto 0);
        header_out : OUT tDTCInHeader;
        data_out : OUT tStubArray
    );
end top;

architecture Behavioral of top is
    signal counter : integer := 0;
    signal links_in : std_logic_vector(63 downto 0);
    signal header : tDTCInHeader;
    signal DTCIn_stubs : tDTCInStubArray;
    signal stubs : tStubArray;
    signal lut_check : std_logic_vector(7 downto 0);

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
      links_out => links_in
  );

-- links_in <= data_in;
header_out <= header;
data_out <= stubs;

LinkFormatterInstance : entity work.LinkFormatter
    port map(
        clk => clk,
        links_in => links_in,
        header => header,
        stubs => DTCIn_stubs
    );

gStubFormatter : for i in 0 to stubs_per_word - 1 generate
    StubFormatterInstance : entity work.StubFormatter
    port map(
        clk => clk,
        header => header,
        stub_in => DTCIn_stubs(i),
        stub_out => stubs(i)
    );
end generate;

LUTTestInstance : entity work.blk_mem_gen_0
    port map(
        clka => clk,
        addra => std_logic_vector(to_unsigned((counter mod 16), 4)),
        ena => '1',
        douta => lut_check
    );

end Behavioral;
