Class = require "hump.class"

World = Class {}

function World:init(name)
	self.name = name
	self.chunks = {}
end

function World:update(dt)
	local chunks = self.chunks
	for y = 1, #chunks do
		for x = 1, #chunks[y] do
			chunks[y][x]:update(dt)
		end
	end
end

function World:draw()
	local chunks = self.chunks
	for y = 1, #chunks do
		for x = 1, #chunks[y] do
			chunks[y][x]:draw(dt)
		end
	end
end

function World:block(x, y, z)
	
end

function World:chunk(x, y)
	
end

function World:stats()
	return #self.chunks
end