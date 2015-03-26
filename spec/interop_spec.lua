require 'luma.lib.prelude'

local function run(s)
	return s_loadstring(s) ()
end

describe("Lua tables", function()
	it("Can be accessed using dot-syntax", function()
		_G.a = { b = { c = "hi", fn = function() return "bye" end } }
		assert.is.equal(run "a.b.c", "hi")
		assert.is.equal(run "(a.b.fn)", "bye")
		_G.a = nil
	end)

	it("Can have methods defined using colon-syntax", function()
		assert.is.equal(run [[
			(define a (table :wat 2))
			(define (a:fn) (+ (:wat self) 1))
			(a.fn a)
		]], 3)
	end)

	it("Can use methods with colon-syntax", function()
		assert.is.equal(run [[
			(define a (table :wat 2))
			(define (a:fn) (+ (:wat self) 2))
			(a:fn)
		]], 4)
	end)

end)
