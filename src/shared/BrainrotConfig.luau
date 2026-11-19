--!strict
-- BrainrotConfig: Definitive configuration for Tsunami Brainrot Heist

export type RarityType = "Common" | "Rare" | "Epic" | "Legendary" | "Mythic" | "Divine"

export type BrainrotItem = {
	Id: string,
	Name: string,
	Rarity: RarityType,
	Income: number, -- $/sec
	Value: number,  -- One-time cash bonus if sold
	Weight: number, -- Spawn rate weight
	BodyColor: Color3,
	AccentColor: Color3,
	Material: Enum.Material,
	Scale: Vector3,
	Shape: "Block" | "Ball" | "Cylinder" | "Special",
	Tagline: string,
}

local BrainrotConfig = {}

BrainrotConfig.Rarities = {
	Common = {
		Color = Color3.fromRGB(180, 180, 180),
		Name = "COMMON",
		BorderColor = Color3.fromRGB(120, 120, 120),
	},
	Rare = {
		Color = Color3.fromRGB(64, 156, 255),
		Name = "RARE",
		BorderColor = Color3.fromRGB(0, 100, 220),
	},
	Epic = {
		Color = Color3.fromRGB(175, 64, 255),
		Name = "EPIC",
		BorderColor = Color3.fromRGB(120, 0, 200),
	},
	Legendary = {
		Color = Color3.fromRGB(255, 180, 0),
		Name = "LEGENDARY",
		BorderColor = Color3.fromRGB(200, 130, 0),
	},
	Mythic = {
		Color = Color3.fromRGB(255, 45, 85),
		Name = "MYTHIC",
		BorderColor = Color3.fromRGB(180, 10, 40),
	},
	Divine = {
		Color = Color3.fromRGB(0, 255, 230),
		Name = "DIVINE",
		BorderColor = Color3.fromRGB(0, 180, 180),
	},
}

BrainrotConfig.Items = {
	-- COMMON
	{
		Id = "baby_skibidi",
		Name = "Baby Skibidi",
		Rarity = "Common",
		Income = 2,
		Value = 15,
		Weight = 40,
		BodyColor = Color3.fromRGB(230, 230, 230),
		AccentColor = Color3.fromRGB(50, 50, 50),
		Material = Enum.Material.Plastic,
		Scale = Vector3.new(2, 2.5, 2),
		Shape = "Cylinder",
		Tagline = "Brrr skibidi dop dop dop yes yes!",
	},
	{
		Id = "noob_mewing",
		Name = "Mewing Noob",
		Rarity = "Common",
		Income = 4,
		Value = 30,
		Weight = 35,
		BodyColor = Color3.fromRGB(255, 255, 50),
		AccentColor = Color3.fromRGB(0, 150, 255),
		Material = Enum.Material.SmoothPlastic,
		Scale = Vector3.new(2, 3, 1.5),
		Shape = "Block",
		Tagline = "🤫🧏 Bye bye jawline!",
	},
	{
		Id = "giga_cat",
		Name = "Giga Cat",
		Rarity = "Common",
		Income = 7,
		Value = 50,
		Weight = 30,
		BodyColor = Color3.fromRGB(200, 140, 90),
		AccentColor = Color3.fromRGB(255, 255, 255),
		Material = Enum.Material.SmoothPlastic,
		Scale = Vector3.new(2.2, 2.2, 2.8),
		Shape = "Ball",
		Tagline = "Heavy gym cat hits 300kg bench.",
	},

	-- RARE
	{
		Id = "sigma_toilet",
		Name = "Sigma Toilet",
		Rarity = "Rare",
		Income = 15,
		Value = 120,
		Weight = 22,
		BodyColor = Color3.fromRGB(240, 240, 245),
		AccentColor = Color3.fromRGB(20, 20, 20),
		Material = Enum.Material.Glass,
		Scale = Vector3.new(2.5, 3.2, 2.5),
		Shape = "Cylinder",
		Tagline = "Only true sigmas flush.",
	},
	{
		Id = "smurf_cat",
		Name = "Smurf Cat (Shailushai)",
		Rarity = "Rare",
		Income = 25,
		Value = 200,
		Weight = 18,
		BodyColor = Color3.fromRGB(40, 130, 240),
		AccentColor = Color3.fromRGB(255, 255, 255),
		Material = Enum.Material.SmoothPlastic,
		Scale = Vector3.new(2.4, 3.5, 2),
		Shape = "Special",
		Tagline = "We live, we love, we lie 🎵",
	},
	{
		Id = "grimace_shake",
		Name = "Grimace Shake",
		Rarity = "Rare",
		Income = 40,
		Value = 350,
		Weight = 15,
		BodyColor = Color3.fromRGB(150, 40, 180),
		AccentColor = Color3.fromRGB(255, 255, 255),
		Material = Enum.Material.Neon,
		Scale = Vector3.new(2, 3.8, 2),
		Shape = "Cylinder",
		Tagline = "Happy Birthday Grimace... *collapses*",
	},

	-- EPIC
	{
		Id = "fanum_taxer",
		Name = "Fanum Tax Collector",
		Rarity = "Epic",
		Income = 85,
		Value = 750,
		Weight = 10,
		BodyColor = Color3.fromRGB(210, 60, 60),
		AccentColor = Color3.fromRGB(255, 215, 0),
		Material = Enum.Material.Neon,
		Scale = Vector3.new(3, 4, 2.5),
		Shape = "Block",
		Tagline = "Taxing 10% of your fries instantly!",
	},
	{
		Id = "rizz_god",
		Name = "The Rizzler",
		Rarity = "Epic",
		Income = 140,
		Value = 1200,
		Weight = 8,
		BodyColor = Color3.fromRGB(190, 70, 240),
		AccentColor = Color3.fromRGB(255, 100, 200),
		Material = Enum.Material.ForceField,
		Scale = Vector3.new(2.8, 4.2, 2.5),
		Shape = "Special",
		Tagline = "Unspoken W Rizz activated.",
	},
	{
		Id = "looksmaxxer_king",
		Name = "Looksmaxxer King",
		Rarity = "Epic",
		Income = 220,
		Value = 1800,
		Weight = 7,
		BodyColor = Color3.fromRGB(255, 170, 120),
		AccentColor = Color3.fromRGB(0, 0, 0),
		Material = Enum.Material.SmoothPlastic,
		Scale = Vector3.new(3, 4.5, 2),
		Shape = "Block",
		Tagline = "Cheekbones sharper than a katana.",
	},

	-- LEGENDARY
	{
		Id = "skibidi_scientist",
		Name = "Professor Skibidi",
		Rarity = "Legendary",
		Income = 500,
		Value = 4500,
		Weight = 4,
		BodyColor = Color3.fromRGB(255, 200, 50),
		AccentColor = Color3.fromRGB(0, 220, 255),
		Material = Enum.Material.Neon,
		Scale = Vector3.new(3.5, 5, 3.5),
		Shape = "Cylinder",
		Tagline = "Calculated the exact velocity of brainrot.",
	},
	{
		Id = "the_rock_eyebrow",
		Name = "The Rock Eyebrow",
		Rarity = "Legendary",
		Income = 850,
		Value = 7500,
		Weight = 3,
		BodyColor = Color3.fromRGB(160, 140, 120),
		AccentColor = Color3.fromRGB(255, 50, 50),
		Material = Enum.Material.CorrodedMetal,
		Scale = Vector3.new(3.5, 5.2, 3),
		Shape = "Block",
		Tagline = "🤨 *Vine Boom sound effect intensifies*",
	},
	{
		Id = "quandale_dingle",
		Name = "Quandale Dingle",
		Rarity = "Legendary",
		Income = 1300,
		Value = 11000,
		Weight = 2.5,
		BodyColor = Color3.fromRGB(180, 100, 40),
		AccentColor = Color3.fromRGB(255, 255, 0),
		Material = Enum.Material.Neon,
		Scale = Vector3.new(3.2, 5.4, 2.5),
		Shape = "Special",
		Tagline = "Hey guys, Quandale Dingle here!",
	},

	-- MYTHIC
	{
		Id = "golden_walter",
		Name = "Golden Walter Dog",
		Rarity = "Mythic",
		Income = 3200,
		Value = 28000,
		Weight = 1.2,
		BodyColor = Color3.fromRGB(255, 215, 0),
		AccentColor = Color3.fromRGB(255, 255, 255),
		Material = Enum.Material.Neon,
		Scale = Vector3.new(4, 5.5, 4),
		Shape = "Ball",
		Tagline = "I like fire trucks and moster trucks.",
	},
	{
		Id = "omni_chad",
		Name = "Omni Mewing Chad",
		Rarity = "Mythic",
		Income = 6500,
		Value = 60000,
		Weight = 0.8,
		BodyColor = Color3.fromRGB(255, 80, 120),
		AccentColor = Color3.fromRGB(255, 230, 0),
		Material = Enum.Material.ForceField,
		Scale = Vector3.new(4.2, 6.2, 3.5),
		Shape = "Block",
		Tagline = "Can you hear the silence? Can you see the dark?",
	},
	{
		Id = "galaxy_brainrot",
		Name = "Galaxy Brain Cosmic",
		Rarity = "Mythic",
		Income = 12000,
		Value = 120000,
		Weight = 0.4,
		BodyColor = Color3.fromRGB(120, 20, 255),
		AccentColor = Color3.fromRGB(0, 255, 255),
		Material = Enum.Material.Neon,
		Scale = Vector3.new(4.8, 6.5, 4.8),
		Shape = "Ball",
		Tagline = "Expanding cerebral capacity across dimensions.",
	},

	-- DIVINE / SECRET
	{
		Id = "brainrot_overlord",
		Name = "👑 TITAN BRAINROT OVERLORD",
		Rarity = "Divine",
		Income = 35000,
		Value = 350000,
		Weight = 0.1,
		BodyColor = Color3.fromRGB(0, 255, 230),
		AccentColor = Color3.fromRGB(255, 255, 255),
		Material = Enum.Material.Neon,
		Scale = Vector3.new(6, 8.5, 6),
		Shape = "Special",
		Tagline = "THE APEX ENTITY OF ALL MEMES AND REBIRTHS.",
	},
} :: {BrainrotItem}

-- Upgrades configuration
BrainrotConfig.Upgrades = {
	Speed = {
		Name = "Movement Speed",
		Tiers = {
			{ Level = 1, Cost = 50, Value = 20 },
			{ Level = 2, Cost = 250, Value = 24 },
			{ Level = 3, Cost = 1000, Value = 28 },
			{ Level = 4, Cost = 5000, Value = 34 },
			{ Level = 5, Cost = 25000, Value = 42 },
		},
	},
	Backpack = {
		Name = "Backpack Size",
		Tiers = {
			{ Level = 1, Cost = 0, Value = 3 },
			{ Level = 2, Cost = 150, Value = 5 },
			{ Level = 3, Cost = 600, Value = 8 },
			{ Level = 4, Cost = 3000, Value = 14 },
			{ Level = 5, Cost = 15000, Value = 25 },
		},
	},
	Rebirth = {
		Name = "Cosmic Rebirth",
		BaseCost = 5000,
		CostMultiplier = 4,
		IncomeMultiplierPerRebirth = 1.5,
	},
}

-- Arena and Hazard constants
BrainrotConfig.Arena = {
	MapSize = Vector3.new(420, 20, 420),
	WastelandRadius = 130,
	BasePlotDistance = 160,
	BasePlotSize = Vector3.new(70, 4, 70),
	MaxBrainrotsInField = 35,
	SpawnInterval = 3, -- seconds
	PedestalsPerPlot = 10,
}

BrainrotConfig.Tsunami = {
	Interval = 45, -- seconds between tsunami cycles
	WarningDuration = 10, -- countdown duration
	WaveDuration = 8, -- wave transit duration across wasteland
	WaveSpeed = 65, -- studs per sec
	WaveSize = Vector3.new(350, 40, 30),
}

return BrainrotConfig
