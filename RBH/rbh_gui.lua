RBH_NUM_HITLIST_ENTRIES = 14
RBH_NUM_ITEMLARGESS_ENTRIES = 8
RBH_NUM_AUDIT_HISTORY_ENTRIES = 8
RBH_SelectedBounty = -1
RBH_BountyFilters = {}
RBH_BountyFilters.ShowHorde = true
RBH_BountyFilters.ShowAlliance = true
RBH_BountyFilters.ShowOpen = true
RBH_BountyFilters.ShowClaimed = true
RBH_BountyFilters.ShowPaid = true
RBH_BountyFilters.ShowRealmChannel = true
RBH_BountyFilters.ShowGuildChannel = true
RBH_BountyFilters.ShowPrivateChannel = true
RBH_MAX_MAX_AGE = 9999

----------------------
--  Minimap Button  --
----------------------
do
	local dragMode = nil
	
	local function moveButton(self)
		if dragMode == "free" then
			local centerX, centerY = Minimap:GetCenter()
			local x, y = GetCursorPosition()
			x, y = x / self:GetEffectiveScale() - centerX, y / self:GetEffectiveScale() - centerY
			self:ClearAllPoints()
			self:SetPoint("CENTER", x, y)
		else
			local centerX, centerY = Minimap:GetCenter()
			local x, y = GetCursorPosition()
			x, y = x / self:GetEffectiveScale() - centerX, y / self:GetEffectiveScale() - centerY
			centerX, centerY = math.abs(x), math.abs(y)
			centerX, centerY = (centerX / math.sqrt(centerX^2 + centerY^2)) * 80, (centerY / sqrt(centerX^2 + centerY^2)) * 80
			centerX = x < 0 and -centerX or centerX
			centerY = y < 0 and -centerY or centerY
			self:ClearAllPoints()
			self:SetPoint("CENTER", centerX, centerY)
		end
	end

	local button = CreateFrame("Button", "RBHMinimapButton", Minimap)
	button:SetHeight(32)
	button:SetWidth(32)
	button:SetFrameStrata("MEDIUM")
	button:SetPoint("CENTER", -65.35, -38.8)
	button:SetMovable(true)
	button:SetUserPlaced(true)
	button:SetNormalTexture("interface\\lootframe\\lootpanel-icon")
	button:SetPushedTexture("interface\\lootframe\\lootpanel-icon")
	--button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

	button:SetScript("OnMouseDown", function(self, button)
		if IsShiftKeyDown() and IsAltKeyDown() then
			dragMode = "free"
			self:SetScript("OnUpdate", moveButton)
		elseif IsShiftKeyDown() then
			dragMode = nil
			self:SetScript("OnUpdate", moveButton)
        elseif button == "RightButton" then
            RBH_BuyBounty()
		end
	end)
	button:SetScript("OnMouseUp", function(self)
		self:SetScript("OnUpdate", nil)
	end)
	button:SetScript("OnClick", function(self, button)
		if IsShiftKeyDown() then return end        
        RBH_ToggleHitList()
	end)
	button:SetScript("OnEnter", function(self)
		GameTooltip_SetDefaultAnchor(GameTooltip, self)
		GameTooltip:SetText("Realm Bounty Hunter")
        GameTooltip:AddLine("Left Click to toggle RBH",1,1,1)
        GameTooltip:AddLine("Right Click to place a bounty",1,1,1)
        GameTooltip:AddLine("Shift+Click to move this button on the minimap",1,1,1)
        GameTooltip:AddLine("Shift+Alt+Click to move this button anywhere",1,1,1)
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)

	function RBH_ToggleMinimapButton()
		self.Options.ShowMinimapButton = not self.Options.ShowMinimapButton
		if self.Options.ShowMinimapButton then
			button:Show()
		else
			button:Hide()
		end
	end

	function RBH_HideMinimapButton()
		return button:Hide()
	end
end

function RBH_ToggleHitList()
    if (RBH_HitListFrame:IsShown()) then
        RBH_HitListFrame:Hide();
    else
        RBH_HitListFrame:Show();
    end
end

function RBH_EntryOnClick(self)   
    local i = self.index
    RBH_SelectedBounty = i
    RBH_SelectedBountyId = RBH_HitListFiltered[i].id   
    RBH_HitListUpdate()
    
    rbh_debug("Selected Bounty: id="..RBH_SelectedBountyId..", issuer="..RBH_HitListFiltered[i].issuer)
    
    --set state of delete bounty button
    if ((RBH_HitListFiltered[i].issuer ==  RBH_GetFullName(UnitName("player")) or
        RBH_HitListFiltered[i].issuer == RBH_RemoveWhiteSpace(RBH_GetFullName(UnitName("player"))))) and
        RBH_HitListFiltered[i].state ~= "RBH_CLAIMED" then
        RBH_BountyFilterFrameDeleteBounty:SetEnabled(true)         
    else
        RBH_BountyFilterFrameDeleteBounty:SetEnabled(false)        
    end 
    
    --set state of Bounty Paid button
    if (RBH_HitListFiltered[i].claimer == RBH_GetFullName(UnitName("player"))) 
        and RBH_HitListFiltered[i].state == "RBH_CLAIMED" then
        RBH_BountyFilterFrameMarkAsPaid:SetEnabled(true)
    else
        RBH_BountyFilterFrameMarkAsPaid:SetEnabled(false)
    end
end   

--tooltip for hit list entry 
function RBH_EnterHitListEntry(self)   
    local i = self.index
    local issuer = RBH_HitListFiltered[i].issuer
    local claimer = RBH_HitListFiltered[i].claimer
    local realm = RBH_HitListFiltered[i].realm
    local level = RBH_HitListFiltered[i].level
    local class = RBH_HitListFiltered[i].class
    local race = RBH_HitListFiltered[i].race
    local zone = RBH_HitListFiltered[i].zone
    local xcoord = RBH_HitListFiltered[i].xcoord
    local ycoord = RBH_HitListFiltered[i].ycoord
    local intelage = RBH_HitListFiltered[i].intelage
    local name = RBH_HitListFiltered[i].name   
    local guild = RBH_HitListFiltered[i].guild
    local id = RBH_HitListFiltered[i].id
   
    if faction == nil then
        faction = "UKNOWN"
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

    --GameTooltip_SetDefaultAnchor(GameTooltip, self)    
    --GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT",0,0)
    --GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT",0,0)
    --GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT",-350,0)
    GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT",-60,0)
    
    --set name in tooltip
    local namestr = name
    if realm ~= nil and realm ~= "" then
        namestr = namestr.."-"..realm
    end    
    GameTooltip:SetText(namestr)
    
    --set guild in tooltip
    local guildstr = ""
    if guild ~= nil and guild ~= "" then
        guildstr = "<"..guild..">"
    end
    if guildstr ~= "" then
        GameTooltip:AddLine(guildstr,1,1,1)
    end
    
    --set lvl race class in tooltip
    local str = "" 
    if level ~= nil and level ~= "" then
        str = "Level "..level.." "
    end
    if race ~= nil and race ~= "" then
        str = str..race.." "
    end
    if class ~= nil and class ~= "" then
        str = str..RBH_FormatClassName(class)
    end  
    if str ~= "" then
        GameTooltip:AddLine(str,1,1,1)
    end
    
    --set intel data in tooltip
    if zone ~= nil and zone ~= "" and intelage ~= nil then
        if intelage ~= nil and intelage > 0 then
            local age = SecondsToTime(time()-intelage)
            GameTooltip:AddLine("Last seen in "..zone.." "..age.." ago",1,1,1)
        end
    end
    GameTooltip:AddLine("Issued by: "..issuer,1,1,1)
    if (claimer ~= "") then
        GameTooltip:AddLine("Claimed by: "..claimer,1,1,1)    
    end
    
    --set note if there is one
    if RBH_Notes[id] ~= nil then
        GameToolTip:AddLine(RBH_Notes[id].note,1,1,0)
    end
    
    GameTooltip:Show()
end  

function RBH_FormatClassName(class)
    if class == "DEATHKNIGHT" then
        return "Death Knight"
    elseif class == "DRUID" then
        return "Druid"
    elseif class == "HUNTER" then
        return "Hunter"
    elseif class == "MAGE" then
        return "Mage"
    elseif class == "ROGUE" then
        return "Rogue"
    elseif class == "SHAMAN" then
        return "Shaman"
    elseif class == "PALADIN" then
        return "Paladin"
    elseif class == "PRIEST" then
        return "Priest"
    elseif class == "WARLOCK" then
        return "Warlock"
    elseif class == "WARRIOR" then
        return "Warrior"
	elseif class == "MONK" then
		return "Monk"
    elseif class == "DEMONHUNTER" then
        return "Demon Hunter"
    else
        return class
    end
end

function RBH_UnformatClassName(class)
    if class == "Death Knight" then
        return "DEATHKNIGHT"
    elseif class == "Druid" then
        return "DRUID"
    elseif class == "Hunter" then
        return "HUNTER"
    elseif class == "Mage" then
        return "MAGE"
    elseif class == "Rogue" then
        return "ROGUE"
    elseif class == "Shaman" then
        return "SHAMAN"
    elseif class == "Paladin" then
        return "PALADIN"
    elseif class == "Priest" then
        return "PRIEST"
    elseif class == "Warlock" then
        return "WARLOCK"
    elseif class == "Warrior" then
        return "WARRIOR"
	elseif class == "Monk" then
		return "MONK"
    elseif class == "Demon Hunter" then
        return "DEMONHUNTER"
    else
        return class
    end
end

function RBH_ExitHitListEntry(self)
    GameTooltip:Hide()
end

function RBH_CreateGUI()
   local i,frame,textString,moneyFrame   
   
   --Set Column Header Widths (kludgey adaptation to 4.0.1 guild roster)
   --bounty list
   RBH_ColumnHeaderFactionMiddle:SetWidth(31-9)
   RBH_ColumnHeaderNameMiddle:SetWidth(78-9)
   RBH_ColumnHeaderStateMiddle:SetWidth(64-9)
   RBH_ColumnHeaderBountyMiddle:SetWidth(140-9)   
   RBH_ListFrame:EnableMouse()
   RBH_ListFrame:EnableMouseWheel(1)   
   RBH_ListFrame:SetScript("OnShow",RBH_HitListUpdate) 
   RBH_ListFrame:Show()   
   MoneyFrame_Update(RBH_LargessAmountFrame, RBH_Largess); 
   RBH_LargessAmountFrame:SetScript("OnUpdate",function() RBH_GuiUpdate() end)
   
   --List Entry Frames (faux scroll frames)
   for i = 0,RBH_NUM_HITLIST_ENTRIES-1 do       
      frame = CreateFrame("Button","RBH_ListEntry"..i,RBH_ListFrame,"RBH_EntryTemplate")
      frame:SetPoint("TOPLEFT",0,-i*17)
      frame:Show() 
   end 
   RBH_ListEntryNormalTexture = frame:GetNormalTexture()
   RBH_UIFrame:SetPoint("TOPLEFT",-5,2)  
   
   -- set add bounty quantity default
   RBH_AddBountyFrameQtBox:SetText("1")  
end

function RBH_HitListUpdate()
   local i,dataOffset,offset,n,m
   local moneyFrame,textString,entryFrame,statusFrameTexture,factionTexture  
   
   RBH_FilterHitList()
   n = #RBH_HitListFiltered     
   FauxScrollFrame_Update(RBH_ListFrame,n,RBH_NUM_HITLIST_ENTRIES,17,nil,nil,nil,nil,nil,nil,true);
   offset = FauxScrollFrame_GetOffset(RBH_ListFrame);
   
   for i = 0,RBH_NUM_HITLIST_ENTRIES-1 do
      dataOffset = offset + i + 1      
      textString = _G["RBH_ListEntry"..i.."_TargetName"]
      moneyFrame = _G["RBH_ListEntry"..i.."_BountyAmount"]
      statusFrameTexture = _G["RBH_ListEntry"..i.."_BountyStatusTexture"]
	  statusFrameLockTexture = _G["RBH_ListEntry"..i.."_BountyLockStatusTexture"]
      factionTexture = _G["RBH_ListEntry"..i.."_TargetFactionTexture"]
      entryFrame = _G["RBH_ListEntry"..i]
      
      if entryFrame == nil or factionTexture == nil or moneyFrame == nil or textString == nil then
        return
      end
      
      if dataOffset <= n then         
         --set faction image
         if (RBH_HitListFiltered[dataOffset].faction) == "UNKNOWN" then
            --factionTexture:SetTexture("interface\\gossipframe\\activequesticon")
            factionTexture:Hide()
            --factionTexture:Show()
         elseif (RBH_HitListFiltered[dataOffset].faction) == "Horde" then
            factionTexture:SetTexture("interface\\targetingframe\\ui-pvp-horde.blp")
            factionTexture:Show()
         elseif (RBH_HitListFiltered[dataOffset].faction) == "Alliance" then
            factionTexture:SetTexture("interface\\targetingframe\\ui-pvp-alliance.blp")
            factionTexture:Show()
         else
            if factionTexture ~= nil then
                factionTexture:Hide()
            end
         end
         --set status image
         if (RBH_HitListFiltered[dataOffset].state == "RBH_OPEN") then
            statusFrameTexture:SetTexture("interface\\minimap\\tracking\\Auctioneer.blp")
            statusFrameLockTexture:Hide()
         elseif (RBH_HitListFiltered[dataOffset].state == "RBH_OPEN_L" ) then
            statusFrameTexture:SetTexture("interface\\minimap\\tracking\\Auctioneer.blp")
            statusFrameLockTexture:Show()		
         elseif (RBH_HitListFiltered[dataOffset].state == "RBH_CLAIMED") then
            statusFrameTexture:SetTexture("interface\\lootframe\\lootpanel-icon")
            if (RBH_HitListFiltered[dataOffset].valid == true) then
                statusFrameLockTexture:SetTexture("interface\\buttons\\UI-CheckBox-Check")
                statusFrameLockTexture:Show()
            else
                statusFrameLockTexture:Hide()
            end
         elseif (RBH_HitListFiltered[dataOffset].state == "RBH_PAID") then
            statusFrameTexture:SetTexture("interface\\minimap\\tracking\\Banker.blp")
            statusFrameLockTexture:Hide()         
         end
         
        --check for lock
        local fullName = RBH_HitListFiltered[dataOffset].name.."-"..RBH_HitListFiltered[dataOffset].realm
        if (RBH_Intel ~= nil and RBH_Intel[fullName] ~= nil) then
            if (( RBH_HitListFiltered[dataOffset].state == "RBH_OPEN" or 
                RBH_HitListFiltered[dataOffset].state == "RBH_CLAIMED" ) and            
                RBH_HitListFiltered[dataOffset].valid == false and 
                RBH_Intel[fullName].guid ~= nil ) then
                statusFrameLockTexture:SetTexture("interface\\LFGFRAME\\UI-LFG-ICON-LOCK.png")
                statusFrameLockTexture:Show()
            end
        end
        --hide lock if player is the issuer
        if (RBH_HitListFiltered[dataOffset].issuer ~= RBH_GetFullName("player")) then
            statusFrameLockTexture:Hide()
        end
        
         --set bounty money
         MoneyFrame_Update(moneyFrame, RBH_HitListFiltered[dataOffset].amount);
         --set target name
         textString:SetText(RBH_HitListFiltered[dataOffset].name)
		 
		 --set target class color
		 if RBH_Config["ClassColors"] then
             local class = RBH_UnformatClassName(RBH_HitListFiltered[dataOffset].class)
		     local color = RAID_CLASS_COLORS[class]
             if color ~= nil then
                textString:SetTextColor(color.r, color.g, color.b)
             end
		 end
		 
         entryFrame.index = dataOffset
         if RBH_SelectedBounty == dataOffset then
            --set selected texture            
            entryFrame:LockHighlight()
         else
             --reset normal texture
            entryFrame:UnlockHighlight()
         end        
         entryFrame:Show()         
      else
         entryFrame:Hide()                
      end        
   end    
end

function RBH_CreateFriendsTab()   
   FriendsFrameTab6 = CreateFrame("Button", "FriendsFrameTab" ..6, FriendsFrame, "FriendsFrameTabTemplate");
   FriendsFrameTab6:SetPoint("LEFT", "FriendsFrameTab" .. 5, "RIGHT", -14, 0);
   FriendsFrameTab6:SetID(6);
   PanelTemplates_SetNumTabs(FriendsFrame, 6);
   PanelTemplates_UpdateTabs(FriendsFrame);
   FriendsFrameTab6:SetPoint("LEFT", "FriendsFrameTab" .. 5, "RIGHT", -14, 0);
   FriendsFrameTab6:SetText("RBH")
   TabID = 6

   -- add ourself to the subframe list....
   tinsert(FRIENDSFRAME_SUBFRAMES, "RBH_UIFrame");

   hooksecurefunc("FriendsFrame_Update", RBH_FriendsFrame_Update);
end

function RBH_FriendsFrame_Update()
   if(FriendsFrame.selectedTab == 6) then
      FriendsFrameTitleText:SetText("Realm Bounty Hunter");
      if(RBH_UIFrame:IsVisible()) then
         return;
      end
      FriendsFrameTopLeft:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-TopLeft");
      FriendsFrameTopRight:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-TopRight");
      FriendsFrameBottomLeft:SetTexture("Interface\\FriendsFrame\\GuildFrame-BotLeft");      
      FriendsFrameBottomRight:SetTexture("Interface\\FriendsFrame\\GuildFrame-BotRight");
      
      --RBH_UIFrame:ScrollFrameUpdate();
      RBH_UIFrame:SetParent("FriendsFrame");
      RBH_UIFrame:SetAllPoints();
      RBH_UIFrame:Show();
      
      FriendsFrame_ShowSubFrame("NonExistingFrame"); -- so all friendframe tabs get hidden  
      FriendsFrame_ShowSubFrame("RBH_UIFrame")
   end
end

function RBH_DelayScript(script,delay,id)   
   if id == nil then
      id = "RBH_TimerFrame"
   else
      id = "RBH_TimerFrame"..id
   end
   local f = CreateFrame("Frame",id,UIParent)
   local stop = time() + delay
   f:SetScript("OnUpdate",function() RBH_TimerUpdate(stop,f,script) end)   
end

function RBH_TimerUpdate(stop,self,script)   
   local t = time()    
   if t >= stop then       
      self:SetScript("OnUpdate",nil)
      RunScript(script)
   end   
end

function RBH_SortByName(a,b)    
   if RBH_NAME_SORT then      
      return a.name > b.name
   else      
      return a.name < b.name
   end
end
   
function RBH_SortByAmount(a,b)   
   if RBH_AMOUNT_SORT then
      return tonumber(a.amount) > tonumber(b.amount)   
   else
      return tonumber(a.amount) < tonumber(b.amount) 
   end
end

function RBH_SortByFaction(a,b)
   if a.faction == nil or a.faction == "NPC" then
      return false
   elseif b.faction == nil or b.faction == "NPC" then
      return true
   elseif RBH_FACTION_SORT then
      return a.faction > b.faction
   else
      return a.faction < b.faction
   end
end

function RBH_SortByState(a,b)
   if RBH_STATE_SORT then
      return a.state > b.state
   else
      return a.state < b.state
   end
end

function RBH_FilterHitList()
    local i,name,amount,id,issuer,timestamp,state,claimer,audit,faction,realm,zone,xcoord,ycoord,intelage,class,race,level,guild,realm_chan,guild_chan,private_chan,valid
    local valid
    local n = #RBH_HitList
    RBH_HitListFiltered = {}
   
    for i = 1,n do
        name = RBH_HitList[i].name
        realm = RBH_HitList[i].realm
        amount = RBH_HitList[i].amount   
        id = RBH_HitList[i].id      
        issuer = RBH_HitList[i].issuer
        timestamp = RBH_HitList[i].timestamp
        state = RBH_HitList[i].state
        claimer = RBH_HitList[i].claimer      
        faction = RBH_HitList[i].faction      
        realm_chan = RBH_HitList[i].realm_chan
        guild_chan = RBH_HitList[i].guild_chan
        private_chan = RBH_HitList[i].private_chan
        if (RBH_HitList[i].valid == nil) then
            valid = false
        else
            valid = RBH_HitList[i].valid
        end
        local fullName = name.."-"..realm
        if RBH_Intel[fullName] == nil then
            zone = ""
            xcoord = ""
            ycoord = ""
            intelage = ""
            class = ""
            race = ""
            level = ""
            guild = ""
        else
            zone = RBH_Intel[fullName].zone
            xcoord = RBH_Intel[fullName].xcoord
            ycoord = RBH_Intel[fullName].ycoord
            intelage = RBH_Intel[fullName].intelage
            class = RBH_Intel[fullName].class
            race = RBH_Intel[fullName].race
            level = RBH_Intel[fullName].level
            guild = RBH_Intel[fullName].guild
        end
      
        if (not RBH_Config["ShowHorde"] and faction == "Horde") or
            (not RBH_Config["ShowAlliance"] and faction == "Alliance") or
            (not RBH_Config["ShowOpen"] and state == "RBH_OPEN") or 
            (not RBH_Config["ShowClaimed"] and state == "RBH_CLAIMED") or
            (not RBH_Config["ShowPaid"] and state == "RBH_PAID") or         
            (state == "RBH_DEL") then   
                --do nothing
        elseif (RBH_Config["ShowRealmChannel"] and realm_chan == RBH_REALM_CHANNEL) or
            (RBH_Config["ShowGuildChannel"] and guild_chan == RBH_GUILD_CHANNEL) or
            (RBH_Config["ShowPrivateChannel"] and private_chan == RBH_PRIVATE_CHANNEL) then
                table.insert(RBH_HitListFiltered,{id=id,name=name,amount=amount,issuer=issuer,timestamp=timestamp,state=state,claimer=claimer,audit=audit,faction=faction,realm=realm,zone=zone,xcoord=xcoord,ycoord=ycoord,intelage=intelage,class=class,race=race,level=level,guild=guild,valid=valid});
        end 
    end
end

function RBH_GuiUpdate()     
    if RBH_Largess == nil then
        return
    end
    local largess = RBH_Largess 
    if largess < 0 then 
      largess = abs(largess)
      RBH_NegLargess:Show()
    else 
      RBH_NegLargess:Hide()
    end
      --RBH_LargessMessage(largess)
      MoneyFrame_Update(RBH_LargessAmountFrame, largess);      
end

function RBH_EnterBountyListButton(self)
    --GameTooltip_SetDefaultAnchor(GameTooltip,UIParent)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    GameTooltip:ClearLines()
    GameTooltip:AddLine("Bounty List")
    GameTooltip:AddLine("View the bounty list",1,1,1)
    GameTooltip:Show()
end

function RBH_LeaveBountyListButton()
    GameTooltip:Hide()
end

function RBH_DisplayBountyList()       
    RBH_ConfigScrollFrame:Hide()
    --RBH_FactionDetailsScrollFrame:Hide()
    RBH_UIFrame:Show()  
    
    --set portrait icon
    SetPortraitToTexture(RBH_HitListFrameSkullnXBonesTexture,"interface\\targetingframe\\targetdead")
    --SetPortraitToTexture(RBH_HitListFrameSkullnXBonesTexture,"interface\\icons\\inv_misc_book_06")
    --RBH_HitListFrameSkullnXBones:SetFrameStrata("BACKGROUND")
end

function RBH_BountyListOnShow()  
    if (RBH_SelectedBounty == nil) then
        RBH_BountyFilterFrameMarkAsPaid:SetEnabled(false)
        RBH_BountyFilterFrameDeleteBounty:SetEnabled(false)
        return
    end
    
    if (RBH_HitListFiltered[RBH_SelectedBounty]) == nil then
        RBH_BountyFilterFrameMarkAsPaid:SetEnabled(false)
        RBH_BountyFilterFrameDeleteBounty:SetEnabled(false)
        return
    end
    
    --set state of delete bounty button
    if ((RBH_HitListFiltered[RBH_SelectedBounty].issuer ==  RBH_GetFullName(UnitName("player")) or
        RBH_HitListFiltered[RBH_SelectedBounty].issuer ==  RBH_RemoveWhiteSpace(RBH_GetFullName(UnitName("player"))))) and
        RBH_HitListFiltered[RBH_SelectedBounty].state ~= "RBH_CLAIMED" then
        RBH_BountyFilterFrameDeleteBounty:SetEnabled(true)         
    else
        RBH_BountyFilterFrameDeleteBounty:SetEnabled(false)        
    end 
    
    --set state of Bounty Paid button
    if (RBH_HitListFiltered[RBH_SelectedBounty].claimer == RBH_GetFullName(UnitName("player"))) 
        and RBH_HitListFiltered[RBH_SelectedBounty].state == "RBH_CLAIMED" then
        RBH_BountyFilterFrameMarkAsPaid:SetEnabled(true)
    else
        RBH_BountyFilterFrameMarkAsPaid:SetEnabled(false)
    end
end

function RBH_EnterTrophyBagButton(self)  
    --GameTooltip_SetDefaultAnchor(GameTooltip,UIParent)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    GameTooltip:ClearLines()
    GameTooltip:AddLine("Trophy Bag")
    GameTooltip:AddLine("Contains the heads of all your bounty kills",1,1,1)
    GameTooltip:AddLine("This feature has been disabled",1,0,0)
    GameTooltip:Show()
end

function RBH_LeaveTrophyBagButton()
    GameTooltip:Hide()
end   

function RBH_EnterIntelButton(self)
    --GameTooltip_SetDefaultAnchor(GameTooltip,UIParent)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    GameTooltip:ClearLines()
    GameTooltip:AddLine("Gather Intelligence")
    GameTooltip:AddLine("Spy on bounty targets of your current faction",1,1,1)
    GameTooltip:AddLine("This feature has been disabled",1,0,0)
    GameTooltip:Show()
end

function RBH_LeaveIntelButton()
    GameTooltip:Hide()
end

function RBH_EnterConfigButton(self)
    --GameTooltip_SetDefaultAnchor(GameTooltip,UIParent)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    GameTooltip:ClearLines()
    GameTooltip:AddLine("Configuration")
    GameTooltip:AddLine("Change some RBH settings",1,1,1)
    GameTooltip:Show()
end

function RBH_LeaveConfigButton()
    GameTooltip:Hide()
end

function RBH_IntelOnClick()
    
end

function RBH_ConfigChannels()
    RBH_Config["RealmChannel"] = RBH_ConfigFormCheckRealmChannel:GetChecked()
    RBH_Config["GuildChannel"] = RBH_ConfigFormCheckGuildChannel:GetChecked()
    RBH_Config["PrivateChannel"] = RBH_ConfigFormCheckPrivateChannel:GetChecked()
    
    if (RBH_Config["RealmChannel"]) then
        JoinPermanentChannel(RBH_REALM_CHANNEL)
    else
        LeaveChannelByName(RBH_REALM_CHANNEL)
    end
       
    if (RBH_Config["PrivateChannel"]) then
        JoinPermanentChannel(RBH_PRIVATE_CHANNEL, RBH_PRIVATE_PASSWORD)		
    else
        LeaveChannelByName(RBH_PRIVATE_CHANNEL)
    end
end

function RBH_ConfigFormOnShow(self)
    RBH_ConfigFormCheckRealmChannel:SetChecked(RBH_Config["RealmChannel"])
    RBH_ConfigFormCheckGuildChannel:SetChecked(RBH_Config["GuildChannel"])
    RBH_ConfigFormCheckPrivateChannel:SetChecked(RBH_Config["PrivateChannel"])
    RBH_ConfigFormChannelNameBox:SetText(RBH_PRIVATE_CHANNEL)
    RBH_ConfigFormPasswordBox:SetText(RBH_PRIVATE_PASSWORD)
    RBH_ConfigFormPrivateChannelEditBtn:SetEnabled(true)
    RBH_ConfigFormChannelNameBox:SetEnabled(false)
    RBH_ConfigFormPasswordBox:SetEnabled(false)
    RBH_ConfigFormPrivateChannelSaveBtn:SetEnabled(false)
    RBH_ConfigFormPrivateChannelCancelBtn:SetEnabled(false)
    RBH_ConfigFormRejectHorde:SetChecked(RBH_Config["RejectHorde"])
    RBH_ConfigFormRejectAlliance:SetChecked(RBH_Config["RejectAlliance"])
    RBH_ConfigFormRejectUnknown:SetChecked(RBH_Config["RejectUnknown"])
    MoneyInputFrame_SetCopper(RBH_ConfigFormMinAmount, RBH_Config["MinAmount"])    
    RBH_ConfigFormMaxAge:SetText(RBH_Config["MaxAge"])
    
end

function RBH_ConfigFormOnUpdate(self)
    RBH_Config["MinAmount"] = MoneyInputFrame_GetCopper(RBH_ConfigFormMinAmount)
end

function RBH_ConfigFormMaxAgeInc()
    RBH_Config["MaxAge"] = RBH_Config["MaxAge"] + 1
    RBH_ConfigFormMaxAge:SetText(tostring(RBH_Config["MaxAge"]))
end

function RBH_ConfigFormMaxAgeDec()
    RBH_Config["MaxAge"] = RBH_Config["MaxAge"] - 1
    RBH_ConfigFormMaxAge:SetText(tostring(RBH_Config["MaxAge"]))
end

function RBH_ConfigFormValidateMaxAge()
    local age = tonumber(RBH_ConfigFormMaxAge:GetText())
    
    if (age == nil) then
        return
    end
    
    if (age + 1 > RBH_MAX_MAX_AGE) then
        RBH_Config["MaxAge"] = RBH_MAX_MAX_AGE            
    elseif (age - 1 < 1) then
        RBH_Config["MaxAge"] = 1
    else
        RBH_Config["MaxAge"] = age
    end
    
    RBH_ConfigFormMaxAge:SetText(tostring(RBH_Config["MaxAge"]))
end

function RBH_EditPrivateChannel()
    RBH_ConfigFormPrivateChannelEditBtn:SetEnabled(false)
    RBH_ConfigFormChannelNameBox:SetEnabled(true)
    RBH_ConfigFormPasswordBox:SetEnabled(true)
    RBH_ConfigFormPrivateChannelSaveBtn:SetEnabled(true)
    RBH_ConfigFormPrivateChannelCancelBtn:SetEnabled(true)
end

function RBH_SavePrivateChannel()
    RBH_ConfigFormPrivateChannelEditBtn:SetEnabled(true)
    RBH_ConfigFormChannelNameBox:SetEnabled(false)
    RBH_ConfigFormPasswordBox:SetEnabled(false)
    RBH_ConfigFormPrivateChannelSaveBtn:SetEnabled(false)
    RBH_ConfigFormPrivateChannelCancelBtn:SetEnabled(false)
    LeaveChannelByName(RBH_PRIVATE_CHANNEL)
    RBH_PRIVATE_CHANNEL = RBH_ConfigFormChannelNameBox:GetText()
    RBH_PRIVATE_PASSWORD = RBH_ConfigFormPasswordBox:GetText()
    JoinPermanentChannel(RBH_PRIVATE_CHANNEL, RBH_PRIVATE_PASSWORD)
end

function RBH_CancelPrivateChannel()
    RBH_ConfigFormPrivateChannelEditBtn:SetEnabled(true)
    RBH_ConfigFormChannelNameBox:SetEnabled(false)    
    RBH_ConfigFormPasswordBox:SetEnabled(false)    
    RBH_ConfigFormPrivateChannelSaveBtn:SetEnabled(false)
    RBH_ConfigFormPrivateChannelCancelBtn:SetEnabled(false)    
    RBH_ConfigFormChannelNameBox:SetText(RBH_PRIVATE_CHANNEL)   
    RBH_ConfigFormPasswordBox:SetText(RBH_PRIVATE_PASSWORD)
end

function RBH_CheckPrivateChannelClicked()
    if (RBH_ConfigFormCheckPrivateChannel:GetChecked()) then
        RBH_ConfigFormPrivateChannelEditBtn:SetEnabled(true)
        RBH_ConfigFormChannelNameBox:SetEnabled(false)
        RBH_ConfigFormPasswordBox:SetEnabled(false)
        RBH_ConfigFormPrivateChannelSaveBtn:SetEnabled(false)
        RBH_ConfigFormPrivateChannelCancelBtn:SetEnabled(false)
    else
        RBH_ConfigFormPrivateChannelEditBtn:SetEnabled(false)
        RBH_ConfigFormChannelNameBox:SetEnabled(false)
        RBH_ConfigFormPasswordBox:SetEnabled(false)
        RBH_ConfigFormPrivateChannelSaveBtn:SetEnabled(false)
        RBH_ConfigFormPrivateChannelCancelBtn:SetEnabled(false)
    end
end

function RBH_BountyFilterDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, RBH_BountyFilterDropDown_Initialize, "MENU");
	RBH_BountyFilterDropDownText:SetJustifyH("CENTER");
	RBH_BountyFilterDropDownButton:Show();
end

function RBH_BountyFilterDropDown_Initialize(self, level)
	
	local info = UIDropDownMenu_CreateInfo();	
	
    info.text = "Show Horde"
    info.func = 	function() 
                            RBH_Config["ShowHorde"] = not RBH_Config["ShowHorde"]
                            RBH_BountyFilters.ShowHorde = RBH_Config["ShowHorde"]
                            RBH_HitListUpdate()                            
						end 
	info.keepShownOnClick = true;
	info.checked = 	RBH_BountyFilters.ShowHorde;
	info.isNotRadio = true;
	UIDropDownMenu_AddButton(info)
    
    info.text = "Show Alliance"
    info.func = 	function() 
							RBH_Config["ShowAlliance"] = not RBH_Config["ShowAlliance"]
                            RBH_BountyFilters.ShowAlliance = RBH_Config["ShowAlliance"]
                            RBH_HitListUpdate()  
						end 
	info.keepShownOnClick = true;
	info.checked = 	RBH_BountyFilters.ShowAlliance;
	info.isNotRadio = true;
	UIDropDownMenu_AddButton(info)
		
    info.text = "Show Claimed"
    info.func = 	function() 
							RBH_Config["ShowClaimed"] = not RBH_Config["ShowClaimed"]
                            RBH_BountyFilters.ShowClaimed = RBH_Config["ShowClaimed"]
                            RBH_HitListUpdate()                            
						end 
	info.keepShownOnClick = true;
	info.checked = 	RBH_BountyFilters.ShowClaimed;
	info.isNotRadio = true;
	UIDropDownMenu_AddButton(info)
    
        info.text = "Show Open"
    info.func = 	function() 
							RBH_Config["ShowOpen"] = not RBH_Config["ShowOpen"]
                            RBH_BountyFilters.ShowOpen = RBH_Config["ShowOpen"]
                            RBH_HitListUpdate()                            
						end 
	info.keepShownOnClick = true;
	info.checked = 	RBH_BountyFilters.ShowOpen;
	info.isNotRadio = true;
	UIDropDownMenu_AddButton(info)
    
    info.text = "Show Paid"
    info.func = 	function() 
							RBH_Config["ShowPaid"] = not RBH_Config["ShowPaid"]
                            RBH_BountyFilters.ShowPaid = RBH_Config["ShowPaid"]
                            RBH_HitListUpdate()                            
						end 
	info.keepShownOnClick = true;
	info.checked = 	RBH_BountyFilters.ShowPaid;
	info.isNotRadio = true;
	UIDropDownMenu_AddButton(info)
    
    info.text = "Show Realm Channel"
    info.func = 	function() 
							RBH_Config["ShowRealmChannel"] = not RBH_Config["ShowRealmChannel"]
                            RBH_BountyFilters.ShowRealmChannel = RBH_Config["ShowRealmChannel"]
                            RBH_HitListUpdate() 
						end 
	info.keepShownOnClick = true;
	info.checked = 	RBH_BountyFilters.ShowRealmChannel;
	info.isNotRadio = true;
	UIDropDownMenu_AddButton(info)
    
    info.text = "Show Guild Channel"
    info.func = 	function() 
							RBH_Config["ShowGuildChannel"] = not RBH_Config["ShowGuildChannel"]
                            RBH_BountyFilters.ShowGuildChannel = RBH_Config["ShowGuildChannel"]
                            RBH_HitListUpdate() 
						end 
	info.keepShownOnClick = true;
	info.checked = 	RBH_BountyFilters.ShowGuildChannel;
	info.isNotRadio = true;
	UIDropDownMenu_AddButton(info)
    
    info.text = "Show Private Channel"
    info.func = 	function() 
							RBH_Config["ShowPrivateChannel"] = not RBH_Config["ShowPrivateChannel"]
                            RBH_BountyFilters.ShowPrivateChannel = RBH_Config["ShowPrivateChannel"]
                            RBH_HitListUpdate() 
						end 
	info.keepShownOnClick = true;
	info.checked = 	RBH_BountyFilters.ShowPrivateChannel;
	info.isNotRadio = true;
	UIDropDownMenu_AddButton(info)

end

    