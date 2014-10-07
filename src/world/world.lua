---------------------------------------
-- temporary placeholders for chunk ---

local function istable(t) return type(t) == 'table' end

-- end of placeholders ----------------
---------------------------------------

lovenoise = require "lovenoise.lovenoise"

local World = Class {}

World.tile_width = 32
World.tile_height = 16
World.chunk_size = 32
World.chunk_height = 128

function World:init(name, width, height)
	self.chunks = {}
	self.name = name
	self.width = width
	self.height = height
	self.noise = self:make_noise()
	self.cnoise = self:cave_noise()
	
	-- stats
	self.total_blocks = 0
	self.total_chunks = 0
	self.active_blocks = 0
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

function World:cave_noise()
	local test_noise = lovenoise.newNoise(
                           {"fractal", 200, {6, 0.7, 0.8}},
                           {"simplex", 64}
                       )
	--testNoise:setthreshold(0.2):setseed(1337)
	test_noise:setseed(3200)
	return test_noise
end

function World:make_whole_chunk(cx, cy)
	local chunk = {}
	heights = self:make_chunk(chunk, cx, cy)
	self:make_caves(chunk, heights, cx, cy)
	return chunk
end

function World:make_chunk(c, cx, cy)
	local noise = self.noise
	local chunk = c
	local block = 0
	local top, topdrawn
	local ceil = math.ceil
	
	local heights = {}
	for y = 1, World.chunk_size  do
		chunk[y] = {}
		for z = 1, World.chunk_height do
			chunk[y][z] = {}
			for x = 1, World.chunk_size do
				top = ceil(32 * noise:eval((cx*World.chunk_size) + x, (cy*World.chunk_size) + y))
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
	return heights
end

function World:make_caves(c, h, cx, cy)
	local noise = self.cnoise
	local chunk = c
	local heights = h
	local block
	for y = 1, World.chunk_size  do
		for z = 1, World.chunk_height do
			for x = 1, World.chunk_size do	
				value = noise:eval((cx*World.chunk_size) + x, (cy*World.chunk_size) + y, z)
				block = (value > 0.4 and z > 14 and 0)
				if block == 0 and z > heights[x] then
					chunk[y][z][x] = block
					self.total_blocks = self.total_blocks - 1
					block = -1
				end
			end
		end
	end
end

function World:make_rivers(c, cx, cy)

end

function World:make_sea(c, cx, cy)
	for y = 1, World.chunk_size  do
		for z = 1, World.chunk_height do
			for x = 1, World.chunk_size do
				if z < 64 and z > 15 and c[y][z][x] == 0 then
					c[y][z][x] = 5
				end
			end
		end
	end
end

function World:generate()
	local c
	local chunks = self.chunks
	local stime = love.timer.getTime()
	for y = 1, self.height do
		chunks[y] = {}
		for x = 1, self.width do
			c = self:make_whole_chunk(x, y)
			chk = Chunk(c)
			chunks[y][x] = chk
			self.total_chunks = self.total_chunks + 1
			self.total_blocks = self.total_blocks + 32768
			self.active_blocks = self.total_blocks
		end
	end
	local time_taken = love.timer.getTime() - stime
	local total_chunks = self.height*self.width
	print("It took: " .. time_taken .. " seconds to build " .. total_chunks .. " chunks.")
	print(" - Seconds per chunk: " .. time_taken/total_chunks)
end

function World:rebuild_chunk(chunk, x, y, zoom)
	local o_x = ((x * (World.chunk_size*World.tile_width)/ 2) + (y * (World.chunk_size*World.tile_width) / 2))
	local o_y = ((y * (World.chunk_size*World.tile_height) / 2) - (x * (World.chunk_size*World.tile_height) / 2))
	return chunk:rebuild(zoom, o_x, o_y)
end

function World:rebuild(zoom)
	-- memory
	last_zoom = last_zoom or zoom

	-- reset stats
	self.active_blocks = 0
	self.total_blocks = 0
	
	-- local vars
	local chunk
	local total_built = 0
	local chunks = self.chunks
	local stime = love.timer.getTime()
	local batchtime = 0
	for y = 1, #chunks do
		for x = #chunks[y], 1, -1 do
			chunk = chunks[y][x]
			if chunk.dirty or last_zoom ~= zoom then
				batchtime  = batchtime + self:rebuild_chunk(chunk, x, y, zoom)
				total_built = total_built + 1
			end
			self.active_blocks = self.active_blocks + chunk.active_blocks
			self.total_blocks = self.total_blocks + chunk.total_blocks
		end
	end
	local time_taken = love.timer.getTime() - stime
	print("It took: " .. time_taken .. " seconds to rebuild " .. total_built .. " chunks spritebatches.")
	print("SpriteBatch time: " .. (batchtime/time_taken)*100 .. "%")
	print(" - seconds per chunk: " .. time_taken/total_built)
	
	--memory
	last_zoom = zoom
	
	--update global
	rebuild_time = time_taken
end

function World:update(dt)
	local chunks = self.chunks
	for y = 1, #chunks do
		for x = 1, #chunks[y] do
			chunks[y][x]:update(dt)
		end
	end
end

function World:draw(z)
	local lg = love.graphics
	lg.push()
	lg.translate(0, -16*z)
	local chunks = self.chunks
	for y = 1, #chunks do
		for x = #chunks[y], 1, -1 do
			chunks[y][x]:draw()
		end
	end
	lg.pop()
end

function World:block(x, y, z)
	local c_x = math.floor(x / World.chunk_size)+1
	local c_y = math.floor(y / World.chunk_size)+1
	local o_x = (x % World.chunk_size)+1
	local o_y = (y % World.chunk_size)+1
	return self.chunks[c_y][c_x].blocks[o_y][z][o_x]
end

function World:set_block(x, y, z, v)
	local c_x = math.floor(x / World.chunk_size)+1
	local c_y = math.floor(y / World.chunk_size)+1
	local o_x = (x % World.chunk_size)+1
	local o_y = (y % World.chunk_size)+1
	self.chunks[c_y][c_x].blocks[o_y][z][o_x] = v
	self.chunks[c_y][c_x].dirty = true
end

function World:chunk(x, y)
	return self.chunks[y][x]
end

function World:stats()
	return self.total_chunks, self.total_blocks, self.active_blocks
end

return World
