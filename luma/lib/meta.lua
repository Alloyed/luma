-- A wrapper over get/setmetatable that allows for function metatables
-- TODO: provide a way to write luma without these wrappers

local _FN_REGISTRY = setmetatable({}, {__mode = 'kv'})

local MT = {}

local setmetatable_orig = setmetatable
function MT.setmetatable(o, mt)
	if type(o) == 'function' then
		_FN_REGISTRY[o] = mt
	else
		setmetatable_orig(o, mt)
	end
	return o
end

local getmetatable_orig = getmetatable
function MT.getmetatable(o)
	if type(o) == 'function' then
		return _FN_REGISTRY[o]
	end
	return getmetatable_orig(o)
end

local type_orig = type
function MT.type(o)
	local mt = getmetatable(o)
	return mt and mt._type or type_orig(o)
end

function MT.docstring(o)
	local mt = MT.getmetatable(o)
	return mt and mt._docstring
end

return MT