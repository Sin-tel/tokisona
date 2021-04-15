-- converts the abstract syntax tree into lua code.

local header = [[
require("types")
]]

local variables = {}
local code = ""

local function eval(t)
	-- t.name
	if t.name == "assignment" then
		return eval(t[1]) .. " = " .. eval(t[2]) .. "\n"
	elseif t.name == "question" then
		return "printv(" .. eval(t[1]) .. ")" .. "\n"
	elseif t.name == "stringvar" or t.name == "numbervar" or t.name == "boolvar" then
		local c = ""

		local vname = t[2][1]
		if not variables[vname] then
			
			variables[vname] = true
		end
		c = c .. "cast(" ..  vname .. ", " .. t[1][1] .. ").val"		

		return c
	elseif t.name == "StringLit" then
		return t[1]
	elseif t.name == "Word" then
		return '"' .. t[1][1] .. '"'
	elseif t.name == "numberLiteral" then
		local c = ''
		for i,v in ipairs(t) do
			c = c .. " " .. v[1]
		end
		c = '"' .. c:sub(2) .. '"'

		return "cast(" ..  c .. ", " .. '"number"' .. ").val"
	elseif t.name == "boolLiteral" then
		return "true"
	elseif t.name == "bool" then
		local c = ""
		for i,v in ipairs(t) do	
			if v.name == "Keyword" and v[1] == "ala" then
				c = c .. "not "
			end
		end
		return c .. eval(t[1])
	elseif t.name == "comment" then
		return ""
	elseif t.name == "loop" then
		return "for _=1, " .. eval(t[1]) .. " do\n"
			.. eval(t[2])
			.. "end\n"
	elseif t.name == "conditional" then
		local c_if = "if " .. eval(t[1]) .. " then\n" .. eval(t[2])
		local c_else = ""
		if(t[3] and t[3][1] == "ante") then
			c_else = "else\n" .. eval(t[4])
		end
		return c_if .. c_else .. "end\n"

	elseif t.name == "binop" then
		if(t[2][1] == "suli") then
			return " add(" .. eval(t[1]) .. " , " .. eval(t[3]) .. ")"
		elseif(t[2][1] == "lili") then
			return " sub(" .. eval(t[1]) .. " , " .. eval(t[3]) .. ")"
		end

	elseif t.name == "relop" then
		if(t[2][1] == "sama") then
			return " eq(" .. eval(t[1]) .. " , " .. eval(t[3]) .. ")"
		elseif(t[2][1] == "ala") then
			return " neq(" .. eval(t[1]) .. " , " .. eval(t[3]) .. ")"
		elseif(t[3][1] == "suli") then
			return " gt(" .. eval(t[2]) .. " , " .. eval(t[1]) .. ")"
		elseif(t[3][1] == "lili") then
			return " lt(" .. eval(t[2]) .. " , " .. eval(t[1]) .. ")"
		end

	elseif t.name == "weka" then
		-- wrap break in empty block
		-- this makes it work in the middle of another block
		return "do break end\n"

	else
		local c = ""
		for i,v in ipairs(t) do			
			if type(v) == "table" then
				c = c .. eval(v)
			else
				error("cant evaluate: " .. t.name .. " " .. t[1])
			end
		end
		return c
	end
end

local function transpile(tree)
	variables = {}
	code = ""

	code = code .. header

	local c = eval(tree)

	for k,v in pairs(variables) do
		code = code .. k .. " = {}\n"
	end

	-- add a single iter for loop so "break" works anywhere
	code = code .. "repeat\n\n" ..  c .. "\nuntil true"

	return code
end

return transpile