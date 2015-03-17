local reader = require 'core.reader'
local gen = require 'core.gen'
require 'lib.luma.core'

local function run(str)
	return loadstring(gen(reader(str))) ()
end

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
end)
