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

local tile_width = 32
local tile_height = 16
local chunk_size = 4

-- end of placeholders ----------------
---------------------------------------


Class = require "hump.class"

Chunk = Class {}

function Chunk:init(chunkdata, world)
	self.world = world
	self.blocks = deepcopy(chunkdata)
	self.vblocks = deepcopy(self.blocks)
	self.faces = {}
end

function Chunk:update(dt)

end

function Chunk:draw(offsetx, offsety)
	local tmp = self.vblocks
	local lg = love.graphics
	for y = 1, #tmp do
		for z = #tmp[y], 1, -1 do
			for x = #tmp[y][z], 1, -1 do
				local t_x = ((x * tile_width / 2) + (y * tile_width / 2)) + offsetx
				local t_y = ((y * tile_height / 2) - (x * tile_height / 2) + offsety) + (z * tile_height)
				
				local block = blocks[tmp[y][z][x]] or 0
				if block ~= 0 then
					lg.draw(spritesheet, block, t_x, t_y)
				end
			end
		end
	end 	
end

function Chunk:rebuild()
	local tmp = self.blocks
	for y = 1, #tmp do
		for z = 1, #tmp[y] do
			for x = 1, #tmp[y][z] do
				local faces = 0
				local cur_block = tmp[y][z][x]
				if z-1 ~= 0 		 	and tmp[y][z-1][x] ~= 0 then faces = faces+1 end -- above
				if z+1 ~= #tmp[y]+1	 	and tmp[y][z+1][x] ~= 0 then faces = faces+1 end -- below
				if x-1 ~= 0 		 	and tmp[y][z][x-1] ~= 0 then faces = faces+1 end -- left of
				if x+1 ~= #tmp[y][z]+1 	and tmp[y][z][x+1] ~= 0 then faces = faces+1 end -- right of
				if y-1 ~= 0 		 	and tmp[y-1][z][x] ~= 0 then faces = faces+1 end -- in front
				if y+1 ~= #tmp+1 		and tmp[y+1][z][x] ~= 0 then faces = faces+1 end -- behind
				
				if faces > 4 then
					self.vblocks[y][z][x] = 0
				end
			end
		end
	end
end