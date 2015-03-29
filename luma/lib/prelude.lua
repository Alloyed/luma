local _LUMA_VERSION = "Luma v0.1-snapshot"

if not _LOADED then
	_LOADED = true
	local core = require('luma.lib.core')
	for k, v in pairs(core) do
		_G[k] = v
	end
end

local reader = require 'luma.read'
local gen = require 'luma.compile'

function s_loadstring(s, chunk)
	local ast = reader(s)
	return s_loadexpr(ast, chunk)
end

function s_compilestring(s)
	local ast = reader(s)
	return "require 'luma.lib.prelude'; " .. gen(ast)
end

function s_loadexpr(expr, chunk)
	local lua = gen(expr)
	return loadstring(lua, chunk)
end

function s_loadfile(fname)
	local f = io.open(fname, "r")
	local s = f:read('*a')
	f:close()
	return s_loadstring(s, fname)
end

function s_compilefile(fname)
	local f = io.open(fname, 'r')
	local s = f:read('*a')
	f:close()

	local res, err = s_compilestring(s)
	assert(res, err)

	local w = io.open(string.gsub(fname, "%.luma$", ".lua"), 'w')
	w:write(res)
	w:close()

	return true
end

