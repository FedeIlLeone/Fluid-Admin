--[[

	© 2021 FedeIlLeone

	ButtonController - Button controller for FluidUI
	
	Functions:
	
		ButtonController.Create(ButtonFrame) --> [FluidUI Button]
		
		* Parameter description for "ButtonController.Create()":
			
			ButtonFrame [Frame] -- FluidUI Button frame
			
			FlyoutText [string] -- Text that will be placed on a possible flyout
			
			FlyoutPosition [string] -- 'Up', 'Down', 'Left' or 'Right' for a possible flyout positioning
		
	Members [Controller]:
	
		Controller.Clicked [RBXScriptSignal] - Event that fires on click, bind a function to it
		
--]]

local ButtonController = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TouchEnabled = UserInputService.TouchEnabled
local FlyoutController = require(script.Parent.FlyoutController)

local Controller = {
	DownTween = nil,
	UpTween = nil,
	HoverUpTween = nil,
	HoverDownTween = nil
}


function Controller:_DoDownTween()
	if self.UpTween then
		self.UpTween:Cancel()
		self.UpTween = nil
	end
	
	local DownTween = TweenService:Create(self.ButtonFrame, TweenInfo.new(0.075, Enum.EasingStyle.Linear), {
		BackgroundColor3 = Color3.new(self.OriginalColor.R * 0.75, self.OriginalColor.G * 0.75, self.OriginalColor.B * 0.75)
	})
	self.DownTween = DownTween
	DownTween:Play()
end

function Controller:_Button1Down()
	self:_DoDownTween()
end


function Controller:_DoUpTween()
	if self.DownTween then
		self.DownTween:Cancel()
		self.DownTween = nil
	end
	
	local UpTween = TweenService:Create(self.ButtonFrame, TweenInfo.new(0.075, Enum.EasingStyle.Quint), {
		BackgroundColor3 = self.OriginalColor
	})
	self.UpTween = UpTween
	UpTween:Play()
end

function Controller:_Button1Up()
	self:_FireClickEvent()
	self:_DoUpTween()
end


function Controller:_FireClickEvent()
	self.ClickedEvent:Fire()
end


function Controller:_Hover()
	if TouchEnabled then
		return
	end
	
	if self.HoverDownTween then
		self.HoverDownTween:Cancel()
		self.HoverDownTween = nil
	end
	
	local HoverUpTween = TweenService:Create(self.DropShadow, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
		Size = UDim2.new(1, 12, 1, 12)
	})
	self.HoverUpTween = HoverUpTween
	HoverUpTween:Play()
end


function Controller:_Unhover()
	self:_DoUpTween()
	if TouchEnabled then
		return
	end
	
	if self.HoverUpTween then
		self.HoverUpTween:Cancel()
		self.HoverUpTween = nil
	end
	
	local HoverDownTween = TweenService:Create(self.DropShadow, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
		Size = UDim2.new(1, 6, 1, 6)
	})
	self.HoverDownTween = HoverDownTween
	HoverDownTween:Play()
end


Controller.__index = Controller

function ButtonController.Create(ButtonFrame, FlyoutText, FlyoutPosition)
	if not ButtonFrame then
		error("⚠: ButtonFrame", ButtonFrame, "is nil.")
	end
	
	local Object = {}
	setmetatable(Object, Controller)
	Object.ButtonFrame = ButtonFrame
	Object.Button = ButtonFrame.Button
	Object.DropShadow = ButtonFrame.DropShadow
	Object.OriginalColor = ButtonFrame.BackgroundColor3
	Object.ClickedEvent = Instance.new("BindableEvent", ButtonFrame)
	Object.Clicked = Object.ClickedEvent.Event
	
	Object.Button.MouseButton1Down:Connect(function()
		Object:_Button1Down()
	end)
	Object.Button.MouseButton1Up:Connect(function()
		Object:_Button1Up()
	end)
	Object.Button.MouseMoved:Connect(function()
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
	
	if FlyoutText ~= nil and not TouchEnabled then
		Object.FlyoutObject = FlyoutController.Create(Object, FlyoutText, FlyoutPosition)
	end
	
	return Object
end


return ButtonController