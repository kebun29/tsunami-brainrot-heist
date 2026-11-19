local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

print("[Server] Initializing Tsunami Brainrot Heist...")

-- 1. Ensure Shared folder and Network instances exist
local sharedFolder = ReplicatedStorage:WaitForChild("Shared", 10)
if not sharedFolder then
	error("[Server] Missing ReplicatedStorage.Shared folder!")
end

local BrainrotConfig = require(sharedFolder:WaitForChild("BrainrotConfig"))
local NetworkProtocol = require(sharedFolder:WaitForChild("NetworkProtocol"))

local networkFolder = Instance.new("Folder")
networkFolder.Name = "BrainrotNetwork"
networkFolder.Parent = ReplicatedStorage

for _, eventName in pairs(NetworkProtocol.Events) do
	local ev = Instance.new("RemoteEvent")
	ev.Name = eventName
	ev.Parent = networkFolder
end

for _, funcName in pairs(NetworkProtocol.Functions) do
	local fn = Instance.new("RemoteFunction")
	fn.Name = funcName
	fn.Parent = networkFolder
end
print("[Server] Remote network channels initialized.")

-- 2. Load Services
local WorldBuilder = require(script.Parent:WaitForChild("WorldBuilder"))
local EconomyService = require(script.Parent:WaitForChild("EconomyService"))
local BaseManager = require(script.Parent:WaitForChild("BaseManager"))
local BrainrotSpawner = require(script.Parent:WaitForChild("BrainrotSpawner"))
local HazardManager = require(script.Parent:WaitForChild("HazardManager"))

-- 3. Construct 3D World Arena
WorldBuilder.build()
print("[Server] 3D World Arena built.")

-- 4. Initialize Core Systems
BaseManager.init()
EconomyService.init()
BrainrotSpawner.init()
HazardManager.init()

print("[Server] Tsunami Brainrot Heist fully loaded & ready!")
