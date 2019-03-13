--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

USE WORK.XMLutilities_pkg.ALL;
USE WORK.utilities_pkg.ALL;

USE work.mp7_data_types.ALL;


-- ----------------------------------------------
PACKAGE stub_pkg IS

  TYPE tSelectionKey IS( CoarseTmBx , FineTmBx );

  SUBTYPE tAddress   IS NATURAL RANGE 0 TO 511;
  TYPE tAddressArray IS ARRAY( 0 TO 7 ) OF tAddress;
  TYPE tAddressPipe  IS ARRAY( NATURAL RANGE <> ) OF tAddressArray;

  CONSTANT NullAddress                   : tAddress      := 0;
  CONSTANT NullAddressArray              : tAddressArray := ( OTHERS => NullAddress );

  FUNCTION InitializeAddressPipe( LENGTH : INTEGER ) RETURN tAddressPipe;


  TYPE tCICstub IS RECORD
    CIC       : UNSIGNED( 6 DOWNTO 0 );
    ROC       : UNSIGNED( 2 DOWNTO 0 );
    Strip     : UNSIGNED( 7 DOWNTO 0 );
    Bend      : SIGNED( 2 DOWNTO 0 );
    Z         : UNSIGNED( 3 DOWNTO 0 ); --CBC packs 4th bend bit into LSB of, otherwise unused, Z
    Bx        : UNSIGNED( 4 DOWNTO 0 );
    StubValid : BOOLEAN;
    DataValid : BOOLEAN;
  END RECORD;

  TYPE tUnconstrainedCICstubArray IS ARRAY( INTEGER RANGE <> ) OF tCICstub;
  SUBTYPE tCICstubArray           IS tUnconstrainedCICstubArray( 0 TO 71 );
  TYPE tCICstubPipe               IS ARRAY( INTEGER RANGE <> ) OF tCICstubArray;

  CONSTANT NullCICstub      : tCICstub      := ( ( OTHERS => '0' ) , ( OTHERS => '0' ) , ( OTHERS => '0' ) , ( OTHERS => '0' ) , ( OTHERS => '0' ) , ( OTHERS => '0' ) , FALSE , FALSE );
  CONSTANT NullCICstubArray : tCICstubArray := ( OTHERS   => NullCICstub );


  TYPE tStub IS RECORD
    Bx        : UNSIGNED( 4 DOWNTO 0 );
    CIC       : UNSIGNED( 7 DOWNTO 0 ); 
    Bend      : SIGNED( 2 DOWNTO 0 );
    Z         : UNSIGNED( 3 DOWNTO 0 ); --CBC packs 4th bend bit into LSB of, otherwise unused, Z
    LocalR    : SIGNED( 4 DOWNTO 0 );
    LocalPhi  : SIGNED( 10 DOWNTO 0 );
    StubValid : BOOLEAN;
    DataValid : BOOLEAN;
  END RECORD;

  TYPE tUnconstrainedStubArray IS ARRAY( INTEGER RANGE <> ) OF tStub;
  SUBTYPE tStubArray           IS tUnconstrainedStubArray( 0 TO 71 );
  TYPE tStubPipe               IS ARRAY( INTEGER RANGE <> ) OF tStubArray;

  CONSTANT NullStub : tStub := ( ( OTHERS => '0' ) , ( OTHERS => '0' ) , ( OTHERS => '0' ) , ( OTHERS => '0' ) , ( OTHERS => '0' ) , ( OTHERS => '0' ) , FALSE , FALSE );
  CONSTANT NullStubArray           : tStubArray := ( OTHERS => NullStub );


  FUNCTION ToStdLogicVector( aStub : tStub ; CONSTANT width : INTEGER ) RETURN STD_LOGIC_VECTOR;
  FUNCTION ToStub( aStdLogicVector : STD_LOGIC_VECTOR ) RETURN tStub;


  --TYPE tGlobalStub IS RECORD
  --  Z         : SIGNED( 13 DOWNTO 0 );
  --  rT        : UNSIGNED( 11 DOWNTO 0 );
  --  phi0      : SIGNED( 14 DOWNTO 0 );
  --  Bend      : SIGNED( 4 DOWNTO 0 );
  --  StubValid : BOOLEAN;
  --  DataValid : BOOLEAN;
  --END RECORD;

  --TYPE tUnconstrainedGlobalStubArray IS ARRAY( INTEGER RANGE <> ) OF tGlobalStub;
  --SUBTYPE tGlobalStubArray           IS tUnconstrainedGlobalStubArray( 0 TO 71 );
  --TYPE tGlobalStubPipe               IS ARRAY( INTEGER RANGE <> ) OF tGlobalStubArray;

  --CONSTANT NullGlobalStub : tGlobalStub := ( ( OTHERS => '0' ) , ( OTHERS => '0' ) , ( OTHERS => '0' ) , ( OTHERS => '0' ) , FALSE , FALSE );
  --CONSTANT NullGlobalStubArray           : tGlobalStubArray := ( OTHERS => NullGlobalStub );

  --FUNCTION ToStdLogicVector( aStub : tGlobalStub ; CONSTANT width : INTEGER ) RETURN STD_LOGIC_VECTOR;
  --FUNCTION ToGlobalStub( aStdLogicVector : STD_LOGIC_VECTOR ) RETURN tGlobalStub;


  TYPE tCICheader IS RECORD
    ModuleIsPS : BOOLEAN;
    Status     : STD_LOGIC_VECTOR( 8 DOWNTO 0 );
    BXID       : UNSIGNED( 11 DOWNTO 0 );
    StubCount  : UNSIGNED( 5 DOWNTO 0 );  
    DataValid  : BOOLEAN;
  END RECORD;

  TYPE tUnconstrainedCICheaderArray IS ARRAY( INTEGER RANGE <> ) OF tCICheader;
  SUBTYPE tCICheaderArray           IS tUnconstrainedCICheaderArray( 0 TO 71 );

  CONSTANT NullCICheader : tCICheader := ( FALSE , ( OTHERS => '0' ) , ( OTHERS => '0' ) , ( OTHERS => '0' ) , false );
  CONSTANT NullCICheaderArray : tCICheaderArray := ( OTHERS => NullCICheader );


  FUNCTION ToCBCStub( aData : lWord ) RETURN tCICstub;
  FUNCTION ToMPAStub( aData : lWord ) RETURN tCICstub;
  FUNCTION ToCICheader( aData : lWord ) RETURN tCICheader;


END PACKAGE stub_pkg;
-- ----------------------------------------------



-- ----------------------------------------------
PACKAGE BODY stub_pkg IS

  --FUNCTION ToStdLogicVector( aStub : tGlobalStub ; CONSTANT width : INTEGER ) RETURN STD_LOGIC_VECTOR IS
  --  VARIABLE lStdLogicVector       : STD_LOGIC_VECTOR( width-1 DOWNTO 0 ) := ( OTHERS => '0' );
  --BEGIN
  --  lStdLogicVector( 13 DOWNTO 0 )  := STD_LOGIC_VECTOR( aStub.Z );
  --  lStdLogicVector( 25 DOWNTO 14 ) := STD_LOGIC_VECTOR( aStub.rT );
  --  lStdLogicVector( 40 DOWNTO 26 ) := STD_LOGIC_VECTOR( aStub.phi0 );
  --  lStdLogicVector( 45 DOWNTO 41 ) := STD_LOGIC_VECTOR( aStub.Bend );
  --  lStdLogicVector( 46 )           := ToStdLogic( aStub.StubValid );
  --  RETURN lStdLogicVector;
  --END FUNCTION ToStdLogicVector;

  --FUNCTION ToGlobalStub( aStdLogicVector : STD_LOGIC_VECTOR ) RETURN tGlobalStub IS
  --  VARIABLE lStub                 : tGlobalStub := NullGlobalStub;
  --BEGIN
  --  lStub.Z         := SIGNED( aStdLogicVector( 13 DOWNTO 0 ) );
  --  lStub.rT        := UNSIGNED( aStdLogicVector( 25 DOWNTO 14 ) );
  --  lStub.phi0      := SIGNED( aStdLogicVector( 40 DOWNTO 26 ) );
  --  lStub.Bend      := SIGNED( aStdLogicVector( 45 DOWNTO 41 ) );
  --  lStub.StubValid := ToBoolean( aStdLogicVector( 46 ) );
  --  RETURN lStub;
  --END FUNCTION ToGlobalStub;



  FUNCTION InitializeAddressPipe( LENGTH : INTEGER ) RETURN tAddressPipe IS
    VARIABLE lRet                        : tAddressPipe( 0 TO LENGTH-1 ) := ( OTHERS => ( OTHERS => 0 ) );
  BEGIN

    FOR i IN 0 TO LENGTH-1 LOOP
      lRet( i ) := ( OTHERS => ( ( LENGTH-1 ) - i ) );
    END LOOP;

    RETURN lRet;
  END FUNCTION InitializeAddressPipe;



  FUNCTION ToCBCStub( aData : lWord ) RETURN tCICstub IS
    VARIABLE lRet : tCICstub := NullCICstub;    
  BEGIN
    lRet .Bx        := "00" & UNSIGNED( aData.Data( 17 downto 15 ) ); -- 3 bit -> 18 bits
    lRet .ROC       := UNSIGNED( aData.Data( 14 downto 12 ) ); -- 3 bit -> 15 bits
    lRet .Strip     := UNSIGNED( aData.Data( 11 downto 4 ) );  -- 8 bit -> 12 bits
    lRet .Bend      := SIGNED( aData.Data( 2 downto 0 ) );     -- 4 bit -> 4 bits
    lRet .Z         := "000" & aData.Data( 3 ); --CBC packs 4th bend bit into LSB of, otherwise unused, Z
    lRet .StubValid := ToBoolean(aData.Data(18));
    lRet .DataValid := ToBoolean(aData.Valid);  
    return lRet;
  END FUNCTION ToCBCStub;


  FUNCTION ToMPAStub( aData : lWord ) RETURN tCICstub IS
    VARIABLE lRet : tCICstub := NullCICstub;    
  BEGIN
    lRet .Bx        := "00" & UNSIGNED( aData.Data( 20 downto 18 ) ); -- 3 bit -> 21 bits
    lRet .ROC       := UNSIGNED( aData.Data( 17 downto 15 ) ); -- 3 bit -> 18 bits
    lRet .Strip     := UNSIGNED( aData.Data( 14 downto 7 ) );  -- 8 bit -> 15 bits
    lRet .Bend      := SIGNED( aData.Data( 6 downto 4 ) );     -- 3 bit -> 7 bits
    lRet .Z         := UNSIGNED( aData.Data( 3 downto 0 ) );   -- 4 bit -> 4 bits
    lRet .StubValid := ToBoolean(aData.Data(21));
    lRet .DataValid := ToBoolean(aData.Valid);  
    return lRet;
  END FUNCTION ToMPAStub;

  FUNCTION ToCICheader( aData : lWord ) RETURN tCICheader IS
    VARIABLE lRet : tCICheader := NullCICheader;
  BEGIN
    lRet.ModuleIsPS := ToBoolean( aData.Data( 27 ) );
    lRet.Status     := aData.Data( 26 DOWNTO 18 );                
    lRet.BXID       := UNSIGNED( aData.Data( 17 DOWNTO 6 ) );
    lRet.StubCount  := UNSIGNED( aData.Data( 5 DOWNTO 0 ) );
    lRet.DataValid  := ToBoolean(aData.Data(28));
    return lRet;
  END FUNCTION ToCICheader;



  FUNCTION ToStdLogicVector( aStub : tStub ; CONSTANT width : INTEGER  ) RETURN STD_LOGIC_VECTOR IS
    VARIABLE lStdLogicVector       : STD_LOGIC_VECTOR( width-1 DOWNTO 0 ) := ( OTHERS => '0' );
  BEGIN
    lStdLogicVector(  4 DOWNTO 0 )  := STD_LOGIC_VECTOR( aStub.Bx );
    lStdLogicVector( 12 DOWNTO 5 )  := STD_LOGIC_VECTOR( aStub.CIC ); 
    lStdLogicVector( 15 DOWNTO 13 )  := STD_LOGIC_VECTOR( aStub.Bend );
    lStdLogicVector( 19 DOWNTO 16 )  := STD_LOGIC_VECTOR( aStub.Z );
    lStdLogicVector( 24 DOWNTO 20 )  := STD_LOGIC_VECTOR( aStub.LocalR  );
    lStdLogicVector( 35 DOWNTO 25 )  := STD_LOGIC_VECTOR( aStub.LocalPhi );
    lStdLogicVector( 36 ) := ToStdLogic( aStub.StubValid );
    RETURN lStdLogicVector;
  END FUNCTION ToStdLogicVector;

  FUNCTION ToStub( aStdLogicVector : STD_LOGIC_VECTOR ) RETURN tStub IS
    VARIABLE lStub                 : tStub := NullStub;
  BEGIN
    lStub.Bx       := UNSIGNED(aStdLogicVector(  4 DOWNTO 0 ));
    lStub.CIC      := UNSIGNED(aStdLogicVector( 12 DOWNTO 5 )); 
    lStub.Bend     := SIGNED(aStdLogicVector( 15 DOWNTO 13 ));
    lStub.Z        := UNSIGNED(aStdLogicVector( 19 DOWNTO 16 ));
    lStub.LocalR   := SIGNED(aStdLogicVector( 24 DOWNTO 20 ));
    lStub.LocalPhi := SIGNED(aStdLogicVector( 35 DOWNTO 25 ));
    lStub.StubValid := ToBoolean( aStdLogicVector( 36 ) );
    RETURN lStub;
  END FUNCTION ToStub;


END PACKAGE BODY stub_pkg;
