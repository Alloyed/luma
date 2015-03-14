inspect = require 'lib.inspect'
reader  = require 'reader'
gen     = require 'gen'

function add(...)
	local s = 0
	for _, v in ipairs {...} do
		s = s + v
	end
	return s
end

local function test(str)
	local t = str
	print("RAW", t)
	t = reader(t)
	print("AST", inspect(t))
	t = gen(t)
	print("GEN", ("%q"):format(t))
	print("EVAL")
	local f = assert(loadstring(t))
	if f then
		print(f())
	end
end

test [[
(let ((a 5) (b 6)) (+ a b))
]]
