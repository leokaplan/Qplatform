local bump = require 'bump'
local World = {}
World.__index = World 
function World.new(seed)
    local o = {}
    setmetatable(o, World)
    o.H = 400
    o.world = bump.newWorld()
    o.gravity = 0.5
    o.time = 0
    o.seed = seed
    local player = {}
    player.x = 10
    player.y = 10
    player.vy = 0
    player.w = 10
    player.h = 10
    player.speed = 5
    player.jump = 10
    player.state = "air"
    
    
    o.player = player 
    o.world:add(o.player,player.x,player.y,player.w,player.h)
    o.plats = {}
    table.insert(o.plats,{x=0,y=0,h=5,w=40})
    local num = 10
    local sw = 20
    for i=1,num do
        table.insert(o.plats,{x=20+i*(40+sw),y=0,h=5,w=40})
    end
    for k,v in pairs(o.plats) do
        o.world:add(v,v.x,v.y,v.w,v.h)
    end
    return o
end
function World:reset()
    print(self)
    self = World.new(self.seed)
    print(self,self.player.x)
end
function World:update(input,dt)
    local p = self.player 
    if input == "left" then
        p.x = p.x - p.speed*dt 
    elseif input == "right" then
        p.x = p.x + p.speed*dt 
    elseif input == "jump" then
        if p.state == "ground" then
            p.vy = p.jump
        end
    end
    if p.state == "air" then
        p.y = p.y + p.vy*dt
        p.vy = p.vy - self.gravity*dt
    end
    local cols,len
    p.x,p.y,cols,len = self.world:move(p,p.x,p.y) 
    if p.x < 0 then p.x = 0 end
    if len > 0 then
        p.state = "ground"
    else
        p.state = "air"
    end
    self.time = self.time + dt
    self.player = p
end
function World:draw()
    if self.player.state == "air" then
        love.graphics.setColor(255,0,0)
    end
    if self.player.state == "ground" then
        love.graphics.setColor(0,0,255)
    end
    love.graphics.rectangle("line",self.player.x,self.H-self.player.y-self.player.h,self.player.w,self.player.h)
    
    love.graphics.setColor(255,255,255)
    for k,p in pairs(self.plats) do
        love.graphics.rectangle("line",p.x,self.H-p.y+p.h,p.w,p.h)
    end
end
function World:state()
    local function dist(a,b)
        return math.sqrt((a.x-b.x)*(a.x-b.x)+(a.y-b.y)*(a.y-b.y))
    end
    local plata,dx,dy
    local d = nil
    local kp = nil
    for k,p in pairs(self.plats) do
        local di = dist(self.player,p)
        if d == nil or di < d then
            d = di
            plata = p
            kp = k
        end
    end
    plata = self.plats[kp]
    dx = math.floor(plata.x - self.player.x) 
    dy = math.floor(plata.y - self.player.y) 
    --print(dx,dy)
    local state
    if self.player.state =="ground" then
        state = 1
    else
        state = 2
    end

    return {self.time,state,dx,dy} 
end
return World
