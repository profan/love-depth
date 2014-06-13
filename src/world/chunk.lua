Class = require "hump.class"

Chunk = Class {}

function Chunk:init()
	self.blocks = {}
	self.faces = {}
end

function Chunk:create(t)
	self.blocks = deepcopy(t)
end

function Chunk:update(dt)
	
end

function Chunk:draw()
	
end

function Chunk:rebuild()
	
end