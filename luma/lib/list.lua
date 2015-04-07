-- Naive linked list implementation
require 'luma.lib.compat51'
local fun = require 'luma.lib.fun'

local ListProto = {}
local list = setmetatable({}, {__index = ListProto})
local mt = {}
list.EMPTY = setmetatable({}, mt) -- Should this be different?

function ListProto.car(self)
	return rawget(self, '_car')
end

function ListProto.cdr(self)
	return rawget(self, '_cdr')
end

function ListProto.pair(self)
	return ListProto.car(self), ListProto.cdr(self)
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
		if l ~= list.EMPTY then
			return list.cons(list.car(l), loop(i, list.cdr(l)))
		elseif lists[i+1] ~= list.EMPTY then
			return loop(i+1, lists[i+1])
		else
			return nil
		end
	end
	return loop(1, lists[1])
end

function ListProto.unpack(self)
	if self == list.EMPTY then
		return
	end
	return list.car(self), ListProto.unpack(list.cdr(self))
end

local function is_list(o)
	return getmetatable(o) == mt
end

list.is_list = is_list

local function _ipairs(param, state)
	if state == list.EMPTY then
		return nil
	end

	local head, tail = list.pair(state)
	if not is_list(tail) then
		return list.EMPTY, head, tail
	end

	return tail, head
end

--[[
--   Implements a stateless, generic for for linked lists.
--   call like
--   	for _, v in ipairs(list) do
--   or, in 5.1
--   	for _, v in list:ipairs() do
--   note that instead of the first value being a meaningful index like it is
--   in normal ipairs, it is used soley to represent the iterator's state.
--   This is consistent with luafun iterators.
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

function mt.__tostring(l)
	local head, tail = l:pair()

	if list.is_list(tail) then
		local inner, sep = "", ""
		fun.each(function(v)
			inner = inner .. sep .. tostring(v)
			sep = " "
		end, l)
		return "(" .. inner .. ")"
	end

	return string.format("(%s . %s)", tostring(head), tostring(tail))
end

function list.cons(a, b)
	return setmetatable({_car = a, _cdr = b}, mt)
end

function list.icons(a, b)
	return {_car = a, _cdr = b}
end

local function reverse(...)
	return fun.reduce(function(l, v)
		return list.cons(v, l)
	end, list.EMPTY, ...)
end

function list.from_table(t)
	local l = list.EMPTY
	for i = #t, 1, -1 do
		l = list.cons(t[i], l)
	end
	return l
end

function list.from(...)
	if fun.length(...) == 0 then
		return list.EMPTY
	end
	-- FIXME: Real tables can safely be read in reverse
	return reverse(reverse(...))
end

function list.list(...)
	return list.from({...})
end

return list
