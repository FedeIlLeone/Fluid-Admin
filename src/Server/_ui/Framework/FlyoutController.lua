--[[

	© 2021 FedeIlLeone

	FlyoutController - Flyout controller for FluidUI
	
	Functions:
	
		FlyoutController.Create(Button, FlyoutText) --> [FluidUI Flyout]
		
		* Parameter description for "FlyoutController.Create()":
			
			Button [FluidUI Button] -- FluidUI Button object
			
			FlyoutText [string] -- Text that will be placed on the flyout
		
			FlyoutPosition [string] -- 'Up', 'Down', 'Left' or 'Right' for flyout positioning
		
--]]

local FlyoutController = {}

local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local FlyoutTemplate = script.Parent._templates.Flyout

local Controller = {
	Hovering = false,
	TimeHover = 0,
	PopupTweens = {}
}

local MAX_TIMEHOVER = 3


local function fadeAll(flyoutObject, inOrOut)
	for _, instance in pairs(flyoutObject.Flyout:GetDescendants()) do
		if instance:IsA("GuiObject") then
			if flyoutObject.PopupTweens[instance] then
				flyoutObject.PopupTweens[instance]:Cancel()
				flyoutObject.PopupTweens[instance] = nil
			end
		end
		
		local fadeProps = {}
		
		fadeProps.TextTransparency = instance:IsA("TextLabel") and (inOrOut and 1 or 0) or nil
		fadeProps.TextStrokeTransparency = instance:IsA("TextLabel") and (inOrOut and 1 or 0.85) or nil
		fadeProps.ImageTransparency = instance:IsA("ImageLabel") and (inOrOut and 1 or 0) or nil
		fadeProps.BackgroundTransparency = instance:IsA("Frame") and (inOrOut and 1 or 0) or nil
		
		flyoutObject.PopupTweens[instance] = TweenService:Create(instance, TweenInfo.new(0.25, Enum.EasingStyle.Linear), fadeProps)
		flyoutObject.PopupTweens[instance]:Play()
	end
end

local function fitText(textLabel, text)
	local pos = 1
	local newLine = true
	local textSize = textLabel.TextSize
	local font = textLabel.Font
	local absoluteSize = textLabel.AbsoluteSize
	local vector = Vector2.new(100000, 100000)
	local finalText = ""
	textLabel.Text = ""
	
	while pos < string.len(text) do
		local nextWord = string.sub(text, pos, string.find(text, " ", pos))
		
		if newLine then
			newLine = false
			for i = 1, string.len(nextWord) do
				local oldText = finalText
				finalText = finalText .. string.sub(nextWord, i, i)
				pos = pos + 1
				if absoluteSize.X <= TextService:GetTextSize(finalText, textSize, font, vector).X then
					finalText = oldText
					pos = pos - 1
					newLine = true
					break
				end
			end
		else
			local oldText = finalText
			finalText = oldText .. nextWord
			if absoluteSize.X <= TextService:GetTextSize(finalText, textSize, font, vector).X then
				finalText = oldText
				newLine = true
			else
				pos = pos + string.len(nextWord)
			end
		end
		
		if newLine then
			finalText = finalText .. "\n"
		end
	end
	
	textLabel.Text = finalText
	return math.ceil(TextService:GetTextSize(finalText, textSize, font, vector).X / textSize) * textSize, math.ceil(TextService:GetTextSize(finalText, textSize, font, vector).Y / textSize) * textSize
end

local function positionFix(position, absoluteSize)
	if position == "Up" then
		return Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, -absoluteSize.Y - 5)
	elseif position == "Down" then
		return Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, absoluteSize.Y + 5)
	elseif position == "Left" then
		return Vector2.new(0, 0.5), UDim2.new(0, -absoluteSize.X - 5, 0.5, 0)
	elseif position == "Right" then
		return Vector2.new(0, 0.5), UDim2.new(0, absoluteSize.X + 5, 0.5, 0)
	end
end


function Controller:_Hover()
	if self.Hovering then
		return
	end
	
	if self.TimeHover == 0 then
		self.TimeHover = tick()
	end
	
	if (tick() - self.TimeHover) < MAX_TIMEHOVER then
		return
	end
	
	self.Hovering = true
	fadeAll(self, false)
end


function Controller:_Unhover()
	self.TimeHover = 0
	self.Hovering = false
	fadeAll(self, true)
end


Controller.__index = Controller

function FlyoutController.Create(Button, FlyoutText, Position)
	if not Button then
		error("⚠: Button", Button, "is nil.")
	end
	
	local Flyout = FlyoutTemplate:Clone()
	Flyout.FlyoutText.Text = FlyoutText
	Flyout.Parent = Button.ButtonFrame
	local flyoutFitTextX, flyoutFitTextY = fitText(Flyout.FlyoutText, FlyoutText)
	Flyout.Size = UDim2.new(0, flyoutFitTextX + 10, 0, flyoutFitTextY + 10)
	local anchorPoint, position = positionFix(Position or "Up", Flyout.AbsoluteSize)
	Flyout.AnchorPoint = anchorPoint
	Flyout.Position = position
	
	local Object = {}
	setmetatable(Object, Controller)
	Object.Flyout = Flyout
	Object.ButtonObject = Button
	Object.ButtonFrame = Button.ButtonFrame
	Object.Button = Button.ButtonFrame.Button
	
	Object.ButtonFrame.Button.MouseMoved:Connect(function()
		Object:_Hover()
	end)
	Object.Button.MouseLeave:Connect(function()
		Object:_Unhover()
	end)
	Object.Button.SelectionGained:Connect(function()
		Object:_Hover()
	end)
	Object.Button.SelectionLost:Connect(function()
		Object:_Unhover()
	end)
		
	return Object
end


return FlyoutController