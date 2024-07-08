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

---@class Collider Virtualized body collider superclass
---@field collide fun(self, slaveCollider: Collider):boolean
local collider = {}
local Collider_meta = {__index = collider}

---Get distance to other collider object
---@param slaveCollider Collider Another collider to get distance to
---@return pixels Distance Distance between colliders
function collider:getDistanceToOrigin(slaveCollider)
    return math.sqrt((self.x-slaveCollider.x)^2 + (self.y-slaveCollider.y)^2)
end

-- Collider fnc

---Create new collider object
---@param x pixels Starting X coordinate of the new collider
---@param y pixels Starting Y coordinate of the new collider
---@param cbody Body Body object for the new collider
---@return Collider Object
function Collider.new(x, y, cbody)
    assert(cbody, "No body defined for Collider object")

    ---@class Collider
    local obj = {
        x = x or 0,
        y = y or 0,
        body = cbody
    }

    if cbody.bodyType == body.BodyType.CIRCULAR then
        local CircularCollider = require("classes.colliders.Circular")
        setmetatable(obj, {__index = CircularCollider.class})

        return obj
    end

    setmetatable(obj, Collider_meta)
    return obj
end

Collider.class = collider

return Collider