--[[

	© 2021 FedeIlLeone

	EditStats - EditStats server side module
	
	Functions:
	
		EditStats.Run(admin, data) --> [Success]
		
		* Parameter description for "EditStats.Run()":
			
			admin [Player] -- Player instance, normally must be an admin
			
			data [Table] -- Table with all additional data for the module
		
		EditStats.Log(admin, playerName, userId, reason, value)
		
--]]

local EditStats = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local Utility = ReplicatedStorage.Utility
local SendCoreNotif = ReplicatedStorage._adminRemotes.Client.SendCoreNotif
local Constants = require(Utility.Constants)
local PlayerUtility = require(Utility.PlayerUtility)
local DiscordLogging = require(script.Parent.Parent.DiscordLogging.DiscordLogging)
local DataStore = DataStoreService:GetDataStore("PointsStats")

local CURRENCY_NAME = "Points"


local function truncateString(str, length)
	if string.len(str) > length then
		return string.sub(str, 1, length) .. "..."
	else
		return str
	end
end


function EditStats:Run(admin, data)
	for _, value in pairs(data) do
		if value == "" or value == nil then
			SendCoreNotif:FireClient(admin, "Edit Stats", "Compile everything!", 5)
			return false
		end
	end
	
	local player = data.Player
	local reason = truncateString(data.Reason, Constants.MAX_REASON_LENGTH)
	local value = data.Value
	
	local userId, playerName = PlayerUtility:GetNameAndUserIdFromPlayer(player)
	if (userId and playerName) == nil then
		SendCoreNotif:FireClient(admin, "Edit Stats", player .. " doesn't exists!", 5)
		return false
	end
	
	local plr = Players:FindFirstChild(playerName)
	if plr then
		plr.leaderstats:FindFirstChild(CURRENCY_NAME).Value = value
	else
		local success = pcall(function()
			DataStore:SetAsync(userId, value)
		end)
		if not success then
			wait(10)
			DataStore:SetAsync(userId, value)
		end
	end
	
	EditStats:Log(admin, playerName, userId, reason, value)
	
	return true
end

function EditStats:Log(admin, playerName, userId, reason, value)
	local embedData = {
		embeds = {
			{
				title = "Edit Stats",
				description = "An admin just edited a player stats!",
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
						name = "Value",
						value = value
					}
				}
			}
		}
	}

	DiscordLogging:Run(embedData)
end


return EditStats