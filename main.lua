
function startworld(seed)
    local world = {}
    world.gravity = 1
    local player = {}
    player.x = 10
    player.y = 30
    player.vy = 0
    player.w = 10
    player.h = 10
    player.speed = 5
    player.jump = 10
    player.state = "air"
    world.player = player 
    world.plats = {}
    table.insert(world.plats,{x=0,y=0,h=5,w=40})
    local num = 10
    local sw = 15
    for i=1,num do
        table.insert(world.plats,{x=20+i*(40+sw),y=0,h=5,w=30})
    end
    return world
end
function collide(o, world)
    for k,p in pairs(world.plats) do
        if o.x < p.x+p.w and o.x > p.x and o.y > p.y and o.y < p.y+o.h then
            return true
        end
    end
end
function update(world,input,dt)
    newworld = {}
    for k,v in pairs(world) do
        newworld[k] = v
    end
    newworld.player = {}
    for k,v in pairs(world.player) do
        newworld.player[k] = v
    end
    if input == "left" then
        newworld.player.x = world.player.x - world.player.speed*dt 
    elseif input == "right" then
        newworld.player.x = world.player.x + world.player.speed*dt 
    elseif input == "jump" then
        if world.player.state == "ground" then
            newworld.player.vy = world.player.jump
            newworld.player.state = "air"
        end
    end
    if world.player.state == "air" then
        newworld.player.y = world.player.y + newworld.player.vy*dt
        newworld.player.vy = newworld.player.vy - world.gravity*dt
    end
    if collide(world.player,world) then
        newworld.player.state = "ground"
    else
        newworld.player.state = "air"
    end
    return newworld
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
    for k,v in pairs(t) do
        if maxv == nil or v > maxv then  
            maxv = v
            maxk = k
        end
    end
    return maxk
end
function initIA(size)
    local ia = {}
    for i=1,size do
        --ia[i] = {100,100,100,100}
        ia[i] = {0,0,0,100}
    end
    return ia
end
--rate = 1
function learning(rate, security,num,length)
    local IA = initIA(length+10)
    seed = 0
    for i=1,num do
        print("episode "..i)
        IA = episode(IA,rate,security,seed,length)
    end
    for k,v in pairs(IA) do
        print(k, v[1],v[2],v[3],v[4])
    end
    return IA
end
    
function runIA(ia,world,s)
    return max(ia[s])
end
function train(ia,s,a,score,rate,security,dt)
    ia[s][a] = ia[s][a] + rate * (score + security*max(ia[s+dt]) - ia[s][a] )
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
function getscore(world,newworld)
    --if newworld.player.state == "ground" and world.player.state == "air" then
    --    return 10 + (newworld.player.x - world.player.x)/100
    --end
    if newworld.player.state == "ground" and world.player.state == "ground" then
        return (newworld.player.x - world.player.x)/100
    end
    if newworld.player.state == "air" then
        return (newworld.player.y - world.player.y) + (newworld.player.x - world.player.x)/100
    end
    return 0
end
function getstate(time,world)
    return time 
end
function input2string(i)
    if i == 1 then return "left" end
    if i == 2 then return "right" end
    if i == 3 then return "jump" end
    if i == 4 then return "idle" end
end
function episode(memory,rate,security,seed,length)
    local IA = remember(memory)
    local world = startworld(seed)
    local time = 1
    local score = 0
    --print("\tstart")
    while time < length and not condition(world) do
        local input = runIA(IA,world,time)
        local dt = 1
        local newworld = update(world,input2string(input),dt)
        --print(input2string(input),world.player.x,newworld.player.x)
        score = score + getscore(world,newworld) - 1
        --print("\tstep",time,input,score, world.player.x,world.player.y)
        IA = train(IA,getstate(time,world),input,score,rate,security,dt)
        time = time + dt
        world = newworld
    end
    --print(time,IA[time][1],IA[time][2],IA[time][3],IA[time][4])
    return IA
end
function love.load()
    l = 50
    trained = learning(1,0.5,100,l)
    world = startworld(seed)
    time = 1
    H = 400
end
function love.update(dt)
    if time < l then
        local input = runIA(trained,world,time)
    --else
    --    local input = 4
        local newworld = update(world,input2string(input),1)
        time = time + 1
        world = newworld
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
    for k,p in pairs(world.plats) do
        love.graphics.rectangle("line",p.x,H-p.y+p.h,p.w,p.h)
    end
end
