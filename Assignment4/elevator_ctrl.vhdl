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
    CONSTANT DOOR_TIME       : INTEGER := CLK_FREQ * 2;  -- 2 seconds for door open duration
    
    -- Request Resolver Signals
    SIGNAL floor_requests    : STD_LOGIC_VECTOR(NUM_FLOORS-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL target_floor      : INTEGER RANGE -1 TO NUM_FLOORS-1 := -1; -- -1 means no request
    SIGNAL push_button_prev  : STD_LOGIC := '0';
    
    -- Unit Control Signals
    SIGNAL current_floor     : INTEGER RANGE 0 TO NUM_FLOORS-1 := 0;
    SIGNAL door_timer        : INTEGER RANGE 0 TO DOOR_TIME := 0; -- Timer for door open duration
    SIGNAL move_timer        : INTEGER RANGE 0 TO MOVE_TIME := 0; -- Timer for 2-second floor transition
    
    TYPE state_type IS (IDLE, MOVING_UP, MOVING_DOWN, DOOR_OPENING);
    SIGNAL current_state     : state_type := IDLE;
    
BEGIN
    -- Output assignments
    curr_floor <= current_floor;
    
    -----------------------------------------------------------
    -- REQUEST RESOLVER BLOCK
    -- Manages floor request register and determines target floor
    -- Direction priority: continue in current direction until no more requests
    -- This block is ASYNCHRONOUS - responds immediately to changes
    -----------------------------------------------------------
    request_resolver: PROCESS(floor_requests, current_state, current_floor, target_floor)
        VARIABLE next_target : INTEGER;
    BEGIN
        -- Resolve next target floor based on current state and direction
        next_target := -1;
        
        CASE current_state IS
            WHEN IDLE =>
                -- When idle, check upward first, then downward
                FOR i IN current_floor+1 TO NUM_FLOORS-1 LOOP
                    IF floor_requests(i) = '1' THEN
                        next_target := i;
                        EXIT;
                    END IF;
                END LOOP;
                
                IF next_target = -1 THEN
                    FOR i IN current_floor-1 DOWNTO 0 LOOP
                        IF floor_requests(i) = '1' THEN
                            next_target := i;
                            EXIT;
                        END IF;
                    END LOOP;
                END IF;
                
                -- Check current floor
                IF next_target = -1 AND floor_requests(current_floor) = '1' THEN
                    next_target := current_floor;
                END IF;
            
            WHEN MOVING_UP =>
                -- Check current floor FIRST if there's a request (stop here)
                IF floor_requests(current_floor) = '1' THEN
                    next_target := current_floor;
                ELSE
                    -- Continue upward if there are requests above
                    FOR i IN current_floor+1 TO NUM_FLOORS-1 LOOP
                        IF floor_requests(i) = '1' THEN
                            next_target := i;
                            EXIT;
                        END IF;
                    END LOOP;
                    
                    -- Only reverse if no requests above
                    IF next_target = -1 THEN
                        FOR i IN current_floor-1 DOWNTO 0 LOOP
                            IF floor_requests(i) = '1' THEN
                                next_target := i;
                                EXIT;
                            END IF;
                        END LOOP;
                    END IF;
                END IF;
            
            WHEN MOVING_DOWN =>
                -- Check current floor FIRST if there's a request (stop here)
                IF floor_requests(current_floor) = '1' THEN
                    next_target := current_floor;
                ELSE
                    -- Continue downward if there are requests below
                    FOR i IN current_floor-1 DOWNTO 0 LOOP
                        IF floor_requests(i) = '1' THEN
                            next_target := i;
                            EXIT;
                        END IF;
                    END LOOP;
                    
                    -- Only reverse if no requests below
                    IF next_target = -1 THEN
                        FOR i IN current_floor+1 TO NUM_FLOORS-1 LOOP
                            IF floor_requests(i) = '1' THEN
                                next_target := i;
                                EXIT;
                            END IF;
                        END LOOP;
                    END IF;
                END IF;
            
            WHEN DOOR_OPENING =>
                -- When door is opening, check in the previous direction first
                IF target_floor > current_floor THEN
                    -- Was moving up, continue upward
                    FOR i IN current_floor+1 TO NUM_FLOORS-1 LOOP
                        IF floor_requests(i) = '1' THEN
                            next_target := i;
                            EXIT;
                        END IF;
                    END LOOP;
                    
                    IF next_target = -1 THEN
                        FOR i IN current_floor-1 DOWNTO 0 LOOP
                            IF floor_requests(i) = '1' THEN
                                next_target := i;
                                EXIT;
                            END IF;
                        END LOOP;
                    END IF;
                    
                ELSIF target_floor < current_floor THEN
                    -- Was moving down, continue downward
                    FOR i IN current_floor-1 DOWNTO 0 LOOP
                        IF floor_requests(i) = '1' THEN
                            next_target := i;
                            EXIT;
                        END IF;
                    END LOOP;
                    
                    IF next_target = -1 THEN
                        FOR i IN current_floor+1 TO NUM_FLOORS-1 LOOP
                            IF floor_requests(i) = '1' THEN
                                next_target := i;
                                EXIT;
                            END IF;
                        END LOOP;
                    END IF;
                    
                ELSE
                    -- Was at same floor (idle case), check both directions
                    FOR i IN current_floor+1 TO NUM_FLOORS-1 LOOP
                        IF floor_requests(i) = '1' THEN
                            next_target := i;
                            EXIT;
                        END IF;
                    END LOOP;
                    
                    IF next_target = -1 THEN
                        FOR i IN current_floor-1 DOWNTO 0 LOOP
                            IF floor_requests(i) = '1' THEN
                                next_target := i;
                                EXIT;
                            END IF;
                        END LOOP;
                    END IF;
                END IF;
                
                -- Check current floor
                IF next_target = -1 AND floor_requests(current_floor) = '1' THEN
                    next_target := current_floor;
                END IF;
        END CASE;
        
        target_floor <= next_target;
    END PROCESS request_resolver;
    
    -----------------------------------------------------------
    -- FLOOR REQUEST REGISTER
    -- Synchronous process to register floor requests and clear served floors
    -----------------------------------------------------------
    request_register: PROCESS(clk, reset)
        VARIABLE requested_floor : INTEGER;
    BEGIN
        IF reset = '1' THEN
            floor_requests   <= (OTHERS => '0');
            push_button_prev <= '0';
            
        ELSIF rising_edge(clk) THEN
            -- Register new floor request on push button rising edge
            IF push_button = '1' AND push_button_prev = '0' THEN
                requested_floor := TO_INTEGER(UNSIGNED(switch_floor));
                IF requested_floor >= 0 AND requested_floor < NUM_FLOORS THEN
                    floor_requests(requested_floor) <= '1';
                END IF;
            END IF;
            push_button_prev <= push_button;
            
            -- Clear the current floor request when elevator arrives and door opens
            IF current_state = DOOR_OPENING THEN
                IF current_floor >= 0 AND current_floor < NUM_FLOORS THEN
                    floor_requests(current_floor) <= '0';
                END IF;
            END IF;
        END IF;
    END PROCESS request_register;
    
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
                            
                            -- Check if we've reached target floor (check AFTER incrementing)
                            IF current_floor + 1 = target_floor THEN
                                current_state <= DOOR_OPENING;
                                door_timer <= 0;
                            END IF;
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
                            
                            -- Check if we've reached target floor (check AFTER decrementing)
                            IF current_floor - 1 = target_floor THEN
                                current_state <= DOOR_OPENING;
                                door_timer <= 0;
                            END IF;
                        END IF;
                    END IF;
                
                WHEN DOOR_OPENING =>
                    mv_up <= '0';
                    move_down <= '0';
                    door_open <= '1';
                    move_timer <= 0;
                    
                    -- Keep door open for 2 seconds
                    IF door_timer < DOOR_TIME - 1 THEN
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