StaticPopupDialogs["ADD_BOUNTY"] = {
      text = "Enter the bounty amount and target name:",
      button1 = "Place Bounty",
      button2 = "Cancel",     
      OnAccept = function (self, data, data2)
         local name = self.editBox:GetText()
         local money = MoneyInputFrame_GetCopper(self.moneyInputFrame)
         
         if RBH_Largess >= money then
            RBH_AddBounty(name, money)
         else
            RBH_LargessMessage("You do not have enough money.","red")                       
         end
         
      end,
      OnShow = function (self, data, data2)
         local name = UnitName("target")    
         local money = MoneyInputFrame_GetCopper(self.moneyInputFrame)       
         if name then self.editBox:SetText(name) end
         if name ~= "" and money > 0 then
            self.button1:Enable()
         else
            self.button1:Disable()
         end      
      end,   
      OnHide = function (self)
         --MoneyInputFrame_ResetMoney(self.moneyInputFrame)
      end,  
      EditBoxOnTextChanged = function (self)
         local parent = self:GetParent()
         local name = parent.editBox:GetText()      
         local money = MoneyInputFrame_GetCopper(parent.moneyInputFrame)    
         if name ~= "" and money > 0 then
            parent.button1:Enable()
         else
            parent.button1:Disable()
         end 
      end,  
      OnUpdate = function(self, elapsed)
         local name = self.editBox:GetText()    
         local money = MoneyInputFrame_GetCopper(self.moneyInputFrame)       
         
         if name ~= "" and money > 0 then
            self.button1:Enable()
         else
            self.button1:Disable()
         end      
      end,
      
      hasMoneyInputFrame = true,
      hasEditBox = true,     
      timeout = 0,
      whileDead = true,
      hideOnEscape = true   
   }
   
StaticPopupDialogs["INTEL_POST"] = {
      text = "The guild bounty list has been posted.  If you wish to spy on the enemy faction, then click the Close button and log in with a toon of that faction and click the Gather Intel button again.  If you wish to spy on the friendly faction then click the Spy button.",
      button1 = "Spy",
      button2 = "Close",     
      OnAccept = function (self, data, data2)
         RBH_IntelSpy()         
      end,
      OnUpdate = nil,
      hasMoneyInputFrame = false,
      hasEditBox = false,
      timeout = 0,
      whileDead = true,
      hideOnEscape = true
  }
  
StaticPopupDialogs["INTEL_SPY"] = {
    text = "Would you like to spy on your bounty targets or report intel data?",
    button1 = "Spy",
    button2 = "Report",
    OnAccept = function (self)
        RBH_IntelSpy()
    end,
    OnCancel = function (self)
        RBH_IntelReport()
    end,
    OnUpdate = nil,
    hasMoneyInputFrame = false,
    hasEditBox = false,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true
}

StaticPopupDialogs["WARNING_AUDIT_HIST_CLEAR"] = {
    text = "Warning: this will delete all audit history data.  Are you sure you want to do this?",
    button1 = "Yes",
    button2 = "Cancel",
    OnAccept = function (self)
        RBH_LargessMessage("Clearing Audit History...")
        RBH_AuditHistory = {}
    end,
    OnUpdate = nil,
    hasMoneyInputFrame = false,
    hasEditBox = false,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true
}