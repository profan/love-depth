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

Vector = require "hump.vector"
Camera = require "hump.camera"
WorldInc = require "world.world"
ChunkInc = require "world.chunk"
BlockInc = require "world.block"

-- end of hump library includes ------
---------------------------------------

---------------------------------------
-- game related functions/variables ---

local otherchunk = { -- y, x, z stored
	{
		{2, 2, 2, 2}
	},
}

local chunk = { -- y, z, x stored
	{
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
}

local tilemap = {
	-- { {2,2,2,2}, {1,1,1,1}, {1,1,1,1}, {1,1,1,1}, {1,1,1,1}, {1,1,1,3}, {3,3,3,3}, {3,3,3,3}  },
	-- { {0,2,2,2}, {2,1,1,1}, {1,1,1,1}, {1,1,1,1}, {1,1,1,1}, {1,1,3,3}, {3,3,3,3}, {3,3,3,3}  },
	-- { {0,0,0,2}, {0,2,2,2}, {2,1,1,1}, {1,1,1,3}, {1,1,3,3}, {3,3,3,3}, {3,3,3,3}, {3,3,3,3}  },
	-- { {0,0,0,0}, {0,0,0,2}, {0,2,2,1}, {2,1,3,3}, {1,3,3,3}, {3,3,3,3}, {3,3,3,3}, {3,3,3,3}  },
}

local spritesheet
local blocks = {}
local chunk_size = 4

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
	cam = Camera(0, 0)
	
	-- world related
	world = World("Overworld")
	
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
end

function setup_tilemap()
	for i, v in pairs(deepcopy(chunk)) do
		table.insert(tilemap, v[1])
	end
	-- local map_height = 64 / chunk_size
	-- local map_width = 64 / chunk_size
	-- for y = 1, map_height do
		-- tilemap[y] = {}
		-- for x = 1, map_width do
			-- tilemap[y] = deepcopy(chunk)
		-- end
	-- end
end

function draw_debug()
	local lg = love.graphics
	lg.setColor(color_white)
	lg.print("FPS: " .. love.timer.getFPS(), 800, 32)
end

function draw_world()
	local tmp = tilemap
	local lg = love.graphics
	for y = 1, #tmp do
		for z = #tmp[y], 1, -1 do
			for x = #tmp[y][z], 1, -1 do
				local t_x = (x * tile_width / 2) + (y * tile_width / 2)
				local t_y = (y * tile_height / 2) - (x * tile_height / 2) + (z * tile_height)
				
				local block = blocks[tmp[y][z][x]] or 0
				if block ~= 0 then
					lg.draw(spritesheet, block, t_x, t_y)
				end
			end
		end
	end 
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
	draw_debug()
	cam:draw(draw_world)
end

function love.update(dt)
	
	-- keyboard movement
	if love.keyboard.isDown("up") then cam:move(0, -1) end
	if love.keyboard.isDown("down") then cam:move(0, 1) end
	if love.keyboard.isDown("left") then cam:move(-1, 0) end
	if love.keyboard.isDown("right") then cam:move(1, 0) end
	
	-- mouse stuff
	if love.mouse.isDown("x1") then cam:zoom(1.25) end
	if love.mouse.isDown("m") then cam:zoomTo(1) end
	if love.mouse.isDown("r") then cam:zoomTo(0.01) end
	if love.mouse.isDown("x2") then cam:zoom(0.75) end
	
end

function love.mousepressed(x, y, button)

end

-- end of love functions/vars ---------
---------------------------------------