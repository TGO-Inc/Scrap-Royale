function Player.client_onCreate( self )
	print("Player.client_onCreate")
end

function Player.client_onUpdate( self, dt )
	if sm.localPlayer ~= nil then
		if sm.localPlayer.getPlayer():getCharacter() ~= nil then
			--print(sm.localPlayer.getPlayer():getCharacter():getWorldPosition())
		end
	end
end