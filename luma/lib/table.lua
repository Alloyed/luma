local mt     = {_LUMA_TABLE = true}
local xtable = setmetatable({}, mt)

local old_mt = getmetatable(table)
if old_mt and old_mt._LUMA_TABLE then
	return table
end

for k, v in pairs(table) do
	xtable[k] = v
end

function xtable.from(...)
	return fun.totable(...)
end

function xtable.table(...)
	local t = {}
	for i=1, select('#', ...), 2 do
		t[select(i, ...)] = select(i + 1, ...)
	end
	return t
end

function xtable.array(...)
	local a = {}
	for i=1, select('#', ...) do
		a[i] = select(i, ...)
	end
	return a
end

mt.__call = function(self, ...) return xtable.table(...) end

function xtable.get(t, k)
	return t[k]
end

function xtable.assocb(t, k, v)
	t[k] = v
	return t
end

return xtable
