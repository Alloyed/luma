--[[
-- "Builtin" functions are functions that take a list of arguments
-- (unevaluated, like macros) and return a string of the lua representation
-- of that expression. In a sense, they are macros that generate lua,
-- instead of lisp.
--]]
require 'luma.lib.compat51'
local fun         = require 'ltrie.fun'
local ast         = require 'luma.read.ast'
local symbol      = require 'luma.lib.symbol'
local builtins    = {}
local concat, gen = nil, nil
local macros = nil

local function is_local(pred)
	if pred or _G._LUMA_REPL then
		return ""
	end
	return "local "
end

local function defval(lval, rval)
	local prefix = is_local(string.find(tostring(lval), '%.'))
	return prefix .. gen(lval) .. "=" .. gen(rval) .. "", true
end

local function closure_parts(args, body)
	argstr = concat(args, ",")
	return argstr, gen(ast.make_list(body))
end

local function closure(args, ...)
	return ("(function(%s) %s end)")
		:format(closure_parts(fun.totable(args), {...}))
end

local function defun(signature, ...)
	local name = tostring(fun.head(signature))
	local args = fun.totable(fun.tail(signature))

	local islocal = is_local(name:match("[%.%:]"))
	return ("%sfunction %s(%s) %s end")
		:format(islocal, name, closure_parts(args, {...})), true
end

local _unpack = unpack
local function unpack(t)
	if t.unpack then
		return t:unpack()
	end
	return _unpack(t)
end

function builtins.set_BANG_(body)
	local lval, rval = unpack(body)
	return ("%s = %s"):format(gen(lval), gen(rval)), true
end

function builtins.assoc_BANG_(body)
	local t, k, v = unpack(body)
	return ("%s[%s] = %s"):format(gen(t), gen(k), gen(v)), true
end

function builtins.define(body)
	local lvalue = body[1]
	local rvalue = body[2]
	if lvalue._type == 'symbol' then
		return defval(lvalue, rvalue)
	elseif lvalue._type == 'sexp' then
		return defun(unpack(body))
	else
		assert(nil, "Invalid define.")
	end
end

function builtins._DO_(body)
	local l = ast.make_list(body)
	return gen(l), true
end


function builtins.lambda(a)
	return closure(unpack(a))
end

function builtins.let(form)
	local bindforms = fun.head(form)
	local bindstrings = {}
	fun.each(function(binding)
		assert(len(binding) == 2, "Binding forms must have 2 elements")
		local bindstr, _ = defval(unpack(binding))
		table.insert(bindstrings, bindstr)
	end, bindforms)
	local bound = table.concat(bindstrings, " ")
	local body  = ast.make_list(fun.tail(form))
	
	return ('(function() %s %s end)()'):format(bound, gen(body))
end

-- if is reserved so we need to add it as a string
builtins["if"] = function(a)
	local pred    = gen(a[1])
	local iftrue  = gen(ast.make_list{a[2]})
	local iffalse = a[3] and
		"else " .. gen(ast.make_list{a[3]}) or ""
	return ("(function() if %s then %s %s end end)()")
		:format(pred, iftrue, iffalse)
end

function builtins.cond(body)
	local first = true
	local s = ""
	for _, form in ipairs(body) do
		local pred = fun.head(form)
		local predstr = gen(pred)
		local rest = gen(ast.make_list(fun.tail(form)))
		if pred == ast.make_symbol 'else' then
			s = s .. " else " .. rest
		elseif first then
			s = s .. ("if %s then %s"):format(predstr, rest)
			first = nil
		else
			s = s .. (" elseif %s then %s"):format(predstr, rest)
		end
	end
	return ("(function() %s end end)()"):format(s)
end

local function op(symbol)
	return function(body)
		return ("(%s)"):format(concat(body, symbol))
	end
end

function builtins._SUB_(body)
	-- negation operator
	if (#body == 1) then
		return ("(-%s)"):format(gen(body[1]))
	-- actual subtraction
	else
		return ("(%s)"):format(concat(body, "-"))
	end
end

builtins._ADD_            = op '+'
builtins._STAR_           = op '*'
builtins._DIV_            = op '/'
builtins._AND_            = op ' and '
builtins._OR_             = op ' or '
builtins.mod              = op '%'
builtins._EQ_             = op '=='
builtins.not_EQ_          = op '~='
builtins._LT_             = op '<'
builtins._GT_             = op '>'
builtins._LT__EQ_         = op '<='
builtins._GT__EQ_         = op '>='
builtins["string.concat"] = op '..'

function builtins._NOT_(body)
	assert(len(body) == 1, "Not takes a single expression")
	return ("(not %s)"):format(gen(body[1]))
end

local function drop_indexes(...)
	return fun.map(function(i, v)
		return v
	end, ...)
end

function builtins.table(body)
	local keys, vals = fun.partition(function(i, _)
		return i % 2 == 1
	end, fun.enumerate(body))
	keys, vals = drop_indexes(keys), drop_indexes(vals)
	local iter = fun.zip(keys, vals)

	local pairs = {}
	fun.each(function(k, v)
		table.insert(pairs, ("[%s] = %s"):format(gen(k), gen(v)))
	end, iter)

	local r =  ("{%s}"):format(table.concat(pairs, ","))
	return r
end

function builtins.array(body)
	local a = {}
	fun.each(function(v)
		local s = gen(v)
		table.insert(a, s)
	end, body)

	return ("{%s}"):format(table.concat(a, ","))
end

function builtins.quote(body)
	local o = body[1]
	return ast.quote(o)
end

-- TODO: replace with a properly hygienic define-syntax
function builtins.define_macro(body)
	local signature = fun.head(body)
	local name = tostring(fun.head(signature))
	local args = fun.totable(fun.tail(signature))
	local argstr = concat(args, ",")
	local bodystr = gen(ast.make_list(fun.tail(body)))
	local compiled, err = (loadstring or load)(
		("return function(%s) %s end"):format(argstr, bodystr))
	assert(compiled, err)
	macros[name] = compiled ()
	return "", true
end

function builtins.mcall(body)
	local table = fun.head(body)
	local k     = fun.head(fun.tail(body))
	local args  = fun.chain({table}, fun.drop(2, body))
	if type(k) == 'table' and k._type == 'symbol' then
		return ("%s.%s(%s)"):format(gen(table), gen(k), concat(args, ", "))
	else
		return ("%s[%s](%s)"):format(gen(table), gen(k), concat(args, ", "))
	end
end

-- This is a builtins factory, so the compiler and the builtins table can
-- mutually recur. Don't try to use the builtins outside of the compiler.
return function(_concat, _gen, _macros)
	concat, gen, macros = _concat, _gen, _macros
	return builtins
end
