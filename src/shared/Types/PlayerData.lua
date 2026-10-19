--!strict
-- PlayerData.lua - Type definitions untuk ProfileStore
-- Single source of truth untuk struktur data player

export type PlantSlot = {
	SeedId: string,
	PlantedAt: number, -- os.time() SERVER
	GrowthTime: number,
	IsMutant: boolean?,
	MutantMultiplier: number?, -- 1.5 - 3.0
}

export type PlotData = {
	PlotId: string,
	Slots: { [number]: PlantSlot? }, -- Index 1..MaxSlots, nil = kosong
	ShieldUntil: number?, -- os.time() sampai kapan shield aktif
	OwnerUserId: number?,
}

export type InventoryData = {
	Seeds: { [string]: number }, -- seedId -> qty
	Crops: { [string]: number }, -- harvested cropId -> qty
}

export type QuestData = {
	QuestId: string,
	Progress: number,
	Target: number,
	Claimed: boolean,
}

export type PlayerData = {
	-- Identity
	UserId: number,
	Username: string,
	FirstJoinAt: number,
	LastJoinAt: number,
	TotalPlayTime: number, -- detik

	-- Currency (SERVER LEDGER - JANGAN PERNAH TRUST CLIENT!)
	Coins: number,
	Gems: number,

	-- Progression
	Level: number,
	Xp: number,
	PlotsOwned: { string }, -- PlotIds
	Inventory: InventoryData,
	Collection: { [string]: boolean }, -- plantId -> unlocked

	-- Quests & Daily
	DailyStreak: number,
	LastDailyClaimDay: number, -- os.time() day index
	Quests: { QuestData },
	SeasonXp: number,
	SeasonTier: number,
	HasPremiumPass: boolean,

	-- Social
	GuildId: string?,
	Friends: { number },

	-- Stats
	Stats: {
		TotalHarvests: number,
		TotalSteals: number,
		TotalStealVictims: number,
		TotalFusions: number,
		TotalTrades: number,
		TotalIncome: number,
	},

	-- Security
	DataVersion: number, -- Untuk migrasi
	BanInfo: {
		IsBanned: boolean,
		Reason: string?,
		BannedAt: number?,
		ExpiresAt: number?,
	}?,
}

return {}
