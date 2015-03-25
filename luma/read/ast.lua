local List    = require 'luma.lib.list'
local ast = {}

local function sexp_q()
	error("TODO")
end

function ast.make_sexp(tbl)
	local l = List.from(tbl)
	l._type = 'sexp'
	return l
end

local function list_q(l)
	error("lists are broken")
end

function ast.make_list(tbl)
	local l = {_type = 'sexp', List.from(tbl)}
	tbl._type = 'list'
	return tbl
end

local function symbol_repr(self)
	return self[1]
	:gsub('^and$', "_AND_")
	:gsub('^or$',  "_OR_")
	:gsub('^xor$', "_XOR_")
	:gsub('^not$', "_NOT_")
	:gsub('^-$',   "_SUB_")
	:gsub("-",     "_")
	:gsub("%?",    "_QMARK_")
	:gsub("%!",    "_BANG_")
	:gsub("+",     "_ADD_")
	:gsub("*",     "_STAR_")
	:gsub("/",     "_DIV_")
	:gsub("=",     "_EQ_")
	:gsub("<",     "_LT_")
	:gsub(">",     "_GT_")
end

local function symbol_eq(a, b)
	return b._type == 'symbol' and a[1] == b[1]
end

local function symbol_q(sym)
	return ("ast.make_symbol(%q)"):format(sym[1])
end

-- TODO: intern symbols
function ast.make_symbol(str)
	local t = {_type = 'symbol', _quote = symbol_q, str}
	setmetatable(t, {__tostring = symbol_repr,
	                 __eq       = symbol_eq})
	return t
end

local function string_repr(self)
	return ("%q"):format(self[1])
end

local function str_q(s)
	return ("ast.make_str(%q)"):format(s[1])
end

function ast.make_str(str)
	local t = {_type = 'string', _quote = str_q, str}
	setmetatable(t, {__tostring = string_repr})
	return t
end

function ast.make_kw(s)
	return ast.make_sexp {ast.make_symbol'keyword', ast.make_str(s)}
end

local function num_repr(self)
	return tostring(self[1])
end

local function num_q(n)
	return ("ast.make_num(%f)"):format(n[1])
end

function ast.make_num(str)
	local t = {_type = 'number', _quote = num_q, tonumber(str)}
	setmetatable(t, {__tostring = num_repr})
	return t
end

local function newline_repr()
	return "\n"
end

function ast.make_newline()
	local t = {_type = 'newline'}
	--setmetatable(t, {__tostring = newline_repr})
	return t
end

local function list_walk(expr)
	return expr
	--[[
	local done = {_type = expr._type}
	for _, v in ipairs(expr) do
		if v._type == 'newline' then
			if #done > 0 then
				done[#done]._nl = true
			else
			end
		elseif v._type == 'list'  or v._type == 'sexp' then
			table.insert(done, list_walk(v))
		else
			table.insert(done, v)
		end
	end
	return done
	--]]
end

function ast.tag_ast(expr)
	return list_walk(expr)
end

return ast
