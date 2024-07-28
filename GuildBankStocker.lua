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
	["Flask of the Draconic Mind"] = 3 * 35
}

local FRAME_NAME = "Shoppinglist"

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(self, event)
	if (event == "PLAYER_LOGIN") then
		CloseChatFrame()
	elseif (event == "GUILDBANKBAGSLOTS_CHANGED") then
		f["WAITCOUNT"] = f["WAITCOUNT"] - 1
		if (f["WAITCOUNT"] == 0) then
			print_difference(GbankInventory())
			f:UnregisterEvent("GUILDBANKBAGSLOTS_CHANGED")
		end
	end
end)

SlashCmdList["STOCKER"] = function(_msg)
	f["WAITCOUNT"] = 0;
	f:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED")
	GbankGet()
end

function print_difference(storage)
	local string = { "Buy the following:" }
	for demandName, demantCount in pairs(SHOPPINGLIST) do
		local missing = 0
		local link
		if storage[demandName] then
			missing = demantCount - storage[demandName]["count"]
			link = storage[demandName]["link"]
		else
			missing = demantCount
			link = GetItemInfo(demandName)["count"]
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

function GbankGet()
	for localtab = 1, GetNumGuildBankTabs() do
		if (select(3, GetGuildBankTabInfo(localtab))) then
			QueryGuildBankTab(localtab)
			f["WAITCOUNT"] = f["WAITCOUNT"] + 1
		end
	end
end

function GbankInventory()
	local contents = {}
	for tab = 1, GetNumGuildBankTabs() do
		for slot = 1, 98 do
			local link = GetGuildBankItemLink(tab, slot)

			if link then
				local name = GetItemInfo(link)
				local _, count = GetGuildBankItemInfo(tab, slot)

				if contents[name] then
					contents[name]["count"] = contents[name]["count"] + count
				else
					contents[name] = {
						["link"] = link,
						["count"] = count,
					}
				end
			end
		end
	end
	return contents
end

function CloseChatFrame()
	for i = 1, NUM_CHAT_WINDOWS do
		local name = FCF_GetChatWindowInfo(i)
		if (name == FRAME_NAME) then
			FCF_Close(_G['ChatFrame' .. i])
		end
	end
end
