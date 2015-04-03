local reader = require 'luma.read'
local gen = require 'luma.compile'

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
	it("binds multiple vars", function()
		assert.has.no.errors(function()
			run [[
			(let ((a 2)
			      (b 3)
			      (c 4))
			  (assert (= a 2))
			  (assert (= b 3))
			  (assert (= c 4)))
			]]
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
	it("is a returnable expression", function()
		assert.has.no.errors(function() run [[
		(assert (= 1 ((lambda () (let ((a 1)) a)))))
		]] end)
	end)
end)

describe("(define)", function()
	it("binds to the next highest scope", function()
		assert.has.no.errors(function()
			run [[
			(let ((a 1))
			  (define b 2)
			  (assert (= a 1))
			  (assert (= b 2)))
			(assert (= a nil))
			(assert (= b nil))]]
		end)
	end)
	it("can be used on tables", function()
		assert.has.no.errors(function()
			run [[
			(define a (table))
			(define a.b 2)
			(assert (= a.b 2))
			]]
		end)
	end)
	it("can be used to define methods", function()
		assert.has.no.errors(function()
			run [[
			(define a (table))
			(define (a:m _) self)
			(assert (= (a:m 10) a))
			]]
		end)
	end)
end)
