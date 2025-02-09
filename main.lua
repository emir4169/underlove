local debugMode = true
local FPS = 30
local lib_path = love.filesystem.getSaveDirectory() .. "/libraries"
local extension = jit.os == "Windows" and "dll" or jit.os == "Linux" and "so" or jit.os == "OSX" and "dylib"
package.cpath = string.format("%s;%s/?.%s", package.cpath, lib_path, extension)
currentEncounter = 'testEnemy'
Enemies = require('assets.enemies.' .. currentEncounter)
imgui = require "cimgui" -- cimgui is the folder containing the Lua module (the "src" folder in the git repository)
local ffi = require("ffi")
local function loadEnemy()
	package.loaded[Enemies] = nil
	Enemies = require('assets.enemies.' .. currentEncounter)
end

function reload()
	love.audio.stop()
	love.graphics.clear()
	love.load()
	playMusic = true
end

function love.keypressed(key)
	imgui.love.KeyPressed(key)
    if not imgui.love.GetWantCaptureKeyboard() then
		imgui.love.RunShortcuts(key)
    	if key == 'up' then
    	    input.up = true
    	elseif key == 'down' then
    	    input.down = true
    	elseif key == 'left' then
    	    input.left = true
    	elseif key == 'right' then
    	    input.right = true
    	elseif key == 'z' or key == 'return' then
    	    input.primary = true
    	elseif key == 'x' or key == 'rshift' or key == 'lshift' then
    	    input.secondary = true
    	elseif key == "f4" then
			fullscreen = not fullscreen
			love.window.setFullscreen(fullscreen, "desktop")
		end
		if debugMode then
			if key == '1' then
				love.graphics.captureScreenshot('screenie.png') 
			elseif key == 'r' then
				reload()
			end
		end
	end
end

function love.load(arg)
    local saveDir = "libraries/"
    local sourceFile = "cimgui.so"
    local destinationFile = saveDir .. sourceFile

    -- Ensure the libraries directory exists
    love.filesystem.createDirectory(saveDir)

    -- Read the source file from the .love file
    local fileData, err = love.filesystem.read(sourceFile)
    if fileData then
        -- Write it to the save directory
        local success, errorMsg = love.filesystem.write(destinationFile, fileData)
        if success then
            print("File copied successfully!")
        else
            print("Error copying file:", errorMsg)
        end
    else
        print("Error reading file:", err)
    end
	loadEnemy()
	imgui.love.Init() 
	love.audio.setVolume(1)
	global = {gameState = 'BattleEngine', battleState = nil, choice = 0, subChoice = 0}

	BattleEngine = require 'source.BattleEngine'

	fonts = {

		determination = love.graphics.newFont('assets/fonts/determination-mono.ttf', 32),
		mnc = love.graphics.newFont('assets/fonts/Mars_Needs_Cunnilingus.ttf', 23),
		dotumche = love.graphics.newFont('assets/fonts/dotumche.ttf', 13),
		default = love.graphics.newFont(12),
		consolas = love.graphics.newFont('assets/fonts/Consolas.ttf', 16),
		fredoka = love.graphics.newFont('assets/fonts/Fredoka-Medium.ttf', 16)
	}

	outlineWidth = 2

	for _, font in pairs(fonts) do
		font:setFilter("nearest", "nearest")
	end

	input = {up = false, down = false, left = false, right = false, primary = false, secondary = false}
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setBackgroundColor(0, 0, 0)

    yourCanvasName = love.graphics.newCanvas(640, 480)

    if global.gameState == 'BattleEngine' then BattleEngine:load() end
end

function love.update(dt)
	imgui.love.Update(dt)
    imgui.NewFrame()
    if global.gameState == 'BattleEngine' then BattleEngine:update(dt) end
    input = {up = false, down = false, left = false, right = false, primary = false, secondary = false}
end

-- didn't make these two functions :( sulfur gave them to me from the love2d forums but we can't find the source
local function connect()
    love.graphics.setCanvas(yourCanvasName)
    love.graphics.clear()
end

local function disconnect()
    love.graphics.setCanvas()
	local screenW,screenH = love.graphics.getDimensions()
	local canvasW,canvasH = yourCanvasName:getDimensions()
	local scale = math.min(screenW/canvasW , screenH/canvasH)
	love.graphics.push()
	love.graphics.translate( math.floor((screenW - canvasW * scale)/2) , math.floor((screenH - canvasH * scale)/2))
	love.graphics.scale(scale,scale)
    love.graphics.setColor(1, 1, 1)
	love.graphics.draw(yourCanvasName)
	love.graphics.pop()
end

function love.draw()
    connect()
    if global.gameState == 'BattleEngine' then BattleEngine:draw() end
    disconnect()
	if imgui.Begin("test", nil, imgui.ImGuiWindowFlags_MenuBar) then
        local action = function() print("Shortcut processed.") end
        local shortcut = imgui.love.Shortcut({"ctrl", "shift"}, "s", action, true, false)

        if imgui.BeginMenuBar() then
            if imgui.BeginMenu("File") then
                -- disable MenuItem if shortcut is not enabled
                if imgui.MenuItem_Bool("Save", shortcut.text, nil, shortcut.enabled) then
                    shortcut.action()
                end
                imgui.EndMenu()
            end
            imgui.EndMenuBar()
        end
		-- get a int * to Player.stats.hp using ai
		plhp =    ffi.new("int[1]", Player.stats.hp)
		plmaxhp = ffi.new("int[1]", Player.stats.maxhp)
		pllove =  ffi.new("int[1]", Player.stats.love)
		if imgui.SliderInt("HP", plhp, 1,20)       then Player.stats.hp = plhp[0] end
		if imgui.SliderInt("Max HP", plmaxhp, 1,20)then Player.stats.maxhp = plmaxhp[0] end
		if imgui.SliderInt("Love", pllove, 1,20)   then Player.stats.love = pllove[0] end

    end
    imgui.End()
    imgui.Render()
    imgui.love.RenderDrawLists()
	if debugMode then
		local width = 230
		local height = 81

		love.graphics.setColor(0, 0, 0, .5)
		love.graphics.rectangle('fill', 5, 5, width, height, 5)

		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setLineWidth(2)
		love.graphics.setLineStyle('rough')
		love.graphics.rectangle('line', 5, 5, width, height, 5)

		love.graphics.setColor(0, 0, 0)
		love.graphics.setLineWidth(2)
		love.graphics.setLineStyle('rough')
		love.graphics.rectangle('line', 3, 3, width + 4, height + 4, 5)
		
		love.graphics.setFont(fonts.consolas)
		love.graphics.setColor(1, 1, 1)
		love.graphics.print('FPS: ' .. love.timer.getFPS() .. '\ngameState: ' .. global.gameState .. '\nbattleState: ' .. global.battleState .. '\nRAM Usage: ' .. math.floor(collectgarbage("count")) .. ' KB', 10, 10)
	end
end

local timerSleep = function () return 1/FPS end
function love.run()
	if love.math then
		love.math.setRandomSeed(os.time())
	end
 
	if love.load then love.load(arg) end
 
	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end
 
	local dt = 0
 
	-- Main loop time.
	while true do
		-- Process events.
		local startT = love.timer.getTime()
		
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end
 
		-- Update dt, as we'll be passing it to update
		if love.timer then
			love.timer.step()
			dt = love.timer.getDelta()
		end
 
		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled
 
		if love.graphics and love.graphics.isActive() then
			love.graphics.clear(love.graphics.getBackgroundColor())
			love.graphics.origin()
			if love.draw then love.draw() end
			love.graphics.present()
		end
 
		if love.timer then
			local endT = love.timer.getTime()
			love.timer.sleep(timerSleep() - (endT - startT))
		end
	end
end

love.keyreleased = function(key, ...)
    imgui.love.KeyReleased(key)
    if not imgui.love.GetWantCaptureKeyboard() then
        -- your code here 
    end
end

love.textinput = function(t)
    imgui.love.TextInput(t)
    if imgui.love.GetWantCaptureKeyboard() then
        -- your code here 
    end
end

love.quit = function()
    return imgui.love.Shutdown()
end
love.mousemoved = function(x, y, ...)
    imgui.love.MouseMoved(x, y)
    if not imgui.love.GetWantCaptureMouse() then
        -- your code here
    end
end

love.mousepressed = function(x, y, button, ...)
    imgui.love.MousePressed(button)
    if not imgui.love.GetWantCaptureMouse() then
        -- your code here 
    end
end

love.mousereleased = function(x, y, button, ...)
    imgui.love.MouseReleased(button)
    if not imgui.love.GetWantCaptureMouse() then
        -- your code here 
    end
end