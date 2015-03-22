--[[
-- "Builtin" functions are functions that take a list of arguments
-- (unevaluated, like macros) and return a string of the lua representation
-- of that expression. In a sense, they are macros that generate lua,
-- instead of lisp.
--]]
local fun         = require 'luma.lib.fun'
local inspect     = require 'inspect'
local ast         = require 'luma.read.ast'
local AList       = require 'luma.lib.alist'
local builtins    = {}
local concat, gen = nil, nil

local function defval(lval, rval)
	local prefix = string.find(tostring(lval), '%.') and "" or "local "
	return prefix .. gen(lval) .. "=" .. gen(rval) .. "", true
end

local function closure(args, ...)
	local body = ast.make_list {...}
	local argstr = concat(args:table(), ",")
	return ("(function(%s) %s end)"):format(argstr, gen(body))
end

local function defun(signature, ...)
	local body = ast.make_list {...}
	local name = tostring(fun.head(signature))
	local args = fun.totable(fun.tail(signature))
	local argstr = concat(args, ",")
	local islocal = name:match("[%.%:]") and "" or "local "
	return ("%sfunction %s(%s) %s end")
		:format(islocal, name, argstr, gen(body))
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
	return gen(lval) .. "=" .. gen(rval), true
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

function builtins.lambda(a)
	return closure(unpack(a))
end

function builtins.let(form)
	local bindforms = fun.head(form)
	local bindstrings = {}
	for _, binding in ipairs(bindforms) do
		assert(#binding == 2, "Binding forms must have 2 elements")
		local bindstr, _ = defval(unpack(binding))
		table.insert(bindstrings, bindstr)
	end
	local bound = table.concat(bindstrings, "; ")
	local body  = fun.totable(fun.tail(form))
	body._type = "list"
	
	return ('(function() %s; %s end)()'):format(bound, gen(body)), true
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
		local rest = gen(ast.make_list(fun.totable(fun.tail(form))))
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

builtins._ADD_    = op '+'
builtins._STAR_   = op '*'
builtins._DIV_    = op '/'
builtins._AND_    = op ' and '
builtins._OR_     = op ' or '
builtins.mod      = op '%'
builtins._EQ_     = op '=='
builtins.not_EQ_  = op '~='
builtins._LT_     = op '<'
builtins._GT_     = op '>'
builtins._LT__EQ_ = op '<='
builtins._GT__EQ_ = op '>='

function builtins._NOT_(body)
	assert(#body == 1, "Not takes a single expression")
	return ("(not %s)"):format(gen(body[1]))
end

function builtins.table(body)
	local alist = AList.from_flat(body)
	local pairs = {}
	fun.each(function(pair)
		if pair ~= nil then
			local k, v = pair:car(), pair:cdr()
			table.insert(pairs, ("[%s] = %s"):format(gen(k), gen(v)))
		end
	end, alist)

	return ("{%s}"):format(table.concat(pairs, ","))
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
	return body[1]:_quote()
end

return function(_concat, _gen)
	concat, gen = _concat, _gen
	return builtins
end
