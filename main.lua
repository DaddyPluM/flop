local button = require "button"
require "particles"
local breezfield = require "breezfield"

local particle = {}
local buttons = {}
local objects = {}
local img = love.graphics.newImage("ball.png")
local particles = {}


mouse_x, mouse_y = love.mouse.getPosition()
win_width, win_height = love.window.getMode()

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

function love.mousepressed(x, y, button, isTouch, presses)
	for button_index in pairs(buttons) do
		buttons[button_index]:checkPressed(x, y)
	end
end

function love.keypressed(key)
	if key == "w" then
		bean:setLinearVelocity(0, -150)
	end
end

function love.load()
	timer = 0
	love.graphics.setFont(love.graphics.newFont(21))
	score = -1
	math.randomseed(os.time())
	world = breezfield.newWorld(0, 300.81, true)
	bean = world:newCollider("Rectangle", { 50, 100, 35, 10})
	--bean:setType("dynamic")
	pipes = {}
    function reset()
		particles = {}
		for i, v in pairs(pipes) do
			v:destroy()
		end
		pipes = {}
		score = -1
		bean:setPosition(50, 100)
		bean:setLinearVelocity(0, 0)
		bean:setFixedRotation(true)
		--bean:rotation(0)
		create_pipe()
    end
	function create_pipe()
		gap = math.random(30, 150)
		length = math.random(win_height/4, win_height*(3/4))
		pipe = world:newCollider("Rectangle", {win_width + 30, 0+length/2, 30, length})
		l_g = win_height - (length+gap)
		pipee = world:newCollider("Rectangle", {win_width + 30, (length + gap)+l_g/2, 30, l_g})
		pipe:setType("static")
		pipee:setType("static")
		table.insert(pipes, pipe)
		table.insert(pipes, pipee)
		score = score + 1
		return length, l_g
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
		spawn = math.random(31)
		if spawn == 13 then	
			local size = math.random(1000)/1000
			table.insert(particles, create_particle(win_width+10, win_height/2, 50+size*100, 0, 180, 1, size, size, 80, 1, false, img, 1, 0, win_height/2))
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
		world:update(dt)
		bean_x, bean_y = bean:getPosition()
		timer = timer + dt
		if timer >= 0.1 then
			table.insert(particles, create_particle(bean_x-20, bean_y, 150, 70, 180, 10, 0.5, 0, .3, 1, true, img, 1, 0, 0))
			timer = 0
		end
		
		--local colls = world:queryRectangleleArea(x, y, radius)
		for i, v in pairs(pipes) do
			local x, y = v:getPosition()
			function v:enter(other)
				if other == bean then
					end_game()
				end
			end
			if x + 15 > 0 then
				v:setPosition(x - (400 * dt), y)
			else
				v:destroy()
                pipes[i+1]:destroy()
				pipes = {}
				create_pipe()
				break
			end
		end
	end
	
	win_width, win_height = love.window.getMode()	
	mouse_x = love.mouse.getX()
	mouse_y = love.mouse.getY()	
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