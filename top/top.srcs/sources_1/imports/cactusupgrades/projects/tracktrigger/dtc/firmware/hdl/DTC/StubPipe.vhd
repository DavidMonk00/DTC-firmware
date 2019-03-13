
-- --------------------------------------------------------------------------------
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;

--! Using the data-types
USE work.stub_pkg.ALL;

--! @brief An entity providing a StubPipe
--! @details Detailed description
ENTITY StubPipe IS
  GENERIC(
    DDR : BOOLEAN := FALSE
  );
  PORT(
    clk      : IN STD_LOGIC               := '0'; --! The algorithm clock
    stubsIn  : IN tUnconstrainedStubArray := NullStubArray;
    stubPipe : OUT tStubPipe
  );
END StubPipe;

--! @brief Architecture definition for entity StubPipe
--! @details Detailed description
ARCHITECTURE behavioral OF StubPipe IS
    SIGNAL stubPipeInternal : tStubPipe( stubPipe'RANGE ) := ( OTHERS => NullStubArray );
BEGIN

  stubPipeInternal( 0 ) <= stubsIn; -- since the data is clocked out , no need to clock it in as well...

  gStubPipe : FOR i IN 1 TO stubPipe'HIGH GENERATE
    stubPipeInternal( i ) <= stubPipeInternal( i-1 ) WHEN( RISING_EDGE( clk ) OR( DDR AND FALLING_EDGE( clk ) ) );
  END GENERATE gStubPipe;

  stubPipe <= stubPipeInternal;


END ARCHITECTURE behavioral;
