require 'luma.lib.prelude'

describe("(identity)", function()
	assert.is.equal(identity(1), 1)
	assert.is.equal(identity(2), 2)
	local t = {identity("a", "b", "c")}
	assert.are.same(t, {"a", "b", "c"})
	local f = {}
	assert.is.equal(identity(f), f)
end)

describe("(doall)", function()
	local old = { 4, 3, 5, 1 }
	local new = {}
	doall(map(function(i) table.insert(new, i) end, old))
	assert.are.same(new, old)
end)

describe("(partial)", function()
	assert.is.equal(partial(_ADD_, 3) (4),    _ADD_(3, 4))
	assert.is.equal(partial(_ADD_, 3) (4, 5), _ADD_(3, 4, 5))
	assert.is.equal(partial(_ADD_, 3, 4) (5), _ADD_(3, 4, 5))
end)

describe("(apply)", function()
	assert.is.equal(apply(_ADD_, {3, 4}),      _ADD_(3, 4))
	assert.is.equal(apply(_ADD_, {3}, {4}),    _ADD_(3, 4))
	assert.is.equal(apply(_ADD_, {3, 4}, {5}), _ADD_(3, 4, 5))
	assert.is.equal(apply(_ADD_, {3}, {4, 5}), _ADD_(3, 4, 5))
end)

describe("(comp)", function()
end)

describe("(mapcat)", function()
end)

describe("(get)", function()
	t = { a = 1, b = 2, [1] = 3 }
	assert.is.equal(get(t, 'a'), t.a)
	assert.is.equal(get(t, 'b'), t.b)
	assert.is.equal(get(t, 1), t[1])
end)
