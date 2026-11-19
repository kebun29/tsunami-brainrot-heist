--!strict
-- HazardManager: Controls the periodic Tsunami sweep, sirens, and safe zone checks

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local BrainrotConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotConfig") :: ModuleScript)
local NetworkProtocol = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("NetworkProtocol") :: ModuleScript)

local HazardManager = {}

local remoteEvents: { [string]: RemoteEvent } = {}
local economyServiceRef: any = nil
local tsunamiWave: Part? = nil

-- Safe Zone check: Base plots center
local BASE_CENTERS = {
	Vector3.new(0, 0, -BrainrotConfig.Arena.BasePlotDistance),
	Vector3.new(0, 0, BrainrotConfig.Arena.BasePlotDistance),
	Vector3.new(BrainrotConfig.Arena.BasePlotDistance, 0, 0),
	Vector3.new(-BrainrotConfig.Arena.BasePlotDistance, 0, 0),
}

function HazardManager.IsPlayerInSafeZone(player: Player): boolean
	local char = player.Character
	if not char then return false end
	local root = char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then return false end
	
	local pos = root.Position
	for _, center in ipairs(BASE_CENTERS) do
		local dist = (Vector2.new(pos.X, pos.Z) - Vector2.new(center.X, center.Z)).Magnitude
		if dist <= 48 and pos.Y >= 3.5 then
			return true
		end
	end
	return false
end

function HazardManager.CreateTsunamiWave(): Part
	local wave = Instance.new("Part")
	wave.Name = "TsunamiWave"
	wave.Size = BrainrotConfig.Tsunami.WaveSize
	wave.Color = Color3.fromRGB(0, 190, 255)
	wave.Material = Enum.Material.Neon
	wave.Transparency = 0.25
	wave.Anchored = true
	wave.CanCollide = false
	wave.CastShadow = false
	
	-- Foam crest
	local crest = Instance.new("Part")
	crest.Name = "Crest"
	crest.Size = Vector3.new(BrainrotConfig.Tsunami.WaveSize.X + 2, 4, 8)
	crest.CFrame = wave.CFrame * CFrame.new(0, BrainrotConfig.Tsunami.WaveSize.Y / 2, 0)
	crest.Color = Color3.fromRGB(240, 255, 255)
	crest.Material = Enum.Material.Neon
	crest.Anchored = true
	crest.CanCollide = false
	crest.Parent = wave
	
	-- Sound
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://9114223175"
	sound.Looped = true
	sound.Volume = 1
	sound.Parent = wave
	
	wave.Parent = Workspace:WaitForChild("TsunamiMap")
	return wave
end

function HazardManager.BroadcastHazard(state: "Safe" | "Warning" | "Surge", timeLeft: number)
	local ev = remoteEvents[NetworkProtocol.Events.HazardState]
	if ev then
		ev:FireAllClients({
			State = state,
			TimeLeft = timeLeft,
		})
	end
end

function HazardManager.RunCycle()
	-- Phase 1: Calm / Gathering (35 seconds)
	local calmTime = BrainrotConfig.Tsunami.Interval - BrainrotConfig.Tsunami.WarningDuration
	HazardManager.BroadcastHazard("Safe", calmTime)
	task.wait(calmTime)
	
	-- Phase 2: Warning (10 seconds)
	for remaining = BrainrotConfig.Tsunami.WarningDuration, 1, -1 do
		HazardManager.BroadcastHazard("Warning", remaining)
		task.wait(1)
	end
	
	-- Phase 3: Surge / Tsunami Sweep
	HazardManager.BroadcastHazard("Surge", BrainrotConfig.Tsunami.WaveDuration)
	
	if not tsunamiWave or not tsunamiWave.Parent then
		tsunamiWave = HazardManager.CreateTsunamiWave()
	end
	
	local startZ = 180
	local endZ = -180
	tsunamiWave.CFrame = CFrame.new(0, 20, startZ)
	
	local duration = BrainrotConfig.Tsunami.WaveDuration
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
	local tween = TweenService:Create(tsunamiWave, tweenInfo, {
		CFrame = CFrame.new(0, 20, endZ)
	})
	
	local hitConnection: RBXScriptConnection? = nil
	hitConnection = tsunamiWave.Touched:Connect(function(hit)
		local char = hit.Parent
		local player = char and Players:GetPlayerFromCharacter(char)
		if player and not HazardManager.IsPlayerInSafeZone(player) then
			local root = char:FindFirstChild("HumanoidRootPart") :: BasePart?
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			if root and humanoid then
				-- Wash player back
				root.AssemblyLinearVelocity = Vector3.new(0, 70, -120)
				
				-- Penalize carried backpack items
				local data = economyServiceRef.GetData(player)
				if data and #data.Backpack > 0 then
					table.clear(data.Backpack)
					economyServiceRef.SyncState(player)
					economyServiceRef.Notify(player, "🌊 WASHED OUT! Tsunami took your carried backpack items!", Color3.fromRGB(255, 60, 60))
				end
			end
		end
	end)
	
	tween:Play()
	tween.Completed:Wait()
	
	if hitConnection then hitConnection:Disconnect() end
	tsunamiWave.CFrame = CFrame.new(0, -100, 0)
end

function HazardManager.Init(remotes: { [string]: RemoteEvent }, economyService: any)
	remoteEvents = remotes
	economyServiceRef = economyService
	
	task.spawn(function()
		task.wait(5) -- Initial grace period
		while true do
			HazardManager.RunCycle()
		end
	end)
end

return HazardManager
