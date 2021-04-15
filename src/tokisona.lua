--[[
	command line version
	run:
	> lua tokisona.lua toki.tps
]]

local file = arg[1]
package.path = arg[0]:match("(.-)[^\\/]+$") .. "?.lua;" .. package.path

require( "util")
lex = require("lexer")
parse = require("parser")
transpile = require("transpiler")


filestring = readfile(file)
tokens = lex(filestring)
syntaxTree = parse(tokens)
luacode = transpile(syntaxTree)

loadstring(luacode)()



