--!strict
-- BrainrotSpawner: Spawns 3D animated brainrot models in the wasteland with billboard stats

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local BrainrotConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotConfig") :: ModuleScript)
local NetworkProtocol = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("NetworkProtocol") :: ModuleScript)

local BrainrotSpawner = {}

local activeBrainrots: { [Model]: any } = {}
local spawnedFolder: Folder

-- Weighted random selection
local totalWeight = 0
for _, item in ipairs(BrainrotConfig.Items) do
	totalWeight += item.Weight
end

function BrainrotSpawner.PickRandomItem(): any
	local r = math.random() * totalWeight
	local accumulated = 0
	for _, item in ipairs(BrainrotConfig.Items) do
		accumulated += item.Weight
		if r <= accumulated then
			return item
		end
	end
	return BrainrotConfig.Items[1]
end

function BrainrotSpawner.CreateModel(item: any, position: Vector3): Model
	local rarityInfo = BrainrotConfig.Rarities[item.Rarity]
	local model = Instance.new("Model")
	model.Name = item.Id
	
	-- Root / Torso
	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = item.Scale
	root.CFrame = CFrame.new(position)
	root.Color = item.BodyColor
	root.Material = item.Material
	root.Anchored = true
	root.CanCollide = false
	root.TopSurface = Enum.SurfaceType.Smooth
	root.BottomSurface = Enum.SurfaceType.Smooth
	
	if item.Shape == "Ball" then
		root.Shape = Enum.PartType.Ball
	elseif item.Shape == "Cylinder" then
		root.Shape = Enum.PartType.Cylinder
	end
	root.Parent = model
	model.PrimaryPart = root
	
	-- Accent / Head Part
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = item.Scale * 0.65
	head.CFrame = root.CFrame * CFrame.new(0, item.Scale.Y * 0.65, 0)
	head.Color = item.AccentColor
	head.Material = Enum.Material.Neon
	head.Anchored = true
	head.CanCollide = false
	head.Shape = Enum.PartType.Ball
	head.Parent = model
	
	-- Glowing Crown / Aura for Legendary+
	if item.Rarity == "Legendary" or item.Rarity == "Mythic" or item.Rarity == "Divine" then
		local aura = Instance.new("Highlight")
		aura.Name = "RarityAura"
		aura.FillColor = rarityInfo.Color
		aura.OutlineColor = Color3.fromRGB(255, 255, 255)
		aura.FillTransparency = 0.6
		aura.OutlineTransparency = 0.1
		aura.Parent = model
		
		local sparkles = Instance.new("Sparkles")
		sparkles.SparkleColor = rarityInfo.Color
		sparkles.Parent = root
	end
	
	-- Billboard GUI (Name, Rarity, Income rate)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "InfoBillboard"
	billboard.Size = UDim2.fromOffset(220, 90)
	billboard.StudsOffset = Vector3.new(0, item.Scale.Y + 2.5, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 120
	
	-- Rarity Badge
	local rarityBadge = Instance.new("TextLabel")
	rarityBadge.Name = "RarityBadge"
	rarityBadge.Size = UDim2.new(1, 0, 0, 22)
	rarityBadge.Position = UDim2.fromScale(0, 0)
	rarityBadge.BackgroundColor3 = rarityInfo.BorderColor
	rarityBadge.BackgroundTransparency = 0.2
	rarityBadge.Text = `[ {rarityInfo.Name} ]`
	rarityBadge.TextColor3 = rarityInfo.Color
	rarityBadge.TextSize = 14
	rarityBadge.Font = Enum.Font.GothamBold
	rarityBadge.Parent = billboard
	
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 6)
	uiCorner.Parent = rarityBadge
	
	-- Name Label
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, 0, 0, 26)
	nameLabel.Position = UDim2.new(0, 0, 0, 24)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = item.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 18
	nameLabel.Font = Enum.Font.GothamBlack
	nameLabel.TextStrokeTransparency = 0.3
	nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	nameLabel.Parent = billboard
	
	-- Income Label
	local incomeLabel = Instance.new("TextLabel")
	incomeLabel.Name = "IncomeLabel"
	incomeLabel.Size = UDim2.new(1, 0, 0, 22)
	incomeLabel.Position = UDim2.new(0, 0, 0, 52)
	incomeLabel.BackgroundTransparency = 1
	incomeLabel.Text = `+\${item.Income}/sec  (\${item.Value})`
	incomeLabel.TextColor3 = Color3.fromRGB(100, 255, 120)
	incomeLabel.TextSize = 15
	incomeLabel.Font = Enum.Font.GothamBold
	incomeLabel.TextStrokeTransparency = 0.4
	incomeLabel.Parent = billboard
	
	billboard.Parent = root
	
	-- Proximity Prompt for interaction
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Collect Brainrot"
	prompt.ObjectText = item.Name
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 14
	prompt.RequiresLineOfSight = false
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.Parent = root
	
	model.Parent = spawnedFolder
	activeBrainrots[model] = item
	
	return model
end

function BrainrotSpawner.SpawnRandomInWasteland()
	if not spawnedFolder then return end
	
	-- Check capacity limit
	local count = 0
	for _ in pairs(activeBrainrots) do count += 1 end
	if count >= BrainrotConfig.Arena.MaxBrainrotsInField then
		return
	end
	
	-- Pick random position in wasteland circle
	local angle = math.random() * math.pi * 2
	local radius = 25 + (math.random() * (BrainrotConfig.Arena.WastelandRadius - 35))
	local x = math.cos(angle) * radius
	local z = math.sin(angle) * radius
	local spawnPos = Vector3.new(x, 4.5, z)
	
	local item = BrainrotSpawner.PickRandomItem()
	local model = BrainrotSpawner.CreateModel(item, spawnPos)
end

function BrainrotSpawner.Remove(model: Model)
	activeBrainrots[model] = nil
	model:Destroy()
end

function BrainrotSpawner.Init(economyService: any)
	spawnedFolder = Instance.new("Folder")
	spawnedFolder.Name = "SpawnedBrainrots"
	spawnedFolder.Parent = Workspace
	
	-- Initial spawn batch (20 items)
	for _ = 1, 20 do
		BrainrotSpawner.SpawnRandomInWasteland()
	end
	
	-- Continuous Spawner Loop
	task.spawn(function()
		while true do
			task.wait(BrainrotConfig.Arena.SpawnInterval)
			BrainrotSpawner.SpawnRandomInWasteland()
		end
	end)
	
	-- Idle Animation Loop (Gentle float and rotate)
	task.spawn(function()
		local t = 0
		while true do
			local dt = task.wait(0.05)
			t += dt
			for model, item in pairs(activeBrainrots) do
				local root = model.PrimaryPart
				if root then
					local origY = 4.5
					local offsetY = math.sin(t * 3 + root.Position.X * 0.1) * 0.6
					root.CFrame = CFrame.new(root.Position.X, origY + offsetY, root.Position.Z) * CFrame.Angles(0, t * 1.5, 0)
					local head = model:FindFirstChild("Head") :: BasePart?
					if head then
						head.CFrame = root.CFrame * CFrame.new(0, item.Scale.Y * 0.65, 0)
					end
				end
			end
		end
	end)
	
	-- ProximityPrompt Listener
	local ProximityPromptService = game:GetService("ProximityPromptService")
	ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
		local root = prompt.Parent :: BasePart?
		local model = root and root.Parent :: Model?
		if model and activeBrainrots[model] then
			local item = activeBrainrots[model]
			local success = economyService.TryPickup(player, item.Id)
			if success then
				BrainrotSpawner.Remove(model)
				-- Sound effect on pickup
				local snd = Instance.new("Sound")
				snd.SoundId = "rbxassetid://9114223175"
				snd.Volume = 0.5
				snd.Parent = player.Character or Workspace
				snd:Play()
				game:GetService("Debris"):AddItem(snd, 2)
			end
		end
	end)
end

return BrainrotSpawner
