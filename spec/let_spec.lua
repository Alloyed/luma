local reader = require 'core.reader'
local gen = require 'core.gen'

local function run(str)
	local t = reader(str)
	t = gen(t)
	local f, err = loadstring(t)
	assert(f ~= nil, t)
	return f()
end

describe("(let)", function()
	it("binds one var", function()
		assert.has.no.errors(function()
			run "(let ((a 2)) (assert (= a 2)))"
		end)
		assert.has.errors(function()
			run "(let ((a 2))) (assert (= a 2))"
		end)
	end)
	it("binds with nested lets", function()
		assert.has.no.errors(function()
			run [[
			(let ((a 1))
			  (let ((b 2))
			    (assert (and (= a 1) (= b 2))))
			  (assert (and (= a 1) (= b nil))))
			(assert (and (= a nil) (= b nil)))
			]]
		end)
	end)
	it("captures values in lambdas", function()
		assert.has.no.errors(function()
			run [[
			(define fun
			  (let ((a 1))
			    (lambda (_) a)))
			(assert (= 1 (fun)))
			]]
		end)
	end)
end)
