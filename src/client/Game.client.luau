local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local sharedFolder = ReplicatedStorage:WaitForChild("Shared", 15)
local BrainrotConfig = require(sharedFolder:WaitForChild("BrainrotConfig"))
local NetworkProtocol = require(sharedFolder:WaitForChild("NetworkProtocol"))

local networkFolder = ReplicatedStorage:WaitForChild("BrainrotNetwork", 15)
local stateUpdateEvent = networkFolder:WaitForChild(NetworkProtocol.Events.STATE_UPDATE)
local tsunamiWarnEvent = networkFolder:WaitForChild(NetworkProtocol.Events.TSUNAMI_WARNING)
local tsunamiStrikeEvent = networkFolder:WaitForChild(NetworkProtocol.Events.TSUNAMI_STRIKE)
local brainrotCollectEvent = networkFolder:WaitForChild(NetworkProtocol.Events.BRAINROT_COLLECTED)
local brainrotDepositEvent = networkFolder:WaitForChild(NetworkProtocol.Events.BRAINROT_DEPOSITED)
local buyUpgradeFunc = networkFolder:WaitForChild(NetworkProtocol.Functions.BUY_UPGRADE)
local performRebirthFunc = networkFolder:WaitForChild(NetworkProtocol.Functions.PERFORM_REBIRTH)

-- Sound effects generator
local function playChime(pitch: number)
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://9114223171"
	sound.Pitch = pitch or 1
	sound.Volume = 0.5
	sound.Parent = SoundService
	sound:Play()
	game:GetService("Debris"):AddItem(sound, 2)
end

-- ScreenGui Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BrainrotHeistHUD"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Top Banner: Tsunami Warning Alert
local tsunamiAlert = Instance.new("Frame")
tsunamiAlert.Name = "TsunamiAlert"
tsunamiAlert.Size = UDim2.new(0.6, 0, 0, 60)
tsunamiAlert.Position = UDim2.new(0.2, 0, 0.02, 0)
tsunamiAlert.BackgroundColor3 = Color3.fromRGB(220, 20, 40)
tsunamiAlert.BackgroundTransparency = 1
tsunamiAlert.BorderSizePixel = 0
tsunamiAlert.Visible = false
tsunamiAlert.Parent = screenGui

local alertCorner = Instance.new("UICorner")
alertCorner.CornerRadius = UDim.new(0, 10)
alertCorner.Parent = tsunamiAlert

local alertStroke = Instance.new("UIStroke")
alertStroke.Color = Color3.fromRGB(255, 255, 255)
alertStroke.Thickness = 2
alertStroke.Parent = tsunamiAlert

local alertText = Instance.new("TextLabel")
alertText.Size = UDim2.new(1, 0, 1, 0)
alertText.BackgroundTransparency = 1
alertText.Font = Enum.Font.FredokaOne
alertText.TextSize = 24
alertText.TextColor3 = Color3.fromRGB(255, 255, 255)
alertText.Text = "⚠️ TSUNAMI INCOMING! RETURN TO BASE SAFEZONE! ⚠️"
alertText.Parent = tsunamiAlert

-- Main Status Dashboard (Top Left)
local hudFrame = Instance.new("Frame")
hudFrame.Name = "HUDFrame"
hudFrame.Size = UDim2.new(0, 280, 0, 190)
hudFrame.Position = UDim2.new(0, 20, 0, 20)
hudFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
hudFrame.BackgroundTransparency = 0.15
hudFrame.BorderSizePixel = 0
hudFrame.Parent = screenGui

local hudCorner = Instance.new("UICorner")
hudCorner.CornerRadius = UDim.new(0, 12)
hudCorner.Parent = hudFrame

local hudStroke = Instance.new("UIStroke")
hudStroke.Color = Color3.fromRGB(80, 140, 255)
hudStroke.Thickness = 2
hudStroke.Parent = hudFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -20, 0, 26)
titleLabel.Position = UDim2.new(0, 10, 0, 8)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.FredokaOne
titleLabel.TextSize = 18
titleLabel.TextColor3 = Color3.fromRGB(255, 220, 80)
titleLabel.Text = "⚡ TSUNAMI BRAINROT HEIST"
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = hudFrame

local cashLabel = Instance.new("TextLabel")
cashLabel.Size = UDim2.new(1, -20, 0, 24)
cashLabel.Position = UDim2.new(0, 10, 0, 38)
cashLabel.BackgroundTransparency = 1
cashLabel.Font = Enum.Font.GothamBold
cashLabel.TextSize = 16
cashLabel.TextColor3 = Color3.fromRGB(80, 255, 120)
cashLabel.Text = "💰 Cash: $0"
cashLabel.TextXAlignment = Enum.TextXAlignment.Left
cashLabel.Parent = hudFrame

local incomeLabel = Instance.new("TextLabel")
incomeLabel.Size = UDim2.new(1, -20, 0, 22)
incomeLabel.Position = UDim2.new(0, 10, 0, 64)
incomeLabel.BackgroundTransparency = 1
incomeLabel.Font = Enum.Font.GothamMedium
incomeLabel.TextSize = 14
incomeLabel.TextColor3 = Color3.fromRGB(150, 220, 255)
incomeLabel.Text = "📈 Income: +$0/s"
incomeLabel.TextXAlignment = Enum.TextXAlignment.Left
incomeLabel.Parent = hudFrame

local backpackLabel = Instance.new("TextLabel")
backpackLabel.Size = UDim2.new(1, -20, 0, 22)
backpackLabel.Position = UDim2.new(0, 10, 0, 88)
backpackLabel.BackgroundTransparency = 1
backpackLabel.Font = Enum.Font.GothamMedium
backpackLabel.TextSize = 14
backpackLabel.TextColor3 = Color3.fromRGB(255, 180, 80)
backpackLabel.Text = "🎒 Backpack: 0 / 3"
backpackLabel.TextXAlignment = Enum.TextXAlignment.Left
backpackLabel.Parent = hudFrame

local baseLabel = Instance.new("TextLabel")
baseLabel.Size = UDim2.new(1, -20, 0, 22)
baseLabel.Position = UDim2.new(0, 10, 0, 112)
baseLabel.BackgroundTransparency = 1
baseLabel.Font = Enum.Font.GothamMedium
baseLabel.TextSize = 13
baseLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
baseLabel.Text = "🏠 Base Plot: Base 1"
baseLabel.TextXAlignment = Enum.TextXAlignment.Left
baseLabel.Parent = hudFrame

local rebirthLabel = Instance.new("TextLabel")
rebirthLabel.Size = UDim2.new(1, -20, 0, 22)
rebirthLabel.Position = UDim2.new(0, 10, 0, 136)
rebirthLabel.BackgroundTransparency = 1
rebirthLabel.Font = Enum.Font.GothamMedium
rebirthLabel.TextSize = 13
rebirthLabel.TextColor3 = Color3.fromRGB(255, 120, 200)
rebirthLabel.Text = "🔥 Rebirths: 0 (1.0x Boost)"
rebirthLabel.TextXAlignment = Enum.TextXAlignment.Left
rebirthLabel.Parent = hudFrame

local safeBadge = Instance.new("TextLabel")
safeBadge.Size = UDim2.new(1, -20, 0, 20)
safeBadge.Position = UDim2.new(0, 10, 0, 160)
safeBadge.BackgroundTransparency = 1
safeBadge.Font = Enum.Font.GothamBold
safeBadge.TextSize = 12
safeBadge.TextColor3 = Color3.fromRGB(100, 255, 100)
safeBadge.Text = "🛡️ STATUS: SAFE (IN BASE)"
safeBadge.TextXAlignment = Enum.TextXAlignment.Left
safeBadge.Parent = hudFrame

-- Upgrades Menu Panel (Bottom Right)
local shopFrame = Instance.new("Frame")
shopFrame.Name = "ShopFrame"
shopFrame.Size = UDim2.new(0, 260, 0, 190)
shopFrame.Position = UDim2.new(1, -280, 1, -210)
shopFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
shopFrame.BackgroundTransparency = 0.15
shopFrame.BorderSizePixel = 0
shopFrame.Parent = screenGui

local shopCorner = Instance.new("UICorner")
shopCorner.CornerRadius = UDim.new(0, 12)
shopCorner.Parent = shopFrame

local shopStroke = Instance.new("UIStroke")
shopStroke.Color = Color3.fromRGB(160, 100, 255)
shopStroke.Thickness = 2
shopStroke.Parent = shopFrame

local shopTitle = Instance.new("TextLabel")
shopTitle.Size = UDim2.new(1, -20, 0, 26)
shopTitle.Position = UDim2.new(0, 10, 0, 8)
shopTitle.BackgroundTransparency = 1
shopTitle.Font = Enum.Font.FredokaOne
shopTitle.TextSize = 16
shopTitle.TextColor3 = Color3.fromRGB(220, 180, 255)
shopTitle.Text = "🛒 UPGRADES & REBIRTH"
shopTitle.TextXAlignment = Enum.TextXAlignment.Left
shopTitle.Parent = shopFrame

local function createShopButton(name: string, yPos: number, bgColor: Color3)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(1, -20, 0, 42)
	btn.Position = UDim2.new(0, 10, 0, yPos)
	btn.BackgroundColor3 = bgColor
	btn.BorderSizePixel = 0
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 13
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.AutoButtonColor = true
	btn.Parent = shopFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	return btn
end

local speedBtn = createShopButton("SpeedBtn", 40, Color3.fromRGB(40, 120, 200))
local backpackBtn = createShopButton("BackpackBtn", 88, Color3.fromRGB(180, 110, 40))
local rebirthBtn = createShopButton("RebirthBtn", 136, Color3.fromRGB(180, 40, 90))

-- Notification Toast System (Center/Bottom)
local notificationLabel = Instance.new("TextLabel")
notificationLabel.Name = "NotificationLabel"
notificationLabel.Size = UDim2.new(0.5, 0, 0, 40)
notificationLabel.Position = UDim2.new(0.25, 0, 0.85, 0)
notificationLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
notificationLabel.BackgroundTransparency = 1
notificationLabel.Font = Enum.Font.GothamBold
notificationLabel.TextSize = 18
notificationLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
notificationLabel.Text = ""
notificationLabel.Parent = screenGui

local notifCorner = Instance.new("UICorner")
notifCorner.CornerRadius = UDim.new(0, 8)
notifCorner.Parent = notificationLabel

local function showNotification(text: string, color: Color3)
	notificationLabel.Text = text
	notificationLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
	notificationLabel.BackgroundTransparency = 0.2
	
	task.spawn(function()
		task.wait(2.2)
		local tween = TweenService:Create(notificationLabel, TweenInfo.new(0.6), {BackgroundTransparency = 1, TextTransparency = 1})
		tween:Play()
		tween.Completed:Wait()
		notificationLabel.TextTransparency = 0
		notificationLabel.Text = ""
	end)
end

-- Wire State Updates
local cachedState = nil
local function renderState(state)
	cachedState = state
	cashLabel.Text = string.format("💰 Cash: $%s", state.Cash or 0)
	incomeLabel.Text = string.format("📈 Income: +$%s/s", state.IncomeRate or 0)
	backpackLabel.Text = string.format("🎒 Backpack: %d / %d", state.BackpackCount or 0, state.BackpackCapacity or 3)
	baseLabel.Text = string.format("🏠 Base Plot: Base %s", tostring(state.BasePlotId or 1))
	rebirthLabel.Text = string.format("🔥 Rebirths: %d (%.1fx Multiplier)", state.Rebirths or 0, 1 + (state.Rebirths or 0) * 0.5)

	-- Speed Upgrade Info
	local currentSpeedLvl = state.Upgrades and state.Upgrades.speed or 1
	local nextSpeedCost = BrainrotConfig.Upgrades.Speed.costForLevel(currentSpeedLvl)
	if nextSpeedCost then
		speedBtn.Text = string.format("⚡ Walkspeed Lvl %d (Cost: $%d)", currentSpeedLvl, nextSpeedCost)
	else
		speedBtn.Text = "⚡ Walkspeed: MAX"
	end

	-- Backpack Upgrade Info
	local currentBackpackLvl = state.Upgrades and state.Upgrades.backpack or 1
	local nextBackpackCost = BrainrotConfig.Upgrades.Backpack.costForLevel(currentBackpackLvl)
	if nextBackpackCost then
		backpackBtn.Text = string.format("🎒 Backpack Lvl %d (Cost: $%d)", currentBackpackLvl, nextBackpackCost)
	else
		backpackBtn.Text = "🎒 Backpack: MAX"
	end

	-- Rebirth Info
	local rebirthCost = BrainrotConfig.Upgrades.Rebirth.costForRebirth(state.Rebirths or 0)
	rebirthBtn.Text = string.format("🔥 Rebirth (%d) - Cost: $%d", (state.Rebirths or 0) + 1, rebirthCost)
end

stateUpdateEvent.OnClientEvent:Connect(function(state)
	renderState(state)
end)

-- Button Click Handlers
speedBtn.MouseButton1Click:Connect(function()
	local success, msg = buyUpgradeFunc:InvokeServer("speed")
	if success then
		playChime(1.2)
		showNotification("⚡ Walkspeed upgraded!", Color3.fromRGB(100, 200, 255))
	else
		showNotification(msg or "Not enough cash!", Color3.fromRGB(255, 100, 100))
	end
end)

backpackBtn.MouseButton1Click:Connect(function()
	local success, msg = buyUpgradeFunc:InvokeServer("backpack")
	if success then
		playChime(1.2)
		showNotification("🎒 Backpack capacity expanded!", Color3.fromRGB(255, 200, 100))
	else
		showNotification(msg or "Not enough cash!", Color3.fromRGB(255, 100, 100))
	end
end)

rebirthBtn.MouseButton1Click:Connect(function()
	local success, msg = performRebirthFunc:InvokeServer()
	if success then
		playChime(1.5)
		showNotification("🔥 REBIRTH SUCCESSFUL! Income Multiplier increased!", Color3.fromRGB(255, 100, 220))
	else
		showNotification(msg or "Need more cash to rebirth!", Color3.fromRGB(255, 100, 100))
	end
end)

-- Event Listeners
brainrotCollectEvent.OnClientEvent:Connect(function(data)
	playChime(1.1)
	showNotification(string.format("✨ Looted: %s (%s, +$%d/s)", data.name, data.rarity, data.income), Color3.fromRGB(255, 230, 100))
end)

brainrotDepositEvent.OnClientEvent:Connect(function(data)
	playChime(1.3)
	showNotification(string.format("🏦 Deposited %d Brainrots! +$%d Bonus Cash!", data.count, data.depositBonus), Color3.fromRGB(100, 255, 140))
end)

-- Tsunami Warning System
tsunamiWarnEvent.OnClientEvent:Connect(function(duration)
	tsunamiAlert.Visible = true
	tsunamiAlert.BackgroundTransparency = 0.2
	playChime(0.7)

	task.spawn(function()
		local remaining = duration
		while remaining > 0 do
			tsunamiAlert.BackgroundColor3 = (remaining % 2 == 0) and Color3.fromRGB(220, 20, 40) or Color3.fromRGB(180, 0, 0)
			alertText.Text = string.format("⚠️ TSUNAMI WAVE IN %ds! GET TO BASE SAFEZONE! ⚠️", remaining)
			task.wait(1)
			remaining -= 1
		end
		alertText.Text = "🌊 TSUNAMI SURGE SWEEPING WASTELAND! 🌊"
		task.wait(4)
		tsunamiAlert.Visible = false
	end)
end)

tsunamiStrikeEvent.OnClientEvent:Connect(function()
	showNotification("🌊 WASHED AWAY! Carried backpack lost! Return safely next time!", Color3.fromRGB(255, 80, 80))
end)

-- Safe zone proximity checker
task.spawn(function()
	while true do
		task.wait(0.5)
		local char = localPlayer.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			local rootPos = char.HumanoidRootPart.Position
			local distFromCenter = math.sqrt(rootPos.X * rootPos.X + rootPos.Z * rootPos.Z)
			if distFromCenter > (BrainrotConfig.Arena.Radius - 15) then
				safeBadge.Text = "🛡️ STATUS: SAFE ZONE (PROTECTED)"
				safeBadge.TextColor3 = Color3.fromRGB(100, 255, 120)
			else
				safeBadge.Text = "⚠️ STATUS: DANGER ZONE (TSUNAMI HAZARD)"
				safeBadge.TextColor3 = Color3.fromRGB(255, 100, 100)
			end
		end
	end
end)

print("[Client] Tsunami Brainrot Heist HUD Loaded.")
