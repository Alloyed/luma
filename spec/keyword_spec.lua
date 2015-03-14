local kw = require('lib.keyword').keyword
describe("keywords", function()
	it("is equal iff the keyword string is the same", function()
		assert.are.equal(kw('a'), kw('a'))
		assert.are.equal(kw('b'), kw('b'))
		assert.are_not.equal(kw('a'), kw('b'))
		local a = kw('a')
		local a2 = a
		assert.are.equal(a, a2)
	end)
end)
