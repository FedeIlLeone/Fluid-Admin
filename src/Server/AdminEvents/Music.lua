--[[

	© 2021 FedeIlLeone

	Music - Music server side module
	
	Functions:
	
		Music.Run(admin, data) --> [Success]
		
		* Parameter description for "Music.Run()":
			
			admin [Player] -- Player instance, normally must be an admin
			
			data [Table] -- Table with all additional data for the module
		
--]]

local Music = {}

local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SendCoreNotif = ReplicatedStorage._adminRemotes.Client.SendCoreNotif
local SendChatNotif = ReplicatedStorage._adminRemotes.Client.SendChatNotif

local MUSIC_NOTIF_COLOR = Color3.fromRGB(0, 255, 127)

local BGM = nil


function Music:Run(admin, data)
	local id = data.ID
	local loop = data.Loop
	
	if not workspace:FindFirstChild("BGM") then
		BGM = Instance.new("Sound")
		BGM.Name = "BGM"
		BGM.Parent = workspace
	end
	
	BGM = workspace:FindFirstChild("BGM")
	
	local ProductInfo = nil
	
	local success = pcall(function()
		ProductInfo = MarketplaceService:GetProductInfo(tonumber(id))
	end)
	if not success then
		SendCoreNotif:FireClient(admin, "Music", "Couldn't get productInfo", 5)
		return false
	end
	
	BGM.SoundId = "rbxassetid://" .. id
	BGM.Looped = loop
	
	BGM:Play()
	
	SendChatNotif:FireAllClients("Now playing:" .. (loop and " in loop " or " ") .. "'" .. ProductInfo.Name .. "'", MUSIC_NOTIF_COLOR)
	
	return true
end


return Music