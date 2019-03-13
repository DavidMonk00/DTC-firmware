-- --------------------------------------------------------------------------------
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;

--! Using the data-types
USE work.stub_pkg.ALL;

--! @brief An entity providing a AddressPipe
--! @details Detailed description
ENTITY AddressPipe IS
  GENERIC(
    DDR : BOOLEAN := FALSE
  );
  PORT(
    clk         : IN STD_LOGIC     := '0'; --! The algorithm clock
    addressIn   : IN tAddressArray := NullAddressArray;
    addressPipe : OUT tAddressPipe
  );
END AddressPipe;

--! @brief Architecture definition for entity AddressPipe
--! @details Detailed description
ARCHITECTURE behavioral OF AddressPipe IS
    SIGNAL addressPipeInternal : tAddressPipe( addressPipe'RANGE ) := InitializeAddressPipe( addressPipe'LENGTH );
BEGIN

  addressPipeInternal( 0 ) <= addressIn; -- since the data is clocked out , no need to clock it in as well...

  gAddressPipe : FOR i IN 1 TO addressPipe'HIGH GENERATE
    addressPipeInternal( i ) <= addressPipeInternal( i-1 ) WHEN( RISING_EDGE( clk ) OR( DDR AND FALLING_EDGE( clk ) ) );
  END GENERATE gAddressPipe;

  addressPipe <= addressPipeInternal;


END ARCHITECTURE behavioral;
