-- Crafter.lua --

dofile "$SURVIVAL_DATA/Scripts/game/survival_items.lua"
dofile "$SURVIVAL_DATA/Scripts/game/survival_survivalobjects.lua"
dofile "$SURVIVAL_DATA/Scripts/game/util/pipes.lua"

Workbench = class( nil )

local crafters = {
	-- Workbench
	["e9f97012-bede-4ae7-8e35-1b2005542dbf"] = {
		needsPower = false,
		slots = 1,
		speed = 1
	}
}

function Workbench.server_onCreate( self )
	self:sv_init()
end

function Workbench.server_onRefresh( self )
	self.crafter = nil
	self.network:setClientData( { craftArray = {}, pipeGraphs = {} })
	self:sv_init()
end

function Workbench.server_canErase( self )
	return #self.sv.craftArray == 0
end

function Workbench.client_onCreate( self )
	self:cl_init()
end

function Workbench.client_onDestroy( self )
	for _,effect in ipairs( self.cl.mainEffects ) do
		effect:destroy()
	end

	for _,effect in ipairs( self.cl.secondaryEffects ) do
		effect:destroy()
	end

	for _,effect in ipairs( self.cl.tertiaryEffects ) do
		effect:destroy()
	end

	for _,effect in ipairs( self.cl.quaternaryEffects ) do
		effect:destroy()
	end
end

function Workbench.client_onRefresh( self )
	self.crafter = nil
	self:cl_disableAllAnimations()
	self:cl_init()
end

function Workbench.client_canErase( self )
	if #self.cl.craftArray > 0 then
		sm.gui.displayAlertText( "#{INFO_BUSY}", 1.5 )
		return false
	end
	return true
end

-- Server Init

function Workbench.sv_init( self )
	self.crafter = crafters[tostring( self.shape:getShapeUuid() )]
	self.sv = {}
	self.sv.clientDataDirty = false
	self.sv.storageDataDirty = true
	self.sv.craftArray = {}
	if self.params then print( self.params ) end
end

-- Client Init

function Workbench.cl_init( self )
	local shapeUuid = self.shape:getShapeUuid()
	if self.crafter == nil then
		self.crafter = crafters[tostring( shapeUuid )]
	end
	self.cl = {}
	self.cl.craftArray = {}
	self.cl.uvFrame = 0
	self.cl.animState = nil
	self.cl.animName = nil
	self.cl.animDuration = 1
	self.cl.animTime = 0

	self.cl.currentMainEffect = nil
	self.cl.currentSecondaryEffect = nil
	self.cl.currentTertiaryEffect = nil
	self.cl.currentQuaternaryEffect = nil

	self.cl.mainEffects = {}
	self.cl.secondaryEffects = {}
	self.cl.tertiaryEffects = {}
	self.cl.quaternaryEffects = {}

	-- print( self.crafter.subTitle )
	-- print( "craft_start", self.interactable:getAnimDuration( "craft_start" ) )
	-- if self.interactable:hasAnim( "craft_loop" ) then
	-- 	print( "craft_loop", self.interactable:getAnimDuration( "craft_loop" ) )
	-- else
	-- 	print( "craft_loop01", self.interactable:getAnimDuration( "craft_loop01" ) )
	-- 	print( "craft_loop02", self.interactable:getAnimDuration( "craft_loop02" ) )
	-- 	print( "craft_loop03", self.interactable:getAnimDuration( "craft_loop03" ) )
	-- end
	-- print( "craft_finish", self.interactable:getAnimDuration( "craft_finish" ) )


	if shapeUuid == "e9f97012-bede-4ae7-8e35-1b2005542dbf" then

		self.cl.mainEffects["craft_loop"] = sm.effect.createEffect( "Workbench - Work01", self.interactable )
		self.cl.mainEffects["craft_finish"] = sm.effect.createEffect( "Workbench - Finish", self.interactable )
		self.cl.mainEffects["idle"] = sm.effect.createEffect( "Workbench - Idle", self.interactable )
	end
end

function Workbench.client_onClientDataUpdate( self, data )
	self.cl.craftArray = data.craftArray
	self.cl.pipeGraphs = data.pipeGraphs

	-- Experimental needs testing
	for _, val in ipairs( self.cl.craftArray ) do
		if val.time == -1 and val.startTick then
			local estimate = max( sm.game.getServerTick() - val.startTick, 0 ) -- Estimate how long time has passed since server started crafing and client recieved craft
			val.time = estimate
		end
	end
end

-- Internal util


-- Server

function Workbench.server_onFixedUpdate( self )

end

--Client

local UV_OFFLINE = 0
local UV_READY = 1
local UV_FULL = 2
local UV_HEART = 3
local UV_WORKING_START = 4
local UV_WORKING_COUNT = 4
local UV_JAMMED_START = 8
local UV_JAMMED_COUNT = 4

function Workbench.client_onFixedUpdate( self )

end

function Workbench.client_onUpdate( self, deltaTime )

	local prevAnimState = self.cl.animState

	local craftTimeRemaining = 0

	self.cl.animState = "idle"
	self.interactable:setUvFrameIndex( UV_READY )
	self.cl.animTime = self.cl.animTime + deltaTime
	local animDone = false
	if self.cl.animTime > self.cl.animDuration then
		self.cl.animTime = math.fmod( self.cl.animTime, self.cl.animDuration )

		--print( "ANIMATION DONE:", self.cl.animName )
		animDone = true
	end

	local craftbotParameter = 1

	if self.cl.animState ~= prevAnimState then
		--print( "NEW ANIMATION STATE:", self.cl.animState )
	end

	local prevAnimName = self.cl.animName

	if self.cl.animState == "offline" then
		assert( self.crafter.needsPower )
		self.cl.animName = "offline"

	elseif self.cl.animState == "idle" then
		if self.cl.animName == "offline" or self.cl.animName == nil then
			if self.crafter.needsPower then
				self.cl.animName = "turnon"
			else
				self.cl.animName = "idle"
			end
			animDone = true
		elseif self.cl.animName == "turnon" or self.cl.animName == "unfold" or self.cl.animName == "craft_finish" then
			if animDone then
				self.cl.animName = "idle"
			end
		elseif self.cl.animName == "idle" then
			if animDone then
				local rand = math.random( 1, 5 )
				if rand == 1 then
					self.cl.animName = "idlespecial01"
				elseif rand == 2 then
					self.cl.animName = "idlespecial02"
				else
					self.cl.animName = "idle"
				end
			end
		elseif self.cl.animName == "idlespecial01" or self.cl.animName == "idlespecial02" then
			if animDone then
				self.cl.animName = "idle"
			end
		else
			--assert( self.cl.animName == "craft_finish" )
			if animDone then
				self.cl.animName = "idle"
			end
		end

	elseif self.cl.animState == "craft" then
		if self.cl.animName == "idle" or self.cl.animName == "idlespecial01" or self.cl.animName == "idlespecial02" or self.cl.animName == "turnon" or self.cl.animName == "unfold" or self.cl.animName == nil then
			self.cl.animName = "craft_start"
			animDone = true

		elseif self.cl.animName == "craft_start" then
			if animDone then
				if self.interactable:hasAnim( "craft_loop" ) then
					self.cl.animName = "craft_loop"
				else
					self.cl.animName = "craft_loop01"
				end
			end

		elseif self.cl.animName == "craft_loop" then
			if animDone then
				if craftTimeRemaining <= 2 then
					self.cl.animName = "craft_finish"
				else
					--keep looping
				end
			end

		elseif self.cl.animName == "craft_finish" then
			if animDone then
				self.cl.animName = "craft_start"
			end

		end
	end

	if self.cl.animName ~= prevAnimName then
		--print( "NEW ANIMATION:", self.cl.animName )

		if prevAnimName then
			self.interactable:setAnimEnabled( prevAnimName, false )
			self.interactable:setAnimProgress( prevAnimName, 0 )
		end

		self.cl.animDuration = self.interactable:getAnimDuration( self.cl.animName )
		self.cl.animTime = 0

		--print( "DURATION:", self.cl.animDuration )

		self.interactable:setAnimEnabled( self.cl.animName, true )
	end

	if animDone then

		local mainEffect = self.cl.mainEffects[self.cl.animName]
		local secondaryEffect = self.cl.secondaryEffects[self.cl.animName]
		local tertiaryEffect = self.cl.tertiaryEffects[self.cl.animName]
		local quaternaryEffect = self.cl.quaternaryEffects[self.cl.animName]

		if mainEffect ~= self.cl.currentMainEffect then

			if self.cl.currentMainEffect ~= self.cl.mainEffects["craft_finish"] then
				if self.cl.currentMainEffect then
					self.cl.currentMainEffect:stop()
				end
			end
			self.cl.currentMainEffect = mainEffect
		end

		if secondaryEffect ~= self.cl.currentSecondaryEffect then

			if self.cl.currentSecondaryEffect then
				self.cl.currentSecondaryEffect:stop()
			end

			self.cl.currentSecondaryEffect = secondaryEffect
		end

		if tertiaryEffect ~= self.cl.currentTertiaryEffect then

			if self.cl.currentTertiaryEffect then
				self.cl.currentTertiaryEffect:stop()
			end

			self.cl.currentTertiaryEffect = tertiaryEffect
		end

		if quaternaryEffect ~= self.cl.currentQuaternaryEffect then

			if self.cl.currentQuaternaryEffect then
				self.cl.currentQuaternaryEffect:stop()
			end

			self.cl.currentQuaternaryEffect = quaternaryEffect
		end

		if self.cl.currentMainEffect then
			self.cl.currentMainEffect:setParameter( "craftbot", craftbotParameter )

			if not self.cl.currentMainEffect:isPlaying() then
				self.cl.currentMainEffect:start()
			end
		end

		if self.cl.currentSecondaryEffect then
			self.cl.currentSecondaryEffect:setParameter( "craftbot", craftbotParameter )

			if not self.cl.currentSecondaryEffect:isPlaying() then
				self.cl.currentSecondaryEffect:start()
			end
		end

		if self.cl.currentTertiaryEffect then
			self.cl.currentTertiaryEffect:setParameter( "craftbot", craftbotParameter )

			if not self.cl.currentTertiaryEffect:isPlaying() then
				self.cl.currentTertiaryEffect:start()
			end
		end

		if self.cl.currentQuaternaryEffect then
			self.cl.currentQuaternaryEffect:setParameter( "craftbot", craftbotParameter )

			if not self.cl.currentQuaternaryEffect:isPlaying() then
				self.cl.currentQuaternaryEffect:start()
			end
		end
	end
	assert(self.cl.animName)
	self.interactable:setAnimProgress( self.cl.animName, self.cl.animTime / self.cl.animDuration )
end

function Workbench.cl_disableAllAnimations( self )
	if self.interactable:hasAnim( "turnon" ) then
		self.interactable:setAnimEnabled( "turnon", false )
	else
		self.interactable:setAnimEnabled( "unfold", false )
	end
	self.interactable:setAnimEnabled( "idle", false )
	self.interactable:setAnimEnabled( "idlespecial01", false )
	self.interactable:setAnimEnabled( "idlespecial02", false )
	self.interactable:setAnimEnabled( "craft_start", false )
	if self.interactable:hasAnim( "craft_loop" ) then
		self.interactable:setAnimEnabled( "craft_loop", false )
	else
		self.interactable:setAnimEnabled( "craft_loop01", false )
		self.interactable:setAnimEnabled( "craft_loop02", false )
		self.interactable:setAnimEnabled( "craft_loop03", false )
	end
	self.interactable:setAnimEnabled( "craft_finish", false )
	self.interactable:setAnimEnabled( "aimbend_updown", false )
	self.interactable:setAnimEnabled( "aimbend_leftright", false )
	self.interactable:setAnimEnabled( "offline", false )
end

function Workbench.client_canInteract( self )
	--sm.gui.setCenterIcon( "Use" )
	--local keyBindingText =  sm.gui.getKeyBinding( "Use" )
	--sm.gui.setInteractionText( "", keyBindingText, "#{INTERACTION_USE}" )
	return false
end

function Workbench.client_onInteract( self, character, state )
	if state == true then
		Workbench.playAnim( self, character, state )

	end
end

function Workbench.playAnim( self, character, state )
	local rand = math.random( 1, 9 )
	self.cl.animTime = 0
	if rand == 1 then
		self.cl.animName = "idlespecial01"
	elseif rand == 2 then
		self.cl.animName = "idlespecial02"
	elseif rand == 3 then
		self.cl.animName = "craft_start"
	elseif rand == 4 then
		self.cl.animName = "craft_loop"
		self.cl.animTime = 50
	elseif rand == 5 then
		self.cl.animName = "craft_finish"
	elseif rand == 6 then
		self.cl.animName = "aimbend_updown"
	elseif rand == 7 then
		self.cl.animName = "aimbend_leftright"
	elseif rand == 8 then
		self.cl.animName = "offline"
	else
		self.cl.animName = "idle"
	end
	self.cl.animDuration = self.interactable:getAnimDuration( self.cl.animName )
	self.interactable:setAnimEnabled( self.cl.animName, true )
	self.interactable:setAnimProgress( self.cl.animName,self.cl.animTime / self.cl.animDuration)
end


