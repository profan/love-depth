---------------------------------------
-- temporary placeholders for chunk ---

local tile_width = 32
local tile_height = 16
local chunk_size = 32

-- end of placeholders ----------------
---------------------------------------

Class = require "hump.class"
lovenoise = require "lovenoise"

World = Class {}

function World:init(name, width, height)
	self.chunks = {}
	self.name = name
	self.width = width
	self.height = height
	
	-- stats
	self.total_blocks = 0
	self.total_chunks = 0
	self.total_active = 0
end

function World:make_noise()
	local testNoise = lovenoise.newNoise(
                           {"fractal", 100, {6, 0.7, 1.4}},
                           {"simplex", 128}
                       )
	--testNoise:setthreshold(0.2):setseed(1337)
	testNoise:setseed(1337)
	return testNoise
end

function World:make_chunk(cx, cy)
	local noise = self:make_noise()
	local chunk = {}
	local block = 0
	local top
	for y = 1, chunk_size do
		chunk[y] = {}
		for z = 1, 64 do
			chunk[y][z] = {}
			for x = 1, chunk_size do
				lastz = lastz or 0
				topdrawn = topdrawn or false
				if z ~= lastz then
					top = math.floor(64.0 * noise:eval((cx*chunk_size) + x, (cy*chunk_size) + y))
					print("Z: " .. top)
					topdrawn = false
				end
				block = (z == top and 2) or (z > 14 and 3 and topdrawn) or (z < top and 1 and topdrawn) or 0
				if z == top then
					topdrawn = true
				end
				--block = (z == 1 and 2) or (z > 14 and 3) or 1
				chunk[y][z][x] = block
			end
		end
	end
	return chunk
end

function World:generate()
	local chunks = self.chunks
	local c
	for y = 1, self.height do
		chunks[y] = {}
		for x = 1, self.width do
			c = self:make_chunk(x, y)
			chk = Chunk(c, self)
			table.insert(chunks[y], x, chk) --inserts into chunk coord y, x with chunk newchunk
			self.total_chunks = self.total_chunks + 1
			self.total_blocks = self.total_blocks + 32768
			self.total_active = self.total_blocks
		end
	end
end

function World:rebuild()
	local chunks = self.chunks
	for y = 1, #chunks do
		for x = #chunks[y], 1, -1 do
			local o_x = ((x * (chunk_size*tile_width)/ 2) + (y * (chunk_size*tile_width) / 2))
			local o_y = ((y * (chunk_size*tile_height) / 2) - (x * (chunk_size*tile_height) / 2))
			chunks[y][x]:rebuild(o_x, o_y)
		end
	end
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
	local c_x = math.floor(x / chunk_size)
	local c_y = math.floor(y / chunk_size)
	local o_x = x % chunk_size
	local o_y = y % chunk_size
	return self.chunks[c_y][c_x].blocks[o_y][z][o_x]
end

function World:chunk(x, y)
	return self.chunks[y][x]
end

function World:stats()
	return self.total_chunks, self.total_blocks, self.total_active
end