local _LUMA_VERSION = "Luma v0.1-snapshot"

if not _LUMA_LOADED then
	_LUMA_LOADED = true
	local core = require('luma.lib.core')
	for k, v in pairs(core) do
		_G[k] = v
	end
end

local read    = require 'luma.read'
local compile = require 'luma.compile'

-- TODO: should we namespace these? maybe namespace the original lua ones?
function s_loadstring(s, chunk)
	local ast = read(s)
	return s_loadexpr(ast, chunk)
end

function s_compilestring(s)
	local ast = read(s)
	return "require('luma.lib.prelude'); " .. compile(ast)
end

function s_loadexpr(expr, chunk)
	local lua = compile(expr)
	return loadstring(lua, chunk)
end

local function eat_file(fname)
	local f = io.open(fname, 'r')
	local s = f:read('*a')
	f:close()

	return s
end

function s_loadfile(fname)
	return s_loadstring(eat_file(fname), fname)
end

function s_compilefile(fname)
	local res, err = s_compilestring(eat_file(fname))
	assert(res, err)

	local w = io.open(string.gsub(fname, "%.luma$", ".lua"), 'w')
	w:write(res)
	w:close()

	return true
end

