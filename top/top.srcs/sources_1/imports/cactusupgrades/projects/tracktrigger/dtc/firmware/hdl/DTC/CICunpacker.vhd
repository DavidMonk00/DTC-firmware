--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

USE WORK.stub_pkg.ALL;
USE WORK.utilities_pkg.ALL;
USE work.mp7_data_types.ALL;

ENTITY CICunpacker IS
  GENERIC( 
    IncomingDataWidth : INTEGER;
    OutgoingStubWidth : INTEGER;
    OutgoingHeaderWidth : INTEGER;
    FramesPerBoxCar : INTEGER
  );
  PORT(
    clk        : IN STD_LOGIC; --! The algorithm clock
    LinkIn    :  IN lword := LWORD_NULL;
    StubOut   : OUT lword := LWORD_NULL;
    HeaderOut : OUT lword := LWORD_NULL
  );
END CICunpacker;



-- -------------------------------------------------------------------------------------------------------------------------------------------------
ARCHITECTURE RTL OF CICunpacker IS
  signal Accumulator : STD_LOGIC_VECTOR( 47 downto 0 ) := (OTHERS=>'0');
  signal BitCounter : INTEGER RANGE -1 TO 47 := -1; -- Location of the Stub MSB
  signal ReadingHeader : BOOLEAN := TRUE;
  signal Counter : INTEGER RANGE 0 TO FramesPerBoxCar-1 := 0;

BEGIN

  prc : PROCESS( clk )
  BEGIN
    IF( RISING_EDGE( clk ) ) THEN
      IF( not ToBoolean( LinkIn .valid ) ) THEN
        StubOut <= LWORD_NULL;
        HeaderOut <= LWORD_NULL;
        BitCounter    <= -1;
        Counter <= 0;
        Accumulator   <= (OTHERS=>'0');
        ReadingHeader <= TRUE;
      ELSE

        HeaderOut .Valid <= '1';
        HeaderOut .Data( OutgoingHeaderWidth ) <= '0'; 

        StubOut .Valid <= '1';
        StubOut .Data( OutgoingStubWidth ) <= '0'; 

        -- Update Accumulator2 variable before Accumulator variable to add a layer of registering to the variable bit-shift
        If( ReadingHeader ) THEN
          if( BitCounter >= OutgoingHeaderWidth-1 ) THEN
            HeaderOut .Data( OutgoingHeaderWidth-1 downto 0 ) <= Accumulator( BitCounter downto BitCounter-(OutgoingHeaderWidth-1) );
            HeaderOut .Data( OutgoingHeaderWidth ) <= '1'; 
            BitCounter <= BitCounter - OutgoingHeaderWidth + IncomingDataWidth; 
            ReadingHeader <= FALSE;
          else
            BitCounter <= BitCounter + IncomingDataWidth;            
          end if;
        else
          if( BitCounter >= OutgoingStubWidth-1 ) THEN
            StubOut .Data( OutgoingStubWidth-1 downto 0 ) <= Accumulator( BitCounter downto BitCounter-(OutgoingStubWidth-1) );
            StubOut .Data( OutgoingStubWidth ) <= '1'; 
            BitCounter <= BitCounter - OutgoingStubWidth + IncomingDataWidth; 
          else
            BitCounter <= BitCounter + IncomingDataWidth;            
          end if;
        end if;

        Accumulator( 47 downto 0 ) <= Accumulator( 47-IncomingDataWidth downto 0 ) & LinkIn .Data( IncomingDataWidth-1 DOWNTO 0 );

        if( Counter = FramesPerBoxCar-1 ) then
          Counter <= 0;
          ReadingHeader <= TRUE;
        else
          Counter <= Counter + 1 ;
        END IF;

      end if;
    END IF;
  END PROCESS;

END ARCHITECTURE RTL;
-- -------------------------------------------------------------------------------------------------------------------------------------------------









