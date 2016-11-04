local IA = require "IA"
local ia = IA.new(2,2,0.5,0.5,function()return{10,10}end)
print(
    ia:actions({0,1}),
    ia:actions({0,1}),
    ia:actions({0,1})
    )
print(unpack(ia:actions({0,1})))
ia:train({0,1},{1,1},2,0.5)
print(unpack(ia:actions({0,1})))
ia:train({0,1},{1,1},2,10)
print(unpack(ia:actions({0,1})))
print(ia:run({0,1}))
