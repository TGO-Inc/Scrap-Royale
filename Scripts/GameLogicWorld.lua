dofile("$CONTENT_DATA/Scripts/GameConstants.lua")

HANDLE_INITIALIZED = false

function CreativeCustomWorld.SetGameHandle( self, handle )
    if not sm.isServerMode() then return end
    if (handle.self ~= nil) and (self.SafeHandle == nil) and (self.GameHandle == nil) then
        self.SafeHandle = sm.uuid.new()
        sm.event.sendToGame( "SetWorldHandle", { safe = handle.self, self = self.SafeHandle } )
    elseif (self.SafeHandle == handle.safe) and (self.SafeHandle ~= nil) and (handle.self ~= nil) then
        self.GameHandle = handle.self
        HANDLE_INITIALIZED = true
    end
end

function CreativeCustomWorld.checkp(self, handle)
    return ((self.SafeHandle == handle) and (self.SafeHandle ~= nil) and (sm.isServerMode())) or not HANDLE_INITIALIZED
end

function CreativeCustomWorld.sve_LoadStorages( self, ref )
    if self:checkp(ref.self) then
        StorageLootList = {}
        for p,o in pairs(self:LoadAvailableContainers({self=self.SafeHandle})) do
            container = o:getContainer(0)
            self:EmptyContainer({self=self.SafeHandle, container=container})
            ContainerContents = {}
            for i = size-Random(1, math.min(5, size)), size do
                itemTable = pickRandomItem(o:getShape():getShapeUuid())
                uuid = itemTable._uuid
                if uuid == nil then uuid = itemTable[1] end
                ContainerContents[size-i] = { uuid = uuid, count = Random(1, itemTable.maxstack) }
            end
            StorageLootList[container.id] = ContainerContents
        end
        sm.event.sendToGame( "sve_setStorageList", { self = self.GameHandle, data=StorageLootList } )
    elseif(self.SafeHandle == nil) then 
        print("ServerUUID Not Initialized")
    else 
        print("No Permission")
    end
end

function CreativeCustomWorld.EmptyContainer( self , ref )
    if self:checkp(ref.self) then
        container = ref.container
        size = container:getSize()
        for i = 1, size do
            if container:isEmpty() then break end
            item = container:getItem(i)
            sm.container.beginTransaction()
            sm.container.spend(container, item.uuid, item.quantity, true)
            sm.container.endTransaction()
        end
    end
end

function CreativeCustomWorld.LoadAvailableContainers( self, ref )
    if self:checkp(ref.self) then
        storageArray = {}
        for k,v in pairs(sm.body.getAllBodies()) do 
            for l,m in pairs(v:getInteractables()) do 
                uuid = m:getShape():getShapeUuid()
                if ArrayContainsValue(ApprovedRefillContainers, uuid) then
                    table.insert(storageArray, m)
                end
            end
        end
        return storageArray
    end
end

local s_start = sm.quat.new(0.707,0,0,0.707)

function CreativeCustomWorld.sv_UpdateStormLoc( self, ref )
    if self:checkp(ref.self) then
        if(self.stormEffectData == nil) then
            self.stormEffectData = {}
        end
        self.stormEffectData.start_radius = ref.start_radius
        self.stormEffectData.radius =ref.start_radius
        self.stormEffectData.end_radius = ref.end_radius
        self.stormEffectData.start_pos = ref.start_pos
        self.stormEffectData.position =ref.start_radius
        self.stormEffectData.end_pos = ref.end_pos
        self.stormEffectData.startTime = ref.time
        self.stormEffectData.time = ref.time
        self.stormEffectData.damangecycle = true
        ref.self = nil
        self.network:sendToClients("cl_UpdateStormLoc", ref)
    end
end

function CreativeCustomWorld.cl_UpdateStormLoc( self, ref )
    if self:checkp(ref.self) then
        if self.stormEffect == nil then
            self.stormEffect = sm.effect.createEffect("ShapeRenderable")
            self.stormEffectData = {}
        end

        self.stormEffect:setParameter("uuid", sm.uuid.new( "72de823d-2273-45ed-bb80-3dae7ee8ef2f" ))
        self.stormEffect:setParameter("color", sm.color.new( 1,1,1,1 ))

        self.stormEffect:setScale( sm.vec3.new( ref.start_radius, 256, ref.start_radius ))
        self.stormEffectData.start_radius = ref.start_radius
        self.stormEffectData.end_radius = ref.end_radius

        self.stormEffect:setPosition(ref.start_pos)
        self.stormEffectData.start_pos = ref.start_pos
        self.stormEffectData.end_pos = ref.end_pos

        self.stormEffect:setRotation(s_start)
        self.stormEffectData.rotation = { quat = s_start, vec = sm.vec3.new(90, -90, 0) }

        self.stormEffectData.startTime = ref.time
        self.stormEffectData.time = ref.time

        self.stormEffectData.cycle = true

        self.stormSpeed = 0.03

        if not self.stormEffect:isPlaying() then
            self.stormEffect:start()
        end
    end
end

local function rotateQuat( data, amt )
    deg = data.vec
    deg.y = deg.y - amt
    if (deg.y < -90) then
        deg.y = 90
    end
    returnQuat = sm.quat.fromEuler( deg )
    return returnQuat
end

local intermissionTimer = 2 * 40

function CreativeCustomWorld.UpdateStormPos( self, ref )
    if(self.stormEffect ~= nil) and self.stormEffectData.damangecycle  then
        if self.stormEffectData.time > 1 then 
            self.stormEffectData.time = self.stormEffectData.time - 1
            local percent = math.abs(((self.stormEffectData.startTime - self.stormEffectData.time) / self.stormEffectData.startTime) - 1)
            local scale = (self.stormEffectData.start_radius - self.stormEffectData.end_radius) * percent
            self.stormEffectData.radius = self.stormEffectData.end_radius + scale * 2
            if self.stormEffectData.radius < 0.5 then
                self.stormEffectData.radius = 0
                self.stormEffectData.damangecycle = false
            end
            self.stormEffectData.position = self.stormEffectData.end_pos + ((self.stormEffectData.start_pos - self.stormEffectData.end_pos) * percent)
            if (self.stormEffectData.time == 1) then
                print("Finished Storm Cycle")
            end
        elseif intermissionTimer > 0 then
            intermissionTimer = intermissionTimer - 1
        elseif intermissionTimer == 0 then
            intermissionTimer = 2 * 40
            sm.event.sendToGame( "sv_NewStormPos", { self = self.GameHandle } )
        end
    end
end

function CreativeCustomWorld.UpdateStormVisuals( self, ref )
    if(self.stormEffect ~= nil) and self.stormEffectData.cycle  then
        self.stormEffectData.rotation.quat = rotateQuat( self.stormEffectData.rotation, self.stormSpeed )
        self.stormEffect:setRotation(self.stormEffectData.rotation.quat)
        if self.stormEffectData.time > 1 then
            if self.stormSpeed < 5 then
                self.stormSpeed = self.stormSpeed + 0.02
            end
            if self.stormEffectData.end_radius < 1 and self.stormEffectData.end_radius > 0 then 
                self.stormEffectData.end_radius = 0
            end
            self.stormEffectData.rotation.quat = rotateQuat( self.stormEffectData.rotation, self.stormSpeed )
            self.stormEffect:setRotation(self.stormEffectData.rotation.quat)
            self.stormEffectData.time = self.stormEffectData.time - 1
            local percent = math.abs(((self.stormEffectData.startTime - self.stormEffectData.time) / self.stormEffectData.startTime) - 1)
            local scale = (self.stormEffectData.start_radius - self.stormEffectData.end_radius) * percent
            if not self.stormEffect:isPlaying() then
                self.stormEffect:start()
            end
            local scaleXY = sm.vec3.new(self.stormEffectData.end_radius + scale, self.stormEffectData.end_radius + scale, 0) * 2
            self.stormEffect:setScale( sm.vec3.new( scaleXY.x, 256, scaleXY.y ))
            local diff = self.stormEffectData.end_pos + ((self.stormEffectData.start_pos - self.stormEffectData.end_pos) * percent)
            self.stormEffect:setPosition(diff)
            if (self.stormEffectData.end_radius + scale) * 2 < 0.05 then
                scale = 0
                self.stormEffectData.end_radius = 0
                self.stormEffectData.cycle = false
                self.stormEffect:stop()
                self.stormEffect:destroy()
                self.stormEffect = nil
            end
        else
            if self.stormSpeed > 0.03 then
                self.stormSpeed = self.stormSpeed - 0.02
            end
            if self.stormSpeed < 0.03 then
                self.stormSpeed = 0.03
            end
        end
    end
end