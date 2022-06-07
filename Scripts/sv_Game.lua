dofile( "$SURVIVAL_DATA/Scripts/game/managers/EffectManager.lua" )
dofile( "$SURVIVAL_DATA/Scripts/game/managers/UnitManager.lua" )
dofile( "$SURVIVAL_DATA/Scripts/game/util/recipes.lua" )
dofile( "$SURVIVAL_DATA/Scripts/game/survival_projectiles.lua" )
dofile( "$SURVIVAL_DATA/Scripts/game/survival_meleeattacks.lua" )


Game = class( nil )
dofile("$CONTENT_DATA/Scripts/cl_Game.lua")
dofile("$CONTENT_DATA/Scripts/GameLogic.lua")

ls_worlds = {}

function Game.server_onCreate( self )
	print("Game.server_onCreate")

    g_unitManager = UnitManager()
	g_unitManager:sv_onCreate( nil, { aggroCreations = true } )

    self.sv = {}
	self.sv.saved = self.storage:load()

	self.worldScriptFilename = "$CONTENT_DATA/Scripts/worlds/CreativeCustomWorld.lua";
    self.worldScriptClass = "CreativeCustomWorld";

	if self.sv.saved == nil then
        self.sv.saved = {}
        self.sv.saved.data = self.data
        self.sv.saved.world = sm.world.createWorld( self.worldScriptFilename, self.worldScriptClass, { worldFile = "$CONTENT_DATA/Terrain/worlds/lobby.world" }, 0 )
        table.insert( ls_worlds, self.sv.saved.world )
		self.storage:save( self.sv.saved )
	end

    if not sm.exists( self.sv.saved.world ) then
		sm.world.loadWorld( self.sv.saved.world )
	end

	local time = sm.storage.load( STORAGE_CHANNEL_TIME )
	if time then
		print( "Loaded timeData:" )
		print( time )
	else
		time = {}
		time.timeOfDay = 0.5
		sm.storage.save( STORAGE_CHANNEL_TIME, time )
	end

	self.network:setClientData( { time = time.timeOfDay } )

end

function Game.sv_loadWorld(self, data)
	local character = data.player:getCharacter()
	
	worldName = data.world[2]
	if not (string.find(".world", worldName) or string.find(".blueprint", worldName)) then
		worldName = worldName..".world"
	end

	self.sv.saved.world:destroy()
	self.sv.saved.world = sm.world.createWorld( self.worldScriptFilename, self.worldScriptClass, { worldFile = "$CONTENT_DATA/Terrain/worlds/"..worldName }, 0 )
	self.storage:save( self.sv.saved )
	
	local params = { pos = character:getWorldPosition(), dir = character:getDirection() }
	self.sv.saved.world:loadCell( math.floor( params.pos.x/64 ), math.floor( params.pos.y/64 ), data.player, "sv_recreatePlayerCharacter", params )
end

function Game.sv_recreatePlayerCharacter( self, world, x, y, player, params )
	local yaw = math.atan2( params.dir.y, params.dir.x ) - math.pi/2
	local pitch = math.asin( params.dir.z )
	local newCharacter = sm.character.createCharacter( player, self.sv.saved.world, params.pos, yaw, pitch )
	player:setCharacter( newCharacter )
	print( "Recreate character in new world" )
	print( params )
end

function Game.server_onFixedUpdate( self, timeStep )
	g_unitManager:sv_onFixedUpdate()
end

function Game.server_onPlayerJoined( self, player, newPlayer )
	if newPlayer then
		self.sv.saved.world:loadCell( 0, 0, player, "sv_createNewPlayer" )
	else
		g_unitManager:sv_onPlayerJoined( player )
	end

end

function Game.server_onPlayerLeft( self, player )
	print( player.name, "left the game" )
end

function Game.sv_createNewPlayer( self, world, x, y, player )
	local params = { player = player, x = x, y = y }
	sm.event.sendToWorld( self.sv.saved.world, "sv_e_spawnNewCharacter", params )
end

function Game.sv_exportCreation( self, params )
	local obj = sm.json.parseJsonString( sm.creation.exportToString( params.body ) )
	sm.json.save( obj, "$SURVIVAL_DATA/LocalBlueprints/"..params.name..".blueprint" )
end

function Game.sv_importCreation( self, params )
	sm.creation.importFromFile( params.world, "$SURVIVAL_DATA/LocalBlueprints/"..params.name..".blueprint", params.position )
end