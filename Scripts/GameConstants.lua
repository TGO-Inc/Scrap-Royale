--- Constants

function ArrayContainsValue(array, item)
    for k,v in pairs(array) do
        if v == item then return true end
    end
    return false
end

function ArrayContainsKey(array, item)
    for k,v in pairs(array) do
        if k == item then return true end
    end
    return false
end

function pickRandomItem(container_uuid)
    weightedArray = {}
    for k,v in pairs(ApprovedContainerItems[tostring(container_uuid)]) do
        weight = v.weight
        for i = 1, weight do
            table.insert(weightedArray, v)
        end
    end
    weightedArray = ShuffleList(weightedArray)
    num = math.random(1, #weightedArray)
    randomItem = weightedArray[num]
    return randomItem
end

function Random(lowwer, upper)
    samples = {}
    for i = 0, 100 do
        samples[i] = math.max(lowwer, math.min(upper, math.random(lowwer, upper)  * math.random(1,2)))
    end
    random = samples[math.random(1,100)]
    return random
end

function ShuffleList(x)
    shuffled = {}
    
    itemL = {}
    for i = 1, #x+1 do
        itemL[i] = i
    end
    
    for i, v in ipairs(x) do
        local pos = Random(1, #x)
        while itemL[pos] == nil do pos = Random(1, #x) end
        table.insert(shuffled, i, x[pos])
        itemL[pos] = nil
    end

    return shuffled
end

ApprovedRefillContainers = { 
    sm.uuid.new("fcfae5e2-1df9-47d8-bb9a-30bec9b5b1f5"),
    sm.uuid.new("79cc711e-7094-4029-8419-bbbf8f08c6f2"),
    sm.uuid.new("ad35f7e6-af8f-40fa-aef4-77d827ac8a8a"),
    sm.uuid.new("f08d772f-9851-400f-a014-d847900458a7"),
    sm.uuid.new("d0afb527-e786-4a22-a907-6da7e7cba8cb"),
    sm.uuid.new("90dbaebf-8ea1-4a5a-8f6f-86ddde77c6c8")
}

StandardLootList = {
    --[[obj_consumable_gas]] { maxstack = 20, weight = 5, _uuid = sm.uuid.new( "d4d68946-aa03-4b8f-b1af-96b81ad4e305" ) }, 
    --[[obj_consumable_battery]] { maxstack = 10, weight = 5, _uuid = sm.uuid.new( "910a7f2c-52b0-46eb-8873-ad13255539af" ) },  
    --[[obj_consumable_sunshake]] { maxstack = 5, weight = 7, _uuid = sm.uuid.new( "cb7305b2-d8b5-4302-aff3-6cdd9212ca64" ) }, 
    --[[obj_consumable_pizzaburger]] { maxstack = 1, weight = 2, _uuid = sm.uuid.new( "54d84731-d9ec-435d-bc9d-d48e0763b1bf" ) }, 
    --[[obj_consumable_longsandwich]] { maxstack = 1, weight = 1, sm.uuid.new( "e243f642-6934-42bb-8cdd-f8ff1704d411" ) }, 
    --[[obj_consumable_milk]] { maxstack = 5, weight = 3, _uuid = sm.uuid.new( "2c4a2633-153a-4800-ba3d-2ac0d993b9c8" ) },
    --[[obj_consumable_water]] { maxstack = 10, weight = 5, _uuid = sm.uuid.new( "869d4736-289a-4952-96cd-8a40117a2d28" ) },
    --[[obj_consumable_chemical]] { maxstack = 8, weight = 6, _uuid = sm.uuid.new( "f74c2891-79a9-45e0-982e-4896651c2e25" ) },
    --[[obj_consumable_inkammo]] { maxstack = 15, weight = 6, _uuid = sm.uuid.new( "c7322cd1-3158-41d9-b15a-eff2f2f8d9f7" ) },
    --[[obj_consumable_glowstick]] { maxstack = 15, weight = 5, _uuid = sm.uuid.new( "3a3280e4-03b6-4a4d-9e02-e348478213c9" ) },
    --[[obj_plantables_banana]] { maxstack = 5, weight = 7, _uuid = sm.uuid.new( "aa4c9c5e-7fc6-4c27-967f-c550e551c872" ) },
    --[[obj_plantables_blueberry]] { maxstack = 5, weight = 7, _uuid = sm.uuid.new( "6a43fff2-8c6d-4460-9f44-e5483b5267dd" ) },
    --[[obj_plantables_orange]] { maxstack = 5, weight = 7, _uuid = sm.uuid.new( "f5098301-1693-457b-8efc-83b3504105ac" ) },
    --[[obj_plantables_pineapple]] { maxstack = 5, weight = 7, _uuid = sm.uuid.new( "4ec64cda-1a5b-4465-88b4-5ea452c4a556" ) },
    --[[obj_plantables_carrot]] { maxstack = 5, weight = 7, _uuid = sm.uuid.new( "47ece75a-bfca-4e8a-b618-4f609fcea0da" ) },
    --[[obj_plantables_redbeet]] { maxstack = 5, weight = 7, _uuid = sm.uuid.new( "4ce00048-f735-4fab-b978-5f405e60f48f" ) },
    --[[obj_plantables_tomato]] { maxstack = 5, weight = 7, _uuid = sm.uuid.new( "6d92d8e7-25e9-4698-b83d-a64dc97978c8" ) },
    --[[obj_plantables_broccoli]] { maxstack = 5, weight = 7, _uuid = sm.uuid.new( "b5cdd503-fe1c-482b-86ab-6a5d2cc4fc8f" ) },
    --[[obj_plantables_potato]] { maxstack = 25, weight = 20, _uuid = sm.uuid.new( "bfcfac34-db0f-42d6-bd0c-74a7a5c95e82" ) },
    --[[tool_spudgun]] { maxstack = 1, weight = 3, _uuid = sm.uuid.new( "c5ea0c2f-185b-48d6-b4df-45c386a575cc" ) },
    --[[tool_shotgun]] { maxstack = 1, weight = 3, _uuid = sm.uuid.new( "f6250bf4-9726-406f-a29a-945c06e460e5" ) },
    --[[tool_gatling]] { maxstack = 1, weight = 3, _uuid = sm.uuid.new( "9fde0601-c2ba-4c70-8d5c-2a7a9fdd122b" ) },
    --[[tool_connect]] --{ maxstack = 1, weight = 3, _uuid = sm.uuid.new( "8c7efc37-cd7c-4262-976e-39585f8527bf" ) },
    --[[tool_paint]] { maxstack = 1, weight = 3, _uuid = sm.uuid.new( "c60b9627-fc2b-4319-97c5-05921cb976c6" ) },
    --[[tool_weld]] --{ maxstack = 1, weight = 3, _uuid = sm.uuid.new( "fdb8b8be-96e7-4de0-85c7-d2f42e4f33ce" ) }
}

ApprovedContainerItems = { }
ApprovedContainerItems["fcfae5e2-1df9-47d8-bb9a-30bec9b5b1f5"] = StandardLootList
ApprovedContainerItems["79cc711e-7094-4029-8419-bbbf8f08c6f2"] = StandardLootList
ApprovedContainerItems["ad35f7e6-af8f-40fa-aef4-77d827ac8a8a"] = StandardLootList
ApprovedContainerItems["f08d772f-9851-400f-a014-d847900458a7"] = StandardLootList -- fridge
ApprovedContainerItems["d0afb527-e786-4a22-a907-6da7e7cba8cb"] = StandardLootList
ApprovedContainerItems["90dbaebf-8ea1-4a5a-8f6f-86ddde77c6c8"] = StandardLootList