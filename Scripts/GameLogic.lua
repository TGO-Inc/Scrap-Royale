
function Game.InitHandles( self )
    if not sm.isServerMode() then return end
    if self.SafeHandle == nil and self.WorldHandle == nil then
        self.SafeHandle = sm.uuid.new()
        sm.event.sendToWorld(self.sv.saved.world, "SetGameHandle", { self = self.SafeHandle });
    end
end

function Game.SetWorldHandle( self, handle )
    if not sm.isServerMode() then return end
    if self.SafeHandle == handle.safe and self.SafeHandle ~= nil then
        self.WorldHandle = handle.self
        sm.event.sendToWorld(self.sv.saved.world, "SetGameHandle", { safe = handle.self, self = self.SafeHandle });
    end
end

function Game.checkp(self, handle)
    return ((self.SafeHandle == handle) and (self.SafeHandle ~= nil) and (sm.isServerMode())) or not HANDLE_INITIALIZED
end

function Game.InitData( self )
    self.sv.stormCounter = 0
    self.sv.stormSize = 0
    self.sv.stormCenter = { x = 0, y = 0 }
end

function Game.MainGameLogic( self, ref )
    --if self:checkp(ref.self) then
        -- Get all chests and stuff in world
        -- Generate all loot (dont fill chests until players open chest)
        self:InitData()
        self.sv.stormSize = math.pow(self.sv.worldSize*4, 2) * 3
        sm.event.sendToWorld(self.sv.saved.world, "sve_LoadStorages", { self = self.WorldHandle })
    --end
end

function Game.MainGameLogic2 ( self )
    --if self:checkp(ref.self) then
    -- Generate storm center and preceeding locations
    self:sv_NewStormPos({ self = self.SafeHandle })
    -- sm.event.sendToWorld(self.sv.saved.world, "sve_LoadWorldSize", { self = self.WorldHandle, callback="Game.SetWorldSize" })
    -- choose battle bus path
    -- battle bus
    -- randomize seat locations for players
    -- start storm formation timer for 1 min and move bus over landscape (30 seconds)

    -- 10 min game
    -- form storm and start 5 min timer
    -- storm move 4 min
    -- storm move 3 min
    -- storm move 2 min
    -- storm move 1 min
    -- end
end

function Game.sv_loadWorld( self, data )
	worldName = data.world[2]
	if not (string.find(worldName, ".world") or string.find(worldName, ".blueprint")) then
		worldName = worldName..".world"
	end

	if self.sv.saved.world ~= nil then
		print("Deleting world")
		self.sv.saved.world:destroy()
		self.sv.saved.world = nil
		self.storage:save( self.sv.saved )
	end

	fName = "$CONTENT_DATA/Terrain/worlds/"..worldName
	jWorld = sm.json.open( fName )
	self.sv.worldSize = math.pow(#jWorld.cellData/4, 0.5)

	self.sv.saved.world = sm.world.createWorld( self.worldScriptFilename, self.worldScriptClass, { worldFile = fName }, 0 )
	self:InitHandles()

	if not sm.exists( self.sv.saved.world ) then
		sm.world.loadWorld( self.sv.saved.world )
	end

	self.storage:save( self.sv.saved )

	if data.player ~= nil then
		local character = data.player:getCharacter()
		local params = { pos = character:getWorldPosition(), dir = character:getDirection() }
		self.sv.saved.world:loadCell( 0, 0, data.player, "sv_recreatePlayerCharacter", params )
	end
end

function Game.sve_setStorageList( self, ref )
    if self:checkp(ref.self) then 
        print(ref.data)
        self:MainGameLogic2()
    end
    --[[
        sm.container.beginTransaction()
        container:setItem(slot, uuid, count)
        sm.container.endTransaction()
    ]]
end

local function a2b2c2f( a, b )
    local c = math.pow(a, 2) + math.pow(b, 2)
    return math.floor(math.pow(c, 0.5))
end

local pcent = {
    max = { 0.90, 0.75, 0.70, 0.65, 0.6, 0.5 },
    min = { 0.85, 0.60, 0.50, 0.45, 0.3, 0.25 } 
}

function Game.getPcentMin( self )
    local ksf = pcent.min[self.sv.stormCounter]
    if ksf == nil then
        return pcent.min[#pcent.min]
    end
    return ksf
end

function Game.getPcentMax( self )
    local ksf = pcent.max[self.sv.stormCounter]
    if ksf == nil then
        return pcent.max[#pcent.max]
    end
    return ksf
end

function Game.sv_NewStormPos( self, ref )
    if self:checkp(ref.self) then
        print("Generating New Storm")
        local size = self.sv.stormSize / 2
        local coordSize = math.floor(size * 0.30)
        local x = math.random(-coordSize, coordSize)
        local y = math.random(-coordSize, coordSize)
        local coords = { x = x, y = y }
        local radiusMax = size - a2b2c2f(x, y)
        self.sv.stormCounter = self.sv.stormCounter + 1
        local estimatedRadius = math.floor(
            math.random(
                size * self:getPcentMin(),
                size * self:getPcentMax()
        ))
        local radius = math.min(math.floor(radiusMax * 0.95), estimatedRadius)
        self.sv.stormSize = radius * 2
        sm.event.sendToWorld(self.sv.saved.world, "sv_UpdateStormLoc", 
        { 
            self = self.WorldHandle,
            start_pos = sm.vec3.new(self.sv.stormCenter.x, self.sv.stormCenter.y, 75),
            end_pos = sm.vec3.new(coords.x + self.sv.stormCenter.x, coords.y + self.sv.stormCenter.y, 75),
            start_radius = size,
            end_radius = radius,
            time = 2 * 3 * 40
        })
        self.sv.stormCenter.x = coords.x + self.sv.stormCenter.x
        self.sv.stormCenter.y = coords.y + self.sv.stormCenter.y
    end
end