local terminal = {}

local commandHistory = {}
local currentCommand = ""
local cursorPosition = 0
local prompt = "hacker@infiltrator:~$ "
local terminalOutput = {"ZH:OM Welcome to DOGE Linux ver 4.20!"}

-- Add this function to handle text input from main.lua
function terminal.handleTextInput(text)
    currentCommand = currentCommand:sub(1, cursorPosition) .. text .. currentCommand:sub(cursorPosition + 1)
    cursorPosition = cursorPosition + 1
end

local commands = {
    ls = function(args, gameState) 
        -- Visual effect: list files with animation
        love.graphics.setColor(0.5, 1, 0.5)
        local path = args[1] or gameState.filesystem.currentPath
        return gameState.filesystem.listDirectory(gameState.filesystem, path)
    end,
    cd = function(args, gameState)
        -- Visual effect: directory change animation
        love.graphics.setColor(0.7, 0.7, 1)
        local path = args[1] or "~"
        return gameState.filesystem.changeDirectory(gameState.filesystem, path)
    end,
    cat = function(args, gameState)
        -- Visual effect: text reveal animation
        love.graphics.setColor(1, 1, 0.7)
        if not args[1] then return {"Error: No file specified"} end
        return gameState.filesystem.readFile(gameState.filesystem, args[1])
    end,
    startx = function(args, gameState)
        -- Visual effect: boot animation
        love.graphics.setColor(0, 1, 0)
        gameState.currentScreen = "desktop"
        return {"Starting X Window System..."}
    end,
    help = function(args, gameState)
        -- Visual effect: help menu animation
        love.graphics.setColor(0, 1, 1)
        local result = {
            "Available commands:",
            "ls - List directory contents",
            "cd - Change directory",
            "cat - Display file contents",
            "startx - Start graphical desktop",
            "brute-force - Attempt to crack passwords",
            "sqlinject - Perform SQL injection attack",
            "ddos - Simulate DDoS attack",
            "nmap - Scan network for vulnerabilities",
            "ssh - Connect to remote server",
            "upload - Upload files to remote server",
            "scan - Scan for wireless networks",
            "bypass - Bypass authentication systems",
            "redirect - Redirect network traffic",
            "connect - Connect to a network",
            "firewall-exploit - Exploit firewall vulnerabilities",
            "edit - Edit files on remote systems",
            "apt-get - Package manager (install|update|list)",
            "help - Display this help message"
        }
        
        -- Add installed packages to help
        if gameState.installedPackages then
            table.insert(result, "")
            table.insert(result, "Installed packages:")
            for pkg, info in pairs(gameState.installedPackages) do
                table.insert(result, pkg .. " - " .. info.description)
            end
        end
        
        return result
    end,
    ["brute-force"] = function(args, gameState)
        -- Visual effect: password cracking animation
        love.graphics.setColor(1, 0, 0)
        if not args[1] then return {"Error: Target required"} end
        return {"Brute forcing " .. args[1] .. "...", 
                "Testing common passwords...",
                "Testing dictionary words...",
                "Success! Password cracked."}
    end,
    sqlinject = function(args, gameState)
        -- Visual effect: database injection animation
        love.graphics.setColor(1, 0.5, 0)
        if not args[1] then return {"Error: Target required"} end
        return {"Injecting SQL into " .. args[1] .. "...",
                "Bypassing input validation...",
                "Executing malicious query...",
                "Database compromised! Access granted."}
    end,
    ddos = function(args, gameState)
        -- Visual effect: network flood animation
        love.graphics.setColor(1, 0, 0.5)
        if not args[1] then return {"Error: Target required"} end
        return {"Launching DDoS attack against " .. args[1] .. "...",
                "Sending packets from zombie network...",
                "Target is experiencing heavy load...",
                "Success! Target server is down."}
    end,
    nmap = function(args, gameState)
        -- Visual effect: port scanning animation
        love.graphics.setColor(0.5, 0.5, 1)
        if not args[1] then return {"Error: Target required"} end
        return {"Scanning " .. args[1] .. " for open ports...",
                "Discovered open ports: 22, 80, 443, 3306",
                "Scan complete."}
    end,
    ssh = function(args, gameState)
        -- Visual effect: connection animation
        love.graphics.setColor(0, 0.8, 0)
        if not args[1] then return {"Error: Target required"} end
        return {"Connecting to " .. args[1] .. " via SSH...",
                "Authentication successful.",
                "Connected to remote server."}
    end,
    upload = function(args, gameState)
        -- Visual effect: upload progress animation
        love.graphics.setColor(0.8, 0.8, 0)
        if not args[1] or not args[2] then return {"Error: Usage: upload <file> <destination>"} end
        return {"Uploading " .. args[1] .. " to " .. args[2] .. "...",
                "Upload complete.",
                "File executed on remote server."}
    end,
    scan = function(args, gameState)
        -- Visual effect: scanning animation
        love.graphics.setColor(0, 0.7, 0.7)
        return {"Scanning for networks...",
                "Found networks: Home_WiFi, Corporate_Secure, Guest",
                "Scan complete."}
    end,
    bypass = function(args, gameState)
        -- Visual effect: bypass animation
        love.graphics.setColor(1, 0.3, 0.3)
        if not args[1] then return {"Error: Target required"} end
        return {"Attempting to bypass " .. args[1] .. "...",
                "Exploiting security flaws...",
                "Bypass successful!"}
    end,
    redirect = function(args, gameState)
        -- Visual effect: traffic redirection animation
        love.graphics.setColor(0.3, 0.3, 1)
        if not args[1] then return {"Error: Target required"} end
        return {"Redirecting " .. args[1] .. "...",
                "Traffic now flowing through your proxy.",
                "Redirection complete."}
    end,
    connect = function(args, gameState)
        -- Visual effect: connection animation
        love.graphics.setColor(0.5, 1, 0.5)
        if not args[1] then return {"Error: Target required"} end
        return {"Connecting to " .. args[1] .. "...",
                "Connection established."}
    end,
    ["firewall-exploit"] = function(args, gameState)
        -- Visual effect: firewall breach animation
        love.graphics.setColor(1, 0.1, 0.1)
        if not args[1] then return {"Error: Target required"} end
        return {"Exploiting firewall vulnerabilities in " .. args[1] .. "...",
                "Firewall rules bypassed.",
                "You now have unrestricted access."}
    end,
    edit = function(args, gameState)
        -- Visual effect: file editing animation
        love.graphics.setColor(1, 1, 0.5)
        if not args[1] then return {"Error: File required"} end
        return {"Editing " .. args[1] .. "...",
                "Changes saved.",
                "File modified successfully."}
    end
}

-- Add to the commands table
commands["apt-get"] = function(args, gameState)
    -- Visual effect: package installation animation
    love.graphics.setColor(0.3, 0.8, 1)
    
    if not args[1] then 
        return {"Usage: apt-get [install|update|list] [package]"} 
    end
    
    if args[1] == "install" then
        if not args[2] then
            return {"Error: No package specified"}
        end
        
        local package = args[2]
        local packages = {
            ["keylogger"] = {
                description = "Records keystrokes on target systems",
                installed = false
            },
            ["rootkit"] = {
                description = "Provides persistent backdoor access",
                installed = false
            },
            ["packet-sniffer"] = {
                description = "Captures and analyzes network traffic",
                installed = false
            },
            ["ransomware"] = {
                description = "Encrypts target files for ransom",
                installed = false
            },
            ["phishing-kit"] = {
                description = "Creates convincing fake login pages",
                installed = false
            },
            ["crypto-miner"] = {
                description = "Mines cryptocurrency on target systems",
                installed = false
            },
            ["vpn-tunnel"] = {
                description = "Creates encrypted connection to hide activity",
                installed = false
            },
            ["port-scanner"] = {
                description = "Advanced port scanning with stealth options",
                installed = false
            },
            ["wifi-cracker"] = {
                description = "Breaks WPA/WPA2 encryption on wireless networks",
                installed = false
            },
            ["data-exfiltrator"] = {
                description = "Secretly extracts data from target systems",
                installed = false
            },
            -- Add special hidden packages
            ["brain-interface"] = {
                description = "Neural network hacking tool for brain-computer interfaces",
                installed = false,
                special = true,
                hiddenMission = "neuralink_breach"
            },
            ["geo-mapper"] = {
                description = "Infrastructure mapping and control system",
                installed = false,
                special = true,
                hiddenMission = "boring_company"
            },
            ["crypto-hijacker"] = {
                description = "Cryptocurrency wallet access and manipulation tool",
                installed = false,
                special = true,
                hiddenMission = "doge_heist"
            }
        }
        
        if packages[package] then
            if not gameState.installedPackages then
                gameState.installedPackages = {}
            end
            
            if gameState.installedPackages[package] then
                return {"Package '" .. package .. "' is already installed"}
            end
            
            -- Simulate installation process
            local result = {
                "Reading package lists... Done",
                "Building dependency tree... Done",
                "The following NEW packages will be installed:",
                "  " .. package,
                "0 upgraded, 1 newly installed, 0 to remove and 0 not upgraded.",
                "Need to get 2,845 kB of archives.",
                "After this operation, 8,456 kB of additional disk space will be used.",
                "Get:1 http://security.ubuntu.com/ubuntu " .. package .. " [2,845 kB]",
                "Fetched 2,845 kB in 2s (1,422 kB/s)",
                "Selecting previously unselected package " .. package .. ".",
                "Preparing to unpack .../archives/" .. package .. ".deb ...",
                "Unpacking " .. package .. " ...",
                "Setting up " .. package .. " ...",
                "Processing triggers for man-db ...",
                "Package '" .. package .. "' installed successfully."
            }
            
            -- Register the package as installed
            gameState.installedPackages[package] = packages[package]
            
            -- Add the new command to the commands table if it doesn't exist
            if not commands[package] then
                commands[package] = function(cmdArgs, state)
                    love.graphics.setColor(1, 0.4, 0.7)
                    if not cmdArgs[1] then return {"Error: Target required"} end
                    return {"Running " .. package .. " on " .. cmdArgs[1] .. "...",
                            "Operation successful. Target compromised."}
                end
            end
            
            return result
        else
            return {"E: Unable to locate package " .. package}
        end
    elseif args[1] == "update" then
        return {
            "Get:1 http://security.ubuntu.com/ubuntu focal InRelease [265 kB]",
            "Get:2 http://security.ubuntu.com/ubuntu focal-security InRelease [114 kB]",
            "Get:3 http://security.ubuntu.com/ubuntu focal-updates InRelease [114 kB]",
            "Reading package lists... Done",
            "Building dependency tree... Done",
            "All packages are up to date."
        }
    elseif args[1] == "list" then
        if not gameState.installedPackages then
            gameState.installedPackages = {}
        end
        
        local result = {"Available packages:"}
        local packages = {
            "keylogger", "rootkit", "packet-sniffer", "ransomware", 
            "phishing-kit", "crypto-miner", "vpn-tunnel", "port-scanner", 
            "wifi-cracker", "data-exfiltrator"
        }
        
        for _, pkg in ipairs(packages) do
            local status = gameState.installedPackages[pkg] and "[installed]" or "[available]"
            table.insert(result, "  " .. pkg .. " " .. status)
        end
        
        return result
    else
        return {"Unknown apt-get command: " .. args[1],
                "Usage: apt-get [install|update|list] [package]"}
    end
end

function terminal.update(dt, gameState)
    -- Terminal update logic
    -- No keyboard handling here - it's now in keyPressed function
end

-- Add this helper function for text wrapping
function terminal.wrapText(text, maxWidth)
    -- Improved text wrapping for better readability
    local lines = {}
    
    -- Split text by newlines first
    for line in text:gmatch("([^\n]*)\n?") do
        if line ~= "" then
            table.insert(lines, line)
        end
    end
    
    return lines
end

function terminal.draw(gameState)
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.setColor(0, 1, 0)
    
    local font = love.graphics.getFont()
    local lineHeight = 20
    local maxLines = math.floor((love.graphics.getHeight() - 30) / lineHeight)
    local maxWidth = love.graphics.getWidth() - 20  -- Maximum width for text wrapping
    
    -- Process terminal output with text wrapping
    local wrappedOutput = {}
    for _, line in ipairs(terminalOutput) do
        local wrappedLines = terminal.wrapText(line, maxWidth)
        for _, wrappedLine in ipairs(wrappedLines) do
            table.insert(wrappedOutput, wrappedLine)
        end
    end
    
    -- Calculate which lines to display (implement scrolling)
    local startLine = math.max(1, #wrappedOutput - maxLines + 1)
    local displayLines = {}
    
    for i = startLine, #wrappedOutput do
        table.insert(displayLines, wrappedOutput[i])
    end
    
    -- Draw terminal output
    for i, line in ipairs(displayLines) do
        love.graphics.print(line, 10, 10 + (i-1) * lineHeight)
    end
    
    -- Draw current command line
    love.graphics.print(prompt .. currentCommand, 10, 10 + #displayLines * lineHeight)
    
    -- Draw cursor
    if math.floor(love.timer.getTime() * 2) % 2 == 0 then
        local promptWidth = font:getWidth(prompt)
        local cmdWidth = font:getWidth(currentCommand:sub(1, cursorPosition))
        love.graphics.rectangle("fill", 10 + promptWidth + cmdWidth, 10 + #displayLines * lineHeight, 8, lineHeight)
    end
    
    -- Draw command visual effects (if any)
    if commandEffect then
        commandEffect.draw()
    end
end

function terminal.executeCommand(cmd, gameState)
    -- Parse and execute command
    local parts = {}
    for part in cmd:gmatch("%S+") do
        table.insert(parts, part)
    end
    
    local cmdName = parts[1]
    
    -- Check if command is empty
    if not cmdName then
        return -- Don't do anything for empty commands
    end
    
    table.remove(parts, 1)
    
    if commands[cmdName] then
        local result = commands[cmdName](parts, gameState)
        if type(result) == "table" then
            for _, line in ipairs(result) do
                table.insert(terminalOutput, line)
            end
        elseif result then
            table.insert(terminalOutput, result)
        end
    elseif gameState.installedPackages and gameState.installedPackages[cmdName] then
        -- Execute installed package command
        local result = {"Running " .. cmdName .. "..."}
        if #parts > 0 then
            table.insert(result, "Target: " .. parts[1])
            table.insert(result, gameState.installedPackages[cmdName].description)
            table.insert(result, "Operation completed successfully.")
        else
            table.insert(result, "Error: No target specified")
        end
        
        for _, line in ipairs(result) do
            table.insert(terminalOutput, line)
        end
    else
        table.insert(terminalOutput, "Command not found: " .. cmdName)
    end
end

-- Add these helper functions for desktop integration
function terminal.getOutput()
    return terminalOutput
end

function terminal.getCurrentCommand()
    return currentCommand
end

function terminal.getPrompt()
    return prompt
end

function terminal.getCursorPosition()
    return cursorPosition
end

function terminal.setCurrentCommand(cmd)
    currentCommand = cmd
    cursorPosition = #cmd
end

function terminal.addToOutput(text)
    table.insert(terminalOutput, text)
end

-- Add these functions to handle keyboard events
function terminal.keyPressed(key, gameState)
    if key == "return" or key == "kpenter" then
        -- Execute command
        table.insert(terminalOutput, prompt .. currentCommand)
        
        -- Process command
        terminal.executeCommand(currentCommand, gameState)
        
        -- Add to history and reset
        table.insert(commandHistory, currentCommand)
        currentCommand = ""
        cursorPosition = 0
    elseif key == "backspace" then
        if cursorPosition > 0 then
            currentCommand = currentCommand:sub(1, cursorPosition - 1) .. currentCommand:sub(cursorPosition + 1)
            cursorPosition = cursorPosition - 1
        end
    elseif key == "left" then
        cursorPosition = math.max(0, cursorPosition - 1)
    elseif key == "right" then
        cursorPosition = math.min(#currentCommand, cursorPosition + 1)
    elseif key == "up" then
        -- Navigate command history
        if #commandHistory > 0 then
            currentCommand = commandHistory[#commandHistory]
            cursorPosition = #currentCommand
        end
    elseif key == "down" then
        -- Clear command or go forward in history
        currentCommand = ""
        cursorPosition = 0
    end
end

return terminal

