 function RBH_Intel_DoUpdate(msg) 
    local name,realm,faction,class,race,level,guild,zone,xcoord,ycoord,intelage = string.split(",",msg)
    
    rbh_debug("RBH_Intel_DoUpdate("..msg..")")
    
    if name == nil or realm == nil then
        return
    end
    
    if intelage == nil or intelage == "" then 
        intelage = 0
    end      
    
    local fullName = name.."-"..realm
    
    if RBH_Intel[fullName] == nil then
        RBH_Intel[fullName] = {}
    end
    
    if RBH_Intel[fullName].intelage == nil or RBH_Intel[fullName].intelage == "" then
        RBH_Intel[fullName].intelage = 0
    end    
    
    if (tonumber(intelage) > tonumber(RBH_Intel[fullName].intelage)) then
        RBH_Intel[fullName].faction = faction
        RBH_Intel[fullName].zone = zone
        RBH_Intel[fullName].xcoord = xcoord
        RBH_Intel[fullName].ycoord = ycoord
        RBH_Intel[fullName].intelage = tonumber(intelage)
        RBH_Intel[fullName].class = class
        RBH_Intel[fullName].race = race
        RBH_Intel[fullName].level = level
        RBH_Intel[fullName].guild = guild
        RBH_HitListUpdate()      
    end
end

function RBH_IntelToString(fullName)
    if RBH_Intel == nil then
        return ""
    end
    
    if RBH_Intel[fullName] == nil then
        return ""
    end
    
    --local name = RBH_Intel[fullName].name
    --local realm = RBH_Intel[fullName].realm
    local name, realm = string.split("-", fullName)
    local class = RBH_Intel[fullName].class
    local race = RBH_Intel[fullName].race
    local faction = RBH_Intel[fullName].faction
    local level = RBH_Intel[fullName].level
    local guild = RBH_Intel[fullName].guild
    local zone = RBH_Intel[fullName].zone
    local xcoord = RBH_Intel[fullName].xcoord
    local ycoord = RBH_Intel[fullName].ycoord
    local intelage = RBH_Intel[fullName].intelage
    
    if class == nil then
        class = ""
    end
    if race == nil then
        race = ""
    end
    if faction == nil then
        faction = ""
    end
    if level == nil then
        level = ""
    end
    if guild == nil then
        guild = ""
    end
    if zone == nil then
        zone = ""
    end
    if xcoord == nil then
        xcoord = ""
    end
    if ycoord == nil then
        ycoord = ""
    end
    if intelage == nil then
        intelage = 0
    end        
    
    local intelMsg = name..","..realm..","..faction..","..class..","..race..","..level..","..guild..","..zone..","..xcoord..","..ycoord..","..intelage 
    
    return intelMsg
end
