-- MovementController
local MovementController

local Collider = require("classes.Collider")

-- documentation



-- config



-- consts



-- vars



-- init



-- fnc



-- classes

---@class MovementController
local mc = {}
local MovementController_meta = {__index = mc}

---Get distance to other movement controller object
---@param slaveController MovementController
---@return number
function mc:getDistanceTo(slaveController)
    return self.collider:getDistanceTo(slaveController.collider)
end

function mc:checkCollision(slaveController)
    return self.collider:collide(slaveController.collider)
end

-- MovementController fnc

---Create new MovementController object
---@param x number
---@param y number
---@param body Body
---@return MovementController
function MovementController.new(x, y, body)
    assert(body, "No body defined for MovementController object")

    ---@class MovementController
    local obj = {
        x = x or 0,
        y = y or 0,
        collider = Collider.new(x, y, body)
    }

    setmetatable(obj, MovementController_meta)

    return obj
end

return MovementController