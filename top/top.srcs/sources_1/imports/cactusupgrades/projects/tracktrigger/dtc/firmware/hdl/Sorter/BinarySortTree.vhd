-- ---------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

PACKAGE BinarySortTreePkg IS

  TYPE SortData IS RECORD 
    Key : UNSIGNED( 15 downto 0 );
    DataPtr : UNSIGNED( 9 downto 0 );
  END RECORD;

  CONSTANT NullSortData : SortData := ( (OTHERS=>'0') , (OTHERS=>'0') );

  TYPE SortDataArray IS ARRAY( NATURAL RANGE <> ) OF SortData;
  TYPE RamAddressArray IS ARRAY( NATURAL RANGE <> ) OF UNSIGNED( 8 downto 0 );

  function minimum( l , r : integer ) return integer;

END PACKAGE BinarySortTreePkg;
-- ---------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------
PACKAGE BODY BinarySortTreePkg IS
  function minimum( l , r : integer ) return integer is
  begin
    if (l<r) then return l;
    else return r;
    end if;
  end function;
END PACKAGE BODY;
-- ---------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

use work.BinarySortTreePkg.ALL;
use work.utilities_pkg.ALL;

entity BinarySortNode is
GENERIC(
	FullKeyWidth : INTEGER;
  LayerNumber : INTEGER
);
PORT(
	clk           : IN STD_LOGIC;
	SortDataIn    : IN SortData := NullSortData;
  RamAddressIn  : IN UNSIGNED( 8 downto 0 ) := (OTHERS=>'0');
  SortDataOut   : OUT SortData := NullSortData;
	RamAddressOut : OUT UNSIGNED( 8 downto 0 ) := (OTHERS=>'0')
);
end BinarySortNode;


architecture RTL of BinarySortNode is

  CONSTANT KeyBits : INTEGER := FullKeyWidth - LayerNumber;
  CONSTANT ChildPtrSize : INTEGER := MINIMUM( LayerNumber+1 , 7 ) + 2; --Four phases increase minimum number of children by 4, or 2 bits on the pointer size
-- ------------------------------------------------
  TYPE InternalStorage IS RECORD
    DataPtr : UNSIGNED( 9 downto 0 );
    KeyMSB : UNSIGNED( 0 DOWNTO 0 );
    KeyRemainder : UNSIGNED( KeyBits-2 DOWNTO 0 );
    LeftPtr : UNSIGNED( ChildPtrSize-1 DOWNTO 0 );
    LeftPtrValid : BOOLEAN;
    RightPtr : UNSIGNED( ChildPtrSize-1 DOWNTO 0 );
    RightPtrValid : BOOLEAN;
    -- Here for convenience
    DataValid : BOOLEAN;
    RamAddress : UNSIGNED( 8 downto 0 );
    Delta : UNSIGNED( KeyBits-2 DOWNTO 0 );
  END RECORD;

  CONSTANT NullInternalStorage : InternalStorage := ( (OTHERS=>'0') , "0" , (OTHERS=>'0') , (OTHERS=>'0') , FALSE , (OTHERS=>'0') , FALSE , FALSE , (OTHERS=>'0') , (OTHERS=>'0') );
-- ------------------------------------------------

  SIGNAL RamRead , RamWrite : STD_LOGIC_VECTOR( 35 downto 0 ) := (OTHERS=>'0');

  SIGNAL NewData1, OldData1 : InternalStorage := NullInternalStorage;
  SIGNAL NewData2, OldData2 : InternalStorage := NullInternalStorage;
  SIGNAL ToRAM3, ToOut3 : InternalStorage := NullInternalStorage;
  SIGNAL ToRAM4 : InternalStorage := NullInternalStorage;

  SIGNAL NextChild : UNSIGNED( ChildPtrSize DOWNTO 0 ) := (OTHERS=>'0');
begin

  blockram_512x36_instance : entity work.blockram_512x36
  PORT MAP (
    clka => clk,
    wea => '1',
    addra => STD_LOGIC_VECTOR( ToRAM4.RamAddress ),
    dina => RamWrite,
    clkb => clk,
    addrb => STD_LOGIC_VECTOR( RamAddressIn ),
    doutb => RamRead
  );

  OldData1.DataPtr <= UNSIGNED( RamRead( 9 downto 0 ) );
  OldData1.LeftPtrValid <= ToBoolean( RamRead( 10 ) );
  OldData1.RightPtrValid <= ToBoolean( RamRead( 11 ) );
  OldData1.KeyRemainder <= UNSIGNED( RamRead( KeyBits+10 DOWNTO 12 ) );
  OldData1.KeyMSB <= UNSIGNED( RamRead( KeyBits+11 DOWNTO KeyBits+11 ) );
  OldData1.LeftPtr <= UNSIGNED( RamRead( ChildPtrSize+KeyBits+11 DOWNTO KeyBits+12 ) );
  OldData1.RightPtr <= UNSIGNED( RamRead( ChildPtrSize+ChildPtrSize+KeyBits+11 DOWNTO ChildPtrSize+KeyBits+12 ) );

  RamWrite( 9 downto 0 ) <= STD_LOGIC_VECTOR( ToRAM4.DataPtr );
  RamWrite( 10 )  <= ToStdLogic( ToRAM4.LeftPtrValid );
  RamWrite( 11 )  <= ToStdLogic( ToRAM4.RightPtrValid );
  RamWrite( KeyBits+10 DOWNTO 12 )  <= STD_LOGIC_VECTOR( ToRAM4.KeyRemainder );
  RamWrite( KeyBits+11 DOWNTO KeyBits+11 )  <= STD_LOGIC_VECTOR( ToRAM4.KeyMSB );
  RamWrite( ChildPtrSize+KeyBits+11 DOWNTO KeyBits+12 )  <= STD_LOGIC_VECTOR( ToRAM4.LeftPtr );
  RamWrite( ChildPtrSize+ChildPtrSize+KeyBits+11 DOWNTO ChildPtrSize+KeyBits+12 )  <= STD_LOGIC_VECTOR( ToRAM4.RightPtr );

  NewData1.LeftPtrValid <= ToBoolean( RamRead( 10 ) );
  NewData1.RightPtrValid <= ToBoolean( RamRead( 11 ) );
  NewData1.LeftPtr <= UNSIGNED( RamRead( ChildPtrSize+KeyBits+11 DOWNTO KeyBits+12 ) );
  NewData1.RightPtr <= UNSIGNED( RamRead( ChildPtrSize+ChildPtrSize+KeyBits+11 DOWNTO ChildPtrSize+KeyBits+12 ) );

  PROCESS( clk )
  BEGIN
    IF( RISING_EDGE( clk ) ) THEN
      -- ------------------------------------------------------------------------
      -- First clock, read RAM and format data in
      OldData1.RamAddress <= RamAddressIn;
      NewData1.RamAddress <= RamAddressIn;
      NewData1.DataPtr <= SortDataIn.DataPtr;
      NewData1.KeyMSB <= SortDataIn.Key( KeyBits-1 DOWNTO KeyBits-1 );
      NewData1.KeyRemainder <= SortDataIn.Key( KeyBits-2 DOWNTO 0 );
      -- ------------------------------------------------------------------------
      -- ------------------------------------------------------------------------
      -- Second clock, calculate deltas and valid-flags
      NewData2 <= NewData1;
      NewData2.DataValid <= ( (NewData1.KeyMSB & NewData1.KeyRemainder) /= TO_UNSIGNED( 0 , KeyBits) );
      if( NewData1.KeyMSB = "0" ) THEN NewData2.Delta <= not( NewData1.KeyRemainder ) + 1; 
      else                             NewData2.Delta <= NewData1.KeyRemainder;
      end if;

      OldData2 <= OldData1;
      OldData2.DataValid <= ( (OldData1.KeyMSB & OldData1.KeyRemainder) /= TO_UNSIGNED( 0 , KeyBits) );
      if( OldData1.KeyMSB = "0" ) THEN OldData2.Delta <= not( OldData1.KeyRemainder ) + 1;
      else                             OldData2.Delta <= OldData1.KeyRemainder;
      end if;
      -- ------------------------------------------------------------------------
      -- ------------------------------------------------------------------------
      if( NewData2.DataValid and OldData2.DataValid ) then 
        ASSERT ( (NewData2.KeyMSB & NewData2.KeyRemainder) /= (OldData2.KeyMSB & OldData2.KeyRemainder) ) REPORT "Duplicate key" SEVERITY FAILURE;
      end if;
      -- ------------------------------------------------------------------------
      -- ------------------------------------------------------------------------
      --Third clock, do comparison
      if ( not OldData2.DataValid ) then -- Old is invalid, store new      
        ToRAM3 <= NewData2;
        ToOut3 <= OldData2; 
      elsif ( not NewData2.DataValid ) then -- Old is valid, new is invalid
        ToRAM3 <= OldData2;
        ToOut3 <= NewData2; 
      elsif ( NewData2.Delta < OldData2.Delta ) then -- Store new data and pass-on old, updating RAM with child pointer address if necessary
        ToRAM3 <= NewData2;   
        ToOut3 <= OldData2;  
      else -- Pass-on new data and store old, updating RAM with child pointer address with child pointer address if necessary
        ToRAM3 <= OldData2;   
        ToOut3 <= NewData2;            
      end if;
      -- ------------------------------------------------------------------------
      -- ------------------------------------------------------------------------
      -- Fourth clock, update addresses
      ToRAM4 <= ToRAM3;

      SortDataOut.Key( KeyBits-2 DOWNTO 0 ) <= ToOut3.KeyRemainder;
      SortDataOut.DataPtr <= ToOut3.DataPtr;

      if( ToOut3.DataValid ) then
        if( ToOut3.KeyMSB = "1" ) then -- push right
          if( NOT ToOut3.RightPtrValid ) then
            ASSERT ( NextChild( ChildPtrSize ) /= '1' ) REPORT "Child Counter Overflow" SEVERITY FAILURE;
            RamAddressOut( ChildPtrSize-1 DOWNTO 0 ) <= NextChild( ChildPtrSize-1 DOWNTO 0 );                                    
            ToRAM4.RightPtr <= NextChild( ChildPtrSize-1 DOWNTO 0 );
            ToRAM4.RightPtrValid <= TRUE;
            NextChild <= NextChild + 1;
          else
            RamAddressOut( ChildPtrSize-1 DOWNTO 0 ) <= ToOut3.RightPtr; 
          end if;      
        else --push left
          if( NOT ToOut3.LeftPtrValid ) then
            ASSERT ( NextChild( ChildPtrSize ) /= '1' ) REPORT "Child Counter Overflow" SEVERITY FAILURE;          
            RamAddressOut( ChildPtrSize-1 DOWNTO 0 ) <= NextChild( ChildPtrSize-1 DOWNTO 0 ); 
            ToRAM4.LeftPtr <= NextChild( ChildPtrSize-1 DOWNTO 0 );
            ToRAM4.LeftPtrValid <= TRUE;
            NextChild <= NextChild + 1;  
          else
            RamAddressOut( ChildPtrSize-1 DOWNTO 0 ) <= ToOut3.LeftPtr; 
          end if;  
        end if;
      end if;
      -- ------------------------------------------------------------------------
    end if;
  end process;
end RTL;
-- ---------------------------------------------------------------------------------



-- ---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

use work.BinarySortTreePkg.ALL;
use work.utilities_pkg.ALL;

entity BinarySortTree is
GENERIC(
  FullKeyWidth : INTEGER;
  LayerCount : INTEGER
);
PORT(
  clk : IN STD_LOGIC;
  SortDataIn  : IN SortData := NullSortData;
  SortDataOut  : OUT SortData := NullSortData
);
end BinarySortTree;


architecture RTL of BinarySortTree is
  SIGNAL lSortData : SortDataArray( 0 TO LayerCount ) := (OTHERS => NullSortData);
  SIGNAL lRamAddress : RamAddressArray( 0 TO LayerCount ) := (OTHERS => (OTHERS=>'0'));
begin

  lSortData( 0 ) <= SortDataIn;
  lRamAddress(0)( 1 downto 0 ) <= ( lRamAddress(0)( 1 downto 0 ) + 1 ) when RISING_EDGE(clk);

  g1: FOR i in 0 to LayerCount-1 GENERATE
    BinarySortNodeInstance : entity work.BinarySortNode
    GENERIC MAP(
      FullKeyWidth => FullKeyWidth,
      LayerNumber => i
    )
    PORT MAP(
      clk => clk,
      SortDataIn  => lSortData(i),
      RamAddressIn => lRamAddress(i),
      SortDataOut  => lSortData(i+1),
      RamAddressOut => lRamAddress(i+1)
    );
  end generate g1;

  SortDataOut <= lSortData( LayerCount );

end RTL;
-- ---------------------------------------------------------------------------------
