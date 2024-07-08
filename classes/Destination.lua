-- Destination
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

---Returns standard radius of a destination point
---@return pixels Radius Radius of a circular body for destination points
local function getDestinationPointRadius()
    return DESTINATION_RADIUS
end

---Sets color for type index
---@param typeIndex DestinationTypeIndex Type index to define color for
---@param colortable ColorRGBA Respectful color table
local function setTypeColor(typeIndex, colortable)
    typeColors[typeIndex] = colortable
end

-- classes

---@class Destination World object class
local destination = {}
local Destination_meta = {__index = destination}

---Get angle of destination point movement
---@return radians Angle Angle of the destination point's movement
function destination:getAngle()
    return self.controller.angle
end

---Get destination point X, Y coordinate and angle.
---@return pixels X X coordinate of a destination point
---@return pixels Y Y coordinate of a destination point
---@return radians Angle Angle of destination point's movement
function destination:getDirectionals()
    return self.controller.collider.x, self.controller.collider.y, self.controller.angle
end

---Get destination point type
---@return DestinationTypeIndex Type Type of a destination point object
function destination:getType()
    return self.type
end

---Update destination point
---@param dt number Delta time to update destination point object
function destination:tick(dt)
    local curve = (math.random(0, 200) - 100)/100 * DESTINATION_ANGLE_DEVIANCE
    self.controller:turn(curve)

    self.controller:tick(dt)
end

---Paint destination point
function destination:draw()
    self.body:paint(self.controller:getCoordinates())
end

-- Destination fnc

---Create new Destination object
---@param x pixels Starting X coordinate of the new destination point
---@param y pixels Starting Y coordinate of the new destination point
---@param destinationType DestinationTypeIndex Set destination point type for the new destination point
---@param velocity number? Starting movement velocity of the new destination point 
---@return Destination Object
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