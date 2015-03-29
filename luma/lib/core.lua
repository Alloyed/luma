local List = require 'luma.lib.list'

     list,      cons,      car,      cdr,      append =
List.list, List.cons, List.car, List.cdr, List.append

local Keyword = require 'luma.lib.keyword'

keyword, _G['keyword?'] = Keyword.keyword, Keyword.is_keyword

local AList = require 'luma.lib.alist'

alist = AList.alist

local fun = require 'luma.lib.fun'

map,         reduce,     nth,     range,     intersperse =
fun.map, fun.reduce, fun.nth, fun.range, fun.intersperse

    concat,    count =
fun.chain, fun.length

ast = require 'luma.read.ast'

function identity(...)
	return ...
end

function doall(...)
	return fun.each(identity, ...)
end

function vararg(...)
	return ipairs {...}
end

function _ADD_(...)
	local sum = ...
	for _, v in vararg(select(2, ...)) do
		sum = sum + v
	end
	return sum
end

function _SUB_(...)
	local sum = ...
	for _, v in vararg(select(2, ...)) do
		sum = sum - v
	end
	return sum
end

function _STAR_(...)
	local sum = 1
	for _, v in vararg(...) do
		sum = sum * v
	end
	return sum
end

function _DIV_(...)
	local sum = ...
	for _, v in vararg(select(2, ...)) do
		sum = sum / v
	end
	return sum
end

function string.concat(...)
	local sum = ...
	for _, v in vararg(select(2, ...)) do
		sum = sum .. v
	end
	return sum
end

-- TODO: this can probably be made more efficient without the List.from()
function apply(fn, ...)
	local args = List.from(fun.chain(...))
	return fn(List.unpack(args))
end

function partial(f, ...)
	local va = fun.iter(vararg(...))
	return function(...)
		local vb = fun.iter(vararg(...))
		return apply(f, va, vb)
	end
end

-- FIXME: no werko
function comp(...)
	fns = {...}
	return function(...)
		local v = ...
		for _, f in ipairs(fns) do
			v = f(v)
		end
		return v
	end
end

function mapcat(...)
	apply(concat, map(...))
end

