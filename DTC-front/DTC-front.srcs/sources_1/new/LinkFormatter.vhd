----------------------------------------------------------------------------------
-- Company: Imperial College London
-- Engineer: David Monk
--
-- Create Date: 05/07/2019 11:42:21 AM
-- Design Name:
-- Module Name: LinkFormatter - Behavioral
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
use IEEE.std_logic_unsigned.all;

-- Project specific imports
use work.data_types.all;


entity LinkFormatter is
    port (
        --Input Ports --
        clk : in std_logic;
        links_in : in std_logic_vector(63 downto 0);

        -- Output Ports --
        header : out tDTCInHeader := NullDTCInHeader;
        stubs : out tDTCInWordStubArray := NullDTCInWordStubArray
    );
end LinkFormatter;

architecture Behavioral of LinkFormatter is

begin
    -- Header separation
    header.boxcar_number <= unsigned(links_in(63 downto 52));
    header.stub_count <= unsigned(links_in(51 downto 46));
    -- CIC stubs separation from data section
    gstubs : for i in 0 to stubs_per_word - 1 generate
        stubs(i).valid <= links_in(45 - i * stub_width);
        stubs(i).offset <= unsigned(links_in(45 - (i * stub_width + 1) downto 45 - (i * stub_width + 3)));
        stubs(i).id     <= unsigned(links_in(45 - (i * stub_width + 4) downto 45 - (i * stub_width + 6)));
        stubs(i).strip  <= unsigned(links_in(45 - (i * stub_width + 7) downto 45 - (i * stub_width + 14)));
        stubs(i).bend   <= unsigned(links_in(45 - (i * stub_width + 15) downto 45 - (i * stub_width + 18)));
    end generate;

end Behavioral;
