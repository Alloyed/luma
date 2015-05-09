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

local List = import(core, 'ltrie.list', {
	'cons', 'car', 'cdr', 'append',
	list = 'of'
})

import(core, 'luma.lib.symbol', {
	'keyword', 'symbol'
})

local fun = import(core, 'ltrie.fun', {
	'each', 'map', 'reduce', 'filter', 'nth', 'range', 'intersperse', 'take',
	'drop', 'zip',
	concat = 'chain', count = 'length', _REPEAT_ = 'duplicate'
})

core.ast = require 'luma.read.ast'

core.table = require 'luma.lib.table'

core.array = core.table.array

local mt = require 'luma.lib.meta'

function core.identity(...)
	return ...
end
mt.docstring(core.identity, [[
Returns its arguments.
]])

function core.doall(...)
	return fun.each(core.identity, ...)
end
mt.docstring(core.doall, [[
Forces the evaluation of lazy sequences.
]]) 

function core.vararg(...)
	return ipairs {...}
end
mt.docstring(core.vararg, [[
Returns an iterator that produces its arguments.
]])

function core._ADD_(...)
	local sum = ...
	for i=2, select('#', ...) do
		sum = sum + select(i, ...)
	end
	return sum
end
mt.docstring(core._ADD_, [[
Sums the arguments from left to right, respecting the (__add) metamethod.
]])

function core._SUB_(...)
	local sum = ...
	for i=2, select('#', ...) do
		sum = sum - select(i, ...)
	end
	return sum
end
mt.docstring(core._SUB_, [[
subtracts the arguments from left to right, respecting the (__sub) metamethod.
]])

function core._STAR_(...)
	local sum = 1
	for i=1, select('#', ...) do
		sum = sum * select(i, ...)
	end
	return sum
end
mt.docstring(core._STAR_, [[
Multiplies the arguments from left to right, respecting the (__mul) metamethod.
]])

function core._DIV_(...)
	local sum = ...
	for i=2, select('#', ...) do
		sum = sum / select(i, ...)
	end
	return sum
end
mt.docstring(core._DIV_, [[
Divides the arguments from left to right, respecting the (__div) metamethod.
]])

function core._AND_(...)
	local sum = ...
	for i=2, select('#', ...) do
		sum = sum and select(i, ...)
	end
	return sum
end
mt.docstring(core._AND_, [[
evaluates exprs one at a time, from left to right. if an expression evaluates
to false, ie. (nil | false), then return that value, otherwise return the
value of the last expression.
]])

function core._OR_(...)
	local sum = ...
	for i=2, select('#', ...) do
		sum = sum or select(i, ...)
	end
	return sum
end
mt.docstring(core._OR_, [[
evaluates exprs one at a time, from left to right. if an expression evaluates
to true, then return that value, otherwise return the value of the last
expression.
]])

function core.mod(num, div)
	return num % div
end
mt.docstring(core.mod, [[returns the modulus of num and div]])

function core._EQ_(...)
	local sum = ...
	for i=2, select('#', ...) do
		sum = sum == select(i, ...)
	end
	return sum
end
mt.docstring(core._EQ_, [[
Returns true if every argument == the last argument,
respecting the (__eq) metamethod, false otherwise.
]])

function core.not_EQ_(...)
	local sum = ...
	for i=2, select('#', ...) do
		sum = sum ~= select(i, ...)
	end
	return sum
end
mt.docstring(core.not_EQ_, [[
Returns true if every argument ~= the last argument,
respecting the (__eq) metamethod, false otherwise.
]])

function core._LT_(...)
	local sum = ...
	for i=2, select('#', ...) do
		sum = sum < select(i, ...)
	end
	return sum
end
mt.docstring(core._LT_, [[
Returns true if every argument < the last argument,
respecting the (__lt) metamethod, false otherwise.
]])

function core._GT_(...)
	local sum = ...
	for i=2, select('#', ...) do
		sum = sum > select(i, ...)
	end
	return sum
end
mt.docstring(core._GT_, [[
Returns true if every argument > the last argument,
respecting the (__gt) metamethod, false otherwise.
]])

function core._LT__EQ_(...)
	local sum = ...
	for i=2, select('#', ...) do
		sum = sum <= select(i, ...)
	end
	return sum
end
mt.docstring(core._LT__EQ_, [[
Returns true if every argument <= the last argument,
respecting the (__le) metamethod, false otherwise.
]])

function core._GT__EQ_(...)
	local sum = ...
	for i=2, select('#', ...) do
		sum = sum >= select(i, ...)
	end
	return sum
end
mt.docstring(core._GT__EQ_, [[
Returns true if every argument >= the last argument,
respecting the (__ge) metamethod, false otherwise.
]])

-- TODO: should we monkey patch like this?
function string.concat(...)
	local sum = ...
	for i=2, select('#', ...) do
		sum = sum .. select(i, ...)
	end
	return sum
end
mt.docstring(string.concat, [[
Returns the concatenation of its arguments, respecting the (__concat)
metamethod.
]])

function core.apply(fn, ...)
	local args = {}
	local n = fun.numargs(...)
	for i=1, n - 1 do
		table.insert(args, (select(i, ...)))
	end
	local arglist = select(n, ...)
	fun.each(function(v)
		table.insert(args, v)
	end, arglist)
	
	return fn(unpack(args))
end
mt.docstring(core.apply, [[
Returns the application of f to args. Any arguments in between f and args are
prepended to the args before application.
]])

function core.partial(f, ...)
	local va = fun.iter{...}
	return function(...)
		local vb = fun.iter{...}
		return core.apply(f, fun.chain(va, vb))
	end
end
mt.docstring(core.partial, [[
Takes a function f, and some arguments A, and returns a partial application of
f to A. When the partial application is called with extra arguments B, f is
called with both A and B, chained. There is no limit on the arities of either
A or B.
]])

function core.comp(...)
	local f = {...}
	return function(...)
		local arg = {...}
		local function loop(fns)
			if not fun.is_null(fun.tail(fns)) then
				return fun.head(fns) (loop(fun.tail(fns)))
			end
			return fun.head(fns) (unpack(arg))
		end
		return loop(f)
	end
end
mt.docstring(core.comp, [[
Takes a set of functions, and returns a composition of those functions.
the functions are composed from right to left, so for example
    (comp a b c)
would return a function that does the equivalent of
    (lambda (...) (a (b (c ...))))
]])

function core.mapcat(...)
	return core.apply(core.concat, fun.map(...))
end
mt.docstring(core.mapcat, [[
Applies (core.map) to the arguments, and then concatenates the result.
]])

function core.sort(iterable, cmp)
	local tmp = fun.totable(iterable)
	table.sort(tmp, cmp)
	return fun.iter(tmp)
end
mt.docstring(core.sort, [[
Returns an iterator containing all of the value in iterable, sorted.
If a comparison function is not provided, (<) is used.
]])

local function impl(method_name, default)
	return function(...)
		local self = ...
		if self[method_name] then
			return self[method_name](...)
		end
		return default(...)
	end
end

core.get = impl('get', function(t, k)
	return t[k]
end)
mt.docstring(core.get, [[
Returns the value in t mapped to k. If no such value, returns nil
]])

function core.get_in(t, ks)
	local r = t
	fun.each(function(sym)
		r = core.get(r, sym)
	end, ks)
	return r
end
mt.docstring(core.get_in, [[
Returns the value nested in t that can be reached by using (get) on each key
in ks.
]])

core.assoc_BANG_ = impl('assocb', function(t, k, v)
	t[k] = v
	return t
end)
mt.docstring(core.assoc_BANG_, [[
Mutates the object t such that (= (get t k) v).
Returns t.
]])

function core.assoc_in_BANG_(t, ks, v)
	local _t, last = t, nil
	fun.each(function(sym)
		if last ~= nil then
			_t = core.get(_t, last)
		end
		last = sym
	end, ks)
	return core.assoc_BANG_(_t, last, v)
end
mt.docstring(core.assoc_in_BANG_, [[
Mutates the object t such that (= (get-in t ks) v).
Returns t.
]])

return core
