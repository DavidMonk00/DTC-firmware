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
        stub_in : in tPreCorrectionStub;
        matrix : in tCorrectionMatrix;

        -- Output Ports --
        stub_out : out tStub := NullStub
    );
end CoordinateCorrector;

architecture Behavioral of CoordinateCorrector is
    -- buffer vector required? Multiplications should be performed in parallel,
    -- therefore this should not be needed, given matrix arrives on first clock.
    type tCoordVector is record
        r : integer;
        phi : integer;
        z : integer;
    end record;

    signal multiplied_matrix : tCorrectionMatrix := NullCorrectionMatrix;
    signal buff : tUnconstrainedStubArray(0 to 1) := (others => NullStub);
    signal vector : tCoordVector := (others => 0);

begin
    pCorrection : process(clk)
    begin
        if rising_edge(clk) then
            buff(0).header <= stub_in.header;
            buff(0).payload <= stub_in.payload;
            buff(1) <= buff(0);

            lMultiplication : for i in 0 to 5 loop
                if (i mod 2) = 0 then
                    multiplied_matrix(i) <= matrix(i)*to_integer(stub_in.intrinsic.strip);
                else
                    multiplied_matrix(i) <= matrix(i)*to_integer(stub_in.intrinsic.column);
                end if;
            end loop;

            vector.r <= multiplied_matrix(0) + multiplied_matrix(1);
            vector.phi <= multiplied_matrix(2) + multiplied_matrix(3);
            vector.z <= multiplied_matrix(4) + multiplied_matrix(5);

            stub_out.header <= buff(1).header;
            stub_out.payload.r <= buff(1).payload.r + vector.r;
            stub_out.payload.z <= buff(1).payload.z + vector.z;
            stub_out.payload.phi <= buff(1).payload.phi + vector.phi;
            stub_out.payload.alpha <= buff(1).payload.alpha;
            stub_out.payload.layer <= buff(1).payload.layer;
            stub_out.payload.barrel <= buff(1).payload.barrel;
            stub_out.payload.module <= buff(1).payload.module;
            stub_out.payload.valid <= buff(1).payload.valid;
            stub_out.payload.bend <= buff(1).payload.bend;
        end if;
    end process;
end Behavioral;
