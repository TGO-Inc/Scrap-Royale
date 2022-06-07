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
        counter = 0
        for i = size-math.random(1, math.min(1, size)), size do
            counter = counter + 1
            sm.container.beginTransaction()
            itemTable = pickRandomItem(o:getShape():getShapeUuid())
            uuid = itemTable._uuid
            if uuid == nil then uuid = itemTable[1] end
            count = math.random(1, itemTable.maxstack)
            --print(tostring(uuid).." : "..count)
            container:setItem(size-i, uuid, count)
            sm.container.endTransaction()
        end
        --print(counter)
    end
end