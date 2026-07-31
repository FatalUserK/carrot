--stylua: ignore start
dofile_once("data/scripts/perks/perk.lua")

local cheats = {
	{
		code = "motherlode",
		name = "Motherlode",
		description = "You got 1000 gold, you filthy cheater.",
		func = function(player)
			local wallet_component = EntityGetFirstComponentIncludingDisabled(player, "WalletComponent")
			if wallet_component == nil then return end
			ComponentSetValue2(wallet_component, "money", ComponentGetValue2(wallet_component, "money") + 1000)
		end,
	},
	{
		code = "duplicateme",
		name = "Dupe",
		description = "There are two of you??",
		func = function(player)
			EntitySetTransform(EntityLoad("data/entities/player_rng_items.xml"), EntityGetTransform(player))
		end,
	},
	{
		code = "noclip",
		name = "Noclip",
		description = "You idiot, what did you think was gonna happen",
		func = function(player)
			EntityApplyTransform(player, markers.noclip.x + GetParallelWorldPosition(EntityGetTransform(player))*BiomeMapGetSize()*512, markers.noclip.y)
		end,
	},
	{
		code = function()
			return StatsGetValue("world_seed") or "12345"
		end,
		progress_id = "world_reincarnation",
		name = "World Reincarnation",
		description = "The world has been regenerated with a new seed.",
		func = function(player)
			local x, y = EntityGetTransform(player)

			SetRandomSeed(x, y + GameGetFrameNum())

			local seed = Random(1, 2147483646) + Random(1, 2147483646)
			print("New seed: " .. seed)

			SetWorldSeed(seed)

			BiomeMapLoad_KeepPlayer(MagicNumbersGetValue("BIOME_MAP"), "data/biome/_pixel_scenes")
		end,
	},
	{
		code = "userk",
		do_not_random = true,
		not_cheat = true,
		func = function()
			print("UserK")
			GamePrint("UserK")
			GamePrintImportant("UserK", "UserK")
		end,
	},
	{
		code = "/kill",
		progress_id = "killplayer",
		name = "Ouch!",
		description = "Player fell out of the world.",
		do_not_random = true,
		func = function(player)
			EntityInflictDamage( player, 9999999999999999999999999, "DAMAGE_PHYSICS_BODY_DAMAGED", "Fell out of the world", "DISINTEGRATED", 0, 0 )
			EntityKill(player)
		end,
	},
	{
		code = "altf4",
		name = "oh",
		description = "okay bye-",
		do_not_random = true,
		func = function()
			EntityKill(GameGetWorldStateEntity()) --lmao
		end,
	},
	{code="/spawn",name="/spawn",description="Teleporting in 3... 2... wait, you're already there!",func=function(a)local b=tonumber(MagicNumbersGetValue("DESIGN_PLAYER_START_POS_X"))local c=tonumber(MagicNumbersGetValue("DESIGN_PLAYER_START_POS_Y"))local d=GetParallelWorldPosition(EntityGetTransform(a))*BiomeMapGetSize()*512;EntityApplyTransform(a,b+d,c)end},
	{
		code = "allsight",
		name = "All Seeing!",
		description = "i got tired of getting this manually while testing",
		func = function(player)
			perk_pickup( nil, player, "REMOVE_FOG_OF_WAR", true, false, true )
		end
	},
	{
		code = "whereami",
		name = "Where am I?",
		description = "Must've sleep walked..",
		func = function(player)
			do return end
			GameAddFlagRun("random_teleport_next")
			GameAddFlagRun("no_return")

			local x, y = EntityGetTransform(player)
			EntityLoad("mods/noita.fairmod/files/content/speedrun_door/portal_kolmi.xml", x, y)
		end
	},
	{
		code = "superchest",
		func = function(player)
			local x,y = EntityGetTransform(player)

			GamePrintImportant("Activated Cheat: Super Chest", "Alright, just this once")
			EntityLoad( "data/entities/items/pickup/chest_random_super.xml", x, y - 20)
			AddFlagPersistent("fairmod_spawned_superchest")
		end
	},
	{
		code = "gimmetinker",
		name = "gimme tinker",
		description = "no :)",
		func = function(player)
			perk_pickup( nil, player, "NO_WAND_EDITING", true, false, true )
		end
	},
	{
		code = "printuserdiagnostic",
		not_cheat = true,
		not_progress = true,
		func = function()
			GamePrint(tostring(ModSettingGet("fairmod.user_seed")))
		end
	},
	{
		code = "carrot",
		devmode = true,
		func = function(player)
			local x,y = EntityGetTransform(player)
			EntityLoad( "mods/userk.debug/modules/carrot/entity.xml", x, y - 10)
		end
	},
	{
		code = "mainworld",
		func = function(player)
			local x,y = EntityGetTransform(player)
			EntityApplyTransform(player, x - (GetParallelWorldPosition(EntityGetTransform(player)) * BiomeMapGetSize() * 512), y)
		end
	},
	{
		code = "thirsty",
		name = "Thirsty",
		description = "Hydration is key!",
		func = function(player)
			local x,y = EntityGetTransform(player)
			EntityLoad("data/entities/projectiles/deck/sea_water.xml", x, y)
		end
	},
	{
		code = "notthirsty",
		name = "Not Thirsty",
		description = "Hydration is not!",
		func = function(player)
			local x,y = EntityGetTransform(player)
			EntityLoad("data/entities/projectiles/deck/sea_lava.xml", x, y)
		end
	},
	{
		code = "anticheat",
		name = "A mysterious seal",
		description = "A mysterious seal has been enforced",
		do_not_random = true,
		not_cheat = true,
		not_progress = true,
		func = function(player)
			GameAddFlagRun("userk.no_cheats")
		end,
	},
	{
		code = "freevbucks",
		name = "The ancient script has been invoked",
		description = "The mysterious seal has been vanquished",
		do_not_random = true,
		not_cheat = true,
		not_progress = true,
		func = function(player)
			if GameHasFlagRun("userk.no_cheats") then
		   		GameRemoveFlagRun("userk.no_cheats")
			end
		end,
	},
	{
		code = "fixperformance",
		decoration = "mods/empty.png",
		func = function(p, x, y)
			SetRandomSeed(y, x-GameGetFrameNum())
			GamePrintImportant("Cheat activated: Fix Performance", Random() < .01 and "and then there were two." or "removed of all those pesky entities!", "mods/empty.png")
			local tags = {
				"player_unit",
				"world_state",
			}
			for _,entity_id in ipairs(EntityGetInRadius(x, y, math.huge)) do
				local kill = true
				for _,tag in ipairs(tags) do
					if EntityHasTag(EntityGetRootEntity(entity_id), tag) then kill = false break end
				end

				if kill and EntityGetName(entity_id) ~= "$animal_longleg" then
					EntityKill(entity_id)
				end
			end
		end
	},
	{
		code = "neveragain",
		name = "Never Again :)",
		description = "Life is simpler in the cube.",
		func = function(p, x, y)
			GameScreenshake(10)
			GamePlaySound("data/audio/Desktop/explosion.bank", "explosions/box", x, y)
			LoadPixelScene("mods/userk.debug/modules/cheats/misc/safety_box.png", "", x-23, y-23, "", true, false, nil, nil, true)
		end
	},
	{
		code = "groundbreakingtechnology",
		name = "Groundbreaking Technology",
		description = "New leaps made every year!",
		func = function(p, x, y)
			EntityLoad("data/entities/projectiles/deck/crumbling_earth_effect.xml", x, y)
		end
	},
	{
		code = "endofeverything",
		name = "End of Everything",
		description = "genuinely what were you expecting",
		func = function(p,x,y)
			local eoe = EntityLoad("data/entities/projectiles/deck/all_spells_loader.xml", x, y)
			if p then EntityAddChild(p, eoe) end
		end
	},
	{
		code = "chosen1",
		name = "Chosen One",
		description = "",
		func = function(p,x,y)
			perk_pickup(nil, p, perk_list[Random(1, #perk_list)].id, true, false, true)
		end
	},
	{
		code = "amightycocktail",
		name = "A Mighty Cocktail",
		description = "The Strongest Potion.",
		func = function(p,x,y)
			local potion = EntityLoad("data/entities/items/pickup/potion_empty.xml", x, y)
			local mat_inv = EntityGetFirstComponent(potion, "MaterialInventoryComponent")
			if not mat_inv then return end
			ComponentSetValue2(mat_inv, "do_reactions", 0)

			local mat_count = 0
			while true do
				local name = CellFactory_GetName(mat_count)
				if name == "unknown" then break
				else
					mat_count = mat_count + 1
					AddMaterialInventoryMaterial(potion, name, 2)
				end
			end
			GamePickUpInventoryItem(p, potion)
		end,
	},
	{
		code = "tfem",
		name = "Thanks For Edit Mands",
		description = "You're Melcowe :)", --You're Me  ow  :)
		func = function(player)
			perk_pickup(nil, player, "EDIT_WANDS_EVERYWHERE", true, false, true)
		end,
	},
}


local num_cheats = #cheats
for i, value in ipairs(dofile("mods/userk.debug/modules/cheats/locations.lua")) do
	local id = "goto" .. value.id
	local x = value.x
	local y = value.y

	cheats[num_cheats + i] = {
		code = id,
		progress_id = id,
		name = value.name or id,
		description = value.desc,
		decoration = value.decor or "",
		is_teleport = true,
		func = function(player)
			if value.pw_local then x = x + GetParallelWorldPosition(EntityGetTransform(player)) * BiomeMapGetSize() * 512 end
			EntityApplyTransform(player, x, y)
		end
	}
end



for i = 1, #cheats do
	local cheat = cheats[i]
	if not cheat.description then cheat.description = "" end
	if not cheat.decoration then
		local code_decor_filepath = "mods/userk.debug/modules/cheats/3pieces/" .. tostring(cheat.code) .. ".png"
		if ModDoesFileExist(code_decor_filepath) then
			cheat.decoration = code_decor_filepath
		else
			cheat.decoration = ""
		end
	end

	cheat.progress_id = cheat.progress_id or cheat.code

	if cheat.condition == nil then cheat.condition = true end

	if cheat.aliases then --do last so correct info is applied correctly
		for _,alias in ipairs(cheat.aliases) do
			local new_cheat = {}
			for key, value in pairs(cheat) do
				new_cheat[key] = value
			end
			new_cheat.code = alias
			new_cheat.progress_id = cheat.progress_id or cheat.code
			new_cheat.is_alias = true
			cheats[#cheats+1] = new_cheat
		end
	end
end

return cheats

--stylua: ignore end