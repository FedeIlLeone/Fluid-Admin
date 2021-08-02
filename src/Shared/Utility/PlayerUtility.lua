--[[

	© 2021 FedeIlLeone

	PlayerUtility - Utility regarding players
	
	Functions:
	
		PlayerUtility.GetNameAndUserIdFromPlayer(player) --> [userId, playerName]
		
		* Parameter description for "PlayerUtility.GetNameAndUserIdFromPlayer()":
			
			player [Player] -- Player instance
		
--]]

local PlayerUtility = {}

local Players = game:GetService("Players")


function PlayerUtility:GetNameAndUserIdFromPlayer(player)
	local userId = nil
	local playerName = nil

	local success = pcall(function()
		if Players:GetNameFromUserIdAsync(player) then
			playerName = Players:GetNameFromUserIdAsync(player)
			userId = Players:GetUserIdFromNameAsync(playerName)
		end
	end)
	if not success then
		success = pcall(function()
			if Players:GetUserIdFromNameAsync(player) then
				userId = Players:GetUserIdFromNameAsync(player)
				playerName = Players:GetNameFromUserIdAsync(userId)
			end
		end)
		if not success then
			return nil, nil
		end
	end

	return tonumber(userId), tostring(playerName)
end


return PlayerUtility