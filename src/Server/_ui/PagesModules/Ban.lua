--[[

	© 2021 FedeIlLeone

	Ban - Ban client side module
	
	Functions:
	
		Ban.Init()
		
		Ban.Submit() --> [Table]
		
--]]

local Ban = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local p = Players.LocalPlayer
local Framework = script.Parent.Parent.Framework
local Utility = ReplicatedStorage.Utility
local ButtonController = require(Framework.ButtonController)
local SendClientCoreNotif = ReplicatedStorage._adminRemotes.Client.SendClientCoreNotif
local Constants = require(Utility.Constants)
local Frames = script.Parent.Parent.Frames
local BanFrame = Frames.Pages.BanFrame

local recentPlayers = { unpack(Players:GetPlayers()) }
local proofsAdded = 0
local proofs = ""


Players.PlayerAdded:Connect(function(player)
	if not table.find(recentPlayers, player) then
		table.insert(recentPlayers, player)
	end
end)

function Ban:Init()
	local PlayerTextBox = BanFrame.PlayerTextBox
	local DaysTextBox = BanFrame.ExtraFrame.DaysTextBox
	local ProofTextBox = BanFrame.ExtraFrame.ProofTextBox
	local AddButton = ButtonController.Create(BanFrame.ExtraFrame.AddButton, "Max " .. Constants.MAX_PROOFS .. " proofs")
	
	PlayerTextBox.TextBox.FocusLost:Connect(function()
		if PlayerTextBox.TextBox.Text ~= "" then
			for _, player in pairs(recentPlayers) do
				if string.sub(string.lower(player.Name), 1, #PlayerTextBox.TextBox.Text) == string.lower(PlayerTextBox.TextBox.Text) or string.sub(string.lower(player.DisplayName), 1, #PlayerTextBox.TextBox.Text) == string.lower(PlayerTextBox.TextBox.Text) then
					PlayerTextBox.TextBox.Text = player.Name
				end
			end
		end
	end)
	
	DaysTextBox.TextBox.PlaceholderText = "📅"
	DaysTextBox.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
		DaysTextBox.TextBox.Text = string.gsub(DaysTextBox.TextBox.Text, "[^%d]", "")
		
		if tonumber(DaysTextBox.TextBox.Text) then
			DaysTextBox.TextBox.Text = math.clamp(tonumber(DaysTextBox.TextBox.Text), 1, p:GetRankInGroup(Constants.GROUP_ID) < Constants.HR_RANK and Constants.MAX_LIMITED_DAYS or Constants.MAX_DAYS)
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
			SendClientCoreNotif:Fire("Ban", "The proof has been added and stacked to " .. proofsAdded .. " proof(s).", 3)
		else
			ProofTextBox.TextBox.Text = ""
			SendClientCoreNotif:Fire("Ban", "Reached the limit of " .. Constants.MAX_PROOFS .. " proofs for the ban!", 3)
		end
	end)
end

function Ban:Submit()
	local PlayerTextBox = BanFrame.PlayerTextBox
	local ReasonTextBox = BanFrame.ReasonTextBox
	local DaysTextBox = BanFrame.ExtraFrame.DaysTextBox
	
	local request = {
		EventType = "Ban",
		Additional = {
			Player = PlayerTextBox.TextBox.Text,
			Reason = ReasonTextBox.TextBox.Text,
			Days = DaysTextBox.TextBox.Text,
			Proof = proofs
		}
	}
	
	PlayerTextBox.TextBox.Text = ""
	ReasonTextBox.TextBox.Text = ""
	DaysTextBox.TextBox.Text = ""
	proofsAdded = 0
	proofs = ""
	
	return request
end


return Ban