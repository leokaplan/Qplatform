local teacher = {}
local function copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
  return res
end

local function remember(x) 
    return copy(x)
end
local World = require "world"
local judge = require "judge"
local function episode(memory,seed,length,keep)
    local ia = remember(memory)
    local world = World.new(seed)
    local score = 0
    --print("\tstart")
    local t = 0
    while world.time < length   do
        local photo = judge.snap(world)
        local s = world:state()
        local action = ia:run(s)
        local dt = 1
        world:update(action2string[action],dt)
        --print(input2string(input),world.player.x,newworld.player.x)
        score = score + judge.getscore(photo,world) 
        --score = score + getscore(world,newworld) - 1
        --print("\tstep",time,input,score, world.player.x,world.player.y)
        local sl = world:state()
        ia:train(s,sl,action,score)
        
        if judge.condition(world) then
            t = world.time
            world = World.new(seed)
            world.time = t
            score = score/keep
        end
        --world = newworld
    end
    --print(score)
    --print(time,IA[time][1],IA[time][2],IA[time][3],IA[time][4])
    return ia,score
end
function teacher.train(ia, num,length,target)
    local i = 0
    local score = 0
    local newia,newscore
    local conv = 0
    while i < num and score < target and conv < 10 do
        newia,newscore = episode(ia,seed,length,2)
        if newscore >= score then
            if newscore > score then
                conv = 0
                ia.security = ia.security*1.1
                print(score,newscore,ia.security)
            else
                conv = conv + 1
            end
            ia = newia
            score = newscore
        end
        if newscore < score then
            conv = 0
            ia.security = ia.security*0.9
            --print(score,newscore,ia.security)
        end
        i = i + 1
    end
end
return teacher
