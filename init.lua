local callbacks = {
	OnModPreInit = {},
	OnModInit = {},
	OnModPostInit = {},
	OnPlayerSpawned = {},
	OnPlayerDied = {},
	OnWorldInitialized = {},
	OnWorldPreUpdate = {},
	OnWorldPostUpdate = {},
	OnBiomeConfigLoaded = {},
	OnMagicNumbersAndWorldSeedInitialized = {},
	OnPausedChanged = {},
	OnModSettingsChanged = {},
	OnPausePreUpdate = {},
}

local modules = {
	"carrot",
	"profiler",
	"cheats",
}


local translations = ModTextFileGetContent("data/translations/common.csv")
translations = translations .. "\n" .. ModTextFileGetContent("mods/userk.debug/files/standard.csv") .. "\n"
translations = translations:gsub("\r", ""):gsub("\n\n+", "\n")
ModTextFileSetContent("data/translations/common.csv", translations)

for _, module in ipairs(modules) do
	for key, func in pairs(dofile_once("mods/userk.debug/modules/"..module.."/init.lua") or {}) do
		if callbacks[key] then
			local target_callback = callbacks[key]
			target_callback[#target_callback+1] = func
		end
	end
end

for key, callback in pairs(callbacks) do
	_G[key] = function(...)
		for _,func in ipairs(callback) do
			func(...)
		end
	end
end