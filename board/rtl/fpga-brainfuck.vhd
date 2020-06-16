library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uart;

library extras;
use extras.all;

entity fpga_top is
port (
    -- --------------------------------
    -- CLOCKS
    ----------------------------------- 
    -- Reference clocks
    CLK		        : in std_logic;
    -- Reset button
    RESET_BTN_N     : in std_logic; 
    
    -- --------------------------------
    -- UART interface
    -- --------------------------------
    UART_TXD  : out std_logic;
    UART_RXD  : in  std_logic

);
end entity;

architecture full of fpga_top is

    -- Constants ----------------------
    constant CLK_FREQ      : integer := 12e6;   -- set system clock frequency in Hz
    constant BAUD_RATE     : integer := 115200; -- baud rate value
    constant PARITY_BIT    : string  := "none"; -- legal values: "none", "even", "odd", "mark", "space"
    constant USE_DEBOUNCER : boolean := True;   -- enable/disable debouncer

    constant RESET_CNT_WIDTH : integer := 7;
    
    -- Signals ------------------------

    -- Clock & resets & debouncers
    signal clk_ref      : std_logic;
    signal clk_c0 		: std_logic;
    
    signal reset_cnt_c0	    : unsigned(RESET_CNT_WIDTH-1 downto 0);
    signal reset_cnt_ref	: unsigned(RESET_CNT_WIDTH-1 downto 0);
    signal locked		    : std_logic;

    signal reset_c0_sync        : std_logic;
    signal reset_ref_sync       : std_logic;
    signal reset_c0 	        : std_logic;
    signal reset_ref            : std_logic;

    signal btn_debounced_n      : std_logic;
    signal btn_debounced        : std_logic;
	
begin

    -- ------------------------------------------------------------------------
    -- Clocks & Reset
    -- ------------------------------------------------------------------------

    -- Clocks are generated by the PLL from reference closk 12MHz. The reset is
    -- asserted automatically when the output clocks are locked. There is also a 
    -- possibility to assert the system reset by the reset buttton.
    --
    -- List of generated clocks & resets:
    -- * clk_c0 and reset_c0 -- main system clocks used in the design (after the PLL)
    -- * CLK (12MHz) and reset_12 -- reference clocks and reset 

    -- Generate input clocks
    pll_i : work.pll 
    port map(
        inclk0		=> CLK,
        c0			=> clk_c0,
        locked		=> locked
    );

    -- Reference clock signal
    clk_ref <= CLK;

    -- Reset synchronization
    reset_sync_ref_i : reset_synchronizer 
    generic map(
        STAGES                  => 3,
        RESET_ACTIVE_LEVEL      => '1'
    )
    port map(
        --# {{clocks|}}
        Clock       => clk_ref,
        Reset       => RESET_BTN_N,

        --# {{data|}}
        Sync_reset => reset_ref_sync
    );

    reset_sync_c0_i : reset_synchronizer 
    generic map(
        STAGES                  => 3,
        RESET_ACTIVE_LEVEL      => '1'
    )
    port map(
        --# {{clocks|}}
        Clock       => clk_c0,
        Reset       => RESET_BTN_N,

        --# {{data|}}
        Sync_reset => reset_c0_sync
    );

    -- Reset generation is based on the counter which holds the reset for 
    -- several clock cycles. The generator of the funciton is taken from the
    -- MSB bit of the counter vector.
    reset_c0_p : process(clk_c0)
    begin
        if(rising_edge(clk_c0))then
            if(locked = '0' or reset_c0_sync = '1') then
                -- Reset is locked
                reset_cnt_c0  <= (others=>'0');
            else
                -- Reset needs to be asserted (one clock cycle shoudl be enough)
                if(reset_cnt_c0(6) = '0')then
                    reset_cnt_c0 <= reset_cnt_c0 + 1;
                end if;
            end if;
        end if;
    end process;

    reset_ref_p : process(clk_ref)
    begin
        if(rising_edge(clk_ref))then
            if(reset_ref_sync = '1') then
                -- Reset is locked
                reset_cnt_ref  <= (others=>'0');
            else
                -- Reset needs to be asserted (one clock cycle shoudl be enough)
                if(reset_cnt_ref(6) = '0')then
                    reset_cnt_ref <= reset_cnt_ref + 1;
                end if;
            end if;
        end if;
    end process;

    -- Generated reset signals
    reset_c0    <= not(reset_cnt_c0(RESET_CNT_WIDTH-1));
    reset_ref   <= not(reset_cnt_ref(RESET_CNT_WIDTH-1));

    -- ------------------------------------------------------------------------
    -- UART connection -- it is passed to the 12MHz clock domain
    -- ------------------------------------------------------------------------

    -- UART endpoint for the communication with the software
	uart_i: entity uart.UART
    generic map (
        CLK_FREQ      => CLK_FREQ,
        BAUD_RATE     => BAUD_RATE,
        PARITY_BIT    => PARITY_BIT,
        USE_DEBOUNCER => USE_DEBOUNCER
    )
    port map (
        CLK         => CLK,
        RST         => reset_c0,
        -- UART INTERFACE
        UART_TXD    => UART_TXD,
        UART_RXD    => UART_RXD,
        -- USER DATA OUTPUT INTERFACE
        DOUT        => open,
        DOUT_VLD    => open,
        FRAME_ERROR => open,
        -- USER DATA INPUT INTERFACE
        DIN         => (others => '0'),
        DIN_VLD     => '1',
        DIN_RDY     => open
    );

end architecture;
