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
	["Severed Sagefish Head"] = 20 * 28,
	["Skewered Eel"] = 20 * 21,
	["Lavascale Minestrone"] = 20 * 14,
	["Crocolisk Au Gratin"] = 20 * 7,
	["Grilled Dragon"] = 20 * 7,
	-- tab 3
	["Flask of Steelskin"] = 3 * 21,
	["Flask of the Winds"] = 3 * 21,
	["Flask of Titanic Strength"] = 3 * 21,
	["Flask of the Draconic Mind"] = 3 * 35,
	-- tab 5
	["Hypnotic Dust"] = 20 * 14,
	["Heavenly Shard"] = 20 * 3,
	["Maelstrom Crystal"] = 20 * 2,
	["Greater Celestial Essence"] = 10 * 7,

}

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(self, event)
	if (event == "PLAYER_LOGIN") then
		CloseChatFrame()
	elseif (event == "GUILDBANKBAGSLOTS_CHANGED") then
		f["WAITCOUNT"] = f["WAITCOUNT"] - 1
		if (f["WAITCOUNT"] == 0) then
			PrintShoppingList()
			f:UnregisterEvent("GUILDBANKBAGSLOTS_CHANGED")
		end
	end
end)

SlashCmdList["STOCKER"] = function(_msg)
	f["WAITCOUNT"] = 0;
	f:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED")
	QueryGBank()
end

function PrintShoppingList()
	local content = GetGBankContent()
	local strings = {}

	for shoppingItem, shoppingCount in pairs(SHOPPINGLIST) do
		local missing = 0
		local link

		-- Check if item on the shoppinlist is even in the guildbank
		if content[shoppingItem] then
			missing = shoppingCount - content[shoppingItem]["count"]
			link = content[shoppingItem]["link"]
		else
			missing = shoppingCount
			link = GetItemInfo(shoppingItem)["count"]

			if link == nil then
				link = shoppingItem
			end
		end

		if missing > 0 then
			strings[#strings + 1] = format("%s - %d", link, missing)
		end
	end

	PrintChatFrame(strings)
end

function QueryGBank()
	for localtab = 1, GetNumGuildBankTabs() do
		-- Check if your can access a guildbank tab
		if (select(3, GetGuildBankTabInfo(localtab))) then
			QueryGuildBankTab(localtab)
			f["WAITCOUNT"] = f["WAITCOUNT"] + 1
		end
	end
end

function GetGBankContent()
	local content = {}
	for tab = 1, GetNumGuildBankTabs() do
		for slot = 1, 98 do
			ScanGBankSlot(tab, slot, content)
		end
	end

	return content
end

function ScanGBankSlot(tab, slot, content)
	local link = GetGuildBankItemLink(tab, slot)

	if link then
		local name = GetItemInfo(link)
		local count = select(2, GetGuildBankItemInfo(tab, slot))

		AddToContent(link, name, count, content)
	end
end

function AddToContent(link, name, count, content)
	if content[name] then
		content[name]["count"] = content[name]["count"] + count
	else
		content[name] = {
			["link"] = link,
			["count"] = count
		}
	end
end

local FRAME_NAME = "Shoppinglist"

function PrintChatFrame(strings)
	if #strings == 0 then
		print("Nothing to buy")
		return
	end

	local chatframe = FCF_OpenNewWindow(FRAME_NAME)
	chatframe:AddMessage("Buy the following:")
	for i = 1, #strings do
		chatframe:AddMessage(strings[i])
	end
end

function CloseChatFrame()
	for i = 1, NUM_CHAT_WINDOWS do
		local name = FCF_GetChatWindowInfo(i)
		if (name == FRAME_NAME) then
			FCF_Close(_G['ChatFrame' .. i])
		end
	end
end
