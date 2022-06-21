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

function CreativeCustomWorld.sve_LoadStorages( self, data )
    if self:checkp(data.self) then
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

function CreativeCustomWorld.EmptyContainer( self , data )
    if self:checkp(data.self) then
        container = data.container
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

function CreativeCustomWorld.LoadAvailableContainers( self, data )
    if self:checkp(data.self) then
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