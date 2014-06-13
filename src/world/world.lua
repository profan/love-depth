---------------------------------------
-- temporary placeholders for chunk ---

local newchunk = { -- y, z, x stored
		{
			{2,2,2,2}, {1,1,1,1}, {1,1,1,1}, {1,1,1,1}, {1,1,1,1}, {1,1,1,1}, {1,1,1,1}, {1,1,1,1}, 
			{3,3,3,3}, {3,3,3,3}, {3,3,3,3}, {3,3,3,3}, {3,3,3,3}, {3,3,3,3}, {3,3,3,3}, {3,3,3,3},
		},
		{
			{2,2,2,2}, {1,1,1,1}, {1,1,1,1}, {1,1,1,1}, {1,1,1,1}, {1,1,1,1}, {1,1,1,1}, {1,1,1,1}, 
			{3,3,3,3}, {3,3,3,3}, {3,3,3,3}, {3,3,3,3}, {3,3,3,3}, {3,3,3,3}, {3,3,3,3}, {3,3,3,3}
		},
		{
			{2,2,2,2}, {1,1,1,1}, {1,1,1,1}, {1,1,1,1}, {1,1,1,1}, {1,1,1,1}, {1,1,1,1}, {1,1,1,1}, 
			{3,3,3,3}, {3,3,3,3}, {3,3,3,3}, {3,3,3,3}, {3,3,3,3}, {3,3,3,3}, {3,3,3,3}, {3,3,3,3} 
		},
		{
			{2,2,2,2}, {1,1,1,1}, {1,1,1,1}, {1,1,1,1}, {1,1,1,1}, {1,1,1,1}, {1,1,1,1}, {1,1,1,1}, 
			{3,3,3,3}, {3,3,3,3}, {3,3,3,3}, {3,3,3,3}, {3,3,3,3}, {3,3,3,3}, {3,3,3,3}, {3,3,3,3},
		}
}

local chunk_size = 4

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

function World:generate()
	local chunks = self.chunks
	for y = 1, self.height do
		chunks[y] = {}
		for x = 1, self.width do
			chk = Chunk(newchunk, self)
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
			local o_x = ((x * (chunk_size*32)/ 2) + (y * (chunk_size*32) / 2))
			local o_y = ((y * (chunk_size*16) / 2) - (x * (chunk_size*16) / 2))
			-- local o_x = (x * chunk_size * 32) --- (chunk_size * 32)
			-- local o_y = (y * chunk_size * 16)
			--local d_x = (x * tile_width / 2) + (y * tile_width / 2)
			--local d_y = (y * tile_height / 2) - (x * tile_height / 2)
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