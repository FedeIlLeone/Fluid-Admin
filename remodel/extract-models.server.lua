--[[

	© 2021 FedeIlLeone

	extract-models - Extracts the required models from development place
	
	This works with remodel (https://github.com/rojo-rbx/remodel)
	To run this script, execute `remodel run .\remodel\extract-models.server.lua`
	
--]]

local game = remodel.readPlaceFile("remodel/dev.rbxlx")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local UI = StarterGui:FindFirstChild("AdminPanelUI")
local _templates = StarterGui:FindFirstChild("_templates")
local _adminRemotes = ReplicatedStorage:FindFirstChild("_adminRemotes")

local UI_FINAL_DIRECTORY = "src/Server"
local TEMPLATES_FINAL_DIRECTORY = "src/Server/_ui/Framework"
local REMOTES_FINAL_DIRECTORY = "src/Shared"

remodel.writeModelFile(UI, UI_FINAL_DIRECTORY .. "/" .. UI.Name .. ".rbxmx")
remodel.writeModelFile(_templates, TEMPLATES_FINAL_DIRECTORY .. "/" .. _templates.Name .. ".rbxmx")
remodel.writeModelFile(_adminRemotes, REMOTES_FINAL_DIRECTORY .. "/" .. _adminRemotes.Name .. ".rbxmx")