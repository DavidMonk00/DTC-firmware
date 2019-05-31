----------------------------------------------------------------------------------
-- Company: Imperial College London
-- Engineer: David Monk
--
-- Create Date: 05/01/2019 03:16:15 PM
-- Design Name:
-- Module Name: top - Behavioral
-- Project Name:
-- Target Devices: KU15P
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Revision 0.1 - Documentation added
-- Revision 0.2 - Code Review: 20190531
-- Additional Comments:
--
----------------------------------------------------------------------------------

-- Standard library imports
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

-- Project specific imports
use work.data_types.all;
use work.FunkyMiniBus.all;
use work.utilities_pkg.all;


entity top is
    PORT(
        -- Input Ports --
        clk : in std_logic;
        data_in : in tLinksIn;

        -- Output Ports --
        header_out : out tDTCInHeaderArray := NullDTCInHeaderArray;
        data_out : out tStubArray
    );
end top;

architecture Behavioral of top is
    signal bus_out, bus_in : tFMBusArray;

    signal counter : integer := 0; -- Counter to more easily calculate latency
    signal links_in : tLinksIn := NullLinksIn; -- Input word for CIC
    signal header : tDTCInHeaderArray := NullDTCInHeaderArray; -- Header of CIC word
    signal DTCIn_stubs : tDTCInStubArray; -- Array of CIC stubs formed from CIC word
    signal stubs : tStubArray; -- Array of converted stubs
    signal link_number : tLinkLUT := cLinkLUT;

begin

-- Process for increasing counter by one each clock cycle
process(clk)
begin
    if rising_edge(clk) then
        counter <= counter + 1;
    end if;
end process;

-- Connections required for test synthesis
links_in <= data_in;
header_out <= header;
data_out <= stubs;


gLinksFormat : for i in 0 to link_count - 1 generate
    -- Dummy instance to generate CIC words from file
    -- LinkGeneratorInstance : entity work.LinkGenerator
    -- port map(
    --    -- Input Ports --
    --    clk => clk,
    --
    --    -- Output Ports --
    --    links_out => links_in(i)
    -- );

    -- Input links are formatted into a more readable format, separates out header
    LinkFormatterInstance : entity work.LinkFormatter
        port map(
            -- Input Ports --
            clk => clk,
            link_in => links_in(i),

            -- Output Ports --
            header => header(i),
            stubs(0) => DTCIn_stubs(i * stubs_per_word),
            stubs(1) => DTCIn_stubs(i * stubs_per_word + 1)
        );
end generate;


-- Each CIC stub is then converted into psuedo-global coordinates
gStubFormatter : for i in 0 to stubs_per_word*link_count - 1 generate
    signal link_index : unsigned(4 downto 0) := (others => '0');
begin
    link_index <= to_unsigned(link_number(i), 5);

    StubFormatterInstance : entity work.StubFormatter
    generic map(
        index => i
    )
    port map(
        -- Input Ports --
        clk => clk,
        header => header(i/2),
        stub_in => DTCIn_stubs(i),
        bus_in => bus_in,
        link_index => link_index,

        -- Output Ports --
        stub_out => stubs(i)
        -- bus_out => bus_out
    );
end generate;


-- Test entity for checking if IP core creation would work
--LUTTestInstance : entity work.blk_mem_gen_0
--    port map(
--        clka => clk,
--        addra => b"0001",
--        ena => '1',
--        douta => lut_check
--    );tance : entity work.blk_mem_gen_0
--    port map(
--        clka => clk,
--        addra => b"0001",
--        ena => '1',
--        douta => lut_check
--    );

end Behavioral;
