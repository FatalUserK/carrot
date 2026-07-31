local module = {}

if ModIsEnabled("noita.fairmod") then return module end

local cheat_codes = dofile_once("mods/userk.debug/modules/cheats/cheats.lua")

local current_input_text = ""

module.OnWorldPreUpdate = function()

	local players = EntityGetWithTag("player_unit")

	if #players == 0 then return end

	local player = players[1]

	local keys = dofile_once("mods/userk.debug/modules/cheats/keyboard.lua")
	local buttons = dofile_once("mods/userk.debug/modules/cheats/controller.lua")

	local key_ranges = keys.key_ranges

	local last_added = ""

	local was_any_pressed = false
	if GameGetIsGamepadConnected() then
		for i=1,#buttons do
			if InputIsJoystickButtonJustDown(0, i) then
				last_added = (buttons[i] or "")
				current_input_text = current_input_text .. last_added
				was_any_pressed = #last_added > 0
			end
		end
	end

	for _, key_range in ipairs(key_ranges) do
		for i = key_range[1], key_range[2] do
			if InputIsKeyJustUp(i) then
				last_added = (keys.key_map[i] or "")
				current_input_text = current_input_text .. last_added
				was_any_pressed =  #last_added > 0
			end
		end
	end

	if not was_any_pressed then return end

	-- Function to check if input matches any cheat code
	---@param input string
	local function check_input(input)
		for _, v in ipairs(cheat_codes) do
			local code = v.code
			if type(code) == "function" then code = code() end

			local condition = v.condition
			if type(condition) == "function" then condition = condition() end
			if string.sub(code, 1, string.len(input)) == input and condition then
				if string.len(code) == string.len(input) then
					if GameHasFlagRun("userk.no_cheats") and not v.not_cheat then
						GamePrintImportant("$userk.cheats.silenced_log", "$userk.cheats.silenced_logdesc")
						return
					end
					if v.name then
						GamePrintImportant(GameTextGet("$userk.cheats.cheat_executed", v.name), v.description, v.decoration)
					end
					local x,y = EntityGetTransform(player)
					v.func(player, x, y)
					current_input_text = ""
				end

				if #input > 2 then
					print("current_cheat_text", input)
				end
				return true
			end
		end
		return false
	end

	local was_any_match = check_input(current_input_text)

	if not was_any_match then
		-- Try all suffixes of current_input_text
		local found = false
		for i = 2, #current_input_text do
			local suffix = current_input_text:sub(i)
			if check_input(suffix) then
				current_input_text = suffix
				found = true
				break
			end
		end
		if not found then current_input_text = "" end
	end
end

return module