-- ColliderCircular
local ColliderCircular = {}

local collider_parent = require("classes.Collider")
local body = require("classes.Body")

-- documentation



-- config



-- consts



-- vars



-- init



-- fnc



-- classes

---@class ColliderCircular : Collider
---@field body BodyCircular
local collider = {}

setmetatable(collider, {__index = collider_parent.class}) -- Set parenthesis for circular collider

---Collide circular v circular
---@private
---@param slaveCollider ColliderCircular
---@return boolean
function collider:collideCircular(slaveCollider)
    local contactDistance = self.body.radius + slaveCollider.body.radius
    local calculatedDistance = self:getDistanceToOrigin(slaveCollider)

    return calculatedDistance <= contactDistance
end
---Collision function for circular body type
---@param slaveCollider Collider
function collider:collide(slaveCollider)
    if slaveCollider.body.bodyType == body.BodyType.CIRCULAR then
        ---@cast slaveCollider ColliderCircular
        return self:collideCircular(slaveCollider)
    end
end

-- ColliderCircular fnc

ColliderCircular.class = collider

return ColliderCircular