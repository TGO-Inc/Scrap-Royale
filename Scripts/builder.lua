dofile "$GAME_DATA/Scripts/game/AnimationUtil.lua"
dofile "$SURVIVAL_DATA/Scripts/util.lua"
dofile "$SURVIVAL_DATA/Scripts/game/survival_shapes.lua"
--Just so you know, there is a bug with ceiling placement and I am looking for a fix.
--r4ndytaylor69 26.06.22
function round(number)
	return math.floor(number)
end

aea = class()
aea.size = 16
aea.rotation = sm.quat.identity()
aea.rotationIndex = 1
aea.mode = 1
function round(x)
  return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end


function aea.client_onCreate( self )
	
end

function aea.client_onRefresh( self )

end

function aea.client_onClientDataUpdate( self, clientData )

end



function aea.client_onUpdate( self, dt )
	
end


aea.sver = function(self, result)
	local tile = sm.vec3.new(self.size,1, self.size)

	print(result)
	result.x = round(result.x*16)/16
	result.y = round(result.y*16)/16
	result.z = round(result.z*16)/16
	print(result)
	if(self.mode == 2) then
		
		tile = sm.vec3.new(self.size, self.size, 1)
	end

	sm.shape.createBlock(blk_concrete1, tile, result, self.rotation, false )
end

function aea.client_onToggle( self )

	
	return true
end


function aea.client_onEquip( self, animate )

end

function aea.client_onUnequip( self )

end


-- Interact
function aea.client_onEquippedUpdate( self, primaryState, secondaryState, forceBuildActive )

	local hit, result = sm.localPlayer.getRaycast(25)
	if(not hit) then return true, false end
	local vec = result.pointWorld
	local rx, ry = 0, 0
	local px, py, pz = sm.localPlayer.getPlayer():getCharacter():getDirection().x, sm.localPlayer.getPlayer():getCharacter():getDirection().y, sm.localPlayer.getPlayer():getCharacter():getDirection().z
	local rot = math.abs(math.ceil( math.deg(math.atan2( py, px )) + 180))
	if (math.abs(pz) >= 0.6 ) then
		self.mode = 2
	else
		self.mode = 1
	end
	sm.gui.setInteractionText( "<p textShadow='false' bg='gui_keybinds_bg_orange' color='#66440C' spacing='9'>"..sm.gui.getKeyBinding("ForceBuild",false).."</p>", "Build slant", "" )

	if (rot < 135 and rot >= 45) then
		self.rotationIndex = 180
		vec.y = vec.y + 0.25
		rx = 45 
	end
	if (rot < 225 and rot >= 135) then
		self.rotationIndex = 90
	
		ry = 45 
	end
	if  (rot < 315 and rot >= 225) then
		self.rotationIndex = 360
		vec.y = vec.y - 0.25
		rx = -45
	end
	if (rot < 360 and rot >= 315) or rot < 45 then
		self.rotationIndex = 270
	
		ry = -45
	end
	--insert visualisation here
	if (not forceBuildActive) then rx, ry = 0, 0 end
	if (primaryState ~= 1) then return true, false end
	self.rotation = sm.quat.fromEuler(sm.vec3.new(rx,ry,self.rotationIndex))
	self.network:sendToServer("sver", vec)
	return true, false

	--[[	Fuck visualisation, fuck it.
		for r6 = 0, self.size-1, 1 do
			for r8 = 0, self.size-1, 1 do
				if(self.rotationIndex == 90) or (self.rotationIndex == 270) then
					sm.visualization.setBlockVisualization( sm.vec3.new(round(vec.x*4), round(vec.y*4+r6), round(vec.z*4+r8)), false, nil)
				else
					sm.visualization.setBlockVisualization( sm.vec3.new(round(vec.x*4-r6), round(vec.y*4), round(vec.z*4+r8)), false, nil)
				end
			end
		end
	]]

	
end
