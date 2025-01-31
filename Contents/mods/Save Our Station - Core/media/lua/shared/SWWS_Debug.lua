-------------------------------------------------------
-- Save Our Station! - Debug Options -- 
-------------------------------------------------------

SWWS_Debug = SWWS_Debug or {}

SWWS_Debug.version = "v12"
SWWS_Debug.isInitialized = false


-------------------------------------------------------
-- DEBUG OPTIONS -- 
-- DO NOT MESS WITH UNLESS YOU KNOW WHAT YOU ARE DOING!
-------------------------------------------------------

-- Forces mod to reinitialize game state every time a game is loaded (= Clears any currently-ongoing stages)
SWWS_Debug.forceInitialize = false

-- Ignores if the power is on or off, and forces breakdown checks every hour.
SWWS_Debug.ignoreRequirePowerShutoff = false

-- Force stage time to a single hour.
SWWS_Debug.forceMinimumTime = false

-- Forces the fatal pool to be chosen every time.
SWWS_Debug.forceFatal = false

-- Forces the NON-fatal (Interruption) pool to be chosen every time.
-- Important: This IGNORES the "Enable Interruptions" mod option.
SWWS_Debug.forceNonFatal = false

-- Makes batteries on military walkies last forever when enabled.
SWWS_Debug.infiniteBattery = false

-- Adds basic debug loadout of a walkie talkie and a watch to players.
SWWS_Debug.debugLoadout = false

-- Enables logging of various events
SWWS_Debug.logging = false

function SWWS_Debug.PrintTable(_table, _indents)
	_indents = _indents or 0

	for k, v in pairs(_table) do
		local formatting = string.rep("  ", _indents) .. k .. ": "
		if type(v) == "table" then
			print("SWWS:> " , formatting)
			SWWS_Debug.PrintTable(v, _indents+1)
		elseif type(v) == 'boolean' then
			print("SWWS:> " , formatting .. tostring(v))
		else
			print("SWWS:> " , formatting .. v)
		end
	end
end

-------------------------------------------------------

if SWWS_Debug.logging then

	local gameType = "Singleplayer"

	if isServer() then
		gameType = "Server"
	elseif isClient() then
		gameType = "Client / Host"
	end 

	print("SWWS: Game Type [" .. gameType .. "], running [" .. SWWS_Debug.version .. "]")

end

function SWWS_Debug.GetPlayers()
	local players = {}
	if not isClient() and not isServer() then
		-- Is singleplayer
		players = { getPlayer() }
    else
		players = getOnlinePlayers()
	end
	return players
end

function SWWS_Debug.RechargeRadios()
	for _, player in ipairs(SWWS_Debug.GetPlayers()) do
		local walkie = getPlayer():getInventory():getItemFromType("Radio.WalkieTalkie5", true, true)
		if walkie then
			walkie:getDeviceData():setPower(1)	
		end
	end
end
if SWWS_Debug.infiniteBattery then
	Events.EveryTenMinutes.Add(SWWS_Debug.RechargeRadios)
end

SWWS_Debug.playersWithDebugLoadout = {}

function SWWS_Debug.AddDebugLoadout()
	for _, player in ipairs(SWWS_Debug.GetPlayers()) do
		if not SWWS_Debug.playersWithDebugLoadout[player] then
			SWWS_Debug.playersWithDebugLoadout[player] = true

			player:setGodMod(true)
			player:setUnlimitedCarry(true)
			player:setNoClip(true)
			player:setInvisible(true)

			player:getInventory():AddItem("WristWatch_Right_DigitalBlack")
			local walkie = player:getInventory():AddItem("Radio.WalkieTalkie5")

			ISTimedActionQueue.add(ISEquipWeaponAction:new(player, walkie, 20, true, false))
			ISTimedActionQueue.add(ISRadioAction:new("ToggleOnOff",player, walkie))
			ISTimedActionQueue.add(ISRadioAction:new("SetChannel",player, walkie, DynamicRadio.cache[WeatherChannel.channelUUID]:GetFrequency()))
		end
	end
end
if SWWS_Debug.debugLoadout then
	Events.EveryOneMinute.Add(SWWS_Debug.AddDebugLoadout)
end