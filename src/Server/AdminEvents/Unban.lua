--[[

	© 2021 FedeIlLeone

	Unban - Unban server side module
	
	Functions:
	
		Unban.Run(admin, data) --> [Success]
		
		* Parameter description for "Unban.Run()":
			
			admin [Player] -- Player instance, normally must be an admin
			
			data [Table] -- Table with all additional data for the module
		
		Unban.Log(admin, playerName, userId, reason, proofs)
		
--]]

local Unban = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local Utility = ReplicatedStorage.Utility
local SendCoreNotif = ReplicatedStorage._adminRemotes.Client.SendCoreNotif
local Constants = require(Utility.Constants)
local PlayerUtility = require(Utility.PlayerUtility)
local DiscordLogging = require(script.Parent.Parent.DiscordLogging.DiscordLogging)
local DataStore = DataStoreService:GetDataStore("BanSystem")

local DATA_BANS_KEY = "PlayerBans"


local function truncateString(str, length)
	if string.len(str) > length then
		return string.sub(str, 1, length) .. "..."
	else
		return str
	end
end


function Unban:Run(admin, data)
	if admin:GetRankInGroup(Constants.GROUP_ID) < Constants.HR_RANK then
		SendCoreNotif:FireClient(admin, "Unban", "You're not able to use the unban feature!", 5)
		return
	end
	
	for _, value in pairs(data) do
		if value == "" or value == nil then
			SendCoreNotif:FireClient(admin, "Unban", "Compile everything!", 5)
			return false
		end
	end

	local player = data.Player
	local reason = truncateString(data.Reason, Constants.MAX_REASON_LENGTH)
	local proofs = data.Proof

	local userId, playerName = PlayerUtility:GetNameAndUserIdFromPlayer(player)
	if (userId and playerName) == nil then
		SendCoreNotif:FireClient(admin, "Unban", player .. " doesn't exists!", 5)
		return false
	end

	if playerName == admin.Name then
		SendCoreNotif:FireClient(admin, "Unban", "You can't unban yourself.", 5)
		return false
	end

	local bans = DataStore:GetAsync(DATA_BANS_KEY) or {}

	if bans ~= nil then
		if bans[tostring(userId)] then
			bans[tostring(userId)] = nil
		else
			SendCoreNotif:FireClient(admin, "Unban", playerName .. " is not banned.", 5)
			return false
		end
	else
		SendCoreNotif:FireClient(admin, "Unban", playerName .. " is not banned.", 5)
		return false
	end

	local success = pcall(function()
		DataStore:SetAsync(DATA_BANS_KEY, bans)
	end)
	if not success then
		wait(10)
		DataStore:SetAsync(DATA_BANS_KEY, bans)
	end
	
	Unban:Log(admin, playerName, userId, reason, proofs)

	return true
end

function Unban:Log(admin, playerName, userId, reason, proofs)
	local embedData = {
		embeds = {
			{
				title = "Unban",
				description = "An admin just unbanned a player!",
				color = Constants.EMBED_COLOR,
				thumbnail = {
					url = "http://www.roblox.com/Thumbs/Avatar.ashx?x=150&y=200&Format=Png&username=" .. playerName
				},
				fields = {
					{
						name = "Admin",
						value = "[" .. admin.Name .. " | " .. admin.UserId .. "](https://www.roblox.com/users/" .. admin.UserId .. "/profile)"
					},
					{
						name = "Player",
						value = "[" .. playerName .. " | " .. userId .. "](https://www.roblox.com/users/" .. userId .. "/profile)"
					},
					{
						name = "Reason",
						value = reason
					},
					{
						name = "Proof",
						value = proofs
					}
				}
			}
		}
	}

	DiscordLogging:Run(embedData)
end


return Unban