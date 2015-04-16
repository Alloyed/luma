describe("list", function()
	local fun  = require 'luma.lib.fun'
	local list = require 'luma.lib.list'

	it("implements (from)", function()
		assert.are.same(
			list.from{1, 2, 3},
			list.cons(1, list.cons(2, list.cons(3, nil))))
	end)
	it("implements (get)", function()
		assert.is.equal(list.get(list.from{6, 7, 8}, 2), 7)
	end)
	it("implements (conj)", function()
		assert.are.same(
			fun.totable(list.conj(list.from{2, 3, 4}, 1)),
			{1, 2, 3, 4})
	end)
	it("implements (assoc)", function()
		local old = list.from{1, 2, 3, 4}
		assert.are.same(
			fun.totable(list.assoc(old, 1, 10)),
			{10, 2, 3, 4})
		assert.are.same(
			fun.totable(list.assoc(old, 3, 10)),
			{1, 2, 10, 4})
		assert.are.same(
			fun.totable(old),
			{1, 2, 3, 4})
	end)
	it("implements (assoc!)", function()
		local old = list.from{1, 2, 3, 4}
		assert.are.same(
			fun.totable(list.assocb(old, 1, 10)),
			{10, 2, 3, 4})
		assert.are.same(
			fun.totable(old),
			{10, 2, 3, 4})
		assert.are.same(
			fun.totable(list.assocb(old, 3, 10)),
			{10, 2, 10, 4})
		assert.are.same(
			fun.totable(old),
			{10, 2, 10, 4})
	end)
end)

describe("alists", function()
	local fun     = require 'luma.lib.fun'
	local list    = require 'luma.lib.list'
	local alist   = require 'luma.lib.alist'
	local inspect = require 'inspect'

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
