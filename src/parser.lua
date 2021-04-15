-- recursive descent parser with backtracking
-- generates an abstract syntax tree from the list of tokens


local index = 1
local tokens = {}
local tree = {}
local node = tree

local wordlist = require("wordlist")

local report_error = false

local function err(msg)
	report_error = true
	print(msg)

	--error(msg)
end

local function checkName(name)
	local n = name:lower()
	if string.match(n, '[bcdfghqrvyz]')
	or string.match(n, 'ji')
	or string.match(n, 'wu')
	or string.match(n, 'wo')
	or string.match(n, 'ti')
	or string.match(n, '[mn][mn]')
	or string.match(n, '[aeiou][aeiou]')
	or string.match(n, '[ptkswljm][ptkswljm]')
	then

		err("illegal character combination in: " .. name )
	end

	return true
end


local function newNode(name)
	local n = {}
	n.name = name
	n.parent = node
	n.index = index

	node = n
end

-- always accept
local function maybe(r)
	return true
end

-- failed to match anything
local function up()
	node = node.parent
	index = node.index
	return false
end

local function try(r)
	if r then
		-- succes. push new node and continue
		table.insert(node.parent, node)
		node = node.parent
		return true
	else
		-- failure. empty current node and backtrack
		local n = {}
		n.name = node.name
		n.parent = node.parent
		n.index = node.index

		node = n
		index = n.index
		return false
	end
end

local function multiple(f)
	
	local r = f()

	if not r then
		return false
	end

	while true do
		node.index = index
		r = f()
		if not r then
			index = node.index
			return true
		end
	end
end

local function match(t)
	local n = tokens[index]

	if n == t then
		index = index + 1
		table.insert(node,{n, name = "Keyword"})
		return n
	end
end

local function match_any(t)
	local bag = {}
	for i,v in ipairs(t) do
		bag[v] = true
	end

	local n = tokens[index]

	if bag[n] then
		index = index + 1
		table.insert(node,{n, name = "Keyword"})
		return n
	end
end
-- match without putting in tree
local function skip(t)
	local n = tokens[index]
	if n == t then
		index = index + 1
		return n
	end
end

local function StringLit()
	local n = tokens[index]
	if n:sub(1,1) == '"' then
		table.insert(node,{n, name = "StringLit"})
		index = index + 1
		return n
	end
end

local function Name()
	local n = tokens[index]

	local l = n:sub(1,1)
	-- check first letter capital and valid
	if l == l:upper() and checkName(n) then
		table.insert(node,{n, name = "Name"})
		index = index + 1
		return n
	end
end

local function CommentWord()
	local n = tokens[index]

	-- check first letter capital
	if n ~= "\n" then
		table.insert(node,n)
		index = index + 1
		return n
	end
end

-- numbervar := "nanpa" Name
local function numbervar()
	newNode("numbervar")

	return try(match("nanpa") and Name()) 
		or up()
end

-- stringvar := "nimi" Name
local function stringvar()
	newNode("stringvar")
	return 
		try(match("nimi") and Name()) 
		or up()
end

-- boolvar := "sona" Name
local function boolvar()
	newNode("boolvar")
	return 
		try(match("sona") and Name()) 
		or up()
end

-- number := ("mute" | "luka" | "tu" | "wan")+
--         | "ala" 
--         | "ali" 
--         | numbervar
local function numberLiteral()
	newNode("numberLiteral")

	return try(multiple(function() return match_any({"mute","luka","wan","tu"}) end)) 
		or try(match("ala")) 
		or try(match("ali"))
		or up()
end

-- number := numberLiteral | numbervar
local function number()
	newNode("number")
	return try(numberLiteral())
		or try(numbervar())  
		or up()
end

-- any word from the official list
local function Word()
	newNode("Word")
	return try(match_any(wordlist)) 
		or up()
end
-- str := StringLit
--      | stringvar 
--      | Word
local function str()
	newNode("str")

	return try(StringLit()) 
		or try(stringvar()) 
		or try(Word()) 
		or up()
end

-- bool := "lon" ("ala")?
--       | boolvar ("ala")?
local function boolLiteral()
	newNode("boolLiteral")

	return try(match("lon"))
		or up()
end

local function bool()
	newNode("bool")

	return try(boolLiteral() and maybe(multiple(function() return match("ala") end)))
		or try(boolvar() and maybe(multiple(function() return match("ala") end)))
		or up()
end

-- exp := number | bool | str
local function exp()
	newNode("expression")
	return try(number()) 
		or try(bool()) 
		or try(str()) 
		or up()
end

-- var := numbervar 
--      | boolvar
--      | stringvar
local function var()
	newNode("var")
	return try(numbervar()) 
		or try(stringvar()) 
		or try(boolvar()) 
		or up()
end

-- relop := number "la" number "li suli"
--        | number "la" number "li lili" 
--        | exp "li sama e" exp 
--        | exp "li sama ala e" exp
local function relop()
	newNode("relop")
	return try(number() and skip("la") and number() and skip("li") and match("suli"))
		or try(number() and skip("la") and number() and skip("li") and match("lili"))
		or try(exp() and skip("li") and skip("sama") and match("ala") and skip("e") and exp())
		or try(exp() and skip("li") and match("sama") and skip("e") and exp())
		or up()
end

-- binop := number "li suli e" number 
--        | number "li lili e" number 
--        | str "li lili e" str 
local function binop()
	newNode("binop")
	return try(number() and skip("li") and match("suli") and skip("e") and number())
		or try(number() and skip("li") and match("lili") and skip("e") and number())
		or try(str() and skip("li") and match("suli") and skip("e") and str())
		or up()
end

-- sentence := StringLit (".")? | binop "." | relop "."
local function sentence()
	newNode("sentence")
	return try(StringLit() and maybe(skip("."))) 
		or try(binop() and skip("."))
		or try(relop() and skip("."))
		or up()
end

--assignment := var 'li' exp '.' 
--            | var 'li ni:' sentence "."
local function assignment()
	newNode("assignment")
	return try(var() and skip("li") and exp() and skip(".")) 
		or try(var() and skip("li") and skip("ni") and skip(":") and sentence()) 
		or up()
end

-- question := number "li seme?" 
--           | str "li seme?" 
--           | bool "li lon ala lon?"
local function question()
	newNode("question")
	return try(number() and skip("li") and skip("seme") and skip("?"))
		or try(str() and skip("li") and skip("seme") and skip("?"))
		or try(bool() and skip("li") and skip("lon") and skip("ala") and skip("lon") and skip("?"))
		or up()
end

local function commentLine()
	newNode("commentLine")
	-- quit on o pini
	if skip("o") and skip("pini") and skip(".") then
		return up()
	end
	return try(multiple(CommentWord) and skip("\n"))
		or up()
end

local function commentLineSingle()
	newNode("commentLineSingle")
	return try(multiple(CommentWord) and skip("\n"))
		or up()
end

-- comment := "mi pilin e ni:" Text 
--          | "mi pilin e ni:\n" (Text)+ "o pini!" ("\n")?
--          | aaa
local function comment()
	newNode("comment")
	return try(skip("mi") and skip("pilin") and skip("e") and skip("ni") and skip(":") 
			and commentLineSingle())
		or try(skip("mi") and skip("pilin") and skip("e") and skip("ni") and skip(":") and skip("\n")
			and multiple(commentLine)
			and skip("o") and skip("pini") and skip(".") and maybe(skip("\n")))
		or up()
end

local chunk
local block

-- loop := "tenpo" number "la o pali e ni:" block "o pini."
local function loop()
	newNode("loop")
	return 
		try(	
			skip("tenpo") and number() 
			and skip("la") and skip("o") and skip("pali") and skip("e") and skip("ni") and skip(":") and maybe(skip("\n"))
			and block() and skip("o") and skip("pini") and skip(".")
		)
		or up()
end

-- conditional := relop "la o pali e ni:" block ("ante la o pali e ni:" block)? "o pini."
-- conditional := bool "la o pali e ni:" block ("ante la o pali e ni:" block)? "o pini."
local function conditional()
	newNode("conditional")
	return	try(	
			relop() 
			and skip("la") and skip("o") and skip("pali") and skip("e") and skip("ni") and skip(":") and maybe(skip("\n"))
			and block() 
			and maybe(
				match("ante") and skip("la") and skip("o") and skip("pali") and skip("e") and skip("ni") and skip(":") and maybe(skip("\n"))
			and block() )
			and skip("o") and skip("pini") and skip(".")
			)
		or try(	
			bool() 
			and skip("la") and skip("o") and skip("pali") and skip("e") and skip("ni") and skip(":") and maybe(skip("\n"))
			and block() 
			and maybe(
				match("ante") and skip("la") and skip("o") and skip("pali") and skip("e") and skip("ni") and skip(":") and maybe(skip("\n"))
			and block() )
			and skip("o") and skip("pini") and skip(".")
			)
		or up()
end

local function weka()
	newNode("weka")
	return try(skip("o") and skip("weka") and skip("."))
		or up()
end

-- chunk := assigment
--        | question
--        | comment
function chunk()
	newNode("chunk")

	-- EOF
	if not tokens[index] then
		return up()
	end

	return try(assignment())
		or try(question())
		or try(loop()) 
		or try(conditional()) 
		or try(weka()) 
		or try(comment()) 
		or up()
end


-- block := (chunk (\n)?)+
function block()
	newNode("block")

	r = try(maybe(skip("\n")) and multiple( function() 
		return chunk() and maybe(skip("\n"))
	end))

	--[[if not r then
		err("error: empty block at: " .. index)
	end]]

	return r
end

local function parse(t)
	tokens = t
	index = 1
	tree = {}
	node = tree
	tree.name = "root"

	block()

	if tokens[index] then
		err("syntax error at: " .. tokens[index] .. "\t" .. tostring(index))
	end

	--[[if report_error then
		return false
	end]]

	return tree
end






return parse