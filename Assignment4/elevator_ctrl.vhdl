LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.MATH_REAL.ALL;

ENTITY elevator_ctrl IS
    GENERIC (
        NUM_FLOORS : INTEGER := 10;
        CLK_FREQ   : INTEGER := 50000000  -- Clock frequency in Hz (default 50 MHz)
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
END ENTITY elevator_ctrl;

ARCHITECTURE behavior OF elevator_ctrl IS
    -- Constants
    CONSTANT MOVE_TIME       : INTEGER := CLK_FREQ * 2;  -- 2 seconds for floor transition
    
    -- Request Resolver Signals
    SIGNAL floor_requests    : STD_LOGIC_VECTOR(NUM_FLOORS-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL target_floor      : INTEGER RANGE -1 TO NUM_FLOORS-1 := -1; -- -1 means no request
    SIGNAL push_button_prev  : STD_LOGIC := '0';
    
    -- Unit Control Signals
    SIGNAL current_floor     : INTEGER RANGE 0 TO NUM_FLOORS-1 := 0;
    SIGNAL door_timer        : INTEGER RANGE 0 TO 3 := 0; -- Timer for door open duration
    SIGNAL move_timer        : INTEGER RANGE 0 TO MOVE_TIME := 0; -- Timer for 2-second floor transition
    
    TYPE state_type IS (IDLE, MOVING_UP, MOVING_DOWN, DOOR_OPENING);
    SIGNAL current_state     : state_type := IDLE;
    
BEGIN
    -- Output assignments
    curr_floor <= current_floor;
    
    -----------------------------------------------------------
    -- REQUEST RESOLVER BLOCK
    -- Manages floor request register and determines target floor
    -----------------------------------------------------------
    request_resolver: PROCESS(reset, push_button, current_state)
        VARIABLE requested_floor : INTEGER;
    BEGIN
        IF reset = '1' THEN
            floor_requests <= (OTHERS => '0');
            target_floor <= -1;
        ELSIF falling_edge(push_button) THEN
            -- Register the floor request from switch_floor
            requested_floor := TO_INTEGER(UNSIGNED(switch_floor));
            IF requested_floor < NUM_FLOORS THEN
                floor_requests(requested_floor) <= '1';
            END IF;
        END IF;
            
        -- Clear the current floor request when elevator arrives
        IF current_state = DOOR_OPENING AND current_floor = target_floor THEN
            IF target_floor >= 0 AND target_floor < NUM_FLOORS THEN
                floor_requests(target_floor) <= '0';
            END IF;
        END IF;
            
        -- Resolve next target floor
        -- Priority: closest floor in current direction, then reverse direction
        target_floor <= -1; -- Reset first
        
        -- Look for requests above current floor
        FOR i IN current_floor+1 TO NUM_FLOORS-1 LOOP
            IF floor_requests(i) = '1' THEN
                target_floor <= i;
                EXIT;
            END IF;
        END LOOP;
        
        -- If no requests above, look for requests below
        IF target_floor = -1 THEN
            FOR i IN current_floor-1 DOWNTO 0 LOOP
                IF floor_requests(i) = '1' THEN
                    target_floor <= i;
                    EXIT;
                END IF;
            END LOOP;
        END IF;
        
        -- Check current floor request
        -- IF target_floor = -1 AND floor_requests(current_floor) = '1' THEN
        --     target_floor <= current_floor;
        -- END IF;
    END PROCESS request_resolver;
    
    -----------------------------------------------------------
    -- UNIT CONTROL FSM
    -- Controls elevator movement based on target floor
    -- Each floor transition takes 2 seconds
    -----------------------------------------------------------
    unit_control: PROCESS(clk, reset)
    BEGIN
        IF reset = '1' THEN
            current_state <= IDLE;
            current_floor <= 0;
            door_timer <= 0;
            move_timer <= 0;
            mv_up <= '0';
            move_down <= '0';
            door_open <= '0';
            
        ELSIF rising_edge(clk) THEN
            CASE current_state IS
                WHEN IDLE =>
                    mv_up <= '0';
                    move_down <= '0';
                    door_open <= '0';
                    move_timer <= 0;
                    
                    -- Check if there's a valid target floor
                    IF target_floor /= -1 THEN
                        IF target_floor > current_floor THEN
                            current_state <= MOVING_UP;
                            move_timer <= 0;
                        ELSIF target_floor < current_floor THEN
                            current_state <= MOVING_DOWN;
                            move_timer <= 0;
                        ELSE -- target_floor = current_floor
                            current_state <= DOOR_OPENING;
                            door_timer <= 0;
                        END IF;
                    END IF;
                
                WHEN MOVING_UP =>
                    mv_up <= '1';
                    move_down <= '0';
                    door_open <= '0';
                    
                    -- Count 2 seconds before moving to next floor
                    IF move_timer < MOVE_TIME - 1 THEN
                        move_timer <= move_timer + 1;
                    ELSE
                        -- 2 seconds elapsed, move to next floor
                        move_timer <= 0;
                        IF current_floor < NUM_FLOORS - 1 THEN
                            current_floor <= current_floor + 1;
                        END IF;
                        
                        -- Check if reached target floor
                        IF current_floor + 1 >= target_floor THEN
                            current_state <= DOOR_OPENING;
                            door_timer <= 0;
                        END IF;
                    END IF;
                
                WHEN MOVING_DOWN =>
                    mv_up <= '0';
                    move_down <= '1';
                    door_open <= '0';
                    
                    -- Count 2 seconds before moving to next floor
                    IF move_timer < MOVE_TIME - 1 THEN
                        move_timer <= move_timer + 1;
                    ELSE
                        -- 2 seconds elapsed, move to next floor
                        move_timer <= 0;
                        IF current_floor > 0 THEN
                            current_floor <= current_floor - 1;
                        END IF;
                        
                        -- Check if reached target floor
                        IF current_floor - 1 <= target_floor THEN
                            current_state <= DOOR_OPENING;
                            door_timer <= 0;
                        END IF;
                    END IF;
                
                WHEN DOOR_OPENING =>
                    mv_up <= '0';
                    move_down <= '0';
                    door_open <= '1';
                    move_timer <= 0;
                    
                    -- Keep door open for a few clock cycles
                    IF door_timer < 2 THEN
                        door_timer <= door_timer + 1;
                    ELSE
                        -- Door closing, return to IDLE
                        current_state <= IDLE;
                        door_timer <= 0;
                    END IF;
                    
            END CASE;
        END IF;
    END PROCESS unit_control;

END ARCHITECTURE behavior;