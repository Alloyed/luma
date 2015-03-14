--[[Generated by Luann v0.1-snapshot]] package.path = "../lib/?.lua;" .. package.path; require('luann.core'); local vec=require(vec)
local lg=love.graphics
local lk=love.keyboard
local _STAR_pos_STAR_=vec(100,100)
local size=vec(50,50)
local speed=250
local directions
=list
(cons(up,vec(0,(-speed)))
,cons(down,vec(0,speed))
,cons(left,vec((-speed),0))
,cons(right,vec(speed,0)))
local velocity=(function(dt) local test_direction=(function(direction) return (function() if lk.isDown(car(direction))
 then return cdr(direction)
 else return vec(0,0) end end)() end)
return apply(_ADD_,map(test_direction,directions)) end)
love.load=(function() return nil end)
love.update=(function(dt) _STAR_pos_STAR_=(_STAR_pos_STAR_+(velocity()*dt)) end)
love.draw=(function() return lg.rectangle(fill,car(_STAR_pos_STAR_),cdr(_STAR_pos_STAR_),car(size),cdr(size)) end)

