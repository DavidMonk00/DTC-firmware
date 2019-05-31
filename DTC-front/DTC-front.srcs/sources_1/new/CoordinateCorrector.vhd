----------------------------------------------------------------------------------
-- Company: Imperial College London
-- Engineer: David Monk
--
-- Create Date: 05/17/2019 02:12:35 PM
-- Design Name:
-- Module Name: CoordinateCorrector - Behavioral
-- Project Name: DTC Front End
-- Target Devices: KU15P
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Revision 0.1 - Code Review: 20190631
--
-- Additional Comments:
--
----------------------------------------------------------------------------------

-- Standard library imports
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Project specific imports
use work.data_types.all;


-- NOTE: Not convinced this will be the final port map, the corrector should
-- take the stub and the matrix as inputs, with a corrected stub as the output.
-- Also need strip and z values for the module for matrix multiplication.
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
    -- buffer vector required? Multiplications should be performed in parallel,
    -- therefore this should not be needed, given matrix arrives on first clock.
    type xBuff is record
        strip : signed(10 downto 0);
        z : signed(4 downto 0);
    end record;
    signal matrix : tCorrectionMatrix := testCorrectionMatrix;

begin

end Behavioral;
