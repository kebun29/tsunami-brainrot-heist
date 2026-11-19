--!strict
-- NetworkProtocol: Central definition of remote event names and structures

local NetworkProtocol = {
	Events = {
		PickupRequest = "PickupBrainrot",
		DepositRequest = "DepositAllBrainrots",
		UpgradeRequest = "PurchaseUpgrade",
		RebirthRequest = "ExecuteRebirth",
		
		-- Server -> Client broadcasts
		StateUpdate = "PlayerStateUpdate",
		HazardState = "TsunamiHazardState",
		Notification = "SendClientNotice",
	},
}

return NetworkProtocol
