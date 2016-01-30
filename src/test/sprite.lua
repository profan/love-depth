local Class = require "hump.class"

local Sprite = Class {}
Sprite:include(TileEntity)

function Sprite:init(pos_vec, offset)
	TileEntity.init(self, pos_vec, offset)
end

return Sprite
