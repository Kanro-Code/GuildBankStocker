SLASH_STOCKER1 = "/gbs"
SLASH_STOCKER2 = "/guildbankstocker"

local shoppinglist = {
	-- tab 1
	["Potion of the Tol'vir"] = 20 * 21,
	["Volcanic Potion"] = 20 * 21,
	["Golemblood Potion"] = 20 * 14,
	["Mythical Mana Potion"] = 20 * 14,
	["Earthen Potion"] = 20 * 7,
	["Potion of Concentration"] = 20 * 7,
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

local waitcount = 0;
SlashCmdList["STOCKER"] = function(_msg)
	waitcount = 0;
	poll_gbank()
end

local f = CreateFrame("Frame")
f:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED")
f:SetScript("OnEvent", function(self, event)
	waitcount = waitcount - 1
	if (waitcount == 0) then
		print_difference(scan_gbank(), shoppinglist)
	end
end)

function print_difference(current, shoppinglist)
	print("Buy the following:")
	for name, demand in pairs(shoppinglist) do
		local buycount = 0
		local link
		if current[name] then
			buycount = demand - current[name][2]
			link = current[name][1]
		else
			buycount = demand
			link = GetItemInfo(name)[2]
			if link == nil then
				link = name
			end
		end

		if buycount > 0 then
			print(link, " - ", buycount)
		end
	end
end

function poll_gbank()
	for tab = 1, GetNumGuildBankTabs() do
		if (select(3, GetGuildBankTabInfo(tab))) then
			QueryGuildBankTab(tab)
			waitcount = waitcount + 1
		end
	end
end

function scan_gbank()
	local contents = {}
	for tab=1,3 do
		for i=1,98 do 
			local link = GetGuildBankItemLink(tab,i)
			if link then
				local name = GetItemInfo(link)
				local _, count = GetGuildBankItemInfo(tab,i)
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