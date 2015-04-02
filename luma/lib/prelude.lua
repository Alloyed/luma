local _LUMA_VERSION = "Luma v0.1-snapshot"

if not _LUMA_LOADED then
	_LUMA_LOADED = true
	local core = require('luma.lib.core')
	for k, v in pairs(core) do
		_G[k] = v
	end
end

local read    = require 'luma.read'
local codegen = require 'luma.compile'

_G.luma = {}

function luma.compile(s)
	local expr, err = read(s)
	if err then return expr, err end

	local lua, err2 = codegen(expr)
	if err2 then return lua, err2 end

	return "require('luma.lib.prelude'); " .. lua
end

function luma.load(expr, chunk)
	local lua, err = codegen(expr)
	if err then return lua, err end

	return loadstring(lua, chunk)
end

function luma.loadstring(s, chunk)
	local expr, err = read(s)
	if err then return expr, err end

	return luma.load(expr, chunk)
end

function luma.eval(expr, chunk)
	local f, err = luma.load(expr, chunk)
	if err then return f, err end

	return f()
end

local function eat_file(fname)
	local f = io.open(fname, 'r')
	local s = f:read('*a')
	f:close()

	return s
end

function luma.loadfile(fname)
	return luma.loadstring(eat_file(fname), fname)
end

function luma.compilefile(fname)
	local res, err = luma.compile(eat_file(fname))
	assert(res, err)

	local w = io.open(string.gsub(fname, "%.luma$", ".lua"), 'w')
	w:write(res)
	w:close()

	return true
end

