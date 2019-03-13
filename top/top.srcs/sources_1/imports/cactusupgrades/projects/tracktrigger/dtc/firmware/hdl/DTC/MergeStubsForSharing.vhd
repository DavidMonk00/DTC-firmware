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

ENTITY MergeStubsForSharing IS
  PORT(
    clk      : IN STD_LOGIC; --! The algorithm clock
    StubsIn  : IN tStubArray  := NullStubArray;
    StubsOut : OUT tStubArray := NullStubArray
  );
END MergeStubsForSharing;


ARCHITECTURE behavioral OF MergeStubsForSharing IS
BEGIN

  g1                                                   : FOR i IN 0 TO 7 GENERATE
    SIGNAL srst , rd_en , full , empty , valid : STD_LOGIC_VECTOR( 0 TO 8 )                       := ( OTHERS => '0' );
    TYPE tData is array ( 0 to 8 ) of STD_LOGIC_VECTOR( 36 DOWNTO 0 );
    SIGNAL din , dout                                  : tData := ( OTHERS => ( OTHERS => '0' ) );

    SIGNAL data_valid : STD_LOGIC_VECTOR( 4 downto 0 ) := (OTHERS=>'0');


  BEGIN

    g2 : FOR j in 0 to 8 generate
    begin

      srst(j) <= Not ToStdLogic( StubsIn( (9*i)+j ).DataValid );
      din(j)   <= ToStdLogicVector( StubsIn( (9*i)+j ) , 37 );

      FifoInstance : ENTITY work.fifo_generator_0
      PORT MAP(
        clk   => clk ,
        srst  => srst(j) ,
        din   => din(j)( 35 DOWNTO 0 ) ,
        wr_en => din(j)( 36 ) ,
        rd_en => rd_en(j) ,
        dout  => dout(j)( 35 DOWNTO 0 ) ,
        full  => full(j) ,
        empty => empty(j) ,
        valid => valid(j)
      );

    end generate g2;

    Control : PROCESS( clk )
    BEGIN
      IF( RISING_EDGE( clk ) ) THEN

        rd_en <= (OTHERS=>'0');
        StubsOut(i) <= NullStub;

        for j in 0 to 8 loop
          if ToBoolean( valid(j) and NOT rd_en(j) ) THEN
            StubsOut(i) <= ToStub( dout(j) );
            StubsOut(i).StubValid <= TRUE;
            rd_en(j) <= '1';
            exit;
          end if;
        end loop;

        data_valid <= data_valid(3 downto 0) & ToStdLogic( StubsIn(9*i).DataValid ); 
        StubsOut(i).DataValid <= ToBoolean(data_valid(2));

      END IF;
    END PROCESS;

  END GENERATE g1;
-- ---------------------------------------

END ARCHITECTURE behavioral;
