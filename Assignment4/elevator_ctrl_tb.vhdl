LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.MATH_REAL.ALL;

ENTITY elevator_ctrl_tb IS
END ENTITY elevator_ctrl_tb;

ARCHITECTURE testbench OF elevator_ctrl_tb IS
    -- Component declaration
    COMPONENT elevator_ctrl IS
        GENERIC (
            NUM_FLOORS : INTEGER := 10;
            CLK_FREQ   : INTEGER := 50000000
        );
        PORT (
            reset       : IN  STD_LOGIC;
            push_button : IN  STD_LOGIC;
            switch_floor: IN  STD_LOGIC_VECTOR (INTEGER(CEIL(LOG2(REAL(NUM_FLOORS))))-1 DOWNTO 0);
            clk         : IN  STD_LOGIC;
            mv_up       : OUT STD_LOGIC;
            move_down   : OUT STD_LOGIC;
            door_open   : OUT STD_LOGIC;
            curr_floor  : OUT INTEGER RANGE 0 TO NUM_FLOORS-1
        );
    END COMPONENT;
    
    -- Test configuration - use smaller clock frequency for faster simulation
    CONSTANT NUM_FLOORS_TB : INTEGER := 10;
    CONSTANT CLK_FREQ_TB   : INTEGER := 100;  -- 100 Hz for fast simulation (2 sec = 200 clocks)
    CONSTANT CLK_PERIOD    : TIME := 10 ms;   -- 100 Hz clock
    CONSTANT FLOOR_TIME    : TIME := 2000 ms; -- Time for one floor transition (2 seconds)
    CONSTANT FLOOR_TIMEOUT : TIME := 2500 ms; -- Timeout per floor (2.5 sec with margin)
    
    -- Testbench signals
    SIGNAL reset       : STD_LOGIC := '0';
    SIGNAL push_button : STD_LOGIC := '0';
    SIGNAL switch_floor: STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL clk         : STD_LOGIC := '0';
    SIGNAL mv_up       : STD_LOGIC;
    SIGNAL move_down   : STD_LOGIC;
    SIGNAL door_open   : STD_LOGIC;
    SIGNAL curr_floor  : INTEGER RANGE 0 TO NUM_FLOORS_TB-1;
    
    -- Control signal for simulation
    SIGNAL sim_done    : BOOLEAN := FALSE;
    
BEGIN
    -- Instantiate the Unit Under Test (UUT)
    uut: elevator_ctrl
        GENERIC MAP (
            NUM_FLOORS => NUM_FLOORS_TB,
            CLK_FREQ   => CLK_FREQ_TB
        )
        PORT MAP (
            reset       => reset,
            push_button => push_button,
            switch_floor => switch_floor,
            clk         => clk,
            mv_up       => mv_up,
            move_down   => move_down,
            door_open   => door_open,
            curr_floor  => curr_floor
        );
    
    -- Clock process
    clk_process: PROCESS
    BEGIN
        WHILE NOT sim_done LOOP
            clk <= '0';
            WAIT FOR CLK_PERIOD / 2;
            clk <= '1';
            WAIT FOR CLK_PERIOD / 2;
        END LOOP;
        WAIT;
    END PROCESS;
    
    -- Stimulus process
    stimulus: PROCESS
        -- Procedure to request a floor
        PROCEDURE request_floor(floor_num : INTEGER) IS
        BEGIN
            REPORT "Requesting floor " & INTEGER'IMAGE(floor_num);
            switch_floor <= STD_LOGIC_VECTOR(TO_UNSIGNED(floor_num, 4));
            WAIT FOR 50 ms;  -- User sets switches
            push_button <= '1';
            WAIT FOR 100 ms;  -- Button pressed
            push_button <= '0';
            WAIT FOR 50 ms;  -- Button released
        END PROCEDURE;
        
        -- Procedure to wait for elevator to reach a floor
        PROCEDURE wait_for_floor(expected_floor : INTEGER; timeout : TIME) IS
            VARIABLE start_time : TIME;
            VARIABLE last_floor : INTEGER;
            VARIABLE floor_change_time : TIME;
        BEGIN
            start_time := NOW;
            last_floor := curr_floor;
            floor_change_time := NOW;
            
            WHILE curr_floor /= expected_floor LOOP
                WAIT FOR CLK_PERIOD;
                
                -- Check if floor changed
                IF curr_floor /= last_floor THEN
                    -- Check if time between consecutive floors exceeds 2 seconds + margin
                    IF (NOW - floor_change_time) > FLOOR_TIMEOUT THEN
                        REPORT "ERROR: Floor transition took " & TIME'IMAGE(NOW - floor_change_time) & 
                               " which exceeds " & TIME'IMAGE(FLOOR_TIME) & 
                               "! (Floor " & INTEGER'IMAGE(last_floor) & 
                               " -> " & INTEGER'IMAGE(curr_floor) & ")" 
                            SEVERITY ERROR;
                    ELSE
                        REPORT "Floor changed from " & INTEGER'IMAGE(last_floor) & 
                               " to " & INTEGER'IMAGE(curr_floor) & 
                               " in " & TIME'IMAGE(NOW - floor_change_time);
                    END IF;
                    last_floor := curr_floor;
                    floor_change_time := NOW;
                END IF;
                
                -- Overall timeout check
                IF (NOW - start_time) > timeout THEN
                    REPORT "Overall timeout waiting for floor " & INTEGER'IMAGE(expected_floor) & 
                           " - Currently at floor " & INTEGER'IMAGE(curr_floor)
                        SEVERITY ERROR;
                    EXIT;
                END IF;
            END LOOP;
            REPORT "Elevator reached floor " & INTEGER'IMAGE(curr_floor) & " at time " & TIME'IMAGE(NOW);
        END PROCEDURE;
        
    BEGIN
        -- Test Case 1: Reset
        REPORT "========================================";
        REPORT "Test Case 1: Reset Test";
        REPORT "========================================";
        reset <= '1';
        WAIT FOR 100 ms;
        reset <= '0';
        WAIT FOR 100 ms;
        ASSERT curr_floor = 0 REPORT "Floor should be 0 after reset" SEVERITY ERROR;
        ASSERT mv_up = '0' REPORT "mv_up should be 0 after reset" SEVERITY ERROR;
        ASSERT move_down = '0' REPORT "move_down should be 0 after reset" SEVERITY ERROR;
        REPORT "Reset test passed!";
        WAIT FOR 200 ms;
        
        -- Test Case 2: Move up from floor 0 to floor 3
        REPORT "========================================";
        REPORT "Test Case 2: Move Up (Floor 0 -> 3)";
        REPORT "========================================";
        request_floor(3);
        WAIT FOR 100 ms;
        ASSERT mv_up = '1' REPORT "mv_up should be active" SEVERITY WARNING;
        wait_for_floor(3, 10 sec);
        WAIT UNTIL door_open = '1' FOR 2 sec;
        ASSERT door_open = '1' REPORT "Door should open at floor 3" SEVERITY ERROR;
        REPORT "Test Case 2 passed!";
        WAIT FOR 500 ms;
        
        -- Test Case 3: Move down from floor 3 to floor 1
        REPORT "========================================";
        REPORT "Test Case 3: Move Down (Floor 3 -> 1)";
        REPORT "========================================";
        request_floor(1);
        WAIT FOR 100 ms;
        ASSERT move_down = '1' REPORT "move_down should be active" SEVERITY WARNING;
        wait_for_floor(1, 10 sec);
        WAIT UNTIL door_open = '1' FOR 2 sec;
        ASSERT door_open = '1' REPORT "Door should open at floor 1" SEVERITY ERROR;
        REPORT "Test Case 3 passed!";
        WAIT FOR 500 ms;
        
        -- Test Case 4: Multiple floor requests (elevator scheduling)
        REPORT "========================================";
        REPORT "Test Case 4: Multiple Requests";
        REPORT "========================================";
        request_floor(7);
        WAIT FOR 200 ms;
        request_floor(5);
        WAIT FOR 200 ms;
        request_floor(3);
        WAIT FOR 200 ms;
        
        REPORT "Waiting for elevator to service all requests...";
        -- Wait for floor 3 (closest below)
        wait_for_floor(3, 10 sec);
        WAIT UNTIL door_open = '0' FOR 2 sec;
        
        -- Then floor 5 (above)
        wait_for_floor(5, 10 sec);
        WAIT UNTIL door_open = '0' FOR 2 sec;
        
        -- Then floor 7 (above)
        wait_for_floor(7, 10 sec);
        WAIT UNTIL door_open = '1' FOR 2 sec;
        REPORT "Test Case 4 passed!";
        WAIT FOR 500 ms;
        
        -- Test Case 5: Request current floor
        REPORT "========================================";
        REPORT "Test Case 5: Request Current Floor";
        REPORT "========================================";
        REPORT "Current floor: " & INTEGER'IMAGE(curr_floor);
        request_floor(curr_floor);
        WAIT FOR 200 ms;
        ASSERT door_open = '1' REPORT "Door should open immediately" SEVERITY WARNING;
        REPORT "Test Case 5 passed!";
        WAIT FOR 500 ms;
        
        -- Test Case 6: Boundary test - Floor 0 (Ground)
        REPORT "========================================";
        REPORT "Test Case 6: Ground Floor Test";
        REPORT "========================================";
        request_floor(0);
        wait_for_floor(0, 15 sec);
        WAIT UNTIL door_open = '1' FOR 2 sec;
        ASSERT curr_floor = 0 REPORT "Should be at ground floor" SEVERITY ERROR;
        REPORT "Test Case 6 passed!";
        WAIT FOR 500 ms;
        
        -- Test Case 7: Boundary test - Floor 9 (Top)
        REPORT "========================================";
        REPORT "Test Case 7: Top Floor Test";
        REPORT "========================================";
        request_floor(9);
        wait_for_floor(9, 20 sec);
        WAIT UNTIL door_open = '1' FOR 2 sec;
        ASSERT curr_floor = 9 REPORT "Should be at top floor" SEVERITY ERROR;
        REPORT "Test Case 7 passed!";
        WAIT FOR 500 ms;
        
        -- Test Case 8: Invalid floor request (floor >= NUM_FLOORS)
        REPORT "========================================";
        REPORT "Test Case 8: Invalid Floor Request";
        REPORT "========================================";
        REPORT "Attempting to request floor 15 (invalid)...";
        switch_floor <= STD_LOGIC_VECTOR(TO_UNSIGNED(15, 4));
        WAIT FOR 50 ms;
        push_button <= '1';
        WAIT FOR 100 ms;
        push_button <= '0';
        WAIT FOR 500 ms;
        ASSERT curr_floor = 9 REPORT "Elevator should stay at floor 9" SEVERITY WARNING;
        REPORT "Test Case 8 passed!";
        WAIT FOR 500 ms;
        
        -- End of simulation
        REPORT "========================================";
        REPORT "All test cases completed!";
        REPORT "========================================";
        sim_done <= TRUE;
        WAIT;
    END PROCESS;
    
    -- Monitor process to display elevator status
    -- I want to print only when there is a change in state not on clk
    monitor: PROCESS(mv_up, move_down, door_open, curr_floor)
    BEGIN
        IF mv_up = '1' THEN
            REPORT "Status: Moving UP - Current Floor: " & INTEGER'IMAGE(curr_floor);
            ELSIF move_down = '1' THEN
                REPORT "Status: Moving DOWN - Current Floor: " & INTEGER'IMAGE(curr_floor);
            ELSIF door_open = '1' THEN
                REPORT "Status: DOOR OPEN at Floor: " & INTEGER'IMAGE(curr_floor);
        END IF;
    END PROCESS;

END ARCHITECTURE testbench;
