local list             = require 'luma.lib.list'
local fun              = require 'luma.lib.fun'
local ast              = require 'luma.read.ast'
local builtins_factory = require 'luma.compile.builtins'
local gen              = nil
local builtins         = nil
local macros           = {}

local function concat(tbl, sep)
	local tmp = {}
	fun.each(function(v)
		table.insert(tmp, gen(v))
	end, tbl)
	return table.concat(tmp, sep)
end

local function fcall(sexp)
	local name = fun.head(sexp)
	local args = fun.totable(fun.tail(sexp))
	local builtin = builtins[tostring(name)]
	local macro   = macros[tostring(name)]
	if builtin then
		return builtin(args)
	elseif macro then
		return gen(macro(unpack(args)))
	else
		return gen(name) .. ("(%s)"):format(concat(args, ","))
	end
end

local function exprlist(exprs)
	local res = ""
	local last, is_statement = "", false
	fun.each(function(e)
		res = res .. last .. "\n"
		last, is_statement = gen(e)
	end, exprs)
	return res .. (is_statement and "" or "return ") .. last
end

local function expr_type(o)
	local rawtype = type(o)
	if rawtype ~= 'table' then
		return rawtype
	elseif o._type then
		return o._type
	elseif list.is_list(o) then
		return 'sexp'
	end
	error("expr type not recognized")
end

local gen_dispatch = {
	list    = exprlist,
	sexp    = fcall,
	number  = tostring,
	string  = function(s) return string.format('%q', s) end,
	symbol  = tostring,
	keyword = tostring
}

function gen(expr)
	if expr == nil then
		return ""
	end
	local t = expr_type(expr)
	local typed_gen = gen_dispatch[t]

	if typed_gen then
		return typed_gen(expr)
	else
		assert(nil,
		("unimplemented expr type %q, object: %q")
		:format(tostring(t), tostring(expr)))
	end
end

builtins = builtins_factory(concat, gen, macros)
return gen
