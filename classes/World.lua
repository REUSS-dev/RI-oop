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

---Remove object from a world by its ObjectID
---@param id ObjectID ID of an object to remove
function world:removeObject(id)
    table.remove(self.worldObjects, id)
end

---Repopulate world with drones
function world:repopulate()
    self.drones = {}

    for i = 1, self.dronesCount do
        self.drones[i] = drone.new(
            math.random(0, self.width),
            math.random(0, self.height)
        )
    end
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
        for _, worldObject in ipairs(self.worldObjects) do
            if worldObject.controller:checkCollision(currentDrone.controller) then
                local objectType = worldObject:getType()

                currentDrone:resetCounter(objectType)

                if objectType == World.WorldObjectType.BASE and currentDrone:isCurrentDestination(World.WorldObjectType.BASE) then
                    currentDrone:setDestination(World.WorldObjectType.RESOURCE)
                    currentDrone:setFill(false)
                    currentDrone:turnTowards(worldObject)
                    currentDrone.controller:reverseAngle()
                elseif objectType == World.WorldObjectType.RESOURCE and currentDrone:isCurrentDestination(World.WorldObjectType.RESOURCE) then
                    currentDrone:setDestination(World.WorldObjectType.BASE)
                    currentDrone:setFill(true)
                    currentDrone:turnTowards(worldObject)
                    currentDrone.controller:reverseAngle()
                end
            end
        end

        -- Exchange info with other drones around
        for v = i + 1, self.dronesCount do
            local otherDrone = self.drones[v]

            local counter = currentDrone:tryScream(otherDrone)
            if counter then
                self:newConnection(i, v, counter)
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
    for _, worldObject in pairs(self.worldObjects) do
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
    love.graphics.rectangle("line", 0, 0, self.width, self.height)

    for i = 1, #self.connections do
        local con = self.connections[i]
        local color = dest.getTypeColor(con[3])
        love.graphics.setColor(color[1], color[2], color[3], con[4]/CONNECTION_TIME*0.5)
        love.graphics.line(self.drones[con[1]].controller.collider.x, self.drones[con[1]].controller.collider.y, self.drones[con[2]].controller.collider.x, self.drones[con[2]].controller.collider.y)
    end

    for _, droneToDraw in ipairs(self.drones) do
        droneToDraw:draw()
    end

    for _, object in ipairs(self.worldObjects) do
        object:draw()
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
        connections = {}
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