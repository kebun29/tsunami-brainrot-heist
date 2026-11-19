--!strict
-- WorldBuilder: Procedurally builds the immersive 3D Arena, 4 Player Bases, and Wasteland

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BrainrotConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotConfig") :: ModuleScript)

local WorldBuilder = {}

local BASE_COLORS = {
	Color3.fromRGB(0, 170, 255), -- Base 1: Cyan
	Color3.fromRGB(255, 60, 60),  -- Base 2: Crimson
	Color3.fromRGB(80, 240, 80),  -- Base 3: Lime
	Color3.fromRGB(255, 190, 0),  -- Base 4: Amber Gold
}

local BASE_OFFSETS = {
	Vector3.new(0, 0, -BrainrotConfig.Arena.BasePlotDistance),  -- North
	Vector3.new(0, 0, BrainrotConfig.Arena.BasePlotDistance),   -- South
	Vector3.new(BrainrotConfig.Arena.BasePlotDistance, 0, 0),   -- East
	Vector3.new(-BrainrotConfig.Arena.BasePlotDistance, 0, 0),  -- West
}

function WorldBuilder.CreatePart(name: string, size: Vector3, cframe: CFrame, color: Color3, material: Enum.Material, parent: Instance): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material
	part.Anchored = true
	part.CanCollide = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

function WorldBuilder.BuildArena()
	-- Check if map already exists
	local existing = Workspace:FindFirstChild("TsunamiMap")
	if existing then
		existing:Destroy()
	end
	
	local mapFolder = Instance.new("Folder")
	mapFolder.Name = "TsunamiMap"
	mapFolder.Parent = Workspace
	
	-- 1. Main Floor / Ground
	local ground = WorldBuilder.CreatePart(
		"MainGround",
		BrainrotConfig.Arena.MapSize,
		CFrame.new(0, -10, 0),
		Color3.fromRGB(35, 38, 42),
		Enum.Material.Cobblestone,
		mapFolder
	)
	
	-- 2. Central Wasteland Debris & Spawning Ground
	local wastelandCenter = WorldBuilder.CreatePart(
		"WastelandCenter",
		Vector3.new(BrainrotConfig.Arena.WastelandRadius * 2, 2, BrainrotConfig.Arena.WastelandRadius * 2),
		CFrame.new(0, 1, 0),
		Color3.fromRGB(55, 45, 40),
		Enum.Material.CrackedLava,
		mapFolder
	)
	
	-- Hazard Zone Ring
	local ring = Instance.new("CylinderHandleAdornment")
	ring.Name = "HazardRing"
	ring.Adornee = wastelandCenter
	ring.Height = 0.5
	ring.Radius = BrainrotConfig.Arena.WastelandRadius
	ring.InnerRadius = BrainrotConfig.Arena.WastelandRadius - 3
	ring.Color3 = Color3.fromRGB(255, 50, 50)
	ring.Transparency = 0.3
	ring.CFrame = CFrame.Angles(math.rad(90), 0, 0)
	ring.Parent = wastelandCenter
	
	-- Central Monolith / Tower
	local monolith = WorldBuilder.CreatePart(
		"CentralMonolith",
		Vector3.new(16, 45, 16),
		CFrame.new(0, 22.5, 0),
		Color3.fromRGB(25, 25, 30),
		Enum.Material.Slate,
		mapFolder
	)
	
	-- Glowing Beacon on top of Monolith
	local beacon = WorldBuilder.CreatePart(
		"SirenBeacon",
		Vector3.new(8, 8, 8),
		CFrame.new(0, 48, 0),
		Color3.fromRGB(255, 200, 0),
		Enum.Material.Neon,
		mapFolder
	)
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 180, 0)
	light.Range = 60
	light.Brightness = 4
	light.Parent = beacon
	
	-- Wasteland Props & Cover Obstacles
	local propPositions = {
		Vector3.new(45, 6, 45), Vector3.new(-45, 6, 45),
		Vector3.new(45, 6, -45), Vector3.new(-45, 6, -45),
		Vector3.new(70, 8, 0), Vector3.new(-70, 8, 0),
		Vector3.new(0, 8, 70), Vector3.new(0, 8, -70),
	}
	
	for i, pos in ipairs(propPositions) do
		local pillar = WorldBuilder.CreatePart(
			`RuinPillar_{i}`,
			Vector3.new(8, 16, 8),
			CFrame.new(pos) * CFrame.Angles(0, math.rad(i * 45), math.rad(math.sin(i) * 10)),
			Color3.fromRGB(70, 70, 75),
			Enum.Material.Concrete,
			mapFolder
		)
		
		-- Neon Accent Stripe
		local stripe = WorldBuilder.CreatePart(
			`NeonStripe_{i}`,
			Vector3.new(8.2, 1.5, 8.2),
			CFrame.new(pos + Vector3.new(0, 4, 0)),
			Color3.fromRGB(255, 60, 60),
			Enum.Material.Neon,
			pillar
		)
	end
	
	-- 3. Build 4 Player Base Plots
	local basesFolder = Instance.new("Folder")
	basesFolder.Name = "Bases"
	basesFolder.Parent = mapFolder
	
	for baseId = 1, 4 do
		local baseOffset = BASE_OFFSETS[baseId]
		local baseColor = BASE_COLORS[baseId]
		
		local baseModel = Instance.new("Model")
		baseModel.Name = `BasePlot_{baseId}`
		baseModel.Parent = basesFolder
		
		-- Base Platform
		local plot = WorldBuilder.CreatePart(
			"Platform",
			BrainrotConfig.Arena.BasePlotSize,
			CFrame.new(baseOffset + Vector3.new(0, 2, 0)),
			Color3.fromRGB(20, 22, 28),
			Enum.Material.DiamondPlate,
			baseModel
		)
		
		-- Neon Protective Perimeter
		local borderSize = BrainrotConfig.Arena.BasePlotSize
		local neonBorder = WorldBuilder.CreatePart(
			"NeonBorder",
			Vector3.new(borderSize.X + 2, 1, borderSize.Z + 2),
			CFrame.new(baseOffset + Vector3.new(0, 4.2, 0)),
			baseColor,
			Enum.Material.Neon,
			baseModel
		)
		
		-- Safe Zone ForceField Indicator (Holographic Dome)
		local safeDome = Instance.new("Part")
		safeDome.Name = "SafeZoneDome"
		safeDome.Shape = Enum.PartType.Ball
		safeDome.Size = Vector3.new(75, 75, 75)
		safeDome.CFrame = CFrame.new(baseOffset + Vector3.new(0, 20, 0))
		safeDome.Color = baseColor
		safeDome.Material = Enum.Material.ForceField
		safeDome.Transparency = 0.85
		safeDome.Anchored = true
		safeDome.CanCollide = false
		safeDome.Parent = baseModel
		
		-- Spawn Location for Players
		local spawn = Instance.new("SpawnLocation")
		spawn.Name = "BaseSpawn"
		spawn.Size = Vector3.new(10, 1, 10)
		spawn.CFrame = CFrame.new(baseOffset + Vector3.new(0, 4.5, -18))
		spawn.Color = baseColor
		spawn.Material = Enum.Material.Neon
		spawn.Anchored = true
		spawn.CanCollide = true
		spawn.Neutral = true
		spawn.Duration = 0
		spawn.Parent = baseModel
		
		-- Billboard on Spawn
		local spawnGui = Instance.new("BillboardGui")
		spawnGui.Size = UDim2.fromOffset(180, 50)
		spawnGui.StudsOffset = Vector3.new(0, 4, 0)
		spawnGui.AlwaysOnTop = true
		local spawnLabel = Instance.new("TextLabel")
		spawnLabel.Size = UDim2.fromScale(1, 1)
		spawnLabel.BackgroundTransparency = 1
		spawnLabel.Text = `[ BASE {baseId} - SAFE ZONE ]`
		spawnLabel.TextColor3 = baseColor
		spawnLabel.TextSize = 16
		spawnLabel.Font = Enum.Font.GothamBold
		spawnLabel.Parent = spawnGui
		spawnGui.Parent = spawn
		
		-- Deposit ATM / Collector Pad
		local depositPad = WorldBuilder.CreatePart(
			"DepositPad",
			Vector3.new(14, 1.2, 14),
			CFrame.new(baseOffset + Vector3.new(0, 4.5, 0)),
			Color3.fromRGB(0, 255, 120),
			Enum.Material.Neon,
			baseModel
		)
		
		local depositGui = Instance.new("BillboardGui")
		depositGui.Size = UDim2.fromOffset(260, 80)
		depositGui.StudsOffset = Vector3.new(0, 6, 0)
		depositGui.AlwaysOnTop = true
		
		local depositLabel = Instance.new("TextLabel")
		depositLabel.Size = UDim2.fromScale(1, 0.5)
		depositLabel.Position = UDim2.fromScale(0, 0)
		depositLabel.BackgroundTransparency = 1
		depositLabel.Text = "💎 DEPOSIT PAD 💎"
		depositLabel.TextColor3 = Color3.fromRGB(80, 255, 140)
		depositLabel.TextSize = 20
		depositLabel.Font = Enum.Font.GothamBlack
		depositLabel.Parent = depositGui
		
		local subLabel = Instance.new("TextLabel")
		subLabel.Size = UDim2.fromScale(1, 0.5)
		subLabel.Position = UDim2.fromScale(0, 0.5)
		subLabel.BackgroundTransparency = 1
		subLabel.Text = "[ STAND HERE TO STORE BRAINROTS ]"
		subLabel.TextColor3 = Color3.fromRGB(230, 255, 240)
		subLabel.TextSize = 13
		subLabel.Font = Enum.Font.Gotham
		subLabel.Parent = depositGui
		depositGui.Parent = depositPad
		
		-- 10 Pedestals for placed passive income brainrots
		local pedestalsFolder = Instance.new("Folder")
		pedestalsFolder.Name = "Pedestals"
		pedestalsFolder.Parent = baseModel
		
		for p = 1, 10 do
			local row = math.floor((p - 1) / 5)
			local col = (p - 1) % 5
			local pX = (col - 2) * 11
			local pZ = 16 + (row * 9)
			
			local pedestal = WorldBuilder.CreatePart(
				`Pedestal_{p}`,
				Vector3.new(6, 2.5, 6),
				CFrame.new(baseOffset + Vector3.new(pX, 5, pZ)),
				Color3.fromRGB(40, 45, 55),
				Enum.Material.Metal,
				pedestalsFolder
			)
			
			local rim = WorldBuilder.CreatePart(
				"NeonRim",
				Vector3.new(6.4, 0.4, 6.4),
				CFrame.new(baseOffset + Vector3.new(pX, 6.2, pZ)),
				baseColor,
				Enum.Material.Neon,
				pedestal
			)
		end
	end
	
	-- 4. Speed Boost Jump Pads connecting Base to Wasteland
	for baseId = 1, 4 do
		local baseOffset = BASE_OFFSETS[baseId]
		local dir = (Vector3.zero - baseOffset).Unit
		local padPos = baseOffset + (dir * 45)
		
		local jumpPad = WorldBuilder.CreatePart(
			`SpeedJumpPad_{baseId}`,
			Vector3.new(12, 1, 12),
			CFrame.new(padPos.X, 2, padPos.Z),
			Color3.fromRGB(255, 230, 0),
			Enum.Material.Neon,
			mapFolder
		)
		
		local padGui = Instance.new("BillboardGui")
		padGui.Size = UDim2.fromOffset(160, 40)
		padGui.StudsOffset = Vector3.new(0, 4, 0)
		padGui.AlwaysOnTop = true
		local l = Instance.new("TextLabel")
		l.Size = UDim2.fromScale(1, 1)
		l.BackgroundTransparency = 1
		l.Text = "⚡ BOOST PAD ⚡"
		l.TextColor3 = Color3.fromRGB(255, 240, 80)
		l.TextSize = 14
		l.Font = Enum.Font.GothamBold
		l.Parent = padGui
		padGui.Parent = jumpPad
		
		jumpPad.Touched:Connect(function(hit)
			local char = hit.Parent
			local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
			if root then
				root.AssemblyLinearVelocity = (dir * 90) + Vector3.new(0, 40, 0)
			end
		end)
	end
	
	return mapFolder
end

return WorldBuilder
