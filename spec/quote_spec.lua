require 'spec.run'

describe("(quote)", function()
	it("does nothing to numbers", function()
		assert.are.equal(run "(quote 10)",
		                 10)
		assert.are.equal(run "(quote 10.5)",
		                 10.5)
		assert.are.equal(run "(quote -10.5)",
		                 -10.5)
	end)
	it("does nothing to strings", function()
		assert.are.equal(run '(quote "foo")',
		                 run '"foo"')
		assert.are.equal(run [[(quote "yo\nyo")]],
		                 run [["yo\nyo"]])
	end)
	it("does nothing to keywords/symbols", function()
		assert.are.equal(run "(quote :foo)",
		                 run ":foo")
		assert.are.equal(run "(quote foo)",
		                 run '(symbol "foo")')
	end)
	it("It returns lists verbatim", function()
		assert.are.equal(run "(quote (1 2 3))",
		                 run "(list 1 2 3)")
		assert.are.equal(run '(quote (sym "quote" 3))',
		                 run '(list (quote sym) "quote"  3)')
	end)
	it("produces eval-able output", function()
	end)
end)
