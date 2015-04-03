-- Provides lua 5.1-5.2 compatibility where possible

if not _LUMA_51_COMPAT_PATCH then
	local ipairs_orig = ipairs
	local pairs_orig = pairs
	if _VERSION == "Lua 5.1" then
		function pairs(t)
			local mt = getmetatable(t)
			if mt and mt.__pairs then
				return mt.__pairs(t)
			else
				return pairs_orig(t)
			end
		end

		function ipairs(t)
			local mt = getmetatable(t)
			if mt and mt.__ipairs then
				return mt.__ipairs(t)
			else
				return ipairs_orig(t)
			end
		end
	end

	function len(a)
		local mt = getmetatable(a)
		if mt and mt.__len then
			return mt.__len(a)
		else
			return #a
		end
	end
end

_LUMA_51_COMPAT_PATCH = true
