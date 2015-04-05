require 'luma.lib.prelude'

function run(s)
	return assert(luma.loadstring(s)) ()
end
