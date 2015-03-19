local List = require 'luma.lib.list'

list, cons, car, cdr, append = List.list, List.cons, List.car, List.cdr, List.append

local Keyword = require 'luma.lib.keyword'

keyword, _G['keyword?'] = Keyword.keyword, Keyword.is_keyword

local AList = require 'luma.lib.alist'

alist = AList.alist

local fun = require 'luma.lib.fun'

map, reduce, count, nth = fun.map, fun.reduce, fun.length, fun.nth
concat = fun.chain

function identity(...)
	return ...
end

function doall(...)
	return fun.each(identity, ...)
end

do
	local i, t, l = 0, {}
	local function iter(...)
		i = i + 1
		if i > l then return end
		return i, t[i]
	end

	function vararg(...)
		i = 0
		l = select("#", ...)
		for n = 1, l do
			t[n] = select(n, ...)
		end
		for n = l+1, #t do
			t[n] = nil
		end
		return iter
	end
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

function apply(fn, ...)
	local args = List.from(fun.chain(...))
	return fn(List.unpack(args))
end

function partial(f, ...)
	local va = varargs(...)
	return function(...)
		local vb = varargs(...)
		apply(f, va, vb)
	end
end

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
