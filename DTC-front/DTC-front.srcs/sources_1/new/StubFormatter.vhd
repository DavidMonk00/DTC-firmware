-- ----------------------------------------------------------------------------------
-- -- Company: Imperial College London
-- -- Engineer: David Monk
-- --
-- -- Create Date: 05/07/2019 02:16:21 PM
-- -- Design Name:
-- -- Module Name: StubFormatter - Behavioral
-- -- Project Name: DTC Front End
-- -- Target Devices: KU15P
-- -- Tool Versions:
-- -- Description:
-- --
-- -- Dependencies:
-- --
-- -- Revision:
-- -- Revision 0.01 - File Created
-- -- Revision 0.1 - Added Documentation
-- -- REvision 0.2 - Code Review: 20190531
-- -- Additional Comments:
-- --
-- ----------------------------------------------------------------------------------
--
-- -- Standard library imports
-- library IEEE;
-- use IEEE.std_logic_1164.all;
-- use IEEE.numeric_std.all;
--
-- -- Project specific imports
-- use work.data_types.all;
-- use work.FunkyMiniBus.all;
-- use work.utilities_pkg.all;
--
--
-- entity StubFormatter is
--     GENERIC (
--         index : integer
--     );
--     PORT(
--         -- Input Ports --
--         clk : in std_logic;
--         header : in tHeader;
--         stub_in : in tCICStub;
--         bus_in : in tFMBusArray;
--         link_index : in unsigned(4 downto 0);
--
--         -- Output Ports --
--         stub_out : out tPreCorrectionStub := NullPreCorrectionStub;
--         bus_out : out tFMBusArray
--     );
-- end StubFormatter;
--
-- architecture Behavioral of StubFormatter is
--     signal address : std_logic_vector(17 downto 0) := (others => '0');
--     signal pos_lut_out : std_logic_vector(53 downto 0) := (others => '0');
--     signal clk_bus : std_logic := '0';
--     signal tmp_buff : tNonLUTBuf := NullNonLUTBuff;
--
--     -- Constants required for FunkyMiniBus
--     constant x : integer := bus_out(0)'low + index;
--     subtype A is natural range x + 0 to x + 0;
--
-- begin
--
-- -- Concatenate stub ID and stub strip to form 11 bit address
-- address(7 downto 0) <= std_logic_vector(link_index) & std_logic_vector(stub_in.row(10 downto 8)); -- Highest 3 bits are assumed to be the FE ID - No idea if this is correct as I didn't make the specifications
--
--
-- gPromClocked : for i in 0 to 2 generate
--     PosLutInstance0 : ENTITY work.GenPromClocked
--         GENERIC MAP(
--           FileName => "random_" & INTEGER'IMAGE(i) & ".mif",
--           BusName  => "A/PosLutA" & INTEGER'IMAGE( index )
--         )
--         PORT MAP(
--             -- Input Ports --
--             clk => clk ,
--             AddressIn => address(10 downto 0),
--             BusIn => bus_in(i)(A),
--             BusClk => clk_bus,
--
--             -- Output Ports --
--             DataOut => pos_lut_out(18*i + 17 downto 18*i),
--             BusOut => bus_out(i)(A)
--         );
-- end generate;
--
--
-- pBuffer : process(clk)
-- begin
--     if rising_edge(clk) then
--         -- Buffer data not needed for LUTs
--         tmp_buff.valid <= stub_in.valid;
--         tmp_buff.bx <= (header.boxcar_number(4 downto 0) + stub_in.bx(2 downto 0)) mod 18;
--         tmp_buff.bend <= stub_in.bend;
--         tmp_buff.strip <= stub_in.row(7 downto 0);
--         tmp_buff.column <= stub_in.column;
--     end if;
-- end process;
--
--
-- -- Process to use LUT data to produce r, phi, z coordinates to the stubs. This
-- -- process should be a zero clock process as it is simply routing the output of
-- -- the LUT. Output should be timed such that the stub is assosciated with the
-- -- correct lookup.
-- pFormat : process(clk)
-- begin
--     if rising_edge(clk) then
--         if (tmp_buff.valid = '1') then
--             -- Read buffer values
--             stub_out.header.bx <= tmp_buff.bx;
--             stub_out.payload.valid <= tmp_buff.valid;
--             stub_out.payload.bend <= tmp_buff.bend;
--             stub_out.intrinsic.strip <= tmp_buff.strip;
--             stub_out.intrinsic.column <= tmp_buff.column;
--
--             -- Require LUT
--             stub_out.header.nonant <= pos_lut_out(1 downto 0);
--             stub_out.payload.r <= to_integer(unsigned(pos_lut_out(13 downto 2)));
--             stub_out.payload.z <= to_integer(signed(pos_lut_out(25 downto 14)));
--             stub_out.payload.phi <= to_integer(signed(pos_lut_out(42 downto 26)));
--             stub_out.payload.alpha <= signed(pos_lut_out(45 downto 42));
--             stub_out.payload.layer <= unsigned(pos_lut_out(47 downto 46));
--             stub_out.payload.barrel <= pos_lut_out(48);
--             stub_out.payload.module <= pos_lut_out(49);
--
--         else
--             stub_out <= NullPreCorrectionStub;
--         end if;
--     end if;
-- end process;
--
-- end Behavioral;


-- Standard library imports
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Project specific imports
use work.data_types.all;
use work.FunkyMiniBus.all;
use work.utilities_pkg.all;


entity StubFormatter2 is
    GENERIC (
        index : integer
    );
    PORT(
        -- Input Ports --
        clk : in std_logic;
        header : in tHeader;
        stub_in : in tCICStub;
        bus_in : in tFMBusArray;
        link_index : in unsigned(4 downto 0);

        -- Output Ports --
        stub_out : out tPreCorrectionStub := NullPreCorrectionStub;
        bus_out : out tFMBusArray
    );
end StubFormatter2;

architecture Behavioral of StubFormatter2 is
begin


gStubFormatter : for i in 0 to link_count*stubs_per_word - 1 generate
    signal clk_bus : std_logic := '0';
    -- Constants required for FunkyMiniBus
    constant x : integer := bus_out(0)'low + i;
    subtype A is natural range x + 0 to x + 0;

    signal address : std_logic_vector(17 downto 0) := (others => '0');
    signal tmp_buff : tNonLUTBuf := NullNonLUTBuff;
    signal pos_lut_out : std_logic_vector(53 downto 0) := (others => '0');
begin
    -- Concatenate stub ID and stub strip to form 11 bit address
    address(7 downto 0) <= std_logic_vector(link_index) & std_logic_vector(stub_in.row(10 downto 8)); -- Highest 3 bits are assumed to be the FE ID - No idea if this is correct as I didn't make the specifications

    gPromClocked : for j in 0 to 2 generate
        PosLutInstance0 : ENTITY work.GenPromClocked
            GENERIC MAP(
              FileName => "random_" & INTEGER'IMAGE(j) & ".mif",
              BusName  => "A/PosLutA" & INTEGER'IMAGE(i)
            )
            PORT MAP(
                -- Input Ports --
                clk => clk ,
                AddressIn => address(10 downto 0),
                BusIn => bus_in(j)(A),
                BusClk => clk_bus,

                -- Output Ports --
                DataOut => pos_lut_out(18*j + 17 downto 18*j),
                BusOut => bus_out(j)(A)
            );
    end generate;

    pBuffer : process(clk)
    begin
        if rising_edge(clk) then
            -- Buffer data not needed for LUTs
            tmp_buff.valid <= stub_in.valid;
            tmp_buff.bx <= (header.boxcar_number(4 downto 0) + stub_in.bx(2 downto 0)) mod 18;
            tmp_buff.bend <= stub_in.bend;
            tmp_buff.strip <= stub_in.row(7 downto 0);
            tmp_buff.column <= stub_in.column;
        end if;
    end process;

    -- Process to use LUT data to produce r, phi, z coordinates to the stubs. This
    -- process should be a zero clock process as it is simply routing the output of
    -- the LUT. Output should be timed such that the stub is assosciated with the
    -- correct lookup.
    pFormat : process(clk)
    begin
        if rising_edge(clk) then
            if (tmp_buff.valid = '1') then
                -- Read buffer values
                stub_out.header.bx <= tmp_buff.bx;
                stub_out.payload.valid <= tmp_buff.valid;
                stub_out.payload.bend <= tmp_buff.bend;
                stub_out.intrinsic.strip <= tmp_buff.strip;
                stub_out.intrinsic.column <= tmp_buff.column;

                -- Require LUT
                stub_out.header.nonant <= pos_lut_out(1 downto 0);
                stub_out.payload.r <= to_integer(unsigned(pos_lut_out(13 downto 2)));
                stub_out.payload.z <= to_integer(signed(pos_lut_out(25 downto 14)));
                stub_out.payload.phi <= to_integer(signed(pos_lut_out(42 downto 26)));
                stub_out.payload.alpha <= signed(pos_lut_out(45 downto 42));
                stub_out.payload.layer <= unsigned(pos_lut_out(47 downto 46));
                stub_out.payload.barrel <= pos_lut_out(48);
                stub_out.payload.module <= pos_lut_out(49);

            else
                stub_out <= NullPreCorrectionStub;
            end if;
        end if;
    end process;    

end generate;

end Behavioral;
