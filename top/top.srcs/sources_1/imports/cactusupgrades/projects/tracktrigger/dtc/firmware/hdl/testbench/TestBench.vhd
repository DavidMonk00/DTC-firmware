--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

USE IEEE.math_REAL.ALL;


USE STD.TEXTIO.ALL;


USE WORK.others_pkg.ALL;
USE WORK.utilities_pkg.ALL;
USE WORK.XMLutilities_pkg.ALL;


USE work.mp7_data_types.ALL;
--use work.BinarySortTreePkg.ALL;
use work.BinarySortTree2Pkg.ALL;


--! @brief An entity providing a TestBench
--! @details Detailed description
ENTITY tb IS
END tb;

--! @brief Architecture definition for entity TestBench
--! @details Detailed description
ARCHITECTURE behavioral OF tb IS

  SIGNAL clk                  : STD_LOGIC            := '1';
---- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- LINK SIGNALS
--  SIGNAL links_in , links_out : ldata( 17 DOWNTO 0 ) := ( OTHERS => LWORD_NULL );
--  SIGNAL spare_links_in , spare_links_out : ldata( 59 downto 18 ) := ( OTHERS => LWORD_NULL );
---- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--  TYPE tLinkDelay IS ARRAY ( 20 DOWNTO 0 ) OF ldata( 11 DOWNTO 0 );
--  SIGNAL LinkDelay : tLinkDelay := ( OTHERS => ( OTHERS => LWORD_NULL ) );

  SIGNAL SortDataIn , SortDataOut  : SortData := NullSortData;
  --SIGNAL RamAddressIn , RamAddressOut  : UNSIGNED( 8 downto 0 ) := (OTHERS=>'0');
  SIGNAl Rst : STD_LOGIC := '0';


BEGIN

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    clk <= NOT clk AFTER 2.1 ns; -- 240MHz
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  g1                           : FOR x IN 0 TO 0 GENERATE
    stimulus                   : PROCESS( clk )
      VARIABLE seed1           : POSITIVE := 12121121; -- Seed values for random generator
      VARIABLE seed2           : POSITIVE := x + 239847; -- Seed values for random generator
      VARIABLE counter         : INTEGER  := -3;
      VARIABLE rand            : REAL; -- Random real-number value in range 0 to 1.0  

      VARIABLE Bend , BendSign : INTEGER := 0;

    BEGIN
      IF RISING_EDGE( CLK ) THEN

        --links_in( x ) <= LWORD_NULL;

        --IF ( counter >= 0 and counter < 96 ) THEN
        --  UNIFORM( seed1 , seed2 , rand ); -- generate random number
        --  links_in( x ) .data( 15 DOWNTO 0 ) <= STD_LOGIC_VECTOR( TO_UNSIGNED( INTEGER( rand * REAL( (2 ** 16) ) ) , 16 ) );
        --  UNIFORM( seed1 , seed2 , rand ); -- generate random number
        --  links_in( x ) .data( 31 DOWNTO 16 ) <= STD_LOGIC_VECTOR( TO_UNSIGNED( INTEGER( rand * REAL( (2 ** 16) ) ) , 16 ) );

        --  links_in( x ) .valid <= '1';
        --END IF;

        SortDataIn <= NullSortData;  
        -- RamAddressIn(8 downto 7) <= TO_UNSIGNED( counter mod 4  , 2 );  

        if ( counter mod 4 = 0 ) THEN
          SortDataIn.Key <= to_unsigned( (counter/4) , 9 );  
          SortDataIn.DataPtr <= to_unsigned( (counter/4) , 9 ); 
          SortDataIn.DataValid <= TRUE; 
        end if;

        rst <= '0';
        if( counter = 50 ) THEN
          rst <= '1';
        end if;

        counter := counter + 1;
      END IF;
    END PROCESS;
  END GENERATE g1;



  --LinkDelay( 20 DOWNTO 1 ) <= LinkDelay( 19 DOWNTO 0 ) when RISING_EDGE( clk );

  --DUT : ENTITY work.DtcTop
  --PORT MAP(
  --  clk      => clk ,
  --  LinksIn( 17 downto 0 )  => links_in ,
  --  LinksIn( 59 downto 18 ) => spare_links_in,
  --  LinksIn( 71 downto 60 ) => LinkDelay( 20 ),
  --  LinksOut( 17 downto 0 ) => links_out,
  --  LinksOut( 59 downto 18 ) => spare_links_out,    
  --  LinksOut( 71 downto 60 ) => LinkDelay( 0 )
  --);

  --BinarySortNodeInstance : entity work.BinarySortNode
  --GENERIC MAP(
  --  FullKeyWidth => 3,
  --  LayerNumber => 0
  --)
  --PORT MAP(
  --  clk => clk,
  --  SortDataIn  => SortDataIn,
  --  RamAddressIn => RamAddressIn,
  --  SortDataOut  => SortDataOut,
  --  RamAddressOut => RamAddressOut
  --);

  --BinarySortTreeInstance : entity work.BinarySortTree
  --GENERIC MAP(
  --  FullKeyWidth => 3,
  --  LayerCount => 3
  --)
  --PORT MAP(
  --  clk => clk,
  --  SortDataIn  => SortDataIn,
  --  SortDataOut  => SortDataOut
  --);


  BinarySortTreeInstance : entity work.BinarySortTree2
  PORT MAP(
    clk => clk,
    rst => rst,
    SortDataIn  => SortDataIn,
    SortDataOut  => SortDataOut
  );

END ARCHITECTURE behavioral;
