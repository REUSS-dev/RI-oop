-- MovementController
local MovementController = {}

local Collider = require("classes.Collider")

-- documentation

---@alias radians number

-- config



-- consts



-- vars



-- init



-- fnc



-- classes

---@class MovementController
local mc = {}
local MovementController_meta = {__index = mc}

---Return movement controller's X and Y coordinates
---@return pixels X X coordinate of a movement controller
---@return pixels Y Y coordinate of a movement controller
function mc:getCoordinates()
    return self.collider.x, self.collider.y
end

---Turn movement controller by some amount
---@param rads radians Angle to turn movement controller by
function mc:turn(rads)
    self.angle = self.angle + rads
end

---Turn a drone around
function mc:reverseAngle()
    self.angle = self.angle + math.pi
end

---Reflect angle of a drone's movement vertically (mirrored over X axis)
function mc:reflectAngleVertical()
    self.angle = self.angle * -1
end

---Reflect angle of a drone's movement horizontally (mirrored over Y axis)
function mc:reflectAngleHorizontal()
    self.angle = (self.angle + math.pi) * -1
end

---Get distance to other movement controller object
---@todo Gets distance to the other movement controller collider's origin. May want to return the actual distance between closest colliding points of colliders
---@param slaveController MovementController Another movement controller to get distance to
---@return pixels Distance Distance between two movement controllers
function mc:getDistanceTo(slaveController)
    return self.collider:getDistanceToOrigin(slaveController.collider)
end

---Check collision with another movement controller object
---@param slaveController MovementController Another movement controller to check collision to
---@return boolean Collision If two movement controllers collide
function mc:checkCollision(slaveController)
    return self.collider:collide(slaveController.collider)
end

---Tick movement controller. Returns new X and Y coordinates.
---@param dt number Delta time to update movement controller object
function mc:tick(dt)
    local x = math.cos(self.angle) * self.v * dt
	local y = math.sin(self.angle) * self.v * dt

    self.collider.x = self.collider.x + x
    self.collider.y = self.collider.y + y
end

-- MovementController fnc

---Create new MovementController object
---@param x pixels Starting X coordinate of the new movement controller
---@param y pixels Starting Y coordinate of the new movement controller
---@param body Body Body object for the new movement controller
---@param velocity number? Starting velocity of the new movement controller
---@param angle radians? Starting angle of the new movement controller
---@return MovementController Object
function MovementController.new(x, y, body, velocity, angle)
    assert(body, "No body defined for MovementController object")

    ---@class MovementController
    local obj = {
        v = velocity or 0,
        angle = angle or 0,
        collider = Collider.new(x, y, body)
    }

    setmetatable(obj, MovementController_meta)

    return obj
end

return MovementController