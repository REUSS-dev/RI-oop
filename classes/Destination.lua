-- Drone
local Destination = {}

local body = require("classes.Body")
local controller = require("classes.MovementController")

-- documentation

---@alias DestinationTypeIndex number

-- config

local DESTINATION_BODY_TYPE = body.BodyType.CIRCULAR

local DESTINATION_RADIUS = 50

local DESTINATION_ANGLE_DEVIANCE = 0.1

-- consts

local DESTINATION_VELOCITY_DEFAULT = 0
local DESTINATION_COLOR_DEFAULT = {1, 1, 1}

-- vars

---@type table<DestinationTypeIndex, ColorRGBA>
local typeColors = {}

-- init

setmetatable(typeColors, {__index = function () return DESTINATION_COLOR_DEFAULT end})

-- fnc

local function getDestinationPointRadius()
    return DESTINATION_RADIUS
end

---Sets color for type index
---@param typeIndex DestinationTypeIndex
---@param colortable ColorRGBA
local function setTypeColor(typeIndex, colortable)
    typeColors[typeIndex] = colortable
end

-- classes

---@class Destination
local destination = {}
local Destination_meta = {__index = destination}

---Get angle of destination point movement
---@return radians
function destination:getAngle()
    return self.controller.angle
end

---Get destination point X, Y coordinate and angle.
---@return number
---@return number
---@return radians
function destination:getDirectionals()
    return self.controller.collider.x, self.controller.collider.y, self.controller.angle
end

---Get destination point type
---@return DestinationTypeIndex
function destination:getType()
    return self.type
end

---Update destination point
---@param dt number
function destination:tick(dt)
    local curve = (math.random(0, 200) - 100)/100 * DESTINATION_ANGLE_DEVIANCE
    self.controller:turn(curve)

    self.controller:tick(dt)
end

---Paint destination point
function destination:draw()
    self.body:paint(self.controller:getCoordinates())
end

-- Drone fnc

---Create new Drone object
---@param x number
---@param y number
---@param destinationType number
---@param velocity number?
function Destination.new(x, y, destinationType, velocity)
    assert(destinationType, "Destination type not set for destination point")
    
    ---@class Destination
    local obj = {
        type = destinationType
    }

    
    obj.body = body.new(DESTINATION_BODY_TYPE, DESTINATION_RADIUS, typeColors[destinationType]) --[[@as BodyCircular]]
    obj.controller = controller.new(
        x,
        y,
        obj.body--[[@as Body]],
        velocity or DESTINATION_VELOCITY_DEFAULT,
        math.rad(math.random(1, 360))
    )

    setmetatable(obj, Destination_meta)

    return obj
end

Destination.registerType = setTypeColor
Destination.getDestinationPointRadius = getDestinationPointRadius

return Destination