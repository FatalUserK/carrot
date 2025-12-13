local PROFILER_ENABLED = false

if PROFILER_ENABLED then
	local noita_callbacks = {
		OnModPreInit = false,
		OnModInit = false,
		OnModPostInit = false,
		OnPlayerSpawned = false,
		OnPlayerDied = false,
		OnWorldInitialized = false,
		OnWorldPreUpdate = true,
		OnWorldPostUpdate = true,
		OnBiomeConfigLoaded = false,
		OnMagicNumbersAndWorldSeedInitialized = false,
		OnPausedChanged = false,
		OnModSettingsChanged = false,
		OnPausePreUpdate = true,
	}

	local function inject_profiler()
		if not PROFILER_ENABLED then return end

		local mods = ModGetActiveModIDs()

		for _, mod_id in ipairs(mods) do
			local init_path = "mods/" .. mod_id .. "/init.lua"

			if ModDoesFileExist(init_path) and mod_id ~= "evaisa.compatibility_fixes" then
				local content = ModTextFileGetContent(init_path)
				if content and content ~= "" then
					local profiler_header = [[
	-- [PROFILER INJECTED BY evaisa.compatibility_fixes]
	local __PROFILER_MOD_ID__ = "]] .. mod_id .. [["
	local __PROFILER_START_TIME__ = GameGetRealWorldTimeSinceStarted()
	local __PROFILER_DATA__ = {}
	local __PROFILER_LOGGED_ONCE__ = {}
	local __PROFILER_CAN_PRINT__ = false

	local function __profiler_log__(msg)
		table.insert(__PROFILER_DATA__, msg)
	end

	local function __profiler_flush__()
		for _, msg in ipairs(__PROFILER_DATA__) do
			print(msg)
		end
		__PROFILER_DATA__ = {}
	end

	local function __profiler_wrap_callback__(name, original_func, once_only)
		if not original_func then return nil end
		return function(...)
			if name == "OnMagicNumbersAndWorldSeedInitialized" then
				__PROFILER_CAN_PRINT__ = true
				__profiler_flush__()
			end
			local should_profile = not once_only or not __PROFILER_LOGGED_ONCE__[name]
			local start = GameGetRealWorldTimeSinceStarted()
			local results = {original_func(...)}
			local elapsed = GameGetRealWorldTimeSinceStarted() - start
			if should_profile and elapsed > 0.001 then
				if __PROFILER_CAN_PRINT__ then
					print(string.format("[PROFILER] [%s] %s took %.4fs", __PROFILER_MOD_ID__, name, elapsed))
				else
					__profiler_log__(string.format("[PROFILER] [%s] %s took %.4fs", __PROFILER_MOD_ID__, name, elapsed))
				end
				if once_only then
					__PROFILER_LOGGED_ONCE__[name] = true
				end
			end
			return unpack(results)
		end
	end

	]]
					local profiler_footer = [[

	-- [PROFILER FOOTER - WRAP CALLBACKS]
	local __profiler_init_end_time__ = GameGetRealWorldTimeSinceStarted()
	local __profiler_init_elapsed__ = __profiler_init_end_time__ - __PROFILER_START_TIME__
	if __profiler_init_elapsed__ > 0.001 then
		__profiler_log__(string.format("[PROFILER] [%s] init.lua execution took %.4fs", __PROFILER_MOD_ID__, __profiler_init_elapsed__))
	end

	if not OnMagicNumbersAndWorldSeedInitialized then
		function OnMagicNumbersAndWorldSeedInitialized()
			__PROFILER_CAN_PRINT__ = true
			__profiler_flush__()
		end
	end

	]]
					local callback_wrappers = ""
					for callback_name, once_only in pairs(noita_callbacks) do
						callback_wrappers = callback_wrappers .. string.format(
							"if %s then %s = __profiler_wrap_callback__(\"%s\", %s, %s) end\n",
							callback_name, callback_name, callback_name, callback_name, tostring(once_only)
						)
					end

					profiler_footer = profiler_footer .. callback_wrappers

					local new_content = profiler_header .. content .. profiler_footer
					ModTextFileSetContent(init_path, new_content)
				end
			end
		end
	end

	inject_profiler()

	local queued_prints = {}

	local queue_print = function(msg)
		table.insert(queued_prints, msg)
	end



	local DEBUG = true

	function OnMagicNumbersAndWorldSeedInitialized()
		__PROFILER_CAN_PRINT_GLOBAL__ = true
		if not DEBUG then return end
		for _, msg in ipairs(queued_prints) do
			print(msg)
		end
	end
	print(ModTextFileGetContent("mods/parallel_parity/init.lua"))
end


if ModIsEnabled("conjurer_reborn") or ModIsEnabled("raksa") then return end


ModMaterialsFileAdd( "mods/carrot/files/materials.xml" )


function OnPlayerSpawned(player)
	local x, y = EntityGetTransform(player)
	GamePickUpInventoryItem(player, EntityLoad("mods/carrot/files/entity.xml", x, y), false)
end
