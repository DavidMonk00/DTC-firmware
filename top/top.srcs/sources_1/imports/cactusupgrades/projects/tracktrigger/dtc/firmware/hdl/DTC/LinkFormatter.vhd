--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

USE WORK.stub_pkg.ALL;
USE WORK.utilities_pkg.ALL;
USE work.mp7_data_types.ALL;

ENTITY InputLinkFormatter IS
  PORT(
    clk        : IN STD_LOGIC; --! The algorithm clock
    LinksIn    : IN ldata( 71 DOWNTO 0 ) := ( OTHERS => LWORD_NULL );
    StubsOut   : OUT tCICstubArray       := NullCICstubArray;
    HeadersOut : OUT tCICheaderArray     := NullCICheaderArray
  );
END InputLinkFormatter;



-- -------------------------------------------------------------------------------------------------------------------------------------------------
ARCHITECTURE PreframedCBCdata OF InputLinkFormatter IS
BEGIN

  g1               : FOR i IN 0 TO 71 GENERATE
    SIGNAL Counter : INTEGER RANGE 0 TO 3 := 0;
  BEGIN
-- ---------------------------------------
    PROCESS( clk )
    BEGIN
      IF( RISING_EDGE( clk ) ) THEN
        IF( LinksIn( i ) .valid = '0' ) THEN
          StubsOut( i ) <= NullCICstub;
          Counter       <= 0;
        ELSE
          IF( Counter = 0 ) THEN
            StubsOut( i ) .ROC       <= UNSIGNED( LinksIn( i ) .Data( 2 DOWNTO 0 ) ); -- 3 bit -> 3 bits
            StubsOut( i ) .Strip     <= UNSIGNED( LinksIn( i ) .Data( 10 DOWNTO 3 ) ); -- 8 bit -> 11 bits
            StubsOut( i ) .Bx        <= "00" & UNSIGNED( LinksIn( i ) .Data( 13 DOWNTO 11 ) ); -- 3 bit -> 14 bits
            StubsOut( i ) .Bend      <= SIGNED( LinksIn( i ) .Data( 17 DOWNTO 14 ) ); -- 4 bit -> 18 bits
            StubsOut( i ) .StubValid <= ToBoolean( LinksIn( i ) .Data( 18 ) ); -- 1 bit -> 19 bits
            StubsOut( i ) .DataValid <= TRUE;
          END IF;

          Counter <= ( Counter + 1 ) MOD 4;
        END IF;
      END IF;
    END PROCESS;
-- ---------------------------------------
  END GENERATE g1;

END ARCHITECTURE PreframedCBCdata;
-- -------------------------------------------------------------------------------------------------------------------------------------------------



-- -------------------------------------------------------------------------------------------------------------------------------------------------
ARCHITECTURE CBC_FEC5_8bit_240Mhz OF InputLinkFormatter IS
BEGIN

  g1               : FOR i IN 0 TO 71 GENERATE
    SIGNAL StubOut , HeaderOut : lword := LWORD_NULL;
  BEGIN

    UnpackerInstance : ENTITY work.CICunpacker
    GENERIC MAP( 
      IncomingDataWidth => 8,
      OutgoingStubWidth => 18,
      OutgoingHeaderWidth => 28,
      FramesPerBoxCar => 48
    )
    PORT MAP(
      clk       => clk,
      LinkIn    => LinksIn( i ),
      StubOut   => StubOut,
      HeaderOut => HeaderOut
    );

    StubsOut( i ) <= ToCBCstub( StubOut );
    HeadersOut( i ) <= ToCICheader( HeaderOut );

  END GENERATE g1;
END ARCHITECTURE CBC_FEC5_8bit_240Mhz;
-- -------------------------------------------------------------------------------------------------------------------------------------------------


-- -------------------------------------------------------------------------------------------------------------------------------------------------
ARCHITECTURE MPA_FEC5_8bit_240Mhz OF InputLinkFormatter IS
BEGIN

  g1               : FOR i IN 0 TO 71 GENERATE
    SIGNAL StubOut , HeaderOut : lword := LWORD_NULL;
  BEGIN

    UnpackerInstance : ENTITY work.CICunpacker
    GENERIC MAP( 
      IncomingDataWidth => 8,
      OutgoingStubWidth => 21,
      OutgoingHeaderWidth => 28,
      FramesPerBoxCar => 48
    )
    PORT MAP(
      clk       => clk,
      LinkIn    => LinksIn( i ),
      StubOut   => StubOut,
      HeaderOut => HeaderOut
    );

    StubsOut( i ) <= ToMPAstub( StubOut );
    HeadersOut( i ) <= ToCICheader( HeaderOut );

  END GENERATE g1;
END ARCHITECTURE MPA_FEC5_8bit_240Mhz;
-- -------------------------------------------------------------------------------------------------------------------------------------------------


---- -------------------------------------------------------------------------------------------------------------------------------------------------
--ARCHITECTURE MPA_FEC5_16bit_240Mhz OF InputLinkFormatter IS
--BEGIN

--  g1               : FOR i IN 0 TO 71 GENERATE
--    SIGNAL StubOut , HeaderOut : lword := LWORD_NULL;
--  BEGIN

--    UnpackerInstance : ENTITY work.CICunpacker
--    GENERIC MAP( 
--      IncomingDataWidth => 16,
--      OutgoingStubWidth => 21,
--      OutgoingHeaderWidth => 28,
--      FramesPerBoxCar => 48
--    )
--    PORT MAP(
--      clk       => clk,
--      LinkIn    => LinksIn( i ),
--      StubOut   => StubOut,
--      HeaderOut => HeaderOut
--    );

--    StubsOut( i ) <= ToMPAstub( StubOut );
--    HeadersOut( i ) <= ToCICheader( HeaderOut );

--  END GENERATE g1;
--END ARCHITECTURE MPA_FEC5_16bit_240Mhz;
---- -------------------------------------------------------------------------------------------------------------------------------------------------








