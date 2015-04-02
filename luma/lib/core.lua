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

import(core, 'luma.lib.keyword', {
	'keyword',
	keyword_QMARK_ = 'is_keyword'
})

import(core, 'luma.lib.alist', {
	'alist'
})

local fun = import(core, 'luma.lib.fun', {
	'map', 'reduce', 'nth', 'range', 'intersperse',
	concat = 'chain', count = 'length'
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
	for _, v in core.vararg(select(2, ...)) do
		sum = sum + v
	end
	return sum
end

function core._SUB_(...)
	local sum = ...
	for _, v in core.vararg(select(2, ...)) do
		sum = sum - v
	end
	return sum
end

function core._STAR_(...)
	local sum = 1
	for _, v in core.vararg(...) do
		sum = sum * v
	end
	return sum
end

function core._DIV_(...)
	local sum = ...
	for _, v in core.vararg(select(2, ...)) do
		sum = sum / v
	end
	return sum
end

-- TODO: should we monkey patch like this?
function string.concat(...)
	local sum = ...
	for _, v in core.vararg(select(2, ...)) do
		sum = sum .. v
	end
	return sum
end

-- TODO: this can probably be made more efficient without the List.from()
function core.apply(fn, ...)
	local args = List.from(fun.chain(...))
	return fn(List.unpack(args))
end

function partial(f, ...)
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

return core
