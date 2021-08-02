--[[

	© 2021 FedeIlLeone

	EditStats - EditStats client side module
	
	Functions:
	
		EditStats.Init()
		
		EditStats.Submit() --> [Table]
		
--]]

local EditStats = {}

local Players = game:GetService("Players")
local Frames = script.Parent.Parent.Frames
local EditStatsFrame = Frames.Pages.EditStatsFrame

local recentPlayers = { unpack(Players:GetPlayers()) }


Players.PlayerAdded:Connect(function(player)
	if not table.find(recentPlayers, player) then
		table.insert(recentPlayers, player)
	end
end)

function EditStats:Init()
	local PlayerTextBox = EditStatsFrame.PlayerTextBox
	local ValueTextBox = EditStatsFrame.ValueTextBox
	
	PlayerTextBox.TextBox.FocusLost:Connect(function()
		if PlayerTextBox.TextBox.Text ~= "" then
			for _, player in pairs(recentPlayers) do
				if string.sub(string.lower(player.Name), 1, #PlayerTextBox.TextBox.Text) == string.lower(PlayerTextBox.TextBox.Text) or string.sub(string.lower(player.DisplayName), 1, #PlayerTextBox.TextBox.Text) == string.lower(PlayerTextBox.TextBox.Text) then
					PlayerTextBox.TextBox.Text = player.Name
				end
			end
		end
	end)
	
	ValueTextBox.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
		ValueTextBox.TextBox.Text = string.gsub(ValueTextBox.TextBox.Text, "[^%d]", "")
	end)
end

function EditStats:Submit()
	local PlayerTextBox = EditStatsFrame.PlayerTextBox
	local ReasonTextBox = EditStatsFrame.ReasonTextBox
	local ValueTextBox = EditStatsFrame.ValueTextBox

	local request = {
		EventType = "EditStats",
		Additional = {
			Player = PlayerTextBox.TextBox.Text,
			Reason = ReasonTextBox.TextBox.Text,
			Value = ValueTextBox.TextBox.Text
		}
	}
	
	PlayerTextBox.TextBox.Text = ""
	ReasonTextBox.TextBox.Text = ""
	ValueTextBox.TextBox.Text = ""

	return request
end


return EditStats