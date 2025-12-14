local button = require "button"
require "particles"
local breezfield = require "breezfield"

local particle = {}
local buttons = {}
local objects = {}
local img = love.graphics.newImage("ball.png")
local particles = {}


--mouse_x, mouse_y = love.mouse.getPosition()     -- Get mouse x and y position
win_width, win_height = love.window.getMode()	-- Get window width and height

local game_state = { -- The different states of the game
    menu = true,    --When the player opens the game, it will show the menu by default
    game = false,
    pause = false,
    over = false,
}

local function start_game()  --Begins the game
    if game_state["over"] then
        reset()
    end
    game_state["menu"] = false
    game_state["game"] = true
    game_state["pause"] = false
    game_state["over"] = false
end

local function start_menu()  --Opens the main menu
    reset()
    if game_state["over"] then
        reset()
    end
    game_state["menu"] = true
    game_state["game"] = false
    game_state["pause"] = false
    game_state["over"] = false
end

local function pause_game()  --Pauses the game
    game_state["menu"] = false
    game_state["game"] = false
    game_state["pause"] = true
    game_state["over"] = false
end

local function end_game()    -- Ends the game (Game Over)
    game_state["menu"] = false
    game_state["game"] = false
    game_state["pause"] = false
    game_state["over"] = true
end

function love.mousepressed(x, y, button, isTouch, presses)	-- Check which button is currently being pressed
	for button_index in pairs(buttons) do
		buttons[button_index]:checkPressed(x, y)
	end
end

function love.keypressed(key)	-- Keyboard input handling
	if key == "w" then
		bean:setLinearVelocity(0, -150)
	end
end

function love.load()
	timer = 0
	love.graphics.setFont(love.graphics.newFont(21))	-- Set font size to 21
	score = -1
	math.randomseed(os.time())	-- Set seed for randomisation to system time
	world = breezfield.newWorld(0, 300.81, true)    -- Create new physics world
	bean = world:newCollider("Rectangle", { 50, 100, 35, 10})   -- Create player
	--bean:setType("dynamic")
	pipes = {}
    function reset()    -- Reset some game variables
		particles = {}
		for i, v in pairs(pipes) do
			v:destroy()     -- Destroy all pipes
		end
		pipes = {}
		score = -1
		bean:setPosition(50, 100)
		bean:setLinearVelocity(0, 0)
		bean:setFixedRotation(true)
		--bean:rotation(0)
		create_pipe()
    end
	function create_pipe()  -- Funtion for creating pipe
		gap = math.random(30, 150)  -- Random gap
		length = math.random(win_height/4, win_height*(3/4))    -- Random length of top pipe
		pipe = world:newCollider("Rectangle", {win_width + 30, 0+length/2, 30, length})     -- Create pipe using length
		l_g = win_height - (length+gap)     -- Determine the poiie second pipe by subtractiing the length of the first pipe + gap from window height
		pipee = world:newCollider("Rectangle", {win_width + 30, (length + gap)+l_g/2, 30, l_g})     -- Create 2nd pipe below first pipe with a distance between them being the gap
		pipe:setType("static")
		pipee:setType("static")
		table.insert(pipes, pipe)
		table.insert(pipes, pipee)
		score = score + 1   -- Increase score
		--return length, l_g
	end
    --reset()
	create_pipe()
	buttons.quit = button("Quit", love.event.quit, nil, 100, 20)
	buttons.restart = button("Reastart", start_game, nil, 100, 20)
	buttons.play = button("Play", start_game, nil, 100, 20)
end

function love.update(dt)
	frame = 1/dt
	if game_state["game"] then
		spawn = math.random(15)		-- Generate randome number from 0 to 31 every frame
		if spawn == 13 then	-- If number is 13
			local size = math.random(1000)/1000
			local speed = (size * 400)	-- Generate random speed based on size (bigger = faster)
            table.insert(particles, create_particle(win_width+10, win_height/2, speed, 0, 180, 1, size, size, (win_width+10) / speed, 1, false, img, 1, 0, win_height/2))		-- Create particles to create the illusion of motion using parallax
		end
		if #particles > 0 then      --If there are particles present in-game
			for i, v in pairs(particles) do
				x, y = v:getPosition()
				
				if v.finished == true then      --If particle emiters have exceeded their lifetime
					table.remove(particles, i)    --Remove particle emitters that have exceeded their lifetime
				end
				v:update(dt)    --Update particles
				--print(x, #particles)
			end
		end
		world:update(dt)    -- Update physics world
		bean_x, bean_y = bean:getPosition()
		timer = timer + dt
		if timer >= 0.15 then
			table.insert(particles, create_particle(bean_x-20, bean_y, 150, 70, 180, 10, 0.5, 0, .3, 1, true, img, 1, 0, 0))    -- Spawn particles at the end of the player to create the illusion of motion
			timer = 0
		end
		
		--local colls = world:queryRectangleleArea(x, y, radius)
        if (#pipes >0) then
            for i, v in pairs(pipes) do
                local x, y = v:getPosition()
                function v:enter(other)     -- If player collides with pipe
                    if other == bean then
                        end_game()
                    end
                end
                if x + 15 > 0 then      -- If pipe has  not reached the left side of the screen
                    v:setPosition(x - (400 * dt), y)    -- Move towards the left side of the screen
                else    -- If pipe has reached the left side of the screen
                    v:destroy()     -- Destroy top pipe
                    pipes[i+1]:destroy()   -- Destroy bottom pipe
                    pipes = {}  -- Wipe the table used to keep track of the pipes
                    create_pipe()   -- Create new pipes
                    break
                end
            end
        end
	end
	
	--win_width, win_height = love.window.getMode()	
	--mouse_x, mouse_y = love.mouse.getPosition()     -- Update mouse position
end

function love.draw()
	--love.graphics.print(world.getBodyCount())
	if game_state["game"] then
        if #particles > 0 then  --If there are particles present in-game
            for i, v in pairs(particles) do
                v:draw()    --Draw particles
            end
        end
		love.graphics.printf(score, 0, 0, win_width, "center")
		world:draw()
        
	elseif game_state["over"] then
		--world:destroy()
		love.graphics.printf("FinalScore", 0, win_height/2 - 50, win_width, "center")
		love.graphics.printf(score, 0, win_height/2, win_width, "center")
		buttons.quit:draw(win_width/2 - buttons.quit:get_width()/2, win_height/2 + 50 - buttons.quit:get_height()/2)
		buttons.restart:draw(win_width/2 - buttons.restart:get_width()/2, win_height/2 + 100 - buttons.restart:get_height()/2)
        
	elseif game_state["menu"] then
		buttons.play:draw(win_width/2 - buttons.play:get_width()/2, win_height/2 + 50 - buttons.play:get_height()/2)
        
	end
end