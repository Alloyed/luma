-- TODO: this is totally gross.
local List = require 'luma.lib.list'
local fun = require 'luma.lib.fun'
local symbol = require 'luma.lib.symbol'
local ast = {}

function ast.quote(o)
	if type(o) == 'table' and o._quote then
		return o:_quote()
	elseif type(o) == 'string' then
		return ("%q"):format(o)
	end
	return tostring(o)
end

local function sexp_q(o)
	local t = {}
	fun.each(function(v)
		table.insert(t, ast.quote(v))
	end, o)

	-- FIXME: return lists, not make_sexps
	return ("ast.make_sexp{%s}"):format(table.concat(t, ", "))
end

function ast.make_sexp(tbl)
	local l = List.from(tbl)
	l._type = 'sexp'
	l._quote = sexp_q
	return l
end

local function list_q(o)
	local t = {}
	fun.each(function(v)
		table.insert(t, raw_quote())
	end, o)

	return ("ast.make_list{%s}"):format(table.concat(t, ", "))
end

function ast.make_list(tbl)
	local l = {_type = 'sexp', List.from(tbl)}
	tbl._type = 'list'
	tbl._quote = list_q
	return tbl
end

function ast.make_symbol(str)
	return symbol.symbol(str)
end

function ast.make_keyword(str)
	return symbol.keyword(':' .. str)
end

function ast.make_quote(...)
	local l = {ast.make_symbol'quote', ...}

	return ast.make_sexp(l)
end

local control_seqs = {
	a='\a', b='\b', f='\f', n='\n', r='\r', t='\t',
	v='\v', ['\\']='\\', ['\"']='\"', ['\'']='\''
}

-- FIXME: lua also takes decimal sequeneces
local function str_unescape(s)
	local r = string.gsub(s, "\\(.)", control_seqs)
	return r
end

function ast.make_str(str)
	return str_unescape(str)
end

function ast.make_num(str)
	return tonumber(str)
end

function ast.tag_ast(expr)
	return expr
end

return ast
