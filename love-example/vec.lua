local mt = {}

local function new(a, b)
	return setmetatable({a, b}, mt)
end

function mt.__add(a, b)
	return new(a[1] + b[1], a[2] + b[2])
end

function mt.__sub(a, b)
	return new(a[1] - b[1], a[2] - b[2])
end

function mt.__mul(a, sc)
	return new(a[1] * sc, a[2] * sc)
end

function mt.__tostring(s)
	return ("(%g, %g)"):format(unpack(s))
end

return new
