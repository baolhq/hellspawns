local enemy = {
    kind = "chaser", -- "chaser", "wanderer"
    hp = 0,
    maxHp = 0,
    speed = 0,
    sprite = {},
}

function enemy:init(kind, sprite)
    self.kind = kind
    self.maxHp = 100
    self.hp = self.maxHp
    self.speed = 200
    self.sprite = sprite
end

return enemy
