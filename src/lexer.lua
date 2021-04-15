-- lexer
-- converts file into a list of tokens, in this case words, punctuation, etc.

local token = ""
local list = {}
local word = false

local function add(t)
	if t ~= "" then
		-- hack to make ale and ali synonymous
		if t == "ale" then
			t = "ali"
		end
		table.insert(list,t)
		token = ""
		prev = t
	end
end

function lex(str)
	token = ""
	prev = ""
	list = {}

	word = false
	quote = false
	newline = false

	-- add a newline so the last line doesnt fail
	str = str .. "\n"

	for char in str:gmatch('.') do
		if quote then
			token = token .. char
			if char == '"' then
				add(token)
				quote = false
			end
			
		else
			if char == "." or char == "!" then
				if word then
					add(token)
				end
				add(".")
				word = false
			elseif char == "," then
				-- skip
			elseif char == "?" or char == ":" then
				if word then
					add(token)
				end
				add(char)
				word = false
			elseif char == "\n" or char == "\r" then
				if word then
					add(token)
				end
				if prev ~= "\n" and prev ~= "\r" then
					add("\n")
				end
				word = false
			elseif char == " " or char == "\t" then
				if word then
					add(token)
				end
				word = false
			elseif char == '"' then
				token = token .. char
				quote = true
			else
				token = token .. char
				word = true
			end
		end
	end
	

	return list
end

return lex