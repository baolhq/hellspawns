local collider = {}

function collider.aabb(a, b)
    return a.pos.x < b.pos.x + b.width and
        b.pos.x < a.pos.x + a.width and
        a.pos.y < b.pos.y + b.height and
        b.pos.y < a.pos.y + a.height
end

return collider
