SLASH_STOCKER1 = "/gbs"
SLASH_STOCKER2 = "/guildbankstocker"

local SHOPPINGLIST = {
	-- tab 1
	["Potion of the Tol'vir"] = 20 * 21,
	["Volcanic Potion"] = 20 * 28,
	["Golemblood Potion"] = 20 * 14,
	["Mythical Mana Potion"] = 20 * 14,
	["Earthen Potion"] = 20 * 7,
	["Potion of Concentration"] = 20 * 14,
	-- tab 2
	["Beer-Basted Crocolisk"] = 20 * 21,
	["Severed Sagefish Head"] = 20 * 21,
	["Skewered Eel"] = 20 * 14,
	["Lavascale Minestrone"] = 20 * 14,
	["Crocolisk Au Gratin"] = 20 * 7,
	["Grilled Dragon"] = 20 * 7,
	-- tab 3
	["Flask of Steelskin"] = 3 * 21,
	["Flask of the Winds"] = 3 * 21,
	["Flask of Titanic Strength"] = 3 * 21,
	["Flask of the Draconic Mind"] = 3 * 28
}

local FRAME_NAME = "Shoppinglist"

local WAITCOUNT = 0;
local f1 = CreateFrame("Frame")
f1:RegisterEvent("PLAYER_LOGIN")
f1:SetScript("OnEvent", function(self, event)
	close_chatframe()
end)

SlashCmdList["STOCKER"] = function(_msg)
	WAITCOUNT = 0;
	poll_gbank()

	local f2 = CreateFrame("Frame")
	f2:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED")
	f2:SetScript("OnEvent", function(self, event)
		WAITCOUNT = WAITCOUNT - 1
		if (WAITCOUNT == 0) then
			print_difference(scan_gbank())
		end
	end)
end

function print_difference(storage)
	local string = { "Buy the following:" }
	for demandName, demantCount in pairs(SHOPPINGLIST) do
		local missing = 0
		local link
		if storage[demandName] then
			missing = demantCount - storage[demandName][2]
			link = storage[demandName][1]
		else
			missing = demantCount
			link = GetItemInfo(demandName)[2]
			if link == nil then
				link = demandName
			end
		end

		if missing > 0 then
			string[#string + 1] = format("%s - %d", link, missing)
		end
	end

	if #string == 1 then
		print("Nothing to buy")
		return
	else
		local chatframe = FCF_OpenNewWindow(FRAME_NAME)
		for i = 0, #string do
			-- print(string[i])
			chatframe:AddMessage(string[i])
		end
	end
end

function poll_gbank()
	for localtab = 1, GetNumGuildBankTabs() do
		if (select(3, GetGuildBankTabInfo(localtab))) then
			QueryGuildBankTab(localtab)
			WAITCOUNT = WAITCOUNT + 1
		end
	end
end

function scan_gbank()
	local contents = {}
	for tab = 1, 3 do
		for i = 1, 98 do
			local link = GetGuildBankItemLink(tab, i)
			if link then
				local name = GetItemInfo(link)
				local _, count = GetGuildBankItemInfo(tab, i)
				if contents[name] then
					contents[name][2] = contents[name][2] + count
				else
					contents[name] = { link, count }
				end
			end
		end
	end
	return contents
end

function close_chatframe()
	print("CLOSING CHAT FRAME", NUM_CHAT_WINDOWS)
	for i = 1, NUM_CHAT_WINDOWS do
		local name = FCF_GetChatWindowInfo(i)
		if (name == FRAME_NAME) then
			FCF_Close(_G['ChatFrame' .. i])
		end
		-- match name then use FCF_Close(_G['ChatFrame' .. i])
	end
end
