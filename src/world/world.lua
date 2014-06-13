---------------------------------------
-- temporary placeholders for chunk ---

local tile_width = 32
local tile_height = 16
local chunk_size = 16

-- end of placeholders ----------------
---------------------------------------


Class = require "hump.class"

World = Class {}

function World:init(name, width, height)
	self.chunks = {}
	self.name = name
	self.width = width
	self.height = height
end

function World:make_chunk()
	local chunk = {}
	local block = 0
	for y = 1, chunk_size do
		chunk[y] = {}
		for z = 1, 32 do
			chunk[y][z] = {}
			for x = 1, chunk_size do
				block = (z == 1 and 2) or (z > 14 and 3) or 1
				chunk[y][z][x] = block
			end
		end
	end
	return chunk
end

function World:generate()
	local chunks = self.chunks
	local c = self:make_chunk()
	for y = 1, self.height do
		chunks[y] = {}
		for x = 1, self.width do
			chk = Chunk(c, self)
			table.insert(chunks[y], x, chk) --inserts into chunk coord y, x with chunk newchunk
		end
	end
end

function World:rebuild()
	local chunks = self.chunks
	for y = 1, #chunks do
		for x = #chunks[y], 1, -1 do
			chunks[y][x]:rebuild()
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
			local o_x = ((x * (chunk_size*tile_width)/ 2) + (y * (chunk_size*tile_width) / 2))
			local o_y = ((y * (chunk_size*tile_height) / 2) - (x * (chunk_size*tile_height) / 2))
			chunks[y][x]:draw(o_x, o_y)
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
	
end

function World:stats()
	return #self.chunks
end