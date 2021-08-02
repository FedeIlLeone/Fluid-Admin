--[[

	© 2021 FedeIlLeone

	UIScript - Main script to control client side of the Admin Panel
	
--]]

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Framework = script.Parent.Framework
local PagesModules = script.Parent.PagesModules
local Utility = ReplicatedStorage.Utility
local ButtonController = require(Framework.ButtonController)
local AdminEvent = ReplicatedStorage._adminRemotes.Server.AdminEvent
local Constants = require(Utility.Constants)
local SidebarFrame = script.Parent.SidebarFrame
local Frames = script.Parent.Frames
local ColorUIGradient_OFF = Frames.Main.SubmitButton.Configuration.UIGradient_OFF.Color
local ColorUIGradient_ON = Frames.Main.SubmitButton.Configuration.UIGradient_ON.Color
local UIGradient = Frames.Main.SubmitButton.UIGradient

local BACKGROUND_TWEENINFO = TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
local FADE_TWEENINFO = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
local CONTENTS_TWEENINFO = TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
local FRAMES_TWEENINFO = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local tweens = {}
local pages = {}
local submitCooldown = {}
local panelOpen = false
local framesOpen = false
local latestFrameTrigger = nil


local function clearTweens(...)
	local pack = {...}
	
	for _, instance in pairs(pack) do
		if tweens[instance] then
			tweens[instance]:Cancel()
			tweens[instance] = nil
		end
	end
end

local function closeFramesPanel()
	tweens[Frames] = TweenService:Create(Frames, FRAMES_TWEENINFO, {
		Position = UDim2.new(0, 130, 2, -5)
	})
	tweens[Frames]:Play()

	framesOpen = false
	latestFrameTrigger = nil
end

local function triggerFramesPanel(page, button)
	clearTweens(Frames)
	
	if framesOpen and latestFrameTrigger == button then
		closeFramesPanel()
	else
		tweens[Frames] = TweenService:Create(Frames, FRAMES_TWEENINFO, {
			Position = UDim2.new(0, 130, 1, -5)
		})
		tweens[Frames]:Play()
		
		local UIPageLayout = Frames.Pages.UIPageLayout
		UIPageLayout:JumpTo(page)
		
		local exposedFrameName = string.gsub(page.Name, "Frame", "")
		UIGradient.Color = submitCooldown[exposedFrameName] and ColorUIGradient_OFF or ColorUIGradient_ON
		
		framesOpen = true
		latestFrameTrigger = button
	end
end


for _, frame in pairs(Frames.Pages:GetChildren()) do
	if frame:IsA("GuiObject") then
		local exposedFrameName = string.gsub(frame.Name, "Frame", "")
		
		if PagesModules:FindFirstChild(exposedFrameName) then
			local page = require(PagesModules:FindFirstChild(exposedFrameName))
			
			if typeof(page.Init) == "function" then
				page:Init()
			end
			
			pages[exposedFrameName] = page
		end
	end
end

local MainButton = ButtonController.Create(SidebarFrame.Main.MainButton)
local Background = SidebarFrame.Main.Background
local Fade = SidebarFrame.Main.Background.Fade
local Contents = SidebarFrame.Contents

MainButton.Clicked:Connect(function()
	clearTweens(Background, Contents)
	
	if not panelOpen then
		for _, obj in pairs(Contents:GetChildren()) do
			if obj:IsA("GuiObject") then
				obj.Visible = true
			end
		end
	end
	
	tweens[Background] = TweenService:Create(Background, BACKGROUND_TWEENINFO, {
		Size = panelOpen and UDim2.new(0, 0, 1, 0) or UDim2.new(1, 0, 1, 0)
	})
	tweens[Background]:Play()
	tweens[Fade] = TweenService:Create(Fade, FADE_TWEENINFO, {
		BackgroundTransparency = panelOpen and 0 or 1
	})
	tweens[Fade]:Play()
	tweens[Contents] = TweenService:Create(Contents, CONTENTS_TWEENINFO, {
		Size = panelOpen and UDim2.new(0, 0, 0.95, 0) or UDim2.new(1, 0, 0.95, 0)
	})
	tweens[Contents]:Play()
	
	
	tweens[Fade].Completed:Connect(function()
		if not panelOpen then
			for _, obj in pairs(Contents:GetChildren()) do
				if obj:IsA("GuiObject") then
					obj.Visible = false
				end
			end
		end
	end)
	
	if panelOpen then
		closeFramesPanel()
	end
	
	panelOpen = not panelOpen
end)

local BanButton = ButtonController.Create(Contents.BanButton)
local BanFrame = Frames.Pages.BanFrame

BanButton.Clicked:Connect(function()
	triggerFramesPanel(BanFrame, BanButton)
end)

local UnbanButton = ButtonController.Create(Contents.UnbanButton)
local UnbanFrame = Frames.Pages.UnbanFrame

UnbanButton.Clicked:Connect(function()
	triggerFramesPanel(UnbanFrame, UnbanButton)
end)

local MusicButton = ButtonController.Create(Contents.MusicButton)
local MusicFrame = Frames.Pages.MusicFrame

MusicButton.Clicked:Connect(function()
	triggerFramesPanel(MusicFrame, MusicButton)
end)

local EditStatsButton = ButtonController.Create(Contents.EditStatsButton)
local EditStatsFrame = Frames.Pages.EditStatsFrame

EditStatsButton.Clicked:Connect(function()
	triggerFramesPanel(EditStatsFrame, EditStatsButton)
end)

local SubmitButton = ButtonController.Create(Frames.Main.SubmitButton, "Submits the current page")

SubmitButton.Clicked:Connect(function()
	local exposedButtonName = string.gsub(latestFrameTrigger.ButtonFrame.Name, "Button", "")
	local lstFrmTrg = latestFrameTrigger
	
	if not pages[exposedButtonName] then
		return
	end
	
	if submitCooldown[exposedButtonName] then
		return
	end
	
	UIGradient.Color = ColorUIGradient_OFF
	submitCooldown[exposedButtonName] = true
	delay(Constants.SUBMIT_DELAY, function()
		if latestFrameTrigger == lstFrmTrg then
			UIGradient.Color = ColorUIGradient_ON
		end
		submitCooldown[exposedButtonName] = nil
	end)
	
	local request = pages[exposedButtonName]:Submit()
	if request then
		AdminEvent:FireServer(request)
	end
end)