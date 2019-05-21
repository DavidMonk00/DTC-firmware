----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/21/2019 10:29:34 AM
-- Design Name: 
-- Module Name: GetLUTs - Behavioral
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
USE work.FunkyMiniBus.ALL;
USE WORK.utilities_pkg.ALL;


entity GetLUTs is
    Port (
        clk : in STD_LOGIC;
        luts : out tLUTArray := NullLUTArray
    );
end GetLUTs;

architecture Behavioral of GetLUTs is
    SIGNAL BusIn , BusOut : tFMBus( 0 TO 71 );
    SIGNAL BusClk         : STD_LOGIC     := '0';
    
    CONSTANT x : INTEGER := BusOut'LOW + 0;
    SUBTYPE A IS NATURAL RANGE x + 0 TO x + 0;
    
    SIGNAL StripNumber , PosLutOut : STD_LOGIC_VECTOR( 17 DOWNTO 0 ) := (OTHERS=>'0');
--    SIGNAL StubsInClk     : tCICstub := NullCICstub;
    
    
begin

    PosLutInstance : ENTITY work.GenPromClocked
    GENERIC MAP(
      FileName => "A_PosLutLow_11to18.mif" ,
      BusName  => "A/PosLutA" & INTEGER'IMAGE( 0 )
    )
    PORT MAP(
      clk       => clk ,
      AddressIn => StripNumber( 10 DOWNTO 0 ) ,
      DataOut   => PosLutOut( 17 DOWNTO 0 ) ,
      BusIn     => BusIn( A ) ,
      BusOut    => BusOut( A ) ,
      BusClk    => BusClk
    );
    
    luts(0) <= PosLutOut;
    
end Behavioral;
