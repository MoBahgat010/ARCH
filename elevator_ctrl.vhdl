LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.MATH_REAL.ALL;

ENTITY elevator_ctrl IS
    GENERIC (
        NUM_FLOORS : INTEGER := 10;
        CLK_FREQ   : INTEGER := 50000000  -- 50 MHz
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
        ssd_out     : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)  -- seven segment display
    );
END ENTITY elevator_ctrl;

ARCHITECTURE behavior OF elevator_ctrl IS
    -- seven segment driver
    COMPONENT ssd IS
        PORT (
            hex_in  : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
            ssd_out : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
        );
    END COMPONENT;
    
    -- Constants
    CONSTANT MOVE_TIME : INTEGER := 2;
    
    -- Type declarations
    TYPE direction_type IS (DIR_UP, DIR_DOWN, DIR_NONE);
    TYPE state_type IS (IDLE, MOVING_UP, MOVING_DOWN, DOOR_OPENING);
    
    -- Clock enable signals
    SIGNAL clk_enable_1sec   : STD_LOGIC := '0';
    SIGNAL clk_counter       : INTEGER RANGE 0 TO CLK_FREQ - 1 := 0;
    SIGNAL reset_clk_counter : STD_LOGIC := '0';
    
    -- Button synchronization signals
    SIGNAL push_button_sync1 : STD_LOGIC := '1';
    SIGNAL push_button_sync2 : STD_LOGIC := '1';
    SIGNAL push_button_prev  : STD_LOGIC := '1';
    SIGNAL button_pressed    : STD_LOGIC := '0';
    
    -- Request and control signals
    SIGNAL floor_requests : STD_LOGIC_VECTOR(NUM_FLOORS-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL target_floor   : INTEGER RANGE -1 TO NUM_FLOORS-1 := -1;
    SIGNAL current_floor  : INTEGER RANGE 0 TO NUM_FLOORS-1 := 0;
    SIGNAL last_direction : direction_type := DIR_NONE;
    
    -- State machine signals
    SIGNAL current_state : state_type := IDLE;
    SIGNAL prev_state    : state_type := IDLE;
    
    -- Timers
    SIGNAL door_timer : INTEGER RANGE 0 TO MOVE_TIME := 0;
    SIGNAL move_timer : INTEGER RANGE 0 TO MOVE_TIME := 0;
    
    -- SSD conversion signal
    SIGNAL floor_bcd : STD_LOGIC_VECTOR(3 DOWNTO 0);
    
BEGIN
    -- Output assignments
    curr_floor <= current_floor;
    floor_bcd <= STD_LOGIC_VECTOR(TO_UNSIGNED(current_floor, 4));
    
    -- Seven-Segment display instantiation
    ssd_display: ssd
        PORT MAP (
            hex_in  => floor_bcd,
            ssd_out => ssd_out
        );
    
    -- Button Synchronizer: synchronize async button to clock domain
    button_sync: PROCESS(clk, reset)
    BEGIN
        IF reset = '1' THEN
            push_button_sync1 <= '1';
            push_button_sync2 <= '1';
            push_button_prev <= '1';
            button_pressed <= '0';
        ELSIF rising_edge(clk) THEN
            -- Two-stage synchronizer
            push_button_sync1 <= push_button;
            push_button_sync2 <= push_button_sync1;
            push_button_prev <= push_button_sync2;
            
            -- Detect falling edge (button press)
            IF push_button_prev = '1' AND push_button_sync2 = '0' THEN
                button_pressed <= '1';
            ELSE
                button_pressed <= '0';
            END IF;
        END IF;
    END PROCESS button_sync;
    
    -- Clock Enable Generator: 1-second pulse for timers
    clk_enable_gen: PROCESS(clk, reset)
    BEGIN
        IF reset = '1' THEN
            clk_counter <= 0;
            clk_enable_1sec <= '0';
        ELSIF rising_edge(clk) THEN
            IF reset_clk_counter = '1' OR clk_counter = CLK_FREQ - 1 THEN
                clk_counter <= 0;
                clk_enable_1sec <= '0';
            ELSE
                clk_counter <= clk_counter + 1;
                clk_enable_1sec <= '0';
            END IF;
            
            IF clk_counter = CLK_FREQ - 1 THEN
                clk_enable_1sec <= '1';
            END IF;
        END IF;
    END PROCESS clk_enable_gen;
    
    -- Request Register: handle floor button presses and clear served requests
    request_register: PROCESS(clk, reset)
        VARIABLE requested_floor : INTEGER;
    BEGIN
        IF reset = '1' THEN
            floor_requests <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            -- Register new floor request when button is pressed
            IF button_pressed = '1' THEN
                requested_floor := TO_INTEGER(UNSIGNED(switch_floor));
                IF requested_floor < NUM_FLOORS THEN
                    floor_requests(requested_floor) <= '1';
                END IF;
            END IF;
            
            -- Clear served request when door opens
            IF current_state = DOOR_OPENING AND prev_state /= DOOR_OPENING AND 
               target_floor >= 0 AND target_floor < NUM_FLOORS THEN
                floor_requests(target_floor) <= '0';
            END IF;
        END IF;
    END PROCESS request_register;
    
    -- Prioritize closest floor in current direction, then reverse
    resolve_target: PROCESS(floor_requests, current_floor, last_direction)
        VARIABLE found : BOOLEAN;
    BEGIN
        target_floor <= -1;
        found := FALSE;
        
        -- Check current floor first
        IF floor_requests(current_floor) = '1' THEN
            target_floor <= current_floor;
            found := TRUE;
        END IF;
        
        -- Search based on last direction
        IF NOT found THEN
            IF last_direction = DIR_UP OR last_direction = DIR_NONE THEN
                -- Search upward from current floor
                FOR i IN 0 TO NUM_FLOORS - 1 LOOP
                    IF i > current_floor AND floor_requests(i) = '1' THEN
                        target_floor <= i;
                        found := TRUE;
                        EXIT;
                    END IF;
                END LOOP;
                
                -- If not found, search downward
                IF NOT found THEN
                    FOR i IN NUM_FLOORS - 1 DOWNTO 0 LOOP
                        IF i < current_floor AND floor_requests(i) = '1' THEN
                            target_floor <= i;
                            found := TRUE;
                            EXIT;
                        END IF;
                    END LOOP;
                END IF;
                
            ELSIF last_direction = DIR_DOWN THEN
                -- Search downward from current floor
                FOR i IN NUM_FLOORS - 1 DOWNTO 0 LOOP
                    IF i < current_floor AND floor_requests(i) = '1' THEN
                        target_floor <= i;
                        found := TRUE;
                        EXIT;
                    END IF;
                END LOOP;
                
                -- If not found, search upward
                IF NOT found THEN
                    FOR i IN 0 TO NUM_FLOORS - 1 LOOP
                        IF i > current_floor AND floor_requests(i) = '1' THEN
                            target_floor <= i;
                            found := TRUE;
                            EXIT;
                        END IF;
                    END LOOP;
                END IF;
            END IF;
        END IF;
    END PROCESS resolve_target;
    
    -- Main elevator fsm
    unit_control: PROCESS(clk, reset)
    BEGIN
        IF reset = '1' THEN
            current_state <= IDLE;
            prev_state <= IDLE;
            current_floor <= 0;
            last_direction <= DIR_NONE;
            mv_up <= '0';
            move_down <= '0';
            door_open <= '0';
            reset_clk_counter <= '0';
            move_timer <= 0;
            door_timer <= 0;
        ELSIF rising_edge(clk) THEN
            prev_state <= current_state;
            
            CASE current_state IS
                WHEN IDLE =>
                    mv_up <= '0';
                    move_down <= '0';
                    door_open <= '0';
                    reset_clk_counter <= '0';
                    
                    IF target_floor /= -1 THEN
                        move_timer <= 0;
                        reset_clk_counter <= '1';
                        
                        IF target_floor > current_floor THEN
                            current_state <= MOVING_UP;
                            last_direction <= DIR_UP;
                        ELSIF target_floor < current_floor THEN
                            current_state <= MOVING_DOWN;
                            last_direction <= DIR_DOWN;
                        ELSE
                            current_state <= DOOR_OPENING;
                        END IF;
                    END IF;
                
                WHEN MOVING_UP =>
                    mv_up <= '1';
                    move_down <= '0';
                    door_open <= '0';
                    reset_clk_counter <= '0';
                    
                    IF clk_enable_1sec = '1' THEN
                        IF move_timer < MOVE_TIME - 1 THEN
                            move_timer <= move_timer + 1;
                        ELSE
                            move_timer <= 0;
                            IF current_floor < NUM_FLOORS - 1 THEN
                                current_floor <= current_floor + 1;
                            END IF;
                            
                            -- Check target after completing floor transition
                            IF target_floor = -1 THEN
                                current_state <= IDLE;
                            ELSIF current_floor + 1 >= target_floor THEN
                                current_state <= DOOR_OPENING;
                            END IF;
                        END IF;
                    END IF;
                
                WHEN MOVING_DOWN =>
                    mv_up <= '0';
                    move_down <= '1';
                    door_open <= '0';
                    reset_clk_counter <= '0';
                    
                    IF clk_enable_1sec = '1' THEN
                        IF move_timer < MOVE_TIME - 1 THEN
                            move_timer <= move_timer + 1;
                        ELSE
                            move_timer <= 0;
                            IF current_floor > 0 THEN
                                current_floor <= current_floor - 1;
                            END IF;
                            
                            -- Check target after completing floor transition
                            IF target_floor = -1 THEN
                                current_state <= IDLE;
                            ELSIF current_floor - 1 <= target_floor THEN
                                current_state <= DOOR_OPENING;
                            END IF;
                        END IF;
                    END IF;
                
                WHEN DOOR_OPENING =>
                    mv_up <= '0';
                    move_down <= '0';
                    door_open <= '1';
                    reset_clk_counter <= '0';
                    
                    IF clk_enable_1sec = '1' THEN
                        IF door_timer < MOVE_TIME - 1 THEN
                            door_timer <= door_timer + 1;
                        ELSE
                            current_state <= IDLE;
                            door_timer <= 0;
                        END IF;
                    END IF;
                    
            END CASE;
        END IF;
    END PROCESS unit_control;

END ARCHITECTURE behavior;