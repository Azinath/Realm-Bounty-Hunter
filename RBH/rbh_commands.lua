function RBH_Commands(args)  
   local s,e,cmd,arg1,arg2,arg3,arg4 = string.find(args,"(%a*)%s?([.?%a%d]*)%s?([.?%a%d]*)%s?([.?%a%d-?]*)%s?([.?%a%d-?]*)")    
   
   --debug
   if cmd == "debug" then
      if arg1 == "on" then
         RBH_Config["debug"] = true
         RBH_LargessMessage("RBH: debug on")
      elseif arg1 == "off" then
         RBH_Config["debug"] = false
         RBH_LargessMessage("RBH: debug off")
      end    

    --show the GUI
    elseif cmd == "show" then
        RBH_ToggleHitList()
        
   --set default channel
   elseif cmd == "channel" then 
      if arg1 == "guild" then
         RBH_Config["channel"] = "GUILD"
      elseif arg1 == "party" then
         RBH_Config["channel"] = "PARTY"
      elseif arg1 == "officer" then
         RBH_Config["channel"] = "OFFICER"
      elseif arg1 == "private" then
         RBH_Config["channel"] = "PRIVATE"
      end      
  
   --place a bounty   
   elseif cmd == "bounty" then
      if arg1 == "bg" then
        RBH_AddBGBounties(tonumber(arg2))
      end
      
      local name, realm = UnitFullName("target")     
      if (realm == nil) then
        realm = GetRealmName()
      end   
      RBH_AddBounty(name, realm)
      
   --resync hit list
   elseif cmd == "sync" then
      RBH_SendAddonMessageToNetwork("ALERT","RBH_HL_SYNC_REQ", "");         
      
   --clear hit list
   elseif cmd == "clear" then
      if arg1 == "bounties" then
         RBH_HitList = {}
      elseif arg1 == "intel" then
         RBH_Intel = {}
      elseif arg1 == "all" then
         RBH_HitList = {}
         RBH_Intel = {}
      end   
      
   --largess commands
   elseif cmd == "largess" then
      if arg1 == "" then
         RBH_LargessMessage("Your current guild Largess is "..RBH_CopperToGold(RBH_Largess))
      elseif arg1 == "report" then
         RBH_GuildLargessReport()
      elseif arg1 == "set" then
         RBH_SetLargess(arg2,arg3)
      elseif arg1 == "mod" then
         RBH_ModLargess(arg2,arg3)
      end  
   
   --version
   elseif cmd == "version" then
      RBH_LargessMessage("Realm Bounty Hunter v"..RBH_VERSION);
     
    --set UI scale
    elseif cmd == "scale" then
        if arg1 ~= nil then
            RBH_Config["scale"] = arg1
            RBH_HitListFrame:SetScale(arg1)
        end   
    
     --get a list of RBH users
    elseif cmd == "users" then
        RBH_LargessMessage("RBH users...")
        RBH_SendAddonMessageToNetwork("ALERT", "RBH_USERS_REQ", "")
    
    --join comm channels
    elseif cmd == "join" then        
        RBH_JoinCommChannels()
            
    elseif cmd == "claimown" then
        if arg1 == "on" then
            RBH_Config["ClaimYourOwnBounties"] = true
            RBH_LargessMessage("You can now claim your own bounties.", "sys")
        elseif arg1 == "off" then
            RBH_Config["ClaimYourOwnBounties"] = false
            RBH_LargessMessage("You can NOT claim your own bounties now.", "sys")
	    else
		    RBH_Help(cmd)
        end
    
	elseif cmd == "classcolors" then
		if arg1 == "on" then
			RBH_Config["ClassColors"] = true
			RBH_LargessMessage("Class colors enabled.", "sys")
		elseif arg1 == "off" then
			RBH_Config["ClassColors"] = false
			RBH_LargessMessage("Class colors disabled.", "sys")
		else
		    RBH_Help(cmd)
		end			
	
   --help
   elseif cmd == "help" then
      RBH_Help(arg1)    
   else 
      RBH_Help()
   end
end

function RBH_GetAdminLevel()
   if CanEditOfficerNote() and CanEditGuildInfo() then
      return RBH_SUPER_ADMIN
   elseif CanEditOfficerNote() then
      return RBH_ADMIN
   else
      return RBH_USER
   end   
end

function RBH_BuyBounty()
   --local dialog = StaticPopup_Show("ADD_BOUNTY") 
   RBH_AddBountyFrame:Show()
   --[[
   if (dialog) then
      dialog.data  = varName     
      dialog.data2 = varName2
   end  
   local text = _G[dialog:GetName().."Text"];
   local editBox = _G[dialog:GetName().."EditBox"];
   local button1 = _G[dialog:GetName().."Button1"];  
   local moneyInputFrame = _G[dialog:GetName().."MoneyInputFrame"];
   dialog:SetHeight(16 + text:GetHeight() + 8 + editBox:GetHeight() + 8 + button1:GetHeight() + 8 + moneyInputFrame:GetHeight() + 8);   
   ]]--
end

