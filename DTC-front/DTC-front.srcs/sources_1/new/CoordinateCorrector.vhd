----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 05/17/2019 02:12:35 PM
-- Design Name:
-- Module Name: CoordinateCorrector - Behavioral
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

use work.data_types.all;

entity CoordinateCorrector is
    PORT(
        clk : in std_logic;
        stub_in : in tDTCInStub;
        stub_out : out tStub := NullStub
    );
end CoordinateCorrector;

architecture Behavioral of CoordinateCorrector is

begin


end Behavioral;
