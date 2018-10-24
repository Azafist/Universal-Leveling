name = "Universal Exp"
author = "Azafist"

description = [[
This script can "ExpShare", simple leveling, EV training, simple catching anywhere you want !]]
setOptionName(1, "Catch desired Pokemon ")
setOption(1, true)
setOptionName(2, "Catch Uncaught ")
setOptionName(3, "Leveling ")
setOption(3, true)
setOptionName(4, "ExpShare ")
setOptionName(5, "Catch Uncaught Unevolved ")
setOption(5, true)
setOptionName(6, "Fishing ")
setTextOptionName(1, "keepAlive ")
setTextOption(1, 1)
setTextOptionName(2, "MaxLevel ")
setTextOption(2, 101)
setTextOptionName(3, "LevelLocation ")
setTextOption(3, getMapName())
setTextOptionName(4, "minX ")
setTextOption(4, getPlayerX()-2)
setTextOptionName(5, "minY ")
setTextOption(5, getPlayerY()-2)
setTextOptionName(6, "maxX ")
setTextOption(6, getPlayerX()+2)
setTextOptionName(7, "maxY ")
setTextOption(7, getPlayerY()+2)
setOptionName(7, "EV Training ")
setTextOptionName(8, "EV 1") -- HP / ATK / DEF / SPATK / SPDEF / SPD
setTextOptionName(9, "EV 2")
setOptionName(8, "Use Default Option")

function onStart()
	
	-- Load Configurations
	reloadConfig()
	
	trapped = "false"

	log(" ")
	log("=========== WELCOME | START ============")
	log("Welcome to the Universal ExpSharing by imMigno")
	log("Version 2.0.9 | Updated: 09-20-2016 | 11.51 PM")
	log("====================================")
	log(" ")

end

function onPause()
	log("ExpShare | Paused !")
end

function onResume()
	
	reloadConfig()
	
	log("ExpShare | Config successfully reloaded !")
end

function reloadConfig()
	dofile "libs/system.lua"
	dofile "config.lua"
	dofile "List-ToCatch-Pokemon.lua"
	
	if getOption(8) then
		keepAlive = c_keepAlive

		MaxLevel = c_MaxLevel

		LevelLocation = c_LevelLocation
		LevelSpot = c_LevelSpot

		minX = c_minX
		minY = c_minY
		maxX = c_maxX
		maxY = c_maxY
		
		fishing = c_fishing
		ev1 = c_ev1
		ev2 = c_ev2
	else
		keepAlive = tonumber(getTextOption(1))

		MaxLevel = tonumber(getTextOption(2))

		LevelLocation = getTextOption(3)
		LevelSpot = "Rectangle"

		minX = tonumber(getTextOption(4))
		minY = tonumber(getTextOption(5))
		maxX = tonumber(getTextOption(6))
		maxY = tonumber(getTextOption(7))
		
		fishing = getOption(6)
		ev1 = getTextOption(8)
		ev2 = getTextOption(9)
	end
	osTime = os.clock()
end

function onPathAction()
	if getOption(4) and not getOption(7) then
		startTraining()
	else
		startWalkingToCatch()
	end
end

function onBattleAction()
	if isWildBattle() and (hasItem("Ultra Ball") or hasItem("Great Ball") or hasItem("Pokeball")) then
		if isOpponentShiny() or (isUnevolvedNotAlreadyCaught() and getOption(5)) then
			return startCatch()
		elseif getOption(1) then
			for i, valeur in ipairs(to_catch) do
				if getOpponentName() == valeur then
					return startCatch()
				end
			end
		elseif getOption(2) and not isAlreadyCaught() then
			startCatch()
		end
	end
	if getOption(7) then
		if getOption(4) then
			startEvTrainingShare()
		else
			if testEV() then
				startSimpleLeveling()
			else
				return run() or sendUsablePokemon() or sendAnyPokemon() or relog(3)
			end
		end
	elseif getOption(3) then
		if getOption(4) then
			return startExpShare()
		else
			return startSimpleLeveling()
		end
	else
		if trapped == "true" then
			return attack()
		else
			return run() or attack() or sendUsablePokemon() or sendAnyPokemon()
		end
	end
end

function onBattleMessage(wild)
	if stringContains(wild, "wrapped") or stringContains(wild, "You can not switch this Pokemon!") or stringContains(wild, "You failed to run away!") or stringContains(wild, "You can not run away!")  then
		log("ExpShare | Trapped triggered - Activating Anti-Trap")
		trapped = "true"
	end		
end