local symbol = require 'luma.lib.symbol'
require 'spec.run'

describe("keywords", function()
	local kw = symbol.keyword
	it("is equal iff the keyword string is the same", function()
		assert.are.equal(kw(':a'), kw(':a'))
		assert.are.equal(kw(':b'), kw(':b'))
		assert.are_not.equal(kw(':a'), kw(':b'))
		local a  = kw(':a')
		local a2 = a
		assert.are.equal(a, a2)
	end)
	it("can be read in using :kw", function()
		run[[ (assert (= :my-keyword (keyword ":my-keyword"))) ]]
		run[[ (assert (not= :my-keyword :your-keyword)) ]]
		run[[ (assert (not= :my-keyword (keyword ":your-keyword"))) ]]
	end)
end)

describe("Named symbols", function()
	local sym = symbol.symbol
	it("represent a string key and are interned", function()
		local a, b, c = sym 'a', sym 'a', sym 'c'
		assert.is.equal(a, b)
		assert.is.not_equal(a, c)
	end)
end)
