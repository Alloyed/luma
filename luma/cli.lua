#!/usr/bin/env lua
local argparse = require 'argparse'
local inspect  = require 'inspect'

require 'luma.lib.prelude'

local cli = {}

local function printcall(ok, ...)
	if select('#', ...) == 0 then
		print("nil")
	else
		print(...)
	end
end

function cli.repl(f)
	local buf = ''
	print(([[
	%s
	%s
	CTRL-D to discard expression.
	CTRL-C CTRL-C to exit.
	]]):format(_LUMA_VERSION, _VERSION))
	_G._LUMA_REPL = true

	while true do
		io.write(buf == '' and '> ' or '>> ')
		local l = f.read(f, '*l')
		if l == nil then
			io.write('\n')
			buf = ''
		else
			buf = buf .. '\n' .. l
		end

		if l == '' then
			local f, err = luma.loadstring(buf, "=repl")
			if err then
				print(err)
			else
				printcall(pcall(f))
			end
			buf = ''
		end
	end
end

function cli.i_main(argv)
	local parser = argparse()
		:description "Run Luma code, without an explicit compile step."
	parser:mutex(
		parser:option "-i" "--input"
			:description "Evaluate a luma file",
		parser:option "-e" "--eval"
			:description "Evaluate a luma string",
		parser:flag "-r" "--repl"
			:description "Start a luma REPL."
	)
	local args = parser:parse(argv)
	if args.input then
		local chunk, err = luma.loadfile(args.input)
		assert(chunk, err)
		return chunk()
	end
	if args.eval then
		local chunk, err = luma.loadstring(args.eval, "=eval")
		assert(chunk, err)
		return chunk()
	end
	if args.repl then
		return cli.repl(io.stdin)
	end
end

function cli.c_main(argv)
	local parser = argparse():description "Luma is a lisp that compiles to lua"
	parser:argument "input"
		:args "*"
		:description "input files"
	parser:option "-s" "--string"
		:description "Compile string to stdout"
	local args = parser:parse(argv)
	if args.string then
		local out = luma.compile(args.string, "=eval")
		print(out)
	else
		for _, fname in ipairs(args.input) do
			print("compiling " .. fname)
			luma.compilefile(fname)
		end
	end
end

return cli
