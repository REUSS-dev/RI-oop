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

local DRONE_ANGLE_DEVIANCE_BASE = 0.1

local DRONE_COUNTER_INCREMENT = 10
local DRONE_COUNTER_GENERATION_MINIMUM = 100
local DRONE_COUNTER_GENERATION_MAXIMUM = 1000

local DRONE_SCREAM_RADIUS_BASE = 30

-- consts

local DRONE_VELOCITY_MINIMUM = DRONE_VELOCITY_BASE - DRONE_VELOCITY_VARIANCE
local DRONE_VELOCITY_MAXIMUM = DRONE_VELOCITY_BASE + DRONE_VELOCITY_VARIANCE

-- vars

local countersCount = 0
local droneScreamRadius = DRONE_SCREAM_RADIUS_BASE
local droneAngleFluctuation = DRONE_ANGLE_DEVIANCE_BASE

local drawDroneAngle = false

-- init



-- fnc

---Returns the radius all drones are screaming in
---@return pixels Radius Radius in pixels
local function getScreamRadius()
    return droneScreamRadius
end

---Set the multiplier of drone's angle fluctuation. Base is 1.
---@param mult number A number to multiply the base angle fluctuation by
local function setAngleFluctuationMultiplier(mult)
    droneAngleFluctuation = DRONE_ANGLE_DEVIANCE_BASE * mult
end

---Set the amount of counters tracked by drone worldObjects
---@param counters number
local function setCountersCount(counters)
    countersCount = counters
end

---Set the multiplier of drone's scream radius. Base is 1.
---@param mult number A number to multiply the base scream radius by
local function setScreamRadiusMultiplier(mult)
    droneScreamRadius = DRONE_SCREAM_RADIUS_BASE * mult
end

---Set if drone direction facing should be drawn on paint
---@param bool boolean **true**, if directions should be drawn, **false** if directions should not be drawn.
local function setShowDroneDirections(bool)
    drawDroneAngle = bool
end

-- classes

---@class Drone
---@field counters table<DestinationTypeIndex, number>
local drone = {}
local Drone_meta = {__index = drone}

---Increment all counters of a drone
function drone:incrementCounters()
    for i = 1, countersCount do
        self.counters[i] = self.counters[i] + DRONE_COUNTER_INCREMENT
    end
end

---Test if passed destionation type is set for drone object as current destination
---@param testDestinationId DestinationTypeIndex Type of a world object/destination type
---@return boolean Test **true**, if current destination matches object's *testDestinationId*, **false** otherwise
function drone:isCurrentDestination(testDestinationId)
    return testDestinationId == self.currentDestinationId
end

---Get angle of movement of a drone
---@return radians Angle Current drone's movement angle
function drone:getAngle()
    return self.controller.angle
end

---Get X, Y and angle of a drone
---@return pixels X X coordinate of a drone
---@return pixels Y Y coordinate of a drone
---@return radians Angle Angle of drone's movement
function drone:getDirectionals()
    return self.controller.collider.x, self.controller.collider.y, self.controller.angle
end

---Reset a drone's counter of specified ID
---@param counterIndex DestinationTypeIndex Index of a counter to reset
function drone:resetCounter(counterIndex)
    self.counters[counterIndex] = 0
end

---Update a drone
---@param dt number Delta time to update destination point object
function drone:tick(dt)
    local curve = (math.random(0, 200) - 100)/100 * droneAngleFluctuation
    self.controller:turn(curve)

    self.controller:tick(dt)
end

---Set angle of movement towards another drone/world object.
---@param slaveDrone Drone|Destination Another movement controller containing world object
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

---Set drone's new destionation
---@param newDestinationId DestinationTypeIndex Destination type to change
function drone:setDestination(newDestinationId)
    self.currentDestinationId = newDestinationId
end

---Set if drone's body should be filled
---@param toFill boolean Pass **true**, if drone's body should be filled on paint or **false** if it should be hollow.
function drone:setFill(toFill)
    self.body:setFill(toFill)
end

---Try to connect to other drone and exchange info. Returns counter ID if exchange is successful.
---@param slaveDrone Drone Another drone to attempt exchange information
---@return DestinationTypeIndex|false Screamed_counter Last screamed counter if one is screamed. **false** otherwise
---@return pixels Distance Distance between respective drones
function drone:tryScream(slaveDrone)
    -- Abort if drones are out of eachother's reach
    local dronesDistance = self.controller:getDistanceTo(slaveDrone.controller)

    if dronesDistance > droneScreamRadius then
        return false, dronesDistance
    end

    local exchangedID;

    for i = 1, countersCount do
        if self.counters[i] > slaveDrone.counters[i] + droneScreamRadius then
            self.counters[i] = slaveDrone.counters[i] + droneScreamRadius

            if self:isCurrentDestination(i) then
                self:turnTowards(slaveDrone)
            end

            exchangedID = i
        elseif slaveDrone.counters[i] > self.counters[i] + droneScreamRadius then
            slaveDrone.counters[i] = self.counters[i] + droneScreamRadius

            if slaveDrone:isCurrentDestination(i) then
                slaveDrone:turnTowards(self)
            end

            exchangedID = i
        end
    end

    return exchangedID, dronesDistance
end

---Draw a drone
function drone:draw()
    self.body:paint(self.controller:getCoordinates())

    if drawDroneAngle then
        love.graphics.setColor(0.5, 0.5, 0.5, 0.25)
        love.graphics.line(self.controller.collider.x, self.controller.collider.y, self.controller.collider.x + math.cos(self.controller.angle) * self.controller.v/5, self.controller.collider.y + math.sin(self.controller.angle) * self.controller.v/5)
    end
end

-- Drone fnc

---Create new Drone object
---@param x pixels Starting X coordinate of the new drone
---@param y pixels Starting Y coordinate of the new drone
---@param angle radians? Starting angle of the new drone
---@param velocity number? Starting velocity of the new drone
---@return Drone Object
function Drone.new(x, y, angle, velocity)
    ---@class Drone
    local obj = {
        counters = {},
        baseVelocity = velocity or math.random(DRONE_VELOCITY_MINIMUM, DRONE_VELOCITY_MAXIMUM)
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
        obj.baseVelocity,
        angle or math.rad(math.random(1, 360))
    )
    
    obj.body:setFill(obj.currentDestinationId == 1)

    setmetatable(obj, Drone_meta)

    return obj
end

Drone.setCountersCount = setCountersCount
Drone.setScreamRadiusMultiplier = setScreamRadiusMultiplier
Drone.setAngleFluctuationMultiplier = setAngleFluctuationMultiplier
Drone.getScreamRadius = getScreamRadius
Drone.setShowDroneDirections = setShowDroneDirections

return Drone