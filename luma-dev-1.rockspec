package = "Luma"
version = "dev-1"
source = {
	url = "..."
}

description = {
	summary = "A scheme-like language that compiles to Lua",
	detailed = [[
	]],
	homepage = "http://...",
	license = "MIT"
}

dependencies = {
	"lua >= 5.1",
	"lpeg >= 0.12",
	"argparse >= 0.3",
	"inspect >= 3.0"
}

build = {
	type = "builtin",
	modules = {
		["luma.cli"]              = "luma/cli.lua",
		["luma.read"]             = "luma/read.lua",
		["luma.read.ast"]         = "luma/read/ast.lua",
		["luma.compile"]          = "luma/compile.lua",
		["luma.compile.builtins"] = "luma/compile/builtins.lua",
		["luma.lib.prelude"]      = "luma/lib/prelude.lua",
		["luma.lib.core"]         = "luma/lib/core.lua",
		["luma.lib.fun"]          = "luma/lib/fun.lua",
		["luma.lib.list"]         = "luma/lib/list.lua",
		["luma.lib.alist"]        = "luma/lib/alist.lua",
		["luma.lib.keyword"]      = "luma/lib/keyword.lua",
	},
	install = {
		bin = {"bin/luma", "bin/lumac"}
	}
}
