----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 05/03/2019 02:27:09 PM
-- Design Name:
-- Module Name: LinkGenerator - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity LinkGenerator is
    PORT(
        clk : in std_logic;
        links_out : out std_logic_vector(63 downto 0) := (others => '0')
    );
end LinkGenerator;

architecture Behavioral of LinkGenerator is

begin
    process is
        variable line_v : line;
        file read_file : text;
        file write_file : text;
        variable slv_v : std_logic_vector(63 downto 0);
    begin
        file_open(read_file, "source.txt", read_mode);
        file_open(write_file, "target.txt", write_mode);
        while not endfile(read_file) loop
            wait until clk = '1' and clk'event;
            readline(read_file, line_v);
            hread(line_v, slv_v);
            links_out <= slv_v;3
            -- report "slv_v: " & to_hstring(slv_v);
            hwrite(line_v, slv_v);
            writeline(write_file, line_v);
        end loop;
        file_close(read_file);
        file_close(write_file);
        wait;
    end process;
end Behavioral;
