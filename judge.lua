local judge = {}
function judge.snap(world)
    return {player={x=world.player.x,state=world.player.state}}
end
function judge.condition(world)
    if world.player.y < -100 then
        return true
    end
    return false
end
function judge.getscore(world,newworld)
    local score = -0.1
    
    --[[
    if newworld.player.state == "ground" and world.player.state == "ground" then
        score = score + 1
    end
    if newworld.player.state == "air" then
        --score = score + (newworld.player.y - world.player.y)
    end
    if newworld.player.state == "air" then
        score = score + (newworld.player.x - world.player.x)*1
    end
    --]]
    --if newworld.player.state == "ground" and world.player.state == "air" then
    --    score = score + 100
    --end
    if newworld.player.state == "ground" then
        score = score + (newworld.player.x - world.player.x)*2
    end
        --score = score + (newworld.player.x - world.player.x)
        --score = score - 1
        --[[
    if newworld.player.y < 0 then
        score = -1
    end
    --]]
    return score
end
return judge
