local list             = require 'ltrie.list'
local fun              = require 'ltrie.fun'
local ast              = require 'luma.read.ast'
local builtins_factory = require 'luma.compile.builtins'
local gen              = nil
local builtins         = nil
local macros           = {}

local function concat(iter, sep)
	local s  = ""
	local dosep = ""
	fun.each(function(v)
		s = s .. dosep .. gen(v)
		dosep = sep
	end, iter)
	return s
end

local function fcall(sexp)
	local name = gen(fun.head(sexp))
	local args = fun.totable(fun.tail(sexp))
	local builtin = builtins[name]
	local macro   = macros[name]
	if builtin then
		return builtin(args)
	elseif macro then
		return gen(macro(unpack(args)))
	else
		return name .. ("(%s)"):format(concat(args, ","))
	end
end

local function exprlist(exprs)
	local res = ""
	local last, is_statement = "", false
	local sep = ""
	fun.each(function(e)
		res = res .. last .. sep
		sep = ";\n"
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
		error(
		("unimplemented expr type %q, object: %q")
		:format(tostring(t), tostring(expr)))
	end
end

builtins = builtins_factory(concat, gen, macros)
return gen
