--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! Writing to and from files
USE STD.TEXTIO.ALL;
--! Writing to and from files
USE IEEE.STD_LOGIC_TEXTIO.ALL;

--! Using the Calo-L2 common constants
USE work.utilities_pkg.ALL;



--! @brief An entity providing a GenRomClocked
--! @details Detailed description
ENTITY GenRomClocked IS
  GENERIC(
          FileName : STRING
         );
  PORT(
        clk       : IN STD_LOGIC; --! The algorithm clock
        Enable    : IN BOOLEAN := TRUE;
        AddressIn : IN STD_LOGIC_VECTOR;
        DataOut   : OUT STD_LOGIC_VECTOR
      );
END ENTITY GenRomClocked;

--! @brief Architecture definition for entity GenRomClocked
--! @details Detailed description
ARCHITECTURE behavioral OF GenRomClocked IS

  CONSTANT WidthIn  : INTEGER := AddressIn'LENGTH;
  CONSTANT WidthOut : INTEGER := DataOut'LENGTH;

  TYPE mem_type IS ARRAY( 0 TO( 2 ** WidthIn ) -1 ) OF STD_LOGIC_VECTOR( WidthOut -1 DOWNTO 0 );

  IMPURE FUNCTION InitRomFromFile( RomFileName : IN STRING ) RETURN mem_type IS
    FILE RomFile                               : TEXT;
    VARIABLE RomFileLine , Debug               : LINE;
    VARIABLE TEMP                              : CHARACTER;
    VARIABLE Value                             : STD_LOGIC_VECTOR( 19 DOWNTO 0 );
    VARIABLE ROM                               : mem_type;
  BEGIN

    FILE_OPEN( RomFile , RomFileName , READ_MODE );

    FOR i IN mem_type'RANGE LOOP
      READLINE( RomFile , RomFileLine );
      READ( RomFileLine , TEMP );
      READ( RomFileLine , TEMP );
      HREAD( RomFileLine , Value );
      rom( i ) := Value( WidthOut -1 DOWNTO 0 );
    END LOOP;
    FILE_CLOSE( RomFile );

    RETURN ROM;
  END FUNCTION InitRomFromFile;

  SHARED VARIABLE ROM : mem_type                                 := InitRomFromFile( FileName );

--ATTRIBUTE rom_style : STRING;
--ATTRIBUTE rom_style OF ROM : VARIABLE IS "block";

  SIGNAL Data         : STD_LOGIC_VECTOR( WidthOut -1 DOWNTO 0 ) := ( OTHERS => '0' );

BEGIN

-- LUT port
  PROCESS( clk )
  BEGIN
    IF RISING_EDGE( clk ) THEN
      IF Enable THEN
        Data <= ROM( TO_INTEGER( UNSIGNED( AddressIn ) ) );
      END IF;
    END IF;
  END PROCESS;

  DataOut <= Data; --Get rid of the ugly uninitialized signals

END ARCHITECTURE behavioral;
