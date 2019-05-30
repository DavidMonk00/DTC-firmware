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
        link_in : in std_logic_vector(63 downto 0);

        -- Output Ports --
        header : out tDTCInHeader := NullDTCInHeader;
        stubs : out tDTCInWordStubArray := NullDTCInWordStubArray
    );
end LinkFormatter;

architecture Behavioral of LinkFormatter is
    signal counter : integer range 0 to 63 := 63;

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if counter = 63 then
                counter <= 0;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    pHeaderSeparation : process(clk)
    begin
        if rising_edge(clk) then
            if counter < 6 then
                header.boxcar_number <= unsigned(link_in(63 downto 52));
                header.stub_count <= unsigned(link_in(51 downto 46));
                stubs(0).valid <= '0';
                stubs(1).valid <= '0';
            else
                fStubAssignment : for i in 0 to stubs_per_word - 1 loop
                    stubs(i).valid  <= link_in(63 - i * stub_width);
                    stubs(i).bx     <= unsigned(link_in(63 - (i * stub_width + 1) downto 63 - (i * stub_width + 7)));
                    stubs(i).row    <= signed(link_in(63 - (i * stub_width + 8) downto 63 - (i * stub_width + 18)));
                    stubs(i).column <= signed(link_in(63 - (i * stub_width + 19) downto 63 - (i * stub_width + 23)));
                    stubs(i).bend   <= signed(link_in(63 - (i * stub_width + 24) downto 63 - (i * stub_width + 27)));
                end loop;
            end if;
        end if;
    end process;

end Behavioral;
