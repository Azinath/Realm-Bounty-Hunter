MAX_QT_BOUNTIES = 100

function RBH_AddBounty(name,realm,amount,faction,zone,class,split,lock,seq)   
   
    if RBH_HitList == nil then 
        RBH_HitList = {}
    end
    
    if RBH_Intel == nil then
        RBH_Intel = {}
    end
   
    if name == nil then
        return
    end    
      
    local player
	--local prealm
	--player, prealm = UnitFullName("player")
	--player = player.."-"..prealm
    player = RBH_GetFullName(UnitName("player"))
	
    local timestamp = time()
    
    --create time based unique id
    local timeID = timestamp - 1200000000
    
    --create global to enforce uniqueness
    if RBH_LastBountyId == nil then
        RBH_LastBountyId = 0
    end
    
    --test for temporal anomolies
    if timeID == RBH_LastBountyId then
        timeID = timeID + 1
    end
    
    --append the player's name
    local id = player.."_"..timeID
    
    local state = "RBH_OPEN"
    local claimer = ""
    local issuer = player
    local xcoord,ycoord,intelage,guild
    local audit = 0
    local gsc
    local guid
   
    if seq ~= nil then
        id = id..seq
    end
   
    --handle special bounty options
    if split == nil and lock == nil then
        state = "RBH_OPEN"
    elseif split and lock then
        state = "RBH_OPEN_SL"
    elseif split then
        state = "RBH_OPEN_S"
    elseif lock then
        state = "RBH_OPEN_L"
    end 
   
    --handle cross realm names
    --local n1,n2,destName,destRealm = string.find(name,"(.+)-(.+)")
    --if destName == nil then
    --    destName = name
    --    destRealm = GetRealmName()
    --end 
   
    --if UnitName("target") == destName then    
    if UnitName("target") == name then
        faction = UnitFactionGroup("target")
        --name,realm = UnitName("target")
        level = UnitLevel("target")
        race = UnitRace("target")
        class = UnitClass("target")    
        zone = GetRealZoneText("player")
        xcoord,ycoord = GetPlayerMapPosition("player");
        xcoord = floor(xcoord*100)
        ycoord = floor(ycoord*100)
        intelage = time()
        guild = GetGuildInfo("target")
        guid = UnitGUID("target")
    else
        if faction == nil then
            faction = UnitFactionGroup(name)      
        end
    end   
    if faction == nil then
        faction = "UNKNOWN"
    end
    if realm == nil then
        realm = GetRealmName()
    end
    if zone == nil then
        zone = ""
    end   
    if xcoord == nil then
        xcoord = 0
    end
    if ycoord == nil then
        ycoord = 0
    end
    if intelage == nil then
        intelage = 0
    end
    if class == nil then
        class = ""
    end
    if race == nil then
        race = ""
    end
    if level == nil then
        level = ""
    end
    if guild == nil then
        guild = ""
    end
    
    local realmChannel
    if RBH_Config["RealmChannel"] then
        realmChannel = RBH_REALM_CHANNEL
    else
        realmChannel = ""
    end
        
    local guildChannel
    if RBH_Config["GuildChannel"] then
        guildChannel = GetGuildInfo("player")        
    end
    if guildChannel == nil then
        guildChannel = ""
    end
    
    local privateChannel
    if RBH_Config["PrivateChannel"] then
        privateChannel = RBH_PRIVATE_CHANNEL
    else
        privateChannel = ""
    end   
 
    --add bounty message
    RBH_LargessMessage("[RBH] Bounty placed on "..name.." for "..RBH_CopperToGold(amount), "sys")      
    local msg = id..","..timestamp..","..name..","..issuer..","..amount..","..claimer..","..state..","..faction..","..realm..","..realmChannel..","..guildChannel..","..privateChannel
    table.insert(RBH_HitList,{id=id,name=name,amount=amount,issuer=player,timestamp=timestamp,state=state,claimer=claimer,faction=faction,realm=realm,realm_chan=realmChannel,guild_chan=guildChannel,private_chan=privateChannel});   
    --local msg = id..","..timestamp..","..name..","..issuer..","..amount..","..claimer..","..state..","..audit..","..faction..","..realm..","..zone..","..xcoord..","..ycoord..","..intelage
    RBH_Largess = RBH_Largess - amount   
    RBH_SendAddonMessageToNetwork("BULK", "RBH_HL_UPDATE", msg) 
    
    --create intel message
    local fullName = name.."-"..realm
    local intelMsg = name..","..realm..","..faction..","..class..","..race..","..level..","..guild..","..zone..","..xcoord..","..ycoord..","..intelage
    if (RBH_Intel[fullName] == nil) then
        RBH_Intel[fullName] = {}
    end
    if (RBH_Intel[fullName].faction == "UNKNOWN" or RBH_Intel[fullName].faction == nil) then
        RBH_Intel[fullName].faction = faction
    end
    if (RBH_Intel[fullName].class == "" or RBH_Intel[fullName].class == nil) then
        RBH_Intel[fullName].class = class
    end
    if (RBH_Intel[fullName].race == "" or RBH_Intel[fullName].race == nil) then
        RBH_Intel[fullName].race = race
    end
    if (RBH_Intel[fullName].level == "" or RBH_Intel[fullName].level == nil) then
        RBH_Intel[fullName].level = level
    end
    if (RBH_Intel[fullName].guild == "" or RBH_Intel[fullName].guild == nil) then
        RBH_Intel[fullName].guild = guild
    end
    if (RBH_Intel[fullName].zone == "" or RBH_Intel[fullName].zone == nil) then
        RBH_Intel[fullName].zone = zone
    end
    if (RBH_Intel[fullName].xcoord == "" or RBH_Intel[fullName].xcoord == nil) then
        RBH_Intel[fullName].xcoord = xcoord
    end
    if (RBH_Intel[fullName].ycoord == "" or RBH_Intel[fullName].ycoord == nil) then
        RBH_Intel[fullName].ycoord = ycoord
    end
    if (RBH_Intel[fullName].intelage == nil) then
        RBH_Intel[fullName].intelage = 0
    end
    if (guid ~= nil) then
        RBH_Intel[fullName].guid = guid
    end
    if (intelage > RBH_Intel[fullName].intelage) then
        RBH_Intel[fullName].intelage = tonumber(intelage)
        RBH_SendAddonMessageToNetwork("BULK", "RBH_INTEL_UPDATE", intelMsg)    
    end
    
    RBH_HitListUpdate()
end

function RBH_DeleteBounty()    
    
    if RBH_SelectedBountyId == nil then
        return
    end
    
    local id = RBH_SelectedBountyId
    local i 
   
   for i = 1,#RBH_HitList do    
      if RBH_HitList[i].id == id then
        if (RBH_HitList[i].issuer ~= RBH_GetFullName(UnitName("player")) and
           RBH_HitList[i].issuer ~= RBH_RemoveWhiteSpace(RBH_GetFullName(UnitName("player")))) or 
           RBH_HitList[i].state == RBH_CLAIMED then
            RBH_LargessMessage("You can only delete bounties that you have issued.", "red")
            return
         end
         RBH_HitList[i].state = "RBH_DEL"
         RBH_HitList[i].timestamp = time()
         local amount = RBH_HitList[i].amount
         RBH_Largess = RBH_Largess + amount
         RBH_HitListUpdate()
         local msg = RBH_BountyToString(i)
         RBH_SendAddonMessageToNetwork("ALERT","RBH_HL_UPDATE", msg);  
         
         -- increment GUI selection         
         if RBH_HitListFiltered[RBH_SelectedBounty] ~= nil then
            RBH_SelectedBountyId = RBH_HitListFiltered[RBH_SelectedBounty].id 
            RBH_BountyListOnShow()
         else
            RBH_SelectedBountyId = nil
         end
         
         return  --assumes unique ids
      end
   end  
 end
 
function RBH_CopperToGold(copper)
    local gp,sp,cp,gsp;    
    gp = floor(tonumber(copper)/10000);
    sp = abs(floor(mod(tonumber(copper),10000)/100));   
    cp = abs(mod(mod(tonumber(copper),10000),100));    
    gsp = tostring(gp).."g "..tostring(sp).."s "..tostring(cp).."c";
    return gsp;
end

-- Add Bounty Frame
function RBH_AddBountyFrameOnShow(self, data, data2)       
    local name, realm = UnitFullName("target")  
    local faction = UnitFactionGroup("target")
    
    if (realm == nil) then
        realm = GetRealmName()
    end    
    
    local money = MoneyInputFrame_GetCopper(RBH_AddBountyFrameTotalAmount)       
    
    if name then 
        RBH_AddBountyFrameNameBox:SetText(name) 
    end
    
    if realm then
        RBH_AddBountyFrameRealmBox:SetText(realm)
    end
    
    if faction then
        if faction == "Horde" then
            RBH_FactionSelectButtonIcon:SetTexture("interface\\targetingframe\\ui-pvp-horde.blp")
            RBH_ADD_BOUNTY_FACTION = "Horde"
        elseif faction == "Alliance" then        
            RBH_FactionSelectButtonIcon:SetTexture("interface\\targetingframe\\ui-pvp-alliance.blp")
            RBH_ADD_BOUNTY_FACTION = "Alliance"
        end
    else
        if UnitFactionGroup("player") == "Alliance" then
            RBH_FactionSelectButtonIcon:SetTexture("interface\\targetingframe\\ui-pvp-horde.blp")
            RBH_ADD_BOUNTY_FACTION = "Horde"
        else
            RBH_FactionSelectButtonIcon:SetTexture("interface\\targetingframe\\ui-pvp-alliance.blp")
            RBH_ADD_BOUNTY_FACTION = "Alliance"
        end
    end
    
    if (money > 0 and name ~= "" and realm ~= "") then
        RBH_AddBountyFramePlaceBounties:Enable()
    else
        RBH_AddBountyFramePlaceBounties:Disable()
    end      
end

function RBH_AddBountyFrameOnUpdate(self, elapsed)  
    local money = MoneyInputFrame_GetCopper(RBH_AddBountyFrameAmount) 
    local name = RBH_AddBountyFrameNameBox:GetText()
    local realm = RBH_AddBountyFrameRealmBox:GetText()
    local quantity = RBH_AddBountyFrameQtBox:GetText()
    quantity = tonumber(quantity)
    if quantity ~= nil then
        local amount = MoneyInputFrame_GetCopper(RBH_AddBountyFrameAmount)        
        MoneyInputFrame_SetCopper(RBH_AddBountyFrameTotalAmount, amount*quantity)
    end  
    
    if (money > 0 and name ~= "" and realm ~= "") then
        RBH_AddBountyFramePlaceBounties:Enable()
    else
        RBH_AddBountyFramePlaceBounties:Disable()
    end  
    
end

function RBH_AddBountyFrameOnAccept()
    local name = RBH_AddBountyFrameNameBox:GetText()
    local realm = RBH_AddBountyFrameRealmBox:GetText()
    local money = MoneyInputFrame_GetCopper(RBH_AddBountyFrameTotalAmount)
    local quantity = RBH_AddBountyFrameQtBox:GetText()
    local amount = MoneyInputFrame_GetCopper(RBH_AddBountyFrameAmount)    
    local i  
    
    --need to remove these variables
    local split = false
    local lock = false
    
    --RBH_LargessMessage("Accept")
    quantity = tonumber(quantity)
    
    if quantity == nil then 
        return             
    end  
    
    for i = 1, quantity do
        rbh_debug(amount..":"..RBH_Largess)
        if RBH_Largess >= amount then
            if RBH_ADD_BOUNTY_FACTION == nil then
                RBH_ADD_BOUNTY_FACTION = "UNKNOWN"
            end
            RBH_AddBounty(name, realm, amount, RBH_ADD_BOUNTY_FACTION, nil, nil, split, lock, i)            
        else
            RBH_LargessMessage("You do not have enough money.","red")             
            return
        end  
    end
    
    RBH_AddBountyFrame:Hide()
end

function RBH_IncrementBountyQt()
    local qt = tonumber(RBH_AddBountyFrameQtBox:GetText())
    
    if (qt + 1 > MAX_QT_BOUNTIES) then
        qt = MAX_QT_BOUNTIES
    else
        qt = qt + 1
    end
    
    RBH_AddBountyFrameQtBox:SetText(tostring(qt))
end

function RBH_DecrementBountyQt()
    local qt = tonumber(RBH_AddBountyFrameQtBox:GetText())
    
    if (qt - 1 <= 0) then
        qt = 1
    else
        qt = qt -1
    end
    
    RBH_AddBountyFrameQtBox:SetText(tostring(qt))
end

function RBH_ValidateBountyQt()
    local qt = tonumber(RBH_AddBountyFrameQtBox:GetText())
    
    if (qt + 1 > MAX_QT_BOUNTIES) then
        RBH_AddBountyFrameQtBox:SetText(tostring(MAX_QT_BOUNTIES))    
    end  
end
 
function RBH_MarkBountyAsPaid()
     if RBH_SelectedBountyId == nil then
        return
    end
    
    local id = RBH_SelectedBountyId
    local i 
   
   for i = 1,#RBH_HitList do    
      if RBH_HitList[i].id == id then
        if RBH_HitList[i].claimer ~= RBH_GetFullName(UnitName("player")) then
            RBH_LargessMessage("You can only mark bounties as paid that you have claimed.", "red")
            return
         end
         RBH_HitList[i].state = "RBH_PAID"
         RBH_HitList[i].timestamp = time()
         RBH_BountyFilterFrameMarkAsPaid:SetEnabled(false)
         if (RBH_HitList[i].issuer == RBH_GetFullName(UnitName("player"))) then
             local amount = RBH_HitList[i].amount
             RBH_Largess = RBH_Largess + amount
         end
         RBH_HitListUpdate()
         local msg = RBH_BountyToString(i)
         RBH_SendAddonMessageToNetwork("ALERT","RBH_HL_UPDATE", msg);   
         
         return  --assumes unique ids
      end
   end  
 end
 
function RBH_EnterFactionSelectButton(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
    GameTooltip:ClearLines()
    GameTooltip:AddLine("Faction Selection")
    GameTooltip:AddLine("Click this to change the bounty target's faction",1,1,1)
    GameTooltip:Show()             
end
 
function RBH_LeaveFactionSelectButton()
   GameTooltip:Hide()
end
    
function RBH_FactionSelectButtonOnClick()
    if RBH_ADD_BOUNTY_FACTION == "Horde" then
        RBH_FactionSelectButtonIcon:SetTexture("interface\\targetingframe\\ui-pvp-alliance.blp")
        RBH_ADD_BOUNTY_FACTION = "Alliance"
    elseif RBH_ADD_BOUNTY_FACTION == "Alliance" then
        RBH_FactionSelectButtonIcon:SetTexture("interface\\targetingframe\\ui-pvp-horde.blp")
        RBH_ADD_BOUNTY_FACTION = "Horde"
    end
    --RBH_FactionSelectButtonIcon:SetTexture("interface\\targetingframe\\targetdead")    
    --RBH_ADD_BOUNTY_FACTION = "Unknown"
end

function RBH_AddBGBounties(amount)
   local n = GetNumBattlefieldScores()
   local i,name, killingBlows, honorableKills, deaths, honorGained, faction, rank, race, class, damageDone, healingDone 
   local zone = GetRealZoneText();
   local factionName
   
   for i = 1,n do     
      name,killingBlows,honorableKills,deaths,honorGained,faction, rank, race, class, damageDone, healingDone = GetBattlefieldScore(i)
      if (faction == 0 and RBH_PlayerFaction == "Alliance") or (faction == 1 and RBH_PlayerFaction == "Horde") then
         --handle cross realm names
         local n1,n2,destName,destRealm = string.find(name,"(.+)-(.+)")
         if destName == nil then
            destName = name
            destRealm = GetRealmName()
         end      
         if (faction == 1) then
            factionName = "Alliance"
         else
            factionName = "Horde"
         end
         RBH_AddBounty(destName,destRealm,amount,factionName,zone,class,split,lock,i)         
      end
   end
end