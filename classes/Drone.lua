-- Drone
local Drone = {}

local body = require("classes.Body")
local controller = require("classes.MovementController")

-- documentation



-- config

local DRONE_BODY_TYPE = body.BodyType.CIRCULAR

local DRONE_RADIUS = 1
local DRONE_COLOR = {1, 1, 1}

local DRONE_VELOCITY_BASE = 300
local DRONE_VELOCITY_VARIANCE = 100

local DRONE_ANGLE_DEVIANCE = 0.1

-- consts

local DRONE_VELOCITY_MINIMUM = DRONE_VELOCITY_BASE - DRONE_VELOCITY_VARIANCE
local DRONE_VELOCITY_MAXIMUM = DRONE_VELOCITY_BASE + DRONE_VELOCITY_VARIANCE

-- vars



-- init



-- fnc



-- classes

---@class Drone
local drone = {}
local Drone_meta = {__index = drone}

function drone:tick(dt)
    local curve = (math.random(0, 200) - 100)/100 * DRONE_ANGLE_DEVIANCE
    self.controller:turn(curve)

    self.controller:tick(dt)
end

function drone:draw()
    self.body:paint(self.controller:getCoordinates())
end

-- Drone fnc

---Create new Drone object
---@param x number
---@param y number
---@param angle radians?
---@param velocity number?
---@param resource boolean?
function Drone.new(x, y, angle, velocity, resource)
    local resourceValue
    if resource == nil then
        resourceValue = math.random(0, 1) == 0
    end
    
    ---@class Drone
    local obj = {
        res = resourceValue
    }

    
    obj.body = body.new(DRONE_BODY_TYPE, DRONE_RADIUS, DRONE_COLOR) --[[@as BodyCircular]]
    obj.controller = controller.new(x, y, obj.body--[[@as Body]], velocity or math.random(DRONE_VELOCITY_MINIMUM, DRONE_VELOCITY_MAXIMUM), angle or math.rad(math.random(1, 360)))
    
    obj.body:setFill(obj.res)

    setmetatable(obj, Drone_meta)

    return obj
end

return Drone