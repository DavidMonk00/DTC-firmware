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
        -- Input Ports --
        clk : in std_logic;
        dtcin_stub : in tDTCInStub;
        stub_in : in tStub;
        address : std_logic_vector(17 downto 0);
        
        -- Output Ports --
        stub_out : out tStub := NullStub
    );
end CoordinateCorrector;

architecture Behavioral of CoordinateCorrector is
    type xBuff is record
        strip : signed(10 downto 0);
        z : signed(4 downto 0);
    end record;
    signal matrix : tCorrectionMatrix := testCorrectionMatrix; 

begin

end Behavioral;
