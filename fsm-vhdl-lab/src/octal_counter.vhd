-- Octal digit counter: PISO shift register + Moore FSM + mod-16 counter.
-- Counts how many octal digits of the 30-bit word W equal 3 (011).
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Octal_Counter is
  port (
    Clk, Init : in  std_logic;                      -- Init is active-low
    Count     : out std_logic_vector(3 downto 0)
  );
end Octal_Counter;

architecture arch of Octal_Counter is
  type state_type is (A, B, C, D, E, F);
  signal cur : state_type;
  signal R   : std_logic_vector(29 downto 0);       -- PISO shift register
  signal y   : std_logic;                           -- serial bit (MSB first)
  signal z   : std_logic;                           -- Moore output: digit 3 detected
  signal cnt : unsigned(3 downto 0);
  -- 10 octal digits: 3 7 3 0 5 3 6 7 2 3
  signal W   : std_logic_vector(29 downto 0) := "011111011000101011110111010011";
begin
  -- Parallel load on Init = '0', then shift left one bit per clock
  process (Clk)
  begin
    if rising_edge(Clk) then
      if Init = '0' then
        R <= W;
      else
        R <= R(28 downto 0) & '0';
      end if;
    end if;
  end process;
  y <= R(29);

  -- Moore FSM, aligned on 3-bit digit boundaries (A and D are digit-start states)
  process (Init, Clk)
  begin
    if Init = '0' then
      cur <= A;
    elsif rising_edge(Clk) then
      case cur is
        when A | D =>
          if y = '0' then cur <= B; else cur <= E; end if;
        when B =>
          if y = '1' then cur <= C; else cur <= F; end if;
        when C =>
          if y = '1' then cur <= D; else cur <= A; end if;   -- "011" -> D
        when E =>
          cur <= F;
        when F =>
          cur <= A;
      end case;
    end if;
  end process;
  z <= '1' when cur = D else '0';

  -- Mod-16 up counter
  process (Init, Clk)
  begin
    if Init = '0' then
      cnt <= (others => '0');
    elsif rising_edge(Clk) then
      if z = '1' then
        cnt <= cnt + 1;
      end if;
    end if;
  end process;
  Count <= std_logic_vector(cnt);
end arch;
