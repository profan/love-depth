---------------------------------------
-- temporary placeholders for chunk ---

local tile_width = 32
local tile_height = 16
local chunk_size = 32
local chunk_height = 32

-- end of placeholders ----------------
---------------------------------------


Class = require "hump.class"

local Chunk = Class {}

function Chunk:init(chunkdata, world)
	self.world = world
	self.blocks = chunkdata
	self.batch = love.graphics.newSpriteBatch(spritesheet, 30000)
	self.faces = {}
	self.dirty = true
end

function Chunk:update(dt)

end

function Chunk:draw(offsetx, offsety)
	local lg = love.graphics
	lg.draw(self.batch)
end

function Chunk:rebuild(offsetx, offsety)
	local tmp = self.blocks
	local block_types = blocks
	self.batch:bind()
	self.batch:clear()
	
	local y_len = #tmp
	local z_len, x_len
	
	local faces
	local cur_block
	local block, t_x, t_y
	for y = 1, #tmp do
		for z = #tmp[y], 1, -1 do
			z_len = #tmp[y]
			for x = #tmp[y][z], 1, -1 do
				faces = 0
				x_len = #tmp[y][z]
				cur_block = tmp[y][z][x]
				
				if cur_block ~= 0 then
					if z-1 ~= 0 		 	and tmp[y][z-1][x] ~= 0 then faces = faces+1 end -- above
					if z+1 ~= z_len+1	 	and tmp[y][z+1][x] ~= 0 then faces = faces+1 end -- below
					if x-1 ~= 0 		 	and tmp[y][z][x-1] ~= 0 then faces = faces+1 end -- left of
					if x+1 ~= x_len+1 		and tmp[y][z][x+1] ~= 0 then faces = faces+1 end -- right of
					if y-1 ~= 0 		 	and tmp[y-1][z][x] ~= 0 then faces = faces+1 end -- in front
					if y+1 ~= y_len+1 		and tmp[y+1][z][x] ~= 0 then faces = faces+1 end -- behind
					
					if faces == 6 then
						self.world.total_active = self.world.total_active - 1
					end
					
					if faces ~= 6 then
						block = block_types[cur_block] or 0
						t_x = ((x * tile_width / 2) + (y * tile_width / 2)) + offsetx
						t_y = ((y * tile_height / 2) - (x * tile_height / 2) + offsety) + (z * tile_height)
						self.batch:add(block, t_x, t_y, 0, 1, 1, 0, 0, 0, 0)
					end
				end
			end
		end
	end
	self.batch:unbind()
	self.dirty = false
end

return Chunk