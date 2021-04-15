-- some unit tests for the type system.
-- there arent many because writing
-- unit tests is really boring.

require("types")

for i = 0,100 do
	local s = cast(i, "string").val
	local num = cast(s, "number").val
	--print(i, num, s)
	assert(i == num, i)
end

assert(cast(true, "string").val == "lon")
assert(cast(false, "string").val == "lon ala")


assert(cast(cast(1, "boolean"),"string").val  == "lon")
assert(cast(cast(0, "boolean"),"string").val  == "lon ala")