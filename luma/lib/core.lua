local core = {}

local function import(self, module_name, import_tbl)
	local mod = require(module_name)
	for to, from in pairs(import_tbl) do
		if type(to) == 'number' then
			to = from
		end
		self[to] = mod[from]
	end
	return mod
end

local List = import(core, 'luma.lib.list', {
	'list', 'cons', 'car', 'cdr', 'append'
})

import(core, 'luma.lib.symbol', {
	'keyword', 'symbol'
})

import(core, 'luma.lib.alist', {
	'alist'
})

local fun = import(core, 'luma.lib.fun', {
	'each', 'map', 'reduce', 'filter', 'nth', 'range', 'intersperse', 'take',
	'drop', 'zip',
	concat = 'chain', count = 'length', _REPEAT_ = 'duplicate'
})

core.ast = require 'luma.read.ast'

function core.identity(...)
	return ...
end

function core.doall(...)
	return fun.each(core.identity, ...)
end

function core.vararg(...)
	return ipairs {...}
end

function core._ADD_(...)
	local sum = ...
	for i=2, select('#', ...) do
		sum = sum + select(i, ...)
	end
	return sum
end

function core._SUB_(...)
	local sum = ...
	for i=2, select('#', ...) do
		sum = sum - select(i, ...)
	end
	return sum
end

function core._STAR_(...)
	local sum = 1
	for i=1, select('#', ...) do
		sum = sum * select(i, ...)
	end
	return sum
end

function core._DIV_(...)
	local sum = ...
	for i=2, select('#', ...) do
		sum = sum / select(i, ...)
	end
	return sum
end

function core._AND_(...)
	local sum = ...
	for i=2, select('#', ...) do
		sum = sum and select(i, ...)
	end
	return sum
end

function core._OR_(...)
	local sum = ...
	for i=2, select('#', ...) do
		sum = sum or select(i, ...)
	end
	return sum
end

function core.mod(...)
	local sum = ...
	for i=2, select('#', ...) do
		sum = sum % select(i, ...)
	end
	return sum
end

function core._EQ_(...)
	local sum = ...
	for i=2, select('#', ...) do
		sum = sum == select(i, ...)
	end
	return sum
end

function core.not_EQ_(...)
	local sum = ...
	for i=2, select('#', ...) do
		sum = sum ~= select(i, ...)
	end
	return sum
end

function core._LT_(...)
	local sum = ...
	for i=2, select('#', ...) do
		sum = sum < select(i, ...)
	end
	return sum
end

function core._GT_(...)
	local sum = ...
	for i=2, select('#', ...) do
		sum = sum > select(i, ...)
	end
	return sum
end

function core._LT__EQ_(...)
	local sum = ...
	for i=2, select('#', ...) do
		sum = sum <= select(i, ...)
	end
	return sum
end

function core._GT__EQ_(...)
	local sum = ...
	for i=2, select('#', ...) do
		sum = sum >= select(i, ...)
	end
	return sum
end

-- TODO: should we monkey patch like this?
function string.concat(...)
	local sum = ...
	for i=2, select('#', ...) do
		sum = sum .. select(i, ...)
	end
	return sum
end

-- TODO: this can probably be made more efficient without the List.from()
function core.apply(fn, ...)
	local args = List.from(fun.chain(...))
	return fn(List.unpack(args))
end

function core.partial(f, ...)
	local va = fun.iter(core.vararg(...))
	return function(...)
		local vb = fun.iter(core.vararg(...))
		return core.apply(f, va, vb)
	end
end

-- FIXME: no werko
function core.comp(...)
	fns = {...}
	return function(...)
		local v = ...
		for _, f in ipairs(fns) do
			v = f(v)
		end
		return v
	end
end

function core.mapcat(...)
	core.apply(core.concat, fun.map(...))
end

-- FIXME: this shadows the table namespace
--[[
function core.table(...)
	local t = {}
	for i=1, select('#', ...), 2 do
		t[select(i, ...)] = select(i + 1, ...)
	end
	return t
end
--]]

function core.array(...)
	local a = {}
	for i=1, select('#', ...) do
		a[i] = select(i, ...)
	end
	return a
end

function core.sort(iterable, cmp)
	local tmp = fun.totable(iterable)
	table.sort(tmp, cmp)
	return fun.iter(tmp)
end

function core.get(t, k)
	return t[k]
end

function core.get_in(t, vec)
	local r = t
	fun.each(function(sym)
		r = r[sym]
	end, vec)
	return r
end

function core.assoc_BANG_(t, k, v)
	t[k] = v
end

function core.assoc_in_BANG_(t, vec, v)
	local _t, last = t, nil
	fun.each(function(sym)
		if last ~= nil then
			_t = _t[last]
		end
		last = sym
	end, vec)
	_t[last] = v
end

return core
