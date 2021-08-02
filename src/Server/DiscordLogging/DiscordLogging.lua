--[[

	© 2021 FedeIlLeone

	DiscordLogging - Discord admin events logging with a webhook
	
	Functions:
	
		DiscordLogging.Run(data)
		
		* Parameter description for "DiscordLogging.Run()":
			
			data [Table] -- Table with embed data
		
--]]

local DiscordLogging = {}

local HttpService = game:GetService("HttpService")
local AdminFolder = script.Parent.Parent
local Webhook = AdminFolder.Webhook.Value


function DiscordLogging:Run(data)
	local encodedJSON = HttpService:JSONEncode(data)
	
	local success, err = pcall(function()
		HttpService:PostAsync(Webhook, encodedJSON)
	end)
	if not success then
		warn("⚠: " .. err, debug.traceback())
		wait(10)
		HttpService:PostAsync(Webhook, encodedJSON)
	end
end


return DiscordLogging