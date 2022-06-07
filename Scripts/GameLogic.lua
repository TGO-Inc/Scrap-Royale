function Game.MainGameLogic(self)
    -- Get all chests and stuff in world
    sm.event.sendToWorld(self.sv.saved.world, "sve_LoadStorages");
    -- Generate all loot (dont fill chests until players open chest)
    -- Generate storm center and preceeding locations
    -- choose battle bus path
    -- randomize seat locations for players
    -- start storm formation timer for 1 min and move bus over landscape (30 seconds)

    -- 10 min game
    -- form storm and start 5 min timer
    -- storm move 4 min
    -- storm move 3 min
    -- storm move 2 min
    -- storm move 1 min
end