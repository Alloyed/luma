local ast = require 'luma.read.ast'
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
	error(state.msg, 3)
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
	local number_float =
		(number_sign * digit^1 * P'.' * digit^0 + P'.' * digit^1) *
		(S'eE' * number_sign * digit^1)^-1

	return number_hexadecimal +
	       number_float +
	       number_decimal
end

local function lstring_pat()
	local quote = P'"""'
	local capture = C((1 - quote) ^ 0)
	return quote * capture * (quote + Err "Unterminated long string")
end

local function string_pat()
	local quote = P'"'
	local capture = C(((1 - S "\"\r\n\f\\") + (P"\\" * 1)) ^ 0)
	return quote * capture * ('"' + Err "Unterminated string")
end

local function symbol_pat()
	local special_symbols = P"..."
	local illegal_start = pre.digit + pre.space + S"()[]{}\\\"\';:.,"
	local illegal_body  = pre.space + S"()[]{}/\\\"\';,"
	local symbol = (pre.print - illegal_start) * (pre.print - illegal_body)^0

	return special_symbols + symbol
end

local function method_pat()
	local illegal_body  = pre.space + S"()[]{}/\\\"\';:.,"
	return P'.' * (pre.print - illegal_body)^0
end

local function keyword_pat()
	return P":" * C(symbol_pat())
end

local function lpeg_reader(raw_str)
	local space              = pre.space
	local ows                = space ^ 0
	local ws                 = space ^ 1
	local lparen, rparen     = P"(", P")"
	local lbracket, rbracket = P"[", P"]"
	local lbrace, rbrace     = P"{", P"}"

	local grammar = P{ 'toplevel',
		toplevel = Ct(V'atoms') / ast.make_list,
		sexp     = lparen *
		           Ct(V'atoms') / ast.make_sexp *
		           (rparen + Err "Unmatched paren"),
		vexp     = lbracket *
		           Ct(V'atoms') / ast.make_vexp *
		           (rbracket + Err "Unmatched bracket"),
		cexp     = lbrace *
		           Ct(V'atoms') / ast.make_cexp *
		           (rbrace + Err "Unmatched brace"),
		atoms    = (ows * V'atom' * ows)^1 + Cc(nil),
		atom     = V'lstring' + V'string' + V'comment' +
		           V'q_atom'  + V'sexp'   + V'vexp'    + V'cexp' +
		           V'num'     + V'symbol' + V'method'  +  V'keyword',
		q_atom   = (P"'" * V'atom') / ast.make_quote,
		comment  = P';' * P((1 - S"\r\n") ^ 0) * P'\n',
		lstring  = lstring_pat() / ast.make_lstr,
		string   = string_pat()  / ast.make_str,
		num      = number_pat()  / ast.make_num,
		keyword  = keyword_pat() / ast.make_keyword,
		symbol   = symbol_pat()  / ast.make_symbol,
		method   = method_pat()  / ast.make_mcall,
	}

	local err = {}
	local tree = assert(L.match(grammar, raw_str, 1, err))
	return tree
end

local function read(s)
	local ok, err_or_ast = pcall(lpeg_reader, s)
	if not ok then
		print(err_or_ast)
		return nil, err_or_ast
	end

	return err_or_ast
end

return read
