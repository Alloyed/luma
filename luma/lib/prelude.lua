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

function s_loadexpr(expr, chunk)
	local lua = gen(expr)
	return loadstring(lua, chunk)
end

function s_loadfile()
	error("TODO")
end

