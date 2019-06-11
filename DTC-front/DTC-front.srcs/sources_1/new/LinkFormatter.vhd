-- Standard library imports
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

-- Project specific imports
use work.data_types.all;


-- entity LinkFormatter is
--     port (
--         --Input Ports --
--         clk : in std_logic;
--         link_in : in std_logic_vector(63 downto 0);
--
--         -- Output Ports --
--         header : out tHeader := NullHeader;
--         stubs : out tCICWordStubArray := NullCICWordStubArray
--     );
-- end LinkFormatter;
--
-- architecture Behavioral of LinkFormatter is
--     signal counter : integer range 0 to (frames - 1) := (frames - 1);
--
-- begin
--     pCounter : process(clk)
--     begin
--         if rising_edge(clk) then
--             if counter = (frames - 1) then
--                 counter <= 0;
--             else
--                 counter <= counter + 1;
--             end if;
--         end if;
--     end process pCounter;
--
--     pHeaderSeparation : process(clk)
--     begin
--         if rising_edge(clk) then
--             -- Separate out header words from payload
--             if counter < header_frames then
--                 header.boxcar_number <= unsigned(link_in(63 downto 52));
--                 header.stub_count <= unsigned(link_in(51 downto 46));
--                 stubs(0).valid <= '0';
--                 stubs(1).valid <= '0';
--             else
--                 -- Conversion to current DTC input word format
--                 fStubAssignment : for i in 0 to stubs_per_word - 1 loop
--                     stubs(i).valid  <= link_in(63 - i * stub_width);
--                     stubs(i).bx     <= unsigned(link_in(63 - (i * stub_width + 1) downto 63 - (i * stub_width + 7)));
--                     stubs(i).row    <= signed(link_in(63 - (i * stub_width + 8) downto 63 - (i * stub_width + 18)));
--                     stubs(i).column <= signed(link_in(63 - (i * stub_width + 19) downto 63 - (i * stub_width + 23)));
--                     stubs(i).bend   <= signed(link_in(63 - (i * stub_width + 24) downto 63 - (i * stub_width + 27)));
--                 end loop;
--             end if;
--         end if;
--     end process;
--
-- end Behavioral;





-- Standard library imports
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

-- Project specific imports
use work.data_types.all;



entity LinkFormatter2 is
    port (
        clk : in std_logic;
        LinksIn : in tLinksIn;
        HeaderPipeOut : out tHeaderPipe;
        StubPipeOut : out tCICStubPipe
    );
end LinkFormatter2;


architecture Behavioral of LinkFormatter2 is

    signal HeaderArray : tHeaderArray := NullHeaderArray;
    signal StubArray :  tCICStubArray := NullCICStubArray;
    signal counter : integer range 0 to (frames - 1) := (frames - 1);

begin

    pCounter : process(clk)
    begin
        if rising_edge(clk) then
            if counter = (frames - 1) then
                counter <= 0;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process pCounter;

    gLinksFormat : for i in 0 to link_count - 1 generate
    begin

        pHeaderSeparation : process(clk)
        begin
            if rising_edge(clk) then
                -- Separate out header words from payload
                if counter < header_frames then
                    HeaderArray(i).boxcar_number <= unsigned(link_in(63 downto 52));
                    HeaderArray(i).stub_count <= unsigned(link_in(51 downto 46));
                    fStubValid : for j in 0 to stubs_per_word - 1 loop
                        StubArray(i * stubs_per_word + j).valid <= '0';
                    end loop;
                else
                    -- Conversion to current DTC input word format
                    fStubAssignment : for j in 0 to stubs_per_word - 1 loop
                        StubArray(i * stubs_per_word + j).valid  <= link_in(63 - j * stub_width);
                        StubArray(i * stubs_per_word + j).bx     <= unsigned(link_in(63 - (j * stub_width + 1) downto 63 - (j * stub_width + 7)));
                        StubArray(i * stubs_per_word + j).row    <= signed(link_in(63 - (j * stub_width + 8) downto 63 - (j * stub_width + 18)));
                        StubArray(i * stubs_per_word + j).column <= signed(link_in(63 - (j * stub_width + 19) downto 63 - (j * stub_width + 23)));
                        StubArray(i * stubs_per_word + j).bend   <= signed(link_in(63 - (j * stub_width + 24) downto 63 - (j * stub_width + 27)));
                    end loop;
                end if;
            end if;
        end process;

    end generate;

    CICStubPipeInstance : ENTITY work.CICStubPipe
    PORT MAP( clk , StubArray , StubPipeOut );

    CICHeaderPipeInstance : ENTITY work.CICHeaderPipe
    PORT MAP( clk , HeaderArray , HeaderPipeOut );

end Behavioral;
