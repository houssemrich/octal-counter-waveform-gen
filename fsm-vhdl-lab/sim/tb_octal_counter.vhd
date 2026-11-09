library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_octal_counter is end;

architecture sim of tb_octal_counter is
  signal Clk   : std_logic := '0';
  signal Init  : std_logic := '0';
  signal Count : std_logic_vector(3 downto 0);
begin
  dut : entity work.Octal_Counter port map (Clk => Clk, Init => Init, Count => Count);
  Clk <= not Clk after 10 ns;

  process
  begin
    wait for 35 ns;  Init <= '1';
    wait for 32 * 20 ns;                               -- 30 bits + FSM latency
    assert unsigned(Count) = 4
      report "FAIL: expected Count = 4, got " & integer'image(to_integer(unsigned(Count)))
      severity failure;
    report "PASS: Count = " & integer'image(to_integer(unsigned(Count)));
    std.env.stop;
  end process;
end;
