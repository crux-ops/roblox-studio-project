--!strict
-- WorldConfig.lua - Day/Night cycle & global event

local WorldConfig = {
	DayDuration = 1500, -- 25 menit (detik)
	NightDuration = 300, -- 5 menit
	-- Total cycle = 30 menit = Steal window tiap 30 menit

	-- Lighting
	DayLighting = {
		ClockTime = 14,
		Brightness = 2,
		Ambient = Color3.fromRGB(140, 140, 140),
		OutdoorAmbient = Color3.fromRGB(140, 140, 140),
		FogEnd = 100000,
	},
	NightLighting = {
		ClockTime = 0,
		Brightness = 1.2,
		Ambient = Color3.fromRGB(40, 40, 80),
		OutdoorAmbient = Color3.fromRGB(20, 20, 50),
		FogEnd = 500,
		FogColor = Color3.fromRGB(20, 20, 40),
	},

	-- Notifikasi
	Warnings = {
		NightIn60 = "🌙 NIGHT STEAL dalam 60 detik! Siapkan pertahanan!",
		NightStart = "🌙 NIGHT DIMULAI! Steal aktif selama 5 menit! Lari!",
		NightEnd60 = "☀️ Day dalam 60 detik! Kembali ke kebun!",
		DayStart = "☀️ DAY DIMULAI! Waktunya menanam dengan tenang.",
	},
}

return WorldConfig
