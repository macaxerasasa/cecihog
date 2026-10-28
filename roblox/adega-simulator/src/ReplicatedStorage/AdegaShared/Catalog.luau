-- Catalog: todos os móveis do modo construção, com o desenho 3D de cada um.
-- O mesmo código desenha o móvel no servidor, a prévia transparente e as miniaturas da loja.
--
-- Coordenadas locais: o chão fica em y = 0, o centro do móvel em x = z = 0 e a frente aponta para -Z.
-- size = { largura, profundidade } em quadrados da grade (cada quadrado tem Config.Grid studs).
-- kind: seating (mesas com lugares), station (prepara produtos), counter (balcão de atendimento),
--       wall, door (parede que deixa passar) e decor.
-- seats = { { x, z, fx, fz, h } }: posição do assento, direção para onde a pessoa olha e altura do assento.
-- use = { x, z }: onde o funcionário fica para usar a estação.
-- queue / staff = { x, z }: onde o cliente e o atendente ficam no balcão. pickup = { x, y, z }: onde os pedidos prontos ficam.
-- layer = "air": ocupa a camada de cima (pergolados e varais), então dá para pôr mesas embaixo.

local Catalog = {}

local GRID = 2
local WALL_H = 12
local SEAT = 1.85
local DEFAULT_WALL = Color3.fromRGB(214, 206, 192)

local rgb = Color3.fromRGB
local v = Vector3.new
local M = Enum.Material

local RED = rgb(205, 35, 40)
local YELLOW = rgb(250, 196, 30)
local WHITE = rgb(240, 240, 242)
local STEEL = rgb(185, 188, 196)
local DARK = rgb(28, 28, 32)
local WOOD = rgb(128, 84, 50)
local WOOD_DARK = rgb(78, 50, 30)
local NEON_PINK = rgb(255, 60, 170)
local NEON_PURPLE = rgb(170, 70, 255)
local NEON_BLUE = rgb(50, 180, 255)
local GOLD = rgb(255, 196, 40)
local BOTTLES = { rgb(46, 120, 50), rgb(150, 90, 30), rgb(225, 225, 235), rgb(120, 30, 40), rgb(30, 60, 120), rgb(200, 150, 40) }

Catalog.Categories = {
	{ id = "mesas", name = "Mesas", icon = "🍻" },
	{ id = "bar", name = "Bar", icon = "🍾" },
	{ id = "paredes", name = "Paredes", icon = "🧱" },
	{ id = "decoracao", name = "Decoração", icon = "🌿" },
	{ id = "luzes", name = "Luzes e som", icon = "💡" },
}

-- Pedaços reutilizados ---------------------------------------------------------------------------

local function chair(B, x, z, fx, fz, color, material)
	local base = CFrame.lookAt(v(x, 0, z), v(x + fx, 0, z + fz))
	material = material or M.Plastic
	B.part({ cf = base * CFrame.new(0, SEAT - 0.11, 0), size = v(1.6, 0.22, 1.6), color = color, material = material, walk = true })
	B.part({ cf = base * CFrame.new(0, SEAT + 0.8, 0.72), size = v(1.6, 1.5, 0.18), color = color, material = material, walk = true })
	for _, lx in { -0.65, 0.65 } do
		for _, lz in { -0.65, 0.65 } do
			B.part({ cf = base * CFrame.new(lx, (SEAT - 0.22) / 2, lz), size = v(0.16, SEAT - 0.22, 0.16), color = color, material = material, walk = true })
		end
	end
end

local function stool(B, x, z, height, seatColor)
	B.part({ pos = v(x, height - 0.12, z), size = v(0.3, 1.5, 1.5), rot = CFrame.Angles(0, 0, math.rad(90)), shape = Enum.PartType.Cylinder, color = seatColor, material = M.Fabric, walk = true })
	B.part({ pos = v(x, (height - 0.25) / 2, z), size = v(0.25, height - 0.25, 0.25), color = STEEL, material = M.Metal, walk = true })
	B.part({ pos = v(x, 0.9, z), size = v(0.12, 1.1, 1.1), rot = CFrame.Angles(0, 0, math.rad(90)), shape = Enum.PartType.Cylinder, color = STEEL, material = M.Metal, walk = true })
	B.part({ pos = v(x, 0.05, z), size = v(0.1, 1.2, 1.2), rot = CFrame.Angles(0, 0, math.rad(90)), shape = Enum.PartType.Cylinder, color = STEEL, material = M.Metal, walk = true })
end

local function squareTable(B, w, d, color, material, topY)
	topY = topY or 2.95
	B.part({ tag = "Tampo", pos = v(0, topY - 0.1, 0), size = v(w, 0.2, d), color = color, material = material or M.Plastic })
	B.part({ pos = v(0, (topY - 0.2) / 2, 0), size = v(0.35, topY - 0.2, 0.35), color = color, material = material or M.Plastic })
	B.part({ pos = v(0, 0.06, 0), size = v(1.4, 0.12, 1.4), color = color, material = material or M.Plastic })
end

local function bottle(B, x, y, z, color)
	B.part({ pos = v(x, y + 0.5, z), size = v(0.42, 1, 0.42), color = color, material = M.Glass, transparency = 0.1, walk = true })
	B.part({ pos = v(x, y + 1.2, z), size = v(0.18, 0.4, 0.18), color = color, material = M.Glass, transparency = 0.1, walk = true })
end

local function fridge(B, label, labelColor, canColor)
	B.part({ tag = "Uso", pos = v(0, 3.5, 0.1), size = v(3.8, 7, 1.6), color = WHITE, material = M.SmoothPlastic })
	for row = 0, 3 do
		B.part({ pos = v(0, 1.3 + row * 1.35, -0.72), size = v(3.1, 0.8, 0.1), color = if row % 2 == 0 then canColor else labelColor, material = M.Metal })
	end
	B.part({ pos = v(0, 6.25, -0.72), size = v(3.2, 0.12, 0.08), color = rgb(235, 245, 255), material = M.Neon })
	B.part({ pos = v(0, 3.5, -0.8), size = v(3.4, 5.8, 0.08), color = rgb(170, 215, 255), material = M.Glass, transparency = 0.5 })
	B.part({ pos = v(1.55, 3.6, -0.9), size = v(0.14, 2, 0.14), color = STEEL, material = M.Metal })
	B.part({ pos = v(0, 7.55, -0.82), size = v(3.8, 1, 0.12), color = labelColor, text = { text = label, color = rgb(255, 255, 255) } })
end

local function stationCounter(B, width, color, material)
	B.part({ tag = "Uso", pos = v(0, 1.75, 0.1), size = v(width, 3.5, 1.7), color = color, material = material })
	B.part({ pos = v(0, 3.6, 0.1), size = v(width + 0.2, 0.2, 1.9), color = rgb(40, 40, 46), material = M.Granite })
end

local function wallPanel(B, props)
	props.paint = props.paint ~= false and props.material == nil
	return B.part(props)
end

local function header(B)
	B.part({ pos = v(0, WALL_H - 1.5, 0), size = v(4, 3, 0.8), paint = true })
end

local function neonText(B, pos, size, text, color, font)
	B.part({ pos = pos, size = size, color = rgb(15, 12, 22), text = { text = text, color = color, font = font or Enum.Font.FredokaOne } })
end

-- Itens ------------------------------------------------------------------------------------------

Catalog.Items = {
	-- MESAS
	{
		id = "mesa_dupla",
		category = "mesas",
		name = "Mesa de plástico (2 lugares)",
		price = 70,
		level = 1,
		size = { 3, 2 },
		appeal = 0,
		kind = "seating",
		seats = { { -2.2, 0, 1, 0 }, { 2.2, 0, -1, 0 } },
		top = { 0, 3, 0 },
		build = function(B)
			squareTable(B, 2.4, 2.4, RED)
			chair(B, -2.2, 0, 1, 0, RED)
			chair(B, 2.2, 0, -1, 0, RED)
		end,
	},
	{
		id = "mesa_plastico",
		category = "mesas",
		name = "Mesa de plástico (4 lugares)",
		price = 120,
		level = 1,
		size = { 3, 3 },
		appeal = 0,
		kind = "seating",
		seats = { { -2.2, 0, 1, 0 }, { 2.2, 0, -1, 0 }, { 0, -2.2, 0, 1 }, { 0, 2.2, 0, -1 } },
		top = { 0, 3, 0 },
		build = function(B)
			squareTable(B, 2.6, 2.6, RED)
			chair(B, -2.2, 0, 1, 0, RED)
			chair(B, 2.2, 0, -1, 0, RED)
			chair(B, 0, -2.2, 0, 1, RED)
			chair(B, 0, 2.2, 0, -1, RED)
		end,
	},
	{
		id = "mesa_amarela",
		category = "mesas",
		name = "Mesa de boteco amarela (4 lugares)",
		price = 160,
		level = 2,
		size = { 3, 3 },
		appeal = 1,
		kind = "seating",
		seats = { { -2.2, 0, 1, 0 }, { 2.2, 0, -1, 0 }, { 0, -2.2, 0, 1 }, { 0, 2.2, 0, -1 } },
		top = { 0, 3, 0 },
		build = function(B)
			squareTable(B, 2.6, 2.6, YELLOW)
			B.part({ pos = v(0, 2.96, 0), size = v(1.6, 0.02, 1.6), color = RED, walk = true })
			bottle(B, 0.7, 3, -0.6, rgb(40, 110, 50))
			for _, c in { { -2.2, 0, 1, 0 }, { 2.2, 0, -1, 0 }, { 0, -2.2, 0, 1 }, { 0, 2.2, 0, -1 } } do
				chair(B, c[1], c[2], c[3], c[4], YELLOW)
			end
		end,
	},
	{
		id = "mesa_bistro",
		category = "mesas",
		name = "Mesa bistrô com banquetas",
		price = 320,
		level = 3,
		size = { 3, 2 },
		appeal = 2,
		kind = "seating",
		seats = { { -2.1, 0, 1, 0, 2.9 }, { 2.1, 0, -1, 0, 2.9 } },
		top = { 0, 3.95, 0 },
		build = function(B)
			B.part({ tag = "Tampo", pos = v(0, 3.85, 0), size = v(0.2, 2.4, 2.4), rot = CFrame.Angles(0, 0, math.rad(90)), shape = Enum.PartType.Cylinder, color = WOOD, material = M.Wood })
			B.part({ pos = v(0, 1.9, 0), size = v(0.3, 3.7, 0.3), color = DARK, material = M.Metal })
			B.part({ pos = v(0, 0.06, 0), size = v(0.12, 1.6, 1.6), rot = CFrame.Angles(0, 0, math.rad(90)), shape = Enum.PartType.Cylinder, color = DARK, material = M.Metal })
			stool(B, -2.1, 0, 2.9, rgb(160, 30, 40))
			stool(B, 2.1, 0, 2.9, rgb(160, 30, 40))
		end,
	},
	{
		id = "banquetas_balcao",
		category = "mesas",
		name = "Balcão com banquetas (3 lugares)",
		price = 520,
		level = 4,
		size = { 4, 2 },
		appeal = 2,
		kind = "seating",
		seats = { { -2.6, -1.3, 0, 1, 2.9 }, { 0, -1.3, 0, 1, 2.9 }, { 2.6, -1.3, 0, 1, 2.9 } },
		top = { 0, 3.95, 0.7 },
		build = function(B)
			B.part({ pos = v(0, 1.85, 0.9), size = v(7.6, 3.7, 1.2), color = WOOD_DARK, material = M.WoodPlanks })
			B.part({ tag = "Tampo", pos = v(0, 3.8, 0.7), size = v(7.9, 0.25, 1.9), color = rgb(40, 40, 46), material = M.Granite })
			B.part({ pos = v(0, 0.6, 0.25), size = v(7.6, 0.15, 0.15), color = STEEL, material = M.Metal })
			for _, x in { -2.6, 0, 2.6 } do
				stool(B, x, -1.3, 2.9, DARK)
			end
		end,
	},
	{
		id = "mesa_madeira",
		category = "mesas",
		name = "Mesa de madeira rústica (6 lugares)",
		price = 480,
		level = 5,
		size = { 4, 3 },
		appeal = 2,
		kind = "seating",
		seats = { { -2.2, -2.2, 0, 1 }, { 0, -2.2, 0, 1 }, { 2.2, -2.2, 0, 1 }, { -2.2, 2.2, 0, -1 }, { 0, 2.2, 0, -1 }, { 2.2, 2.2, 0, -1 } },
		top = { 0, 3, 0 },
		build = function(B)
			B.part({ tag = "Tampo", pos = v(0, 2.85, 0), size = v(7, 0.3, 2.6), color = WOOD, material = M.WoodPlanks })
			for _, x in { -3, 3 } do
				B.part({ pos = v(x, 1.35, 0), size = v(0.5, 2.7, 2.2), color = WOOD_DARK, material = M.Wood })
			end
			for _, x in { -2.2, 0, 2.2 } do
				chair(B, x, -2.2, 0, 1, WOOD, M.Wood)
				chair(B, x, 2.2, 0, -1, WOOD, M.Wood)
			end
		end,
	},
	{
		id = "sofa_lounge",
		category = "mesas",
		name = "Lounge com sofás (4 lugares)",
		price = 950,
		level = 8,
		size = { 4, 3 },
		appeal = 4,
		kind = "seating",
		seats = { { -1.3, 2.1, 0, -1, 1.6 }, { 1.3, 2.1, 0, -1, 1.6 }, { -1.3, -2.1, 0, 1, 1.6 }, { 1.3, -2.1, 0, 1, 1.6 } },
		top = { 0, 1.7, 0 },
		build = function(B)
			local leather = rgb(70, 30, 40)
			for _, side in { -1, 1 } do
				B.part({ pos = v(0, 0.75, side * 2.1), size = v(5.4, 1.5, 1.6), color = leather, material = M.Fabric, walk = true })
				B.part({ pos = v(0, 2.2, side * 2.75), size = v(5.4, 2, 0.4), color = leather, material = M.Fabric, walk = true })
				for _, x in { -2.85, 2.85 } do
					B.part({ pos = v(x, 1.6, side * 2.1), size = v(0.4, 1.4, 1.6), color = leather, material = M.Fabric, walk = true })
				end
			end
			B.part({ tag = "Tampo", pos = v(0, 1.55, 0), size = v(3.4, 0.3, 1.5), color = rgb(30, 30, 34), material = M.Glass, transparency = 0.2 })
			B.part({ pos = v(0, 0.7, 0), size = v(3, 1.4, 1.1), color = WOOD_DARK, material = M.Wood })
			B.part({ pos = v(0, 1.72, 0), size = v(0.3, 0.3, 0.3), shape = Enum.PartType.Ball, color = rgb(255, 200, 120), material = M.Neon, light = { color = rgb(255, 190, 120), range = 9, brightness = 1 } })
		end,
	},
	{
		id = "mesa_vip",
		category = "mesas",
		name = "Mesa VIP com neon (4 lugares)",
		price = 1600,
		level = 10,
		size = { 3, 3 },
		appeal = 5,
		kind = "seating",
		seats = { { -2.2, 0, 1, 0 }, { 2.2, 0, -1, 0 }, { 0, -2.2, 0, 1 }, { 0, 2.2, 0, -1 } },
		top = { 0, 3, 0 },
		build = function(B)
			squareTable(B, 2.7, 2.7, DARK, M.Metal)
			for _, side in { -1, 1 } do
				B.part({ pos = v(0, 2.8, side * 1.36), size = v(2.7, 0.1, 0.06), color = NEON_PURPLE, material = M.Neon })
				B.part({ pos = v(side * 1.36, 2.8, 0), size = v(0.06, 0.1, 2.7), color = NEON_PURPLE, material = M.Neon })
			end
			B.part({ pos = v(0, 0.2, 0), size = v(0.05, 2, 2), rot = CFrame.Angles(0, 0, math.rad(90)), shape = Enum.PartType.Cylinder, color = NEON_PURPLE, material = M.Neon, walk = true, light = { color = NEON_PURPLE, range = 10, brightness = 1.5 } })
			for _, c in { { -2.2, 0, 1, 0 }, { 2.2, 0, -1, 0 }, { 0, -2.2, 0, 1 }, { 0, 2.2, 0, -1 } } do
				chair(B, c[1], c[2], c[3], c[4], rgb(20, 20, 24), M.Fabric)
			end
		end,
	},

	-- BAR
	{
		id = "balcao_caixa",
		category = "bar",
		name = "Balcão com caixa",
		desc = "Clientes compram para viagem aqui, e os pedidos prontos ficam no balcão.",
		price = 350,
		level = 1,
		size = { 4, 2 },
		appeal = 1,
		kind = "counter",
		queue = { 0, -3.4 },
		staff = { 0, 2.8 },
		pickup = { -1.6, 3.9, 0 },
		build = function(B)
			B.part({ tag = "Uso", pos = v(0, 1.75, 0), size = v(7.8, 3.5, 2), color = WOOD, material = M.WoodPlanks })
			B.part({ pos = v(0, 1.75, -1.02), size = v(7.8, 0.4, 0.06), color = GOLD, material = M.Neon })
			B.part({ pos = v(0, 3.65, 0), size = v(8.1, 0.3, 2.4), color = rgb(30, 30, 34), material = M.Granite })
			B.part({ pos = v(2.6, 4.35, 0.25), size = v(1.6, 1.1, 1.3), color = rgb(45, 45, 50), material = M.Metal })
			B.part({ pos = v(2.6, 5.1, 0.1), size = v(1.2, 0.5, 0.1), color = rgb(60, 220, 120), material = M.Neon })
			B.part({ pos = v(0.6, 3.95, 0.4), size = v(0.9, 0.3, 0.6), color = rgb(240, 240, 240), material = M.SmoothPlastic })
		end,
	},
	{
		id = "geladeira_cerveja",
		category = "bar",
		name = "Geladeira de cerveja",
		desc = "Libera Cerveja lata e, no nível 3, Long neck.",
		price = 160,
		level = 1,
		size = { 2, 1 },
		appeal = 0,
		kind = "station",
		use = { 0, -2.3 },
		top = { 0, 7.1, 0.1 },
		build = function(B)
			fridge(B, "CERVEJA", rgb(200, 30, 35), YELLOW)
		end,
	},
	{
		id = "freezer_energetico",
		category = "bar",
		name = "Geladeira de energético",
		desc = "Libera o Energético.",
		price = 380,
		level = 2,
		size = { 2, 1 },
		appeal = 0,
		kind = "station",
		use = { 0, -2.3 },
		top = { 0, 7.1, 0.1 },
		build = function(B)
			fridge(B, "ENERGÉTICO", rgb(30, 80, 210), rgb(200, 220, 255))
		end,
	},
	{
		id = "prateleira_destilados",
		category = "bar",
		name = "Prateleira de destilados",
		desc = "Libera a Dose de cachaça.",
		price = 420,
		level = 2,
		size = { 3, 1 },
		appeal = 1,
		kind = "station",
		use = { 0, -2.3 },
		top = { 0, 3.6, -0.3 },
		build = function(B)
			B.part({ tag = "Uso", pos = v(0, 1.7, 0.2), size = v(5.6, 3.4, 1.4), color = WOOD_DARK, material = M.Wood })
			B.part({ pos = v(0, 3.45, 0), size = v(5.8, 0.15, 1.8), color = WOOD, material = M.Wood })
			B.part({ pos = v(0, 6.2, 0.75), size = v(5.6, 5.4, 0.3), color = WOOD_DARK, material = M.Wood })
			local i = 0
			for _, y in { 3.55, 5.3, 7.05 } do
				B.part({ pos = v(0, y - 0.07, 0.35), size = v(5.6, 0.14, 0.9), color = WOOD, material = M.Wood })
				for x = -2.4, 2.4, 0.8 do
					i += 1
					bottle(B, x, y, 0.35, BOTTLES[i % #BOTTLES + 1])
				end
			end
			B.part({ pos = v(0, 8.95, 0.6), size = v(5.6, 0.12, 0.12), color = rgb(255, 220, 160), material = M.Neon })
		end,
	},
	{
		id = "bancada_caipirinha",
		category = "bar",
		name = "Bancada de caipirinha",
		desc = "Limão, açúcar e pilão. Libera a Caipirinha.",
		price = 900,
		level = 3,
		size = { 2, 1 },
		appeal = 1,
		kind = "station",
		use = { 0, -2.3 },
		top = { -1, 3.7, 0.1 },
		build = function(B)
			stationCounter(B, 3.8, rgb(40, 130, 70), M.SmoothPlastic)
			B.part({ pos = v(0.6, 3.76, -0.1), size = v(1.6, 0.12, 1), color = rgb(170, 120, 70), material = M.Wood })
			for i = 0, 5 do
				B.part({ pos = v(-1.2 + (i % 3) * 0.45, 3.95, -0.3 + math.floor(i / 3) * 0.45), size = v(0.42, 0.42, 0.42), shape = Enum.PartType.Ball, color = rgb(110, 190, 50) })
			end
			B.part({ pos = v(1.3, 4.2, 0.4), size = v(0.6, 0.9, 0.6), color = WHITE, material = M.Glass, transparency = 0.3 })
			B.part({ pos = v(0, 4.9, 0.85), size = v(3.6, 1, 0.12), color = rgb(30, 110, 50), text = { text = "CAIPIRINHA", color = rgb(255, 255, 255) } })
		end,
	},
	{
		id = "estacao_copao",
		category = "bar",
		name = "Estação do copão",
		desc = "Whisky, energético e gelo de coco. Libera o Copão.",
		price = 1300,
		level = 4,
		size = { 3, 1 },
		appeal = 2,
		kind = "station",
		use = { 0, -2.3 },
		top = { -1.6, 3.7, 0.1 },
		build = function(B)
			stationCounter(B, 5.8, STEEL, M.DiamondPlate)
			B.part({ pos = v(1.8, 5.1, 0.3), size = v(2, 2.8, 1.4), color = rgb(205, 208, 214), material = M.Metal })
			B.part({ pos = v(1.8, 5.6, -0.42), size = v(1.6, 0.6, 0.06), color = NEON_BLUE, material = M.Neon })
			for i = 0, 3 do
				B.part({ pos = v(-2.2 + i * 0.75, 4.35, -0.2), size = v(0.6, 1.3, 0.6), color = WHITE, material = M.Glass, transparency = 0.45 })
			end
			bottle(B, -0.1, 3.7, 0.4, rgb(150, 90, 30))
			bottle(B, 0.45, 3.7, 0.4, rgb(150, 90, 30))
			B.part({ pos = v(0, 7.2, 0.6), size = v(4.4, 1.3, 0.15), color = rgb(255, 120, 20), material = M.Neon, text = { text = "COPÃO", color = rgb(255, 255, 255) } })
		end,
	},
	{
		id = "chopeira",
		category = "bar",
		name = "Chopeira",
		desc = "Torneiras de chopp gelado. Libera o Chopp.",
		price = 1900,
		level = 6,
		size = { 2, 1 },
		appeal = 2,
		kind = "station",
		use = { 0, -2.3 },
		top = { -1, 3.7, 0.1 },
		build = function(B)
			stationCounter(B, 3.8, WOOD_DARK, M.WoodPlanks)
			B.part({ pos = v(0, 4.6, 0.3), size = v(3, 1.8, 0.8), color = STEEL, material = M.Metal })
			for _, x in { -0.9, 0, 0.9 } do
				B.part({ pos = v(x, 4.6, -0.3), size = v(0.18, 0.5, 0.5), color = rgb(220, 220, 225), material = M.Metal })
				B.part({ pos = v(x, 5.2, -0.3), size = v(0.18, 0.9, 0.18), color = DARK, material = M.SmoothPlastic })
			end
			B.part({ pos = v(0, 6.2, 0.6), size = v(3.4, 1, 0.12), color = rgb(240, 180, 30), material = M.Neon, text = { text = "CHOPP", color = rgb(60, 25, 0) } })
		end,
	},
	{
		id = "churrasqueira",
		category = "bar",
		name = "Churrasqueira",
		desc = "Brasa e coifa. Libera o Espetinho.",
		price = 2300,
		level = 7,
		size = { 3, 2 },
		appeal = 3,
		kind = "station",
		use = { 0, -3.3 },
		top = { 2.2, 3.4, 0 },
		build = function(B)
			B.part({ tag = "Uso", pos = v(0, 1.6, 0), size = v(5.4, 3.2, 2.4), color = rgb(150, 70, 50), material = M.Brick })
			B.part({ pos = v(0, 3.25, 0), size = v(4.8, 0.2, 1.9), color = rgb(255, 110, 20), material = M.Neon, smoke = true, light = { color = rgb(255, 120, 40), range = 12, brightness = 1.6 } })
			B.part({ pos = v(0, 3.4, 0), size = v(5, 0.06, 2.1), color = DARK, material = M.DiamondPlate, transparency = 0.4 })
			for i = 0, 5 do
				B.part({ pos = v(-1.9 + i * 0.75, 3.55, 0), size = v(0.18, 0.18, 2.4), color = rgb(140, 70, 35) })
			end
			B.part({ pos = v(0, 8, 0.2), size = v(5.6, 0.5, 2.8), color = STEEL, material = M.Metal })
			B.part({ pos = v(0, 10, 0.6), size = v(1.2, 3.6, 1.2), color = STEEL, material = M.Metal })
			for _, x in { -2.6, 2.6 } do
				B.part({ pos = v(x, 5.75, 1.05), size = v(0.25, 4.4, 0.25), color = STEEL, material = M.Metal })
			end
			B.part({ pos = v(0, 8.75, -1.15), size = v(5.6, 1, 0.12), color = rgb(245, 240, 230), text = { text = "ESPETINHO", color = rgb(190, 30, 30) } })
		end,
	},
	{
		id = "bar_drinks",
		category = "bar",
		name = "Bar de drinks",
		desc = "Coqueteleira, taças e gin. Libera a Gin tônica.",
		price = 3200,
		level = 8,
		size = { 3, 1 },
		appeal = 3,
		kind = "station",
		use = { 0, -2.3 },
		top = { -1.8, 3.7, 0.1 },
		build = function(B)
			stationCounter(B, 5.8, rgb(30, 25, 40), M.SmoothPlastic)
			B.part({ pos = v(0, 1.75, -0.78), size = v(5.8, 0.15, 0.06), color = NEON_PINK, material = M.Neon })
			B.part({ pos = v(0, 5.5, 0.7), size = v(5.6, 3.4, 0.2), color = rgb(20, 20, 26), material = M.Glass, transparency = 0.2 })
			for _, y in { 4.4, 5.8 } do
				B.part({ pos = v(0, y, 0.45), size = v(5.4, 0.08, 0.6), color = rgb(200, 230, 255), material = M.Glass, transparency = 0.4 })
				for x = -2.2, 2.2, 0.88 do
					bottle(B, x, y, 0.45, rgb(150, 210, 240))
				end
			end
			B.part({ pos = v(1.4, 4.2, -0.2), size = v(0.45, 0.9, 0.45), color = STEEL, material = M.Metal })
			B.part({ pos = v(0, 7.6, 0.75), size = v(4.4, 1, 0.12), color = rgb(15, 12, 22), text = { text = "DRINKS", color = NEON_PINK } })
		end,
	},
	{
		id = "freezer_baldes",
		category = "bar",
		name = "Freezer de baldes",
		desc = "Balde com gelo e seis cervejas. Libera o Balde de cerveja.",
		price = 4200,
		level = 9,
		size = { 3, 1 },
		appeal = 2,
		kind = "station",
		use = { 0, -2.3 },
		top = { 0, 3.3, 0.1 },
		build = function(B)
			B.part({ tag = "Uso", pos = v(0, 1.5, 0.1), size = v(5.6, 3, 1.8), color = WHITE, material = M.SmoothPlastic })
			B.part({ pos = v(0, 3.05, 0.1), size = v(5.4, 0.1, 1.6), color = rgb(170, 215, 255), material = M.Glass, transparency = 0.4 })
			B.part({ pos = v(0, 1.6, -0.82), size = v(5.6, 0.8, 0.1), color = rgb(200, 30, 35), text = { text = "BALDE GELADO", color = rgb(255, 255, 255) } })
			for _, x in { -1.8, 0, 1.8 } do
				B.part({ pos = v(x, 3.6, 0.1), size = v(1, 1.1, 1.1), rot = CFrame.Angles(0, 0, math.rad(90)), shape = Enum.PartType.Cylinder, color = STEEL, material = M.Metal })
				for _, dx in { -0.2, 0.2 } do
					bottle(B, x + dx, 3.6, 0.1, rgb(40, 110, 50))
				end
			end
		end,
	},
	{
		id = "fritadeira",
		category = "bar",
		name = "Fritadeira",
		desc = "Óleo quente e cestas. Libera a Porção de batata frita.",
		price = 5200,
		level = 11,
		size = { 2, 1 },
		appeal = 1,
		kind = "station",
		use = { 0, -2.3 },
		top = { -1, 3.7, 0.1 },
		build = function(B)
			stationCounter(B, 3.8, STEEL, M.Metal)
			for _, x in { -0.8, 0.8 } do
				B.part({ pos = v(x, 3.75, 0), size = v(1.4, 0.1, 1.2), color = rgb(230, 170, 40), material = M.Glass, transparency = 0.2 })
				B.part({ pos = v(x, 4.3, -0.2), size = v(1.2, 0.6, 0.9), color = rgb(160, 160, 166), material = M.DiamondPlate, transparency = 0.3 })
			end
			B.part({ pos = v(0, 5.6, 0.7), size = v(3.4, 2, 0.2), color = STEEL, material = M.Metal })
			B.part({ pos = v(0, 6.9, 0.75), size = v(3.4, 0.9, 0.12), color = rgb(250, 200, 40), text = { text = "PORÇÕES", color = rgb(120, 20, 20) } })
		end,
	},
	{
		id = "estacao_premium",
		category = "bar",
		name = "Estação premium",
		desc = "Whisky 12 anos e LED dourado. Libera o Copão premium.",
		price = 9000,
		level = 14,
		size = { 3, 1 },
		appeal = 5,
		kind = "station",
		use = { 0, -2.3 },
		top = { -1.8, 3.7, 0.1 },
		build = function(B)
			stationCounter(B, 5.8, rgb(15, 15, 18), M.Marble)
			B.part({ pos = v(0, 1.75, -0.78), size = v(5.8, 0.18, 0.06), color = GOLD, material = M.Neon })
			B.part({ pos = v(0, 5.6, 0.75), size = v(5.6, 3.6, 0.2), color = rgb(20, 18, 14), material = M.Marble })
			for x = -2, 2, 1 do
				bottle(B, x, 3.7, 0.4, rgb(180, 110, 30))
			end
			B.part({ pos = v(0, 6.2, 0.6), size = v(4.6, 1.3, 0.12), color = rgb(15, 12, 10), text = { text = "PREMIUM", color = GOLD }, light = { color = GOLD, range = 12, brightness = 1.5 } })
		end,
	},

	-- PAREDES
	{
		id = "parede_reboco",
		category = "paredes",
		name = "Parede rebocada",
		desc = "Pega a cor de parede escolhida em Estilo.",
		price = 15,
		level = 1,
		size = { 2, 1 },
		appeal = 0,
		kind = "wall",
		build = function(B)
			wallPanel(B, { pos = v(0, WALL_H / 2, 0), size = v(4, WALL_H, 0.8) })
		end,
	},
	{
		id = "parede_tijolo",
		category = "paredes",
		name = "Parede de tijolinho",
		price = 25,
		level = 1,
		size = { 2, 1 },
		appeal = 0,
		kind = "wall",
		build = function(B)
			B.part({ pos = v(0, WALL_H / 2, 0), size = v(4, WALL_H, 0.8), color = rgb(170, 84, 60), material = M.Brick })
		end,
	},
	{
		id = "parede_janela",
		category = "paredes",
		name = "Parede com janela",
		price = 45,
		level = 1,
		size = { 2, 1 },
		appeal = 0,
		kind = "wall",
		build = function(B)
			wallPanel(B, { pos = v(0, 1.75, 0), size = v(4, 3.5, 0.8) })
			wallPanel(B, { pos = v(0, WALL_H - 2, 0), size = v(4, 4, 0.8) })
			B.part({ pos = v(0, 5.75, 0), size = v(3.4, 4.5, 0.12), color = rgb(170, 215, 255), material = M.Glass, transparency = 0.55 })
			for _, x in { -1.85, 1.85 } do
				wallPanel(B, { pos = v(x, 5.75, 0), size = v(0.3, 4.5, 0.8) })
			end
			B.part({ pos = v(0, 3.6, -0.3), size = v(4, 0.2, 0.6), color = WHITE })
		end,
	},
	{
		id = "porta_enrolar",
		category = "paredes",
		name = "Porta de enrolar",
		desc = "Uma porta de aço aberta. Os clientes passam por ela.",
		price = 40,
		level = 1,
		size = { 2, 1 },
		appeal = 0,
		kind = "door",
		build = function(B)
			header(B)
			for _, x in { -1.85, 1.85 } do
				B.part({ pos = v(x, 4.5, 0), size = v(0.3, 9, 0.8), color = rgb(120, 120, 128), material = M.Metal })
			end
			B.part({ pos = v(0, 8.4, -0.2), size = v(3.4, 1.2, 1.2), shape = Enum.PartType.Cylinder, color = rgb(150, 150, 158), material = M.CorrodedMetal })
		end,
	},
	{
		id = "vao_aberto",
		category = "paredes",
		name = "Vão aberto",
		desc = "Só a viga no alto. Use para fazer uma entrada larga.",
		price = 10,
		level = 1,
		size = { 2, 1 },
		appeal = 0,
		kind = "door",
		build = function(B)
			header(B)
		end,
	},
	{
		id = "mureta",
		category = "paredes",
		name = "Mureta",
		price = 20,
		level = 1,
		size = { 2, 1 },
		appeal = 0,
		kind = "wall",
		build = function(B)
			wallPanel(B, { pos = v(0, 1.5, 0), size = v(4, 3, 0.8) })
			B.part({ pos = v(0, 3.08, 0), size = v(4.1, 0.16, 1), color = rgb(200, 200, 205), material = M.Concrete })
		end,
	},
	{
		id = "grade_ferro",
		category = "paredes",
		name = "Grade de ferro",
		price = 60,
		level = 2,
		size = { 2, 1 },
		appeal = 0,
		kind = "wall",
		build = function(B)
			B.part({ pos = v(0, 0.3, 0), size = v(4, 0.6, 0.6), color = rgb(150, 150, 152), material = M.Concrete })
			for x = -1.8, 1.8, 0.45 do
				B.part({ pos = v(x, 3.3, 0), size = v(0.12, 5.4, 0.12), color = DARK, material = M.Metal })
			end
			B.part({ pos = v(0, 5.9, 0), size = v(4, 0.2, 0.2), color = DARK, material = M.Metal })
		end,
	},
	{
		id = "parede_quadro",
		category = "paredes",
		name = "Parede com pôster",
		price = 120,
		level = 2,
		size = { 2, 1 },
		appeal = 1,
		kind = "wall",
		build = function(B)
			wallPanel(B, { pos = v(0, WALL_H / 2, 0), size = v(4, WALL_H, 0.8) })
			B.part({ pos = v(0, 6.5, -0.45), size = v(2.8, 3.6, 0.1), color = rgb(240, 200, 40), text = { text = "CERVEJA\nGELADA", color = rgb(150, 20, 30) } })
			B.part({ pos = v(0, 6.5, -0.42), size = v(3, 3.8, 0.06), color = DARK })
		end,
	},
	{
		id = "parede_prateleira",
		category = "paredes",
		name = "Parede com prateleira",
		price = 220,
		level = 3,
		size = { 2, 1 },
		appeal = 2,
		kind = "wall",
		build = function(B)
			wallPanel(B, { pos = v(0, WALL_H / 2, 0), size = v(4, WALL_H, 0.8) })
			local i = 0
			for _, y in { 5, 7 } do
				B.part({ pos = v(0, y - 0.07, -0.7), size = v(3.6, 0.14, 0.8), color = WOOD, material = M.Wood })
				for x = -1.4, 1.4, 0.7 do
					i += 1
					bottle(B, x, y, -0.7, BOTTLES[i % #BOTTLES + 1])
				end
			end
		end,
	},
	{
		id = "parede_vidro",
		category = "paredes",
		name = "Parede de vidro",
		price = 150,
		level = 4,
		size = { 2, 1 },
		appeal = 1,
		kind = "wall",
		build = function(B)
			B.part({ pos = v(0, WALL_H / 2, 0), size = v(3.8, WALL_H - 0.4, 0.15), color = rgb(170, 215, 255), material = M.Glass, transparency = 0.6 })
			for _, x in { -1.95, 1.95 } do
				B.part({ pos = v(x, WALL_H / 2, 0), size = v(0.15, WALL_H, 0.4), color = DARK, material = M.Metal })
			end
			B.part({ pos = v(0, WALL_H - 0.1, 0), size = v(4, 0.2, 0.4), color = DARK, material = M.Metal })
			B.part({ pos = v(0, 0.1, 0), size = v(4, 0.2, 0.4), color = DARK, material = M.Metal })
		end,
	},
	{
		id = "parede_tv",
		category = "paredes",
		name = "Parede com TV do futebol",
		price = 650,
		level = 4,
		size = { 2, 1 },
		appeal = 3,
		kind = "wall",
		build = function(B)
			wallPanel(B, { pos = v(0, WALL_H / 2, 0), size = v(4, WALL_H, 0.8) })
			B.part({ pos = v(0, 7, -0.55), size = v(3.8, 2.3, 0.25), color = rgb(12, 12, 14), material = M.Metal })
			B.part({ pos = v(0, 7, -0.69), size = v(3.5, 2, 0.04), color = rgb(30, 140, 60), material = M.Neon, text = { text = "⚽ AO VIVO 2 x 1", color = rgb(255, 255, 255) } })
		end,
	},
	{
		id = "parede_neon",
		category = "paredes",
		name = "Parede com neon ADEGA",
		price = 260,
		level = 3,
		size = { 2, 1 },
		appeal = 3,
		kind = "wall",
		build = function(B)
			wallPanel(B, { pos = v(0, WALL_H / 2, 0), size = v(4, WALL_H, 0.8) })
			neonText(B, v(0, 7.5, -0.48), v(3.6, 1.6, 0.1), "ADEGA", NEON_PINK)
			for _, y in { 6.6, 8.4 } do
				B.part({ pos = v(0, y, -0.55), size = v(3.6, 0.1, 0.06), color = NEON_PINK, material = M.Neon })
			end
			B.part({ pos = v(0, 7.5, -0.7), size = v(0.2, 0.2, 0.2), transparency = 1, walk = true, light = { color = NEON_PINK, range = 10, brightness = 1.4 } })
		end,
	},
	{
		id = "parede_grafite",
		category = "paredes",
		name = "Parede grafitada",
		price = 320,
		level = 5,
		size = { 2, 1 },
		appeal = 3,
		kind = "wall",
		build = function(B)
			B.part({ pos = v(0, WALL_H / 2, 0), size = v(4, WALL_H, 0.8), color = rgb(40, 40, 52), material = M.Concrete })
			B.part({ pos = v(-0.8, 4, -0.42), size = v(2.2, 2.2, 0.05), shape = Enum.PartType.Block, color = rgb(255, 80, 60) })
			B.part({ pos = v(0.9, 7.5, -0.42), size = v(2, 3, 0.05), color = rgb(60, 200, 255) })
			B.part({ pos = v(0, 5.8, -0.46), size = v(3.8, 1.8, 0.05), color = rgb(40, 40, 52), transparency = 1, text = { text = "QUEBRADA", color = rgb(255, 230, 40), font = Enum.Font.PermanentMarker } })
		end,
	},

	-- DECORAÇÃO
	{
		id = "vaso_planta",
		category = "decoracao",
		name = "Vaso de planta",
		price = 40,
		level = 1,
		size = { 1, 1 },
		appeal = 1,
		kind = "decor",
		build = function(B)
			B.part({ pos = v(0, 0.8, 0), size = v(1.4, 1.6, 1.4), color = rgb(175, 88, 50), material = M.Concrete })
			B.part({ pos = v(0, 2.4, 0), size = v(1.9, 1.9, 1.9), shape = Enum.PartType.Ball, color = rgb(70, 150, 60), material = M.Grass })
		end,
	},
	{
		id = "engradados",
		category = "decoracao",
		name = "Pilha de engradados",
		price = 30,
		level = 1,
		size = { 1, 1 },
		appeal = 0,
		kind = "decor",
		build = function(B)
			B.part({ pos = v(0, 0.75, 0), size = v(1.7, 1.5, 1.7), color = YELLOW, material = M.Plastic })
			B.part({ pos = v(0, 2.25, 0), size = v(1.7, 1.5, 1.7), color = rgb(30, 120, 60), material = M.Plastic })
			B.part({ pos = v(0, 3.75, 0), size = v(1.7, 1.5, 1.7), color = RED, material = M.Plastic })
		end,
	},
	{
		id = "cavalete",
		category = "decoracao",
		name = "Cavalete de promoção",
		price = 90,
		level = 1,
		size = { 1, 1 },
		appeal = 1,
		kind = "decor",
		build = function(B)
			B.part({ pos = v(0, 1.8, -0.3), size = v(1.6, 3.2, 0.12), rot = CFrame.Angles(math.rad(-12), 0, 0), color = rgb(25, 25, 28), text = { text = "PROMO\nCOPÃO\nR$ 25", color = rgb(255, 255, 255), font = Enum.Font.PermanentMarker } })
			B.part({ pos = v(0, 1.8, 0.3), size = v(1.6, 3.2, 0.12), rot = CFrame.Angles(math.rad(12), 0, 0), color = WOOD, material = M.Wood })
		end,
	},
	{
		id = "lixeira",
		category = "decoracao",
		name = "Lixeira",
		price = 35,
		level = 1,
		size = { 1, 1 },
		appeal = 0,
		kind = "decor",
		build = function(B)
			B.part({ pos = v(0, 1.1, 0), size = v(2.2, 1.4, 1.4), rot = CFrame.Angles(0, 0, math.rad(90)), shape = Enum.PartType.Cylinder, color = rgb(40, 130, 70), material = M.Plastic })
			B.part({ pos = v(0, 2.3, 0), size = v(0.2, 1.5, 1.5), rot = CFrame.Angles(0, 0, math.rad(90)), shape = Enum.PartType.Cylinder, color = rgb(30, 100, 50), material = M.Plastic })
		end,
	},
	{
		id = "bandeirinhas",
		category = "decoracao",
		name = "Varal de bandeirinhas",
		desc = "Fica no alto: dá para colocar mesas embaixo.",
		price = 200,
		level = 2,
		size = { 4, 1 },
		appeal = 2,
		kind = "decor",
		layer = "air",
		build = function(B)
			for _, x in { -3.8, 3.8 } do
				B.part({ pos = v(x, 4.5, 0), size = v(0.25, 9, 0.25), color = WOOD, material = M.Wood })
			end
			B.part({ pos = v(0, 8.8, 0), size = v(7.6, 0.06, 0.06), color = DARK, walk = true })
			local colors = { rgb(230, 50, 50), rgb(255, 200, 40), rgb(40, 160, 80), rgb(40, 120, 230), rgb(240, 120, 200) }
			local i = 0
			for x = -3.3, 3.3, 0.6 do
				i += 1
				B.part({ pos = v(x, 8.35, 0), size = v(0.5, 0.8, 0.05), rot = CFrame.Angles(0, 0, math.rad(if i % 2 == 0 then 6 else -6)), color = colors[i % #colors + 1], material = M.Fabric, walk = true })
			end
		end,
	},
	{
		id = "palmeira",
		category = "decoracao",
		name = "Palmeira",
		price = 280,
		level = 3,
		size = { 2, 2 },
		appeal = 2,
		kind = "decor",
		build = function(B)
			B.part({ pos = v(0, 0.9, 0), size = v(2.4, 1.8, 2.4), color = rgb(175, 88, 50), material = M.Concrete })
			for i = 0, 5 do
				B.part({ pos = v(math.sin(i) * 0.12, 2.2 + i * 1.2, 0), size = v(0.7, 1.25, 0.7), color = rgb(130, 95, 60), material = M.Wood })
			end
			for i = 0, 5 do
				local angle = i * math.pi / 3
				B.part({
					cf = CFrame.new(0, 9.2, 0) * CFrame.Angles(0, angle, 0) * CFrame.new(0, 0, -1.6) * CFrame.Angles(math.rad(-25), 0, 0),
					size = v(0.9, 0.12, 3.4),
					color = rgb(50, 150, 60),
					material = M.Grass,
					walk = true,
				})
			end
		end,
	},
	{
		id = "jukebox",
		category = "decoracao",
		name = "Jukebox",
		price = 950,
		level = 5,
		size = { 1, 1 },
		appeal = 3,
		kind = "decor",
		build = function(B)
			B.part({ pos = v(0, 2.1, 0.1), size = v(1.8, 4.2, 1.4), color = rgb(120, 30, 40), material = M.SmoothPlastic })
			B.part({ pos = v(0, 4.3, 0.1), size = v(0.4, 1.8, 1.4), rot = CFrame.Angles(0, math.rad(90), 0), shape = Enum.PartType.Cylinder, color = rgb(120, 30, 40) })
			B.part({ pos = v(0, 3, -0.62), size = v(1.4, 1.4, 0.06), color = rgb(255, 180, 60), material = M.Neon })
			B.part({ pos = v(0, 1.4, -0.62), size = v(1.4, 0.8, 0.06), color = NEON_BLUE, material = M.Neon, light = { color = rgb(255, 150, 80), range = 8, brightness = 1 } })
		end,
	},
	{
		id = "fliperama",
		category = "decoracao",
		name = "Fliperama",
		price = 1300,
		level = 6,
		size = { 1, 1 },
		appeal = 3,
		kind = "decor",
		build = function(B)
			B.part({ pos = v(0, 2.5, 0.2), size = v(1.8, 5, 1.4), color = rgb(30, 30, 80), material = M.SmoothPlastic })
			B.part({ pos = v(0, 3.7, -0.52), size = v(1.4, 1.3, 0.06), color = rgb(60, 255, 140), material = M.Neon, text = { text = "GAME", color = rgb(10, 40, 20), font = Enum.Font.Arcade } })
			B.part({ pos = v(0, 2.6, -0.65), size = v(1.6, 0.25, 0.6), color = DARK })
			B.part({ pos = v(0, 4.85, -0.52), size = v(1.6, 0.4, 0.06), color = NEON_PINK, material = M.Neon })
		end,
	},
	{
		id = "sinuca",
		category = "decoracao",
		name = "Mesa de sinuca",
		price = 2800,
		level = 7,
		size = { 5, 3 },
		appeal = 6,
		kind = "decor",
		build = function(B)
			B.part({ pos = v(0, 2.65, 0), size = v(8.4, 0.7, 4.8), color = WOOD_DARK, material = M.Wood })
			B.part({ pos = v(0, 3.03, 0), size = v(7.6, 0.1, 4), color = rgb(30, 120, 60), material = M.Fabric })
			for _, x in { -3.6, 3.6 } do
				for _, z in { -1.8, 1.8 } do
					B.part({ pos = v(x, 1.15, z), size = v(0.6, 2.3, 0.6), color = WOOD_DARK, material = M.Wood })
				end
			end
			local balls = { rgb(255, 255, 255), rgb(240, 200, 30), rgb(200, 30, 30), rgb(30, 60, 200), rgb(20, 20, 20), rgb(240, 120, 20), rgb(120, 30, 160) }
			for i, color in balls do
				B.part({ pos = v(-2 + i * 0.6, 3.26, -0.4 + (i % 2) * 0.6), size = v(0.35, 0.35, 0.35), shape = Enum.PartType.Ball, color = color, walk = true })
			end
			B.part({ pos = v(1, 3.2, 1.2), size = v(5, 0.1, 0.1), rot = CFrame.Angles(0, math.rad(15), 0), color = rgb(200, 160, 100), material = M.Wood, walk = true })
			B.part({ pos = v(0, 8.5, 0), size = v(4, 0.4, 1), color = rgb(30, 110, 60), material = M.Metal })
			B.part({ pos = v(0, 8.25, 0), size = v(3.6, 0.1, 0.8), color = rgb(255, 240, 200), material = M.Neon, light = { color = rgb(255, 235, 200), range = 12, brightness = 1.4 } })
			B.part({ pos = v(0, 10.2, 0), size = v(0.1, 3.4, 0.1), color = DARK, walk = true })
		end,
	},
	{
		id = "cabine_dj",
		category = "decoracao",
		name = "Cabine de DJ",
		desc = "O DJ contratado toca aqui.",
		price = 3500,
		level = 9,
		size = { 3, 2 },
		appeal = 4,
		kind = "decor",
		staff = { 0, 2.6 },
		build = function(B)
			B.part({ pos = v(0, 1.8, -0.4), size = v(5.6, 3.6, 2), color = rgb(20, 20, 26), material = M.Metal })
			B.part({ pos = v(0, 1.8, -1.42), size = v(5.4, 0.25, 0.06), color = NEON_PURPLE, material = M.Neon })
			B.part({ pos = v(0, 0.9, -1.42), size = v(5.4, 0.25, 0.06), color = NEON_BLUE, material = M.Neon })
			for _, x in { -1.4, 1.4 } do
				B.part({ pos = v(x, 3.68, -0.4), size = v(0.15, 1.6, 1.6), rot = CFrame.Angles(0, 0, math.rad(90)), shape = Enum.PartType.Cylinder, color = rgb(15, 15, 15) })
			end
			B.part({ pos = v(0, 3.7, -0.4), size = v(0.9, 0.2, 1), color = rgb(60, 60, 66) })
			B.part({ pos = v(0, 1.8, -1.5), size = v(0.2, 0.2, 0.2), transparency = 1, walk = true, light = { color = NEON_PURPLE, range = 14, brightness = 2 } })
		end,
	},

	-- LUZES E SOM
	{
		id = "poste_luz",
		category = "luzes",
		name = "Poste de luz",
		price = 160,
		level = 1,
		size = { 1, 1 },
		appeal = 1,
		kind = "decor",
		build = function(B)
			B.part({ pos = v(0, 0.2, 0), size = v(1.2, 0.4, 1.2), color = DARK, material = M.Metal })
			B.part({ pos = v(0, 5, 0), size = v(0.3, 9.6, 0.3), color = DARK, material = M.Metal })
			B.part({ pos = v(0, 9.9, 0), size = v(1, 1, 1), shape = Enum.PartType.Ball, color = rgb(255, 225, 170), material = M.Neon, light = { color = rgb(255, 210, 150), range = 22, brightness = 1.5 } })
		end,
	},
	{
		id = "abajur",
		category = "luzes",
		name = "Luminária de chão",
		price = 120,
		level = 1,
		size = { 1, 1 },
		appeal = 1,
		kind = "decor",
		build = function(B)
			B.part({ pos = v(0, 0.1, 0), size = v(0.2, 1.2, 1.2), rot = CFrame.Angles(0, 0, math.rad(90)), shape = Enum.PartType.Cylinder, color = GOLD, material = M.Metal })
			B.part({ pos = v(0, 2.6, 0), size = v(0.15, 5, 0.15), color = GOLD, material = M.Metal })
			B.part({ pos = v(0, 5.3, 0), size = v(1.4, 1.6, 1.6), rot = CFrame.Angles(0, 0, math.rad(90)), shape = Enum.PartType.Cylinder, color = rgb(255, 235, 200), material = M.Neon, transparency = 0.15, light = { color = rgb(255, 220, 170), range = 14, brightness = 1.2 } })
		end,
	},
	{
		id = "caixa_som",
		category = "luzes",
		name = "Caixa de som",
		price = 320,
		level = 2,
		size = { 1, 1 },
		appeal = 2,
		kind = "decor",
		build = function(B)
			B.part({ pos = v(0, 1.9, 0), size = v(1.8, 3.8, 1.6), color = rgb(22, 22, 26), material = M.Metal })
			B.part({ pos = v(0, 1.4, -0.82), size = v(0.08, 1.4, 1.4), rot = CFrame.Angles(0, math.rad(90), 0), shape = Enum.PartType.Cylinder, color = rgb(60, 60, 66) })
			B.part({ pos = v(0, 1.4, -0.84), size = v(0.06, 1.55, 1.55), rot = CFrame.Angles(0, math.rad(90), 0), shape = Enum.PartType.Cylinder, color = NEON_BLUE, material = M.Neon, transparency = 0.3 })
			B.part({ pos = v(0, 3, -0.82), size = v(0.08, 0.7, 0.7), rot = CFrame.Angles(0, math.rad(90), 0), shape = Enum.PartType.Cylinder, color = rgb(60, 60, 66) })
		end,
	},
	{
		id = "letreiro_neon",
		category = "luzes",
		name = "Letreiro neon ADEGA 24H",
		price = 750,
		level = 4,
		size = { 2, 1 },
		appeal = 3,
		kind = "decor",
		build = function(B)
			for _, x in { -1.6, 1.6 } do
				B.part({ pos = v(x, 3, 0), size = v(0.25, 6, 0.25), color = DARK, material = M.Metal })
			end
			neonText(B, v(0, 6.8, 0), v(3.8, 2, 0.3), "ADEGA 24H", rgb(255, 210, 40))
			for _, y in { 5.75, 7.85 } do
				B.part({ pos = v(0, y, -0.17), size = v(3.8, 0.12, 0.06), color = NEON_PINK, material = M.Neon })
			end
			B.part({ pos = v(0, 6.8, -0.5), size = v(0.2, 0.2, 0.2), transparency = 1, walk = true, light = { color = rgb(255, 180, 80), range = 14, brightness = 1.5 } })
		end,
	},
	{
		id = "paredao",
		category = "luzes",
		name = "Paredão de som",
		price = 1600,
		level = 6,
		size = { 3, 1 },
		appeal = 5,
		kind = "decor",
		build = function(B)
			B.part({ pos = v(0, 3.2, 0.1), size = v(5.8, 6.4, 1.6), color = rgb(18, 18, 22), material = M.Metal })
			for _, x in { -1.9, 0, 1.9 } do
				for _, y in { 1.6, 4.6 } do
					B.part({ pos = v(x, y, -0.72), size = v(0.1, 1.7, 1.7), rot = CFrame.Angles(0, math.rad(90), 0), shape = Enum.PartType.Cylinder, color = rgb(60, 60, 66) })
					B.part({ pos = v(x, y, -0.74), size = v(0.06, 1.85, 1.85), rot = CFrame.Angles(0, math.rad(90), 0), shape = Enum.PartType.Cylinder, color = NEON_PURPLE, material = M.Neon, transparency = 0.35 })
				end
			end
			B.part({ pos = v(0, 6.5, -0.72), size = v(5.8, 0.15, 0.06), color = NEON_PINK, material = M.Neon, light = { color = NEON_PURPLE, range = 16, brightness = 1.8 } })
		end,
	},
	{
		id = "globo_luz",
		category = "luzes",
		name = "Globo espelhado",
		price = 1100,
		level = 7,
		size = { 1, 1 },
		appeal = 3,
		kind = "decor",
		spin = "Globo",
		build = function(B)
			B.part({ pos = v(0, 0.2, 0), size = v(1.2, 0.4, 1.2), color = DARK, material = M.Metal })
			B.part({ pos = v(0, 4.5, 0), size = v(0.2, 8.6, 0.2), color = DARK, material = M.Metal })
			B.part({ tag = "Globo", pos = v(0, 9.4, 0), size = v(1.6, 1.6, 1.6), shape = Enum.PartType.Ball, color = rgb(230, 230, 240), material = M.Foil, light = { color = rgb(200, 120, 255), range = 20, brightness = 1.2 } })
		end,
	},
	{
		id = "pergolado",
		category = "luzes",
		name = "Pergolado com luzes",
		desc = "Fica no alto: dá para colocar mesas embaixo.",
		price = 1900,
		level = 8,
		size = { 4, 4 },
		appeal = 5,
		kind = "decor",
		layer = "air",
		build = function(B)
			for _, x in { -3.7, 3.7 } do
				for _, z in { -3.7, 3.7 } do
					B.part({ pos = v(x, 4.6, z), size = v(0.5, 9.2, 0.5), color = WOOD, material = M.Wood })
				end
			end
			for _, z in { -3.7, 3.7 } do
				B.part({ pos = v(0, 9.35, z), size = v(8, 0.5, 0.4), color = WOOD, material = M.Wood })
			end
			for x = -3.2, 3.2, 1.6 do
				B.part({ pos = v(x, 9.75, 0), size = v(0.3, 0.3, 8.2), color = WOOD_DARK, material = M.Wood, walk = true })
			end
			local colors = { rgb(255, 210, 90), rgb(255, 130, 60), rgb(255, 90, 160), rgb(90, 220, 255) }
			local i = 0
			for _, z in { -2, 0, 2 } do
				for x = -3.3, 3.3, 1.1 do
					i += 1
					B.part({ pos = v(x, 9.05, z), size = v(0.35, 0.35, 0.35), shape = Enum.PartType.Ball, color = colors[i % #colors + 1], material = M.Neon, walk = true })
				end
			end
			B.part({ pos = v(0, 8.8, 0), size = v(0.2, 0.2, 0.2), transparency = 1, walk = true, light = { color = rgb(255, 200, 140), range = 16, brightness = 1.2 } })
		end,
	},
}

Catalog.ById = {}
for index, item in Catalog.Items do
	item.order = index
	Catalog.ById[item.id] = item
end

-- Grade -----------------------------------------------------------------------------------------

function Catalog.footprint(item, rotation)
	local w, d = item.size[1], item.size[2]
	if rotation % 2 == 1 then
		return d, w
	end
	return w, d
end

-- Ajusta um valor para o centro válido mais próximo: (centro - metade) precisa cair na grade.
function Catalog.snap(value, cells)
	local half = cells * GRID / 2
	return math.floor((value - half) / GRID + 0.5) * GRID + half
end

function Catalog.localCFrame(x, z, rotation)
	return CFrame.new(x, 0, z) * CFrame.Angles(0, rotation * math.pi / 2, 0)
end

function Catalog.inBounds(item, x, z, rotation, plotSize)
	local w, d = Catalog.footprint(item, rotation)
	local hw, hd = w * GRID / 2, d * GRID / 2
	return x - hw >= -plotSize / 2 - 0.01 and x + hw <= plotSize / 2 + 0.01 and z - hd >= -0.01 and z + hd <= plotSize + 0.01
end

function Catalog.cells(item, x, z, rotation)
	local w, d = Catalog.footprint(item, rotation)
	local minI = math.floor((x - w * GRID / 2) / GRID + 0.5)
	local minJ = math.floor((z - d * GRID / 2) / GRID + 0.5)
	local layer = item.layer or "floor"
	local list = {}
	for i = minI, minI + w - 1 do
		for j = minJ, minJ + d - 1 do
			table.insert(list, layer .. ":" .. i .. ":" .. j)
		end
	end
	return list
end

-- Construção do modelo ---------------------------------------------------------------------------

local function addText(part, spec)
	local gui = Instance.new("SurfaceGui")
	gui.Face = spec.face or Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.LightInfluence = 0
	gui.Parent = part
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = spec.text
	label.TextScaled = true
	label.Font = spec.font or Enum.Font.FredokaOne
	label.TextColor3 = spec.color or Color3.new(1, 1, 1)
	label.Parent = gui
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0.05, 0)
	padding.PaddingRight = UDim.new(0.05, 0)
	padding.PaddingTop = UDim.new(0.1, 0)
	padding.PaddingBottom = UDim.new(0.1, 0)
	padding.Parent = gui
end

-- options: wallColor, ghost (prévia sem colisão), noLights
function Catalog.buildModel(item, cframe, options)
	options = options or {}
	local model = Instance.new("Model")
	model.Name = item.id
	local wallColor = options.wallColor or DEFAULT_WALL
	local w, d = item.size[1], item.size[2]

	local root = Instance.new("Part")
	root.Name = "Raiz"
	root.Size = Vector3.new(w * GRID - 0.1, 0.2, d * GRID - 0.1)
	root.CFrame = cframe * CFrame.new(0, 0.1, 0)
	root.Transparency = 1
	root.Anchored = true
	root.CanCollide = false
	root.CanTouch = false
	root.Parent = model
	model.PrimaryPart = root

	local B = {}
	function B.part(p)
		local part = Instance.new("Part")
		part.Name = p.tag or p.name or "Peca"
		part.Anchored = true
		part.Size = p.size
		if p.cf then
			part.CFrame = cframe * p.cf
		else
			part.CFrame = cframe * CFrame.new(p.pos) * (p.rot or CFrame.identity)
		end
		part.Color = p.color or wallColor
		part.Material = p.material or Enum.Material.SmoothPlastic
		part.Transparency = p.transparency or 0
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		part.CanCollide = not p.walk and part.Transparency < 1
		part.CanTouch = false
		if p.shape then
			part.Shape = p.shape
		end
		if p.paint then
			part.Color = wallColor
			part:SetAttribute("Pintura", true)
		end
		if p.text then
			addText(part, p.text)
		end
		if p.light and not options.noLights then
			local light = Instance.new("PointLight")
			light.Color = p.light.color
			light.Range = p.light.range
			light.Brightness = p.light.brightness
			light.Shadows = false
			light.Parent = part
		end
		if p.smoke and not options.ghost then
			local smoke = Instance.new("Smoke")
			smoke.Size = 2
			smoke.Opacity = 0.12
			smoke.RiseVelocity = 3
			smoke.Color = rgb(210, 210, 210)
			smoke.Parent = part
		end
		if options.ghost then
			part.CanCollide = false
			part.CanQuery = false
			part.Transparency = math.max(part.Transparency, 0.35)
		end
		part.Parent = model
		return part
	end

	item.build(B)
	return model
end

-- Pontos do móvel no mundo, a partir do CFrame onde ele foi colocado.
function Catalog.floorPoint(cframe, point)
	return (cframe * CFrame.new(point[1], 0, point[2])).Position
end

function Catalog.point3(cframe, point)
	return (cframe * CFrame.new(point[1], point[2], point[3])).Position
end

function Catalog.isWall(item)
	return item.kind == "wall" or item.kind == "door"
end

return Catalog
