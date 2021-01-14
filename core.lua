local FazzTools = LibStub("AceAddon-3.0"):NewAddon("FazzTools","AceConsole-3.0","AceEvent-3.0","AceHook-3.0")
local AceGUI = LibStub("AceGUI-3.0")

local FazzToolsLDB = LibStub("LibDataBroker-1.1"):NewDataObject("FazzTools!",{
	type="launcher",
	text="FazzTools",
	icon="Interface\\Icons\\INV_Chest_Cloth_17",
	OnClick = function() 
		FazzTools:CreateOptionsFrame()
		FazzToolsFrame:SetShown(not FazzToolsFrame:IsShown())
	end,
	OnTooltipShow = function(tt) tt:AddLine("Open FazzTools options") end,
})
local LDBIcon = LibStub("LibDBIcon-1.0")

local checkboxCounter = 0
function FazzTools:CreateCheckbox(parent,displayname,name)
	checkboxCounter = checkboxCounter + 1
	local checkbutton = CreateFrame("CheckButton","FT_checkbox_0"..checkboxCounter.."_"..name,parent,"ChatConfigCheckButtonTemplate")
	getglobal(checkbutton:GetName().."Text"):SetText(displayname)
	return checkbutton
end

local buttonCounter = 0
function FazzTools:CreateButton(parent,x_loc,y_loc,anchor,height,width,label,name)
	buttonCounter = buttonCounter + 1
	local button = CreateFrame("Button","FT_button_0"..buttonCounter.."_"..name,parent,"UIPanelButtonTemplate")
	button:SetPoint(anchor,x_loc,y_loc)
	button:SetHeight(height)
	button:SetWidth(width)
	button:SetText(label)
	return button
end

local function Frame_OnMouseDown(frame)
	AceGUI:ClearFocus()
end

local function Title_OnMouseDown(frame)
	frame:GetParent():StartMoving()
	AceGUI:ClearFocus()
end

local function MoverSizer_OnMouseUp(mover)
	local frame = mover:GetParent()
	frame:StopMovingOrSizing()
end

function FazzTools:OnInitialize()
	-- body
	self.db = LibStub("AceDB-3.0"):New("FazzToolsInfo",{
		profile = {
			minimap = {
				hide = false,
			},
			options = {
				hideplayerframe = false,
				autokeystone = false,
				hidetalkinghead = false,
				guildannounce = false,
				raidannounce = false,
				partyannounce = false,
				zonechangemessage = false,
			},
			havewemet = {
				showonlogin = false,
				count = 0,
			}
		},
	})
	LDBIcon:Register("FazzTools!",FazzToolsLDB,self.db.profile)
	FazzTools:UpdateMinimapButton()
	self:RegisterChatCommand("ft","ChatCommands")
	FazzTools:FazzHaveWeMet()
end

function FazzTools:OnEnable()
	-- body
	if self.db.profile.options.hideplayerframe then
		self:HookScript(PlayerFrame,"OnEvent","PlayerFrameOnEvent")
	end
	if self.db.profile.options.autokeystone then
		self:RegisterEvent("CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN")
	end
	if self.db.profile.options.hidetalkinghead then
		self:RegisterEvent("TALKINGHEAD_REQUESTED")
	end
	if self.db.profile.options.guildannounce then
		self:RegisterEvent("CHAT_MSG_GUILD","KeystoneHandler")
	end
	if self.db.profile.options.raidannounce then
		self:RegisterEvent("CHAT_MSG_RAID","KeystoneHandler")
		self:RegisterEvent("CHAT_MSG_RAID_LEADER","KeystoneHandler")
	end
	if self.db.profile.options.partyannounce then
		self:RegisterEvent("CHAT_MSG_PARTY","KeystoneHandler")
		self:RegisterEvent("CHAT_MSG_PARTY_LEADER","KeystoneHandler")
	end
	if self.db.profile.options.zonechangemessage then
		self:RegisterEvent("ZONE_CHANGED")
	end
end

function FazzTools:OnDisable()
	-- body
end

function FazzTools:UpdateMinimapButton()
  if (self.db.profile.minimap.hide) then
    LDBIcon:Hide("FazzTools!")
  else
    LDBIcon:Show("FazzTools!")
  end
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
	      	FazzTools:UpdateMinimapButton()
		elseif arg == 'help' then
			self:Print("/ft help - displays this message")
			self:Print("/ft minimap - toggles the minimap button on or off")
		elseif arg == '' then
			FazzTools:CreateOptionsFrame()
		else
			self:Print("Not a valid command")
	    end
  	end
end

function FazzTools:FazzHaveWeMet()
	-- body
	self.db.profile.havewemet.count = self.db.profile.havewemet.count + 1
	if self.db.profile.havewemet.showonlogin then
		if self.db.profile.havewemet.count == 1 then
			FazzTools:Print("Hello "..UnitName("player")..", I've seen you "..self.db.profile.havewemet.count.." time before!")
		else
			FazzTools:Print("Hello "..UnitName("player")..", I've seen you "..self.db.profile.havewemet.count.." times before!")
		end
	end
end

function FazzTools:CreateOptionsFrame()
	-- body
	if not FazzToolsFrame then
		local FazzMainFrame = CreateFrame("Frame","MainFrame",UIParent,BackdropTemplateMixin and "BackdropTemplate")
		FazzMainFrame:SetSize(200,400)
		FazzMainFrame:SetBackdrop({		
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
			tile = true, tileSize = 32, edgeSize = 32,
			insets = { left = 8, right = 8, top = 8, bottom = 8 },
		})
		FazzMainFrame:EnableMouse(true)
		FazzMainFrame:SetMovable(true)
		FazzMainFrame:SetPoint("CENTER",UIParent,"CENTER",0,0)

		local FazzGeneralFrame = CreateFrame("Frame","GeneralFrame",FazzMainFrame)
		FazzGeneralFrame:SetSize(1,110)
		FazzGeneralFrame:SetPoint("TOPLEFT",FazzMainFrame,"TOPLEFT",20,-35)

		local FazzGeneralText = FazzGeneralFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		FazzGeneralText:SetPoint("TOPLEFT",FazzGeneralFrame,"TOPLEFT")
		FazzGeneralText:SetText("General")

		local FazzHidePlayerFrameCheckbox = FazzTools:CreateCheckbox(FazzGeneralFrame,"  Hide Player Frame","hideplayerframe")
		FazzHidePlayerFrameCheckbox:SetPoint("TOPLEFT",FazzGeneralText,"BOTTOMLEFT",10,-10)
		FazzHidePlayerFrameCheckbox:SetChecked(self.db.profile.options.hideplayerframe)
		FazzHidePlayerFrameCheckbox:SetScript("OnClick", function() FT_button_01_savebutton:SetEnabled(FazzTools:CheckForReload()) end)

		local FazzAutoKeystoneCheckbox = FazzTools:CreateCheckbox(FazzGeneralFrame,"  Auto Keystone","autokeystone")
		FazzAutoKeystoneCheckbox:SetPoint("TOPLEFT",FazzHidePlayerFrameCheckbox,"BOTTOMLEFT")
		FazzAutoKeystoneCheckbox:SetChecked(self.db.profile.options.autokeystone)
		FazzAutoKeystoneCheckbox:SetScript("OnClick", function() FT_button_01_savebutton:SetEnabled(FazzTools:CheckForReload()) end)

		local FazzHideTalkingHeadCheckbox = FazzTools:CreateCheckbox(FazzGeneralFrame,"  Hide Talking Head","hidetalkinghead")
		FazzHideTalkingHeadCheckbox:SetPoint("TOPLEFT",FazzAutoKeystoneCheckbox,"BOTTOMLEFT")
		FazzHideTalkingHeadCheckbox:SetChecked(self.db.profile.options.hidetalkinghead)
		FazzHideTalkingHeadCheckbox:SetScript("OnClick", function() FT_button_01_savebutton:SetEnabled(FazzTools:CheckForReload()) end)

		local FazzKeystoneAnnouncerFrame = CreateFrame("Frame","keystoneAnnouncerFrame",FazzMainFrame)
		FazzKeystoneAnnouncerFrame:SetSize(1,110)
		FazzKeystoneAnnouncerFrame:SetPoint("TOPLEFT",FazzGeneralFrame,"BOTTOMLEFT")

		local FazzKeystoneAnnouncerText = FazzKeystoneAnnouncerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		FazzKeystoneAnnouncerText:SetPoint("TOPLEFT",FazzKeystoneAnnouncerFrame,"TOPLEFT")
		FazzKeystoneAnnouncerText:SetText("Keystone Announcer")

		local FazzGuildCheckbox = FazzTools:CreateCheckbox(FazzKeystoneAnnouncerFrame,"  Guild","guild")
		FazzGuildCheckbox:SetPoint("TOPLEFT",FazzKeystoneAnnouncerText,"BOTTOMLEFT",10,-10)
		FazzGuildCheckbox:SetChecked(self.db.profile.options.guildannounce)
		FazzGuildCheckbox:SetScript("OnClick", function() FT_button_01_savebutton:SetEnabled(FazzTools:CheckForReload()) end)
		
		local FazzRaidCheckbox = FazzTools:CreateCheckbox(FazzKeystoneAnnouncerFrame,"  Raid","raid")
		FazzRaidCheckbox:SetPoint("TOPLEFT",FazzGuildCheckbox,"BOTTOMLEFT")
		FazzRaidCheckbox:SetChecked(self.db.profile.options.raidannounce)
		FazzRaidCheckbox:SetScript("OnClick", function() FT_button_01_savebutton:SetEnabled(FazzTools:CheckForReload()) end)

		local FazzPartyCheckbox = FazzTools:CreateCheckbox(FazzKeystoneAnnouncerFrame,"  Party","party")
		FazzPartyCheckbox:SetPoint("TOPLEFT",FazzRaidCheckbox,"BOTTOMLEFT")
		FazzPartyCheckbox:SetChecked(self.db.profile.options.partyannounce)
		FazzPartyCheckbox:SetScript("OnClick", function() FT_button_01_savebutton:SetEnabled(FazzTools:CheckForReload()) end)

		local FazzRandomFrame = CreateFrame("Frame","randomFrame",FazzMainFrame)
		FazzRandomFrame:SetSize(1,80)
		FazzRandomFrame:SetPoint("TOPLEFT",FazzKeystoneAnnouncerFrame,"BOTTOMLEFT")

		local FazzRandomFrameText = FazzRandomFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		FazzRandomFrameText:SetPoint("TOPLEFT",FazzRandomFrame,"TOPLEFT")
		FazzRandomFrameText:SetText("Random")

		local FazzHaveWeMetCheckbox = FazzTools:CreateCheckbox(FazzRandomFrame,"  Have We Met?","havewemet")
		FazzHaveWeMetCheckbox:SetPoint("TOPLEFT",FazzRandomFrameText,"BOTTOMLEFT",10,-10)
		FazzHaveWeMetCheckbox:SetChecked(self.db.profile.havewemet.showonlogin)
		FazzHaveWeMetCheckbox:SetScript("OnClick", function() FT_button_01_savebutton:SetEnabled(FazzTools:CheckForReload()) end)

		local FazzZoneChangeMessageCheckbox = FazzTools:CreateCheckbox(FazzRandomFrame,"  Zone change","zonechangemessage")
		FazzZoneChangeMessageCheckbox:SetPoint("TOPLEFT",FazzHaveWeMetCheckbox,"BOTTOMLEFT")
		FazzZoneChangeMessageCheckbox:SetChecked(self.db.profile.options.zonechangemessage)
		FazzZoneChangeMessageCheckbox:SetScript("OnClick", function() FT_button_01_savebutton:SetEnabled(FazzTools:CheckForReload()) end)

	-- Close and reload button, title bar and title textures --

		local savebutton = FazzTools:CreateButton(FazzMainFrame,20,25,"BOTTOMLEFT",20,70,"Save","savebutton")
		savebutton:SetEnabled(FazzTools:CheckForReload())
		savebutton:SetScript("OnClick", function() 
			FazzTools:NewSettings(
			 	FazzHidePlayerFrameCheckbox:GetChecked(),
				FazzAutoKeystoneCheckbox:GetChecked(),
				FazzHideTalkingHeadCheckbox:GetChecked(),
				FazzGuildCheckbox:GetChecked(),
				FazzRaidCheckbox:GetChecked(),
				FazzPartyCheckbox:GetChecked(),
				FazzHaveWeMetCheckbox:GetChecked(),
				FazzZoneChangeMessageCheckbox:GetChecked()
			)
		end)

		local closebutton = FazzTools:CreateButton(FazzMainFrame,-20,25,"BOTTOMRIGHT",20,70,"Close","closebutton")
		closebutton:SetScript("OnClick", function() FazzMainFrame:Hide() end)

		local titlebg = FazzMainFrame:CreateTexture(nil, "OVERLAY")
		titlebg:SetTexture(131080) -- Interface\\DialogFrame\\UI-DialogBox-Header
		titlebg:SetTexCoord(0.31, 0.67, 0, 0.63)
		titlebg:SetPoint("TOP", 0, 12)
		titlebg:SetWidth(100)
		titlebg:SetHeight(40)

		local title = CreateFrame("Frame", nil, FazzMainFrame)
		title:EnableMouse(true)
		title:SetScript("OnMouseDown", Title_OnMouseDown)
		title:SetScript("OnMouseUp", MoverSizer_OnMouseUp)
		title:SetAllPoints(titlebg)

		local titletext = title:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		titletext:SetPoint("TOP", titlebg, 0, -14)
		titletext:SetText("Fazz Tools")

		local titlebg_left = FazzMainFrame:CreateTexture(nil, "OVERLAY")
		titlebg_left:SetTexture(131080) -- Interface\\DialogFrame\\UI-DialogBox-Header
		titlebg_left:SetTexCoord(0.21, 0.31, 0, 0.63)
		titlebg_left:SetPoint("RIGHT", titlebg, "LEFT")
		titlebg_left:SetWidth(30)
		titlebg_left:SetHeight(40)

		local titlebg_right = FazzMainFrame:CreateTexture(nil, "OVERLAY")
		titlebg_right:SetTexture(131080) -- Interface\\DialogFrame\\UI-DialogBox-Header
		titlebg_right:SetTexCoord(0.67, 0.77, 0, 0.63)
		titlebg_right:SetPoint("LEFT", titlebg, "RIGHT")
		titlebg_right:SetWidth(30)
		titlebg_right:SetHeight(40)

		FazzToolsFrame = FazzMainFrame
		FazzToolsFrame:Hide()
	else
		FT_button_01_savebutton:SetEnabled(FazzTools:CheckForReload())
		FT_checkbox_01_hideplayerframe:SetChecked(self.db.profile.options.hideplayerframe)
		FT_checkbox_02_autokeystone:SetChecked(self.db.profile.options.autokeystone)
		FT_checkbox_03_hidetalkinghead:SetChecked(self.db.profile.options.hidetalkinghead)
		FT_checkbox_04_guild:SetChecked(self.db.profile.options.guildannounce)
		FT_checkbox_05_raid:SetChecked(self.db.profile.options.raidannounce)
		FT_checkbox_06_party:SetChecked(self.db.profile.options.partyannounce)
		FT_checkbox_07_havewemet:SetChecked(self.db.profile.havewemet.showonlogin)
		FT_checkbox_08_zonechangemessage:SetChecked(self.db.profile.options.zonechangemessage)
	end
end

-- ################
-- global function that is called for every set value on a frame and returns true or false based on saved variables
-- default value setting done at frame creation, anytime frame is opened (minimap button click) the value for each box needs to be checked against saved variables

-- function FazzTools:FazzToolsOptions()
-- 	-- body
-- 	if not FazzToolsInfo["globalOptions"] then
-- 		FazzToolsInfo["globalOptions"] = {}
-- 	end
-- end

function FazzTools:NewSettings(playerFrameOption,autoKeystoneOption,talkingHeadOption,guildCheckboxOption,raidCheckboxOption,partyCheckboxOption,haveWeMetCheckboxOption,zoneChangeMessageCheckboxOption)
	-- body
	self.db.profile.options.hideplayerframe = playerFrameOption
	self.db.profile.options.autokeystone = autoKeystoneOption
	self.db.profile.options.hidetalkinghead = talkingHeadOption
	self.db.profile.options.guildannounce = guildCheckboxOption
	self.db.profile.options.raidannounce = raidCheckboxOption
	self.db.profile.options.partyannounce = partyCheckboxOption
	self.db.profile.havewemet.showonlogin = haveWeMetCheckboxOption
	self.db.profile.options.zonechangemessage = zoneChangeMessageCheckboxOption
	C_UI.Reload()
end

function FazzTools:CheckForReload()
	-- body
	if (self.db.profile.options.hideplayerframe == FT_checkbox_01_hideplayerframe:GetChecked()) and 
	(self.db.profile.options.autokeystone == FT_checkbox_02_autokeystone:GetChecked()) and
	(self.db.profile.options.hidetalkinghead == FT_checkbox_03_hidetalkinghead:GetChecked()) and
	(self.db.profile.options.guildannounce == FT_checkbox_04_guild:GetChecked()) and
	(self.db.profile.options.raidannounce == FT_checkbox_05_raid:GetChecked()) and
	(self.db.profile.options.partyannounce == FT_checkbox_06_party:GetChecked()) and
	(self.db.profile.havewemet.showonlogin == FT_checkbox_07_havewemet:GetChecked()) and
	(self.db.profile.options.zonechangemessage == FT_checkbox_08_zonechangemessage:GetChecked()) then
		return false
	else 
		return true
	end
end