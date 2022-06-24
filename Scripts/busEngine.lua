battleBusEngine = class( nil )
battleBusEngine.creations = {}

function battleBusEngine.server_onCreate( self )
    print("engine on create")
	self.start=self.shape:getBody():getWorldPosition()
    print(self.start)

	self.shapes = {}
	self.e = false
	self.gravwork = 0
end

function battleBusEngine.server_onFixedUpdate( self, dt )
    self.firstTick = self.firstTick or sm.game.getServerTick()
    local targetParts = 2
    if targetParts ~= 0 and sm.game.getServerTick() > self.firstTick+200 then-- only run twice just in case
        for i,body in pairs(self.shape:getBody():getCreationBodies()) do 
            for i,shape in pairs(body:getShapes()) do
                if shape:getShapeUuid() == sm.uuid.new("915214c5-f4fa-4d7e-93c8-3737e4a6a4dc") then--get the ship shape
                    self.shipShape=shape
                end
                if shape:getShapeUuid() == sm.uuid.new("09ca2713-28ee-4119-9622-e85490034758") then-- remove block for updateing ship
                    print('part')
                    print(shape)
                    if sm.item.isBlock( shape.uuid ) then
                        shape:destroyShape( 0 )
                    elseif sm.item.isPart( shape.uuid ) then
                        shape:destroyPart( 0 )
                    end
                    targetParts=targetParts-1
                end
            end
        end
    end

    if self.shipShape then--ship ready

        if not self.tpd then-- only run once
            -- self.shipShape:setColor(sm.color.new( math.random(0,225), math.random(0,225), math.random(0,225) )) 

            sm.event.sendToGame("sv_teleportPlayers",{self="N-WORD",data={ship=self.shipShape}})
            self.tpd=true
        end

        sm.physics.applyImpulse(self.shape:getBody(), sm.vec3.new(-1,0,0)*20000,true)
        if self.shape:getBody():getWorldPosition().x < -self.start.x then
            for i,body in pairs(self.shape:getBody():getCreationBodies()) do
                for i,shape in pairs(body:getShapes()) do
                    if sm.item.isBlock( shape.uuid ) then
                        shape:destroyShape( 0 )
                    elseif sm.item.isPart( shape.uuid ) then
                        shape:destroyPart( 0 )
                    end
                end
            end
        end
    end



    

    --code from modpack gravity module
    --free code
	local worldgravity = sm.physics.getGravity()

    local gravity = sm.vec3.new(0,0,(worldgravity*(1.047494)) *dt)
    local id = self.shape:getBody():getCreationBodies()[1].id
    if battleBusEngine.creations[id] == nil or os.clock() - battleBusEngine.creations[id] > 0.01 then
        for k, body in pairs(self.shape:getBody():getCreationBodies()) do
            local drag = sm.vec3.new(0,0,0)
            if self.shapes and self.shapes[k] then
                if (self.shapes[k] - body.worldPosition):length() < 0.0025 then
                    drag = (self.shapes[k] - body.worldPosition)*2
                else
                    drag = (self.shapes[k] - body.worldPosition)/2
                end
                drag.x = 0
                drag.y = 0
            end 
            sm.physics.applyImpulse(body, (gravity + drag)* body.mass, true)
            self.shapes[k] = body.worldPosition
        end
        battleBusEngine.creations[id] = os.clock()
    end

end
