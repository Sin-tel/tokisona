-- debug version
-- run this with lua.exe

require("util")
lex = require("lexer")
parse = require("parser")
transpile = require("transpiler")


filestring = readfile("test.tps")

--print(filestring)

tokens = lex(filestring)

-- for i,v in ipairs(tokens) do
-- 	print(i,v)
-- end

syntaxTree = parse(tokens)

-- print("input: ")
-- print(teststring)
-- print("parse tree: ")
printTree(syntaxTree)

luacode = transpile(syntaxTree)

-- print("====CODE=======")
-- print("")
-- print(luacode)

local f = "out"
writefile(f,luacode)

print("====RUN=======")
loadstring(luacode)()

