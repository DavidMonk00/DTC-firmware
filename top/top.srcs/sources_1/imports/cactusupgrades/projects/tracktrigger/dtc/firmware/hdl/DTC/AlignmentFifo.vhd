-- -----------------------------------------------------------------------------------------------------------------------------
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;

--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

USE WORK.stub_pkg.ALL;
USE WORK.utilities_pkg.ALL;

ENTITY AlignmentFifo IS
  PORT(
    clk      : IN STD_LOGIC; --! The algorithm clock
    StubsIn  : IN tStubArray  := NullStubArray;
    StubsOut : OUT tStubArray := NullStubArray
  );
END AlignmentFifo;


ARCHITECTURE behavioral OF AlignmentFifo IS
BEGIN

  g1                                                   : FOR i IN 0 TO 35 GENERATE
    SIGNAL Counter                                     : INTEGER RANGE -255 TO 107       := - ( 6 * (i/2) ) - 40;

    SIGNAL srst , rd_en , full , empty , valid : STD_LOGIC                       := '0';
    SIGNAL din , dout                                  : STD_LOGIC_VECTOR( 36 DOWNTO 0 ) := ( OTHERS => '0' );

  BEGIN

    din   <= ToStdLogicVector( StubsIn( i ) , 37 );

    FifoInstance : ENTITY work.fifo_generator_0
    PORT MAP(
      clk   => clk ,
      srst  => srst ,
      din   => din( 35 DOWNTO 0 ) ,
      wr_en => din( 36 ) ,
      rd_en => rd_en ,
      dout  => dout( 35 DOWNTO 0 ) ,
      full  => full ,
      empty => empty ,
      valid => valid
    );

    Control : PROCESS( clk )
    BEGIN
      IF( RISING_EDGE( clk ) ) THEN

        IF( Counter = 107 ) THEN
          Counter <= 0;
        ELSE
          Counter <= Counter + 1;
        END IF;

        srst <= '0';
        IF( Counter = 0 ) THEN
          rd_en <= '1';
        ELSIF( Counter = 102 ) THEN
          rd_en <= '0';
          srst  <= '1';
        END IF;

        IF( rd_en = '0' ) THEN
          StubsOut( i ) <= NullStub;
        ELSE
          StubsOut( i )            <= ToStub( dout );
          StubsOut( i ) .StubValid <= ToBoolean( valid AND rd_en );
          StubsOut( i ) .DataValid <= True;
        END IF;

      END IF;
    END PROCESS;




  END GENERATE g1;
-- ---------------------------------------

END ARCHITECTURE behavioral;
