dofile( "$GAME_DATA/Scripts/game/managers/CreativePathNodeManager.lua")
dofile( "$GAME_DATA/Scripts/game/worlds/CreativeBaseWorld.lua")
dofile( "$SURVIVAL_DATA/Scripts/game/managers/WaterManager.lua" )

CreativeCustomWorld = class( CreativeBaseWorld )
print("========= Init World File =========")
CreativeCustomWorld.terrainScript = "$CONTENT_DATA/Scripts/terrain/terrain_custom.lua"
CreativeCustomWorld.enableSurface = true
CreativeCustomWorld.enableAssets = true
CreativeCustomWorld.enableClutter = true
CreativeCustomWorld.enableNodes = true
CreativeCustomWorld.enableCreations = true
CreativeCustomWorld.enableHarvestables = true
CreativeCustomWorld.enableKinematics = true

CreativeCustomWorld.cellMinX = -128
CreativeCustomWorld.cellMaxX = 127
CreativeCustomWorld.cellMinY = -128
CreativeCustomWorld.cellMaxY = 127

dofile( "$CONTENT_DATA/Scripts/GameLogicWorld.lua" )

function CreativeCustomWorld.server_onCreate( self )
	print("server_onCreate")

	CreativeBaseWorld.server_onCreate( self )

	self.waterManager = WaterManager()
	self.waterManager:sv_onCreate( self )

	self.sv = {}
	self.sv.pathNodeManager = CreativePathNodeManager()
	self.sv.pathNodeManager:sv_onCreate( self )
end

function CreativeCustomWorld.client_onCreate( self )
	CreativeBaseWorld.client_onCreate( self )
	if self.waterManager == nil then
		assert( not sm.isHost )
		self.waterManager = WaterManager()
	end
	self.waterManager:cl_onCreate()
end

function CreativeCustomWorld.server_onFixedUpdate( self )
	CreativeBaseWorld.server_onFixedUpdate( self )
	self.waterManager:sv_onFixedUpdate()
	self:UpdateStormPos()
end

function CreativeCustomWorld.client_onFixedUpdate( self )
	self.waterManager:cl_onFixedUpdate()
	self:UpdateStormVisuals()
end

function CreativeCustomWorld.client_onUpdate( self )
	g_effectManager:cl_onWorldUpdate( self )
end

function CreativeCustomWorld.server_onCellCreated( self, x, y )
	self.waterManager:sv_onCellLoaded( x, y )
	self.sv.pathNodeManager:sv_loadPathNodesOnCell( x, y )
end

function CreativeCustomWorld.client_onCellLoaded( self, x, y )
	self.waterManager:cl_onCellLoaded( x, y )
	g_effectManager:cl_onWorldCellLoaded( self, x, y )
end

function CreativeCustomWorld.server_onCellLoaded( self, x, y )
	self.waterManager:sv_onCellReloaded( x, y )
end

function CreativeCustomWorld.server_onCellUnloaded( self, x, y )
	self.waterManager:sv_onCellUnloaded( x, y )
end

function CreativeCustomWorld.client_onCellUnloaded( self, x, y )
	self.waterManager:cl_onCellUnloaded( x, y )
	g_effectManager:cl_onWorldCellUnloaded( self, x, y )
end
--[[
function CreativeCustomWorld.sv_e_spawnNewCharacter( self, params )
	local spawnRayBegin = sm.vec3.new( params.x, params.y, 1024 )
	local spawnRayEnd = sm.vec3.new( params.x, params.y, -1024 )
	local valid, result = sm.physics.spherecast( spawnRayBegin, spawnRayEnd, 0.3 )
	local pos
	if valid then
		pos = result.pointWorld + sm.vec3.new( 0, 0, 0.4 )
	else
		pos = sm.vec3.new( params.x, params.y, 100 )
	end

	local character = sm.character.createCharacter( params.player, self.world, pos )
	params.player:setCharacter( character )
end
]]