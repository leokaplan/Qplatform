local bump = require 'bump'

function startworld(seed)
    local world = bump.newWorld()
    world.gravity = 0.5
    local player = {}
    player.x = 10
    player.y = 50
    player.vy = 0
    player.w = 10
    player.h = 10
    player.speed = 5
    player.jump = 12
    player.state = "air"
    world.player = player 
    world:add(world.player,world.player.x,world.player.y,world.player.w,world.player.h)
    world.plats = {}
    table.insert(world.plats,{x=0,y=0,h=5,w=40})
    local num = 10
    local sw = 20
    for i=1,num do
        table.insert(world.plats,{x=20+i*(40+sw),y=0,h=5,w=40})
    end
    for k,v in pairs(world.plats) do
        world:add(v,v.x,v.y,v.w,v.h)
    end
    return world
end
function update(world,input,dt)
    --[[
    newworld = bump.newWorld()
    for k,v in pairs(world) do
        newworld[k] = v
    end
    newworld.player = {}
    for k,v in pairs(world.player) do
        newworld.player[k] = v
    end
    --]]
    if input == "left" then
        world.player.x = world.player.x - world.player.speed*dt 
    elseif input == "right" then
        world.player.x = world.player.x + world.player.speed*dt 
    elseif input == "jump" then
        if world.player.state == "ground" then
            world.player.vy = world.player.jump
            --newworld.player.state = "air"
        end
    end
    if world.player.state == "air" then
        world.player.y = world.player.y + world.player.vy*dt
        world.player.vy = world.player.vy - world.gravity*dt
    end
    world.player.x,world.player.y,cols,len = world:move(world.player,world.player.x,world.player.y) 
    if len > 0 then
        world.player.state = "ground"
    else
        world.player.state = "air"
    end
    return world
end
--[[
world
    plats = [quad]
    player = quad, state
--]]
--[[
function IA(world)
    acha plata mais proximo
    da p rede dist em x, em y e w da plata mais prox
    --rede: 3 float -> [prob]*input
    rede devolve inputs
    return 
     
end
--]]
function max(t)
    maxv = nil
    maxk = nil
    --print(t)
    for k,v in pairs(t) do
        --print(k,v)
        if maxv == nil or v > maxv then  
            maxv = v
            maxk = k
        end
    end
    return maxk
end
function initIA(size0,size1,size2,size3)
    local ia = {}
    for i=1,size0 do
        ia[i] = {}
        for k,v in pairs({"air","ground"}) do
            ia[i][v] =  {math.random(0,10),math.random(0,10),math.random(0,10),math.random(0,10)}
        end
    end
    return ia
end
--rate = 1
function learning(rate, security,num,length,range)
    local IA = initIA(length+10,2,range+10,range+10)
    seed = 0
    for i=1,num do
        print("episode "..i)
        IA = episode(IA,rate,security,seed,length)
    end
    for k,v in pairs(IA) do
        --print(k, v["air"],v[2],v[3],v[4])
    end
    return IA
end
    
function runIA(ia,world,s)
    return max(getstate(ia,s))
end
function train(ia,s,sl,a,score,rate,security,dt)
    getstate(ia,s)[a] = getstate(ia,s)[a] + rate * (score + security*max(getstate(ia,sl)) - getstate(ia,s)[a] )
    return ia
end
function condition(world)
    if world.player.y < 0 then
        return true
    end
    return false
end
function remember(x)
    return x
end
function snap(world)
    local a = world.player.x*1
    return {player={x=a,state=world.player.state}}
end
function getscore(world,newworld)
    local score = 0
    --[[
    if newworld.player.y < 20 then
        score = score - 10000
    end
    if newworld.player.state == "ground" and world.player.state == "ground" then
        score = score + 1
    end
    if newworld.player.state == "air" then
        --score = score + (newworld.player.y - world.player.y)
    end
    --]]
    if newworld.player.state == "air" and world.player.state == "air" then
        score = score + (newworld.player.x - world.player.x)*1
    end
    --if newworld.player.state == "ground" and world.player.state == "air" then
    --    score = score + 100
    --end
    if newworld.player.state == "ground" then
        score = score + (newworld.player.x - world.player.x)*2
    end
        --score = score + (newworld.player.x - world.player.x)
        score = score - 1
    return score
end
function dist(a,b)
    return math.sqrt((a.x-b.x)*(a.x-b.x)+(a.y-b.y)*(a.y-b.y))
end
function genstate(time,world)
    local plata,dx,dy
    local d = nil
    --[[
    for k,p in pairs(world.plats) do
        local di = dist(world.player,p)
        if d == nil or di < d then
            d = di
            plata = p
        end
    end
    --]]
    plata = world.plats[2]
    dx = math.floor(plata.x - world.player.x) 
    dy = math.floor(plata.y - world.player.y) 
    --print(dx,dy)
    return {time,world.player.state} 
end
function getstate(ia,s)
    --player state,dx,dy
    --[[
    print(s[1],s[2],s[3],s[4],ia[s[1] ] [ s[2] ])
    if s[3] > r/2 then s[3] = r/2 end
    if s[3] < -r/2 then s[3] = -r/2 end
    if s[4] > r/2 then s[4] = r/2 end
    if s[4] < -r/2 then s[4] = -r/2 end
    --]]
    return ia[s[1]][s[2]] 
end

function input2string(i)
    if i == 1 then return "idle" end
    if i == 2 then return "right" end
    if i == 3 then return "jump" end
    if i == 4 then return "left" end
end
function episode(memory,rate,security,seed,length)
    local IA = remember(memory)
    local world = startworld(seed)
    local time = 1
    local score = 0
    --print("\tstart")
    while time < length and not condition(world) do
        local photo = snap(world)
        local s = genstate(time,world)
        local input = runIA(IA,world,s)
        local dt = 1
        local newworld = update(world,input2string(input),dt)
        --print(input2string(input),world.player.x,newworld.player.x)
        score = score + getscore(photo,world) 
        --score = score + getscore(world,newworld) - 1
        --print("\tstep",time,input,score, world.player.x,world.player.y)
        time = time + dt
        local sl = genstate(time,world)
        IA = train(IA,s,sl,input,score,rate,security,dt)
        --world = newworld
    end
    print(score)
    --print(time,IA[time][1],IA[time][2],IA[time][3],IA[time][4])
    return IA
end
local binser = require "binser"
function save(ia,name)
    local f = love.filesystem.newFile(name)
    f:write(binser.serialize(ia))
end
function love.load()
    override = true
    l = 300
    r = 100
    local num = 1000
    --print(jupiter.load("xxx"))

    local name = num.."_"..l.."_"..r..".ia"
    print(name)
    if override or not love.filesystem.isFile(name) then
        print("training")
        trained = learning(1,1,num,l,r)
        save(trained,name)
    else
        print("loading")
        trained = binser.deserialize(love.filesystem.read(name))
    end
    world = startworld(seed)
    time = 1
    H = 400
    score = 0
end
function love.update(dt)

    if time < l and love.keyboard.isDown("space") then
        local photo = snap(world)
        local s = genstate(time,world)
        local input = runIA(trained,world,s)
    --else
    --    local input = 4
        update(world,input2string(input),1)
        score = score + getscore(photo,world) 
        time = time + 1
        --world = newworld
    end
end
function love.draw()
    if world.player.state == "air" then
        love.graphics.setColor(255,0,0)
    end
    if world.player.state == "ground" then
        love.graphics.setColor(0,0,255)
    end
    love.graphics.rectangle("line",world.player.x,H-world.player.y-world.player.h,world.player.w,world.player.h)
    love.graphics.setColor(255,255,255)
    love.graphics.print("$ "..score,10,10)
    love.graphics.print("X "..world.player.x,10,20)
    love.graphics.print("Y "..world.player.y,10,30)
    for k,p in pairs(world.plats) do
        love.graphics.rectangle("line",p.x,H-p.y+p.h,p.w,p.h)
    end
end
