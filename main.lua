-- Hacking Simulation Game
-- A retro-futuristic cyber hacking game

local ui = require("ui")
local terminal = require("terminal")
local filesystem = require("filesystem")
local desktop = require("desktop")
local missions = require("missions")
local player = require("player")

-- Initialize game state
local gameState = {
    currentScreen = "main_menu",
    player = player.new(),
    filesystem = filesystem.initialize()
}

-- Add these variables to track key and mouse presses
local keysPressed = {}
local mousePressed = {}

-- Main game loop
function love.load()
    ui.initialize()
    love.keyboard.setKeyRepeat(true)
end

function love.update(dt)
    local newScreen = nil
    
    if gameState.currentScreen == "main_menu" then
        newScreen = ui.updateMainMenu(dt)
    elseif gameState.currentScreen == "terminal" then
        terminal.update(dt, gameState)
    elseif gameState.currentScreen == "desktop" then
        desktop.update(dt, gameState)
    elseif gameState.currentScreen == "boot_sequence" then
        ui.updateBootSequence(dt, gameState)
    end
    
    -- Change screen if needed
    if newScreen then
        gameState.currentScreen = newScreen
    end
    
    -- Reset pressed keys and mouse buttons
    keysPressed = {}
    mousePressed = {}
end

function love.draw()
    if gameState.currentScreen == "main_menu" then
        ui.drawMainMenu()
    elseif gameState.currentScreen == "terminal" then
        terminal.draw(gameState)
    elseif gameState.currentScreen == "desktop" then
        desktop.draw(gameState)
    elseif gameState.currentScreen == "boot_sequence" then
        ui.drawBootSequence(gameState)
    end
end

-- Add these helper functions to track key and mouse presses
function love.keypressed(key)
    -- Store key state for other modules to check
    love.keyboard.wasPressed = function(k)
        return key == k
    end
    
    -- Pass keyboard events to the current screen
    if gameState.currentScreen == "terminal" then
        terminal.keyPressed(key, gameState)
    elseif gameState.currentScreen == "desktop" then
        desktop.keyPressed(key, gameState)
    end
end

function love.mousepressed(x, y, button)
    -- Store mouse state for other modules to check
    mousePressed[button] = true
    
    -- Pass mouse events to the current screen
    if gameState.currentScreen == "desktop" then
        desktop.handleMousePressed(x, y, button, gameState)
    elseif gameState.currentScreen == "terminal" then
        -- Add terminal mouse handling if needed
    end
end

function love.mousereleased(x, y, button)
    mousePressed[button] = false
    
    -- Add any release handling if needed
    if gameState.currentScreen == "desktop" then
        -- Reset dragging/resizing if needed
        if button == 1 then
            -- These variables should be in desktop.lua scope
            -- desktop.draggingWindow = nil
            -- desktop.resizingWindow = nil
        end
    end
end

-- Add these helper functions to check if a key or mouse button was pressed this frame
function love.keyboard.wasPressed(key)
    return keysPressed[key] == true
end

function love.mouse.wasPressed(button)
    return mousePressed[button] == true
end

function love.textinput(text)
    if gameState.currentScreen == "terminal" then
        terminal.handleTextInput(text)
    elseif gameState.currentScreen == "desktop" then
        desktop.handleTextInput(text, gameState)
    end
end


