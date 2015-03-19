describe("lists", function()
	local list = require 'lib.list'
	it("can be made from luafun iterables", function()
		assert.are.same(
		list.from{1, 2, 3},
		list.cons(1, list.cons(2, list.cons(3, nil))))
	end)
end)

describe("alists", function()
	local fun = require 'lib.fun'
	local list = require 'lib.list'
	local alist = require 'lib.alist'
	local inspect = require 'lib.inspect'
	it("can be constructed", function()
		local lref = list.list(
			list.cons('a', 1),
			list.cons('b', 2),
			list.cons('c', 3)
		)
		local l1 = alist.from(fun.zip({'a', 'b', 'c'}, {1, 2, 3}))
		local l2 = alist.alist('a', 1, 'b', 2, 'c', 3)
		assert.are.equal(lref, l1)
		assert.are.equal(lref, l2)
		assert.are.equal(alist.get(lref, 'a'), 1)
		assert.are.equal(alist.get(lref, 'b'), 2)
		assert.are.equal(alist.get(lref, 'c'), 3)
	end)
end)
