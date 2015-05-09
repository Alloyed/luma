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

-- an interesting tidbit on the introspectable bits of clojure
-- (doc) - prints the docstring for a var given it's name
-- (find-doc) - prints the docstring for a var that matches a pattern
-- (apropos) - return vars whose name matches a regex
-- (source) - print the source of a var
-- (pst) - print a stack trace
function MT.docstring(o, s)
	local mt = MT.getmetatable(o)
	if s then
		mt = mt or {}
		mt._docstring = s
		MT.setmetatable(o, mt)
	end
	return mt and mt._docstring
end

return MT
