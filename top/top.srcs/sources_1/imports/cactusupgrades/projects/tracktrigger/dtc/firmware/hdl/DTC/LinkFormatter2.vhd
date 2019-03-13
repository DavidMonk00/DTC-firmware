--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

USE WORK.stub_pkg.ALL;
USE WORK.utilities_pkg.ALL;

USE work.mp7_data_types.ALL;

ENTITY OutputLinkFormatter IS
  PORT(
    clk      : IN STD_LOGIC; --! The algorithm clock
    StubsIn0 : IN tStubArray            := NullStubArray;
    StubsIn1 : IN tStubArray            := NullStubArray;
    LinksOut : OUT ldata( 71 DOWNTO 0 ) := ( OTHERS => LWORD_NULL )
  );
END OutputLinkFormatter;


ARCHITECTURE behavioral OF OutputLinkFormatter IS
BEGIN


g1                               : FOR x IN 0 TO 17 GENERATE
  SIGNAL Flattened0 , Flattened1 : STD_LOGIC_VECTOR( 71 DOWNTO 0 ) := ( OTHERS => '0' );
BEGIN

  Flattened0                             <= ToStdLogicVector( StubsIn0( x ) , 72 );
  Flattened1                             <= ToStdLogicVector( StubsIn1( x ) , 72 );

-- ---------------------------------------
--PROCESS( clk )
--BEGIN
--  IF( RISING_EDGE( clk ) ) THEN

      LinksOut( ( 2 * x ) + 0 ) .data    <= Flattened0( 31 DOWNTO 0 );
      LinksOut( ( 2 * x ) + 0 ) .valid   <= ToStdLogic( StubsIn0( x ) .DataValid );
      LinksOut( ( 2 * x ) + 0 ) .strobe  <= '1';

      LinksOut( ( 2 * x ) + 1 ) .data    <= x"0000" & Flattened0( 47 DOWNTO 32 );
      LinksOut( ( 2 * x ) + 1 ) .valid   <= ToStdLogic( StubsIn0( x ) .DataValid );
      LinksOut( ( 2 * x ) + 1 ) .strobe  <= '1';

      LinksOut( ( 2 * x ) + 36 ) .data   <= Flattened1( 31 DOWNTO 0 );
      LinksOut( ( 2 * x ) + 36 ) .valid  <= ToStdLogic( StubsIn1( x ) .DataValid );
      LinksOut( ( 2 * x ) + 36 ) .strobe <= '1';

      LinksOut( ( 2 * x ) + 37 ) .data   <= x"0000" & Flattened1( 47 DOWNTO 32 );
      LinksOut( ( 2 * x ) + 37 ) .valid  <= ToStdLogic( StubsIn1( x ) .DataValid );
      LinksOut( ( 2 * x ) + 37 ) .strobe <= '1';

--    END IF;
---- ---------------------------------------
--  END PROCESS;

END GENERATE g1;

END ARCHITECTURE behavioral;
