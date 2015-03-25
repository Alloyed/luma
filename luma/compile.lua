local fun              = require 'luma.lib.fun'
local ast              = require 'luma.read.ast'
local builtins_factory = require 'luma.compile.builtins'
local gen              = nil
local builtins         = nil

local function concat(tbl, sep)
	local tmp = {}
	for i, v in ipairs(tbl) do
		tmp[i] = gen(v)
	end
	return table.concat(tmp, sep)
end

local function fcall(sexp)
	local name = fun.head(sexp)
	local args = fun.totable(fun.tail(sexp))
	local builtin = builtins[tostring(name)]
	if builtin then
		return builtin(args)
	else
		return gen(name) .. ("(%s)"):format(concat(args, ","))
	end
end

local function isprimitive(tbl)
	local t = tbl._type
	return t == 'number' or
	       t == 'string' or
	       t == 'symbol' or
	       t == 'newline'
end

local function exprlist(expr)
	local res = ""
	for i=1,#expr-1 do
		local sep = expr[i]._nl and "" or "; "
		res = res .. gen(expr[i]) .. sep
	end
	local last, isStatement = gen(expr[#expr])
	return res .. (isStatement and "" or "return ") .. last
end

function gen(expr)
	if expr == nil then
		return ""
	end
	local t = expr._type
	local mt = getmetatable(expr)
	local s, isStatement
	if t == 'list' then
		s, isStatement = exprlist(expr)
	elseif t == 'sexp' then
		s, isStatement = fcall(expr)
	elseif isprimitive(expr) then
		s, isStatement = tostring(expr)
	elseif t == nil and type(expr) == 'string' then
		s = expr
	else
		assert(nil,
		("unimplemented expr type %q, %q")
		:format(tostring(t), tostring(expr)))
	end
	if expr._nl then
		return s .. "\n", isStatement
	else
		return s, isStatement
	end
end

builtins = builtins_factory(concat, gen)
return gen
