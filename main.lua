local IA = require "IA"
local teacher = require "teacher"
local judge = require "judge"
local World = require "world"
local debugGraph = require "debugGraph"
function love.load()
    ia = IA.new(4,4,0.8,0.5,function() 
        return {0,0,0,0}--[[
            math.random(0,1),
            math.random(0,1),
            math.random(0,1),
            math.random(0,1)
            } --]]
        end)
    action2string = {"idle","right","right","jump"}
    
    length = 1000
    local num = 1000
    local target = 1000
    
    local override = true

    local name = num.."_"..length..".ia"
    if override or not love.filesystem.isFile(name) then
        print("training")
        teacher.train(ia,num,length,target)
        if not override then 
            ia:save(name)
        end
    else
        print("loading")
        ia:load(name) 
    end
    
    -- simulacao

    world = World.new(seed)
    score = 0
    dg = debugGraph:new('custom', 300, 60,200,60,0.01,"Score")
end
function love.update(dt)
    --if world.time < length then
        --if love.keyboard.isDown("space") then
        local photo = judge.snap(world)
        local s = world:state()
        local action = ia:run(s)
        as = action2string[action]
        world:update(as,1)
        score = score + judge.getscore(photo,world) 
        if world.player.y < -100 then
            world = World.new(seed)
            score = 0
        end
        dg:update(dt, score)
        dg.label = score
    --end
    --end
end
function love.draw()
    love.graphics.setColor(255,255,255)
    love.graphics.print("X  "..world.player.x,10,20)
    love.graphics.print("Y  "..world.player.y,10,30)
    love.graphics.print(as,10,50)
    world:draw()
    dg:draw()
end
