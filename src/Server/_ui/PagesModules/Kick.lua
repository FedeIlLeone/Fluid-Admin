--[[

	© 2021 FedeIlLeone

	Kick - Kick client side module
	
	Functions:
	
		Kick.Init()
		
		Kick.Submit() --> [Table]
		
--]]

local Kick = {}

local Players = game:GetService("Players")
local Frames = script.Parent.Parent.Frames
local KickFrame = Frames.Pages.KickFrame

local recentPlayers = { unpack(Players:GetPlayers()) }


Players.PlayerAdded:Connect(function(player)
	if not table.find(recentPlayers, player) then
		table.insert(recentPlayers, player)
	end
end)

function Kick:Init()
	local PlayerTextBox = KickFrame.PlayerTextBox

	PlayerTextBox.TextBox.FocusLost:Connect(function()
		if PlayerTextBox.TextBox.Text ~= "" then
			for _, player in pairs(recentPlayers) do
				if string.sub(string.lower(player.Name), 1, #PlayerTextBox.TextBox.Text) == string.lower(PlayerTextBox.TextBox.Text) or string.sub(string.lower(player.DisplayName), 1, #PlayerTextBox.TextBox.Text) == string.lower(PlayerTextBox.TextBox.Text) then
					PlayerTextBox.TextBox.Text = player.Name
				end
			end
		end
	end)
end

function Kick:Submit()
	local PlayerTextBox = KickFrame.PlayerTextBox
	local ReasonTextBox = KickFrame.ReasonTextBox
	
	local request = {
		EventType = "Kick",
		Additional = {
			Player = PlayerTextBox.TextBox.Text,
			Reason = ReasonTextBox.TextBox.Text,
		}
	}
	
	PlayerTextBox.TextBox.Text = ""
	ReasonTextBox.TextBox.Text = ""
	
	return request
end


return Kick