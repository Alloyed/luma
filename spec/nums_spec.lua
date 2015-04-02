require 'spec.run'

describe("Numbers", function()
	it("add", function()
		assert.are.equal(run("(+ 2 2)"), 4)
		assert.are.equal(run("(+ 2 2 0.5)"), 4.5)
		assert.are.equal(run("(+ 2)"), 2)
		assert.are.equal(run'(apply + (list 1 2))', 3)
	end)
	it("subtract", function()
		assert.are.equal(run("(- 4 1)"), 3)
		assert.are.equal(run("(- 10.5 .25 1)"), 9.25)
		assert.are.equal(run("(- 2)"), -2)
		assert.are.equal(run'(apply - (list 7 4))', 3)
	end)
	it("multiply", function()
		assert.are.equal(run("(* 4 3)"), 12)
		assert.are.equal(run("(* 10 .5 .5)"), 2.5)
		assert.are.equal(run("(* 2)"), 2)
		assert.are.equal(run'(apply * (list 2 3))', 6)
	end)
	it("divide", function()
		assert.are.equal(run("(/ 12 3)"), 4)
		assert.are.equal(run("(/ 10 2 2)"), 2.5)
		assert.are.equal(run("(/ 2)"), 2)
		assert.are.equal(run'(apply / (list 10 5))', 2)
	end)
	it("are less than", function()
		assert.is_true(run'(< 1 2)')
		assert.is_not_true(run'(< 10 10)')
		assert.is_not_true(run'(< 10 5)')
	end)
	it("are greater then", function()
		assert.is_true(run'(> 2 1)')
		assert.is_not_true(run'(> 10 10)')
		assert.is_not_true(run'(> 5 10)')
	end)
	it("are less than/equal to", function()
		assert.is_true(run'(<= 1 2)')
		assert.is_true(run'(<= 10 10)')
		assert.is_not_true(run'(<= 10 5)')
	end)
	it("are greater than/equal to", function()
		assert.is_true(run'(>= 2 1)')
		assert.is_true(run'(>= 10 10)')
		assert.is_not_true(run'(>= 5 10)')
	end)
end)
