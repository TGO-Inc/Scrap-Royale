dofile( "$GAME_DATA/Scripts/game/BasePlayer.lua" )
dofile( "$CONTENT_DATA/Scripts/survival_constants.lua" )
dofile( "$CONTENT_DATA/Scripts/util/Timer.lua" )
dofile( "$CONTENT_DATA/Scripts/survival_items.lua" )
dofile( "$SURVIVAL_DATA/Scripts/util.lua" )

Player = class( nil )
dofile("$CONTENT_DATA/Scripts/cl_Player.lua")

function Player.server_onCreate( self )
	print("Player.server_onCreate")
end

function Player.server_onRefresh( self )
	
end

function Player.server_onFixedUpdate( self, timeStep )

end

function Player.server_onShapeRemoved( self, removedShapes )
	local numParts = 0
	local numBlocks = 0
	local numJoints = 0

	for _, removedShapeType in ipairs( removedShapes ) do
		if removedShapeType.type == "block"  then
			numBlocks = numBlocks + removedShapeType.amount
		elseif removedShapeType.type == "part"  then
			numParts = numParts + removedShapeType.amount
		elseif removedShapeType.type == "joint"  then
			numJoints = numJoints + removedShapeType.amount
		end
	end

	local staminaSpend = numParts + numJoints + math.sqrt( numBlocks )
	--self:sv_e_staminaSpend( staminaSpend )
end
