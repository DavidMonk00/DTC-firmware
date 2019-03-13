--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

USE IEEE.MATH_REAL.ALL;

--! Writing to and from files
USE IEEE.STD_LOGIC_TEXTIO.ALL;
--! Writing to and from files
USE STD.TEXTIO.ALL;


-- ----------------------------------------------
PACKAGE XMLutilities_pkg IS

  FUNCTION hstring( value             : STD_LOGIC_VECTOR ) RETURN STRING;
  FUNCTION ToXMLattr( Name            : STRING ; Value : STD_LOGIC_VECTOR ) RETURN STRING;
  FUNCTION ToXMLattr( Name            : STRING ; Value : BOOLEAN ) RETURN STRING;
  FUNCTION ToXMLattr( Name            : STRING ; Value : INTEGER ) RETURN STRING;
  FUNCTION ToXMLattr( Name            : STRING ; Value : SIGNED ) RETURN STRING;
  FUNCTION ToXMLattr( Name            : STRING ; Value : UNSIGNED ) RETURN STRING;

  PROCEDURE InitializeXML( FILE aFile : TEXT );
  PROCEDURE CloseXML( FILE aFile      : TEXT );

END PACKAGE XMLutilities_pkg;
-- ----------------------------------------------

-- ----------------------------------------------
PACKAGE BODY XMLutilities_pkg IS
-- ----------------------------------------------------------
  FUNCTION hstring( value : STD_LOGIC_VECTOR ) RETURN STRING IS
    CONSTANT ne           : INTEGER                                    := ( value'LENGTH + 3 ) / 4;
    VARIABLE FixedSize    : STD_LOGIC_VECTOR( ( 4 * ne ) -1 DOWNTO 0 ) := ( OTHERS => '0' );
    VARIABLE result       : STRING( 1 TO ne + 2 );
    CONSTANT LUT          : STRING( 1 TO 16 ) := "0123456789ABCDEF";
  BEGIN

    FixedSize( value'RANGE ) := value;

    result( 1 TO 2 )         := "0x";
    FOR i IN 0 TO ne-1 LOOP
      result( 2 + ne-i ) := LUT( TO_INTEGER( UNSIGNED( FixedSize( 4 * i + 3 DOWNTO 4 * i ) ) ) + 1 );
    END LOOP;
    RETURN result;
  END FUNCTION hstring;
-- ----------------------------------------------------------

  FUNCTION ToXMLattr( Name : STRING ; Value : STD_LOGIC_VECTOR ) RETURN STRING IS
  BEGIN
    RETURN " " & Name & "='" & hstring( Value ) & "' ";
  END FUNCTION ToXMLattr;

  FUNCTION ToXMLattr( Name : STRING ; Value : BOOLEAN ) RETURN STRING IS
  BEGIN
    RETURN " " & Name & "='" & BOOLEAN'IMAGE( Value ) & "' ";
  END FUNCTION ToXMLattr;

  FUNCTION ToXMLattr( Name : STRING ; Value : INTEGER ) RETURN STRING IS
  BEGIN
    RETURN " " & Name & "='" & INTEGER'IMAGE( Value ) & "' ";
  END FUNCTION ToXMLattr;

  FUNCTION ToXMLattr( Name : STRING ; Value : SIGNED ) RETURN STRING IS
  BEGIN
    RETURN " " & Name & "='" & INTEGER'IMAGE( TO_INTEGER( Value ) ) & "' ";
  END FUNCTION ToXMLattr;

  FUNCTION ToXMLattr( Name : STRING ; Value : UNSIGNED ) RETURN STRING IS
  BEGIN
    RETURN " " & Name & "='" & INTEGER'IMAGE( TO_INTEGER( Value ) ) & "' ";
  END FUNCTION ToXMLattr;


  PROCEDURE InitializeXML( FILE aFile : TEXT ) IS
    VARIABLE s                        : LINE;
  BEGIN
    WRITE( s , STRING' ( "<?xml version='1.0'?>" ) );
    WRITELINE( aFile , s );
    WRITE( s , STRING' ( "<data>" ) );
    WRITELINE( aFile , s );
  END PROCEDURE InitializeXML;


  PROCEDURE CloseXML( FILE aFile : TEXT ) IS
    VARIABLE s                   : LINE;
  BEGIN
    WRITE( s , STRING' ( "</data>" ) );
    WRITELINE( aFile , s );
  END PROCEDURE CloseXML;

END PACKAGE BODY XMLutilities_pkg;
