local Chunk = Class {}

function Chunk:init(chunkdata)
	self.blocks = chunkdata
	self.tilemap = blocks -- THIS IS GLOBAL!!!!!!!
	self.batch = love.graphics.newSpriteBatch(spritesheet, 30000)
	self.dirty = true
	
	-- tile entities
	self.entities = {}
	
	-- stats
	self.total_blocks = 0
	self.active_blocks = 0
end

function Chunk:update(dt)
	local ents = self.entities
	for i = 1, #ents do
		ents[i].update()
	end
end

function Chunk:draw(offsetx, offsety)
	love.graphics.draw(self.batch)
end

function Chunk:rebuild(zoom, offsetx, offsety)
	local blocks = self.blocks
	local tilemap = self.tilemap
	self.batch:bind()
	self.batch:clear()
	
	-- reset stats
	self.active_blocks = 0
	self.total_blocks = 0
	
	-- locals to make iteration slightly faster.
	local y_len = #blocks
	local z_len, x_len
	
	-- holds current block and number of faces obstructed by other blocks.
	local faces
	local cur_block
	
	-- reused every iteration in the block which sets actual draw position of blocks and holds block type quad reference.
	local block, tile_x, tile_y
	
	-- total batch time
	local btime = 0
	local stime
	for y = 1, #blocks do
		for z = #blocks[y], zoom, -1 do
			z_len = #blocks[y]
			for x = #blocks[y][z], 1, -1 do
				x_len = #blocks[y][z]
				cur_block = blocks[y][z][x]
				faces = 0
				
				if cur_block ~= 0 then -- if there is in fact somethinfg to draw, 0 means air.
					-- this part checks if a block is surrounded by other blocks or not.
					if z ~= zoom then
						if z-1 ~= 0 		 	and blocks[y][z-1][x] ~= 0 then faces = faces+1 end -- above
						if z+1 ~= z_len+1	 	and blocks[y][z+1][x] ~= 0 then faces = faces+1 end -- below
					end
					if x-1 ~= 0 		 	and blocks[y][z][x-1] ~= 0 then faces = faces+1 end -- left of
					if x+1 ~= x_len+1 		and blocks[y][z][x+1] ~= 0 then faces = faces+1 end -- right of
					if y-1 ~= 0 		 	and blocks[y-1][z][x] ~= 0 then faces = faces+1 end -- in front
					if y+1 ~= y_len+1 		and blocks[y+1][z][x] ~= 0 then faces = faces+1 end -- behind
					
					-- update stats
					self.total_blocks = self.total_blocks + 1

					if faces ~= 6 then
						block = tilemap[cur_block] or 0
						tile_x = ((x * World.tile_width / 2) + (y * World.tile_width / 2)) + offsetx
						tile_y = ((y * World.tile_height / 2) - (x * World.tile_height / 2) + offsety) + (z * World.tile_height)
						stime = love.timer.getTime()
						local id = self.batch:add(block, tile_x, tile_y, 0, 1, 1, 0, 0, 0, 0)
						btime = btime + love.timer.getTime() - stime
						self.active_blocks = self.active_blocks + 1
					end
				end
			end
		end
	end
	self.batch:unbind()
	self.dirty = false
	return btime
end

return Chunk
