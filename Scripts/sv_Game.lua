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
	self.worldScriptClass = "CreativeCustomWorld"

	self:InitData()

	if self.sv.saved == nil then
        self.sv.saved = {}
        self.sv.saved.data = self.data
		self:sv_loadWorld({world = { nil, "lobby.world" }})
		table.insert( ls_worlds, self.sv.saved.world )
		self.storage:save( self.sv.saved )
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

function Game.sv_recreatePlayerCharacter( self, world, x, y, player, params )
	local yaw = math.atan2( params.dir.y, params.dir.x ) - math.pi/2
	local pitch = math.asin( params.dir.z )
	local newCharacter = sm.character.createCharacter( player, self.sv.saved.world, params.pos, yaw, pitch )
	player:setCharacter( newCharacter )
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