-- -------------------------------------------------------------------------------------------------------------------------------------------------
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

USE WORK.stub_pkg.ALL;
USE WORK.utilities_pkg.ALL;

USE work.mp7_data_types.ALL;
--! Using the Calo-L2 algorithm configuration bus
USE work.FunkyMiniBus.ALL;

ENTITY StubFormatter IS
  PORT(
    clk      : IN STD_LOGIC; --! The algorithm clock
    StubsIn  : IN tCICstubArray := NullCICstubArray;
    PrimaryStubsOut , SecondaryStubsOut : OUT tStubArray := NullStubArray
  );
END StubFormatter;


ARCHITECTURE behavioral OF StubFormatter IS

  SIGNAL BusIn , BusOut : tFMBus( 0 TO 71 );
  SIGNAL BusClk         : STD_LOGIC     := '0';

BEGIN

  g1           : FOR i IN 0 TO 71 GENERATE
    CONSTANT x : INTEGER := BusOut'LOW + i;
    SUBTYPE A IS NATURAL RANGE x + 0 TO x + 0;

    SIGNAL StripNumber , PosLutOut : STD_LOGIC_VECTOR( 17 DOWNTO 0 ) := (OTHERS=>'0');
    SIGNAL StubsInClk     : tCICstub := NullCICstub;
  BEGIN

    StripNumber( 10 DOWNTO 0 ) <= STD_LOGIC_VECTOR( StubsIn( i ) .ROC ) & STD_LOGIC_VECTOR( StubsIn( i ) .strip );

    PosLutInstance : ENTITY work.GenPromClocked
    GENERIC MAP(
      FileName => "A_PosLutLow_11to18.mif" ,
      BusName  => "A/PosLutA" & INTEGER'IMAGE( i )
    )
    PORT MAP(
      clk       => clk ,
      AddressIn => StripNumber( 10 DOWNTO 0 ) ,
      DataOut   => PosLutOut( 17 DOWNTO 0 ) ,
      BusIn     => BusIn( A ) ,
      BusOut    => BusOut( A ) ,
      BusClk    => BusClk
    );


    Framing : PROCESS( clk )
      VARIABLE FrameCounter        : INTEGER RANGE 0 TO 47 := 0; -- 8Bx Boxcar at 240MHz = 48 frames
      VARIABLE BoxCarBaseBx , TmBx : INTEGER RANGE 0 TO 17 := 0; -- 18-fold Tm Period. TmBx is the Tm slice allocation for the 1st event in the boxcar
    BEGIN
      IF( RISING_EDGE( clk ) ) THEN

        StubsInClk <= StubsIn( i );

        if ( not StubsInClk.DataValid ) THEN
          BoxCarBaseBx := 0;
          FrameCounter := 0;
          TmBx         := 0;          
        else
          TmBx         := ( BoxCarBaseBx + TO_INTEGER( StubsInClk.Bx ) ) MOD 18;

          IF( FrameCounter /= 47 ) THEN
            FrameCounter := FrameCounter + 1;
          ELSE
            FrameCounter := 0;
            BoxCarBaseBx := ( BoxCarBaseBx + 8 ) MOD 18; -- For the next box-car, add 8 to the Tm slice allocation
          END IF;
          
        end if;

        if( StubsInClk.StubValid AND ToBoolean( PosLutOut( 16 ) ) ) then
          PrimaryStubsOut(i).Bx        <= TO_UNSIGNED( TmBx , 5 );
          PrimaryStubsOut(i).CIC       <= '0' & TO_UNSIGNED( i , 7 );
          PrimaryStubsOut(i).Bend      <= StubsInClk.bend;
          PrimaryStubsOut(i).Z         <= StubsInClk.Z;
          PrimaryStubsOut(i).LocalR    <= SIGNED( PosLutOut( 4 DOWNTO 0 ) );
          PrimaryStubsOut(i).LocalPhi  <= SIGNED( PosLutOut( 15 DOWNTO 5 ) );
          PrimaryStubsOut(i).DataValid <= StubsInClk.DataValid;
          PrimaryStubsOut(i).StubValid <= StubsInClk.StubValid AND ToBoolean( PosLutOut( 16 ) ); -- Valid and destined for primary sector
        else
          PrimaryStubsOut(i) <= NullStub;
          PrimaryStubsOut(i).DataValid <= StubsInClk.DataValid;
        end if;

        if( StubsInClk.StubValid AND ToBoolean( PosLutOut( 17 ) ) ) then
          SecondaryStubsOut(i).Bx        <= TO_UNSIGNED( TmBx , 5 );
          SecondaryStubsOut(i).CIC       <= '1' & TO_UNSIGNED( i , 7 ); -- Will identify stubs from the other chip
          SecondaryStubsOut(i).Bend      <= StubsInClk.bend;
          SecondaryStubsOut(i).Z         <= StubsInClk.Z;
          SecondaryStubsOut(i).LocalR    <= SIGNED( PosLutOut( 4 DOWNTO 0 ) );
          SecondaryStubsOut(i).LocalPhi  <= SIGNED( PosLutOut( 15 DOWNTO 5 ) );
          SecondaryStubsOut(i).DataValid <= StubsInClk.DataValid;
          SecondaryStubsOut(i).StubValid <= StubsInClk.StubValid AND ToBoolean( PosLutOut( 17 ) ); -- Valid and destined for secondary sector
        else
          SecondaryStubsOut(i) <= NullStub;
          SecondaryStubsOut(i).DataValid <= StubsInClk.DataValid; 
        end if;


      END IF;
    END PROCESS;

  END GENERATE g1;

END ARCHITECTURE behavioral;
