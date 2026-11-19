--!strict
-- EconomyService: Manages player economy, inventory, passive income tick, and upgrades

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local BrainrotConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotConfig") :: ModuleScript)
local NetworkProtocol = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("NetworkProtocol") :: ModuleScript)

export type PlayerData = {
	Cash: number,
	Rebirths: number,
	SpeedLevel: number,
	BackpackLevel: number,
	Backpack: { string }, -- List of Brainrot IDs
	PlacedBrainrots: { string }, -- List of Brainrot IDs on base pedestals
	AssignedPlot: number,
}

local EconomyService = {}
local playerData: { [Player]: PlayerData } = {}
local remoteEvents: { [string]: RemoteEvent } = {}

-- Utility to get item data by id
local itemLookup: { [string]: any } = {}
for _, item in ipairs(BrainrotConfig.Items) do
	itemLookup[item.Id] = item
end

function EconomyService.GetItem(id: string)
	return itemLookup[id]
end

function EconomyService.GetData(player: Player): PlayerData?
	return playerData[player]
end

function EconomyService.GetBackpackCapacity(player: Player): number
	local data = playerData[player]
	if not data then return 3 end
	local tier = BrainrotConfig.Upgrades.Backpack.Tiers[data.BackpackLevel]
	return tier and tier.Value or 3
end

function EconomyService.GetWalkSpeed(player: Player): number
	local data = playerData[player]
	if not data then return 16 end
	local tier = BrainrotConfig.Upgrades.Speed.Tiers[data.SpeedLevel]
	return tier and tier.Value or 16
end

function EconomyService.GetTotalPassiveIncome(player: Player): number
	local data = playerData[player]
	if not data then return 0 end
	
	local baseIncome = 0
	for _, id in ipairs(data.PlacedBrainrots) do
		local item = itemLookup[id]
		if item then
			baseIncome += item.Income
		end
	end
	
	local rebirthMultiplier = 1 + (data.Rebirths * BrainrotConfig.Upgrades.Rebirth.IncomeMultiplierPerRebirth)
	return math.floor(baseIncome * rebirthMultiplier)
end

function EconomyService.ApplyCharacterStats(player: Player)
	local char = player.Character
	if char then
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = EconomyService.GetWalkSpeed(player)
		end
	end
end

function EconomyService.SyncState(player: Player)
	local data = playerData[player]
	if not data then return end
	
	-- Update leaderstats
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local cashVal = leaderstats:FindFirstChild("Cash") :: NumberValue?
		if cashVal then cashVal.Value = data.Cash end
		local rebVal = leaderstats:FindFirstChild("Rebirths") :: NumberValue?
		if rebVal then rebVal.Value = data.Rebirths end
	end
	
	-- Fire client state
	local ev = remoteEvents[NetworkProtocol.Events.StateUpdate]
	if ev then
		ev:FireClient(player, {
			Cash = data.Cash,
			Rebirths = data.Rebirths,
			SpeedLevel = data.SpeedLevel,
			BackpackLevel = data.BackpackLevel,
			Backpack = data.Backpack,
			PlacedBrainrots = data.PlacedBrainrots,
			PassiveIncome = EconomyService.GetTotalPassiveIncome(player),
			BackpackMax = EconomyService.GetBackpackCapacity(player),
			AssignedPlot = data.AssignedPlot,
		})
	end
end

function EconomyService.Notify(player: Player, message: string, color: Color3?)
	local ev = remoteEvents[NetworkProtocol.Events.Notification]
	if ev then
		ev:FireClient(player, {
			Message = message,
			Color = color or Color3.fromRGB(255, 255, 255),
		})
	end
end

function EconomyService.TryPickup(player: Player, brainrotId: string): boolean
	local data = playerData[player]
	if not data then return false end
	
	local maxCapacity = EconomyService.GetBackpackCapacity(player)
	if #data.Backpack >= maxCapacity then
		EconomyService.Notify(player, "⚠️ Backpack Full! Deposit at your base!", Color3.fromRGB(255, 120, 120))
		return false
	end
	
	local item = itemLookup[brainrotId]
	if not item then return false end
	
	table.insert(data.Backpack, brainrotId)
	EconomyService.Notify(player, `+1 {item.Name} ({item.Rarity}) added to backpack!`, BrainrotConfig.Rarities[item.Rarity].Color)
	EconomyService.SyncState(player)
	return true
end

function EconomyService.DepositBrainrots(player: Player, baseManagerCallback: ((Player, {string}) -> ())?)
	local data = playerData[player]
	if not data or #data.Backpack == 0 then return end
	
	local depositedCount = 0
	local instantBonus = 0
	
	for _, id in ipairs(data.Backpack) do
		if #data.PlacedBrainrots < BrainrotConfig.Arena.PedestalsPerPlot then
			table.insert(data.PlacedBrainrots, id)
			depositedCount += 1
		else
			-- If pedestals full, sell for instant cash value
			local item = itemLookup[id]
			if item then
				instantBonus += item.Value
			end
		end
	end
	
	local clearedItems = table.clone(data.Backpack)
	table.clear(data.Backpack)
	
	if instantBonus > 0 then
		data.Cash += instantBonus
		EconomyService.Notify(player, `Deposit complete! Sold excess for \${instantBonus}!`, Color3.fromRGB(100, 255, 100))
	else
		EconomyService.Notify(player, `Deposited {depositedCount} Brainrots onto base pedestals!`, Color3.fromRGB(100, 255, 100))
	end
	
	if baseManagerCallback then
		baseManagerCallback(player, data.PlacedBrainrots)
	end
	
	EconomyService.SyncState(player)
end

function EconomyService.UpgradeSpeed(player: Player)
	local data = playerData[player]
	if not data then return end
	
	local nextLevel = data.SpeedLevel + 1
	local nextTier = BrainrotConfig.Upgrades.Speed.Tiers[nextLevel]
	if not nextTier then
		EconomyService.Notify(player, "Speed is already at maximum level!", Color3.fromRGB(255, 200, 50))
		return
	end
	
	if data.Cash >= nextTier.Cost then
		data.Cash -= nextTier.Cost
		data.SpeedLevel = nextLevel
		EconomyService.ApplyCharacterStats(player)
		EconomyService.Notify(player, `⚡ Speed upgraded to Level {nextLevel}!`, Color3.fromRGB(80, 255, 80))
		EconomyService.SyncState(player)
	else
		EconomyService.Notify(player, `Need \${nextTier.Cost - data.Cash} more cash for speed upgrade!`, Color3.fromRGB(255, 100, 100))
	end
end

function EconomyService.UpgradeBackpack(player: Player)
	local data = playerData[player]
	if not data then return end
	
	local nextLevel = data.BackpackLevel + 1
	local nextTier = BrainrotConfig.Upgrades.Backpack.Tiers[nextLevel]
	if not nextTier then
		EconomyService.Notify(player, "Backpack is already at maximum capacity!", Color3.fromRGB(255, 200, 50))
		return
	end
	
	if data.Cash >= nextTier.Cost then
		data.Cash -= nextTier.Cost
		data.BackpackLevel = nextLevel
		EconomyService.Notify(player, `🎒 Backpack upgraded to {nextTier.Value} slots!`, Color3.fromRGB(80, 255, 80))
		EconomyService.SyncState(player)
	else
		EconomyService.Notify(player, `Need \${nextTier.Cost - data.Cash} more cash for backpack upgrade!`, Color3.fromRGB(255, 100, 100))
	end
end

function EconomyService.ExecuteRebirth(player: Player)
	local data = playerData[player]
	if not data then return end
	
	local rebirthConfig = BrainrotConfig.Upgrades.Rebirth
	local cost = rebirthConfig.BaseCost * math.pow(rebirthConfig.CostMultiplier, data.Rebirths)
	
	if data.Cash >= cost then
		data.Cash = 0
		data.Rebirths += 1
		data.SpeedLevel = 1
		data.BackpackLevel = 1
		table.clear(data.Backpack)
		-- Placed brainrots retain to motivate player progression
		EconomyService.ApplyCharacterStats(player)
		EconomyService.Notify(player, `🌟 COSMIC REBIRTH #{data.Rebirths}! All income boosted by +{data.Rebirths * 50}%!`, Color3.fromRGB(0, 255, 255))
		EconomyService.SyncState(player)
	else
		EconomyService.Notify(player, `Need \${cost - data.Cash} more cash to Rebirth!`, Color3.fromRGB(255, 100, 100))
	end
end

function EconomyService.Init(remotes: { [string]: RemoteEvent }, baseManagerCallback: any)
	remoteEvents = remotes
	
	-- Setup player connections
	Players.PlayerAdded:Connect(function(player)
		local leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		
		local cash = Instance.new("NumberValue")
		cash.Name = "Cash"
		cash.Value = 0
		cash.Parent = leaderstats
		
		local rebirths = Instance.new("IntValue")
		rebirths.Name = "Rebirths"
		rebirths.Value = 0
		rebirths.Parent = leaderstats
		
		leaderstats.Parent = player
		
		playerData[player] = {
			Cash = 25, -- Starter gift cash
			Rebirths = 0,
			SpeedLevel = 1,
			BackpackLevel = 1,
			Backpack = {},
			PlacedBrainrots = {},
			AssignedPlot = 1,
		}
		
		player.CharacterAdded:Connect(function()
			task.wait(0.2)
			EconomyService.ApplyCharacterStats(player)
			EconomyService.SyncState(player)
		end)
		
		EconomyService.SyncState(player)
	end)
	
	Players.PlayerRemoving:Connect(function(player)
		playerData[player] = nil
	end)
	
	-- Passive Income Tick Loop (Every 1.0 second)
	task.spawn(function()
		while true do
			task.wait(1.0)
			for player, data in pairs(playerData) do
				local income = EconomyService.GetTotalPassiveIncome(player)
				if income > 0 then
					data.Cash += income
					local leaderstats = player:FindFirstChild("leaderstats")
					if leaderstats then
						local cashVal = leaderstats:FindFirstChild("Cash") :: NumberValue?
						if cashVal then cashVal.Value = data.Cash end
					end
				end
				EconomyService.SyncState(player)
			end
		end
	end)
	
	-- Bind Remote listeners
	local upgradeEv = remoteEvents[NetworkProtocol.Events.UpgradeRequest]
	if upgradeEv then
		upgradeEv.OnServerEvent:Connect(function(player, upgradeType: string)
			if upgradeType == "Speed" then
				EconomyService.UpgradeSpeed(player)
			elseif upgradeType == "Backpack" then
				EconomyService.UpgradeBackpack(player)
			end
		end)
	end
	
	local rebirthEv = remoteEvents[NetworkProtocol.Events.RebirthRequest]
	if rebirthEv then
		rebirthEv.OnServerEvent:Connect(function(player)
			EconomyService.ExecuteRebirth(player)
		end)
	end
	
	local depositEv = remoteEvents[NetworkProtocol.Events.DepositRequest]
	if depositEv then
		depositEv.OnServerEvent:Connect(function(player)
			EconomyService.DepositBrainrots(player, baseManagerCallback)
		end)
	end
end

return EconomyService
