--[[

	© 2021 FedeIlLeone

	Music - Music client side module
	
	Functions:
	
		Music.Init()
		
		Music.Submit() --> [Table]
		
--]]

local Music = {}

local MarketplaceService = game:GetService("MarketplaceService")
local Framework = script.Parent.Parent.Framework
local ButtonController = require(Framework.ButtonController)
local Frames = script.Parent.Parent.Frames
local MusicFrame = Frames.Pages.MusicFrame

local loop = false


function Music:Init()
	local LoopButton = ButtonController.Create(MusicFrame.LoopButton, "Loop option for sound")
	local ColorUIGradient_OFF = MusicFrame.LoopButton.Configuration.UIGradient_OFF.Color
	local ColorUIGradient_ON = MusicFrame.LoopButton.Configuration.UIGradient_ON.Color
	local UIGradient = MusicFrame.LoopButton.UIGradient
	
	LoopButton.Clicked:Connect(function()
		local ButtonText = MusicFrame.LoopButton.Button.ButtonText
		
		UIGradient.Color = loop and ColorUIGradient_OFF or ColorUIGradient_ON
		ButtonText.Text = loop and "Loop OFF" or "Loop ON"
		
		loop = not loop
	end)
end

function Music:Submit()
	local IDTextBox = MusicFrame.IDTextBox
	local Info = MusicFrame.Info
	local ProductInfo = nil
	
	local success = pcall(function()
		ProductInfo = MarketplaceService:GetProductInfo(tonumber(IDTextBox.TextBox.Text))
	end)
	if not success then
		Info.Text = "🎵 Currently playing from you:\nN/A"
		return
	end
	
	Info.Text = "🎵 Currently playing from you:\n" .. ProductInfo.Name
	
	local request = {
		EventType = "Music",
		Additional = {
			ID = IDTextBox.TextBox.Text,
			Loop = loop
		}
	}
	
	return request
end


return Music