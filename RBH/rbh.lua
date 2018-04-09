function RBH_OnLoad(self)
    self:RegisterEvent("VARIABLES_LOADED"); 	
    self:RegisterEvent("PLAYER_LOGIN");
    self:RegisterEvent("PLAYER_LOGOUT");
    self:RegisterEvent("PLAYER_ENTERING_WORLD");	
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
    self:RegisterEvent("CHAT_MSG_SYSTEM");
    self:RegisterEvent("CHAT_MSG_ADDON");
    self:RegisterEvent("WHO_LIST_UPDATE");
    self:RegisterEvent("CHAT_MSG_CHANNEL")
    self:RegisterEvent("CHAT_MSG_CHANNEL_JOIN")
    self:RegisterEvent("CHAT_MSG_CHANNEL_LEAVE")
    self:RegisterEvent("PLAYER_MONEY")
    self:RegisterEvent("GUILD_ROSTER_UPDATE")
    RegisterAddonMessagePrefix("RBH_HL_SYNC_REQ")   
    RegisterAddonMessagePrefix("RBH_HL_UPDATE")
    RegisterAddonMessagePrefix("RBH_INTEL_UPDATE") 
    RegisterAddonMessagePrefix("RBH_USERS_REQ")
    RegisterAddonMessagePrefix("RBH_USERS_ACK")  
    RegisterAddonMessagePrefix("RBH_ADDME_REQ")
    RegisterAddonMessagePrefix("RBH_VALIDATE_REQ")
    RegisterAddonMessagePrefix("RBH_VALIDATE_ACK")
    RegisterAddonMessagePrefix("RBH_NT_UPDATE")
    
end

function RBH_OnEvent(self, event, ...)    
    local arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9 = ...;
    ---print("Event: "..event..", arg2: "..arg2..", arg5: "..arg5..", arg9: "..arg9)
    if event == "VARIABLES_LOADED" then 
        RBH_HitListFrame:RegisterForDrag("LeftButton")        
        RBH_Init() 
        
    elseif (event == "PLAYER_LOGIN") then
        RBH_LargessMessage("[RBH] Realm Bounty Hunter v"..RBH_VERSION.." loaded", "sys")
        RBH_LargessMessage("[RBH] Type /rbh help for a list of commands", "sys") 
        RBH_Largess = GetMoney() - RBH_GetTotalIssuedBountiesValue()
        RBH_CurrMoney = GetMoney()
        
        --init network
        if RBH_Network == nil then
            RBH_Network = {}
        end
        if RBH_Config["RealmChannel"] then
            if RBH_Network[RBH_REALM_CHANNEL] == nil then
                RBH_Network[RBH_REALM_CHANNEL] = {}
            end
        end
        if RBH_Config["PrivateChannel"] then
            if RBH_Network[RBH_PRIVATE_CHANNEL] == nil then
                RBH_Network[RBH_PRIVATE_CHANNEL] = {}
            end
        end     
       
        RBH_ActionQueueInit()     
       --join comm channels 
       RBH_ActionQueueAdd([[                   
        if (RBH_Config["RealmChannel"]) then
            JoinPermanentChannel(RBH_REALM_CHANNEL)
        end
       
        if (RBH_Config["PrivateChannel"]) then
            JoinPermanentChannel(RBH_PRIVATE_CHANNEL, RBH_PRIVATE_PASSWORD)		
        end
        ]],20)
        
        RBH_ActionQueueAdd([[RBH_SendAddonMessageToNetwork("ALERT","RBH_SYNC_REQ","")]], 25)
        

    
    elseif (event == "GUILD_ROSTER_UPDATE") then
        RBH_GUILD_CHANNEL = GetGuildInfo("player")
        
    elseif (event == "PLAYER_LOGOUT") then
        RBH_Network = nil
        LeaveChannelByName(RBH_PRIVATE_CHANNEL)
    
    elseif (event == "PLAYER_ENTERING_WORLD") then                 
        --RBH_SyncNetwork()
        if RBH_Config["scale"] ~= nil then
            RBH_HitListFrame:SetScale(RBH_Config["scale"])
        end   
       
   --check for killing blow      
    elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") and (arg9 ~= UnitName("player")) and arg9 ~= nil then 		
        local n1,n2,destName,destRealm = string.find(arg9,"(.+)-(.+)")
        if destName == nil then           
           destName = arg9
           destRealm = GetRealmName()
        end     
      
	    --RBH_LargessMessage("COMBAT_LOG_EVENT_UNFILTERED: "..arg2..", "..arg5..", "..arg9)
	    local audit
        local f, i = IsBountyOpen(destName, destRealm) 
        
        if not (arg2 == "PARTY_KILL" and arg5 == UnitName("player")) then
            return
        end             
        
        rbh_debug(arg2..": "..destName..":"..destRealm)          
        
        if (i>0) and (RBH_HitList[i].state == "RBH_OPEN") then 
           
            --[[if RBH_HitList[i].class == nil then 
                print(RBH_UnitType(arg8))
                if RBH_UnitType(arg8) == 4 then
                --just killed pet
                    if RBH_HitList[i].class ~= destName then
                        return
                    end
                end
            end ]]--
			
            if not (destRealm == RBH_HitList[i].realm or destRealm == RBH_RemoveWhiteSpace(RBH_HitList[i].realm)) then
                return
            end
            
			local claimer = RBH_GetFullName(UnitName("player"))            
            local amount = RBH_HitList[i].amount      
            local j
            local id  = RBH_HitList[i].id
            local timestamp = time()
            local name = RBH_HitList[i].name
            local issuer = RBH_HitList[i].issuer      
            local rname  
        
            --normal behavior (no split)
            RBH_LargessMessage("[RBH] Bounty claimed on "..destName.." for "..RBH_CopperToGold(amount), "sys");                     
            RBH_HitList[i].state = "RBH_CLAIMED"
            RBH_HitList[i].claimer = claimer; 
            RBH_HitList[i].amount = amount
            local guid = arg8            
            if RBH_Claimed[id] == nil then
                RBH_Claimed[id] = {}
            end
            RBH_Claimed[id].guid = guid         
            RBH_Claimed[id].name = name
            RBH_Claimed[id].issuer = issuer 
            RBH_ValidateClaimedBountyReq(id,issuer)
            rbh_debug("Claimed GUID:" .. RBH_Claimed[id].guid)
            local timestamp = time()
            local name = RBH_HitList[i].name
            local issuer = RBH_HitList[i].issuer              
            
            local msg = id..","..time()..","..name..","..issuer..","..amount..","..claimer..","..RBH_HitList[i].state..","..RBH_HitList[i].faction..","..RBH_HitList[i].realm..","..RBH_HitList[i].realm_chan..","..RBH_HitList[i].guild_chan..","..RBH_HitList[i].private_chan      
            RBH_HitListUpdate()
            RBH_SendAddonMessageToNetwork("ALERT","RBH_HL_UPDATE", msg);                
        end 
    
    --sync
    elseif (event == "CHAT_MSG_ADDON") then       
        --bounty list
        if (arg1 == "RBH_HL_SYNC_REQ") then           
            if arg4 ~= RBH_GetFullName("player") then
                rbh_debug("RBH_HL_SYNC_REQ")
                RBH_HL_DoSync(arg4)
                RBH_NT_DoSync(arg4)
            end
            
        elseif (arg1 == "RBH_HL_UPDATE") then            
            if arg4 ~= RBH_GetFullName("player") then                
                rbh_debug("RBH_HL_UPDATE")
                RBH_HL_DoUpdate(arg2,arg4)
            end
        
        elseif (arg1 == "RBH_NT_UPDATE") then
            if arg4 ~= RBH_GetFullName("player") then                
                rbh_debug("RBH_NT_UPDATE")
                RBH_NT_DoUpdate(arg2,arg4)
            end
        
        elseif (arg1 == "RBH_INTEL_UPDATE") then
            if arg4 ~= RBH_GetFullName("player") then
                rbh_debug("RBH_INTEL_UPDATE")
                RBH_Intel_DoUpdate(arg2)
            end
        
        elseif (arg1 == "RBH_VALIDATE_REQ") then
            --if arg4 ~= RBH_GetFullName("player") then
                rbh_debug("RBH_VALIDATE_REQ")
                RBH_ValidateClaimedBountyReq(arg2,arg4)
            --end           
        
        elseif (arg1 == "RBH_VALIDATE_ACK") then
            --if arg4 ~= RBH_GetFullName("player") then
                rbh_debug("RBH_VALIDATE_ACK")
                RBH_ValidateClaimedBountyAck(arg2,arg4)
            --end
        
        --users request command
        elseif (arg1 == "RBH_USERS_REQ") then
            rbh_debug("RBH_USERS_REQ")           
            ChatThrottleLib:SendAddonMessage("ALERT", "RBH_USERS_ACK", "Realm Bounty Hunter v"..RBH_VERSION, "WHISPER", arg4)
                
        --users response command       
        elseif (arg1 == "RBH_USERS_ACK") then             
            rbh_debug("RBH_USERS_ACK")
            RBH_LargessMessage(arg4..": ".. arg2); 
        
        elseif (arg1 == "RBH_ADDME_REQ") then
            rbh_debug("RBH_ADDME_REQ")
            RBH_AddPlayerToNetwork(arg4, arg2)
            RBH_HL_DoSync(arg4)   
        end  --CHAT_MSG_ADDON   
    
    elseif (event == "CHAT_MSG_CHANNEL_JOIN") then  
        local channelName = string.match(arg4, "%d%.%s(.*)")
        local playerName = RBH_GetFullName(arg2)          
        RBH_AddPlayerToNetwork(playerName, channelName)
        ChatThrottleLib:SendAddonMessage("BULK", "RBH_ADDME_REQ", channelName, "WHISPER", playerName)
        RBH_HL_DoSync(playerName, channelName)
        rbh_debug(playerName .. " joined channel:"..channelName)
    
    elseif (event == "CHAT_MSG_CHANNEL_LEAVE") then       
        local channelName = string.match(arg4, "%d%.%s(.*)")
        local playerName = RBH_GetFullName(arg2)
        rbh_debug(playerName .. " left channel:"..channelName)
        RBH_RemovePlayerFromNetwork(playerName, channelName)
    
    elseif (event == "PLAYER_MONEY") then
        if RBH_CurrMoney ~= nil then
            local deltaMoney = GetMoney() - RBH_CurrMoney
            RBH_CurrMoney = GetMoney()
            RBH_Largess = RBH_Largess + deltaMoney
        else
            RBH_CurrMoney = GetMoney()
        end
    end   
end      
  
function RBH_GetFullName(name)
    if name == nil then
        return
    end
   
    if name == "player" then
        name = UnitName("player")
    end
	
    local n, r = string.split("-", name)
    
    if r ~= nil then
        return name
    else
        r = GetRealmName()
        return name.."-"..r
    end  
end

function RBH_UnitIsInMyGuild(name)

	local i
	for i = 1, #RBH_GuildMates do
		if RBH_GuildMates[i].name == name then
			return true
		end
	end
	
	return false
end
	
function RBH_LargessMessage(msg,color)   
   if (color == nil) or (color == "GREEN") or (color == "green") then 
      --default color is green
      DEFAULT_CHAT_FRAME:AddMessage(msg, 0, 1, 0);
   elseif (color == "RED") or (color == "red") then
      --here's red
      DEFAULT_CHAT_FRAME:AddMessage(msg, 1, 0, 0);
   elseif (color == "sys") then
      --yellow?
      DEFAULT_CHAT_FRAME:AddMessage(msg, 1, 1, 0);
   elseif (color == "rep") then
      DEFAULT_CHAT_FRAME:AddMessage(msg, GetMessageTypeColor("CHAT_MSG_COMBAT_FACTION_CHANGE"));
   end   
end

--remove white space from string
function RBH_RemoveWhiteSpace(s)
  local n = 1
  while true do
    while true do -- removes spaces
      local _, ne, np = s:find("^[^%s%%]*()%s*", n)
      n = np
      if np - 1 ~= ne then s = s:sub(1, np - 1) .. s:sub(ne + 1)
      else break end
    end
    local m = s:match("%%(.?)", n) -- skip magic chars
    if m == "b" then n = n + 4
    elseif m then n = n + 2
    else break end
  end
  return s
end