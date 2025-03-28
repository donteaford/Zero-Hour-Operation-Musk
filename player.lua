local player = {}

function player.new()
    return {
        username = "hacker",
        level = 1,
        experience = 0,
        skills = {
            hacking = 1,
            networking = 1,
            cryptography = 1
        },
        inventory = {},
        completedMissions = {},
        currentMission = nil
    }
end

function player.gainExperience(playerData, amount)
    playerData.experience = playerData.experience + amount
    
    -- Level up if enough experience
    if playerData.experience >= playerData.level * 100 then
        playerData.level = playerData.level + 1
        return true -- Return true if leveled up
    end
    
    return false
end

function player.addToInventory(playerData, item)
    table.insert(playerData.inventory, item)
end

function player.hasItem(playerData, itemName)
    for _, item in ipairs(playerData.inventory) do
        if item.name == itemName then
            return true
        end
    end
    return false
end

return player