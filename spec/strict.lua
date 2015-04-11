local mt = getmetatable(_G)

if mt == nil then
	mt = {}
	setmetatable(_G, mt)
end

function mt.__newindex(t, k, v)
	return rawset(t, k, v)
end
