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
    Port (
        -- Input Ports --
        clk : in std_logic;
        stub_in : in tDTCInStub;
        bus_in : in tFMBusArray;
        link_index : in unsigned(4 downto 0);

        -- Output Ports --
        matrix : out tCorrectionMatrix;
        bus_out : out tFMBusArray
    );
end GetCorrectionMatrix;

architecture Behavioral of GetCorrectionMatrix is

begin


end Behavioral;
