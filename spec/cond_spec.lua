require 'spec.run'

describe("if statements", function()
	it("can have atoms as predicates", function()
		assert.is.equal(run '(if true "a" "b")',  "a")
		assert.is.equal(run '(if false "a" "b")', "b")
	end)
	it("takes at most three args", function()
		run "(if true true)"
		run "(if true false true)"
		assert.has_errors(function() run [[
			(if true true false false)
		]] end)
	end)
	it("can be placed after function calls", function()
		run '(identity "hi") (if true false true)'
	end)
end)
