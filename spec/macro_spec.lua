require 'luma.lib.prelude'

local function run(s)
	local f, err = s_loadstring(s)
	assert(f, err)
	return f()
end

describe("Quotes", function()
	it("work with numbers", function()
		assert.is.equal(run "(quote 7)", 7)
		assert.is.equal(run "(quote 1.0)", 1.0)
		assert.is.equal(run "(quote 0.0)", 0)
		assert.is.equal(run "(quote 10.2)", 10.2)
		assert.is.equal(run "(quote -10.2)", -10.2)
	end)
end)

describe("Macros", function()
end)
