local binser = require "binser"
local IA  = {}
IA.__index = IA 
function IA.new(input,output,rate,security,default)
    local o = {}
    setmetatable(o, IA)
    o.input = input
    o.output = output
    o.rate = rate
    o.security = security
    o.default = default
    return o
end
local function max(t)
    local maxv = nil
    local maxk = nil
    --print(t)
    for k,v in pairs(t) do
        --print(k,v)
        if maxv == nil or v > maxv then 
            maxv = v
            maxk = k
        end
    end
    local best = {}
    for k,v in pairs(t) do
        if maxv == v then
            table.insert(best,k)
        end
    end
    return best[math.random(1,#best)]
end
function IA:actions(state)
    assert(type(state)=='table',"state not table")
    assert(#state == self.input,"#state not #input")
    local temp = self
    for k,v in pairs(state) do
        if temp[v] then
            temp = temp[v]
        else
            temp[v] = {}
            temp = temp[v]
        end
    end
    
    if type(temp) ~= 'table' or #temp == 0 then
        --or random
        local temp2 = self.default()
        for k,v in pairs(temp2) do
            temp[k] = v
        end
        
    end
    assert(type(temp)=='table',"temp not table")
    assert(#temp == self.output,"#temp not #output")
    return temp
end
function IA:run(state)
    local action = max(self:actions(state))
    assert(type(action) ~= 'table',"action not index")
    assert(action <= self.output,"action not in output")
    return action
end
function IA:train(s,sl,a,score) 
    self:actions(s)[a] = self:actions(s)[a] + 
    self.rate * (score + self.security * self:actions(sl)[max(self:actions(sl))] 
    - self:actions(s)[a] )
end
function IA:save(name)
    local f = love.filesystem.newFile(name)
    f:write(binser.serialize(ia))
end
function IA:string()
    return binser.serialize(ia)
end
function IA:load(name)
    self = binser.deserialize(love.filesystem.read(name))
    setmetatable(self, IA)
end
return IA
