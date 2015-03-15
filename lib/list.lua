local fun = require 'lib.fun'
local ListProto = {}
local list = setmetatable({}, {__index = ListProto})

function ListProto.car(self)
	return rawget(self, 1)
end

function ListProto.cdr(self)
	return rawget(self, 2)
end

function ListProto.table(self)
	local tbl = {}
	for _, v in self:ipairs() do
		table.insert(tbl, v)
	end
	return tbl
end

function ListProto.append(...)
	local lists = {...}
	local function loop(i, l)
		if l ~= nil then
			return list.cons(l:car(), loop(i, l:cdr()))
		elseif lists[i+1] ~= nil then
			return loop(i+1, lists[i+1])
		else
			return nil
		end
	end
	return loop(1, lists[1])
end

local car, cdr = ListProto.car, ListProto.cdr
function ListProto.unpack(self)
	if self == nil then
		return
	end
	return car(self), ListProto.unpack(cdr(self))
end

local function _ipairs(param, state)
	if state == -1 then
		return nil
	end
	local rest = cdr(state)
	if rest == nil then
		-- the loop ends on nil so we need to introduce a sentinel (-1) to
		-- return the last value before quitting
		return -1, car(state)
	end
	return rest, car(state)
end

--[[
--   Implements a stateless, generic for for linked lists.
--   call like
--   	for _, v in ipairs(list) do
--   or, in 5.1
--   	for _, v in list:ipairs() do
--   note that instead of the first value being a meaningful index like it is
--   in normal ipairs, it is used soley to represent the iterator's state.
--   This is for luafun's sake.
--]]
function ListProto.ipairs(self)
	return _ipairs, self, self
end

local mt = {}

mt.__index  = function(self, k)
	if type(k) == 'number' then
		return fun.nth(k, self)
	end
	return ListProto[k]
end
mt.__ipairs = ListProto.ipairs
mt.__len = fun.length

-- FIXME: add a list notation
function mt.__tostring(l)
	return string.format("(%s . %s)", tostring(l:car()), tostring(l:cdr()))
end

function list.cons(a, b)
	return setmetatable({a, b}, mt)
end

function list.icons(a, b)
	return {a, b}
end

function list.from(tbl)
	local function loop(i)
		if tbl[i] == nil then return nil end
		return list.cons(tbl[i], loop(i+1))
	end
	return loop(1)
end

function list.list(...)
	return list.from({...})
end

return list
