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

require "cupid.debug"
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

-- related to rebuilding on zoom
wait_time = 0

-- generic
local screen_w
local screen_h

local tile_cell = 32
local tile_width = 32
local tile_height = 16

local color_limegreen =	{153, 255, 0}
local color_white = {255, 255, 255}
local color_blue =	{30, 144, 255} -- dodger blue

local chunk_height = 128

function setup_game()
	screen_w = love.graphics.getWidth()
	screen_h = love.graphics.getHeight()

	-- camera setup
	cam = Camera(2200, 0)
	
	-- world related
	world = World("Overworld", 2, 2)
	
	-- setup stuff
	zoom_level = 1
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
	blocks[5] = love.graphics.newQuad( -- water
			0, tile_cell*4, -- position in tilemap
			tile_cell, tile_cell,
			512, 512 -- width of sheet
	)
end

function setup_tilemap()
	world:generate()
	world:rebuild(zoom_level)
end

function draw_debug()
	local lg = love.graphics
	local chunks, blocks, active = world:stats()
	
	local v_x, v_y = world_to_grid(cam:worldCoords(love.mouse.getPosition()))
	
	lg.setColor(color_white)
	lg.push()
	lg.translate(lg.getWidth() - 256, 32)
	lg.print("FPS: " .. love.timer.getFPS(), 0, 16)
	lg.print("Chunks: " .. chunks, 0, 32)
	lg.print("Blocks: " .. blocks, 0, 48)
	lg.print("Active blocks: " .. active, 0, 64)
	lg.print("Zoom Level: " .. zoom_level, 0, 80)
	lg.print("Update time: " .. (update_time or 0), 0, 96)
	lg.print("Render time: " .. (render_time or 0), 0, 112)
	lg.print("Last rebuild time: " .. (rebuild_time or 0), 0, 128)
	lg.print("Current wait time: " .. (wait_time or 0), 0, 144)
	lg.print("Under Mouse World X:" .. v_x, 0, 164)
	lg.print("Under Mouse World Y:" .. v_y, 0, 180)
	lg.pop()
end

function draw_world()
	world:draw(zoom_level)
end

function draw_highlight()
	local x, y = world_to_grid(cam:worldCoords(love.mouse.getPosition()))
	love.graphics.draw(spritesheet, blocks[4], x, y)
end

function world_to_grid(x, y)
	local m = math.floor(y / tile_height - (x-(tile_width/2)) / tile_width)
	local n = math.floor(y / tile_height + (x-(tile_width/2)) / tile_width)
	local n_x = ((n - m) / 2 * tile_width)
	local n_y = ((n + m) / 2 * tile_height)
	return n_x, n_y
end

wait_time = 0
function explode()
	for x = 1, 64 do
		for y = 1, 64 do
			for z = 1, 64 do
				world:set_block(x, y, z, 0)
			end
		end
	end
	world:rebuild(zoom_level)
end

-- end of game related functions/vars -
---------------------------------------

---------------------------------------
-- love functions ---------------------

function love.load() 
	setup_game()
end

function love.draw()
	-- timing
	local stime = love.timer.getTime()
	cam:attach()
	draw_world()
	draw_highlight()
	cam:detach()
	draw_debug()
	render_time = love.timer.getTime() - stime
end

function love.update(dt)
	newzoom = newzoom or zoom_level
	-- timing
	local stime = love.timer.getTime()
	
	-- keyboard movement
	if love.keyboard.isDown("up") then cam:move(0, -5) end
	if love.keyboard.isDown("down") then cam:move(0, 5) end
	if love.keyboard.isDown("left") then cam:move(-5, 0) end
	if love.keyboard.isDown("right") then cam:move(5, 0) end
	
	wait_time = wait_time - dt
	if newzoom ~= zoom_level and wait_time <= 0 then
		world:rebuild(zoom_level) 
		newzoom = zoom_level
		wait_time = 0
	end
	
	-- mouse stuff
	if love.mouse.isDown("x1") then cam:zoom(1.05) end
	if love.mouse.isDown("r") then explode() end
	if love.mouse.isDown("m") then cam:zoomTo(1) end
	if love.mouse.isDown("x2") then cam:zoom(0.95) end
	
	Timer.update(dt)
	update_time = love.timer.getTime() - stime
end

function love.keypressed(key)
	
end

function love.mousepressed(x, y, button)
	if button == "wu" then 
		if zoom_level + 1 ~= chunk_height+1 then
			zoom_level = zoom_level + 1
			wait_time = wait_time + 0.05
		end
	end
	if button == "wd" then
		if zoom_level - 1 ~= 0 then
			zoom_level = zoom_level - 1
			wait_time = wait_time + 0.05
		end
	end
end

-- end of love functions/vars ---------
---------------------------------------
