-- makes a copy of table tbl from s to e.
-- TODO : write a COW variant
function table.slice(tbl, s, e, step)
	local r = {}
	s = s or 1
	e = e or #tbl
	for i = s, e do
		r[i] = tbl[i]
	end
	return r
end
