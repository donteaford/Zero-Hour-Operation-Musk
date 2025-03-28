local missions = {}

local missionData = {
    tesla = {
        name = "Tesla Infiltration",
        type = "terminal",
        steps = {
            {
                description = "Scan Tesla network for vulnerabilities",
                command = "nmap tesla.com",
                feedback = "Scan complete. Found open ports: 22, 80, 443"
            },
            {
                description = "Brute force SSH password",
                command = "brute-force ssh tesla.com",
                feedback = "Password cracked! Username: admin, Password: model3x"
            },
            {
                description = "Access Tesla mainframe",
                command = "ssh admin@tesla.com",
                feedback = "Connected to Tesla mainframe. Access granted to production systems."
            },
            {
                description = "Plant malware in production system",
                command = "upload malware.bin /var/tesla/production",
                feedback = "Your malware package was run on the Tesla server. Elon is raging mad! All of the robots stopped making automobiles and started making tiny robotic cats!! They're MEOW-tiplying!!"
            }
        },
        completed = false,
        currentStep = 1
    },
    
    starlink = {
        name = "Starlink Breach",
        type = "terminal",
        steps = {
            {
                description = "Scan Starlink satellites",
                command = "scan starlink.com",
                feedback = "Satellite network detected. Access points identified."
            },
            {
                description = "Bypass satellite authentication",
                command = "bypass starlink-auth",
                feedback = "Authentication bypassed. You now have access to the satellite network."
            },
            {
                description = "Redirect satellite signals",
                command = "redirect sat-signal --all",
                feedback = "Signals redirected. Global internet traffic now routes through your server."
            }
        },
        completed = false,
        currentStep = 1
    },
    
    spacex = {
        name = "SpaceX Hack",
        type = "terminal",
        steps = {
            {
                description = "Access SpaceX network",
                command = "connect spacex.com",
                feedback = "Connected to SpaceX network. Firewall detected."
            },
            {
                description = "Bypass firewall",
                command = "firewall-exploit spacex",
                feedback = "Firewall bypassed. Access to launch systems granted."
            },
            {
                description = "Modify launch coordinates",
                command = "edit launch-coords.dat",
                feedback = "Launch coordinates modified. Next rocket will land on your neighbor's house."
            }
        },
        completed = false,
        currentStep = 1
    }
}

function missions.getCurrentMission(missionName)
    return missionData[missionName]
end

function missions.checkMissionProgress(command, missionName)
    local mission = missionData[missionName]
    if not mission then return false, "Mission not found" end
    
    local currentStep = mission.steps[mission.currentStep]
    if currentStep.command == command then
        mission.currentStep = mission.currentStep + 1
        if mission.currentStep > #mission.steps then
            mission.completed = true
        end
        return true, currentStep.feedback
    end
    
    return false, "Command did not advance mission"
end

-- Add hidden bonus missions that require special tools
local hiddenMissions = {
    neuralink_breach = {
        name = "Neuralink Breach",
        type = "hidden",
        requiredTool = "brain-interface",
        steps = {
            {
                description = "Scan Neuralink security protocols",
                command = "brain-interface scan neuralink.com",
                feedback = "Brain interface connected. Neural security protocols detected."
            },
            {
                description = "Bypass neural authentication",
                command = "brain-interface bypass neuralink-auth",
                feedback = "Neural authentication bypassed. Direct access to thought patterns granted."
            },
            {
                description = "Extract thought data",
                command = "brain-interface extract elon-thoughts.dat",
                feedback = "Thought extraction complete. You now know Elon's darkest secrets about Mars colonization!"
            }
        },
        completed = false,
        currentStep = 1,
        reward = {
            type = "tshirt",
            name = "Neural Hacker",
            slogan = "I hacked Elon's brain and all I got was this T-shirt... and his Mars colony plans!"
        }
    },
    
    boring_company = {
        name = "Tunnel Network Takeover",
        type = "hidden",
        requiredTool = "geo-mapper",
        steps = {
            {
                description = "Map Boring Company tunnel network",
                command = "geo-mapper scan boring.com",
                feedback = "Tunnel network mapped. Secret underground bases detected."
            },
            {
                description = "Override tunnel control systems",
                command = "geo-mapper override tunnel-controls",
                feedback = "Tunnel control systems compromised. You now control all underground transport."
            },
            {
                description = "Redirect tunnels to your secret lair",
                command = "geo-mapper redirect tunnels --destination=secret-lair",
                feedback = "Tunnels redirected. All underground traffic now passes through your secret lair!"
            }
        },
        completed = false,
        currentStep = 1,
        reward = {
            type = "tshirt",
            name = "Tunnel Vision",
            slogan = "I redirected Elon's boring tunnels and all I got was this not-so-boring T-shirt!"
        }
    },
    
    doge_heist = {
        name = "Dogecoin Heist",
        type = "hidden",
        requiredTool = "crypto-hijacker",
        steps = {
            {
                description = "Infiltrate Elon's crypto wallet",
                command = "crypto-hijacker scan musk-wallet",
                feedback = "Wallet security analyzed. Dogecoin holdings detected."
            },
            {
                description = "Bypass wallet authentication",
                command = "crypto-hijacker crack musk-wallet",
                feedback = "Wallet cracked. Access to Dogecoin holdings granted."
            },
            {
                description = "Transfer Dogecoins to your wallet",
                command = "crypto-hijacker transfer --amount=all --destination=hacker-wallet",
                feedback = "Transfer complete. You now own 1 million Dogecoin! Much wealth, very hack!"
            }
        },
        completed = false,
        currentStep = 1,
        reward = {
            type = "tshirt",
            name = "Doge Hacker",
            slogan = "I stole Elon's Dogecoin and all I got was this T-shirt... and 1 million DOGE!"
        }
    }
}

-- Add function to get hidden mission
function missions.getHiddenMission(missionName)
    return hiddenMissions[missionName]
end

-- Add function to check if player has required tool for mission
function missions.checkHiddenMissionRequirement(missionName, gameState)
    local mission = hiddenMissions[missionName]
    if not mission then return false, "Mission not found" end
    
    if not gameState.installedPackages or not gameState.installedPackages[mission.requiredTool] then
        return false, "Required tool not installed: " .. mission.requiredTool
    end
    
    return true, "Requirements met"
end

-- Add function to check hidden mission progress
function missions.checkHiddenMissionProgress(command, missionName, gameState)
    local mission = hiddenMissions[missionName]
    if not mission then return false, "Mission not found" end
    
    -- Check if player has required tool
    local hasRequirement, message = missions.checkHiddenMissionRequirement(missionName, gameState)
    if not hasRequirement then
        return false, message
    end
    
    local currentStep = mission.steps[mission.currentStep]
    if currentStep.command == command then
        mission.currentStep = mission.currentStep + 1
        if mission.currentStep > #mission.steps then
            mission.completed = true
            
            -- Add reward to player inventory
            if not gameState.player.tshirts then
                gameState.player.tshirts = {}
            end
            table.insert(gameState.player.tshirts, mission.reward)
            
            return true, currentStep.feedback .. "\n\nMission Complete! You earned the '" .. mission.reward.name .. "' T-shirt: \"" .. mission.reward.slogan .. "\""
        end
        return true, currentStep.feedback
    end
    
    return false, "Command did not advance mission"
end

return missions



