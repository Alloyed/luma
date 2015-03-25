local KEYWORD_REGISTRY = setmetatable({}, {__mode = 'kv'})

local kw = {}

function kw.tostring(o)
	return o.key
end

local mt = {
	__tostring = kw.tostring,
	__call = function(o, table)
		return table[o]
	end
}

local function new_keyword(s)
	local new = setmetatable({key=s}, mt)
	KEYWORD_REGISTRY[s] = new
	return new
end

function kw.keyword(s)
	return KEYWORD_REGISTRY[s] or new_keyword(s)
end

function kw.is_keyword(o)
	return o.key and KEYWORD_REGISTRY[o.key] ~= nil
end

return kw
