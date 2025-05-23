--!native
--!optimize 2
--!strict

--[[
	GradientMap.lua
    MIT License 
    
    	- Howhow, 2025 @ https://github.com/howhow2315
    		"A gradient interpolator for any value type that supports :Lerp(other, alpha). 
    			Useful for Color3, Vector3, or custom datatypes."
]]

local GradientMap = {}
GradientMap.__index = GradientMap

-- 	Creates a new GradientMap based off the provided :Lerp()-able values.
function GradientMap.new(values: {any}, roundPrecision: number?)
	assert(typeof(values) == "table", "GradientMap requires a table of values")
	assert(#values >= 2, "GradientMap requires at least two values")
	
	local first = values[1]
	local t = typeof(first)
	
	-- Ensure the first value has a :Lerp method (e.g., Color3:Lerp, NumberRange:Lerp)
	local hasLerp = pcall(function()
		return typeof(first.Lerp) == "function"
	end)
	assert(hasLerp, "Values must support :Lerp")

	for i, v in ipairs(values) do
		local tV = typeof(v)
		assert(tV == t, `Value at index {i} is of type {tV}, expected {t}`)
	end

	return setmetatable({
		Values = values,
		Precision = (typeof(roundPrecision) == "number" and roundPrecision) or 1e3,
		Cache = {}
	}, GradientMap)
end

-- Returns a interpolated value from the gradient based on the input position by +-max.
function GradientMap:Get(x: number, max: number): any
	local values = self.Values

	if max == 0 then return values[1] end
	if x > max then return values[#values] end
	
	-- Normalize input x into [0, 1] range centered around 0 using the given max value
	local a = math.clamp((x + max) / (2 * max), 0, 1)
	
	-- Round the normalized value to reduce redundant interpolations (acts as cache key)
	local key = math.round(a * self.Precision) / self.Precision

	local cached = self.Cache[key]
	if cached then
		return cached
	end

	local segments = #values - 1
	
	-- Determine which two values to interpolate between, and the local alpha within that segment
	local segment = math.clamp(math.floor(a * segments) + 1, 1, segments)
	local localA = (a * segments) % 1

	local a = values[segment]
	local b = values[segment + 1]
	local result = a:Lerp(b, localA)

	self.Cache[key] = result
	return result
end

return GradientMap