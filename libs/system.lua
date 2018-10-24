local PathFinder = require "ProShinePathfinder/Pathfinder/MoveToApp"

function getLevelSpot()
	if LevelSpot == "Grass" then
		moveToGrass()
	elseif LevelSpot == "Water" then
		if isSurfing() and fishing and fishing_count() and (hasItem("Super Rod") or hasItem("Good Rod") or hasItem("Old Rod")) then
			log("-- Fishing --")
			return useItem("Super Rod") or useItem("Good Rod") or useItem("Old Rod") or moveToWater()
		else
			moveToWater()
		end
	elseif LevelSpot == "Rectangle" then
		if isSurfing() and fishing and fishing_count() and (hasItem("Super Rod") or hasItem("Good Rod") or hasItem("Old Rod")) then
			log("-- Fishing --")
			return useItem("Super Rod") or useItem("Good Rod") or useItem("Old Rod") or moveToRectangle(minX, minY, maxX, maxY)
		else
			moveToRectangle(minX, minY, maxX, maxY)
		end
	else
		fatal("ExpShare | Error on LevelSpot configuration !")
	end
end

function fishing_count()
	f_count = os.clock() - osTime
	if f_count <= 3 then
		osTime = os.clock()
		return false
	else
		osTime = os.clock()
		return true
	end
end

function onLearningMove(moveName, pokemonIndex)
    local ForgetMoveName
    local ForgetMoveTP = 9999
    for moveId=1, 4, 1 do
        local MoveName = getPokemonMoveName(pokemonIndex, moveId)
        if MoveName == nil or MoveName == "cut" or MoveName == "surf" or MoveName == "rock smash" or MoveName == "rocksmash" then
        else
        local CalcMoveTP = math.modf((getPokemonMaxPowerPoints(pokemonIndex,moveId) * getPokemonMovePower(pokemonIndex,moveId))*(math.abs(getPokemonMoveAccuracy(pokemonIndex,moveId)) / 100))
            if CalcMoveTP < ForgetMoveTP then
                ForgetMoveTP = CalcMoveTP
                ForgetMoveName = MoveName
            end
        end
    end
    log("==== Learning new Move ====")
    log(" ")
    log("[Learned] ".. moveName)
    log("[Forgot ] ".. ForgetMoveName)
    log(" ")
    log("===========================")
    return ForgetMoveName
end

function advanceSorting()
	local pokemonsUsable = getUsablePokemonCount()
	for pokemonId=1, pokemonsUsable, 1 do
		if not isPokemonUsable(pokemonId) then --Move it at bottom of the Team
			for pokemonId_ = pokemonsUsable + 1, getTeamSize(), 1 do
				if isPokemonUsable(pokemonId_) then
					swapPokemon(pokemonId, pokemonId_)
					return true
				end
			end
			
		end
	end
	if not isTeamRangeSortedByLevelAscending(1, pokemonsUsable) then --Sort the team without not usable pokemons
		return sortTeamRangeByLevelAscending(1, pokemonsUsable)
	end
	return false
end

function isLevelLocation()
	if getMapName() == LevelLocation then
		return true
	else
		return false
	end
end

function startTraining()
	if trapped == "true" then
		trapped = "false"
		log("ExpShare | AntiTrap deactivated")
	end
	if isOutside() and ( hasItem("S Ninetales Mount") or hasItem("Bicycle") or hasItem("Yellow Bicycle") or hasItem("Blue Bicycle") or hasItem("Green Bicycle") ) and not isSurfing() and not isMounted() then
		return useItem("S Ninetales Mount") or useItem("Bicycle") or useItem("Yellow Bicycle") or useItem("Green Bicycle") or useItem("Blue Bicycle")
	end
	if advanceSorting() then
		return true
	elseif getTeamSize() >= 2 then
		if getUsablePokemonCount() > keepAlive then
			if isPokemonUsable(1) then
				if getPokemonLevel(1) < MaxLevel then
					if not isLevelLocation() then
						PathFinder.moveTo(LevelLocation)
					else
						getLevelSpot()
					end
				else
					fatal("ExpShare | MaxLevel reached -> Training finished !")
					logout()
				end
			else
				fatal("ExpShare | ERRORCODE: P001")
			end
		else
			PathFinder.useNearestPokecenter()
		end
	else
		fatal("ExpShare | You need atleast 2 Pokemon on your Team")
	end
end

function startWalkingToCatch()
	if trapped == "true" then
		trapped = "false"
		log("ExpShare | AntiTrap deactivated")
	end
	if isOutside() and ( hasItem("S Ninetales Mount") or hasItem("Bicycle") or hasItem("Yellow Bicycle") or hasItem("Blue Bicycle") or hasItem("Green Bicycle") ) and not isSurfing() and not isMounted() then
		return useItem("S Ninetales Mount") or useItem("Bicycle") or useItem("Yellow Bicycle") or useItem("Green Bicycle") or useItem("Blue Bicycle")
	end
	if getUsablePokemonCount() > keepAlive then
		if isPokemonUsable(1) then
			if not isLevelLocation() then
				PathFinder.moveTo(LevelLocation)
			else
				getLevelSpot()
			end
		else
			PathFinder.useNearestPokecenter()
		end
	else
		PathFinder.useNearestPokecenter()
	end
end

function startExpShare()
	if isLevelLocation() then
		if getActivePokemonNumber() == 1 and not needPokecenter() and isFightable() then
			if trapped == "true" then
				return attack() or sendUsablePokemon() or sendAnyPokemon()
			else
				return attack() or sendUsablePokemon() or sendAnyPokemon() or run()
			end
		elseif getActivePokemonNumber() == 1 and not needPokecenter() and not isFightable() then
			if trapped == "true" then
				return attack() or sendUsablePokemon() or sendAnyPokemon()
			else
				if sendPokemon(getUsablePokemonCount()) then
					log("ExpShare | "..getPokemonName(1).." has been switched with "..getPokemonName(getUsablePokemonCount()))
				else
					return sendUsablePokemon() or sendAnyPokemon()
				end
			end
		elseif getActivePokemonNumber() == getUsablePokemonCount() and isFightable() and not needPokecenter() then
			return attack() or sendUsablePokemon() or sendAnyPokemon() or run()
		elseif getActivePokemonNumber() ~= getUsablePokemonCount() then
			if isFightable() then
				return attack() or sendUsablePokemon() or sendAnyPokemon() or run()
			else
				if trapped == "true" then
					return attack() or sendUsablePokemon() or sendAnyPokemon()
				else
					if sendPokemon(getUsablePokemonCount()) then
						log("ExpShare | "..getPokemonName(1).." has been switched with "..getPokemonName(getUsablePokemonCount()))
					else
						return sendUsablePokemon() or sendAnyPokemon()
					end
				end
			end
		elseif needPokecenter() then
			if trapped == "true" then
				return attack() or sendUsablePokemon() or sendAnyPokemon()
			else
				return run() or sendUsablePokemon() or sendAnyPokemon() or attack()
			end
		else
			return attack() or sendUsablePokemon() or sendAnyPokemon() or run()
			-- fatal("ExpShare | ERRORCODE: B001")
		end
	else
		if isFightable() then
			if trapped == "true" then
				return attack()
			else
				return run() or attack() or sendUsablePokemon() or sendAnyPokemon()
			end
		else
			if sendPokemon(getUsablePokemonCount()) then
				log("ExpShare | "..getPokemonName(1).." has been switched with "..getPokemonName(getUsablePokemonCount()))
			else
				return sendUsablePokemon() or sendAnyPokemon()
			end
		end
	end
end

function startEvTrainingShare()
	if testEV() then
		if getActivePokemonNumber() == 1 then
			return sendUsablePokemon() or sendAnyPokemon() or attack() or run()
		elseif (not getActivePokemonNumber() == 1) and isFightable() then
			return attack() or sendUsablePokemon() or sendAnyPokemon() or run()
		elseif not isPokemonUsable(1) then
			if trapped == "true" then
				return attack() or sendUsablePokemon() or sendAnyPokemon()
			else
				return run() or sendUsablePokemon() or sendAnyPokemon() or attack()
			end
		else
			return attack() or sendUsablePokemon() or sendAnyPokemon() or run()
			-- fatal("ExpShare | ERRORCODE: B001")
		end
	else
		if isFightable() then
			return run() or sendUsablePokemon() or sendAnyPokemon() or relog(3)
		else
			return sendUsablePokemon() or sendAnyPokemon() or run() or relog(3)
		end
	end
end

function testEV()
	if ev2 == "" then 
		if isOpponentEffortValue(ev1) then
			return true
		else
			return false
		end
	elseif isOpponentEffortValue(ev1) or isOpponentEffortValue(ev2) then
		return true
	else
		return false
	end
end

function startSimpleLeveling()
	if isLevelLocation() then
		if not needPokecenter() and isFightable() then
			if trapped == "true" then
				return attack() or sendUsablePokemon() or sendAnyPokemon()
			else
				return attack() or sendUsablePokemon() or sendAnyPokemon() or run()
			end
		elseif trapped == "true" then
			return attack()
		else
			return run() or attack() or sendUsablePokemon() or sendAnyPokemon()
		end
	else
		if trapped == "true" then
			return attack()
		else
			return run() or attack() or sendUsablePokemon() or sendAnyPokemon()
		end
	end
end

function startCatch()
	if not getOpponentStatus() == "Sleep" and getOpponentName() == "Abra"  then
		return useMove("Sleep Powder") or useItem("Ultra Ball") or useItem("Great Ball") or useItem("Pokeball") or attack() or sendUsablePokemon() or sendAnyPokemon() or run()
	elseif getOpponentStatus() == "Sleep" and getOpponentName() == "Abra"  then
		return useItem("Ultra Ball") or useItem("Great Ball") or useItem("Pokeball") or attack() or sendUsablePokemon() or sendAnyPokemon() or run()
	elseif (getOpponentHealth() > 1) and not (getOpponentType()[1] == "Ghost" or getOpponentType()[2] == "Ghost") then
		return useMove("False Swipe") or useItem("Ultra Ball") or useItem("Great Ball") or useItem("Pokeball") or attack() or sendUsablePokemon() or sendAnyPokemon() or run()
	elseif (not getOpponentStatus() == "Sleep") and not (getOpponentType()[1] == "Grass" or getOpponentType()[2] == "Grass") then
		return useMove("Sleep Powder") or useItem("Ultra Ball") or useItem("Great Ball") or useItem("Pokeball") or attack() or sendUsablePokemon() or sendAnyPokemon() or run()
	else
		return useItem("Ultra Ball") or useItem("Great Ball") or useItem("Pokeball") or attack() or sendUsablePokemon() or sendAnyPokemon() or run()
	end
end

function isFightable()
	if getPokemonLevel(getActivePokemonNumber()) >= (getOpponentLevel() + 10 ) then
		return true
	else
		return false
	end
end

function needPokecenter()
	if getUsablePokemonCount() <= keepAlive then
		return true
	else
		return false
	end
end
