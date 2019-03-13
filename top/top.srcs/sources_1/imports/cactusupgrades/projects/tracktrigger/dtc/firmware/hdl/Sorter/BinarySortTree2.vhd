-- ---------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

PACKAGE BinarySortTree2Pkg IS

  TYPE SortData IS RECORD 
    Key : UNSIGNED( 8 downto 0 );
    DataPtr : UNSIGNED( 8 downto 0 );
    DataValid : BOOLEAN;
  END RECORD;

  CONSTANT NullSortData : SortData := ( (OTHERS=>'0') , (OTHERS=>'0') , FALSE );

  TYPE SortDataArray IS ARRAY( NATURAL RANGE <> ) OF SortData;
  TYPE RamAddressArray IS ARRAY( NATURAL RANGE <> ) OF UNSIGNED( 8 downto 0 );

  TYPE InternalStorage IS RECORD
    DataPtr : UNSIGNED( 8 downto 0 );
    KeyMSB : UNSIGNED( 0 DOWNTO 0 );
    KeyRemainder : UNSIGNED( 7 DOWNTO 0 );
    LeftPtr : UNSIGNED( 8 DOWNTO 0 );
    RightPtr : UNSIGNED( 8 DOWNTO 0 );
    -- Here for convenience
    DataValid : BOOLEAN;
    RamAddress : UNSIGNED( 8 downto 0 );
    Delta : UNSIGNED( 7 DOWNTO 0 );
  END RECORD;

  CONSTANT NullInternalStorage : InternalStorage := ( (OTHERS=>'0') , (OTHERS=>'0')  , (OTHERS=>'0') , (OTHERS=>'0') , (OTHERS=>'0') , FALSE , (OTHERS=>'0') , (OTHERS=>'0') );

END PACKAGE BinarySortTree2Pkg;
-- ---------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------
--PACKAGE BODY BinarySortTree2Pkg IS
--END PACKAGE BODY;
-- ---------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

use work.BinarySortTree2Pkg.ALL;
use work.utilities_pkg.ALL;

entity BinarySortNode2 is
GENERIC(
	MSB : INTEGER
);
PORT(
	clk           : IN STD_LOGIC;
  rst           : IN STD_LOGIC := '0';
	SortDataIn    : IN SortData := NullSortData;
  RamAddressIn  : IN UNSIGNED( 8 downto 0 ) := (OTHERS=>'0');
  NewAddressIn  : IN STD_LOGIC := '0';
  SortDataOut   : OUT SortData := NullSortData;
	RamAddressOut : OUT UNSIGNED( 8 downto 0 ) := (OTHERS=>'0');
  NewAddressOut : OUT STD_LOGIC := '0'
);
end BinarySortNode2;
-- ------------------------------------------------


-- ------------------------------------------------
architecture RTL of BinarySortNode2 is

  SIGNAL RamRead , RamWrite : STD_LOGIC_VECTOR( 35 downto 0 ) := (OTHERS=>'0');

  SIGNAL NewData1, OldData1 : InternalStorage := NullInternalStorage;
  SIGNAL NewData2, OldData2 : InternalStorage := NullInternalStorage;
  SIGNAL ToRAM3, ToOut3 : InternalStorage := NullInternalStorage;
  SIGNAL ToRAM4 : InternalStorage := NullInternalStorage;

  SIGNAL NextChild : UNSIGNED( 8 DOWNTO 0 ) := TO_UNSIGNED( 1 , 9 );
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

  OldData1.DataPtr <= UNSIGNED( RamRead( 8 downto 0 ) );
  OldData1.KeyRemainder <= UNSIGNED( RamRead( 16 DOWNTO 9 ) );
  OldData1.KeyMSB <= UNSIGNED( RamRead( 17 DOWNTO 17 ) );
  OldData1.LeftPtr <= UNSIGNED( RamRead( 26 DOWNTO 18 ) );
  OldData1.RightPtr <= UNSIGNED( RamRead( 35 DOWNTO 27 ) );

  RamWrite( 8 downto 0 ) <= STD_LOGIC_VECTOR( ToRAM4.DataPtr );
  RamWrite( 16 DOWNTO 9 )  <= STD_LOGIC_VECTOR( ToRAM4.KeyRemainder );
  RamWrite( 17 DOWNTO 17 )  <= STD_LOGIC_VECTOR( ToRAM4.KeyMSB );
  RamWrite( 26 DOWNTO 18 )  <= STD_LOGIC_VECTOR( ToRAM4.LeftPtr );
  RamWrite( 35 DOWNTO 27 )  <= STD_LOGIC_VECTOR( ToRAM4.RightPtr );

  NewData1.LeftPtr  <= OldData1.LeftPtr;  -- Use as an alias, so we don't care which way the muxing goes and hope Vivado is smart enough
  NewData1.RightPtr <= OldData1.RightPtr; -- Use as an alias, so we don't care which way the muxing goes and hope Vivado is smart enough

  PROCESS( clk )
  BEGIN
    IF( RISING_EDGE( clk ) ) THEN
      -- ------------------------------------------------------------------------
      -- First clock, read RAM and format data in
      OldData1.RamAddress <= RamAddressIn; 
      OldData1.DataValid <= NOT ToBoolean( NewAddressIn );

      NewData1.RamAddress <= RamAddressIn; -- Use as an alias, so we don't care which way the muxing goes and hope Vivado is smart enough
      NewData1.DataValid <= SortDataIn.DataValid;
      NewData1.DataPtr <= SortDataIn.DataPtr;
      NewData1.KeyMSB <= SortDataIn.Key( MSB DOWNTO MSB );
      NewData1.KeyRemainder( MSB-1 DOWNTO 0 ) <= SortDataIn.Key( MSB-1 DOWNTO 0 );
      -- ------------------------------------------------------------------------
      -- ------------------------------------------------------------------------
      -- Second clock, calculate deltas and valid-flags
      NewData2 <= NewData1;
      if( NewData1.KeyMSB = "0" ) THEN NewData2.Delta <= not( NewData1.KeyRemainder ) + 1; 
      else                             NewData2.Delta <= NewData1.KeyRemainder;
      end if;

      OldData2 <= OldData1;
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
      if ( not OldData2.DataValid ) then -- The address is flagged as new, store new entry and clear the child pointers      
        ToRAM3 <= NewData2;
        ToOut3 <= OldData2; -- Labelled as invalid by definition 
        ToRAM3.LeftPtr <= (OTHERS=>'0');  -- If the incoming data has the "New address" flag set, clear the existing pointers
        ToRAM3.RightPtr <= (OTHERS=>'0');
      elsif ( not NewData2.DataValid ) then -- Old is valid, new is invalid
        ToRAM3 <= OldData2; -- RAM WE permanantly set, write the data back
        ToOut3 <= NewData2; -- Labelled as invalid by definition   
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

      SortDataOut.Key( MSB-1 DOWNTO 0 ) <= ToOut3.KeyRemainder( MSB-1 DOWNTO 0 );
      SortDataOut.DataPtr <= ToOut3.DataPtr;
      SortDataOut.DataValid <= ToOut3.DataValid;
      RamAddressOut <= TO_UNSIGNED( 0 , 9 ); -- NULL ADDRESS - should never be used!
      NewAddressOut <= '0';                                 

      if( ToOut3.DataValid ) then
        if( ToOut3.KeyMSB = "1" ) then -- push right
          if( ToOut3.RightPtr = TO_UNSIGNED( 0 , 9 ) ) then
            ASSERT ( NextChild /= TO_UNSIGNED( 0 , 9 ) ) REPORT "Child Counter Overflow" SEVERITY FAILURE;
            RamAddressOut <= NextChild;   
            NewAddressOut <= '1';                                 
            ToRAM4.RightPtr <= NextChild;
            NextChild <= NextChild + 1;
          else
            RamAddressOut <= ToOut3.RightPtr; 
            NewAddressOut <= '0';                                 
          end if;      
        else --push left
          if( ToOut3.LeftPtr = TO_UNSIGNED( 0 , 9 ) ) then
            ASSERT ( NextChild /= TO_UNSIGNED( 0 , 9 ) ) REPORT "Child Counter Overflow" SEVERITY FAILURE;          
            RamAddressOut <= NextChild; 
            NewAddressOut <= '1';                                 
            ToRAM4.LeftPtr <= NextChild;
            NextChild <= NextChild + 1;  
          else
            RamAddressOut <= ToOut3.LeftPtr; 
            NewAddressOut <= '0';                                 
          end if;  
        end if;
      end if;
      -- ------------------------------------------------------------------------
      -- At the end of the process - we don't care what any other signal does, just label everything invalid and reset the counter 
      if ( rst = '1' ) then
        NextChild <= TO_UNSIGNED( 1 , 9 );
        NewData1.DataValid <= FALSE;
        OldData1.DataValid <= FALSE;
        NewData2.DataValid <= FALSE;
        OldData2.DataValid <= FALSE;
        ToOut3.DataValid <= FALSE;
        ToRAM3.DataValid <= FALSE;
        ToRAM4.DataValid <= FALSE;
        SortDataOut.DataValid <= FALSE;
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

use work.BinarySortTree2Pkg.ALL;
use work.utilities_pkg.ALL;

entity BinarySortTree2 is
PORT(
  clk : IN STD_LOGIC;
  rst : IN STD_LOGIC;
  SortDataIn  : IN SortData := NullSortData;
  SortDataOut  : OUT SortData := NullSortData
);
end BinarySortTree2;



architecture RTL of BinarySortTree2 is
  SIGNAL lSortData : SortDataArray( 0 TO 9 ) := (OTHERS => NullSortData);
  SIGNAL lRamAddress : RamAddressArray( 0 TO 9 ) := (OTHERS => (OTHERS=>'0'));
  SIGNAL lNewAddress : STD_LOGIC_VECTOR( 0 TO 9 ) := (OTHERS=>'0');
  SIGNAL lInitialized : BOOLEAN := FALSE;

begin

  lSortData( 0 ) <= SortDataIn;
  --lRamAddress(0)( 1 downto 0 ) <= ( lRamAddress(0)( 1 downto 0 ) + 1 ) when RISING_EDGE(clk);

  lInitialized <= ((SortDataIn.DataValid OR lInitialized ) AND (rst = '0') ) when RISING_EDGE(clk);
  lNewAddress(0) <= ToStdLogic( SortDataIn.DataValid AND NOT lInitialized );

  g1: FOR i in 0 to 8 GENERATE
    BinarySortNode2Instance : entity work.BinarySortNode2
    GENERIC MAP(
      MSB => 8-i
    )
    PORT MAP(
      clk => clk,
      rst => rst,
      SortDataIn  => lSortData(i),
      RamAddressIn => lRamAddress(i),
      NewAddressIn => lNewAddress(i),
      SortDataOut  => lSortData(i+1),
      RamAddressOut => lRamAddress(i+1),
      NewAddressOut => lNewAddress(i+1)
    );
  end generate g1;

  SortDataOut <= lSortData( 9 );

end RTL;
-- ---------------------------------------------------------------------------------
