--[[

	© 2021 FedeIlLeone

	Kick - Kick server side module
	
	Functions:
	
		Kick.Run(admin, data) --> [Success]
		
		* Parameter description for "Kick.Run()":
			
			admin [Player] -- Player instance, normally must be an admin
			
			data [Table] -- Table with all additional data for the module
		
		Kick.Log(admin, playerName, userId, reason)
		
--]]

local Kick = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = ReplicatedStorage.Utility
local SendCoreNotif = ReplicatedStorage._adminRemotes.Client.SendCoreNotif
local Constants = require(Utility.Constants)
local PlayerUtility = require(Utility.PlayerUtility)
local DiscordLogging = require(script.Parent.Parent.DiscordLogging.DiscordLogging)


local function truncateString(str, length)
	if string.len(str) > length then
		return string.sub(str, 1, length) .. "..."
	else
		return str
	end
end


function Kick:Run(admin, data)
	for _, value in pairs(data) do
		if value == "" or value == nil then
			SendCoreNotif:FireClient(admin, "Kick", "Compile everything!", 5)
			return false
		end
	end
	
	local player = data.Player
	local reason = truncateString(data.Reason, Constants.MAX_REASON_LENGTH)
	
	local userId, playerName = PlayerUtility:GetNameAndUserIdFromPlayer(player)
	if (userId and playerName) == nil then
		SendCoreNotif:FireClient(admin, "Kick", player .. " doesn't exists!", 5)
		return false
	end
	
	if playerName == admin.Name then
		SendCoreNotif:FireClient(admin, "Kick", "You can't kick yourself.", 5)
		return false
	end
	
	local plr = Players:FindFirstChild(playerName)
	if plr then
		plr:Kick("\nYou've got kicked by " .. admin.Name .. " for reason '" .. reason .. "'.")
	end
	
	Kick:Log(admin, playerName, userId, reason)
	
	return true
end

function Kick:Log(admin, playerName, userId, reason)
	local embedData = {
		embeds = {
			{
				title = "Kick",
				description = "An admin just kicked a player!",
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
					}
				}
			}
		}
	}
	
	DiscordLogging:Run(embedData)
end


return Kick