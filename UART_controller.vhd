


--Author: Gonçalo architecture
--Description: receives UART comm. and sets leds architecture
--sends UART message every second with 2 BYTES (can be vhanged for any number of BYTES, still on architecture
--BAUD RATE can be adjusted as wished as well as sending rate
--Read serial data with putty or with TIO 

--To send  more Bytes can be done changing the state machine in entity
--16bbits
--1 stop bit
-- no parity bit
-- Baudrate 115200

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity UART_controller is

    port(
        clk              : in  std_logic;
        reset            : in  std_logic;
        tx_enable        : in  std_logic;

        data_in          : in  std_logic_vector (15 downto 0);
        data_out         : out std_logic_vector (7 downto 0);
        led              : out std_logic ;
        
        ja : in STD_LOGIC_VECTOR (1 downto 0);           -- adc pins                        vai se conectar   
        
            
        rx               : in  std_logic;
        tx               : out std_logic
        );
end UART_controller;


architecture Behavioral of UART_controller is

    component xadc_wiz_0 is
       port
       (
        daddr_in        : in  STD_LOGIC_VECTOR (6 downto 0);     -- Address bus for the dynamic reconfiguration port
        den_in          : in  STD_LOGIC;                         -- Enable Signal for the dynamic reconfiguration port
        di_in           : in  STD_LOGIC_VECTOR (15 downto 0);    -- Input data bus for the dynamic reconfiguration port
        dwe_in          : in  STD_LOGIC;                         -- Write Enable for the dynamic reconfiguration port
        do_out          : out  STD_LOGIC_VECTOR (15 downto 0);   -- Output data bus for dynamic reconfiguration port
        drdy_out        : out  STD_LOGIC;                        -- Data ready signal for the dynamic reconfiguration port
        dclk_in         : in  STD_LOGIC;                         -- Clock input for the dynamic reconfiguration port
        vauxp14         : in  STD_LOGIC;                         --A10
        vauxn14         : in  STD_LOGIC;                         --A11
        busy_out        : out  STD_LOGIC;                        -- ADC Busy signal
        channel_out     : out  STD_LOGIC_VECTOR (4 downto 0);    -- Channel Selection Outputs
        eoc_out         : out  STD_LOGIC;                        -- End of Conversion Signal
        eos_out         : out  STD_LOGIC;                        -- End of Sequence Signal
        alarm_out       : out STD_LOGIC;                         -- OR'ed output of all the Alarms
        vp_in           : in  STD_LOGIC;                         -- Dedicated Analog Input Pair
        vn_in           : in  STD_LOGIC
    );
    end component;
    
    
    component debounce
        port(
            clk        : in  std_logic;
            reset      : in  std_logic;
            button_in  : in  std_logic;
            button_out : out std_logic
            );
    end component;


    component UART
        port(
            clk            : in  std_logic;
            reset          : in  std_logic;
            tx_start       : in  std_logic;

            data_in        : in  std_logic_vector (15 downto 0);
            data_out       : out std_logic_vector (7 downto 0);

            rx             : in  std_logic;
            tx             : out std_logic
            );
    end component;

signal clk_UART : std_logic;
signal count : integer :=0;
signal clk_out1 : STD_LOGIC;


signal ADCValidData : std_logic_vector(11 downto 0);                -- 12 Bits do ADC
signal ADCNonValidData : std_logic_vector(3 downto 0);
signal EnableInt : std_logic := '1';                              --enables the ADC

begin

    tx_controller: Debounce     --used so that it sen dthe message only one time. I can adjust this part of code counting the number of clock cicles
    port map(
            clk            => clk,
            reset          => reset,
            button_in      => clk_out1,
            button_out     => clk_UART
            );

    UART_transceiver: UART
    port map(
            clk            => clk,
            reset          => reset,
            tx_start       => clk_UART,
            data_in        => ADCValidData & "0000",
            data_out       => data_out,
            rx             => rx,
            tx             => tx
            );
            
        
      --inicialiaza o ADC  
        
    adcImp : xadc_wiz_0
    port map
    (
        daddr_in        => "0011110",           -- 14th drp port address is 0x1E
        den_in          => EnableInt,           -- set enable drp port
        di_in           => (others => '0'),     -- set input data as 0 
        dwe_in          => '0',                 -- disable write to drp
        do_out(15 downto 4)    => ADCValidData, -- because we use unipolar xadc
        do_out(3 downto 0 )    => ADCNonValidData,  -- non valid data with dummy vector
        drdy_out        => open,                    
        dclk_in         => clk,           -- 125 Mhz system clock wires to drp
        vauxp14         => ja(0),               -- xadc positive pin                                      
        vauxn14         => ja(1),               -- xadc negative pin
        busy_out        => open,                   
        channel_out    => open,    
        eoc_out         => EnableInt,          -- enable int                   
        eos_out         => open,                      
        alarm_out       => open,                         
        vp_in           => '0',                        
        vn_in           => '0'
    );
    
    
    
    --converts the 100MHz clock in a 100M/(x*2) Hz
   -- em que X é numero de eventos que se quer por segundo
    
    
     process(clk)     
    begin
        if(rising_edge(clk)) then
            count <=count+1;
            if(count = 100000000/16) then
                clk_out1 <= not clk_out1;
                count <=0;
            end if;
        end if;
    end process;
            
    led<= clk_out1;          -- Just to check the sending clock

end Behavioral;
