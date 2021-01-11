local FazzTools_Event = CreateFrame("Frame")

FazzTools_Event:RegisterEvent("ADDON_LOADED")
-- FazzTools_Event:RegisterEvent("PLAYER_LOGOUT")
FazzTools_Event:SetScript("OnEvent", function(self,event,arg1)
	-- body
	if event == "ADDON_LOADED" and arg1 == "FazzTools" then
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
				print("Hello "..UnitName("player")..", I've seen you "..FazzWeMetCount[UnitName("player")].." time before!")
			else
				print("Hello "..UnitName("player")..", I've seen you "..FazzWeMetCount[UnitName("player")].." times before!")
			end
		end


		-- if FazzWeMetLastSeen == nil then
		-- 	-- FazzWeMetCount = FazzWeMetCount + 1
		-- 	print("Hi; what is your name?")
		-- else
		-- 	local name, elapsed = UnitName("player"), time() - FazzWeMetLastSeen
		-- 	print("Hello again, "..name.."; you've been gone for  ".. SecondsToTime(elapsed))
		-- end
	-- elseif event == "PLAYER_LOGOUT" then
		-- FazzWeMetLastSeen = time()
	end
	-- if not fazzSavedVar then -- doesnt exists yet so use default
	-- 	fazzSavedVar = {}
	-- 	fazzSavedVar.test = "TEST"
	-- 	ChatFrame1:AddMessage("Hello muthafucka ".. UnitName("Player")..". I believe this is the first time we've met")
	-- else -- table already set
	-- 	if fazzSavedVar[UnitName("Player")] == 1 then
	-- 		ChatFrame1:AddMessage("Hello muthafucka "..UnitName("Player")..". Hello again, I've seen you "..fazzSavedVar[UnitName("Player")].." time before!")
	-- 	else
	-- 		ChatFrame1:AddMessage("Hello muthafucka "..UnitName("Player")..". Hello again, I've seen you "..fazzSavedVar[UnitName("Player")].." times before!")
	-- 	end
	-- 	local found = 0
	-- 	for name,number in pairs(fazzSavedVar) do
	-- 		if UnitName("Player") == name then
	-- 			fazzSavedVar[name] = fazzSavedVar[name] + 1
	-- 			found = 1
	-- 		end
	-- 	end
	-- 	if found == 0 then
	-- 		fazzSavedVar[UnitName("Player")] = 1
	-- 	end
	-- end
end)

SLASH_FAZZWEMET1 = "/fwm"
function SlashCmdList.FAZZWEMET(msg)
	print("FazzWeMet has met "..UnitName("player")..", "..FazzWeMetCount[UnitName("player")].." times!")
	-- body
end