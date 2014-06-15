---------------------------------------
-- temporary placeholders for chunk ---

local tile_width = 32
local tile_height = 16
local chunk_size = 32

-- end of placeholders ----------------
---------------------------------------


Class = require "hump.class"

Chunk = Class {}

function Chunk:init(chunkdata, world)
	self.world = world
	self.blocks = deepcopy(chunkdata)
	self.batch = love.graphics.newSpriteBatch(spritesheet, 10000)
	self.faces = {}
end

function Chunk:update(dt)

end

function Chunk:draw(offsetx, offsety)
	local lg = love.graphics
	lg.draw(self.batch)
end

function Chunk:rebuild(offsetx, offsety, cx, cy)
	local w = self.world
	local tmp = self.blocks
	local block_types = blocks
	self.batch:bind()
	self.batch:clear()
	for y = 1, #tmp do
		for z = #tmp[y], 1, -1 do
			for x = #tmp[y][z], 1, -1 do
				local faces = 0
				local cur_block = tmp[y][z][x]
				local c_x = math.floor(cx * chunk_size)
				local c_y = math.floor(cy * chunk_size)
				
				print("X: " .. c_x)
				print("Y: " .. c_y)
				
				if z-1 ~= 0 		 	and w:block(c_x, c_y, z-1) ~= 0 then faces = faces+1 end -- above				
				if z+1 ~= #tmp[y]+1 	and w:block(c_x, c_y, z+1) ~= 0 then faces = faces+1 end -- below			
				if x-1 ~= 0 		 	and w:block(c_x-1, c_y, z) ~= 0 then faces = faces+1 end -- left of
				if x+1 ~= #tmp[y][z]+1 	and w:block(c_x+1, c_y, z) ~= 0 then faces = faces+1 end -- right of
				if y-1 ~= 0 		 	and w:block(c_x, c_y-1, z) ~= 0 then faces = faces+1 end -- in front
				if y+1 ~= #tmp+1 		and w:block(c_x, c_y+1, z) ~= 0 then faces = faces+1 end -- behind
				
				-- if z-1 ~= 0 		 	and tmp[y][z-1][x] ~= 0 then faces = faces+1 end -- above
				-- if z+1 ~= #tmp[y]+1	 	and tmp[y][z+1][x] ~= 0 then faces = faces+1 end -- below
				-- if x-1 ~= 0 		 	and tmp[y][z][x-1] ~= 0 then faces = faces+1 end -- left of
				-- if x+1 ~= #tmp[y][z]+1 	and tmp[y][z][x+1] ~= 0 then faces = faces+1 end -- right of
				if faces == 6 then
					w.total_active = w.total_active - 1
				end
				
				if faces ~= 6 then
					local block = block_types[cur_block] or block_types[0]
					local t_x = ((x * tile_width / 2) + (y * tile_width / 2)) + offsetx
					local t_y = ((y * tile_height / 2) - (x * tile_height / 2) + offsety) + (z * tile_height)
					self.batch:add(block, t_x, t_y, 0, 1, 1, 0, 0, 0, 0)
				end
				
			end
		end
	end
	self.batch:unbind()
end