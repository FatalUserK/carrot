local module = {}

if ModIsEnabled("conjurer_reborn") or ModIsEnabled("raksa") then return end


ModMaterialsFileAdd( "mods/userk.debug/modules/carrot/materials.xml" )

module.OnPlayerSpawned = function(player)
	local x, y = EntityGetTransform(player)
	GamePickUpInventoryItem(player, EntityLoad("mods/userk.debug/modules/carrot/entity.xml", x, y), false)
end

return module