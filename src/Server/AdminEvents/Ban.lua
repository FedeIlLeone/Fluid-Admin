--[[

	© 2021 FedeIlLeone

	Ban - Ban server side module
	
	Functions:
	
		Ban.Run(admin, data) --> [Success]
		
		* Parameter description for "Ban.Run()":
			
			admin [Player] -- Player instance, normally must be an admin
			
			data [Table] -- Table with all additional data for the module
		
		Ban.Log(admin, playerName, userId, reason, proofs, days, isPERM)
		
--]]

local Ban = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local Utility = ReplicatedStorage.Utility
local SendCoreNotif = ReplicatedStorage._adminRemotes.Client.SendCoreNotif
local Constants = require(Utility.Constants)
local PlayerUtility = require(Utility.PlayerUtility)
local DiscordLogging = require(script.Parent.Parent.DiscordLogging.DiscordLogging)
local DataStore = DataStoreService:GetDataStore("BanSystem")

local DATA_BANS_KEY = "PlayerBans"
local DAY_CONVERT = 86400


local function truncateString(str, length)
	if string.len(str) > length then
		return string.sub(str, 1, length) .. "..."
	else
		return str
	end
end


function Ban:Run(admin, data)
	for _, value in pairs(data) do
		if value == "" or value == nil then
			SendCoreNotif:FireClient(admin, "Ban", "Compile everything!", 5)
			return false
		end
	end
	
	local player = data.Player
	local reason = truncateString(data.Reason, Constants.MAX_REASON_LENGTH)
	local days = tostring(math.clamp(tonumber(data.Days), 1, admin:GetRankInGroup(Constants.GROUP_ID) < Constants.HR_RANK and Constants.MAX_LIMITED_DAYS or Constants.MAX_DAYS))
	local proofs = data.Proof
	
	local userId, playerName = PlayerUtility:GetNameAndUserIdFromPlayer(player)
	if (userId and playerName) == nil then
		SendCoreNotif:FireClient(admin, "Ban", player .. " doesn't exists!", 5)
		return false
	end
	
	if playerName == admin.Name then
		SendCoreNotif:FireClient(admin, "Ban", "You can't ban yourself.", 5)
		return false
	end
	
	local bans = DataStore:GetAsync(DATA_BANS_KEY) or {}
	
	if bans ~= nil then
		for _, ban in pairs(bans) do
			if ban.UserId == userId then
				SendCoreNotif:FireClient(admin, "Ban", playerName .. " is already banned for " .. tostring(ban.Days) .. " day(s) by " .. ban.Admin .. " for reason '" .. ban.Reason .. "'.", 8)
				return false
			end
		end
	end
	
	local isPERM = tonumber(days) >= Constants.MAX_PERM_DAYS and true or false
	local dateMath = math.floor(os.time()) + (tonumber(days) * DAY_CONVERT)
	
	bans[tostring(userId)] = {
		UserId = userId,
		PlayerName = playerName,
		Admin = admin.Name,
		Reason = reason,
		Proof = proofs,
		DateUntil = isPERM and nil or dateMath,
		Days = isPERM and "PERM" or tonumber(days)
	}
	
	local success = pcall(function()
		DataStore:SetAsync(DATA_BANS_KEY, bans)
	end)
	if not success then
		wait(10)
		DataStore:SetAsync(DATA_BANS_KEY, bans)
	end
	
	local plr = Players:FindFirstChild(playerName)
	if plr then
		plr:Kick("\nYou've got banned for " .. (isPERM and "PERM" or days) .. " day(s) by " .. admin.Name .. " for reason '" .. reason .. "'.")
	end
	
	Ban:Log(admin, playerName, userId, reason, proofs, days, isPERM)
	
	return true
end

function Ban:Log(admin, playerName, userId, reason, proofs, days, isPERM)
	local embedData = {
		embeds = {
			{
				title = "Ban",
				description = "An admin just banned a player!",
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
					},
					{
						name = "Days",
						value = isPERM and "Banned permanently" or "Banned for " .. tostring(days) .. " day(s)"
					}
				}
			}
		}
	}
	
	DiscordLogging:Run(embedData)
end


return Ban