local _LUMA_VERSION = "Luma v0.1-snapshot"
local path    = ""

if not _LOADED then
	_LOADED = true
	package.path = path .. package.path
	require('luma.lib.core')
end

local reader = require 'luma.read'
local gen = require 'luma.compile'

function s_loadstring(s, chunk)
	local ast = reader(s)
	return s_loadexpr(ast, chunk)
end

function s_compilestring(s)
	local ast = reader(s)
	return gen(ast)
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
	w:write("require('luma.lib.prelude');" .. res)
	w:close()

	return true
end

