library ieee;
use ieee.std_logic_1164.all;

entity tb_wave_gen is end;

architecture sim of tb_wave_gen is
  signal Clk50 : std_logic := '0';
  signal Rst   : std_logic := '1';
  signal Sig1, Sig2 : std_logic;
begin
  dut : entity work.Wave_Gen port map (Clk50 => Clk50, Rst => Rst, Sig1 => Sig1, Sig2 => Sig2);
  Clk50 <= not Clk50 after 10 ns;

  process
    variable t0, t1 : time;
  begin
    wait for 100 ns;  Rst <= '0';
    wait until falling_edge(Sig1);   t0 := now;        -- start of S0
    wait until rising_edge(Sig1);    t1 := now;
    report "Sig1 low time  = " & time'image(t1 - t0);
    assert t1 - t0 = 15 us report "FAIL: Sig1 low time" severity failure;
    wait until falling_edge(Sig2);   t0 := now;
    wait until rising_edge(Sig2);    t1 := now;
    report "Sig2 low time  = " & time'image(t1 - t0);
    assert t1 - t0 = 9 us report "FAIL: Sig2 low time" severity failure;
    report "PASS";
    std.env.stop;
  end process;
end;
