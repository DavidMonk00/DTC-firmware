
-- --------------------------------------------------------------------------------
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;

--! Using the data-types
use work.data_types.all;

--! @brief An entity providing a StubPipe
--! @details Detailed description
ENTITY CICStubPipe IS
  PORT(
    clk      : IN STD_LOGIC               := '0'; --! The algorithm clock
    stubsIn  : IN tCICStubArray := NullCICStubArray;
    stubPipe : OUT tCICStubPipe
  );
END CICStubPipe;

--! @brief Architecture definition for entity StubPipe
--! @details Detailed description
ARCHITECTURE behavioral OF CICStubPipe IS
    SIGNAL stubPipeInternal : tCICStubPipe( stubPipe'RANGE ) := ( OTHERS => NullCICStubArray );
BEGIN

  stubPipeInternal( 0 ) <= stubsIn; -- since the data is clocked out , no need to clock it in as well...

  gStubPipe : FOR i IN 1 TO stubPipe'HIGH GENERATE
    stubPipeInternal( i ) <= stubPipeInternal( i-1 ) WHEN RISING_EDGE( clk );
  END GENERATE gStubPipe;

  stubPipe <= stubPipeInternal;

END ARCHITECTURE behavioral;
