name = "Dig"
author = "MeltWS"

description = [[Dig Maps]]

local pf = require "ProShinePathfinder/Pathfinder/MoveToApp" -- requesting table with methods
local map = nil

local DigMaps = {
	"Digletts Cave",
	"Route 3",
    "Route 14",
	"Route 15",
	"Mt. Moon 1F",
	"Mt. Moon B2F",
	"Rock Tunnel 1",
	"Rock Tunnel 2",
	"Dark Cave South",
	"Mt. Mortar 1F",
	"Slowpoke Well",
	"Slowpoke Well L1"
}

function onStart()
	dofile "libs/system.lua"
	dofile "config.lua"
	dofile "List-Unevolved-Pokemon.lua"
end

function onResume()
	dofile "libs/system.lua"
	dofile "config.lua"
	dofile "List-Unevolved-Pokemon.lua"
end

function onPathAction()
	if isOutside() and ( hasItem("S Ninetales Mount") or hasItem("Bicycle") or hasItem("Yellow Bicycle") or hasItem("Blue Bicycle") or hasItem("Green Bicycle") ) and not isSurfing() and not isMounted() then
		return useItem("S Ninetales Mount") or useItem("Bicycle") or useItem("Yellow Bicycle") or useItem("Green Bicycle") or useItem("Blue Bicycle")
	end
    map = getMapName()
    if not pf.moveTo(map, DigMaps[1]) then
        table.remove(DigMaps, 1)
        if DigMaps[1] then
            log("Map " .. map .. ", no more dig to do, moving to:" .. tostring(DigMaps[1]))
            pf.moveTo(map, DigMaps[1])
        else fatal("No more maps to dig")
        end
    end
end

function onBattleAction()
    if isWildBattle() and (hasItem("Ultra Ball") or hasItem("Great Ball") or hasItem("Pokeball")) then
		if isOpponentShiny() or isUnevolvedNotAlreadyCaught() then
			return startCatch()
		elseif not isAlreadyCaught() then
			return startCatch()
		else
			for i, valeur in ipairs(to_catch) do
				if getOpponentName() == valeur then
					return startCatch()
				end
			end
		end
	end
	
	return run() or attack() or sendUsablePokemon() or sendAnyPokemon() or relog(3)
end

