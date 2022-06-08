dofile("$CONTENT_DATA/Scripts/GameConstants.lua")

function CreativeCustomWorld.sve_LoadStorages(self)
    storageArray = {}
    for k,v in pairs(sm.body.getAllBodies()) do 
        for l,m in pairs(v:getInteractables()) do 
            uuid = m:getShape():getShapeUuid()
            if ArrayContainsValue(ApprovedRefillContainers, uuid) then
                table.insert(storageArray, m)
            end
        end
    end

    for p,o in pairs(storageArray) do
        container = o:getContainer(0)
        size = container:getSize()

        for i = 1, size do
            if container:isEmpty() then break end
            item = container:getItem(i)
            sm.container.beginTransaction()
            sm.container.spend(container, item.uuid, item.quantity, true)
            sm.container.endTransaction()
        end

        for i = size-Random(1, math.min(5, size)), size do
            sm.container.beginTransaction()
            itemTable = pickRandomItem(o:getShape():getShapeUuid())
            uuid = itemTable._uuid
            if uuid == nil then uuid = itemTable[1] end
            container:setItem(size-i, uuid, Random(1, itemTable.maxstack))
            sm.container.endTransaction()
        end
    end
end