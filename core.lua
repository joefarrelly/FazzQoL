local FazzTools = LibStub("AceAddon-3.0"):NewAddon("FazzTools","AceConsole-3.0","AceEvent-3.0","AceHook-3.0")
local AceGUI = LibStub("AceGUI-3.0")

local FazzToolsLDB = LibStub("LibDataBroker-1.1"):NewDataObject("FazzTools!",{
	type="launcher",
	text="FazzTools",
	icon="Interface\\Icons\\INV_Chest_Cloth_17",
	OnClick = function() FazzTools:LoadOptions() end,
	OnTooltipShow = function(tt) tt:AddLine("Open FazzTools options") end,
})
local LDBIcon = LibStub("LibDBIcon-1.0")

isOpen = false
-- MainFrame:Hide()
-- _G["GlobalMainFrame"] = MainFrame.frame

function FazzTools:OnInitialize()
	-- body
	self.db = LibStub("AceDB-3.0"):New("FazzToolsDB",{
		profile = {
			minimap = {
				hide = false,
			},
		},
	})
	LDBIcon:Register("FazzTools!",FazzToolsLDB,self.db.profile.minimap)
	self:RegisterChatCommand("ft","ChatCommands")
	FazzTools:FazzWeMet()
	FazzTools:FazzToolsOptions()
end

function FazzTools:OnEnable()
	-- body
	self:RegisterEvent("ZONE_CHANGED")
	if FazzToolsInfo["globalOptions"]["autoKeystone"] then
		self:RegisterEvent("CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN")
	end
	if FazzToolsInfo["globalOptions"]["guildAnnounce"] then
		self:RegisterEvent("CHAT_MSG_GUILD","KeystoneHandler")
	end
	if FazzToolsInfo["globalOptions"]["raidAnnounce"] then
		self:RegisterEvent("CHAT_MSG_RAID","KeystoneHandler")
		self:RegisterEvent("CHAT_MSG_RAID_LEADER","KeystoneHandler")
	end
	if FazzToolsInfo["globalOptions"]["partyAnnounce"] then
		self:RegisterEvent("CHAT_MSG_PARTY","KeystoneHandler")
		self:RegisterEvent("CHAT_MSG_PARTY_LEADER","KeystoneHandler")
	end
	self:RegisterEvent("TALKINGHEAD_REQUESTED")
	if FazzToolsInfo["globalOptions"]["hidePlayerFrame"] then
		self:HookScript(PlayerFrame,"OnEvent","PlayerFrameOnEvent")
	end
end

function FazzTools:OnDisable()
	-- body
end

function FazzTools:ZONE_CHANGED()
	-- body
	self:Print("You are now in "..GetZoneText().." - "..GetSubZoneText())
end

function FazzTools:CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN()
	-- body
	for bag=0,NUM_BAG_SLOTS do
        for slot=1,GetContainerNumSlots(bag) do
            local _, _, _, quality, _, _, itemLink = GetContainerItemInfo(bag,slot)
            if itemLink ~= nil then
                if string.find(itemLink, "Hkeystone") then
                    UseContainerItem(bag,slot)
                end
            end
        end
    end
end

function FazzTools:KeystoneHandler(event,arg1,...)
	-- body
	if arg1 == "!keys" then
		for bag=0,NUM_BAG_SLOTS do
            for slot=1,GetContainerNumSlots(bag) do
                local _, _, _, quality, _, _, itemLink = GetContainerItemInfo(bag,slot)
                if itemLink ~= nil then
                    if string.find(itemLink, "Hkeystone") then
                        if event == "CHAT_MSG_GUILD" then
							SendChatMessage(itemLink,"GUILD")
						elseif event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_PARTY_LEADER" then
							SendChatMessage(itemLink,"PARTY")
						elseif event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_LEADER" then
							SendChatMessage(itemLink,"RAID")
						end	
                    end
                end
            end
        end
	end
end

function FazzTools:TALKINGHEAD_REQUESTED()
	-- body
	if TalkingHeadFrame:IsShown() then
		TalkingHeadFrame:Hide()
	end
end

function FazzTools:PlayerFrameOnEvent()
	-- body
	if PlayerFrame:IsShown() then
		PlayerFrame:Hide()
	end
end

function FazzTools:ChatCommands(input)
	-- body
	local args = {strsplit(' ', input)}
	for _, arg in ipairs(args) do
	    if arg == 'minimap' then
	      	self.db.profile.minimap.hide = not self.db.profile.minimap.hide
	      	self:Print("Minimap button is now " .. (self.db.profile.minimap.hide and "hidden" or "shown"))
	      	if self.db.profile.minimap.hide then
				LDBIcon:Hide("FazzTools!")
			else
				LDBIcon:Show("FazzTools!")
			end 
		elseif arg == 'help' then
			self:Print("/ft help - displays this message")
			self:Print("/ft minimap - toggles the minimap button on or off")
		elseif arg == '' then
			FazzTools:LoadOptions()
		else
			self:Print("Not a valid command")
	    end
  	end
end

function FazzTools:FazzWeMet()
	-- body
	if FazzToolsInfo == nil then
		FazzToolsInfo = {}
		FazzToolsInfo["FazzWeMetCount"] = {}
	end

	if not FazzToolsInfo["FazzWeMetCount"] then
		FazzToolsInfo["FazzWeMetCount"] = {}
		FazzToolsInfo["FazzWeMetCount"][UnitName("player")] = 1
	else
		local found = 0
		for name,number in pairs(FazzToolsInfo["FazzWeMetCount"]) do
			if UnitName("player") == name then
				FazzToolsInfo["FazzWeMetCount"][name] = FazzToolsInfo["FazzWeMetCount"][name] + 1
				found = 1
			end
		end
		if found == 0 then
			FazzToolsInfo["FazzWeMetCount"][UnitName("player")] = 1
		end
	end
	if FazzToolsInfo["FazzWeMetCount"][UnitName("player")] then
		if FazzToolsInfo["FazzWeMetCount"][UnitName("player")] == 1 then
			FazzTools:Print("Hello "..UnitName("player")..", I've seen you "..FazzToolsInfo["FazzWeMetCount"][UnitName("player")].." time before!")
		else
			FazzTools:Print("Hello "..UnitName("player")..", I've seen you "..FazzToolsInfo["FazzWeMetCount"][UnitName("player")].." times before!")
		end
	end
end

function FazzTools:LoadOptions()
	-- body
	if isOpen == true then
		MainFrame:Hide()
		isOpen = false
	else
		-- tinsert(UISpecialFrames, "GlobalMainFrame")
		MainFrame = AceGUI:Create("Frame")
		MainFrame:SetTitle("Fazz Tools")
		-- MainFrame:SetStatusText("Example fazz frame")
		MainFrame:SetHeight(500)
		MainFrame:SetWidth(300)
		MainFrame:SetCallback("OnClose", function(widget)
			AceGUI:Release(widget)
			isOpen = false
		end)
		MainFrame:SetLayout("Flow")



		local playerFrameCheckbox = AceGUI:Create("CheckBox")
		playerFrameCheckbox:SetLabel("Hide player frame")
		-- checkbox:SetType("checkbox")
		if FazzToolsInfo["globalOptions"]["hidePlayerFrame"] ~= nil then
			playerFrameCheckbox:SetValue(FazzToolsInfo["globalOptions"]["hidePlayerFrame"])
		else
			playerFrameCheckbox:SetValue(true)
		end
		playerFrameCheckbox:SetWidth(500)
		-- checkbox:SetCallback("OnValueChanged", function() FazzTools:TestFunc(checkbox:GetValue()) end)
		MainFrame:AddChild(playerFrameCheckbox)

		local autoKeystoneCheckbox = AceGUI:Create("CheckBox")
		autoKeystoneCheckbox:SetLabel("Auto Keystone")
		-- checkbox:SetType("checkbox")
		if FazzToolsInfo["globalOptions"]["autoKeystone"] ~= nil then
			autoKeystoneCheckbox:SetValue(FazzToolsInfo["globalOptions"]["autoKeystone"])
		else
			autoKeystoneCheckbox:SetValue(true)
		end
		autoKeystoneCheckbox:SetWidth(500)
		-- checkbox:SetCallback("OnValueChanged", function() FazzTools:TestFunc(checkbox:GetValue()) end)
		MainFrame:AddChild(autoKeystoneCheckbox)

		local keystoneAnnouncerHeading = AceGUI:Create("InlineGroup")
		keystoneAnnouncerHeading:SetTitle("Keystone Announcer")
		MainFrame:AddChild(keystoneAnnouncerHeading)

		local guildCheckbox = AceGUI:Create("CheckBox")
		guildCheckbox:SetLabel("Guild")
		if FazzToolsInfo["globalOptions"]["guildAnnounce"] ~= nil then
			guildCheckbox:SetValue(FazzToolsInfo["globalOptions"]["guildAnnounce"])
		else
			guildCheckbox:SetValue(true)
		end
		keystoneAnnouncerHeading:AddChild(guildCheckbox)

		local raidCheckbox = AceGUI:Create("CheckBox")
		raidCheckbox:SetLabel("Raid")
		if FazzToolsInfo["globalOptions"]["raidAnnounce"] ~= nil then
			raidCheckbox:SetValue(FazzToolsInfo["globalOptions"]["raidAnnounce"])
		else
			raidCheckbox:SetValue(true)
		end
		keystoneAnnouncerHeading:AddChild(raidCheckbox)

		local partyCheckbox = AceGUI:Create("CheckBox")
		partyCheckbox:SetLabel("Party")
		if FazzToolsInfo["globalOptions"]["partyAnnounce"] ~= nil then
			partyCheckbox:SetValue(FazzToolsInfo["globalOptions"]["partyAnnounce"])
		else
			partyCheckbox:SetValue(true)
		end
		keystoneAnnouncerHeading:AddChild(partyCheckbox)

		local reloadButton = AceGUI:Create("Button")
		reloadButton:SetText("Reload to save changes!")
		reloadButton:SetCallback("OnClick", function() 
			FazzTools:NewSettings(
				playerFrameCheckbox:GetValue(),
				autoKeystoneCheckbox:GetValue(),
				guildCheckbox:GetValue(),
				raidCheckbox:GetValue(),
				partyCheckbox:GetValue()
			)
		end)
		reloadButton:SetWidth(300)
		MainFrame:AddChild(reloadButton)

		isOpen = true
	end
end

function FazzTools:FazzToolsOptions()
	-- body
	if not FazzToolsInfo["globalOptions"] then
		FazzToolsInfo["globalOptions"] = {}
		-- FazzToolsInfo["globalOptions"]["hidePlayerFrame"] = true
	-- else
	-- 	print(FazzToolsInfo["globalOptions"]["hidePlayerFrame"])
	end
end

function FazzTools:NewSettings(playerFrameOption,autoKeystoneOption,guildCheckboxOption,raidCheckboxOption,partyCheckboxOption)
	-- body
	FazzToolsInfo["globalOptions"]["hidePlayerFrame"] = playerFrameOption
	FazzToolsInfo["globalOptions"]["autoKeystone"] = autoKeystoneOption
	FazzToolsInfo["globalOptions"]["guildAnnounce"] = guildCheckboxOption
	FazzToolsInfo["globalOptions"]["raidAnnounce"] = raidCheckboxOption
	FazzToolsInfo["globalOptions"]["partyAnnounce"] = partyCheckboxOption
	C_UI.Reload()
end