-- Moore FSM waveform generator: two drive signals of an inverter leg, 30 us period.
--   S0: Sig1=0 Sig2=1 15 us | S1: 1 1  3 us (dead time)
--   S2: Sig1=1 Sig2=0  9 us | S3: 1 1  3 us (dead time)
library ieee;
use ieee.std_logic_1164.all;

entity Wave_Gen is
  port (
    Clk50, Rst : in  std_logic;                     -- 50 MHz board clock, active-high reset
    Sig1, Sig2 : out std_logic
  );
end Wave_Gen;

architecture arch of Wave_Gen is
  type state_type is (S0, S1, S2, S3);
  signal cur   : state_type;
  signal t     : integer range 0 to 14;             -- clock periods spent in current state
  signal Clk   : std_logic;                         -- 1 MHz clock (1 us period)
  signal count : integer range 0 to 24;
begin
  -- Divide 50 MHz by 50: toggle Clk every 25 cycles of Clk50
  process (Clk50, Rst)
  begin
    if Rst = '1' then
      count <= 0;
      Clk   <= '0';
    elsif rising_edge(Clk50) then
      if count = 24 then
        count <= 0;
        Clk   <= not Clk;
      else
        count <= count + 1;
      end if;
    end if;
  end process;

  -- Moore FSM with a per-state timer
  process (Clk, Rst)
  begin
    if Rst = '1' then
      cur <= S0;
      t   <= 0;
    elsif rising_edge(Clk) then
      case cur is
        when S0 =>
          if t = 14 then cur <= S1; t <= 0; else t <= t + 1; end if;
        when S1 =>
          if t = 2  then cur <= S2; t <= 0; else t <= t + 1; end if;
        when S2 =>
          if t = 8  then cur <= S3; t <= 0; else t <= t + 1; end if;
        when S3 =>
          if t = 2  then cur <= S0; t <= 0; else t <= t + 1; end if;
      end case;
    end if;
  end process;

  Sig1 <= '0' when cur = S0 else '1';
  Sig2 <= '0' when cur = S2 else '1';
end arch;
