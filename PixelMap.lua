--!strict

--[[
	PixelMap.lua
    MIT License 
    
    	- Howhow, 2025 @ https://github.com/howhow2315
    		"An lightweight wrapper for EditableImage,
				providing structured per-pixel access and update methods."
]]

-- Services
local AssetService = game:GetService("AssetService")

-- Constants
local floor = math.floor
local clamp = math.clamp

local writeu8, readu8, fillu8 = buffer.writeu8, buffer.readu8, buffer.fill

-- Class
local PixelMap = {}
PixelMap.__index = PixelMap

-- Creates a new PixelMap object with an editable image and buffer controller
function PixelMap.new(size: Vector2?)
	local s: Vector2 = size or Vector2.one
	local count = s.X * s.Y
	
	local image = AssetService:CreateEditableImage({
		Size = s
	})
	
	local self = setmetatable({
		Image = image,
		Size = s,
		Channels = buffer.create(count * 4), -- RGBa channels for each pixel
		PixelCount = count
	}, PixelMap)
	
	fillu8(self.Channels, 0, 255, count * 4)

	return self
end

-- Returns the Content object for the EditableImage
function PixelMap:GetContent(): Content
	return Content.fromObject(self.Image)
end

-- Writes the buffer contents to the EditableImage
function PixelMap:Refresh()
	self.Image:WritePixelsBuffer(Vector2.zero, self.Size, self.Channels)
end

--local function to8Bit(v: number)
--	return clamp(floor(v * 255 + 0.5), 0, 255))
--end

-- Write color and alpha? directly to flat index (0-base)
function PixelMap:WriteColor(i: number, color: Color3, alpha: number?)
	if i < 0 or i >= self.PixelCount then warn(i) return end

	local i4 = i * 4
	local _r, r, _g, g, _b, b, _a, a =
		i4, clamp(floor(color.R * 255 + 0.5), 0, 255),
		i4 + 1, clamp(floor(color.G * 255 + 0.5), 0, 255),
		i4 + 2, clamp(floor(color.B * 255 + 0.5), 0, 255),
		i4 + 3, alpha and clamp(floor((alpha) * 255 + 0.5), 0, 255) or 255
	
	local pixels = self.Channels
	local lr, lg, lb, la =
		readu8(pixels, _r),
		readu8(pixels, _g),
		readu8(pixels, _b),
		readu8(pixels, _a)
	
	if r ~= lr then writeu8(pixels, _r, r) end
	if g ~= lg then writeu8(pixels, _g, g) end
	if b ~= lb then writeu8(pixels, _b, b) end
	if a ~= la then writeu8(pixels, _a, a) end
	
	--writeu8(pixels, _r, r)
	--writeu8(pixels, _g, g)
	--writeu8(pixels, _b, b)
	--writeu8(pixels, _a, a)
end

-- Reads the RGBa values from a flat pixel index
function PixelMap:GetColor(i: number): (number, number, number, number)
	local i4 = i * 4
	local _r, _g, _b, _a =
		i4,
		i4 + 1,
		i4 + 2,
		i4 + 3

	local pixels = self.Channels
	return
		readu8(pixels, _r),
		readu8(pixels, _g),
		readu8(pixels, _b),
		readu8(pixels, _a)
end

-- Writes color and alpha? to the pixel at (x, y) coordinates
function PixelMap:SetPixel(x: number, y: number, color: Color3, alpha: number?)
	local i = y * self.Size.X + x
	self:WriteColor(i, color, alpha)
end

-- Get the RGBa via (x, y) coordinate
function PixelMap:GetPixel(x: number, y: number, color: Color3): (number, number, number, number)
	local i = y * self.Size.X + x
	return self:GetColor(i)
end

-- Fills the entire buffer with a uniform color and alpha?
function PixelMap:FillColor(color: Color3?, alpha: number?)
	local c = color or Color3.new(0, 0, 0)
	local a = alpha or 1
	local count: number = self.PixelCount
	for i = 0, count - 1 do
		self:WriteColor(i, c, a)
	end
	self:Refresh()
end

-- Clears the buffer to all zero values (transparent black)
function PixelMap:Clear()
	local count: number = self.PixelCount
	fillu8(self.Channels, 0, 0, count * 4)
	self:Refresh()
end

return PixelMap