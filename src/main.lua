---------------------------------------
-- helper functions -------------------

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


-- end of generic helper functions ----
---------------------------------------

---------------------------------------
-- hump libraries here ----------------

require("cupid.debug")
Timer = require "hump.timer"
Vector = require "hump.vector"
Camera = require "hump.camera"
World = require "world.world"
Chunk = require "world.chunk"
Block = require "world.block"

-- end of hump library includes ------
---------------------------------------

---------------------------------------
-- game related functions/variables ---

blocks = {}

-- generic
local screen_w
local screen_h

local tile_cell = 32
local tile_width = 32
local tile_height = 16

local color_limegreen =	{153, 255, 0}
local color_white = {255, 255, 255}
local color_blue =	{30, 144, 255} -- dodger blue

function setup_game()
	screen_w = love.graphics.getWidth()
	screen_h = love.graphics.getHeight()

	-- camera setup
	cam = Camera(5000, 0)
	
	
	-- world related
	world = World("Overworld", 10, 10)
	
	-- setup stuff
	setup_tiles()
	setup_tilemap()
end

function setup_tiles()
	spritesheet = love.graphics.newImage("cubesheet.png")
	blocks[1] = love.graphics.newQuad( -- dirt
			tile_cell*4, tile_cell*5, -- position in tilemap
			tile_cell, tile_cell,
			512, 512 -- width of sheet
	)
	blocks[2] = love.graphics.newQuad( -- grass
			0, tile_cell*5, -- position in tilemap
			tile_cell, tile_cell,
			512, 512 -- width of sheet
	)
	blocks[3] = love.graphics.newQuad( -- stone
			0, tile_cell*6, -- position in tilemap
			tile_cell, tile_cell,
			512, 512 -- width of sheet
	)
	blocks[4] = love.graphics.newQuad( -- selector
			tile_cell*4, tile_cell*6, -- position in tilemap
			tile_cell, tile_cell,
			512, 512 -- width of sheet
	)
end

function setup_tilemap()
	world:generate()
	world:rebuild()
end

function draw_debug()
	local lg = love.graphics
	local chunks, blocks, active = world:stats()
	
	lg.setColor(color_white)
	lg.push()
	lg.translate(800, 32)
	lg.print("FPS: " .. love.timer.getFPS(), 0, 16)
	lg.print("Chunks: " .. chunks, 0, 32)
	lg.print("Blocks: " .. blocks, 0, 48)
	lg.print("Active blocks: " .. active, 0, 64)
	lg.pop()
end

function draw_world()
	world:draw()
end

function draw_highlight()
	local x, y = world_to_grid(cam:worldCoords(love.mouse.getPosition()))
	love.graphics.draw(spritesheet, blocks[4], x, y)
end

function world_to_grid(x, y)
	local n_x = math.floor(x / tile_width) * tile_width
	local n_y = math.floor(y / tile_height) * tile_height
	return n_x, n_y
end

function explode()
	for x = 1, 64 do
		for y = 1, 64 do
			for z = 1, 64 do
				world:set_block(x, y, z, 0)
			end
		end
	end
	world:rebuild()
end

-- end of game related functions/vars -
---------------------------------------

---------------------------------------
-- love functions ---------------------

function love.load() 
	local flags = {
		fullscreen = false, 
		vsync = true, fsaa = 0, 
		resizable = false, 
		borderless = false, 
		centered = true,
		display = 1,
		srgb = false
	}
	love.window.setMode(1024, 768, flags)
	setup_game()
end

function love.draw()
	cam:attach()
	draw_world()
	draw_highlight()
	cam:detach()
	draw_debug()
end

function love.update(dt)
	
	-- keyboard movement
	if love.keyboard.isDown("up") then cam:move(0, -5) end
	if love.keyboard.isDown("down") then cam:move(0, 5) end
	if love.keyboard.isDown("left") then cam:move(-5, 0) end
	if love.keyboard.isDown("right") then cam:move(5, 0) end
	
	-- mouse stuff
	if love.mouse.isDown("x1") then cam:zoom(1.25) end
	if love.mouse.isDown("l") then explode() end
	if love.mouse.isDown("m") then cam:zoomTo(1) end
	if love.mouse.isDown("x2") then cam:zoom(0.75) end
	
	Timer.update(dt)
	
end

function love.keypressed(key)
	
end

function love.mousepressed(x, y, button)
	
end

-- end of love functions/vars ---------
---------------------------------------