----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 06/07/2019 10:55:34 AM
-- Design Name:
-- Module Name: RouterInputReformatting - Behavioral
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

-- Standard library imports
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Project specific imports
use work.data_types.all;

entity RouterInputReformatting is
    port (
        -- Input Ports --
        clk : in std_logic;
        stub_in : in tStub;

        -- Output Ports --
        word_out : out tRouterInputWord
    );
end RouterInputReformatting;

architecture Behavioral of RouterInputReformatting is

begin

pFormat : process(clk)
begin
    if rising_edge(clk) then
        word_out(0)(4 downto 0) <= std_logic_vector(stub_in.header.bx);
        word_out(0)(6 downto 5) <= std_logic_vector(stub_in.header.nonant);

        word_out(1)(0) <= stub_in.payload.valid;
        word_out(1)(12 downto 1) <= std_logic_vector(to_unsigned(stub_in.payload.r, 12));
        word_out(1)(24 downto 13) <= std_logic_vector(to_signed(stub_in.payload.z, 12));
        word_out(1)(41 downto 25) <= std_logic_vector(to_signed(stub_in.payload.phi, 17));
        word_out(1)(45 downto 42) <= std_logic_vector(stub_in.payload.alpha);
        word_out(1)(49 downto 46) <= std_logic_vector(stub_in.payload.bend);
        word_out(1)(51 downto 50) <= std_logic_vector(stub_in.payload.layer);
        word_out(1)(52) <= stub_in.payload.barrel;
        word_out(1)(53) <= stub_in.payload.module;
    end if;
end process;

end Behavioral;
