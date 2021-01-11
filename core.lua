FazzTools = LibStub("AceAddon-3.0"):NewAddon("FazzTools","AceConsole-3.0","AceEvent-3.0","AceHook-3.0")

function FazzTools:OnInitialize()
	-- body
	if FazzWeMetCount == nil then
			FazzWeMetCount = {}
			FazzWeMetCount[UnitName("player")] = 1
	else
		local found = 0
		for name,number in pairs(FazzWeMetCount) do
			if UnitName("player") == name then
				FazzWeMetCount[name] = FazzWeMetCount[name] + 1
				found = 1
			end
		end
		if found == 0 then
			FazzWeMetCount[UnitName("player")] = 1
		end
	end
	if FazzWeMetCount[UnitName("player")] then
		if FazzWeMetCount[UnitName("player")] == 1 then
			FazzTools:Print("Hello "..UnitName("player")..", I've seen you "..FazzWeMetCount[UnitName("player")].." time before!")
		else
			FazzTools:Print("Hello "..UnitName("player")..", I've seen you "..FazzWeMetCount[UnitName("player")].." times before!")
		end
	end
end

function FazzTools:OnEnable()
	-- body
	self:RegisterEvent("ZONE_CHANGED")
	self:RegisterEvent("CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN")
	self:RegisterEvent("CHAT_MSG_GUILD","KeystoneHandler")
	self:RegisterEvent("CHAT_MSG_PARTY","KeystoneHandler")
	self:RegisterEvent("CHAT_MSG_PARTY_LEADER","KeystoneHandler")
	self:RegisterEvent("CHAT_MSG_RAID","KeystoneHandler")
	self:RegisterEvent("CHAT_MSG_RAID_LEADER","KeystoneHandler")

	self:RegisterEvent("TALKINGHEAD_REQUESTED")

	-- TalkingHeadFrame:SecureHook("TalkingHeadFrame_PlayCurrent")
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
	TalkingHeadFrame:Hide()
end