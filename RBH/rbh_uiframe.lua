function RBH_UIInit()
	--CTRaid Fix
	if(FriendsFrameTab5 ~= nil and FriendsFrameTab5:GetText() == "CTRaid") then
		FriendsFrameTab5:SetText("CTRA");
		PanelTemplates_TabResize(0, FriendsFrameTab5, 62);
	end

	while(_G["FriendsFrameTab" .. TabID] ~= nil) do
		TabID = TabID + 1;
	end

	if(_G["FriendsFrameTab" .. (TabID-1)] and _G["FriendsFrameTab" .. (TabID-1)]:GetText() == "Bounties") then
		print("moep");
		TabID = TabID - 1;
		frame = _G["FriendsFrameTab" .. TabID];
		--frame:SetParent(FriendsFrame);
	else
		frame = CreateFrame("Button", "FriendsFrameTab" .. TabID, FriendsFrame, "FriendsFrameTabTemplate");
		frame:SetPoint("LEFT", "FriendsFrameTab" .. (TabID - 1), "RIGHT", -14, 0);
		frame:SetText("Bounties");
		frame:SetID(TabID);
	end
	
	-- add ourself to the subframe list....
	tinsert(FRIENDSFRAME_SUBFRAMES, "RBHUIListFrame");

	-- we need 5 instead of 4 tabs
	PanelTemplates_SetNumTabs(FriendsFrame, TabID);
	PanelTemplates_UpdateTabs(FriendsFrame);

	self:SecureHook("FriendsFrame_Update", "FriendsFrame_Update");
end

function RBH_FriendsFrame_Update()
	if(FriendsFrame.selectedTab == TabID) then
		FriendsFrameTitleText:SetText(VANASKOS.NAME .. " - " .. VANASKOS.VERSION);
		if(VanasKoSFrame:IsVisible()) then
			return;
		end
		FriendsFrameTopLeft:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-TopLeft");
		FriendsFrameTopRight:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-TopRight");
		--FriendsFrameBottomLeft:SetTexture("Interface\\FriendsFrame\\WhoFrame-BotLeft");
		FriendsFrameBottomLeft:SetTexture("Interface\\Addons\\VanasKoS\\Artwork\\KoSListFrame-BotLeft");
		FriendsFrameBottomRight:SetTexture("Interface\\FriendsFrame\\WhoFrame-BotRight");

		VanasKoSGUI:ScrollFrameUpdate();
		RBHUIListFrame:SetParent("FriendsFrame");
		RBHUIListFrame:SetAllPoints();

		FriendsFrame_ShowSubFrame("NonExistingFrame"); -- so all friendframe tabs get hidden
		RBHUIListFrame:Show();
	else
		if(not VanasKoSFrame:IsVisible()) then
			RBHUIListFrame:Hide();
		end
	end
end
