-- -----------------------------------------------------------------------------------------------------------------------------
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;

--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

USE WORK.stub_pkg.ALL;


ENTITY StubDistributionServer IS
  GENERIC(
    SelectionKey : tSelectionKey --;
--DDR : BOOLEAN := FALSE
  );
  PORT(
    clk      : IN STD_LOGIC; --! The algorithm clock
    StubsIn  : IN tUnconstrainedStubArray;
    StubsOut : OUT tUnconstrainedStubArray
  );
END StubDistributionServer;

ARCHITECTURE behavioral OF StubDistributionServer IS

-- ------------------------------------------------------------
  CONSTANT InputSize : NATURAL := StubsIn'LENGTH;
  SUBTYPE InputRange IS NATURAL RANGE 0 TO InputSize -1;
-- ------------------------------------------------------------
  CONSTANT OutputSize : NATURAL := StubsOut'LENGTH;
  SUBTYPE OutputRange IS NATURAL RANGE 0 TO OutputSize -1;
-- ------------------------------------------------------------
  CONSTANT Interleaving : INTEGER                                := 4;
-- ------------------------------------------------------------

-- Sliced unconstrained arrays keep parent indexing - covert to local indexing
  SIGNAL StubsInInt     : tUnconstrainedStubArray( InputRange )  := ( OTHERS => NullStub );
  SIGNAL StubsOutInt    : tUnconstrainedStubArray( OutputRange ) := ( OTHERS => NullStub );

  SIGNAL RamStubs       : tStubArray                             := NullStubArray;
  SIGNAL RamStubPipe    : tStubPipe( 0 TO Interleaving )         := ( OTHERS => NullStubArray );

  SIGNAL WriteAddr      : tAddressArray                          := NullAddressArray;
  SIGNAL ReadAddr       : tAddressArray                          := ( OTHERS => ( Interleaving-1 ) );
  SIGNAL ReadAddrPipe   : tAddressPipe( 0 TO Interleaving-1 )    := InitializeAddressPipe( Interleaving );

  TYPE tCollisionArray IS ARRAY( InputRange ) OF BOOLEAN;
  SIGNAL ReadWriteAddressCollision : tCollisionArray := ( OTHERS => FALSE );

  SUBTYPE tOutputMask IS STD_LOGIC_VECTOR( OutputRange );
  CONSTANT NullOutputMask : tOutputMask := ( OTHERS => '0' );

  TYPE tMaskMap IS ARRAY( InputRange ) OF tOutputMask;
  SIGNAL StubMap , StubMap1 , StubMap2 : tMaskMap := ( OTHERS => NullOutputMask );
  SIGNAL BitMaskMap , BitMaskMap2      : tMaskMap := ( OTHERS => NullOutputMask );

BEGIN

-- ---------------------------------------
-- RAM for storing incoming stubs
-- ---------------------------------------
  g1 : FOR i IN InputRange GENERATE

    StubsInInt( i ) <= StubsIn( StubsIn'LOW + i ); --Map from unconstrained indices to constrained indices

    StubRamInstance : ENTITY work.StubRam
--GENERIC MAP(
--  DDR => DDR
--)
    PORT MAP(
      clk       => clk ,
      WriteAddr => WriteAddr( i ) ,
      StubIn    => StubsInInt( i ) ,
      ReadAddr  => ReadAddr( i ) ,
      StubOut   => RamStubs( i )
    );
  END GENERATE g1;
-- ---------------------------------------

-- ---------------------------------------
-- Select the data for fanout
-- ---------------------------------------
  SelectPrc                             : PROCESS( clk )
    VARIABLE PrioritizedRam             : INTEGER;
    VARIABLE IncReadAddr , IncWriteAddr : INTEGER;
  BEGIN
    IF( RISING_EDGE( clk )
--OR( DDR AND FALLING_EDGE( clk ) ) 
      ) THEN

      StubMap     <= ( OTHERS => NullOutputMask );
      StubMap1    <= ( OTHERS => NullOutputMask );
      StubMap2    <= ( OTHERS => NullOutputMask );
      BitMaskMap  <= ( OTHERS => NullOutputMask );
      StubsOutInt <= ( OTHERS => NullStub );

-- Increment the write pointer if we do write
      FOR InputIndex IN InputRange LOOP
        IF StubsInInt( InputIndex ) .StubValid THEN
          WriteAddr( InputIndex ) <= ( WriteAddr( InputIndex ) + 1 ) MOD 512;
        END IF;
      END LOOP;

-- Flag when the ReadAddress is ahead of the WriteAddress
      FOR InputIndex IN InputRange LOOP
        ReadWriteAddressCollision( InputIndex ) <= ( ( ReadAddr( InputIndex ) - WriteAddr( InputIndex ) ) MOD 512 ) < 256;
      END LOOP;

-- Map the data-valid flags into an array
      FOR InputIndex IN InputRange LOOP
        --IF RamStubPipe( 0 )( InputIndex ) .StubValid THEN --Ram Stub arrives 1 clock-cycle after corresponding ReadAddr & ReadPhase
        IF ( NOT ReadWriteAddressCollision( InputIndex ) ) THEN --Ram Stub arrives 1 clock-cycle after corresponding ReadAddr & ReadPhase

          --IF BitMaskMap2( InputIndex ) = NullOutputMask THEN -- For TM allocation, only one output, so no feedback loop
            --StubMap( InputIndex ) <= RamStubPipe( 0 )( InputIndex ) .SortKey( IndexHi DOWNTO IndexLo );
            StubMap( InputIndex ) <= (OTHERS=>'0');
            case SelectionKey IS
              when CoarseTmBx =>   StubMap( InputIndex )( TO_INTEGER( RamStubPipe( 0 )( InputIndex ).Bx mod 6 ) ) <= '1';
              when FineTmBx   =>   StubMap( InputIndex )( TO_INTEGER( RamStubPipe( 0 )( InputIndex ).Bx / 6 ) ) <= '1';
            end case;
          -- ELSE
          --  StubMap( InputIndex ) <= BitMaskMap2( InputIndex );
          --END IF;
        END IF;
      END LOOP;

-- Remove the duplicates
      FOR OutputIndex IN OutputRange LOOP
        FOR InputIndex IN InputRange LOOP
          PrioritizedRam := InputIndex;
          IF StubMap( PrioritizedRam )( OutputIndex ) = '1' THEN
            StubMap2( PrioritizedRam )( OutputIndex ) <= '1';
            EXIT; -- quits inner loop
          END IF;
        END LOOP;
      END LOOP;

-- Select the relevant stub and increment the addresses as necessary
      ReadAddr <= ReadAddrPipe( Interleaving - 1 ); -- Read address retains its previous value

      FOR InputIndex IN InputRange LOOP

-- For TM allocation, only one output, so no feedback loop
        FOR OutputIndex IN OutputRange LOOP
          IF StubMap2( InputIndex )( OutputIndex ) = '1' THEN
            ReadAddr( InputIndex )   <= ( ReadAddrPipe( Interleaving - 1 )( InputIndex ) + Interleaving ) MOD 512; -- Unless we are reading here...
            StubsOutInt( OutputIndex ) <= RamStubPipe( Interleaving - 2 )( InputIndex );
            exit; -- quits inner loop, should be inferred from above, but just in case
          END IF;
        END LOOP;

-- One input can map to multiple outputs
        --StubMap1( InputIndex ) <= StubMap( InputIndex );

        --IF( StubMap1( InputIndex ) XOR StubMap2( InputIndex ) ) = NullOutputMask AND StubMap1( InputIndex ) /= NullOutputMask THEN
        --  BitMaskMap( InputIndex ) <= NullOutputMask;
        --  ReadAddr( InputIndex )   <= ( ReadAddrPipe( Interleaving - 1 )( InputIndex ) + Interleaving ) MOD 512; -- Unless we are reading here...
        --ELSE
        --  BitMaskMap( InputIndex ) <= StubMap1( InputIndex ) XOR StubMap2( InputIndex );
        --END IF;

        --BitMaskMap2( InputIndex ) <= BitMaskMap( InputIndex ); 

      END LOOP;

    END IF;
  END PROCESS SelectPrc;
-- ---------------------------------------

  StubsOut <= StubsOutInt;

-- ---------------------------------------
  StubPipeInstance : ENTITY work.StubPipe
--GENERIC MAP(
--  DDR => DDR
--)
  PORT MAP(
    clk      => clk ,
    stubsIn  => RamStubs ,
    stubPipe => RamStubPipe
  );
-- ---------------------------------------

-- ---------------------------------------
  AddressPipeInstance : ENTITY work.AddressPipe
--GENERIC MAP(
--  DDR => DDR
--)  
  PORT MAP(
    clk         => clk ,
    addressIn   => ReadAddr ,
    addressPipe => ReadAddrPipe
  );
-- ---------------------------------------


END ARCHITECTURE behavioral;
