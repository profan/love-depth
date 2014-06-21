---------------------------------------
-- temporary placeholders for chunk ---

local tile_width = 32
local tile_height = 16
local chunk_size = 32
local chunk_height = 64

-- end of placeholders ----------------
---------------------------------------


Class = require "hump.class"

local Chunk = Class {}

function Chunk:init(chunkdata)
	self.blocks = chunkdata
	self.batch = love.graphics.newSpriteBatch(spritesheet, 30000)
	self.faces = {}
	self.dirty = true
	-- stats
	self.total_blocks = 0
	self.active_blocks = 0
	
	-- list of quad refs in spritebatch
	self.drawn_blocks = {}
end

function Chunk:update(dt)

end

function Chunk:draw(offsetx, offsety)
	local lg = love.graphics
	lg.draw(self.batch)
end

function Chunk:threadbuild(zoom, offsetx, offsety)
	
end

function Chunk:rebuild(zoom, offsetx, offsety)
	local tmp = self.blocks
	local block_types = blocks
	
	-- reset stats
	self.active_blocks = 0
	self.total_blocks = 0
	
	local y_len = #tmp
	local z_len, x_len
	
	local faces
	local cur_block
	local block, t_x, t_y
	local buildqueue = {}
	for y = 1, #tmp do
		for z = #tmp[y], zoom, -1 do
			z_len = #tmp[y]
			for x = #tmp[y][z], 1, -1 do
				faces = 0
				x_len = #tmp[y][z]
				cur_block = tmp[y][z][x]
				
				if cur_block ~= 0 then
					if z ~= zoom then
						if z-1 ~= 0 		 	and tmp[y][z-1][x] ~= 0 then faces = faces+1 end -- above
						if z+1 ~= z_len+1	 	and tmp[y][z+1][x] ~= 0 then faces = faces+1 end -- below
					end
					if x-1 ~= 0 		 	and tmp[y][z][x-1] ~= 0 then faces = faces+1 end -- left of
					if x+1 ~= x_len+1 		and tmp[y][z][x+1] ~= 0 then faces = faces+1 end -- right of
					if y-1 ~= 0 		 	and tmp[y-1][z][x] ~= 0 then faces = faces+1 end -- in front
					if y+1 ~= y_len+1 		and tmp[y+1][z][x] ~= 0 then faces = faces+1 end -- behind
					
					-- update stats
					self.total_blocks = self.total_blocks + 1

					if faces ~= 6 then
						block = block_types[cur_block] or 0
						t_x = ((x * tile_width / 2) + (y * tile_width / 2)) + offsetx
						t_y = ((y * tile_height / 2) - (x * tile_height / 2) + offsety) + (z * tile_height)
						table.insert(buildqueue, {block, t_x, t_y, 0, 1, 1, 0, 0, 0, 0})
						self.active_blocks = self.active_blocks + 1
					end
				end
			end
		end
	end
	self.dirty = false
	return buildqueue -- returns functions to be run that will do in main thread
end

function Chunk:build_batch(batch)
	self.batch:bind()
	self.batch:clear()
	for i = 1, #batch do
		for k = 1, #batch[i] do
			local b = batch[i]
			self.batch:add(b[1], b[2], b[3], b[4], b[5], b[6], b[7], b[8], b[9], b[10])
		end
	end
	self.batch:unbind()
end

return Chunk