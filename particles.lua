function create_particle(x, y, speed, spread, direction, number, size1, size2, lifetime, alpha, fade, image, variation, area_x, area_y)
	local timer = 0
    local particle = love.graphics.newParticleSystem(image, 32)
	return{
	x = x,
	y = y,
	speed = speed,
	size1 = size1,
	size2 = size2 or size1,
	lifetime = lifetime,
	image = image,
	finished = false,
	fade = fade,
	direction = direction,
    alpha = alpha or 1,
	area_x = area_x or 0,
	area_y = area_y or 0,
	variation = variation or 0,
    particle:setParticleLifetime(lifetime),
    particle:setSpeed(speed),
    particle:setSizes(size1, size2),
    particle:setSpread(spread/60),
    particle:setEmissionArea("uniform", area_x, area_y),
    particle:setPosition(x, y),
    particle:setSizeVariation(variation),
    particle:setDirection(direction * (math.pi / 180)),
    particle:emit(number),
	
	update = function(self, dt)		--Update particles
		particle:update(dt)
	--print(win_width / speed)
		timer = timer + dt
		if timer >= self.lifetime then
			self.finished = true
		end
		if fade == true then	--Fade out particles as they get closer to the end of their lifetime
			self.alpha = 1 - (timer/self.lifetime)
		end
	end,
	
	draw = function(self)
		particle:setColors(1, 1, 1, self.alpha)		--Draw the particles with an alpha value that can be modified
		love.graphics.draw(particle)
	end,
	
	getPosition = function(self)
		return particle:getPosition()		--Return emitter position
	end,
	
	kill = function(self)
		particle:release()
		self.finished = true
		self.lifetime = 0
	end,
	}
end