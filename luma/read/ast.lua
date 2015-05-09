-- TODO: this is totally gross.
local List = require 'ltrie.list'
local fun = require 'ltrie.fun'
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

function ast.make_sexp(...)
	local l = List.from(...)
	l._type = 'sexp'
	l._quote = sexp_q
	return l
end

function ast.make_vexp(...)
	return ast.make_sexp{ast.make_symbol'array', unpack(...)}
end

function ast.make_cexp(...)
	return ast.make_sexp{ast.make_symbol'table', unpack(...)}
end

local function list_q(o)
	local t = {}
	fun.each(function(v)
		table.insert(t, ast.quote(v))
	end, o)

	return ("ast.make_list{%s}"):format(table.concat(t, ", "))
end

function ast.make_list(...)
	local l = List.from(...)
	l._type = 'list'
	l._quote = list_q
	return l
end

function ast.make_symbol(str)
	return symbol.symbol(str)
end

function ast.make_keyword(str)
	return symbol.keyword(':' .. str)
end

function ast.make_mcall(s)
	error("TODO")
end

function ast.make_quote(...)
	return ast.make_sexp{ast.make_symbol'quote', ...}
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

function ast.make_lstr(str)
	return str
end

function ast.make_num(str)
	return tonumber(str)
end

return ast
