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
	assert.is.equal(apply(_ADD_, 3, {4}),    _ADD_(3, 4))
	assert.is.equal(apply(_ADD_, 3, 4, {5}), _ADD_(3, 4, 5))
	assert.is.equal(apply(_ADD_, 3, {4, 5}), _ADD_(3, 4, 5))
end)

describe("(comp)", function()
	local function sub1(i) return i - 1 end
	assert.is.equal(comp(sub1, _ADD_) (2, 2), 3)
	assert.is.equal(comp(sub1, _ADD_) (2, 2, 2), 5)
end)

local fun = require 'luma.lib.fun'
describe("(mapcat)", function()
	assert.are.same(fun.totable(mapcat(sort,
		{{3, 1}, {4, 2}, {5, 1}})),
		{1, 3, 2, 4, 1, 5})
end)

describe("(table)", function()
	assert.are.same(table("a", 1, "b", 2), {a = 1, b = 2})
end)

describe("(array)", function()
	assert.are.same(array("a", 1, "b", 2), {"a", 1, "b", 2})
end)

describe("(get)", function()
	t = { a = 1, b = 2, [1] = 3 }
	assert.is.equal(get(t, 'a'), t.a)
	assert.is.equal(get(t, 'b'), t.b)
	assert.is.equal(get(t, 1), t[1])
end)

describe("(get-in)", function()
	t = { a = {b = 3} }
	assert.is.equal(get_in(t, {"a", "b"}), t.a.b)
end)

describe("(assoc!)", function()
	local old = {a = 2, b = 3}
	local new = assoc_BANG_(old, "a", 4)
	assert.is.equal(new, old)
	assert.is.equal(get(new, "a"), 4)
end)
