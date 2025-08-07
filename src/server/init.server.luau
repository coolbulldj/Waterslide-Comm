print("Hello world, from server!")

local floating_system = require(game.ServerScriptService.server_modules.floaty_system)

local players = game:GetService("Players")

local function onPlayerAdded(player)
	print("Player added: " .. player.Name)
	-- Additional initialization logic for the player can go here
	floating_system.CreateFloaty(
		player,
		"test",
		CFrame.new(Vector3.new(-2335.956, 355.604, -524.296), Vector3.new(0, 0, 0))
	)
end

for _, player in ipairs(players:GetPlayers()) do
	onPlayerAdded(player)
end

players.PlayerAdded:Connect(onPlayerAdded)
