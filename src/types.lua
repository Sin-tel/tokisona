-- the lua types and operators 

nanpa = "number"
sona = "boolean"
nimi = "string"

function wrap(v)
	return {val = v}
end

function cast_tostring(v)
	if type(v.val) == "number" then
		local n = v.val

		if n <= 0 then
			v.val = "ala"
			return v
		elseif n >= 100 then
			v.val = "ali"
			return v
		else
			local s = ""
			while n >= 20 do
				s = s .. " mute"
				n = n - 20
			end
			while n >= 5 do
				s = s .. " luka"
				n = n - 5
			end
			if n == 4 then
				s = s .. " tu tu"
			elseif n == 3 then
				s = s .. " tu wan"
			elseif n == 2 then
				s = s .. " tu"
			elseif n == 1 then
				s = s .. " wan"
			end

			v.val = s:sub(2)

			return v
		end
	elseif type(v.val) == "boolean" then
		if v.val then
			v.val = "lon"
		else
			v.val = "lon ala"
		end
		return v
	end
end

function cast_fromstring(v,t)

	if t == "number" then
		if v.val == "ali" or v.val == "ale" then
			v.val = 100
			return v
		elseif v.val == "ala" then
			v.val = 0
			return v
		else
			local n = 0
			for w in v.val:gmatch("%w+") do 
				if w == "mute" then
					n = n + 20
				elseif w == "luka" then
					n = n + 5
				elseif w == "tu" then
					n = n + 2
				elseif w == "wan" then
					n = n + 1
				elseif w == "ala" then
					v.val = 0
					return v
				elseif w == "ali" or w == "ale" then
					v.val = 100
					return v
				end
			end
			if n == 0 then
				-- kind of stupid
				v.val = 1
				return v
			end
			v.val = n
			return v
		end
	elseif t == "boolean" then
		local n = true
		for w in v.val:gmatch("%w+") do 
			if w == "ala" then
				n = not n
			end
		end
		v.val = n
		return v
	end
end

function cast(v,t) 
	if v == nil then
		error("empty variable")
	end

	-- if passed a value, make new wrapped type
	if type(v) ~= "table" then
		v = wrap(v)
	end

	--print(v.val, t)
	-- if type has no value yet, set to default
	if v.val == nil then
		if t == "number" then
			v.val = 0
		elseif t == "string" then
			v.val = ""
		elseif t == "boolean" then
			v.val = false
		end
		return v
	end

	-- dont do any casting if types are equal
	if t == type(v.val) then
		return v
	end

	-- otherwise, cast to and from string
	if t == "string" then
		return cast_tostring(v)
	end

	if type(v.val) == "string" then
		return cast_fromstring(v,t)
	end

	return cast_fromstring(cast_tostring(v),t)
end

function add(v1,v2)
	if type(v1) == "string" then
		return v1 .. " " .. v2
	else
		local result = v1 + v2
		if result > 100 then
			result = 100
		end
		return result
	end
end

function sub(v1,v2)
	local result = v1 - v2
	if result < 0 then
		result = 0
	end
	return result
end

function eq(v1,v2)
	return v1 == v2
end

function neq(v1,v2)
	return v1 ~= v2
end

function gt(v1,v2)
	return v1 > v2
end

function lt(v1,v2)
	return v1 < v2
end

function printv(v) 
	local s = cast(v,"string").val
	--print(v, s)
	print(s)
end