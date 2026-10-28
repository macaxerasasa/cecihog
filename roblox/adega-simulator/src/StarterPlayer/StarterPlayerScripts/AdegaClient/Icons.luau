-- Icons: ícones desenhados com formas simples (sem emojis nem imagens externas).
-- Cada função recebe o tamanho em pixels e devolve um Frame transparente com o desenho.

local UI = require(script.Parent.UI)

local Icons = {}

local create = UI.create
local rgb = Color3.fromRGB

local function canvas(size, props)
	local frame = create("Frame", { Size = UDim2.fromOffset(size, size), BackgroundTransparency = 1 })
	for key, value in props or {} do
		frame[key] = value
	end
	return frame
end

-- Retângulo pelo centro, em frações do ícone (0 a 1).
local function shape(parent, cx, cy, w, h, color, radius, rotation, props)
	local frame = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(cx, cy),
		Size = UDim2.fromScale(w, h),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Rotation = rotation or 0,
		Parent = parent,
	})
	if radius then
		create("UICorner", { CornerRadius = if radius == "full" then UDim.new(1, 0) else UDim.new(radius, 0), Parent = frame })
	end
	for key, value in props or {} do
		frame[key] = value
	end
	return frame
end
Icons.shape = shape

local function glyph(parent, text, color, scale)
	return UI.label({
		Text = text,
		FontFace = UI.F.heavy,
		TextScaled = true,
		TextColor3 = color,
		TextXAlignment = Enum.TextXAlignment.Center,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(scale or 0.7, scale or 0.7),
		Parent = parent,
	})
end

function Icons.coin(size)
	local c = canvas(size)
	shape(c, 0.5, 0.5, 1, 1, rgb(255, 179, 0), "full")
	shape(c, 0.5, 0.5, 0.74, 0.74, rgb(255, 205, 64), "full")
	glyph(c, "$", rgb(196, 110, 0), 0.62)
	return c
end

-- Relógio com ponteiros; devolve (frame, função para acertar a hora).
function Icons.clock(size, color)
	local c = canvas(size)
	local face = shape(c, 0.5, 0.5, 1, 1, rgb(255, 255, 255), "full")
	create("UIStroke", { Color = color or rgb(36, 31, 46), Thickness = math.max(2, size / 12), Parent = face })
	local function hand(length, width)
		local pivot = create("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = c })
		shape(pivot, 0.5, 0.5 - length / 2, width, length, color or rgb(36, 31, 46), "full")
		return pivot
	end
	local hourHand = hand(0.28, 0.1)
	local minuteHand = hand(0.38, 0.07)
	shape(c, 0.5, 0.5, 0.14, 0.14, color or rgb(36, 31, 46), "full")
	local function set(hour)
		local h = hour % 12
		local m = (hour - math.floor(hour)) * 60
		hourHand.Rotation = (h + m / 60) * 30
		minuteHand.Rotation = m * 6
	end
	return c, set
end

function Icons.person(size, color)
	local c = canvas(size)
	shape(c, 0.5, 0.3, 0.42, 0.42, color, "full")
	shape(c, 0.5, 0.86, 0.78, 0.5, color, 0.45)
	return c
end

function Icons.people(size, color)
	local c = canvas(size)
	shape(c, 0.68, 0.32, 0.32, 0.32, color, "full", 0, { BackgroundTransparency = 0.35 })
	shape(c, 0.7, 0.78, 0.5, 0.36, color, 0.45, 0, { BackgroundTransparency = 0.35 })
	shape(c, 0.38, 0.3, 0.38, 0.38, color, "full")
	shape(c, 0.38, 0.82, 0.62, 0.42, color, 0.45)
	return c
end

function Icons.hammer(size, color)
	local c = canvas(size)
	shape(c, 0.44, 0.56, 0.14, 0.72, color, 0.4, 45)
	shape(c, 0.64, 0.34, 0.6, 0.24, color, 0.2, 45)
	return c
end

-- inner: cor dos detalhes internos (use a cor do fundo quando o ícone for branco)
function Icons.clipboard(size, color, inner)
	local c = canvas(size)
	shape(c, 0.5, 0.55, 0.72, 0.84, color, 0.16)
	shape(c, 0.5, 0.14, 0.36, 0.14, color, "full")
	for i = 0, 2 do
		shape(c, 0.5, 0.4 + i * 0.17, 0.44, 0.07, inner or rgb(255, 255, 255), "full")
	end
	return c
end

function Icons.star(size, color)
	local c = canvas(size)
	glyph(c, "★", color, 1.05)
	return c
end

function Icons.expand(size, color)
	local c = canvas(size)
	local t = 0.12
	for _, corner in { { 0.15, 0.15, 1, 1 }, { 0.85, 0.15, -1, 1 }, { 0.15, 0.85, 1, -1 }, { 0.85, 0.85, -1, -1 } } do
		local x, y, dx, dy = corner[1], corner[2], corner[3], corner[4]
		shape(c, x + dx * 0.14, y, 0.34, t, color, "full")
		shape(c, x, y + dy * 0.14, t, 0.34, color, "full")
	end
	return c
end

function Icons.palette(size, color, inner)
	local c = canvas(size)
	shape(c, 0.5, 0.5, 0.96, 0.9, color, "full")
	shape(c, 0.3, 0.38, 0.18, 0.18, rgb(255, 69, 58), "full")
	shape(c, 0.52, 0.26, 0.18, 0.18, rgb(255, 204, 0), "full")
	shape(c, 0.74, 0.4, 0.18, 0.18, rgb(0, 122, 255), "full")
	shape(c, 0.62, 0.68, 0.2, 0.2, inner or rgb(255, 255, 255), "full")
	return c
end

function Icons.home(size, color, inner)
	local c = canvas(size)
	shape(c, 0.5, 0.36, 0.58, 0.58, color, 0.12, 45)
	shape(c, 0.5, 0.7, 0.66, 0.5, color, 0.1)
	shape(c, 0.5, 0.8, 0.2, 0.3, inner or rgb(255, 255, 255), 0.3)
	return c
end

function Icons.check(size, color)
	local c = canvas(size)
	shape(c, 0.38, 0.6, 0.14, 0.38, color, "full", -45)
	shape(c, 0.6, 0.48, 0.14, 0.66, color, "full", 40)
	return c
end

function Icons.alert(size, color)
	local c = canvas(size)
	shape(c, 0.5, 0.5, 1, 1, color, "full")
	glyph(c, "!", rgb(255, 255, 255), 0.7)
	return c
end

function Icons.info(size, color)
	local c = canvas(size)
	shape(c, 0.5, 0.5, 1, 1, color, "full")
	glyph(c, "i", rgb(255, 255, 255), 0.66)
	return c
end

function Icons.lock(size, color)
	local c = canvas(size)
	local ring = shape(c, 0.5, 0.38, 0.5, 0.56, rgb(0, 0, 0), "full", 0, { BackgroundTransparency = 1 })
	create("UIStroke", { Color = color, Thickness = math.max(2, size / 9), Parent = ring })
	shape(c, 0.5, 0.7, 0.72, 0.5, color, 0.18)
	return c
end

function Icons.cart(size, color)
	local c = canvas(size)
	shape(c, 0.52, 0.45, 0.72, 0.42, color, 0.15)
	shape(c, 0.14, 0.2, 0.22, 0.09, color, "full")
	shape(c, 0.34, 0.86, 0.16, 0.16, color, "full")
	shape(c, 0.72, 0.86, 0.16, 0.16, color, "full")
	return c
end

function Icons.chair(size, color)
	local c = canvas(size)
	shape(c, 0.3, 0.32, 0.12, 0.6, color, "full")
	shape(c, 0.5, 0.58, 0.52, 0.12, color, "full")
	shape(c, 0.68, 0.8, 0.1, 0.36, color, "full")
	shape(c, 0.3, 0.8, 0.1, 0.36, color, "full")
	return c
end

function Icons.dot(size, color)
	local c = canvas(size)
	shape(c, 0.5, 0.5, 1, 1, color, "full")
	return c
end

return Icons
