local Class = require "hump.class"

local TileEntity = Class {}

-- position should be a Vector2
function TileEntity:init(pos_vec, offset)
	-- assert(isvector(pos_vec), "invalid argument: expected vector for TileEntity position.")
	self.position = pos_vec
	self.offset = offset -- offset into sprite batch used for drawing
end

-- ....... update?
function TileEntity:update()

end

return TileEntity
