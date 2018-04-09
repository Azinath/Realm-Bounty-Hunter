function RBH_SyncNetwork()   
    local i,n,msg
    if RBH_HitList == nil then  
        RBH_HitList={};
    end        
    n = #RBH_HitList        
    for  i = 1, n do        
      msg = RBH_BountyToString(i)
      
      rbh_debug("Send: "..msg)   
      
      RBH_SendAddonMessageToNetwork("BULK","RBH_HL_UPDATE",msg);
      --ChatThrottleLib:SendAddonMessage("NORMAL","RBH_HL_UPDATE",msg, "WHISPER", sender);
    end
end    

function RBH_HL_DoSync(sender)   
    local i,n,msg
    if RBH_HitList == nil then  
        RBH_HitList={};
    end        
    n = #RBH_HitList        
    for  i = 1, n do        
        if RBH_IsBountyInActiveChannel(i) then
            msg = RBH_BountyToString(i)      
            rbh_debug("Send: "..msg)         
            --RBH_SendAddonMessageToNetwork("NORMAL","RBH_HL_UPDATE",msg,"WHISPER",sender);
            ChatThrottleLib:SendAddonMessage("NORMAL","RBH_HL_UPDATE",msg,"WHISPER",sender)
            
            --send intel message
            local fullName = RBH_HitList[i].name.."-"..RBH_HitList[i].realm
            local intelMsg = RBH_IntelToString(fullName)
            rbh_debug("Send: " ..intelMsg)
            ChatThrottleLib:SendAddonMessage("NORMAL","RBH_INTEL_UPDATE",intelMsg,"WHISPER",sender)
        end
    end
end    

function RBH_HL_DoUpdate(msg,sender)  
    local id,name,issuer,amount,state,claimer,timestamp,f,i,faction,realm,realm_chan,guild_chan,private_chan
    local f, i
    id,timestamp,name,issuer,amount,claimer,state,faction,realm,realm_chan,guild_chan,private_chan = string.split(",",msg) 
    
    rbh_debug("RBH_HL_DoUpdate("..msg)
    
    if RBH_AcceptIncomingBounty(realm_chan,guild_chan,private_chan) ~= true or
       RBH_RejectBounty(msg) then
        if (private_chan == nil) then
            private_chan = ""
        end
        if (realm_chan ~= nil and guild_chan ~= nil and private_chan ~= nil) then
            rbh_debug("RBH_AccecptIncomingBounty("..realm_chan..","..guild_chan..","..private_chan..") : false")
        end
        
        return
    end
    
    --must have valid name and amount
    if name == nil or amount == nil then 
        rbh_debug("RBH_HL_DoUpdate: Error: name or amount is nil.")
        return
    end  
    
    --validate claimed bounty    
    if (claimer == sender and issuer == RBH_GetFullName("player")) then        
        ChatThrottleLib:SendAddonMessage("ALERT","RBH_VALIDATE_REQ",id,"WHISPER",sender)       
    end
    
    f,i = InHitList(id)
    rbh_debug("Is InHitList["..i.."]:"..tostring(f))
    
    if f == false then    
        rbh_debug("New: "..msg)        
        table.insert(RBH_HitList,{id=id,name=name,amount=amount,issuer=issuer,timestamp=timestamp,state=state,claimer=claimer,faction=faction,realm=realm,realm_chan=realm_chan,guild_chan=guild_chan,private_chan=private_chan});  
        RBH_HitListUpdate()        
               
    elseif ((tonumber(timestamp) > tonumber(RBH_HitList[i].timestamp)) or
           ((tonumber(timestamp) < tonumber(RBH_HitList[i].timestamp)) and state == "RBH_CLAIMED" and RBH_HitList[i].state == "RBH_CLAIMED")) and
           not (RBH_HitList[i].state == "RBH_CLAIMED" and state == "RBH_DEL") then       
        
        rbh_debug("Update: "..msg)
        
        RBH_HitList[i].id = id
        RBH_HitList[i].name = name
        RBH_HitList[i].amount = amount
        RBH_HitList[i].issuer = issuer
        RBH_HitList[i].timestamp = timestamp
        RBH_HitList[i].state = state
        RBH_HitList[i].claimer = claimer        
        RBH_HitList[i].faction = faction
        RBH_HitList[i].realm = realm        
    end    
end

function RBH_BountyToString(i)
    local name = RBH_HitList[i].name
    local amount = RBH_HitList[i].amount   
    local id = RBH_HitList[i].id      
    local issuer = RBH_HitList[i].issuer
    local timestamp = RBH_HitList[i].timestamp
    local state = RBH_HitList[i].state
    local claimer = RBH_HitList[i].claimer
    local faction = RBH_HitList[i].faction
    local realm = RBH_HitList[i].realm  
    local realm_chan = RBH_HitList[i].realm_chan
    local guild_chan = RBH_HitList[i].guild_chan
    local private_chan = RBH_HitList[i].private_chan   
   
    if faction == nil then
        faction = "UNKNOWN"
    end  
    
    if RBH_HitList[i].realm == nil then
        realm = ""
    end  
    
    if RBH_HitList[i].realm_chan == nil then
        realm_chan = ""
    end 
    
    if RBH_HitList[i].guild_chan == nil then
        guild_chan = ""
    end
    
    if RBH_HitList[i].private_chan == nil then
        private_chan = ""
    end
    
    local msg = id..","..timestamp..","..name..","..issuer..","..amount..","..claimer..","..state..","..faction..","..realm..","..realm_chan..","..guild_chan..","..private_chan
  
    return msg
end

function RBH_RejectBounty(msg)
    local id,timestamp,name,issuer,amount,claimer,state,faction,realm,realm_chan,guild_chan,private_chan
    id,timestamp,name,issuer,amount,claimer,state,faction,realm,realm_chan,guild_chan,private_chan = string.split(",",msg) 
    
    if (tonumber(amount) < RBH_Config["MinAmount"]) then
        return true
    end
    if (faction == "Horde" and RBH_Config["RejectHorde"]) then
        return true
    end
    if (faction == "Alliance" and RBH_Config["RejectAlliance"]) then
        return true
    end
    if (faction == "UNKNOWN" and RBH_Config["RejectUnknown"]) then
        return true
    end
    
    local daysOld = (time()- tonumber(timestamp))/86400
    
    if (daysOld > RBH_Config["MaxAge"]) then
        return true
    end
end