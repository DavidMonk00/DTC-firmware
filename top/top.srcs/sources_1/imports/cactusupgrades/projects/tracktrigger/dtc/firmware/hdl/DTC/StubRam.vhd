-- -----------------------------------------------------------------------------------------------------------------------------
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

USE WORK.stub_pkg.ALL;

ENTITY StubRam IS
  PORT(
    clk       : IN STD_LOGIC; --! The algorithm clock
    StubIn    : IN tStub                  := NullStub;
    WriteAddr : IN INTEGER RANGE 0 TO 511 := 0;
    ReadAddr  : IN INTEGER RANGE 0 TO 511 := 0;
    StubOut   : OUT tStub                 := NullStub
  );
END StubRam;

ARCHITECTURE behavioral OF StubRam IS

  SIGNAL RamIn , RamOut                    : STD_LOGIC_VECTOR( 36 DOWNTO 0 ) := ( OTHERS => '0' );
  SIGNAL AddrA , AddrB                    : STD_LOGIC_VECTOR( 8 DOWNTO 0 ) := ( OTHERS => '0' );

  --TYPE mem_type IS ARRAY( 0 TO 511 ) OF STD_LOGIC_VECTOR( 35 DOWNTO 0 );
  --SIGNAL RAM                 : mem_type := ( OTHERS => ( OTHERS => '0' ) );

  --ATTRIBUTE ram_style        : STRING;
  --ATTRIBUTE ram_style OF RAM : SIGNAL IS "block";

BEGIN

  RamIn <= ToStdLogicVector( StubIn , 37 );
  AddrA <= STD_LOGIC_VECTOR( TO_UNSIGNED( WriteAddr , 9 ));
  AddrB <= STD_LOGIC_VECTOR( TO_UNSIGNED( ReadAddr , 9 ));

  --PROCESS( clk )
  --BEGIN
  --  IF( RISING_EDGE( clk ) ) THEN

  --    RAM( WriteAddr ) <= RamIn( 35 downto 0 );
  --    RamOut( 35 DOWNTO 0 )  <= RAM( ReadAddr );

  --  END IF;
  --END PROCESS;

  blockram_512x36Instance : entity work.blockram_512x36
  PORT MAP (
    clka => clk,
    wea => "1",
    addra => AddrA ,
    dina => RamIn( 35 downto 0 ),
    clkb => clk,
    addrb => AddrB,
    doutb => RamOut( 35 downto 0 )
  );


  StubOut <= ToStub( RamOut );


END ARCHITECTURE behavioral;
