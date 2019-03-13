-- ----------------------------------------------
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

USE WORK.stub_pkg.ALL;
USE WORK.others_pkg.ALL;
USE WORK.XMLutilities_pkg.ALL;
USE WORK.utilities_pkg.ALL;

USE work.mp7_data_types.ALL;

--! Using IPbus
USE work.ipbus.ALL;

--! Writing to and from files
USE STD.TEXTIO.ALL;

ENTITY DtcTop IS
  PORT(
    clk       : IN STD_LOGIC; --! The algorithm clock
    LinksIn   : IN ldata( 71 DOWNTO 0 )  := ( OTHERS => LWORD_NULL );
    LinksOut  : OUT ldata( 71 DOWNTO 0 ) := ( OTHERS => LWORD_NULL );
-- Configuration
    ipbus_clk : IN STD_LOGIC             := '0'; --! The IPbus clock
    ipbus_rst : IN STD_LOGIC             := '0';
    ipbus_in  : IN ipb_wbus              := IPB_WBUS_NULL;
    ipbus_out : OUT ipb_rbus             := IPB_RBUS_NULL
  );
END DtcTop;

--! @brief Architecture definition for entity StubStateServer
--! @details Detailed description
ARCHITECTURE behavioral OF DtcTop IS
  SIGNAL InputStubs     : tCICstubArray := NullCICstubArray;
  SIGNAL CICheaders : tCICheaderArray     := NullCICheaderArray;
  SIGNAL PrimaryStubs , StubsForOtherChip , MergedStubsForOtherChip , StubsFromOtherChip , TmBxStubs , AlignedStubs : tStubArray    := NullStubArray;
  SIGNAL MergedStubsFromOtherChip  , CoarseTmBxStubs  : tUnconstrainedStubArray( 0 TO 95 )    := ( OTHERS => NullStub );

  SIGNAL CICLinks : ldata( 71 DOWNTO 0 )  := ( OTHERS => LWORD_NULL );

BEGIN

  -- Unpack 18 MP7 links to 72 "CIC" links
  g1a: for i in 0 to 17 generate
    g1b: for j in 0 to 3 generate
      CICLinks( (4*i) + j ).data( 7 downto 0 ) <= LinksIn( i ).data( (8*j)+7 downto (8*j) );
      CICLinks( (4*i) + j ).valid <= LinksIn( i ).valid;
    end generate g1b;
  end generate g1a;

-- Unpack the links to stub objects
  InputLinkFormatterInstance : ENTITY work.InputLinkFormatter( CBC_FEC5_8bit_240Mhz )
  --InputLinkFormatterInstance : ENTITY work.InputLinkFormatter( MPA_FEC5_8bit_240Mhz )
  PORT MAP(
    clk      => clk ,
    LinksIn  => CICLinks ,
    StubsOut => InputStubs , 
    HeadersOut => CICheaders
  );

  StubFormatterInstance : ENTITY work.StubFormatter
  PORT MAP(
    clk      => clk ,
    StubsIn  => InputStubs ,
    PrimaryStubsOut => PrimaryStubs,
    SecondaryStubsOut => StubsForOtherChip
  );

  MergeStubsForSharingInstance : ENTITY work.MergeStubsForSharing
  PORT MAP(
    clk      => clk ,
    StubsIn  => StubsForOtherChip ,
    StubsOut => MergedStubsForOtherChip
  );

  SharingLinkFormatterInstance: ENTITY work.SharingLinkFormatter
  GENERIC MAP (
    LinkCount => 12,
    StubCount => 8
  )
  PORT MAP(
    clk        => clk,
    LinksIn    => LinksIn( 71 DOWNTO 60 ),
    StubsOut   => StubsFromOtherChip ( 0 to 7 ),
    StubsIn    => MergedStubsForOtherChip ( 0 to 7 ),
    LinksOut   => LinksOut( 71 DOWNTO 60 )
  );

  g2 : FOR i IN 0 TO 7 GENERATE 
    MergedStubsFromOtherChip( (10*i) TO (10*i)+9 ) <= PrimaryStubs( (9*i) TO (9*i)+8 ) & StubsFromOtherChip(i) ;
  end generate g2;

  g3                   : FOR i IN 0 TO 15 GENERATE
    CoarseTmBxInstance : ENTITY work.StubDistributionServer
    GENERIC MAP(
      SelectionKey  => CoarseTmBx
    )
    PORT MAP(
      clk           => clk ,
      StubsIn( 0 )  => MergedStubsFromOtherChip( ( 5 * i ) + 0 ) ,
      StubsIn( 1 )  => MergedStubsFromOtherChip( ( 5 * i ) + 1 ) ,
      StubsIn( 2 )  => MergedStubsFromOtherChip( ( 5 * i ) + 2 ) ,
      StubsIn( 3 )  => MergedStubsFromOtherChip( ( 5 * i ) + 3 ) ,
      StubsIn( 4 )  => MergedStubsFromOtherChip( ( 5 * i ) + 4 ) ,
      StubsOut( 0 ) => CoarseTmBxStubs( 0 + i ) ,
      StubsOut( 1 ) => CoarseTmBxStubs( 16 + i ) ,
      StubsOut( 2 ) => CoarseTmBxStubs( 32 + i ) ,
      StubsOut( 3 ) => CoarseTmBxStubs( 48 + i ) ,
      StubsOut( 4 ) => CoarseTmBxStubs( 64 + i ) ,
      StubsOut( 5 ) => CoarseTmBxStubs( 80 + i )
    );
  END GENERATE g3;

  g4                 : FOR i IN 0 TO 11 GENERATE
    FineTmBxInstance : ENTITY work.StubDistributionServer
    GENERIC MAP(
      SelectionKey  => FineTmBx
    )
    PORT MAP(
      clk           => clk ,
      StubsIn( 0 )  => CoarseTmBxStubs( ( 8 * i ) + 0 ) ,
      StubsIn( 1 )  => CoarseTmBxStubs( ( 8 * i ) + 1 ) ,
      StubsIn( 2 )  => CoarseTmBxStubs( ( 8 * i ) + 2 ) ,
      StubsIn( 3 )  => CoarseTmBxStubs( ( 8 * i ) + 3 ) ,
      StubsIn( 4 )  => CoarseTmBxStubs( ( 8 * i ) + 4 ) ,
      StubsIn( 5 )  => CoarseTmBxStubs( ( 8 * i ) + 5 ) ,
      StubsIn( 6 )  => CoarseTmBxStubs( ( 8 * i ) + 6 ) ,
      StubsIn( 7 )  => CoarseTmBxStubs( ( 8 * i ) + 7 ) ,
      StubsOut( 0 ) => TmBxStubs( 0 + i ) ,
      StubsOut( 1 ) => TmBxStubs( 12 + i ) ,
      StubsOut( 2 ) => TmBxStubs( 24 + i )
    );
  END GENERATE g4;

  AlignmentFifoInstance : ENTITY work.AlignmentFifo
  PORT MAP(
    clk      => clk ,
    StubsIn  => TmBxStubs ,
    StubsOut => AlignedStubs
  );

  OutputLinkFormatterInstance: ENTITY work.SharingLinkFormatter
  GENERIC MAP (
    LinkCount => 54,
    StubCount => 36
  )
  PORT MAP(
    clk        => clk,
    StubsIn    => AlignedStubs ( 0 to 35 ),
    LinksOut   => LinksOut( 53 DOWNTO 0 )
  );

--  OutputLinkFormatterInstance : ENTITY work.OutputLinkFormatter
--  PORT MAP(
--    clk      => clk ,
--    StubsIn0 => AlignedStubs ,
--    LinksOut => LinksOut
--  );

END ARCHITECTURE behavioral;
