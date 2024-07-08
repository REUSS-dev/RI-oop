-- World
local World = {}

local dest = require("classes.Destination")
local drone = require("classes.Drone")

-- documentation

---@alias ObjectID number

-- config



-- consts

---@enum WorldObjectType
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

---@class World
---@field drones Drone[]
---@field worldObjects Destination[]
local world = {}
local World_meta = {__index = world}

function world:placeBase(x, y)
    local base = dest.new(x, y, World.WorldObjectType.BASE)
    table.insert(self.worldObjects, base)

    return #self.worldObjects
end

function world:placeResource(x, y)
    local res = dest.new(x, y, World.WorldObjectType.RESOURCE)
    table.insert(self.worldObjects, res)

    return #self.worldObjects
end

function world:removeObject(id)
    table.remove(self.worldObjects, id)
end

function world:repopulate()
    self.drones = {}

    for i = 1, self.dronesCount do
        self.drones[i] = drone.new(
            math.random(0, self.width),
            math.random(0, self.height)
        )
    end
end

function world:tick(dt)
    for i = 1, self.dronesCount do
        local currentDrone = self.drones[i]
        local x, y, angle = currentDrone:getDirectionals()

        currentDrone:incrementCounters()

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

        for v = i + 1, self.dronesCount do
            local otherDrone = self.drones[v]

            currentDrone:tryScream(otherDrone)
        end
        
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

        currentDrone:tick(dt)
    end
end

function world:paint()
    love.graphics.rectangle("line", 0, 0, self.width, self.height)

    for _, object in ipairs(self.worldObjects) do
        object:draw()
    end

    for _, droneToDraw in ipairs(self.drones) do
        droneToDraw:draw()
    end
end

-- World fnc

---Create new World object
---@param width number
---@param height number
---@param droneAmount number
---@return World
function World.new(width, height, droneAmount, placePoints)

    ---@class World
    local obj = {
        width = width,
        height = height,
        dronesCount = droneAmount,
        drones = {},
        worldObjects = {}
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