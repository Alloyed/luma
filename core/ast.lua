local inspect = require 'lib.inspect'
local ast = {}

local function pr_list(as)
	print("{" .. table.concat(as, ",") .. "}")
end

local function repr_sexp(sexp)
	assert(sexp._type == 'sexp')
	local t = {}
	for i, v in ipairs(sexp) do
		t[i] = tostring(v)
	end
	return "(" .. table.concat(t, " ") .. ")"
end

function ast.make_sexp(tbl)
	tbl._type = 'sexp'
	--setmetatable(tbl, {__tostring = repr_sexp})
	return tbl
end

local function repr_list(sexp)
	assert(sexp._type == 'list')
	local t = {}
	for i, v in ipairs(sexp) do
		t[i] = tostring(v)
	end
	return "'(" .. table.concat(t, " ") .. ")"
end

function ast.make_list(tbl)
	tbl._type = 'list'
	--setmetatable(tbl, {__tostring = repr_list})
	return tbl
end

local function symbol_repr(self)
	return self[1]
	:gsub('^and$', "_AND_")
	:gsub('^or$', "_OR_")
	:gsub('^xor$', "_XOR_")
	:gsub('^not$', "_NOT_")
	:gsub('^-$', "_SUB_")
	:gsub("-","_")
	:gsub("%?", "_QMARK_")
	:gsub("%!","_BANG_")
	:gsub("+", "_ADD_")
	:gsub("*", "_STAR_")
	:gsub("/", "_DIV_")
end

local function symbol_eq(a, b)
	return b._type == 'symbol' and a[1] == b[1]
end

function ast.make_symbol(str)
	local t = {_type = 'symbol', str}
	setmetatable(t, {__tostring = symbol_repr,
                     __eq       = symbol_eq})
	return t
end

local function string_repr(self)
	return ("%q"):format(self[1])
end

function ast.make_str(str)
	local t = {_type = 'string', str}
	setmetatable(t, {__tostring = string_repr})
	return t
end

local function num_repr(self)
	return tostring(self[1])
end

function ast.make_num(str)
	local t = {_type = 'number', tonumber(str)}
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
end

function ast.tag_ast(expr)
	return list_walk(expr)
end

return ast
