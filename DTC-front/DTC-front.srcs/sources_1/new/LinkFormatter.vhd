----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 05/07/2019 11:42:21 AM
-- Design Name:
-- Module Name: LinkFormatter - Behavioral
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
use IEEE.std_logic_unsigned.all;

use work.data_types.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity LinkFormatter is
    PORT(
        clk : in std_logic;
        links_in : in std_logic_vector(63 downto 0);
        header : out tDTCInHeader := NullDTCInHeader;
        stubs : out tDTCInStubArray := NullDTCInStubArray
    );
end LinkFormatter;

architecture Behavioral of LinkFormatter is

begin
    header.boxcar_number <= unsigned(links_in(63 downto 52));
    header.stub_count <= unsigned(links_in(51 downto 46));
    gstubs : for i in 0 to stubs_per_word - 1 generate
        stubs(i).valid <= ??(links_in(45 - i * stub_width));
        stubs(i).offset <= unsigned(links_in(45 - (i * stub_width + 1) downto 45 - (i * stub_width + 3)));
        stubs(i).id     <= unsigned(links_in(45 - (i * stub_width + 4) downto 45 - (i * stub_width + 6)));
        stubs(i).strip  <= unsigned(links_in(45 - (i * stub_width + 7) downto 45 - (i * stub_width + 14)));
        stubs(i).bend   <= unsigned(links_in(45 - (i * stub_width + 15) downto 45 - (i * stub_width + 18)));
    end generate;
    -- links_out.word_1 <= links_in(45 downto 23);
    -- links_out.word_2 <= links_in(22 downto 0);
end Behavioral;
