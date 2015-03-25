-- An alternate require mechanism.
-- FIXME: don't pollute the global namespace

local R = {}

local _IMPORT_RULES = {}

local require_orig = require
function R.require(module_name)
	local luma_file = find_luma(module_name)
	if luma_file then
		s_compilefile(luma_file)
	end
	return require_orig(module_name)
end

function R.require_as(module_name, imported_name)
	local req = require(module_name)
	assert(type(req) == 'table', "Invalid module " .. module_name)
	_G[imported_name] = req

	_IMPORT_RULES[module_name] = {R.require_as, module_name, imported_name}
	return req
end

function R.require_as_is(module_name)
	return R.require_as(module_name, module_name)
end

function R.require_using(module_name, ...)
	local req = require(module_name)
	assert(type(req) == 'table', "Invalid module " .. module_name)

	for i=1, select('#', ...) do
		local v = select(i, ...)
		_G[v] = req[v]
	end

	_IMPORT_RULES[module_name] = {R.require_using, module_name, ...}
	return req
end

function R.reload(module_name)
	local rule = _IMPORT_RULES[module_name]
	assert(rule ~= nil, "Please load module before reloading: " .. module_name)

	package.loaded[module_name] = nil
	return rule[1] (unpack(fun.drop(1, rule):totable()))
end

function R.reload_all()
	local todo = {}
	for k, v in pairs(_IMPORT_RULES) do
		table.insert(todo, k)
	end

	for _, k in ipairs(todo) do
		R.reload(k)
	end
	return "OK"
end

return R
