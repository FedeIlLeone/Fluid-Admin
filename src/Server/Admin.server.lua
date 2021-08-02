--[[

	© 2021 FedeIlLeone

	AdminServer - Main script to control server side of the Admin Panel
	
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local _ui = script.Parent._ui
local AdminEvents = script.Parent.AdminEvents
local Utility = ReplicatedStorage.Utility
local AdminEvent = ReplicatedStorage._adminRemotes.Server.AdminEvent
local SendCoreNotif = ReplicatedStorage._adminRemotes.Client.SendCoreNotif
local Constants = require(Utility.Constants)
local DataStore = DataStoreService:GetDataStore("BanSystem")

local DATA_BANS_KEY = "PlayerBans"
local ADMINPANELUI_NAME = "AdminPanelUI"

local loadedEvents = {}


local function checkBan(player)
	local bans = DataStore:GetAsync(DATA_BANS_KEY)

	if bans ~= nil then
		for _, ban in pairs(bans) do
			if player.UserId == ban.UserId then
				if ban.Days == "PERM" then
					player:Kick("\nYou're banned permanently for reason '" .. ban.Reason .. "'.\nYou won't be able to join again unless you get unbanned.")
					return true
				elseif math.floor(os.time()) < math.floor(ban.DateUntil) then
					player:Kick("\nYou're banned for " .. tostring(ban.Days) .. " day(s) for reason '" .. ban.Reason .. "'.")
					return true
				end
				
				bans[ban.UserId] = nil
				
				local success = pcall(function()
					DataStore:SetAsync(DATA_BANS_KEY, bans)
				end)
				if not success then
					wait(10)
					DataStore:SetAsync(DATA_BANS_KEY, bans)
				end
				
				return false
			end
		end
	else
		return false
	end
end

local function checkStaff(player, canReport)
	for _, rank in pairs(Constants.TRUSTED_RANKS) do
		if player:GetRankInGroup(Constants.GROUP_ID) == rank then
			return true
		end
	end
	
	if canReport then
		player:Kick("\nAdmin event fired.")
	end
	
	return false
end


if StarterGui:FindFirstChild(ADMINPANELUI_NAME) and script:FindFirstChild(ADMINPANELUI_NAME) then
	StarterGui:FindFirstChild(ADMINPANELUI_NAME):Destroy()
elseif StarterGui:FindFirstChild(ADMINPANELUI_NAME) then
	StarterGui:FindFirstChild(ADMINPANELUI_NAME).Parent = script
	warn("⚠: Move the " .. ADMINPANELUI_NAME .. " to be parented to this script!\nDone automatically but remember to do it by yourself for protections.", debug.traceback())
end

for _, obj in pairs(_ui:GetChildren()) do
	local clonedObj = obj:Clone()
	clonedObj.Parent = script.Parent:FindFirstChild(ADMINPANELUI_NAME)
end

Players.PlayerAdded:Connect(function(player)
	if checkBan(player) == true then
		return
	end
	
	if checkStaff(player, false) == true then
		if script.Parent:FindFirstChild(ADMINPANELUI_NAME) then
			local clonedPanel = script.Parent:FindFirstChild(ADMINPANELUI_NAME):Clone()
			clonedPanel.Parent = player.PlayerGui
		end
	end
end)

AdminEvent.OnServerEvent:Connect(function(player, data)
	if checkStaff(player, true) == false then
		return
	end
	
	local eventType = data.EventType
	local additional = data.Additional
	
	if not loadedEvents[eventType] then
		if AdminEvents:FindFirstChild(eventType) then
			loadedEvents[eventType] = require(AdminEvents:FindFirstChild(eventType))
		end
	end
	
	local success = loadedEvents[eventType]:Run(player, additional)
	if success then
		SendCoreNotif:FireClient(player, "Admin Panel", "All good!", 5)
	end
end)