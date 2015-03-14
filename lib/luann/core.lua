local List = require 'list'

list, cons, car, cdr, append = List.list, List.cons, List.car, List.cdr, List.append

function map(fn, l)
	local function loop(l)
		if l == nil then return nil end
		return List.cons(fn(l:car()), loop(l:cdr()))
	end
	return loop(l)
end

function reduce(fn, l)
	local res, rr = l:car(), l:cdr()
	for _, v in rr:ipairs() do
		res = fn(res, v)
	end
	return res
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

function _MULT_(...)
	local sum = 1
	for _, v in vararg(...) do
		sum = sum * v
	end
	return sum
end

function _DIV(...)
	local sum = ...
	for _, v in vararg(select(2, ...)) do
		sum = sum / v
	end
	return sum
end

function apply(fn, l)
	return fn(unpack(List.maketable(l)))
end
