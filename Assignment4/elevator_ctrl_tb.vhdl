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
            curr_floor  : OUT INTEGER RANGE 0 TO NUM_FLOORS-1;
            ssd_out     : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
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
    SIGNAL ssd_out     : STD_LOGIC_VECTOR(6 DOWNTO 0);  -- Seven-segment display output
    
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
            curr_floor  => curr_floor,
            ssd_out     => ssd_out
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
            REPORT ">>> Requesting floor " & INTEGER'IMAGE(floor_num);
            switch_floor <= STD_LOGIC_VECTOR(TO_UNSIGNED(floor_num, 4));
            WAIT FOR 50 ms;
            push_button <= '1';
            WAIT FOR 100 ms;
            push_button <= '0';
            WAIT FOR 50 ms;
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
                    -- Check if time between consecutive floors exceeds timeout
                    IF (NOW - floor_change_time) > FLOOR_TIMEOUT THEN
                        REPORT "ERROR: Floor transition took " & TIME'IMAGE(NOW - floor_change_time) 
                            SEVERITY ERROR;
                    END IF;
                    last_floor := curr_floor;
                    floor_change_time := NOW;
                END IF;
                
                -- Overall timeout check
                IF (NOW - start_time) > timeout THEN
                    REPORT "ERROR: Timeout waiting for floor " & INTEGER'IMAGE(expected_floor) & 
                           " - stuck at floor " & INTEGER'IMAGE(curr_floor)
                        SEVERITY ERROR;
                    EXIT;
                END IF;
            END LOOP;
            REPORT "<<< Reached floor " & INTEGER'IMAGE(curr_floor);
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
        REPORT "[PASS] Test Case 1 passed!";
        WAIT FOR 200 ms;
        
        -- Test Case 2: Move up from floor 0 to floor 3
        REPORT "========================================";
        REPORT "Test Case 2: Move Up (Floor 0 -> 3)";
        REPORT "========================================";
        request_floor(3);
        WAIT FOR 100 ms;
        ASSERT mv_up = '1' REPORT "mv_up should be active when moving to floor 3" SEVERITY WARNING;
        wait_for_floor(3, 10 sec);
        WAIT UNTIL door_open = '1' FOR 2 sec;
        ASSERT door_open = '1' REPORT "Door should open at floor 3" SEVERITY ERROR;
        ASSERT curr_floor = 3 REPORT "Should be at floor 3" SEVERITY ERROR;
        REPORT "[PASS] Test Case 2 passed!";
        WAIT FOR 2500 ms;  -- Wait for door to fully close (2 sec door open + margin)
        
        -- Test Case 3: Move down from floor 3 to floor 1
        REPORT "========================================";
        REPORT "Test Case 3: Move Down (Floor 3 -> 1)";
        REPORT "========================================";
        request_floor(1);
        WAIT FOR 300 ms;  -- Wait for elevator to start moving
        ASSERT move_down = '1' REPORT "move_down should be active when moving to floor 1" SEVERITY WARNING;
        wait_for_floor(1, 10 sec);
        WAIT UNTIL door_open = '1' FOR 3 sec;
        ASSERT door_open = '1' REPORT "Door should open at floor 1" SEVERITY ERROR;
        ASSERT curr_floor = 1 REPORT "Should be at floor 1" SEVERITY ERROR;
        REPORT "[PASS] Test Case 3 passed!";
        WAIT FOR 2500 ms;  -- Wait for door to close
        
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
        
        -- Expected order from floor 1: 3 (up), 5 (up), 7 (up)
        -- Wait for floor 3 (closest request)
        wait_for_floor(3, 10 sec);
        WAIT UNTIL door_open = '1' FOR 3 sec;
        ASSERT curr_floor = 3 REPORT "Should reach floor 3 first" SEVERITY ERROR;
        WAIT FOR 2500 ms;  -- Wait for door to close
        
        -- Then floor 5 (continuing upward)
        wait_for_floor(5, 10 sec);
        WAIT UNTIL door_open = '1' FOR 3 sec;
        ASSERT curr_floor = 5 REPORT "Should reach floor 5 second" SEVERITY ERROR;
        WAIT FOR 2500 ms;  -- Wait for door to close
        
        -- Then floor 7 (continuing upward)
        wait_for_floor(7, 10 sec);
        WAIT UNTIL door_open = '1' FOR 3 sec;
        ASSERT curr_floor = 7 REPORT "Should reach floor 7 last" SEVERITY ERROR;
        REPORT "[PASS] Test Case 4 passed!";
        WAIT FOR 2500 ms;  -- Wait for door to close
        
        -- Test Case 5: Request current floor
        REPORT "========================================";
        REPORT "Test Case 5: Request Current Floor";
        REPORT "========================================";
        request_floor(curr_floor);
        WAIT FOR 300 ms;  -- Wait for door to open
        ASSERT door_open = '1' REPORT "Door should open immediately at current floor" SEVERITY ERROR;
        ASSERT curr_floor = 7 REPORT "Should still be at floor 7" SEVERITY ERROR;
        REPORT "[PASS] Test Case 5 passed!";
        WAIT FOR 2500 ms;  -- Wait for door to close
        
        -- Test Case 6: Boundary test - Floor 0 (Ground)
        REPORT "========================================";
        REPORT "Test Case 6: Ground Floor Test";
        REPORT "========================================";
        request_floor(0);
        wait_for_floor(0, 20 sec);  -- Increased timeout for 7 floors
        WAIT UNTIL door_open = '1' FOR 3 sec;
        ASSERT door_open = '1' REPORT "Door should open at ground floor" SEVERITY ERROR;
        ASSERT curr_floor = 0 REPORT "Should be at ground floor (floor 0)" SEVERITY ERROR;
        REPORT "[PASS] Test Case 6 passed!";
        WAIT FOR 2500 ms;  -- Wait for door to close
        
        -- Test Case 7: Boundary test - Floor 9 (Top)
        REPORT "========================================";
        REPORT "Test Case 7: Top Floor Test";
        REPORT "========================================";
        request_floor(9);
        wait_for_floor(9, 20 sec);  -- Increased timeout for 9 floors
        WAIT UNTIL door_open = '1' FOR 3 sec;
        ASSERT door_open = '1' REPORT "Door should open at top floor" SEVERITY ERROR;
        ASSERT curr_floor = 9 REPORT "Should be at top floor (floor 9)" SEVERITY ERROR;
        REPORT "[PASS] Test Case 7 passed!";
        WAIT FOR 2500 ms;  -- Wait for door to close
        
        -- Test Case 8: Invalid floor request (floor >= NUM_FLOORS)
        REPORT "========================================";
        REPORT "Test Case 8: Invalid Floor Request";
        REPORT "========================================";
        switch_floor <= STD_LOGIC_VECTOR(TO_UNSIGNED(15, 4));
        WAIT FOR 50 ms;
        push_button <= '1';
        WAIT FOR 100 ms;
        push_button <= '0';
        WAIT FOR 1000 ms;  -- Wait to ensure elevator doesn't move
        ASSERT curr_floor = 9 REPORT "Elevator should stay at floor 9 for invalid request" SEVERITY ERROR;
        ASSERT mv_up = '0' AND move_down = '0' REPORT "Elevator should not move for invalid request" SEVERITY ERROR;
        REPORT "[PASS] Test Case 8 passed!";
        WAIT FOR 500 ms;
        
        -- Test Case 9: Dynamic Request During Movement (1->7, request 5 at floor 2, request 2 after passing)
        REPORT "========================================";
        REPORT "Test Case 9: Dynamic Mid-Journey Requests";
        REPORT "========================================";
        REPORT "Scenario: Go from 1 to 7, when reaching 2 request 5, after passing 2 request 2 again";
        
        -- First, move to floor 1 (starting position for this test)
        REPORT "Moving elevator to floor 1 (starting position)";
        request_floor(1);
        wait_for_floor(1, 20 sec);  -- Should take ~16 seconds (8 floors * 2 sec)
        WAIT UNTIL door_open = '1' FOR 2500 ms;
        ASSERT curr_floor = 1 REPORT "Should be at floor 1 to start test" SEVERITY ERROR;
        WAIT FOR 2500 ms;  -- Wait for door to close
        
        -- Request floor 7 from floor 1
        request_floor(7);
        REPORT "Requested floor 7 from floor 1";
        WAIT FOR 200 ms;
        
        -- Wait for elevator to reach floor 2
        wait_for_floor(2, 5 sec);
        REPORT "Reached floor 2 - now requesting floor 5";
        -- Request floor 5 when AT floor 2
        request_floor(5);
        WAIT FOR 100 ms;
        
        -- Wait a bit for elevator to pass floor 2 (continue moving up)
        WAIT UNTIL curr_floor /= 2 FOR 3 sec;
        REPORT "Elevator passed floor 2, now requesting floor 2 again";
        request_floor(2);
        WAIT FOR 200 ms;
        
        REPORT "Expected sequence: 2 -> 5 -> 7 -> 2 (priority: closest in direction first)";
        
        -- Should reach floor 5 next (closer in upward direction)
        wait_for_floor(5, 8 sec);
        WAIT UNTIL door_open = '1' FOR 2500 ms;
        ASSERT door_open = '1' REPORT "Door should open at floor 5" SEVERITY ERROR;
        ASSERT curr_floor = 5 REPORT "Should be at floor 5" SEVERITY ERROR;
        REPORT "Reached floor 5 (correctly prioritized upward direction)";
        WAIT FOR 2500 ms;  -- Wait for door to close
        
        -- Then floor 7 (continue upward to finish all up requests)
        wait_for_floor(7, 8 sec);
        WAIT UNTIL door_open = '1' FOR 2500 ms;
        ASSERT door_open = '1' REPORT "Door should open at floor 7" SEVERITY ERROR;
        ASSERT curr_floor = 7 REPORT "Should be at floor 7" SEVERITY ERROR;
        REPORT "Reached floor 7 (finished upward requests)";
        WAIT FOR 2500 ms;  -- Wait for door to close
        
        -- Finally floor 2 (reverse direction after no more up requests)
        wait_for_floor(2, 12 sec);
        WAIT UNTIL door_open = '1' FOR 2500 ms;
        ASSERT door_open = '1' REPORT "Door should open at floor 2 (after reversal)" SEVERITY ERROR;
        ASSERT curr_floor = 2 REPORT "Should be at floor 2" SEVERITY ERROR;
        REPORT "[PASS] Test Case 9 passed! - Correctly handled dynamic mid-journey requests";
        WAIT FOR 2500 ms;  -- Wait for door to close
        
        -- End of simulation
        REPORT "========================================";
        REPORT "All test cases completed!";
        REPORT "========================================";
        sim_done <= TRUE;
        WAIT;
    END PROCESS;
    
    -- Monitor process to display elevator status
    -- Print only on significant state changes
    monitor: PROCESS(mv_up, move_down, door_open, curr_floor)
        VARIABLE last_floor : INTEGER := 0;
        VARIABLE last_mv_up : STD_LOGIC := '0';
        VARIABLE last_mv_down : STD_LOGIC := '0';
        VARIABLE last_door : STD_LOGIC := '0';
        VARIABLE move_start_time : TIME := 0 ns;
        VARIABLE door_open_time : TIME := 0 ns;
    BEGIN
        -- Report only on actual state transitions or floor changes during movement
        IF (mv_up /= last_mv_up) OR (move_down /= last_mv_down) OR (door_open /= last_door) OR
           ((curr_floor /= last_floor) AND (mv_up = '1' OR move_down = '1')) THEN
            
            IF mv_up = '1' THEN
                -- Starting to move up
                IF last_mv_up = '0' THEN
                    move_start_time := NOW;
                    REPORT "[ELEVATOR] Moving UP - Floor " & INTEGER'IMAGE(curr_floor);
                ELSE
                    -- Floor changed during upward movement
                    REPORT "[ELEVATOR] Moving UP - Floor " & INTEGER'IMAGE(curr_floor) & 
                           " (took " & TIME'IMAGE(NOW - move_start_time) & ")";
                    move_start_time := NOW;
                END IF;
            ELSIF move_down = '1' THEN
                -- Starting to move down
                IF last_mv_down = '0' THEN
                    move_start_time := NOW;
                    REPORT "[ELEVATOR] Moving DOWN - Floor " & INTEGER'IMAGE(curr_floor);
                ELSE
                    -- Floor changed during downward movement
                    REPORT "[ELEVATOR] Moving DOWN - Floor " & INTEGER'IMAGE(curr_floor) & 
                           " (took " & TIME'IMAGE(NOW - move_start_time) & ")";
                    move_start_time := NOW;
                END IF;
            ELSIF door_open = '1' THEN
                -- Door just opened
                IF last_door = '0' THEN
                    door_open_time := NOW;
                    REPORT "[ELEVATOR] DOOR OPEN at Floor " & INTEGER'IMAGE(curr_floor);
                END IF;
            ELSIF door_open = '0' AND last_door = '1' THEN
                -- Door just closed
                REPORT "[ELEVATOR] DOOR CLOSED at Floor " & INTEGER'IMAGE(curr_floor) & 
                       " (was open for " & TIME'IMAGE(NOW - door_open_time) & ")";
            ELSIF (last_mv_up = '1' OR last_mv_down = '1' OR last_door = '1') THEN
                -- Only report IDLE if transitioning from an active state
                REPORT "[ELEVATOR] IDLE at Floor " & INTEGER'IMAGE(curr_floor);
            END IF;
            
            last_floor := curr_floor;
            last_mv_up := mv_up;
            last_mv_down := move_down;
            last_door := door_open;
        END IF;
    END PROCESS;

END ARCHITECTURE testbench;
