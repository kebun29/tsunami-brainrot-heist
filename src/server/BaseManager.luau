--!strict
-- BaseManager: Handles player base plot assignment, pedestals display, and deposit pads

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BrainrotConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotConfig") :: ModuleScript)

local BaseManager = {}

local assignedPlots: { [Player]: number } = {}
local nextPlotIndex = 1
local economyServiceRef: any = nil

function BaseManager.GetAssignedPlot(player: Player): number
	return assignedPlots[player] or 1
end

function BaseManager.GetBaseModel(plotId: number): Model?
	local map = Workspace:FindFirstChild("TsunamiMap")
	if not map then return nil end
	local bases = map:FindFirstChild("Bases")
	if not bases then return nil end
	return bases:FindFirstChild(`BasePlot_{plotId}`) :: Model?
end

function BaseManager.UpdatePedestals(player: Player, placedIds: { string })
	local plotId = BaseManager.GetAssignedPlot(player)
	local baseModel = BaseManager.GetBaseModel(plotId)
	if not baseModel then return end
	
	local pedestalsFolder = baseModel:FindFirstChild("Pedestals")
	if not pedestalsFolder then return end
	
	-- Clear old display items
	for _, child in ipairs(pedestalsFolder:GetChildren()) do
		local oldDisplay = child:FindFirstChild("DisplayItem")
		if oldDisplay then
			oldDisplay:Destroy()
		end
	end
	
	-- Populate new display items
	for index, brainrotId in ipairs(placedIds) do
		if index > BrainrotConfig.Arena.PedestalsPerPlot then break end
		local pedestal = pedestalsFolder:FindFirstChild(`Pedestal_{index}`) :: BasePart?
		if pedestal then
			local item = economyServiceRef.GetItem(brainrotId)
			if item then
				local displayModel = Instance.new("Model")
				displayModel.Name = "DisplayItem"
				
				local part = Instance.new("Part")
				part.Name = "Body"
				part.Size = item.Scale * 0.7
				part.CFrame = pedestal.CFrame * CFrame.new(0, 3, 0)
				part.Color = item.BodyColor
				part.Material = item.Material
				part.Anchored = true
				part.CanCollide = false
				
				if item.Shape == "Ball" then
					part.Shape = Enum.PartType.Ball
				elseif item.Shape == "Cylinder" then
					part.Shape = Enum.PartType.Cylinder
				end
				part.Parent = displayModel
				
				-- Floating Info Billboard
				local billboard = Instance.new("BillboardGui")
				billboard.Size = UDim2.fromOffset(160, 50)
				billboard.StudsOffset = Vector3.new(0, 3, 0)
				billboard.AlwaysOnTop = true
				
				local nameLabel = Instance.new("TextLabel")
				nameLabel.Size = UDim2.new(1, 0, 0, 20)
				nameLabel.BackgroundTransparency = 1
				nameLabel.Text = item.Name
				nameLabel.TextColor3 = BrainrotConfig.Rarities[item.Rarity].Color
				nameLabel.TextSize = 13
				nameLabel.Font = Enum.Font.GothamBold
				nameLabel.Parent = billboard
				
				local incLabel = Instance.new("TextLabel")
				incLabel.Size = UDim2.new(1, 0, 0, 18)
				incLabel.Position = UDim2.new(0, 0, 0, 18)
				incLabel.BackgroundTransparency = 1
				incLabel.Text = `+\${item.Income}/sec`
				incLabel.TextColor3 = Color3.fromRGB(100, 255, 120)
				incLabel.TextSize = 12
				incLabel.Font = Enum.Font.Gotham
				incLabel.Parent = billboard
				
				billboard.Parent = part
				displayModel.Parent = pedestal
			end
		end
	end
end

function BaseManager.Init(economyService: any)
	economyServiceRef = economyService
	
	-- Connect Deposit Pads
	local map = Workspace:WaitForChild("TsunamiMap", 10)
	if map then
		local bases = map:WaitForChild("Bases", 10)
		if bases then
			for baseId = 1, 4 do
				local base = bases:FindFirstChild(`BasePlot_{baseId}`)
				local pad = base and base:FindFirstChild("DepositPad") :: BasePart?
				if pad then
					pad.Touched:Connect(function(hit)
						local char = hit.Parent
						local player = char and Players:GetPlayerFromCharacter(char)
						if player and assignedPlots[player] == baseId then
							economyService.DepositBrainrots(player, function(p, items)
								BaseManager.UpdatePedestals(p, items)
							end)
						end
					end)
				end
			end
		end
	end
	
	-- Assign plots on join
	Players.PlayerAdded:Connect(function(player)
		assignedPlots[player] = nextPlotIndex
		nextPlotIndex = (nextPlotIndex % 4) + 1
		
		local data = economyService.GetData(player)
		if data then
			data.AssignedPlot = assignedPlots[player]
		end
		
		player.CharacterAdded:Connect(function(char)
			task.wait(0.1)
			local plotId = assignedPlots[player]
			local baseModel = BaseManager.GetBaseModel(plotId)
			local spawn = baseModel and baseModel:FindFirstChild("BaseSpawn") :: SpawnLocation?
			local root = char:FindFirstChild("HumanoidRootPart") :: BasePart?
			if spawn and root then
				root.CFrame = spawn.CFrame * CFrame.new(0, 3, 0)
			end
		end)
	end)
	
	Players.PlayerRemoving:Connect(function(player)
		assignedPlots[player] = nil
	end)
end

return BaseManager
