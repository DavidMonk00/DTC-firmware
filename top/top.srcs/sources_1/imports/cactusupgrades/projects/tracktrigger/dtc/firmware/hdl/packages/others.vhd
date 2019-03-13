--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

-- ----------------------------------------------
PACKAGE others_pkg IS

  SUBTYPE tAddress                IS INTEGER RANGE 0 TO 511;
  TYPE tUnconstrainedAddressArray IS ARRAY( NATURAL RANGE <> ) OF tAddress;
  SUBTYPE tAddressArray           IS tUnconstrainedAddressArray( 0 TO 35 );
  TYPE tAddressPipe               IS ARRAY( INTEGER RANGE <> ) OF tAddressArray;

  CONSTANT NullAddress      : tAddress      := 0;
  CONSTANT NullAddressArray : tAddressArray := ( OTHERS => NullAddress );

  TYPE tReadyArray IS ARRAY( INTEGER RANGE <> ) OF BOOLEAN;
  CONSTANT NullReady : BOOLEAN := TRUE;

END PACKAGE others_pkg;
