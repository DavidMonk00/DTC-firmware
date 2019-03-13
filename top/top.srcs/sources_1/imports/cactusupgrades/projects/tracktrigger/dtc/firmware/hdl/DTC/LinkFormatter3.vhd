--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

USE WORK.stub_pkg.ALL;
USE WORK.utilities_pkg.ALL;
USE work.mp7_data_types.ALL;

ENTITY SharingLinkFormatter IS
  GENERIC(
    LinkCount , StubCount : INTEGER 
    );
  PORT(
    clk       : IN STD_LOGIC; --! The algorithm clock
    LinksIn   : IN ldata( LinkCount-1 DOWNTO 0 ) := ( OTHERS => LWORD_NULL );
    StubsOut  : OUT tUnconstrainedStubArray( 0 TO StubCount-1 )   := ( OTHERS => NullStub );
    StubsIn   : IN tUnconstrainedStubArray( 0 TO StubCount-1 )    := ( OTHERS => NullStub );
    LinksOut  : OUT ldata( LinkCount-1 DOWNTO 0 ) := ( OTHERS => LWORD_NULL )
  );
END SharingLinkFormatter;



-- -------------------------------------------------------------------------------------------------------------------------------------------------
ARCHITECTURE RTL OF SharingLinkFormatter IS
  SIGNAL FlatLinks , FlatStubs : STD_LOGIC_VECTOR( 32*LinkCount - 1 DOWNTO 0 ) := (OTHERS=>'0');
BEGIN

  g1 : FOR i IN 0 TO StubCount-1 GENERATE
    CONSTANT LowLink : INTEGER := (48*i)/32;
    SIGNAL lVector : STD_LOGIC_VECTOR( 47 DOWNTO 0 ) := (OTHERS=>'0');

  BEGIN

    FlatStubs( (48*i) + 47 DOWNTO (48*i) ) <= ToStdLogicVector( StubsIn( i ) , 48 );
    lVector <= FlatLinks( (48*i) + 47 DOWNTO (48*i) );

    -- being lazy and doing this in a process so I can use the convenience function AND assign the data-valid flag
    -- the data-valid flag is actually probably not necessary, so we could simplify things and save a register by
    -- changing this process to a single concurrent statement
    prc : process( clk )
    BEGIN
      if rising_edge( clk) then
        StubsOut( i ) <= ToStub( lVector );
        StubsOut( i ).DataValid <= ToBoolean( LinksIn( LowLink+1 ).Valid AND LinksIn( LowLink ).Valid );
      end if;
    end process;

  END GENERATE g1;



  g2 : FOR i IN 0 TO LinkCount-1 GENERATE
    CONSTANT Stub1 : INTEGER := ((i*32)-16)/48;
    CONSTANT Stub2 : INTEGER := ((i*32)+16)/48;
  BEGIN

    FlatLinks( (32*i) + 31 DOWNTO (32*i) ) <= LinksIn( i ).data;

    -- Just relabel bits
    LinksOut( i ).data <= FlatStubs( (32*i) + 31 DOWNTO (32*i) );
    LinksOut( i ).valid <= ToStdLogic( StubsIn( Stub1 ).DataValid AND StubsIn( Stub2 ).DataValid  );

  END GENERATE g2;



END ARCHITECTURE RTL;
-- -------------------------------------------------------------------------------------------------------------------------------------------------


