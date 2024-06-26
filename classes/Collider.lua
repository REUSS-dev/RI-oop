-- Collider
local Collider = {}

local body = require("classes.Body")

-- documentation



-- config



-- consts



-- vars



-- init



-- fnc

-- classes

---@class Collider
---@field collide fun(self, Collider):boolean
local collider = {}
local Collider_meta = {__index = collider}

---Get distance to other collider object
---@param slaveCollider Collider
---@return number
function collider:getDistanceTo(slaveCollider)
    return math.sqrt((self.x-slaveCollider.x)^2 + (self.y-slaveCollider.y)^2)
end

-- Collider fnc

---Create new collider object
---@param x number
---@param y number
---@param cbody Body
---@return Collider
function Collider.new(x, y, cbody)
    assert(body, "No body defined for Collider object")

    ---@class Collider
    local obj = {
        x = x or 0,
        y = y or 0,
        body = body
    }

    if cbody.bodyType == body.BodyType.CIRCULAR then
        local CircularCollider = require("classes.colliders.Circular")
        setmetatable(obj, {__index = CircularCollider})

        return obj
    end

    setmetatable(obj, Collider_meta)
    return obj
end

Collider.class = collider

return Collider