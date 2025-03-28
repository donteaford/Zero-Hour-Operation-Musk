local ui = {}

local menuItems = {"Start New Game", "Save Game", "Load Game", "Settings", "Quit"}
local selectedItem = 1
local bootSequenceTime = 0
local bootSequenceSteps = {
    {time = 0.5, text = "BIOS initialization..."},
    {time = 1.5, text = "Loading kernel..."},
    {time = 2.5, text = "Ubuntu 22.04 LTS booting..."},
    {time = 4.0, text = "Starting system services..."},
    {time = 6.0, text = "Terminal ready"}
}
local currentBootStep = 1

function ui.initialize()
    -- Load fonts, images, etc.
end

function ui.updateMainMenu(dt)
    -- Handle keyboard input for menu navigation
    if love.keyboard.wasPressed("up") then
        selectedItem = selectedItem - 1
        if selectedItem < 1 then selectedItem = #menuItems end
        -- Add visual feedback for debugging
        print("Up pressed, selected item: " .. selectedItem)
    elseif love.keyboard.wasPressed("down") then
        selectedItem = selectedItem + 1
        if selectedItem > #menuItems then selectedItem = 1 end
        -- Add visual feedback for debugging
        print("Down pressed, selected item: " .. selectedItem)
    elseif love.keyboard.wasPressed("return") or love.keyboard.wasPressed("space") then
        -- Handle menu selection
        print("Enter/Space pressed, selected: " .. menuItems[selectedItem])
        if menuItems[selectedItem] == "Start New Game" then
            return "boot_sequence"
        elseif menuItems[selectedItem] == "Quit" then
            love.event.quit()
        end
    end
    
    -- Handle mouse input for menu selection
    local mx, my = love.mouse.getPosition()
    for i, item in ipairs(menuItems) do
        local y = 200 + (i * 40)
        if my >= y and my <= y + 30 then
            selectedItem = i
            if love.mouse.wasPressed(1) then
                print("Mouse clicked on: " .. menuItems[selectedItem])
                if menuItems[selectedItem] == "Start New Game" then
                    return "boot_sequence"
                elseif menuItems[selectedItem] == "Quit" then
                    love.event.quit()
                end
            end
        end
    end
    
    return nil
end

function ui.drawMainMenu()
    love.graphics.setBackgroundColor(0, 0, 0)
    
    -- Load and draw logo on the left half
    -- Set color to white to show logo in its original colors
    love.graphics.setColor(1, 1, 1)
    local logo = love.graphics.newImage("logo.png")
    local logoScale = math.min((love.graphics.getWidth() * 0.45) / logo:getWidth(), 
                              (love.graphics.getHeight() * 0.8) / logo:getHeight())
    love.graphics.draw(logo, 50, love.graphics.getHeight() / 2 - (logo:getHeight() * logoScale) / 2, 
                      0, logoScale, logoScale)
    
    -- Draw title on the right half
    love.graphics.setColor(0, 1, 0)
    love.graphics.printf("ZERO HOUR : OPERATION MUSK", love.graphics.getWidth() / 2, 100, 
                        love.graphics.getWidth() / 2, "center")
    
    -- Draw menu items on the right half
    for i, item in ipairs(menuItems) do
        if i == selectedItem then
            love.graphics.setColor(1, 1, 0)
        else
            love.graphics.setColor(0, 1, 0)
        end
        love.graphics.printf(item, love.graphics.getWidth() / 2, 200 + (i * 40), 
                           love.graphics.getWidth() / 2, "center")
    end
end

function ui.updateBootSequence(dt, gameState)
    bootSequenceTime = bootSequenceTime + dt
    
    if currentBootStep <= #bootSequenceSteps then
        if bootSequenceTime >= bootSequenceSteps[currentBootStep].time then
            currentBootStep = currentBootStep + 1
        end
    else
        -- Boot sequence complete
        bootSequenceTime = 0
        currentBootStep = 1
        gameState.currentScreen = "terminal"
    end
end

function ui.drawBootSequence(gameState)
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.setColor(0, 1, 0)
    
    -- Draw boot messages
    for i=1, currentBootStep-1 do
        love.graphics.printf(bootSequenceSteps[i].text, 50, 100 + (i * 30), love.graphics.getWidth() - 100, "left")
    end
end

return ui



