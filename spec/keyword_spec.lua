local kw = require('lib.keyword').keyword

local reader = require 'core.reader'
local gen = require 'core.gen'

require 'lib.luma.core'

local function run(str, print_compiled)
	local t = reader(str)
	t = gen(t)
	if print_compiled then
		print(t)
	end
	local f, err = loadstring(t)
	assert(f ~= nil, t)
	return f()
end

describe("keywords", function()
	it("is equal iff the keyword string is the same", function()
		assert.are.equal(kw('a'), kw('a'))
		assert.are.equal(kw('b'), kw('b'))
		assert.are_not.equal(kw('a'), kw('b'))
		local a = kw('a')
		local a2 = a
		assert.are.equal(a, a2)
	end)
	it("can be read in using :kw", function()
		run[[ (assert (= :my-keyword (keyword "my-keyword"))) ]]
		run[[ (assert (not= :my-keyword :your-keyword)) ]]
		run[[ (assert (not= :my-keyword (keyword "your-keyword"))) ]]
	end)
end)
