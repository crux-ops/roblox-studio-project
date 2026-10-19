--!strict
export type PlantDefinition = {
	Id: string,
	Name: string,
	Rarity: string,
	Price: number,
	GrowthTime: number,
	SellValue: number,
	Color: Color3,
}
return table.freeze({})
