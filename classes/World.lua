-- World
local World = {}

local drone = require("classes.Drone")

-- documentation



-- config



-- consts



-- vars



-- init



-- fnc



-- classes

---@class World
---@field drones Drone[]
local world = {}
local World_meta = {__index = world}

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
        local x, y, angle = currentDrone:getDroneDirectionals()
        
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
function World.new(width, height, droneAmount)

    ---@class World
    local obj = {
        width = width,
        height = height,
        dronesCount = droneAmount,
        drones = {}
    }

    setmetatable(obj, World_meta)

    obj:repopulate()
    
    return obj
end

return World