--!strict
-- Purpose: responsive prototype HUD, shop, inventory, quests and collection.
-- Dependencies: Comm, Janitor, declarative Element factory. No authoritative client writes.
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Shared = game:GetService("ReplicatedStorage").Shared
local Config = require(Shared.Config.EconomyConfig)
local Plants = require(Shared.Config.PlantConfig)
local SeasonConfig = require(Shared.Config.SeasonConfig)
local RemoteConfig = require(Shared.Config.AntiCheatConfig)
local Comm = require(Shared.Modules.Comm)
local Janitor = require(Shared.Modules.Janitor)
local Element = require(script.Parent.Parent.UI.Components.Element)
local UI = {}
local green = Color3.fromRGB(99, 210, 142)
local dark = Color3.fromRGB(23, 39, 35)
function UI.Start(): Janitor.Janitor
	local cleanup, contentCleanup = Janitor.new(), Janitor.new()
	cleanup:Add(function(): () contentCleanup:Destroy() end)
	local player = Players.LocalPlayer
	local gui = Element.New("ScreenGui", { Name = "MysticGarden", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, player:WaitForChild("PlayerGui"))
	cleanup:Add(gui)
	local panel = Element.New("Frame", { Size = UDim2.new(0.94, 0, 0.68, 0), Position = UDim2.new(0.03, 0, 0.3, 0), BackgroundColor3 = dark, BackgroundTransparency = 0.08 }, gui)
	Element.New("UICorner", { CornerRadius = UDim.new(0, 16) }, panel)
	Element.New("UISizeConstraint", { MaxSize = Vector2.new(900, 620), MinSize = Vector2.new(280, 220) }, panel)
	local header = Element.New("TextLabel", { Size = UDim2.new(1, -24, 0, 36), Position = UDim2.fromOffset(12, 4), BackgroundTransparency = 1, Text = "MYSTIC GARDEN • Memuat data…", TextColor3 = green, TextSize = 18, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left }, panel) :: TextLabel
	local message = Element.New("TextLabel", { Size = UDim2.new(1, -24, 0, 46), Position = UDim2.fromOffset(12, 40), BackgroundTransparency = 1, Text = "Klaim kebun → beli Happy Sprout → tanam → panen → jual.", TextColor3 = Color3.new(1, 1, 1), TextSize = 14, TextWrapped = true }, panel) :: TextLabel
	local tabs = Element.New("ScrollingFrame", { Size = UDim2.new(1, -24, 0, 46), Position = UDim2.fromOffset(12, 90), BackgroundTransparency = 1, AutomaticCanvasSize = Enum.AutomaticSize.X, CanvasSize = UDim2.new(), ScrollBarThickness = 2, ScrollingDirection = Enum.ScrollingDirection.X }, panel)
	Element.New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, tabs)
	local content = Element.New("ScrollingFrame", { Size = UDim2.new(1, -24, 1, -150), Position = UDim2.fromOffset(12, 142), BackgroundTransparency = 1, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), ScrollBarThickness = 6 }, panel) :: ScrollingFrame
	Element.New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, content)
	-- Server-owned snapshot, dynamic shape is confined to this view-only boundary.
	local snapshot: any = nil
	local lastView = ""
	local tab, selected = "Kebun", "sprout"
	local function send(command: string): () Comm.Send(RemoteConfig.ActionRemote, command) end
	local function clear(): ()
		contentCleanup:Cleanup()
		for _, child in content:GetChildren() do if child:IsA("GuiObject") then child:Destroy() end end
	end
	local function label(text: string): ()
		Element.New("TextLabel", { Size = UDim2.new(1, -12, 0, 46), BackgroundTransparency = 1, Text = text, TextColor3 = Color3.new(1, 1, 1), TextSize = 14, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left }, content)
	end
	local function button(text: string, callback: () -> (), parent: Instance?, permanent: boolean?): ()
		local object = Element.New("TextButton", { Size = if parent then UDim2.fromOffset(110, 42) else UDim2.new(1, -12, 0, 46), BackgroundColor3 = green, TextColor3 = dark, Text = text, TextSize = 14, TextWrapped = true, Font = Enum.Font.GothamMedium, AutoButtonColor = true }, parent or content) :: TextButton
		Element.New("UICorner", { CornerRadius = UDim.new(0, 8) }, object)
		local janitor = if permanent then cleanup else contentCleanup
		janitor:Add(object.Activated:Connect(callback))
	end
	local render: () -> ()
	render = function(): ()
		clear()
		if not snapshot then label("Data sedang dimuat. Jika gagal, masuk ulang; data tidak direset.") return end
		if tab == "Kebun" then
			button(if snapshot.PlotId then "Kembali ke kebun #" .. snapshot.PlotId else "Klaim kebun saya", function(): () send(if snapshot.PlotId then "Go" else "Claim") end)
			label("Benih dipilih: " .. Plants[selected].Name .. ". Pilih benih melalui tab Toko.")
			for slot = 1, Config.Slots do
				local growing = snapshot.Slots[tostring(slot)]
				if growing then
					local plant = Plants[growing.PlantId]
					local seconds = math.max(0, growing.PlantedAt + plant.GrowthTime - os.time())
					button("Slot " .. slot .. " • " .. plant.Name .. (if seconds == 0 then " • PANEN" else " • Tumbuh"), function(): () send("Harvest:" .. slot) end)
				else
					button("Slot " .. slot .. " • Tanam " .. Plants[selected].Name .. " (" .. (snapshot.Seeds[selected] or 0) .. " benih)", function(): () send("Plant:" .. selected .. ":" .. slot) end)
				end
			end
		elseif tab == "Toko" then
			local ids: { string } = {}
			for id in Plants do table.insert(ids, id) end
			table.sort(ids, function(a: string, b: string): boolean return Plants[a].Price < Plants[b].Price end)
			for _, id in ids do
				local definition = Plants[id]
				button(definition.Name .. " • " .. definition.Price .. " Coins • " .. definition.GrowthTime .. "dtk • Pilih & beli", function(): () selected = id send("Buy:" .. id) end)
				if (snapshot.Seeds[id] or 0) > 0 then
					button("Pilih " .. definition.Name .. " (tanpa membeli)", function(): () selected = id tab = "Kebun" render() end)
				end
			end
		elseif tab == "Tas" then
			label("Jual panen untuk Coins, atau simpan 3 tanaman sama untuk fusion (" .. Config.FusionCost .. " Coins).")
			if #snapshot.Crops == 0 then label("Tas panen masih kosong.") end
			for _, crop in snapshot.Crops do
				local definition = Plants[crop.PlantId]
				if definition then
					local value = definition.SellValue * (if crop.Mutant then Config.MutationMultiplier else 1)
					button((if crop.Mutant then "MUTANT " else "") .. definition.Name .. " • Jual +" .. value, function(): () send("Sell:" .. crop.Id) end)
				end
			end
			for id, definition in Plants do
				local count = 0
				for _, crop in snapshot.Crops do if crop.PlantId == id and not crop.Mutant then count += 1 end end
				if count >= 3 then button("Fuse 3x " .. definition.Name, function(): () send("Fuse:" .. id) end) end
			end
		elseif tab == "Misi" then
			button("Ambil hadiah harian • Streak " .. snapshot.Streak, function(): () send("Daily") end)
			for name, target in { Harvest = Config.QuestHarvest, Steal = Config.QuestSteal, Fuse = Config.QuestFuse } do
				if name == "Steal" and not Config.EnableSteal then continue end
				button(name .. " " .. (snapshot.Quests[name] or 0) .. "/" .. target .. (if snapshot.QuestClaims[name] then " • Sudah diklaim" else " • Klaim hadiah"), function(): () send("Quest:" .. name) end)
			end
			label("XP season: " .. snapshot.XP .. " • " .. SeasonConfig.XPPerTier .. " XP per tier")
			for tier = 1, math.min(SeasonConfig.Tiers, math.floor(snapshot.XP / SeasonConfig.XPPerTier)) do
				if not snapshot.SeasonClaims[tostring(tier)] then button("Klaim season tier " .. tier, function(): () send("Season:" .. tier) end) end
			end
		elseif tab == "Koleksi" then
			for id, definition in Plants do label(if snapshot.Collection[id] then "✓ " .. definition.Name .. " • " .. definition.Rarity else "? Belum ditemukan • " .. definition.Rarity) end
		else
			label("1. Klaim kebun. 2. Beli Happy Sprout di Toko. 3. Dekati petak, pilih slot untuk menanam. 4. Tunggu 10 detik. 5. Panen, lalu jual di Tas.")
			label("Tanaman tetap tumbuh saat Anda keluar. Coins hanya didapat setelah panen dijual. Fusion menghasilkan mutant bernilai jual x2.")
			label("Siklus malam tersedia. Pencurian, trading, guild, auction, dan pembelian Robux belum dibuka pada build ini.")
			button("Lewati panduan", function(): () send("Tutorial") end)
		end
	end
	for _, name in { "Kebun", "Toko", "Tas", "Misi", "Koleksi", "Bantuan" } do
		button(name, function(): () tab = name content.CanvasPosition = Vector2.zero render() end, tabs, true)
	end
	cleanup:Add(Comm.Listen(RemoteConfig.NoticeRemote, function(payload: unknown): ()
		if typeof(payload) ~= "table" then return end
		local notice = payload :: { [string]: unknown }
		if typeof(notice.Message) == "string" then message.Text = notice.Message end
	end))
	cleanup:Add(Comm.Listen(RemoteConfig.StateRemote, function(payload: unknown): ()
		if typeof(payload) ~= "table" then return end
		snapshot = payload
		header.Text = "MYSTIC GARDEN • " .. snapshot.Coins .. " Coins • " .. snapshot.Gems .. " Gems • " .. (if snapshot.Night then "Malam " else "Siang ") .. snapshot.Remaining .. "dtk" .. (if snapshot.Persistent then "" else " • DATA UJI (tidak disimpan)")
		local ready = {}
		for slot = 1, Config.Slots do
			local growing = snapshot.Slots[tostring(slot)]
			ready[slot] = growing ~= nil and os.time() >= growing.PlantedAt + Plants[growing.PlantId].GrowthTime
		end
		local view = HttpService:JSONEncode({ snapshot.Seeds, snapshot.Crops, snapshot.Slots,
			snapshot.Collection, snapshot.PlotId or 0, snapshot.Quests, snapshot.QuestClaims,
			snapshot.XP, snapshot.SeasonClaims, snapshot.Streak, ready })
		if view ~= lastView then lastView = view render() end
	end))
	local toggle = Element.New("TextButton", { Size = UDim2.fromOffset(160, 42), Position = UDim2.fromOffset(12, 12), Text = "Buka/tutup kebun", BackgroundColor3 = green, TextColor3 = dark, TextSize = 14 }, gui) :: TextButton
	cleanup:Add(toggle.Activated:Connect(function(): () panel.Visible = not panel.Visible end))
	render()
	return cleanup
end
return UI
