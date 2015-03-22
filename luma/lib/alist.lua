-- Association list implementation
local fun = require 'luma.lib.fun'
local list = require 'luma.lib.list'
local AList = {}

function AList.empty()
	return list.empty()
end

-- warning, you have to pass in an iter that returns pairs instead of ipairs
function AList.from(...)
	if fun.length(...) == 0 then
		return AList.empty()
	end
	local keys = {} -- Sorry~
	return list.from(fun.map(function(k, v)
		assert(not keys[k], "Duplicate keys.")
		keys[k] = true
		return list.cons(k, v)
	end, ...))
end

local function is_key(i, v)
	return i % 2 == 1
end

local function selectN(n)
	return function(...)
		return select(n, ...)
	end
end

local inspect = require 'inspect'
function AList.from_flat(...)
	if fun.length(...) == 0 then
		return AList.empty()
	end
	local keys, vals = fun.partition(is_key, fun.enumerate(...))
	local k = fun.map(selectN(2), keys)
	local v = fun.map(selectN(2), vals)
	return AList.from(fun.zip(k, v))
end

function AList.alist(...)
	return AList.from_flat({...})
end

function AList.keys(a)
	return fun.map(list.car, a)
end

function AList.values(a)
	return fun.map(list.cdr, a)
end

function AList.get(a, k)
	return fun.find(function(pair)
		return k == pair:car() and pair:cdr()
	end, a)
end

return AList
