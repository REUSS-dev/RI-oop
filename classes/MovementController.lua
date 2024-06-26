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
---@return number
---@return number
function mc:getCoordinates()
    return self.x, self.y
end

---Turn movement controller by some amount
---@param rads radians
function mc:turn(rads)
    self.angle = self.angle + rads
end

---Get distance to other movement controller object
---@param slaveController MovementController
---@return number
function mc:getDistanceTo(slaveController)
    return self.collider:getDistanceTo(slaveController.collider)
end

---Check collision with another movement controller object
---@param slaveController MovementController
---@return boolean
function mc:checkCollision(slaveController)
    return self.collider:collide(slaveController.collider)
end

---Tick movement controller. Returns new X and Y coordinates.
---@param dt number
---@return number
---@return number
function mc:tick(dt)
    local x = math.cos(self.angle) * self.v * dt
	local y = math.sin(self.angle) * self.v * dt

    self.x = self.x + x
    self.y = self.y + y

    return self.x, self.y
end

-- MovementController fnc

---Create new MovementController object
---@param x number
---@param y number
---@param body Body
---@param velocity number?
---@param angle radians?
---@return MovementController
function MovementController.new(x, y, body, velocity, angle)
    assert(body, "No body defined for MovementController object")

    ---@class MovementController
    local obj = {
        x = x,
        y = y,
        v = velocity or 0,
        angle = angle or 0,
        collider = Collider.new(x, y, body)
    }

    setmetatable(obj, MovementController_meta)

    return obj
end

return MovementController