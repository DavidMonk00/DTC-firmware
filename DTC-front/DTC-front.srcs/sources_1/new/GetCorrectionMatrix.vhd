----------------------------------------------------------------------------------
-- Company: Imperial College London
-- Engineer: David Monk
--
-- Create Date: 05/29/2019 11:12:08 AM
-- Design Name:
-- Module Name: GetArray - Behavioral
-- Project Name: DTC Front End
-- Target Devices: KU15P
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Revision 0.1 - Code Review: 20190531
-- Additional Comments:
--
----------------------------------------------------------------------------------


-- Standard library imports
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Project specific imports
use work.data_types.all;
use work.FunkyMiniBus.all;
use work.utilities_pkg.all;


entity GetCorrectionMatrix is
    GENERIC (
        index : integer
    );
    Port (
        -- Input Ports --
        clk : in std_logic;
        stub_in : in tDTCInStub;
        bus_in : in tFMBus(0 to 71);
        link_index : in unsigned(4 downto 0);

        -- Output Ports --
        matrix : out tCorrectionMatrix := NullCorrectionMatrix;
        bus_out : out tFMBus(0 to 71)
    );
end GetCorrectionMatrix;

architecture Behavioral of GetCorrectionMatrix is
    signal address, data : std_logic_vector(17 downto 0) := (others => '0');
    signal clk_bus : std_logic := '0';

    -- Constants required for FunkyMiniBus
    constant x : integer := bus_out'low + index;
    subtype A is natural range x + 0 to x + 0;
begin
    MatrixLutInstance : ENTITY work.GenPromClocked
        GENERIC MAP(
          FileName => "random_0.mif",
          BusName  => "A/PosLutA" & INTEGER'IMAGE( index )
        )
        PORT MAP(
            -- Input Ports --
            clk => clk ,
            AddressIn => address(10 downto 0),
            BusIn => bus_in(A),
            BusClk => clk_bus,

            -- Output Ports --
            DataOut => data,
            BusOut => bus_out(A)
        );

    gMatrix : for i in 0 to 5 generate
        matrix(i) <= to_integer(signed(data(4 + i downto i)));
    end generate;

end Behavioral;
