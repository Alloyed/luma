local kw = require('luma.lib.keyword').keyword

require 'luma.lib.prelude'

local function run(s)
	local f, err = s_loadstring(s)
	assert(f, err)
	return f()
end

describe("keywords", function()
	it("is equal iff the keyword string is the same", function()
		assert.are.equal(kw('a'), kw('a'))
		assert.are.equal(kw('b'), kw('b'))
		assert.are_not.equal(kw('a'), kw('b'))
		local a  = kw('a')
		local a2 = a
		assert.are.equal(a, a2)
	end)
	it("can be read in using :kw", function()
		run[[ (assert (= :my-keyword (keyword "my-keyword"))) ]]
		run[[ (assert (not= :my-keyword :your-keyword)) ]]
		run[[ (assert (not= :my-keyword (keyword "your-keyword"))) ]]
	end)
end)
