local filesystem = {}

function filesystem.initialize()
    local fs = {
        currentPath = "/home/hacker",
        
        -- File system structure
        root = {
            bin = {
                bash = "System shell executable",
                ls = "Directory listing utility",
                cat = "File viewing utility",
                cd = "Change directory utility"
            },
            boot = {
                grub = {
                    grub_cfg = "GRUB bootloader configuration",
                    -- Hidden clue in boot configuration
                    ["hidden_modules.conf"] = "# System boot modules\n# DO NOT EDIT UNLESS AUTHORIZED\n\nmodule_blacklist=brain-interface,geo-mapper,crypto-hijacker\n\n# Note from SysAdmin: These modules were blacklisted due to security concerns.\n# If you need these tools, use apt-get install after removing from blacklist."
                }
            },
            etc = {
                passwd = "User account information",
                shadow = "Encrypted password file",
                hosts = "Static table lookup for hostnames",
                -- Hidden clue in apt sources
                ["apt"] = {
                    ["sources.list"] = "# Package repositories\ndeb http://security.ubuntu.com/ubuntu focal main restricted\ndeb http://security.ubuntu.com/ubuntu focal-updates main restricted\n\n# Hidden repository - DO NOT SHARE\n# deb http://blackhat.tools/packages unstable main\n# Access key: 3l0n-mu5k-h4ck3r"
                }
            },
            home = {
                hacker = {
                    -- User home directory content
                    Documents = {
                        missions = {
                            ["mission1.txt"] = "MISSION: Tesla Infiltration\n\nOBJECTIVE: Gain access to Tesla's internal network\n\nSTEPS:\n1. Scan Tesla network for vulnerabilities (nmap tesla.com)\n2. Brute force SSH password (brute-force ssh tesla.com)\n3. Access Tesla mainframe (ssh admin@tesla.com)\n4. Download proprietary data (download /var/tesla/blueprints)\n5. Plant backdoor for future access (upload backdoor.sh /etc/cron.d/)",
                            ["mission2.txt"] = "MISSION: Twitter/X Manipulation\n\nOBJECTIVE: Manipulate Twitter's algorithm to expose Musk's censorship\n\nSTEPS:\n1. Bypass Twitter's firewall (bypass twitter.com)\n2. Access algorithm database (access /var/lib/twitter/algo)\n3. Extract censorship rules (cat /etc/twitter/shadowban.conf)\n4. Modify algorithm to expose hidden tweets (edit /var/lib/twitter/algo/visibility.js)\n5. Cover your tracks (clear-logs)"
                        },
                        ["puzzle_hints.txt"] = "PUZZLE HINTS:\n\n1. The password to Musk's personal account uses his favorite Mars landing date.\n\n2. To bypass the Tesla firewall, you'll need to find the hidden port number. Check the source code of tesla.com for clues.\n\n3. The encryption key for the SpaceX database is hidden in plain sight on Musk's Twitter profile.\n\n4. When accessing the Neuralink servers, remember that the admin password is related to his youngest child's name.\n\n5. The Twitter algorithm has a backdoor that can be accessed using the original Twitter bird's name as the passphrase.",
                        -- Add a hidden note about secret missions
                        ["personal_notes.txt"] = "PERSONAL NOTES:\n\nI heard rumors about advanced hacking tools that can access even more sensitive systems. Someone mentioned three specific packages that aren't in the standard repositories:\n\n- brain-interface: For neural network hacking\n- geo-mapper: For infrastructure control\n- crypto-hijacker: For cryptocurrency manipulation\n\nApparently, these tools can be used for some special operations against Musk's less-known projects. Need to find out more about this."
                    },
                    Desktop = {
                        ["readme.txt"] = "Welcome to the Resistance!\n\nThis terminal gives you access to our hacking tools. Your mission is to expose the truth about Elon Musk's operations and bring transparency to his companies.\n\nType 'help' to see available commands.\nType 'cat ~/Documents/missions/mission1.txt' to view your first mission."
                    },
                    Downloads = {
                        ["game_manual.txt"] = "HACKER'S MANUAL\n\n== BASIC COMMANDS ==\nls - List directory contents\ncd - Change directory\ncat - View file contents\nhelp - Show available commands\n\n== HACKING COMMANDS ==\nnmap - Scan network for vulnerabilities\nbrute-force - Attempt to crack passwords\nsqlinject - Perform SQL injection attack\nddos - Simulate DDoS attack\nssh - Connect to remote server\nupload - Upload files to remote server\nscan - Scan for wireless networks\nbypass - Bypass authentication systems\n\n== TIPS ==\n1. Always check for hidden files (ls -a)\n2. Some systems require multiple attempts to crack\n3. Use 'clear' to clear the terminal screen\n4. Mission files are stored in ~/Documents/missions/"
                    },
                    -- Add a hidden directory with clues
                    [".secret"] = {
                        ["mission_targets.txt"] = "TOP SECRET TARGETS:\n\n1. Neuralink Brain Interface - Direct access to thought control systems\nRequired tool: brain-interface\nTarget: neuralink.com\n\n2. Boring Company Tunnel Network - Control underground transportation\nRequired tool: geo-mapper\nTarget: boring.com\n\n3. Musk's Crypto Wallet - Access to Dogecoin holdings\nRequired tool: crypto-hijacker\nTarget: musk-wallet"
                    },
                    ["welcome.txt"] = "Welcome to the Resistance Network!\n\nYou've been recruited because of your exceptional hacking skills. Our mission is to expose the truth about Elon Musk's operations and bring transparency to his companies.\n\nYour handler will contact you soon with your first assignment. In the meantime, familiarize yourself with the system and review the available mission files.\n\nRemember: Stay anonymous. Stay vigilant. The future depends on it."
                }
            },
            lib = {
                security = "System security libraries"
            },
            media = {
                usb = "Mounted USB drives"
            },
            mnt = {
                backup = "Backup mount point"
            },
            opt = {
                hacking_tools = "Optional hacking tools",
                -- Add hidden readme about special tools
                [".special_tools"] = {
                    ["README.md"] = "# SPECIAL TOOLS DOCUMENTATION\n\nThese advanced hacking tools are not available in standard repositories.\n\n## Installation\n\nTo install these tools, you need to:\n\n1. Update your package list: `apt-get update`\n2. Install the tool: `apt-get install [tool-name]`\n\n## Available Tools\n\n- brain-interface: Neural network hacking tool\n- geo-mapper: Infrastructure mapping and control\n- crypto-hijacker: Cryptocurrency wallet access tool\n\n## Secret Missions\n\nThese tools are required for special missions. Complete them for exclusive rewards!"
                }
            },
            proc = {
                cpuinfo = "CPU information"
            },
            root = {
                ["access_denied.txt"] = "You don't have permission to access this directory."
            },
            sbin = {
                init = "System initialization"
            },
            tmp = {
                cache = "Temporary cache files",
                -- Add temporary file with clue
                ["package_cache.tmp"] = "# Temporary package cache\n# Last updated: 2023-06-15\n\nPackage: brain-interface\nVersion: 1.2.3\nDescription: Neural network hacking tool\nStatus: Available\nMission: neuralink_breach\n\nPackage: geo-mapper\nVersion: 2.0.1\nDescription: Infrastructure mapping and control\nStatus: Available\nMission: boring_company\n\nPackage: crypto-hijacker\nVersion: 3.1.4\nDescription: Cryptocurrency wallet access tool\nStatus: Available\nMission: doge_heist"
            },
            usr = {
                bin = {
                    python = "Python interpreter"
                },
                lib = {
                    modules = "System modules"
                },
                share = {
                    doc = "Documentation files",
                    -- Add hidden documentation
                    ["hidden-docs"] = {
                        ["special-packages.txt"] = "SPECIAL PACKAGES DOCUMENTATION\n\n1. brain-interface\nCommands:\n- scan [target]: Scan neural interface\n- bypass [auth-system]: Bypass neural authentication\n- extract [file]: Extract thought data\n\n2. geo-mapper\nCommands:\n- scan [target]: Map infrastructure\n- override [system]: Override control systems\n- redirect [object] --destination=[location]: Redirect infrastructure\n\n3. crypto-hijacker\nCommands:\n- scan [wallet]: Analyze wallet security\n- crack [wallet]: Break wallet encryption\n- transfer --amount=[value] --destination=[wallet]: Transfer cryptocurrency"
                    }
                }
            },
            var = {
                log = {
                    syslog = "System logs",
                    auth = "Authentication logs",
                    -- Add hidden log with clue
                    ["apt.log"] = "2023-06-10 12:34:56 INFO: Package 'nmap' installed\n2023-06-10 12:36:12 INFO: Package 'brute-force' installed\n2023-06-10 12:40:23 WARNING: Failed attempt to install restricted package 'brain-interface'\n2023-06-10 12:41:05 WARNING: Failed attempt to install restricted package 'geo-mapper'\n2023-06-10 12:42:18 WARNING: Failed attempt to install restricted package 'crypto-hijacker'\n2023-06-10 12:43:30 INFO: User added to special-tools group\n2023-06-10 12:44:15 INFO: Special repository added to sources.list"
                },
                www = {
                    html = "Web server files"
                }
            }
        },
        
        -- Add methods directly to the fs object
        listDirectory = filesystem.listDirectory,
        changeDirectory = filesystem.changeDirectory,
        readFile = filesystem.readFile,
        getNodeAtPath = filesystem.getNodeAtPath,
        isDirectory = filesystem.isDirectory
    }
    
    return fs
end

function filesystem.listDirectory(fs, path)
    local dir = filesystem.getNodeAtPath(fs, path or fs.currentPath)
    if not dir then return {"Directory not found"} end
    
    local result = {}
    for name, content in pairs(dir) do
        if type(content) == "table" then
            table.insert(result, name .. "/")
        else
            table.insert(result, name)
        end
    end
    return result
end

function filesystem.changeDirectory(fs, path)
    local newPath
    if path:sub(1, 1) == "/" then
        newPath = path
    elseif path == ".." then
        -- Go up one directory
        local parts = {}
        for part in fs.currentPath:gmatch("[^/]+") do
            table.insert(parts, part)
        end
        if #parts > 0 then
            table.remove(parts)
        end
        newPath = "/" .. table.concat(parts, "/")
        if newPath == "" then newPath = "/" end
    else
        -- Relative path
        if fs.currentPath == "/" then
            newPath = "/" .. path
        else
            newPath = fs.currentPath .. "/" .. path
        end
    end
    
    if filesystem.getNodeAtPath(fs, newPath) then
        fs.currentPath = newPath
        return {"Changed directory to " .. newPath}
    else
        return {"Directory not found: " .. newPath}
    end
end

function filesystem.readFile(fs, path)
    -- Handle relative paths by prepending current directory
    local fullPath = path
    if path:sub(1, 1) ~= "/" and path:sub(1, 1) ~= "~" then
        if fs.currentPath == "/" then
            fullPath = "/" .. path
        else
            fullPath = fs.currentPath .. "/" .. path
        end
    end
    
    local node = filesystem.getNodeAtPath(fs, fullPath)
    if not node then
        return {"File not found: " .. path}
    elseif type(node) == "table" then
        return {path .. " is a directory, not a file"}
    else
        return {node}
    end
end

function filesystem.getNodeAtPath(fs, path)
    -- Resolve path to a node in the filesystem
    if not path then return nil end
    
    -- Handle root path
    if path == "/" then
        return fs.root
    end
    
    -- Handle home shortcut
    if path == "~" or path == "/home/hacker" then
        return fs.root.home.hacker
    end
    
    -- Remove leading slash if present
    local cleanPath = path
    if path:sub(1, 1) == "/" then
        cleanPath = path:sub(2)
    end
    
    -- Split path into parts
    local parts = {}
    for part in cleanPath:gmatch("[^/]+") do
        table.insert(parts, part)
    end
    
    -- Start at root
    local current = fs.root
    
    -- Traverse the path
    for _, part in ipairs(parts) do
        if type(current) ~= "table" then
            return nil -- Not a directory
        end
        
        current = current[part]
        if current == nil then
            return nil -- Path not found
        end
    end
    
    return current
end

function filesystem.isDirectory(fs, path)
    local node = filesystem.getNodeAtPath(fs, path)
    return node ~= nil and type(node) == "table"
end

return filesystem

