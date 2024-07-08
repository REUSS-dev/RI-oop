-- Drone
local Drone = {}

local body = require("classes.Body")
local controller = require("classes.MovementController")

-- documentation



-- config

local DRONE_BODY_TYPE = body.BodyType.CIRCULAR

local DRONE_RADIUS = 1
local DRONE_COLOR = {1, 1, 1}

local DRONE_VELOCITY_BASE = 300/2
local DRONE_VELOCITY_VARIANCE = 100/2

local DRONE_ANGLE_DEVIANCE = 0.1

local DRONE_COUNTER_INCREMENT = 10
local DRONE_COUNTER_GENERATION_MINIMUM = 100
local DRONE_COUNTER_GENERATION_MAXIMUM = 1000

local DRONE_SCREAM_RADIUS = 30

-- consts

local DRONE_VELOCITY_MINIMUM = DRONE_VELOCITY_BASE - DRONE_VELOCITY_VARIANCE
local DRONE_VELOCITY_MAXIMUM = DRONE_VELOCITY_BASE + DRONE_VELOCITY_VARIANCE

-- vars

local countersCount = 0

-- init



-- fnc

local function setCountersCount(counters)
    countersCount = counters
end

-- classes

---@class Drone
---@field counters table<DestinationTypeIndex, number>
local drone = {}
local Drone_meta = {__index = drone}

function drone:incrementCounters()
    for i = 1, countersCount do
        self.counters[i] = self.counters[i] + DRONE_COUNTER_INCREMENT
    end
end

function drone:isCurrentDestination(testDestinationId)
    return testDestinationId == self.currentDestinationId
end

function drone:getAngle()
    return self.controller.angle
end

function drone:getDirectionals()
    return self.controller.collider.x, self.controller.collider.y, self.controller.angle
end

function drone:resetCounter(counterIndex)
    self.counters[counterIndex] = 0
end

function drone:tick(dt)
    local curve = (math.random(0, 200) - 100)/100 * DRONE_ANGLE_DEVIANCE
    self.controller:turn(curve)

    self.controller:tick(dt)
end

---Turn towards another drone
---@param slaveDrone Drone|Destination
function drone:turnTowards(slaveDrone)
    local arccos = math.acos(
        (slaveDrone.controller.collider.x - self.controller.collider.x)
        /
        (
            math.abs(self.controller.collider.x - slaveDrone.controller.collider.x)
            +
            math.abs(self.controller.collider.y - slaveDrone.controller.collider.y)
            +
            0.000000001 -- prevent division by zero
        )
    )
    local angleTowards = arccos *
        (
            self.controller.collider.y <= slaveDrone.controller.collider.y and arccos < 0 and -1
            or
            self.controller.collider.y > slaveDrone.controller.collider.y and arccos > 0 and -1
            or
            1
        )

    self.controller.angle = angleTowards
end

---Sets drone's new destionation
---@param newDestinationId DestinationTypeIndex
function drone:setDestination(newDestinationId)
    self.currentDestinationId = newDestinationId
end

---Sets if drone's body should be filled
---@param toFill boolean
function drone:setFill(toFill)
    self.body:setFill(toFill)
end

function drone:tryScream(slaveDrone)
    if self.controller:getDistanceTo(slaveDrone.controller) > DRONE_SCREAM_RADIUS then
        return false
    end

    for i = 1, countersCount do
        if self.counters[i] > slaveDrone.counters[i] + DRONE_SCREAM_RADIUS then
            self.counters[i] = slaveDrone.counters[i] + DRONE_SCREAM_RADIUS

            if self:isCurrentDestination(i) then
                self:turnTowards(slaveDrone)
            end
        elseif slaveDrone.counters[i] > self.counters[i] + DRONE_SCREAM_RADIUS then
            slaveDrone.counters[i] = self.counters[i] + DRONE_SCREAM_RADIUS

            if slaveDrone:isCurrentDestination(i) then
                slaveDrone:turnTowards(self)
            end
        end
    end

    return true
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
    local resource = resource
    if resource == nil then
        resource = math.random(0, 1) == 0
    end
    
    ---@class Drone
    local obj = {
        counters = {},
    }

    for i = 1, countersCount do
        obj.counters[i] = math.random(DRONE_COUNTER_GENERATION_MINIMUM, DRONE_COUNTER_GENERATION_MAXIMUM)
    end

    obj.currentDestinationId = math.random(1, countersCount)

    obj.body = body.new(DRONE_BODY_TYPE, DRONE_RADIUS, DRONE_COLOR) --[[@as BodyCircular]]
    obj.controller = controller.new(
        x,
        y,
        obj.body--[[@as Body]],
        velocity or math.random(DRONE_VELOCITY_MINIMUM, DRONE_VELOCITY_MAXIMUM),
        angle or math.rad(math.random(1, 360))
    )
    
    obj.body:setFill(obj.currentDestinationId == 1)

    setmetatable(obj, Drone_meta)

    return obj
end

Drone.setCountersCount = setCountersCount

return Drone