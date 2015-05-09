package = "Luma"
version = "scm-1"
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
	"inspect >= 3.0",
	"ltrie"
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
		["luma.lib.symbol"]       = "luma/lib/symbol.lua",
		["luma.lib.compat51"]     = "luma/lib/compat51.lua",
	},
	install = {
		bin = {"bin/luma", "bin/lumac"}
	}
}
