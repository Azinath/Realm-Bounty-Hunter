RBH_REALM_CHANNEL = "rbhrealmchannel007"
--RBH_PRIVATE_CHANNEL = "rbhprivatechannel007"
--RBH_PRIVATE_PASSWORD = "rbhfoo"
if (RBH_PRIVAATE_CHANNEL == nil) then
    RBH_PRIVATE_CHANNEL = ""
end

if (RBH_PRIVATE_PASSWORD == nil) then
    RBH_PRIVATE_PASSWORD = ""
end

function RBH_JoinCommChannels()
    if (RBH_Config["RealmChannel"]) then
        JoinPermanentChannel(RBH_REALM_CHANNEL)
    end
       
    if (RBH_Config["PrivateChannel"]) then
        JoinPermanentChannel(RBH_PRIVATE_CHANNEL, RBH_PRIVATE_PASSWORD)		
    end      
        
    RBH_SendAddonMessageToNetwork("ALERT","RBH_SYNC_REQ","")
 end

function RBH_SendAddonMessageToNetworkChannel(channel, priority, prefix, msg)
    if RBH_Network == nil then
        return
    end
    if RBH_Network[channel] == nil then
        return
    end
    
    local n = #RBH_Network[channel]
    local i
    local name
    for i=1, n do
        name = RBH_Network[channel][i]
        rbh_debug("RBH_SendAddonMessageToNetworkChannel: "..priority..", "..prefix..", "..channel..", "..name..", "..msg)
        ChatThrottleLib:SendAddonMessage(priority, prefix, msg, "WHISPER", name) 
    end
end

--Sends an addon message to all members of the network
function RBH_SendAddonMessageToNetwork(priority, prefix, msg)
    rbh_debug("RBH_SendAddonMessageToNetwork(" .. priority .. "," .. prefix .. "," .. msg .. ")")
    --send to realm channel
    if RBH_Config["RealmChannel"] then
        RBH_SendAddonMessageToNetworkChannel(RBH_REALM_CHANNEL, priority, prefix, msg)
    end
    
    --send to private channel
    if RBH_Config["PrivateChannel"] then
        RBH_SendAddonMessageToNetworkChannel(RBH_PRIVATE_CHANNEL, priority, prefix, msg)
    end
    
    --send to guild
    if (RBH_Config["GuildChannel"]) then   
       ChatThrottleLib:SendAddonMessage(priority, prefix, msg, "GUILD");       
    end
end

--Adds a player to the network under a channel
function RBH_AddPlayerToNetwork(playerName, channelName)
    if (RBH_Network == nil) then
        return
    end
    if (RBH_Network[channelName] == nil) then
        return
    end
    
    --search for player name already in channel
    local n = #RBH_Network[channelName]
    local i
    for i=1,n do
        local name = RBH_Network[channelName]
        if name == playerName then
            return
        end
    end
    
    table.insert(RBH_Network[channelName], playerName)  
    rbh_debug("RBH_AddPlayerToNetwork: "..playerName..", "..channelName)
end

--Removes a player from the network under a channel
function RBH_RemovePlayerFromNetwork(playerName, channelName)
    if RBH_Network == nil then
        return
    end
    if RBH_Network[channelName] == nil then
        return
    end
    
    --search for player name already in channel
    local n = #RBH_Network[channelName]
    local i
    local index
    for i=1,n do
        local name = RBH_Network[channelName]
        if name == playerName then
            index = i
            break
        end
    end
    
    table.remove(RBH_Network[channelName], index)    
end

function RBH_IsBountyInActiveChannel(index)
    local guildName = GetGuildInfo("player")

    if RBH_HitList[index].realm_chan == RBH_REALM_CHANNEL and RBH_Config["RealmChannel"] then
        return true
    elseif RBH_HitList[index].guild_chan == guildName and RBH_Config["GuildChannel"] then
        return true
    elseif RBH_HitList[index].private_chan == RBH_PRIVATE_CHANNEL and RBH_Config["PrivateChannel"] then
        return true
    else 
        return false
    end    
end

function RBH_AcceptIncomingBounty(realm, guild, private)
    if RBH_Config["RealmChannel"] and realm == RBH_REALM_CHANNEL then
        return true
    end  
    
    local guildName = GetGuildInfo("player")
    if RBH_Config["GuildChannel"] and guild == guildName then
        return true
    end
   
    if RBH_Config["PrivateChannel"] and private == RBH_PRIVATE_CHANNEL then
        return true
    end    

    return false
end