--[[

	© 2021 FedeIlLeone

	ClientRemotes - Script to control all client side remotes
	
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local SendChatNotif = ReplicatedStorage._adminRemotes.Client.SendChatNotif
local SendClientCoreNotif = ReplicatedStorage._adminRemotes.Client.SendClientCoreNotif
local SendCoreNotif = ReplicatedStorage._adminRemotes.Client.SendCoreNotif


local function sendCoreNotif(title, text, duration, icon)
	StarterGui:SetCore("SendNotification", {
		Title = title,
		Text = text,
		Icon = icon,
		Duration = duration
	})
end


SendChatNotif.OnClientEvent:Connect(function(text, color)
	StarterGui:SetCore("ChatMakeSystemMessage", {
		Text = text,
		Color = color,
		Font = Enum.Font.SourceSansBold
	})
end)

SendCoreNotif.OnClientEvent:Connect(sendCoreNotif)
SendClientCoreNotif.Event:Connect(sendCoreNotif)