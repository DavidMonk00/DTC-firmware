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
    PORT (
        -- Input Ports --
        clk : in std_logic;
        links_in : in tLinksIn;

        -- Output Ports --
        data_out : out tRouterInputArray := NullRouterInputArray
    );
end top;

architecture Behavioral of top is
    signal bus_out, bus_in : tFMBusArray;
    -- signal header : tHeaderArray := NullHeaderArray; -- Header of CIC word
    -- signal CIC_stubs : tCICStubArray; -- Array of CIC stubs formed from CIC word

    signal CICStubPipe : tCICStubPipe( 0 to 10 ) := (OTHERS=>NullCICStubArray);
    signal FormattedStubPipe : tStubPipe( 0 to 10 ) := (OTHERS=>NullStubArray);
    signal CorrectedStubPipe : tStubPipe( 0 to 10 ) := (OTHERS=>NullStubArray);


    -- signal pre_stubs : tStubArray; -- Array of converted stubs
    -- signal stubs : tStubArray;
    signal matrices : tCorrectionMatrixArray := NullCorrectionMatrixArray;
    signal matrix_bus_out, matrix_bus_in : tFMBus(0 to 71);

begin


    LinkFormatterInstance : entity work.LinkFormatter2
    port map (
        clk => clk,
        LinksIn => links_in,
        StubPipeOut => CICStubPipe
    );

    StubFormatterInstance : entity work.StubFormatter2
    port map (
        clk => clk,
        bus_in => bus_in,
        bus_out => bus_out,
        StubPipeIn => CICStubPipe,
        StubPipeOut => FormattedStubPipe
    );

    GetCorrectionMatrixInstance : entity work.GetCorrectionMatrix
    port map (
        clk => clk,
        bus_in => matrix_bus_in,
        -- bus_out => bus_out
        StubPipeIn => CICStubPipe,
        MatricesOut => matrices
    );

    CoordinateCorrectorInstance : entity work.CoordinateCorrector
    port map (
        clk => clk,
        StubPipeIn => FormattedStubPipe,
        MatricesIn => matrices,

        -- Output Ports --
        StubPipeOut => CorrectedStubPipe
    );

    RouterInputReformattingInstance : entity work.RouterInputReformatting
    port map (
        clk => clk,
        StubPipeIn => CorrectedStubPipe,
        WordsOut => data_out
    );


-- -- Each CIC stub is then converted into psuedo-global coordinates
-- gStubFormatter : for i in 0 to stubs_per_word*link_count - 1 generate
--     signal link_index : unsigned(4 downto 0) := (others => '0');
-- begin
--     link_index <= to_unsigned(link_number(i), 5);
--
--
--     GetCorrectionMatrixInstance : entity work.GetCorrectionMatrix
--     generic map (
--         index => i
--     )
--     port map (
--         -- Input Ports --
--         clk => clk,
--         stub_in => CIC_stubs(i),
--         bus_in => matrix_bus_in,
--         link_index => link_index,
--
--         -- Output Ports
--         matrix => matrices(i)
--         -- bus_out => bus_out
--     );
--
--     CoordinateCorrectorInstance : entity work.CoordinateCorrector
--     port map (
--         -- Input Ports --
--         clk => clk,
--         stub_in => pre_stubs(i),
--         matrix => matrices(i),
--
--         -- Output Ports --
--         stub_out => stubs(i)
--     );
--
--     RouterInputReformattingInstance : entity work.RouterInputReformatting
--     port map (
--         -- Input Ports --
--         clk => clk,
--         stub_in => stubs(i),
--
--         -- Ouput Ports --
--         word_out(0) => data_out(i * 2),
--         word_out(1) => data_out(i * 2 + 1)
--     );
-- end generate;

end Behavioral;
