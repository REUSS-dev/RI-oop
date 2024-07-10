-- World
local World = {}

local dest = require("classes.Destination")
local drone = require("classes.Drone")

-- documentation

---@alias ObjectID number ID of an object inside a world
---@alias Connection table Structure for connections between the drones

-- config

local CONNECTION_TIME = 0.1

-- consts

---@enum WorldObjectType Types of world's objects
World.WorldObjectType = {
    BASE = 1,
    RESOURCE = 2
}

-- vars



-- init

dest.registerType(World.WorldObjectType.BASE, {0, 1, 1})
dest.registerType(World.WorldObjectType.RESOURCE, {1, 1, 0})

drone.setCountersCount(2)

-- fnc



-- classes

---World class
---@class World
---@field drones Drone[]
---@field worldObjects Destination[]
local world = {}
local World_meta = {__index = world}

---Returns if screams are enabled in the world object or newCount
---@return boolean Screams **true**, if screams are enabled, **false** if screams are disabled
function world:isScreamEnabled()
    return self.screamsEnabled
end

---Issue new connection event between drones
---@param drone1 number Sending drone ID
---@param drone2 number Receiving drone ID
---@param exchangedCounterId DestinationTypeIndex Counter exchanged during connection
function world:newConnection(drone1, drone2, exchangedCounterId)
    local newConnection = {drone1, drone2, exchangedCounterId, CONNECTION_TIME}

    self.connections[#self.connections+1] = newConnection
end

---Place Base in a world.
---@param x pixels X coordinate of a Base to place
---@param y pixels Y coordinate of a Base to place
---@return ObjectID ID New Base's acquired world object ID 
function world:placeBase(x, y)
    local base = dest.new(x, y, World.WorldObjectType.BASE)
    table.insert(self.worldObjects, base)

    return #self.worldObjects
end

---Place Resource in a world.
---@param x pixels X coordinate of a Resource to place
---@param y pixels Y coordinate of a Resource to place
---@return ObjectID ID New Resource's acquired world object ID 
function world:placeResource(x, y)
    local res = dest.new(x, y, World.WorldObjectType.RESOURCE)
    table.insert(self.worldObjects, res)

    return #self.worldObjects
end

---Remove last placed base
function world:removeBase()
    for i = #self.worldObjects, 1, -1 do
        if self.worldObjects[i] then
            if self.worldObjects[i].type == World.WorldObjectType.BASE then
                self.worldObjects[i] = nil
                return
            end
        end
    end
end

---Remove last placed resource
function world:removeResource()
    for i = #self.worldObjects, 1, -1 do
        if self.worldObjects[i] then
            if self.worldObjects[i].type == World.WorldObjectType.RESOURCE then
                self.worldObjects[i] = nil
                return
            end
        end
    end
end

---Remove object from a world by its ObjectID
---@param id ObjectID ID of an object to remove
function world:removeObject(id)
    table.remove(self.worldObjects, id)
end

---Repopulate world with drones
function world:repopulate()
    self.drones = {}
    self.connections = {}

    for i = 1, self.dronesCount do
        self.drones[i] = drone.new(
            math.random(0, self.width),
            math.random(0, self.height)
        )
    end
end

---Set the destination speed multiplier for the world object
---@param mult number A number to multiply the destination speed by
function world:setDestinationSpeedMultiplier(mult)
    for _, destination in pairs(self.worldObjects) do

        destination.controller:setVelocity(destination.baseVelocity * mult)
    end
end

---Set the new drone count. Creates or deletes drones if necessary.
---@param newCount number
function world:setDroneCount(newCount)
    if newCount < self.dronesCount then
        for i = newCount + 1, self.dronesCount do
            self.drones[i] = nil
        end

        for i = #self.connections, 1, -1 do
            local connection = self.connections[i]

            if (connection[1] > newCount) or (connection[2] > newCount) then
                table.remove(self.connections, i)
            end
        end

        self.dronesCount = newCount

        print("set new count", newCount)
    elseif newCount > self.dronesCount then
        for i = self.dronesCount + 1, newCount do
            self.drones[i] = drone.new(
                math.random(0, self.width),
                math.random(0, self.height)
            )
        end

        self.dronesCount = newCount
    end
end

---Set the drone speed multiplier for the world object
---@param mult number A number to multiply the drone speed by
function world:setDroneSpeedMultiplier(mult)
    for i = 1, self.dronesCount do
        local drone = self.drones[i]

        drone.controller:setVelocity(drone.baseVelocity * mult)
    end
end

---Sets if screams are enabled in the world object
---@param bool boolean **true**, if screams are enabled, **false** if disabled
function world:setScreamEnabled(bool)
    self.screamsEnabled = bool
end

---Sets if connections between drones should be drawn on paint
---@param bool boolean **true**, if connections are to be drawn, **false** if connections should not be drawn
function world:setShowConnections(bool)
    self.showConnections = bool
    self.connections = {}
end

---Sets if drones should be drawn on paint
---@param bool boolean **true**, if drones are to be drawn, **false** if drones should not be drawn
function world:setShowDrones(bool)
    self.showDrones = bool
end

---Sets if world objects should be drawn on paint
---@param bool boolean **true**, if objects are to be drawn, **false** if objects should not be drawn
function world:setShowObjects(bool)
    self.showObjects = bool
end

---Sets if radius of drone scream should be drawn on paint
---@param bool boolean **true**, if readiuses are to be drawn, **false** if radiuses should not be drawn
function world:setShowRadius(bool)
    self.showRadius = bool
end

---Update a world
---@param dt number Delta time to update world object
function world:tick(dt)
    -- Update drones
    for i = 1, self.dronesCount do
        local currentDrone = self.drones[i]
        local x, y, angle = currentDrone:getDirectionals()

        -- Increment drone's set of counters
        currentDrone:incrementCounters()

        -- Check drone's collision with world objects
        for _, worldObject in pairs(self.worldObjects) do
            if worldObject.controller:checkCollision(currentDrone.controller) then
                local objectType = worldObject:getType()

                currentDrone:resetCounter(objectType)

                if objectType == World.WorldObjectType.BASE and currentDrone:isCurentDestination(World.WorldObjectType.BASE) then
                    currentDrone:setDestination(World.WorldObjectType.RESOURCE)
                    currentDrone:setFill(false)
                    currentDrone:turnTowards(worldObject)
                    currentDrone.controller:reverseAngle()
                elseif objectType == World.WorldObjectType.RESOURCE and currentDrone:isCurentDestination(World.WorldObjectType.RESOURCE) then
                    currentDrone:setDestination(World.WorldObjectType.BASE)
                    currentDrone:setFill(true)
                    currentDrone:turnTowards(worldObject)
                    currentDrone.controller:reverseAngle()
                end
            end
        end

        -- Exchange info with other drones around
        if self.screamsEnabled then
            for v = i + 1, self.dronesCount, 2 do
                local otherDrone = self.drones[v]

                if not otherDrone then print("missing", v) end

                local counter, distance = currentDrone:tryScream(otherDrone)
                if counter and self.showConnections and (distance > 5) then
                    self:newConnection(i, v, counter)
                end
            end
        end
        
        -- Bounce drone of walls
        if x < 0 then
            if math.cos(angle) < 0 then
                currentDrone.controller:reflectAngleHorizontal()
            end
        elseif x > self.width then
            if math.cos(angle) > 0 then
                currentDrone.controller:reflectAngleHorizontal()
            end
        end
        if y < 0 then
            if math.sin(angle) < 0 then
                currentDrone.controller:reflectAngleVertical()
            end
        elseif y > self.height then
            if math.sin(angle) > 0 then
                currentDrone.controller:reflectAngleVertical()
            end
        end

        -- Tick drone movement
        currentDrone:tick(dt)
    end

    -- Update objects
    for i, worldObject in pairs(self.worldObjects) do

        for u, slaveObject in pairs(self.worldObjects) do
            if i ~= u then
                if slaveObject.controller:checkCollision(worldObject.controller) then
                    
                    if slaveObject.type ~= worldObject.type then
                        worldObject:turnTowards(slaveObject)
                        worldObject.controller:reverseAngle()

                        slaveObject:turnTowards(worldObject)
                        slaveObject.controller:reverseAngle()
                    end
                end
            end
        end

        worldObject:tick(dt)

        local x, y, angle = worldObject:getDirectionals()

        if x - dest.getDestinationPointRadius() < 0 then
            if math.cos(angle) < 0 then
                worldObject.controller:reflectAngleHorizontal()
            end
        elseif x + dest.getDestinationPointRadius() > self.width then
            if math.cos(angle) > 0 then
                worldObject.controller:reflectAngleHorizontal()
            end
        end
        if y - dest.getDestinationPointRadius() < 0 then
            if math.sin(angle) < 0 then
                worldObject.controller:reflectAngleVertical()
            end
        elseif y + dest.getDestinationPointRadius() > self.height then
            if math.sin(angle) > 0 then
                worldObject.controller:reflectAngleVertical()
            end
        end
    end

    -- Update connections
    for i = #self.connections, 1, -1 do
        self.connections[i][4] = self.connections[i][4] - dt
        if self.connections[i][4] <= 0 then
            table.remove(self.connections, i)
        end
    end
end

---Draw a world
function world:paint()
    for i = 1, #self.connections do
        local con = self.connections[i]
        local color = dest.getTypeColor(con[3])
        love.graphics.setColor(color[1], color[2], color[3], con[4]/CONNECTION_TIME*0.5)
        love.graphics.line(self.drones[con[1]].controller.collider.x, self.drones[con[1]].controller.collider.y, self.drones[con[2]].controller.collider.x, self.drones[con[2]].controller.collider.y)
    end

    if self.showDrones then
        for i, droneToDraw in ipairs(self.drones) do
            droneToDraw:draw()
            if self.showRadius then
                if i <= 25 then
                    love.graphics.circle("line", droneToDraw.controller.collider.x, droneToDraw.controller.collider.y, drone.getScreamRadius())
                end
            end
        end
    end

    if self.showObjects then
        for _, object in pairs(self.worldObjects) do
            object:draw()
        end
    end
end

-- World fnc

---Create new World object
---@param width pixels Starting width of the new movement controller
---@param height pixels Starting height of the new movement controller
---@param droneAmount number Starting amount of drones for the new movement controller
---@return World Object
function World.new(width, height, droneAmount, placePoints)

    ---@class World
    local obj = {
        width = width,
        height = height,
        dronesCount = droneAmount,
        drones = {},
        worldObjects = {},
        connections = {},

        screamsEnabled = true,
        showConnections = true,
        showDrones = true,
        showObjects = true,
        showRadius = false,
    }

    setmetatable(obj, World_meta)

    obj:repopulate()

    if placePoints then
        obj:placeBase(
            math.random(dest.getDestinationPointRadius(), obj.width - dest.getDestinationPointRadius()),
            math.random(dest.getDestinationPointRadius(), obj.height - dest.getDestinationPointRadius())
        )

        obj:placeResource(
            math.random(dest.getDestinationPointRadius(), obj.width - dest.getDestinationPointRadius()),
            math.random(dest.getDestinationPointRadius(), obj.height - dest.getDestinationPointRadius())
        )
    end

    return obj
end

return World