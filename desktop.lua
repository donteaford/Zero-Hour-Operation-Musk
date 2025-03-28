local terminal = require("terminal")

local desktop = {}

-- Load background image and icons
local backgroundImage = love.graphics.newImage("background.jpg")
local terminalIcon = love.graphics.newImage("terminal.png")
local browserIcon = love.graphics.newImage("browser.png")
local fileExplorerIcon = love.graphics.newImage("file_explorer.png")
local startIcon = love.graphics.newImage("start.png")
local hackingToolsIcon = love.graphics.newImage("hacking_tools.png")

local apps = {
    terminal = {
        icon = terminalIcon,
        title = "Terminal",
        x = 50,
        y = 50,
        width = 600,
        height = 400,
        open = false,
        minimized = false,
        zIndex = 1
    },
    browser = {
        icon = browserIcon,
        title = "Web Browser",
        x = 100,
        y = 100,
        width = 800,
        height = 500,
        open = false,
        minimized = false,
        url = "about:blank",
        zIndex = 2
    },
    fileExplorer = {
        icon = fileExplorerIcon,
        title = "File Explorer",
        x = 150,
        y = 150,
        width = 500,
        height = 400,
        open = false,
        minimized = false,
        currentPath = "/home/hacker",
        zIndex = 3
    },
    hackingTools = {
        icon = hackingToolsIcon,
        title = "Hacking Tools",
        x = 200,
        y = 200,
        width = 600,
        height = 400,
        open = false,
        minimized = false,
        zIndex = 4
    },
    textEditor = {
        icon = love.graphics.newImage("text_editor.png"), -- You'll need to add this image
        title = "Text Editor",
        x = 250,
        y = 150,
        width = 600,
        height = 450,
        open = false,
        minimized = false,
        currentFile = nil,
        content = {},
        readOnly = false,
        zIndex = 5
    }
}

local desktopIcons = {
    {name = "Terminal", x = 50, y = 50, width = 40, height = 60, app = "terminal"},
    {name = "Browser", x = 50, y = 120, width = 40, height = 60, app = "browser"},
    {name = "Files", x = 50, y = 190, width = 40, height = 60, app = "fileExplorer"},
    {name = "Editor", x = 50, y = 260, width = 40, height = 60, app = "textEditor"}
}

local startMenuOpen = false

-- Add these variables for window management
local draggingWindow = nil
local dragOffsetX, dragOffsetY = 0, 0
local resizingWindow = nil

-- Add these variables for context menu and drag-and-drop
local contextMenu = {
    visible = false,
    x = 0,
    y = 0,
    width = 120,
    height = 150,
    options = {"Copy", "Cut", "Paste", "Rename", "Delete"},
    targetFile = "",
    targetPath = ""
}

local draggedFile = {
    active = false,
    file = "",
    sourcePath = "",
    x = 0,
    y = 0
}

-- Add clipboard for file operations
local clipboard = {
    operation = nil, -- "copy" or "cut"
    file = "",
    path = ""
}

function desktop.update(dt, gameState)
    -- Handle window dragging
    if draggingWindow then
        local mx, my = love.mouse.getPosition()
        apps[draggingWindow].x = mx - dragOffsetX
        apps[draggingWindow].y = my - dragOffsetY
        
        -- Check if mouse button is released
        if not love.mouse.isDown(1) then
            draggingWindow = nil
        end
    end
    
    -- Handle window resizing
    if resizingWindow then
        local mx, my = love.mouse.getPosition()
        local app = apps[resizingWindow]
        app.width = math.max(300, mx - app.x)
        app.height = math.max(200, my - app.y)
        
        -- Check if mouse button is released
        if not love.mouse.isDown(1) then
            resizingWindow = nil
        end
    end
    
    -- Update browser loading animation if needed
    for name, app in pairs(apps) do
        if name == "browser" and app.loading then
            local loadTime = love.timer.getTime() - app.loadStartTime
            if loadTime > 1.5 then
                app.loading = false
            end
        end
    end
    
    -- Update file dragging
    if draggedFile.active then
        local mx, my = love.mouse.getPosition()
        draggedFile.x = mx
        draggedFile.y = my
        
        -- Check if mouse button is released
        if not love.mouse.isDown(1) then
            -- Check if dropped on a folder
            local app = apps.fileExplorer
            if app.open and not app.minimized then
                local files = gameState.filesystem.listDirectory(gameState.filesystem, app.currentPath)
                local fileY = app.y + 70
                
                for _, file in ipairs(files) do
                    -- Check if it's a folder and if the file was dropped on it
                    if gameState.filesystem.isDirectory(gameState.filesystem, app.currentPath .. "/" .. file) then
                        local fileX = app.x + 20
                        if mx >= fileX - 10 and mx <= fileX + 50 and
                           my >= fileY and my <= fileY + 50 then
                            -- Move the file to this folder
                            if gameState.filesystem.moveFile then
                                gameState.filesystem.moveFile(
                                    gameState.filesystem,
                                    draggedFile.sourcePath .. "/" .. draggedFile.file,
                                    app.currentPath .. "/" .. file .. "/" .. draggedFile.file
                                )
                            end
                            break
                        end
                    end
                    fileY = fileY + 80
                end
            end
            
            draggedFile.active = false
        end
    end
    
    -- Close context menu if clicked outside
    if contextMenu.visible and love.mouse.wasPressed(1) then
        local mx, my = love.mouse.getPosition()
        if mx < contextMenu.x or mx > contextMenu.x + contextMenu.width or
           my < contextMenu.y or my > contextMenu.y + contextMenu.height then
            contextMenu.visible = false
        end
    end
end

function desktop.draw(gameState)
    -- Draw desktop background
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(backgroundImage, 0, 0, 0, 
                      love.graphics.getWidth() / backgroundImage:getWidth(),
                      love.graphics.getHeight() / backgroundImage:getHeight())
    
    -- Draw desktop icons
    for _, icon in ipairs(desktopIcons) do
        desktop.drawIcon(icon)
    end
    
    -- Draw taskbar
    love.graphics.setColor(0.1, 0.1, 0.1, 0.8)
    love.graphics.rectangle("fill", 0, love.graphics.getHeight() - 40, love.graphics.getWidth(), 40)
    
    -- Draw start button
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(startIcon, 10, love.graphics.getHeight() - 35, 0, 30/startIcon:getWidth(), 30/startIcon:getHeight())
    
    -- Draw start menu if open
    if startMenuOpen then
        desktop.drawStartMenu()
    end
    
    -- Sort apps by zIndex for proper layering
    local sortedApps = {}
    for name, app in pairs(apps) do
        if app.open and not app.minimized then
            table.insert(sortedApps, {name = name, app = app})
        end
    end
    
    table.sort(sortedApps, function(a, b) return a.app.zIndex < b.app.zIndex end)
    
    -- Draw open applications
    for _, appData in ipairs(sortedApps) do
        desktop.drawApp(appData.name, appData.app, gameState)
    end
    
    -- Draw taskbar icons for open apps
    local taskbarIconX = 100
    for name, app in pairs(apps) do
        if app.open then
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(app.icon, taskbarIconX, love.graphics.getHeight() - 35, 0, 30/app.icon:getWidth(), 30/app.icon:getHeight())
            taskbarIconX = taskbarIconX + 40
        end
    end
end

function desktop.drawIcon(icon)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(apps[icon.app].icon, icon.x, icon.y, 0, 40/apps[icon.app].icon:getWidth(), 40/apps[icon.app].icon:getHeight())
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.rectangle("fill", icon.x, icon.y + 45, 40, 20)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(icon.name, icon.x, icon.y + 48, 40, "center")
end

function desktop.drawStartMenu()
    love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
    love.graphics.rectangle("fill", 0, love.graphics.getHeight() - 300, 200, 260)
    
    local menuItems = {"Terminal", "Browser", "File Explorer", "Hacking Tools", "Log Out"}
    local menuIcons = {terminalIcon, browserIcon, fileExplorerIcon, hackingToolsIcon, nil}
    
    for i, item in ipairs(menuItems) do
        local y = love.graphics.getHeight() - 300 + (i-1) * 40
        
        -- Highlight on hover
        local mx, my = love.mouse.getPosition()
        if mx >= 0 and mx <= 200 and my >= y and my <= y + 40 then
            love.graphics.setColor(0.3, 0.3, 0.3)
            love.graphics.rectangle("fill", 0, y, 200, 40)
        end
        
        -- Draw icon
        love.graphics.setColor(1, 1, 1)
        if menuIcons[i] then
            love.graphics.draw(menuIcons[i], 10, y + 5, 0, 30/menuIcons[i]:getWidth(), 30/menuIcons[i]:getHeight())
        end
        
        -- Draw text
        love.graphics.print(item, 50, y + 10)
    end
end

function desktop.drawApp(name, app, gameState)
    -- Draw window background
    love.graphics.setColor(0.2, 0.2, 0.2, 0.9)
    love.graphics.rectangle("fill", app.x, app.y, app.width, app.height)
    
    -- Draw title bar
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", app.x, app.y, app.width, 25)
    
    -- Draw title
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(app.title, app.x + 10, app.y + 5)
    
    -- Minimize button
    love.graphics.setColor(0.8, 0.8, 0.2)
    love.graphics.rectangle("fill", app.x + app.width - 65, app.y + 5, 15, 15)
    
    -- Maximize button
    love.graphics.setColor(0.2, 0.8, 0.2)
    love.graphics.rectangle("fill", app.x + app.width - 45, app.y + 5, 15, 15)
    
    -- Close button
    love.graphics.setColor(0.8, 0.2, 0.2)
    love.graphics.rectangle("fill", app.x + app.width - 25, app.y + 5, 15, 15)
    
    -- Draw resize handle in bottom-right corner
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", app.x + app.width - 15, app.y + app.height - 15, 15, 15)
    
    -- Draw app content
    if name == "terminal" then
        desktop.drawTerminalApp(app, gameState)
    elseif name == "browser" then
        desktop.drawBrowserApp(app, gameState)
    elseif name == "fileExplorer" then
        desktop.drawFileExplorerApp(app, gameState)
    elseif name == "hackingTools" then
        desktop.drawHackingToolsApp(app, gameState)
    elseif name == "textEditor" then
        desktop.drawTextEditorApp(app, gameState)
    end
end

function desktop.drawTerminalApp(app, gameState)
    -- Draw terminal content inside the app window
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", app.x + 5, app.y + 30, app.width - 10, app.height - 35)
    
    -- Get terminal output and display it
    love.graphics.setColor(0, 1, 0)
    local output = terminal.getOutput()
    local lineHeight = 20
    local visibleLines = math.floor((app.height - 60) / lineHeight)
    local startLine = math.max(1, #output - visibleLines + 1)
    
    for i = startLine, #output do
        local line = output[i]
        love.graphics.print(line, app.x + 10, app.y + 35 + (i - startLine) * lineHeight)
    end
    
    -- Draw current command with cursor
    local prompt = terminal.getPrompt()
    local currentCommand = terminal.getCurrentCommand()
    local cursorPos = terminal.getCursorPosition()
    
    love.graphics.print(prompt .. currentCommand, app.x + 10, app.y + app.height - 25)
    
    -- Draw cursor
    if math.floor(love.timer.getTime() * 2) % 2 == 0 then
        local promptWidth = love.graphics.getFont():getWidth(prompt)
        local cmdWidth = love.graphics.getFont():getWidth(currentCommand:sub(1, cursorPos))
        love.graphics.rectangle("fill", app.x + 10 + promptWidth + cmdWidth, 
                               app.y + app.height - 25, 8, 20)
    end
    
    -- When terminal window is active, set focus to it
    if love.mouse.wasPressed(1) then
        local mx, my = love.mouse.getPosition()
        if mx >= app.x and mx <= app.x + app.width and
           my >= app.y + 30 and my <= app.y + app.height then
            gameState.focusedApp = "terminal"
        end
    end
end

function desktop.drawBrowserApp(app, gameState)
    -- Draw browser content inside the app window
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", app.x + 5, app.y + 30, app.width - 10, app.height - 35)
    
    -- Draw address bar
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.rectangle("fill", app.x + 10, app.y + 35, app.width - 20, 25)
    
    -- Draw URL
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(app.url, app.x + 15, app.y + 40)
    
    -- Handle address bar clicks
    if love.mouse.wasPressed(1) then
        local mx, my = love.mouse.getPosition()
        if mx >= app.x + 10 and mx <= app.x + app.width - 20 and
           my >= app.y + 35 and my <= app.y + 60 then
            app.editingURL = true
            app.previousURL = app.url
        else
            app.editingURL = false
        end
    end
    
    -- Draw cursor if editing URL
    if app.editingURL then
        love.graphics.setColor(0, 0, 0)
        local textWidth = love.graphics.getFont():getWidth(app.url)
        love.graphics.rectangle("fill", app.x + 15 + textWidth, app.y + 40, 2, 15)
    end
    
    -- Handle page loading simulation
    if app.loading then
        local currentTime = love.timer.getTime()
        local loadingTime = currentTime - app.loadStartTime
        
        if loadingTime < 3 then
            -- Show loading animation
            love.graphics.setColor(0, 0, 0)
            love.graphics.print("Loading " .. app.url .. " (" .. math.floor(loadingTime/3 * 100) .. "%)", 
                                app.x + 20, app.y + 75)
            
            -- Draw loading bar
            love.graphics.setColor(0.8, 0.8, 0.8)
            love.graphics.rectangle("fill", app.x + 20, app.y + 95, app.width - 40, 20)
            love.graphics.setColor(0.2, 0.6, 1)
            love.graphics.rectangle("fill", app.x + 20, app.y + 95, (app.width - 40) * (loadingTime/3), 20)
            
            return -- Don't show page content while loading
        else
            app.loading = false
        end
    end
    
    -- Display different content based on URL
    if app.url == "www.tesla.com" then
        love.graphics.setColor(0, 0, 0)
        love.graphics.print("Tesla - Electric Cars, Solar & Clean Energy", app.x + 20, app.y + 75)
        love.graphics.print("Model S | Model 3 | Model X | Model Y | Solar Roof", app.x + 20, app.y + 95)
        love.graphics.setColor(0.2, 0.4, 0.8)
        love.graphics.print("Order Now", app.x + 20, app.y + 125)
        love.graphics.print("Learn More", app.x + 20, app.y + 145)
    elseif app.url == "www.spacex.com" then
        love.graphics.setColor(0, 0, 0)
        love.graphics.print("SpaceX - Missions to Mars", app.x + 20, app.y + 75)
        love.graphics.print("Falcon 9 | Falcon Heavy | Dragon | Starship", app.x + 20, app.y + 95)
        love.graphics.setColor(0.8, 0.2, 0.2)
        love.graphics.print("Launch Schedule", app.x + 20, app.y + 125)
        love.graphics.print("Careers", app.x + 20, app.y + 145)
    elseif app.url == "www.starlink.com" then
        love.graphics.setColor(0, 0, 0)
        love.graphics.print("Starlink - High-Speed Internet Access", app.x + 20, app.y + 75)
        love.graphics.print("Global Coverage | Low Latency | Easy Setup", app.x + 20, app.y + 95)
        love.graphics.setColor(0.2, 0.6, 0.8)
        love.graphics.print("Order Now", app.x + 20, app.y + 125)
        love.graphics.print("Check Availability", app.x + 20, app.y + 145)
    elseif app.url == "www.neuralink.com" then
        love.graphics.setColor(0, 0, 0)
        love.graphics.print("Neuralink - Brain-Machine Interfaces", app.x + 20, app.y + 75)
        love.graphics.print("Research | Technology | Applications", app.x + 20, app.y + 95)
        love.graphics.setColor(0.5, 0.3, 0.7)
        love.graphics.print("Learn More", app.x + 20, app.y + 125)
        love.graphics.print("Join Our Team", app.x + 20, app.y + 145)
    elseif app.url == "www.boring.com" then
        love.graphics.setColor(0, 0, 0)
        love.graphics.print("The Boring Company - Tunnels & Infrastructure", app.x + 20, app.y + 75)
        love.graphics.print("Loop | Hyperloop | Tunneling Technology", app.x + 20, app.y + 95)
        love.graphics.setColor(0.7, 0.5, 0.2)
        love.graphics.print("Projects", app.x + 20, app.y + 125)
        love.graphics.print("Not-A-Flamethrower", app.x + 20, app.y + 145)
    else
        love.graphics.setColor(0, 0, 0)
        love.graphics.print("Enter a URL to browse", app.x + 20, app.y + 75)
        love.graphics.print("Try: www.tesla.com, www.starlink.com, www.spacex.com", app.x + 20, app.y + 95)
        love.graphics.print("     www.neuralink.com, www.boring.com", app.x + 20, app.y + 115)
    end
end

function desktop.drawFileExplorerApp(app, gameState)
    -- Draw file explorer content inside the app window
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.rectangle("fill", app.x + 10, app.y + 60, app.width - 20, app.height - 70)
    
    -- Draw toolbar
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.rectangle("fill", app.x + 10, app.y + 30, app.width - 20, 30)
    
    -- Back button
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.rectangle("fill", app.x + 15, app.y + 35, 20, 20)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("<", app.x + 20, app.y + 37)
    
    -- Forward button
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.rectangle("fill", app.x + 40, app.y + 35, 20, 20)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(">", app.x + 45, app.y + 37)
    
    -- Address bar
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", app.x + 65, app.y + 35, app.width - 80, 20)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(app.currentPath or "/home/hacker", app.x + 70, app.y + 37)
    
    -- Initialize lastClickTime and lastClickItem if they don't exist
    app.lastClickTime = app.lastClickTime or 0
    app.lastClickItem = app.lastClickItem or ""
    
    -- Get file listing from filesystem
    local files = {}
    if gameState.filesystem and gameState.filesystem.listDirectory then
        files = gameState.filesystem.listDirectory(gameState.filesystem, app.currentPath)
    else
        files = {"Documents", "Downloads", "Pictures", "secret.txt", "passwords.txt", "hack_notes.txt"}
    end
    
    -- Draw files
    love.graphics.setColor(0, 0, 0)
    for i, item in ipairs(files) do
        local x = app.x + 30 + ((i-1) % 4) * 120
        local y = app.y + 80 + math.floor((i-1) / 4) * 80
        
        -- Determine if it's a folder or file
        local isFolder = not item:match("%.%w+$")
        
        -- Draw icon
        love.graphics.setColor(isFolder and {0.9, 0.7, 0.3} or {0.3, 0.7, 0.9})
        love.graphics.rectangle("fill", x - 10, y, 40, 40)
        
        -- Draw filename
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(item, x - 30, y + 45, 80, "center")
        
        -- Handle clicking on files
        local mx, my = love.mouse.getPosition()
        if love.mouse.wasPressed(1) and
           mx >= x - 10 and mx <= x + 30 and
           my >= y and my <= y + 50 then
        
            -- Check for double click
            local currentTime = love.timer.getTime()
            if currentTime - app.lastClickTime < 0.5 and app.lastClickItem == item then
                -- Double click action
                if isFolder then
                    -- Navigate to folder
                    app.currentPath = app.currentPath .. "/" .. item
                else
                    -- Open text files in the text editor
                    if item:match("%.txt$") then
                        -- Open the text editor
                        apps.textEditor.open = true
                        apps.textEditor.minimized = false
                        apps.textEditor.currentFile = item
                        apps.textEditor.fullPath = app.currentPath .. "/" .. item
                        
                        -- Load file content
                        if gameState.filesystem and gameState.filesystem.readFile then
                            apps.textEditor.content = gameState.filesystem.readFile(gameState.filesystem, app.currentPath .. "/" .. item)
                        else
                            apps.textEditor.content = {"This is the content of " .. item}
                        end
                        
                        -- Set as read-only by default
                        apps.textEditor.readOnly = true
                        
                        -- Initialize cursor position
                        apps.textEditor.cursorLine = 1
                        apps.textEditor.cursorPos = 0
                    end
                end
            else
                -- Start potential drag operation
                app.dragStartX = mx
                app.dragStartY = my
                app.potentialDragFile = item
            end
        
            app.lastClickTime = currentTime
            app.lastClickItem = item
        end
    end
    
    -- Draw file content popup if viewing a file
    if app.viewingFile then
        love.graphics.setColor(1, 1, 1, 0.95)
        love.graphics.rectangle("fill", app.x + 50, app.y + 100, app.width - 100, app.height - 150)
        
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(app.viewingFile, app.x + 60, app.y + 110)
        
        love.graphics.line(app.x + 60, app.y + 130, app.x + app.width - 60, app.y + 130)
        
        -- Draw file content
        if app.fileContent then
            for i, line in ipairs(app.fileContent) do
                love.graphics.print(line, app.x + 60, app.y + 140 + (i-1) * 20)
            end
        end
        
        -- Close button
        love.graphics.setColor(0.8, 0.2, 0.2)
        love.graphics.rectangle("fill", app.x + app.width - 80, app.y + 110, 20, 20)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("X", app.x + app.width - 75, app.y + 112)
        
        -- Handle close button click
        local mx, my = love.mouse.getPosition()
        if love.mouse.wasPressed(1) and
           mx >= app.x + app.width - 80 and mx <= app.x + app.width - 60 and
           my >= app.y + 110 and my <= app.y + 130 then
            app.viewingFile = nil
            app.fileContent = nil
        end
    end
    
    -- Draw dragged file if active
    if draggedFile.active then
        love.graphics.setColor(0.8, 0.8, 0.8, 0.8)
        love.graphics.rectangle("fill", draggedFile.x - 20, draggedFile.y - 10, 40, 40)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(draggedFile.file, draggedFile.x - 40, draggedFile.y + 35, 80, "center")
    end
    
    -- Draw context menu if visible
    if contextMenu.visible then
        -- Draw background
        love.graphics.setColor(0.2, 0.2, 0.2, 0.9)
        love.graphics.rectangle("fill", contextMenu.x, contextMenu.y, contextMenu.width, contextMenu.height)
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.rectangle("line", contextMenu.x, contextMenu.y, contextMenu.width, contextMenu.height)
        
        -- Draw options
        love.graphics.setColor(1, 1, 1)
        for i, option in ipairs(contextMenu.options) do
            local optionY = contextMenu.y + (i-1) * 30 + 5
            
            -- Highlight on hover
            local mx, my = love.mouse.getPosition()
            if mx >= contextMenu.x and mx <= contextMenu.x + contextMenu.width and
               my >= optionY and my <= optionY + 25 then
                love.graphics.setColor(0.3, 0.3, 0.5)
                love.graphics.rectangle("fill", contextMenu.x + 2, optionY, contextMenu.width - 4, 25)
                love.graphics.setColor(1, 1, 1)
                
                -- Handle click on option
                if love.mouse.wasPressed(1) then
                    desktop.handleContextMenuOption(option, gameState)
                    contextMenu.visible = false
                end
            end
            
            love.graphics.print(option, contextMenu.x + 10, optionY + 5)
        end
    end
end

function desktop.drawHackingToolsApp(app, gameState)
    -- Draw hacking tools content inside the app window
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", app.x + 10, app.y + 35, app.width - 20, app.height - 45)
    
    local tools = {
        {name = "Network Scanner", description = "Scan networks for vulnerabilities", command = "nmap"},
        {name = "Password Cracker", description = "Brute force password attacks", command = "brute-force"},
        {name = "SQL Injector", description = "Exploit database vulnerabilities", command = "sqlinject"},
        {name = "DDoS Tool", description = "Distributed denial of service attacks", command = "ddos"},
        {name = "Traffic Redirector", description = "Redirect network traffic", command = "redirect"},
        {name = "SSH Client", description = "Secure shell connections", command = "ssh"},
        {name = "File Uploader", description = "Upload files to remote servers", command = "upload"},
        {name = "Authentication Bypass", description = "Bypass security systems", command = "bypass"}
    }
    
    love.graphics.setColor(0, 1, 0)
    love.graphics.print("AVAILABLE HACKING TOOLS", app.x + 20, app.y + 45)
    
    for i, tool in ipairs(tools) do
        local y = app.y + 70 + (i-1) * 40
        
        -- Highlight on hover
        local mx, my = love.mouse.getPosition()
        if mx >= app.x + 15 and mx <= app.x + app.width - 25 and
           my >= y and my <= y + 35 then
            love.graphics.setColor(0.2, 0.2, 0.2)
            love.graphics.rectangle("fill", app.x + 15, y, app.width - 30, 35)
            
            -- Launch tool if clicked
            if love.mouse.wasPressed(1) then
                gameState.currentScreen = "terminal"
                -- Add command to terminal
                if terminal and terminal.addToOutput then
                    terminal.addToOutput("Launching " .. tool.name .. "...")
                    terminal.setCurrentCommand(tool.command .. " ")
                end
            end
        end
        
        love.graphics.setColor(0, 1, 0)
        love.graphics.print(tool.name, app.x + 20, y + 5)
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.print(tool.description, app.x + 20, y + 20)
    end
end

function desktop.textInput(text)
    for name, app in pairs(apps) do
        if app.open then
            if name == "terminal" and app == apps.terminal then
                -- Pass text input to terminal
                terminal.handleTextInput(text)
            elseif name == "browser" and app.editingURL then
                -- Add text to browser URL
                app.url = app.url .. text
            elseif name == "fileExplorer" and app.editingPath then
                -- Add text to file explorer path
                app.currentPath = app.currentPath .. text
            end
        end
    end
end

-- Add this function to handle keyboard events
function desktop.keyPressed(key, gameState)
    -- Handle keyboard events for open apps
    for name, app in pairs(apps) do
        if app.open and not app.minimized then
            if name == "terminal" then
                -- Pass keyboard events to terminal
                terminal.keyPressed(key, gameState)
                return -- Add this to prevent multiple processing
            elseif name == "browser" and app.editingURL then
                -- Handle URL editing
                if key == "return" or key == "kpenter" then
                    app.editingURL = false
                    -- Simulate page loading
                    app.loading = true
                    app.loadStartTime = love.timer.getTime()
                elseif key == "escape" then
                    app.editingURL = false
                    app.url = app.previousURL or "about:blank"
                elseif key == "backspace" then
                    -- Only remove the last character, not the whole URL
                    app.url = app.url:sub(1, -2)
                end
                return -- Add this to prevent multiple processing
            elseif name == "fileExplorer" and app.editingPath then
                -- Handle path editing
                if key == "return" or key == "kpenter" then
                    app.editingPath = false
                elseif key == "escape" then
                    app.editingPath = false
                    app.currentPath = app.previousPath or "/home/hacker"
                elseif key == "backspace" then
                    -- Only remove the last character
                    app.currentPath = app.currentPath:sub(1, -2)
                end
                return -- Add this to prevent multiple processing
            elseif name == "textEditor" and not app.readOnly then
                -- Handle text editor keyboard input
                if key == "backspace" then
                    local line = app.content[app.cursorLine] or ""
                    if app.cursorPos > 0 then
                        -- Remove character before cursor
                        app.content[app.cursorLine] = line:sub(1, app.cursorPos - 1) .. line:sub(app.cursorPos + 1)
                        app.cursorPos = app.cursorPos - 1
                    elseif app.cursorLine > 1 then
                        -- Join with previous line
                        local prevLine = app.content[app.cursorLine - 1] or ""
                        app.cursorPos = #prevLine
                        app.content[app.cursorLine - 1] = prevLine .. line
                        table.remove(app.content, app.cursorLine)
                        app.cursorLine = app.cursorLine - 1
                    end
                elseif key == "return" or key == "kpenter" then
                    -- Split line at cursor
                    local line = app.content[app.cursorLine] or ""
                    local before = line:sub(1, app.cursorPos)
                    local after = line:sub(app.cursorPos + 1)
                    app.content[app.cursorLine] = before
                    table.insert(app.content, app.cursorLine + 1, after)
                    app.cursorLine = app.cursorLine + 1
                    app.cursorPos = 0
                elseif key == "left" then
                    -- Move cursor left
                    if app.cursorPos > 0 then
                        app.cursorPos = app.cursorPos - 1
                    elseif app.cursorLine > 1 then
                        app.cursorLine = app.cursorLine - 1
                        app.cursorPos = #(app.content[app.cursorLine] or "")
                    end
                elseif key == "right" then
                    -- Move cursor right
                    local line = app.content[app.cursorLine] or ""
                    if app.cursorPos < #line then
                        app.cursorPos = app.cursorPos + 1
                    elseif app.cursorLine < #app.content then
                        app.cursorLine = app.cursorLine + 1
                        app.cursorPos = 0
                    end
                elseif key == "up" and app.cursorLine > 1 then
                    -- Move cursor up
                    app.cursorLine = app.cursorLine - 1
                    local line = app.content[app.cursorLine] or ""
                    app.cursorPos = math.min(app.cursorPos, #line)
                elseif key == "down" and app.cursorLine < #app.content then
                    -- Move cursor down
                    app.cursorLine = app.cursorLine + 1
                    local line = app.content[app.cursorLine] or ""
                    app.cursorPos = math.min(app.cursorPos, #line)
                elseif key == "home" then
                    -- Move cursor to start of line
                    app.cursorPos = 0
                elseif key == "end" then
                    -- Move cursor to end of line
                    local line = app.content[app.cursorLine] or ""
                    app.cursorPos = #line
                elseif key == "s" and love.keyboard.isDown("lctrl", "rctrl") then
                    -- Save file
                    if gameState.filesystem and gameState.filesystem.writeFile then
                        gameState.filesystem.writeFile(gameState.filesystem, app.fullPath, app.content)
                        app.saveMessage = "File saved"
                        app.saveMessageTime = love.timer.getTime()
                    end
                elseif key == "e" and love.keyboard.isDown("lctrl", "rctrl") then
                    -- Toggle edit mode
                    app.readOnly = not app.readOnly
                end
                return
            end
        end
    end
end

-- Add this function to handle text input
function desktop.handleTextInput(text, gameState)
    for name, app in pairs(apps) do
        if app.open and not app.minimized then
            if name == "terminal" then
                terminal.handleTextInput(text)
                return -- Prevent multiple processing
            elseif name == "browser" and app.editingURL then
                app.url = app.url .. text
                return -- Prevent multiple processing
            elseif name == "fileExplorer" and app.editingPath then
                app.currentPath = app.currentPath .. text
                return -- Prevent multiple processing
            elseif name == "textEditor" and not app.readOnly then
                -- Insert text at cursor position
                local line = app.content[app.cursorLine] or ""
                app.content[app.cursorLine] = line:sub(1, app.cursorPos) .. text .. line:sub(app.cursorPos + 1)
                app.cursorPos = app.cursorPos + #text
                return -- Prevent multiple processing
            end
        end
    end
end

-- Update the mouse handling to ensure it works
function desktop.mousepressed(x, y, button, gameState)
    if button ~= 1 then return end -- Only handle left clicks
    
    -- Check if clicking on start button
    local startButtonY = love.graphics.getHeight() - 35
    if x >= 10 and x <= 40 and y >= startButtonY and y <= startButtonY + 30 then
        startMenuOpen = not startMenuOpen
        return
    end
    
    -- Close start menu if clicking elsewhere when it's open
    if startMenuOpen and not (x >= 0 and x <= 200 and y >= love.graphics.getHeight() - 300 and y <= love.graphics.getHeight() - 40) then
        startMenuOpen = false
    end
    
    -- Check start menu items if open
    if startMenuOpen then
        local menuItems = {"Terminal", "Browser", "File Explorer", "Hacking Tools", "Log Out"}
        for i, item in ipairs(menuItems) do
            local itemY = love.graphics.getHeight() - 300 + (i-1) * 40
            if x >= 10 and x <= 190 and y >= itemY and y <= itemY + 30 then
                if item == "Log Out" then
                    gameState.currentScreen = "terminal"
                else
                    local appName = item:lower():gsub(" ", "")
                    if apps[appName] then
                        apps[appName].open = true
                        apps[appName].minimized = false
                    end
                end
                startMenuOpen = false
                return
            end
        end
    end
    
    -- Check desktop icons
    for _, icon in ipairs(desktopIcons) do
        if x >= icon.x and x <= icon.x + 40 and y >= icon.y and y <= icon.y + 60 then
            apps[icon.app].open = true
            apps[icon.app].minimized = false
            return
        end
    end
    
    -- Check taskbar icons for minimized apps
    local taskbarIconX = 100
    for name, app in pairs(apps) do
        if app.open then
            if x >= taskbarIconX and x <= taskbarIconX + 30 and y >= love.graphics.getHeight() - 35 and y <= love.graphics.getHeight() - 5 then
                app.minimized = not app.minimized
                return
            end
            taskbarIconX = taskbarIconX + 40
        end
    end
    
    -- Check window controls for open apps
    for name, app in pairs(apps) do
        if app.open and not app.minimized then
            -- Check if clicking on title bar (for dragging)
            if x >= app.x and x <= app.x + app.width and y >= app.y and y <= app.y + 25 then
                -- Check close button
                if x >= app.x + app.width - 25 and x <= app.x + app.width - 10 and y >= app.y + 5 and y <= app.y + 20 then
                    app.open = false
                    return
                end
                
                -- Check minimize button
                if x >= app.x + app.width - 45 and x <= app.x + app.width - 30 and y >= app.y + 5 and y <= app.y + 20 then
                    app.minimized = true
                    return
                end
                
                -- Check maximize button
                if x >= app.x + app.width - 65 and x <= app.x + app.width - 50 and y >= app.y + 5 and y <= app.y + 20 then
                    -- Toggle maximize
                    if app.maximized then
                        app.x = app.prevX
                        app.y = app.prevY
                        app.width = app.prevWidth
                        app.height = app.prevHeight
                        app.maximized = false
                    else
                        app.prevX = app.x
                        app.prevY = app.y
                        app.prevWidth = app.width
                        app.prevHeight = app.height
                        app.x = 0
                        app.y = 0
                        app.width = love.graphics.getWidth()
                        app.height = love.graphics.getHeight() - 40
                        app.maximized = true
                    end
                    return
                end
                
                -- Start dragging window
                draggingWindow = name
                dragOffsetX = x - app.x
                dragOffsetY = y - app.y
                return
            end
            
            -- Check resize handle
            if x >= app.x + app.width - 15 and x <= app.x + app.width and 
               y >= app.y + app.height - 15 and y <= app.y + app.height then
                resizingWindow = name
                return
            end
            
            -- App-specific click handling
            if name == "browser" then
                -- Handle URL bar clicks
                if x >= app.x + 65 and x <= app.x + app.width - 15 and 
                   y >= app.y + 35 and y <= app.y + 55 then
                    app.editingURL = true
                    app.previousURL = app.url
                    return
                end
            elseif name == "fileExplorer" then
                -- Handle path bar clicks
                if x >= app.x + 65 and x <= app.x + app.width - 15 and 
                   y >= app.y + 35 and y <= app.y + 55 then
                    app.editingPath = true
                    app.previousPath = app.currentPath
                    return
                end
                
                -- Handle file clicks
                local files = gameState.filesystem.listDirectory(gameState.filesystem, app.currentPath)
                local fileY = app.y + 70
                for _, file in ipairs(files) do
                    if x >= app.x + 20 and x <= app.x + app.width - 20 and 
                       y >= fileY and y <= fileY + 20 then
                        -- Double-click detection
                        local currentTime = love.timer.getTime()
                        if app.lastClickItem == file and currentTime - app.lastClickTime < 0.5 then
                            -- Double click - open file or change directory
                            if gameState.filesystem.isDirectory(gameState.filesystem, app.currentPath .. "/" .. file) then
                                app.currentPath = app.currentPath .. "/" .. file
                            else
                                -- Open text files in the text editor
                                if file:match("%.txt$") then
                                    -- Open the text editor
                                    apps.textEditor.open = true
                                    apps.textEditor.minimized = false
                                    apps.textEditor.currentFile = file
                                    apps.textEditor.fullPath = app.currentPath .. "/" .. file
                                    
                                    -- Load file content
                                    if gameState.filesystem and gameState.filesystem.readFile then
                                        apps.textEditor.content = gameState.filesystem.readFile(gameState.filesystem, app.currentPath .. "/" .. file)
                                    else
                                        apps.textEditor.content = {"This is the content of " .. file}
                                    end
                                    
                                    -- Set as read-only by default
                                    apps.textEditor.readOnly = true
                                    
                                    -- Initialize cursor position
                                    apps.textEditor.cursorLine = 1
                                    apps.textEditor.cursorPos = 0
                                else
                                    -- For non-text files, show content in terminal
                                    terminal.addToOutput("Opening file: " .. app.currentPath .. "/" .. file)
                                    local content = gameState.filesystem.readFile(gameState.filesystem, app.currentPath .. "/" .. file)
                                    for _, line in ipairs(content) do
                                        terminal.addToOutput(line)
                                    end
                                end
                            end
                        end
                        app.lastClickItem = file
                        app.lastClickTime = currentTime
                        return
                    end
                    fileY = fileY + 25
                end
            elseif name == "textEditor" then
                -- Handle clicks in the text editor
                if x >= app.x + 10 and x <= app.x + app.width - 10 and
                   y >= app.y + 65 and y <= app.y + app.height - 10 then
                    -- Calculate cursor position from click
                    local lineHeight = 20
                    local clickLine = math.floor((y - (app.y + 70)) / lineHeight) + 1
                    
                    if clickLine >= 1 and clickLine <= #app.content then
                        app.cursorLine = clickLine
                        
                        -- Calculate horizontal cursor position
                        local line = app.content[clickLine]
                        local font = love.graphics.getFont()
                        local clickX = x - (app.x + 15)
                        
                        -- Find closest character position
                        local bestPos = 0
                        local bestDist = math.huge
                        
                        for i = 0, #line do
                            local width = font:getWidth(line:sub(1, i))
                            local dist = math.abs(width - clickX)
                            if dist < bestDist then
                                bestDist = dist
                                bestPos = i
                            end
                        end
                        
                        app.cursorPos = bestPos
                    end
                end
                
                -- Toggle edit mode with button in toolbar
                if x >= app.x + app.width - 100 and x <= app.x + app.width - 20 and
                   y >= app.y + 40 and y <= app.y + 60 then
                    app.readOnly = not app.readOnly
                end
            end
        end
    end
end

-- Connect the desktop.mousepressed function to the main.lua
function desktop.handleMousePressed(x, y, button, gameState)
    desktop.mousepressed(x, y, button, gameState)
end

-- Add text editor drawing function
function desktop.drawTextEditorApp(app, gameState)
    -- Draw text editor content inside the app window
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", app.x + 10, app.y + 35, app.width - 20, app.height - 45)
    
    -- Draw toolbar
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.rectangle("fill", app.x + 10, app.y + 35, app.width - 20, 25)
    
    -- Draw file name in toolbar
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(app.currentFile or "Untitled", app.x + 15, app.y + 40)
    
    -- Draw read-only indicator if applicable
    if app.readOnly then
        love.graphics.setColor(0.7, 0.2, 0.2)
        love.graphics.print("[Read Only]", app.x + app.width - 100, app.y + 40)
    end
    
    -- Draw content area
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", app.x + 10, app.y + 65, app.width - 20, app.height - 75)
    
    -- Draw text content
    love.graphics.setColor(0, 0, 0)
    if app.content then
        for i, line in ipairs(app.content) do
            love.graphics.print(line, app.x + 15, app.y + 70 + (i-1) * 20)
        end
    end
    
    -- Draw cursor if not in read-only mode
    if not app.readOnly and math.floor(love.timer.getTime() * 2) % 2 == 0 then
        local cursorLine = app.cursorLine or 1
        local cursorPos = app.cursorPos or 0
        
        -- Calculate cursor position
        local lineText = app.content[cursorLine] or ""
        local textWidth = 0
        if cursorPos > 0 then
            textWidth = love.graphics.getFont():getWidth(lineText:sub(1, cursorPos))
        end
        
        love.graphics.rectangle("fill", app.x + 15 + textWidth, app.y + 70 + (cursorLine-1) * 20, 2, 20)
    end
end

function desktop.handleContextMenuOption(option, gameState)
    local fullPath = contextMenu.targetPath .. "/" .. contextMenu.targetFile
    
    if option == "Copy" then
        clipboard.operation = "copy"
        clipboard.file = contextMenu.targetFile
        clipboard.path = contextMenu.targetPath
    elseif option == "Cut" then
        clipboard.operation = "cut"
        clipboard.file = contextMenu.targetFile
        clipboard.path = contextMenu.targetPath
    elseif option == "Paste" then
        if clipboard.operation and clipboard.file ~= "" then
            if clipboard.operation == "copy" then
                if gameState.filesystem.copyFile then
                    gameState.filesystem.copyFile(
                        gameState.filesystem,
                        clipboard.path .. "/" .. clipboard.file,
                        contextMenu.targetPath .. "/" .. clipboard.file
                    )
                end
            elseif clipboard.operation == "cut" then
                if gameState.filesystem.moveFile then
                    gameState.filesystem.moveFile(
                        gameState.filesystem,
                        clipboard.path .. "/" .. clipboard.file,
                        contextMenu.targetPath .. "/" .. clipboard.file
                    )
                    -- Clear clipboard after move
                    clipboard.operation = nil
                    clipboard.file = ""
                    clipboard.path = ""
                end
            end
        end
    elseif option == "Rename" then
        -- Set up rename mode for the file
        apps.fileExplorer.renamingFile = contextMenu.targetFile
        apps.fileExplorer.newFileName = contextMenu.targetFile
    elseif option == "Delete" then
        if gameState.filesystem.deleteFile then
            gameState.filesystem.deleteFile(gameState.filesystem, fullPath)
        end
    end
end

function desktop.handleMousePressed(x, y, button, gameState)
    -- Existing mouse handling code...
    
    -- Handle right-click in file explorer
    if button == 2 then
        for name, app in pairs(apps) do
            if name == "fileExplorer" and app.open and not app.minimized then
                -- Check if right-click is within the file explorer window
                if x >= app.x and x <= app.x + app.width and
                   y >= app.y and y <= app.y + app.height then
                    
                    -- Check if right-click is on a file or folder
                    local files = gameState.filesystem.listDirectory(gameState.filesystem, app.currentPath)
                    local fileY = app.y + 70
                    
                    for _, file in ipairs(files) do
                        local fileX = app.x + 20
                        if x >= fileX - 10 and x <= fileX + 50 and
                           y >= fileY and y <= fileY + 50 then
                            -- Show context menu
                            contextMenu.visible = true
                            contextMenu.x = x
                            contextMenu.y = y
                            contextMenu.targetFile = file
                            contextMenu.targetPath = app.currentPath
                            return
                        end
                        fileY = fileY + 80
                    end
                    
                    -- Right-click on empty space in file explorer
                    contextMenu.visible = true
                    contextMenu.x = x
                    contextMenu.y = y
                    contextMenu.targetFile = ""
                    contextMenu.targetPath = app.currentPath
                    -- Only show paste option for empty space
                    contextMenu.options = {"Paste"}
                    return
                end
            end
        end
    end
    
    -- Handle file dragging in file explorer
    if button == 1 then
        for name, app in pairs(apps) do
            if name == "fileExplorer" and app.open and not app.minimized then
                -- Check if click is on a file
                local files = gameState.filesystem.listDirectory(gameState.filesystem, app.currentPath)
                local fileY = app.y + 70
                
                for _, file in ipairs(files) do
                    local fileX = app.x + 20
                    if x >= fileX - 10 and x <= fileX + 50 and
                       y >= fileY and y <= fileY + 50 then
                        -- Start drag operation
                        app.dragStartX = x
                        app.dragStartY = y
                        app.potentialDragFile = file
                        return
                    end
                    fileY = fileY + 80
                end
            end
        end
    end
end

function desktop.handleMouseReleased(x, y, button, gameState)
    -- Check if we were potentially dragging a file
    for name, app in pairs(apps) do
        if name == "fileExplorer" and app.potentialDragFile then
            local dragDistance = math.sqrt((x - app.dragStartX)^2 + (y - app.dragStartY)^2)
            
            -- If dragged more than a few pixels, consider it a drag operation
            if dragDistance > 5 then
                draggedFile.active = true
                draggedFile.file = app.potentialDragFile
                draggedFile.sourcePath = app.currentPath
                draggedFile.x = x
                draggedFile.y = y
            end
            
            app.potentialDragFile = nil
            app.dragStartX = nil
            app.dragStartY = nil
        end
    end
end

return desktop






































