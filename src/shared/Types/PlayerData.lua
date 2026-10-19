--!strict
export type Crop = { Id: string, PlantId: string, Mutant: boolean }
export type Growing = { PlantId: string, PlantedAt: number }
export type Entry = { At: number, Amount: number, Reason: string, Balance: number }
export type Data = {
	Version: number, Coins: number, Gems: number,
	Seeds: { [string]: number }, Crops: { Crop }, Slots: { [string]: Growing },
	Collection: { [string]: boolean }, CollectionRewards: { [string]: boolean },
	LastSeen: number, LastDaily: number, Streak: number,
	QuestDay: number, Quests: { [string]: number }, QuestClaims: { [string]: boolean },
	SeasonId: number, XP: number, SeasonClaims: { [string]: boolean },
	ShieldUntil: number, LastSteal: number,
	Harvests: number, Steals: number, Fusions: number,
	Ledger: { Entry }, TutorialDone: boolean,
}
return {}
