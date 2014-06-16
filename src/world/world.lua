---------------------------------------
-- temporary placeholders for chunk ---

local function istable(t) return type(t) == 'table' end

local tile_width = 32
local tile_height = 16
local chunk_size = 32

-- end of placeholders ----------------
---------------------------------------

Class = require "hump.class"
lovenoise = require "lovenoise"

local World = Class {}

function World:init(name, width, height)
	self.chunks = {}
	self.name = name
	self.width = width
	self.height = height
	self.noise = self:make_noise()
	
	-- stats
	self.total_blocks = 0
	self.total_chunks = 0
	self.total_active = 0
end

function World:make_noise()
	local test_noise = lovenoise.newNoise(
                           {"fractal", 100, {6, 0.7, 1.4}},
                           {"simplex", 128}
                       )
	--testNoise:setthreshold(0.2):setseed(1337)
	test_noise:setseed(1337)
	return test_noise
end

function World:make_chunk(cx, cy)
	local noise = self.noise
	local chunk = {}
	local block = 0
	local top, topdrawn
	local ceil = math.ceil
	
	local heights = {}
	for y = 1, chunk_size  do
		chunk[y] = {}
		for z = 1, 64 do
			chunk[y][z] = {}
			for x = 1, chunk_size do
				top = ceil(64.0 * noise:eval((cx*chunk_size) + x, (cy*chunk_size) + y))
				--print("Z: " .. top)
				
				if heights[x] ~= nil and heights[x] < z then
					block = (z == top and 2) or (z > heights[x]+14 and 3) or 1
				else
					block = 0
				end
				
				if z == top then
					block = 2
					heights[x] = top
				end
				--block = (z == 1 and 2) or (z > 14 and 3) or 1
				chunk[y][z][x] = block
			end
		end
	end
	return chunk
end

function World:generate()
	local c
	local chunks = self.chunks
	local stime = love.timer.getTime()
	for y = 1, self.height do
		chunks[y] = {}
		for x = 1, self.width do
			c = self:make_chunk(x, y)
			chk = Chunk(c, self)
			chunks[y][x] = chk
			self.total_chunks = self.total_chunks + 1
			self.total_blocks = self.total_blocks + 32768
			self.total_active = self.total_blocks
		end
	end
	local time_taken = love.timer.getTime() - stime
	local total_chunks = self.height*self.width
	print("It took: " .. time_taken .. " seconds to build " .. total_chunks .. " chunks.")
	print(" - Seconds per chunk: " .. time_taken/total_chunks)
end

function World:rebuild_chunk(x, y)
	local o_x = ((x * (chunk_size*tile_width)/ 2) + (y * (chunk_size*tile_width) / 2))
	local o_y = ((y * (chunk_size*tile_height) / 2) - (x * (chunk_size*tile_height) / 2))
	self.chunks[y][x]:rebuild(o_x, o_y)
end

function World:rebuild()
	local total_built = 0
	local chunks = self.chunks
	local stime = love.timer.getTime()
	for y = 1, #chunks do
		for x = #chunks[y], 1, -1 do
			if chunks[y][x].dirty then
				self:rebuild_chunk(x, y)
				total_built = total_built + 1
			end
		end
	end
	local time_taken = love.timer.getTime() - stime
	print("It took: " .. time_taken .. " seconds to rebuild " .. total_built .. " chunks spritebatches.")
	print(" - Seconds per chunk: " .. time_taken/total_built)
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
		for x = #chunks[y], 1, -1 do
			chunks[y][x]:draw()
			
		end
	end
end

function World:block(x, y, z)
	local c_x = math.floor(x / chunk_size)+1
	local c_y = math.floor(y / chunk_size)+1
	local o_x = (x % chunk_size)+1
	local o_y = (y % chunk_size)+1
	return self.chunks[c_y][c_x].blocks[o_y][z][o_x]
end

function World:set_block(x, y, z, v)
	local c_x = math.floor(x / chunk_size)+1
	local c_y = math.floor(y / chunk_size)+1
	local o_x = (x % chunk_size)+1
	local o_y = (y % chunk_size)+1
	self.chunks[c_y][c_x].blocks[o_y][z][o_x] = v
	self.chunks[c_y][c_x].dirty = true
end

function World:chunk(x, y)
	return self.chunks[y][x]
end

function World:stats()
	return self.total_chunks, self.total_blocks, self.total_active
end

return World