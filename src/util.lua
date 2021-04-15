function writefile(filename,s)
	local f = filename .. ".lua"

	local file,err = io.open(f, "w" )
	if err then 
		print(err) 
		return err
	end

	file:write("-- this file is automatically generated by the tokisona transpiler\n")
	file:write(s)
	file:close()
end

function dofile(filename)
	local f = filename .. ".lua"

	local code = assert(loadfile(f))
	return code()
end

function readfile(f)

    local file = assert(io.open(f, "rb"))
    local content = file:read("*all")
    file:close()
    return content
end


function printTree(t,n)
	n = n or 0
	if t.name then
		print(string.rep('\t', n) .. t.name)
	else
		print(string.rep('\t', n) .. "Node")
	end

	n = n + 1
	for i,v in ipairs(t) do
		if type(v) == "table" then
			printTree(v,n)
		else
			print(string.rep('\t', n) .. tostring(v))
		end
	end
end