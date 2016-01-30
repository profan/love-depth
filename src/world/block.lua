local Class = require "hump.class"

local Block = Class {}

function Block:init(block_type)
	self.type = block_type
end

return Block
