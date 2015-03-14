local reader = require 'core.reader'
local gen = require 'core.gen'

local function run(str)
	return loadstring(gen(reader(str))) ()
end

describe("Numbers and Arithmetic", function()
	it("adds", function()
		assert.are.equal(run("(+ 2 2)"), 4)
		assert.are.equal(run("(+ 2 2 0.5)"), 4.5)
		assert.are.equal(run("(+ 2)"), 2)
	end)
	it("subtracts", function()
		assert.are.equal(run("(- 4 1)"), 3)
		assert.are.equal(run("(- 10.5 .25 1)"), 9.25)
		assert.are.equal(run("(- 2)"), -2)
	end)
	it("multiplies", function()
		assert.are.equal(run("(* 4 3)"), 12)
		assert.are.equal(run("(* 10 .5 .5)"), 2.5)
		assert.are.equal(run("(* 2)"), 2)
	end)
	it("divides", function()
		assert.are.equal(run("(/ 12 3)"), 4)
		assert.are.equal(run("(/ 10 2 2)"), 2.5)
		assert.are.equal(run("(/ 2)"), 2)
	end)
end)
