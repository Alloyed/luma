require 'spec.run'

describe("Functions", function()
	it("can be made", function()
		assert.is.equal(run "(type (lambda (_) nil))", "function")
		assert.are.equal(run "((lambda (x) (+ x 10)) 10)", 20)
	end)
	it("has a (define) syntax", function()
		assert.are.equal(run "(define (f x) (+ x 10)) (type f)", "function")
		f = nil
		assert.are.equal(run "(define (f x) (+ x 10)) (f 10)", 20)
		f = nil
	end)
	it("can recur from a (define)", function()
		assert.has_errors(function() run [[
		(define fib (lambda (n)
		  (if (<= n 2)
		    1
		    (+ (fib (- n 1)) (fib (- n 2))))))
		(fib 5)]] end)
		fib = nil
		assert.are.equal(run [[
		(define (fib n)
		  (if (<= n 2)
		    1
		    (+ (fib (- n 1)) (fib (- n 2)))))
		(fib 10)]], 55)
	end)
	it("Has a vararg syntax", function()
		assert.are.equal(run [[
		(define (varadd ...)
		  (apply + (list ...)))
		(varadd 1 2 3)]],
		run [[ (+ 1 2 3) ]])
		assert.are.equal(run [[
		((lambda (f ...) (apply f (list ...))) + 1 2 3)]],
		run [[ (+ 1 2 3) ]])
	end)
end)
