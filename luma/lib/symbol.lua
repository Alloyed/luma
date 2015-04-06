local SYMBOL_REGISTRY = setmetatable({}, {__mode = 'kv'})

local function register_symbol(sym)
	assert(SYMBOL_REGISTRY[sym.key] == nil)
	SYMBOL_REGISTRY[sym.key] = sym
	return sym
end

local function symbol_mangle(self)
	return self
	:gsub('^and$',     "_AND_")
	:gsub('^or$',      "_OR_")
	:gsub('^xor$',     "_XOR_")
	:gsub('^not$',     "_NOT_")
	:gsub("^repeat$",  "_REPEAT_")
	:gsub("^until$",   "_UNTIL_")
	:gsub("^do$",      "_DO_")
	:gsub("^while$",   "_WHILE_")
	:gsub("^for$",     "_FOR_")
	:gsub("^end$",     "_END_")
	:gsub('^-$',       "_SUB_")
	:gsub("-",         "_")
	:gsub("%?",        "_QMARK_")
	:gsub("%!",        "_BANG_")
	:gsub("+",         "_ADD_")
	:gsub("*",         "_STAR_")
	:gsub("/",         "_DIV_")
	:gsub("=",         "_EQ_")
	:gsub("<",         "_LT_")
	:gsub(">",         "_GT_")
end

local symbol = {}

local sym_mt = {}
function sym_mt.__tostring(s) return s.key end

function symbol.symbol(raw_s)
	local s = symbol_mangle(raw_s) -- FIXME: mangle when lua needs the symbols, not before
	return SYMBOL_REGISTRY[s] or register_symbol(setmetatable({key = s, _type = "symbol"}, sym_mt))
end

local kw_mt = {}
function kw_mt.__tostring(o)
	return "keyword('" .. o.key .. "')"
end

function kw_mt.__call(o, table)
	return table[o]
end

function symbol.keyword(s)
	assert(s:match("^:"), "Keywords begin with ':'")
	return SYMBOL_REGISTRY[s] or register_symbol(setmetatable({key = s, _type = "keyword"}, kw_mt))
end

return symbol
