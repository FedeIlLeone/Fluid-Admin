--[[

	© 2021 FedeIlLeone

	Unban - Unban client side module
	
	Functions:
	
		Unban.Init()
		
		Unban.Submit() --> [Table]
		
--]]

local Unban = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local p = Players.LocalPlayer
local Framework = script.Parent.Parent.Framework
local Utility = ReplicatedStorage.Utility
local ButtonController = require(Framework.ButtonController)
local SendClientCoreNotif = ReplicatedStorage._adminRemotes.Client.SendClientCoreNotif
local Constants = require(Utility.Constants)
local Frames = script.Parent.Parent.Frames
local UnbanFrame = Frames.Pages.UnbanFrame

local recentPlayers = { unpack(Players:GetPlayers()) }
local proofsAdded = 0
local proofs = ""


Players.PlayerAdded:Connect(function(player)
	if not table.find(recentPlayers, player) then
		table.insert(recentPlayers, player)
	end
end)

function Unban:Init()
	local PlayerTextBox = UnbanFrame.PlayerTextBox
	local ProofTextBox = UnbanFrame.ExtraFrame.ProofTextBox
	local AddButton = ButtonController.Create(UnbanFrame.ExtraFrame.AddButton, "Max " .. Constants.MAX_PROOFS .. " proofs", "Left")
	
	PlayerTextBox.TextBox.FocusLost:Connect(function()
		if PlayerTextBox.TextBox.Text ~= "" then
			for _, player in pairs(recentPlayers) do
				if string.sub(string.lower(player.Name), 1, #PlayerTextBox.TextBox.Text) == string.lower(PlayerTextBox.TextBox.Text) or string.sub(string.lower(player.DisplayName), 1, #PlayerTextBox.TextBox.Text) == string.lower(PlayerTextBox.TextBox.Text) then
					PlayerTextBox.TextBox.Text = player.Name
				end
			end
		end
	end)
	
	AddButton.Clicked:Connect(function()
		if proofsAdded < Constants.MAX_PROOFS then
			proofsAdded += 1
			
			if proofs == "" then
				proofs = ProofTextBox.TextBox.Text
			else
				proofs = proofs .. ", " .. ProofTextBox.TextBox.Text
			end
			
			ProofTextBox.TextBox.Text = ""
			SendClientCoreNotif:Fire("Unban", "The proof has been added and stacked to " .. proofsAdded .. " proof(s).", 3)
		else
			ProofTextBox.TextBox.Text = ""
			SendClientCoreNotif:Fire("Unban", "Reached the limit of " .. Constants.MAX_PROOFS .. " proofs for the unban!", 3)
		end
	end)
end

function Unban:Submit()
	if p:GetRankInGroup(Constants.GROUP_ID) < Constants.HR_RANK then
		SendClientCoreNotif:Fire("Unban", "You're not able to use the unban feature!", 5)
		return
	end
	
	local PlayerTextBox = UnbanFrame.PlayerTextBox
	local ReasonTextBox = UnbanFrame.ReasonTextBox
	
	local request = {
		EventType = "Unban",
		Additional = {
			Player = PlayerTextBox.TextBox.Text,
			Reason = ReasonTextBox.TextBox.Text,
			Proof = proofs
		}
	}
	
	PlayerTextBox.TextBox.Text = ""
	ReasonTextBox.TextBox.Text = ""
	proofsAdded = 0
	proofs = ""
	
	return request
end


return Unban