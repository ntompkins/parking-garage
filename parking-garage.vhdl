-- Nathan Tompkins
-- Digital Electronics Final Project
-- Fall 2019

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY PARKING_GARAGE IS
	PORT (
		-- Globals
		CLK : IN std_logic;
		override : IN std_logic_vector(1 DOWNTO 0);
		override_switch : IN std_logic;
		gate : OUT std_logic;
		alarm : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		entryRamp : IN STD_LOGIC;
		exitRamp : IN std_logic;
		prk_spot : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
		reset_n : IN std_logic;
		button : IN std_logic;
		result : OUT std_logic;
		display : OUT std_logic_vector (3 DOWNTO 0);
		entryLED, exitLED : OUT std_logic;
		motor : OUT std_logic;
		buzzer : OUT std_logic;
		no_spaces : OUT std_logic;
		lower_gate : IN std_logic
	);

END PARKING_GARAGE;

ARCHITECTURE Behavioral OF PARKING_GARAGE IS
	SIGNAL CLK2 : std_logic := '0';
	SIGNAL CLK3 : std_logic := '0';
	SIGNAL alarm0Engage : std_logic_vector(8 DOWNTO 0);
	SIGNAL alarm1Engage : std_logic_vector(1 DOWNTO 0);
	CONSTANT count_max : INTEGER := 8;
	CONSTANT max_entry_time : INTEGER := 40;
	SIGNAL flipflops : STD_LOGIC_VECTOR(1 DOWNTO 0); --input flip flops
	SIGNAL counter_set : STD_LOGIC; --sync reset to zero
	SIGNAL counter : INTEGER RANGE 0 TO 9 := 9;
	SIGNAL buzzer_on : std_logic := '0';

BEGIN
	entryLED <= entryRamp;
	exitLED <= exitRamp;

	-- Buzzer frequency
	buzz_freq : PROCESS (CLK3)
	BEGIN
		buzzer <= buzzer_on;
	END PROCESS buzz_freq;

	-- Main process
	enter_exit_counter : PROCESS (CLK2)
		VARIABLE valid : BOOLEAN := true;
		VARIABLE gate_blocked : INTEGER RANGE 0 TO 30 := 0;
	BEGIN
		IF (rising_edge(CLK2)) THEN

			-- No traffic conditions
			IF (entryRamp = '0' AND exitRamp = '0') THEN
				valid := true;
				gate_blocked := 0;
				buzzer_on <= '0';
			ELSE
				-- Turn on buzzer if blocked for ~6 seconds
				IF (gate_blocked = 30) THEN
					buzzer_on <= '1';
				ELSE
					gate_blocked := gate_blocked + 1;
					buzzer_on <= '0';
				END IF;
			END IF;

			-- Manual override
			IF (override_switch = '1') THEN
				IF (lower_gate = '1') THEN
					motor <= '1';
				ELSE
					motor <= '0';
				END IF;
			END IF;

			-- Open/Close gate and turn on/off signal LED
			IF (counter = 0) THEN
				IF (override_switch = '0') THEN
					motor <= '1';
				END IF;
				no_spaces <= '1';
			ELSE
				IF (override_switch = '0') THEN
					motor <= '0';
				END IF;
				no_spaces <= '0';
			END IF;

			-- Update counter
			IF (entryRamp = '1' AND exitRamp = '0' AND counter > 0 AND valid) THEN
				counter <= counter - 1;
				valid := false;
			ELSIF (exitRamp = '1' AND entryRamp = '0' AND counter < 9 AND valid) THEN
				counter <= counter + 1;
				valid := false;
			END IF;

		END IF;
	END PROCESS;

	-- Update display
	display <= std_logic_vector(to_unsigned(counter, 4));

	counter_set <= flipflops(0) XOR flipflops(1); --determine when to start/reset counter

	-- Clock Divider --
	PROCESS (CLK) IS
	VARIABLE count : INTEGER RANGE 0 TO 800000;
	VARIABLE buzzer_count : INTEGER RANGE 0 TO 18000;
		BEGIN
			IF (rising_edge(CLK)) THEN
				-- ~450 Hz
				IF (buzzer_count < 18000) THEN
					buzzer_count := buzzer_count + 1;
				ELSE
					buzzer_count := 0;
					CLK3 <= NOT CLK3;
				END IF;

				-- 10 Hz
				IF (count < 800000) THEN
					count := count + 1;
				ELSE
					count := 0;
					CLK2 <= NOT CLK2;
				END IF;
			END IF;
		END PROCESS;

		END Behavioral;
		-----------------------

		Clock
		NET CLK LOC = P38; // IN
		NET button LOC = P143;
		NET entryRamp LOC = P119;
		NET exitRamp LOC = P142;
		NET exitLED LOC = P64;
		NET entryLED LOC = P66;
		NET buzzer LOC = P100;
		NET display(3) LOC = P10;
		NET display(2) LOC = P7;
		NET display(1) LOC = P5;
		NET display(0) LOC = P3;
		NET entryLED LOC = P66;
		NET exitLED LOC = P64;
		NET motor LOC = P117;
		NET override_switch LOC = P124;
		NET no_spaces LOC = P115;
		NET lower_gate LOC = P39;
