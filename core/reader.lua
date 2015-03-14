local ast = require 'core.ast'
local L   = require 'lpeg'

local pre = L.locale()
local P,   C,   Cc,   Ct,   V,   S,   R,   V =
    L.P, L.C, L.Cc, L.Ct, L.V, L.S, L.R, L.V

local function loc (str, where)
	local line, pos, linepos = 0, 1, 1
	while true do
		pos = string.find (str, "\n", pos, true)
		if pos and pos < where then
			line = line + 1
			linepos = pos
			pos = pos + 1
		else
			break
		end
	end
	return "line " .. line .. ", column " .. (where - linepos)
end

local function ErrorCall (str, pos, msg, state)
	if not state.msg then
		state.msg = msg .. " at " .. loc (str, pos)
		state.pos = pos
	end
	assert(nil, state.msg)
	return false
end

local function Err (msg)
	return L.Cmt (L.Cc (msg) * L.Carg (1), ErrorCall)
end

local function number_pat()
	local digit = pre.digit
	local number_sign = S'+-'^-1
	local number_decimal = number_sign * digit ^ 1
	local number_hexadecimal = P '0' * S 'xX' * R('09', 'AF', 'af') ^ 1
	local number_float = (digit^1 * P'.' * digit^0 + P'.' * digit^1) *
	(S'eE' * number_sign * digit^1)^-1
	return number_hexadecimal +
	       number_float +
	       number_decimal
end

local function string_pat()
	local quote = P"\""
	local capture = C(((1 - S "\"\r\n\f\\") + (P"\\" * 1)) ^ 0)
	return quote * capture * (quote + Err "Unterminated quote")
end

local function symbol_pat()
	local illegal_start = pre.digit + pre.space + S"()[]{}\\\"\';:,"
	local illegal_body  = pre.digit + pre.space + S"()[]{}/\\\"\';:,"
	return (pre.print - illegal_start) * (pre.print - illegal_body)^0
end

local function reader(raw_str)
	local nl                 = P"\n"
	local space              = pre.space - nl
	local ows                = space ^ 0
	local ws                 = space ^ 1
	local lparen, rparen     = P"(", P")"
	local lbracket, rbracket = P"[", P"]"

	local grammar = P{ 'toplevel',
		toplevel = Ct(V'atoms') / ast.make_list,
		sexp     = lparen *
		           Ct(V'atoms') / ast.make_sexp *
		           (rparen + Err "Unmatched paren"),
		atoms    = (ows * V'atom' * ows)^1 + Err "Invalid atom",
		atom     = V'string'  + V'comment' +
		           V'newline' + V'sexp' +
		           V'num'     + V'symbol',
		comment  = P ';' * P((1 - S"\r\n") ^ 0) * V'newline',
		string   = string_pat() / ast.make_str,
		num      = number_pat() / ast.make_num,
		symbol   = symbol_pat() / ast.make_symbol,
		newline  = nl --/ ast.make_newline,
	}

	local err = {}
	local tree = L.match(grammar, raw_str, 1, err)
	assert(ast, "string parsed incorrectly: ".. raw_str)
	return ast.tag_ast(tree)
end

return reader
