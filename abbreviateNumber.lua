--[[
	abbreviateNumber.lua
    MIT License 
    
    	- Howhow
    		"Abbreviates big numbers into strings (e.g., 501, 1.2M, 3.5B)"
]]

local suffixes: {string} = {
	"k", "M", "B", "T", "Qd", "Qn", "Sx", "Sp", "Oc", "No",
	"De", "Vt", "Tg", "qg", "Qg", "sg", "Sg", "Og", "Ng",
	"Ce", "Du", "Tr", "Qa", "Qi", "Se", "Si", "Ot", "Ni",
	"Mi", "Mc", "Na", "Pi", "Fm", "At", "Zp", "Yc", "Xo", "Ve", "Me",
	"Due", "Tre", "Te", "Pt", "He", "Hp", "Oct", "Ex", "Ic", "Mei",
	"Dui", "Tri", "Teti", "Pti", "Hei", "Hp", "Oci", "Eni", "Tra", "TeC",
	"MTc", "DTc", "TrTc", "TeTc", "PeTc", "HTc", "HpT", "OcT", "EnT", "TetC", "MTetc",
	"DTetc", "TrTetc", "TeTetc", "PeTetc", "HTetc", "HpTetc", "OcTetc", "EnTetc", "PcT",
	"MPcT", "DPcT", "TPCt", "TePCt", "PePCt", "HePCt", "HpPct", "OcPct", "EnPct", "HCt",
	"MHcT", "DHcT", "THCt", "TeHCt", "PeHCt", "HeHCt", "HpHct", "OcHct", "EnHct", "HpCt",
	"MHpcT", "DHpcT", "THpCt"
} -- 102 suffixes is the highest Luau allows due to the num limit of (1.797~e308)

-- Abbreviate a number into a string
local function abbreviateNumber(num: number): string
	assert(typeof(num) == "number", "[abbreviateNumber] Expected number input.")
	num = math.round(num)

	if num < 1000 then
		return tostring(num)
	end

	local exponent = math.log10(num)
	local tier = math.floor(exponent / 3)

	local suffix = suffixes[tier]
	if not suffix then
		return string.format("%.3e", num) -- fallback to scientific if beyond suffix range
	end

	local scaled = num / (10 ^ (tier * 3))
	return string.format("%.1f%s", scaled, suffix)
end

return abbreviateNumber