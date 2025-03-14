if ModIsEnabled("conjurer_reborn") or ModIsEnabled("raksa") then return end



function OnPlayerSpawned(player)
	local x, y = EntityGetTransform(player)
	GamePickUpInventoryItem(player, EntityLoad("mods/carrot/files/entity.xml", x, y), false)
end

ModMaterialsFileAdd( "mods/carrot/files/materials.xml" )