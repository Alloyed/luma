#!/usr/bin/env lua
local argparse = require 'argparse'
local inspect  = require 'inspect'

require 'luma.lib.prelude'

local Luma = {}

function Luma.repl(f)
	error "FIXME"
	local buf = ''
	print(([[
	%s
	%s
	Enter a blank line to evaluate.
	CTRL-D to discard expression.
	CTRL-D a second time to exit.
	]]):format(_LUMA_VERSION, _VERSION))
	

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
			print("EVAL")
			print(buf)
			buf = ''
		end
	end
end

function Luma.i_main(argv)
	local luma = argparse()
		:description "Run luma code, without an explicit compile step."
	luma:mutex(
		luma:option "-i" "--input"
			:description "Evaluate a luma file",
		luma:option "-e" "--eval"
			:description "Evaluate a luma string",
		luma:flag "-r" "--repl"
			:description "Start a luma REPL."
	)
	local args = luma:parse(argv)
	if args.input then
		local chunk, err = s_loadfile(args.input)
		assert(chunk ~= nil, err)
		return chunk()
	end
	if args.eval then
		local chunk, err = s_loadstring(args.eval, "eval")
		assert(chunk ~= nil, err)
		return chunk()
	end
	if args.repl then
		return Luma.repl(io.stdin)
	end
end

function Luma.c_main(argv)
	local luma = argparse():description "Luma is a lisp that compiles to lua"
	luma:argument "input"
		:args "+"
		:description "input files"
	luma:flag "-p" "--pipe"
		:description "Pipe compiled code to stdout"
	local args = luma:parse(argv)
	for _, fname in ipairs(args.input) do
		print("compiling " .. fname)
		s_compilefile(fname)
	end
	print(inspect(args))
end

return Luma
