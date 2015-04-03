-- Naive linked list implementation
require 'luma.lib.compat51'
local fun = require 'luma.lib.fun'
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

local mt = {}
local function is_list(o)
	return getmetatable(o) == mt
end

list.is_list = is_list

local ITER_DONE = {}
local function _ipairs(param, state)
	if state == ITER_DONE then
		return nil
	end
	local rest = cdr(state)
	if rest == nil then
		-- the loop ends on nil so we need to introduce a sentinel (-1) to
		-- return the last value before quitting
		return ITER_DONE, car(state)
	elseif not is_list(rest) then
		return ITER_DONE, car(state), rest
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

mt.__index  = function(self, k)
	if type(k) == 'number' then
		return fun.nth(k, self)
	end
	return ListProto[k]
end
mt.__ipairs = ListProto.ipairs
mt.__len = fun.length
mt.__eq = function(o1, o2)
	return o1:car() == o2:car() and o2:cdr() == o2:cdr()
end

-- FIXME: add a list notation
function mt.__tostring(l)
	return string.format("(%s . %s)", tostring(l:car()), tostring(l:cdr()))
end

-- Note that this is not the same as nil, ie. '() and nil are different
function list.empty(...)
	return setmetatable({}, mt)
end

function list.cons(a, b)
	return setmetatable({a, b}, mt)
end

function list.icons(a, b)
	return {a, b}
end

local function reverse(...)
	return fun.reduce(function(l, v)
		return list.cons(v, l)
	end, nil, ...)
end

function list.from(...)
	if fun.length(...) == 0 then
		return list.empty()
	end
	-- FIXME: Real tables can safely be read in reverse
	return reverse(reverse(...))
end

function list.list(...)
	return list.from({...})
end

return list
