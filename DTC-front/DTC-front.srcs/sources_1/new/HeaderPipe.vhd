
-- --------------------------------------------------------------------------------
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;

--! Using the data-types
use work.data_types.all;

--! @brief An entity providing a HeaderPipe
--! @details Detailed description
ENTITY CICHeaderPipe IS
  PORT(
    clk      : IN STD_LOGIC               := '0'; --! The algorithm clock
    HeadersIn  : IN tHeaderArray := NullHeaderArray;
    HeaderPipe : OUT tHeaderPipe
  );
END CICHeaderPipe;

--! @brief Architecture definition for entity HeaderPipe
--! @details Detailed description
ARCHITECTURE behavioral OF CICHeaderPipe IS
    SIGNAL HeaderPipeInternal : tHeaderPipe( HeaderPipe'RANGE ) := ( OTHERS => NullCICWordHeaderArray );
BEGIN

  HeaderPipeInternal( 0 ) <= HeadersIn; -- since the data is clocked out , no need to clock it in as well...

  gHeaderPipe : FOR i IN 1 TO HeaderPipe'HIGH GENERATE
    HeaderPipeInternal( i ) <= HeaderPipeInternal( i-1 ) WHEN RISING_EDGE( clk );
  END GENERATE gHeaderPipe;

  HeaderPipe <= HeaderPipeInternal;

END ARCHITECTURE behavioral;
