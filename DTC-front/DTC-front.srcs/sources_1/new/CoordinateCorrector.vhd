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
    type tCoordVector is record
        r : integer;
        phi : integer;
        z : integer;
    end record;

    signal multiplied_matrix, matrix_buffer : tCorrectionMatrix := NullCorrectionMatrix;
    signal buff : tUnconstrainedStubArray(0 to 3) := (others => NullStub);
    signal vector, vector_buff : tCoordVector := (others => 0);
    signal strip, column : integer := 0;

begin
    pBuffer : process(clk)
    begin
        if rising_edge(clk) then
            buff(0).header <= stub_in.header;
            buff(0).payload <= stub_in.payload;
            fBuffer : for i in 1 to 3 loop
                buff(i) <= buff(i - 1);
            end loop;

            strip <= to_integer(stub_in.intrinsic.strip);
            column <= to_integer(stub_in.intrinsic.column);

            matrix_buffer <= matrix;
        end if;
    end process;


    pMultiplication : process(clk)
    begin
        if rising_edge(clk) then
            lMultiplication : for i in 0 to 5 loop
                if (i mod 2) = 0 then
                    multiplied_matrix(i) <= matrix_buffer(i)*strip;
                else
                    multiplied_matrix(i) <= matrix_buffer(i)*column;
                end if;
            end loop;
        end if;
    end process;


    pAddition : process(clk)
    begin
        if rising_edge(clk) then
            vector_buff.r <= multiplied_matrix(0) + multiplied_matrix(1);
            vector_buff.z <= multiplied_matrix(2) + multiplied_matrix(3);
            vector_buff.phi <= multiplied_matrix(4) + multiplied_matrix(5);

            vector.r <= buff(2).payload.r + vector_buff.r;
            vector.z <= buff(2).payload.z + vector_buff.z;
            vector.phi <= buff(2).payload.phi + vector_buff.phi;
        end if;
    end process;


    pOutput : process(clk)
    begin
        if rising_edge(clk) then
            stub_out.header <= buff(3).header;
            stub_out.payload.r <= vector.r;
            stub_out.payload.z <= vector.z;
            stub_out.payload.phi <= vector.phi;
            stub_out.payload.alpha <= buff(3).payload.alpha;
            stub_out.payload.layer <= buff(3).payload.layer;
            stub_out.payload.barrel <= buff(3).payload.barrel;
            stub_out.payload.module <= buff(3).payload.module;
            stub_out.payload.valid <= buff(3).payload.valid;
            stub_out.payload.bend <= buff(3).payload.bend;
        end if;
    end process;

end Behavioral;
