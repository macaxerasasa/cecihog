-- AdegaConfig (ModuleScript em ReplicatedStorage)
-- Catálogo do jogo, layout da adega e as regras usadas pelo servidor e pela interface.
-- Posições são relativas ao centro do terreno: a rua fica do lado -Z e a loja do lado +Z.

local Config = {}

Config.DataStoreName = "AdegaSimulator_v2"
Config.StartingCash = 150
Config.StartingItems = { atendente = 1 }
Config.PlotCount = 4 -- coloque o máximo de jogadores do servidor igual a este número
Config.PlotSpacing = 100
Config.PlotRowZ = 80
Config.MaxCustomersPerPlot = 26
Config.WalkSpeed = 9
Config.BaseCustomersPerMinute = 8
Config.BaseServiceTime = 3.5
Config.QueuePerStation = 3
Config.RoundInterval = 9
Config.DayLengthMinutes = 12
Config.MaxLevel = 25
Config.AutoSaveInterval = 60

local rgb = Color3.fromRGB
local v = Vector3.new
local M = Enum.Material

Config.Theme = {
	wine = rgb(112, 26, 44),
	gold = rgb(255, 196, 40),
	neon = rgb(190, 70, 255),
	plastic = rgb(205, 35, 40),
}

-- Produtos do cardápio. "requires" é a melhoria que libera o produto.
Config.Products = {
	{ id = "cerveja", name = "Cerveja lata", icon = "🍺", price = 8, color = rgb(250, 200, 40) },
	{ id = "dose", name = "Dose", icon = "🥃", price = 12, color = rgb(190, 110, 30), requires = "prateleira" },
	{ id = "energetico", name = "Energético", icon = "⚡", price = 10, color = rgb(40, 110, 230), requires = "freezerEnergetico" },
	{ id = "caipirinha", name = "Caipirinha", icon = "🍹", price = 18, color = rgb(150, 220, 80), requires = "bancada" },
	{ id = "espetinho", name = "Espetinho", icon = "🍢", price = 15, color = rgb(140, 70, 30), requires = "churrasqueiro" },
	{ id = "copao", name = "Copão", icon = "🥤", price = 25, color = rgb(255, 140, 30), requires = "estacaoCopao" },
	{ id = "balde", name = "Balde de cerveja", icon = "🍻", price = 45, color = rgb(230, 230, 240), requires = "freezerExtra" },
}

Config.Categories = {
	{ id = "mesas", name = "Mesas", icon = "🍻" },
	{ id = "equipe", name = "Equipe", icon = "👥" },
	{ id = "bar", name = "Bar", icon = "🍾" },
	{ id = "ambiente", name = "Ambiente", icon = "✨" },
}

-- Onde fica cada mesa: as 12 primeiras na calçada, as outras 12 na área ampliada.
Config.TableSlots = {
	{ -18, -6 }, { 18, -6 }, { -26, -6 }, { 26, -6 }, { -18, -14 }, { 18, -14 },
	{ -26, -14 }, { 26, -14 }, { -34, -6 }, { 34, -6 }, { -34, -14 }, { 34, -14 },
	{ -18, -22 }, { 18, -22 }, { -26, -22 }, { 26, -22 }, { -18, -30 }, { 18, -30 },
	{ -26, -30 }, { 26, -30 }, { -34, -22 }, { 34, -22 }, { -34, -30 }, { 34, -30 },
}

-- As 4 cadeiras de cada mesa: deslocamento a partir da mesa e direção em que o cliente olha.
Config.ChairOffsets = {
	{ dx = -2.2, dz = 0, faceX = 1, faceZ = 0 },
	{ dx = 2.2, dz = 0, faceX = -1, faceZ = 0 },
	{ dx = 0, dz = -2.2, faceX = 0, faceZ = 1 },
	{ dx = 0, dz = 2.2, faceX = 0, faceZ = -1 },
}
Config.SeatTop = 1.85

-- Onde cada funcionário fica parado. Os atendentes também definem as filas do balcão.
Config.StaffSpots = {
	atendente = { { 0, 11.6 }, { -6, 11.6 }, { 6, 11.6 } },
	garcom = { { 14.5, 3.6 }, { 16.8, 3.6 }, { 14.5, 1.6 }, { 16.8, 1.6 } },
	caixa = { { -11, 11.6 } },
	seguranca = { { -6, -40.5 }, { 6, -40.5 } },
	dj = { { 27, 11.4 } },
	churrasqueiro = { { -30, 12.8 } },
}
Config.CounterFrontZ = 6.8

Config.Outfits = {
	atendente = { label = "Atendente", shirt = rgb(255, 196, 40), pants = rgb(35, 35, 45), hat = "cap", hatColor = rgb(112, 26, 44) },
	garcom = { label = "Garçom", shirt = rgb(245, 245, 245), pants = rgb(25, 25, 30), hat = "hair", tray = true },
	caixa = { label = "Caixa", shirt = rgb(50, 170, 110), pants = rgb(35, 35, 45), hat = "hair" },
	seguranca = { label = "Segurança", shirt = rgb(20, 20, 24), pants = rgb(20, 20, 24), hat = "bald" },
	dj = { label = "DJ", shirt = rgb(150, 60, 230), pants = rgb(30, 30, 40), hat = "headphones" },
	churrasqueiro = { label = "Churrasqueiro", shirt = rgb(240, 240, 240), pants = rgb(40, 40, 50), hat = "chef" },
}

local BOTTLE_COLORS = { rgb(46, 120, 50), rgb(150, 90, 30), rgb(225, 225, 235), rgb(120, 30, 40), rgb(30, 60, 120), rgb(200, 150, 40) }

local function buildTable(add, slot)
	local tx, tz = slot[1], slot[2]
	local plastic = Config.Theme.plastic
	add({ name = "Mesa", size = v(3.4, 0.3, 3.4), pos = v(tx, 3, tz), color = plastic, material = M.Plastic })
	add({ name = "PeMesa", size = v(0.5, 2.85, 0.5), pos = v(tx, 1.43, tz), color = plastic, material = M.Plastic })
	add({ name = "Garrafa", size = v(0.35, 1.1, 0.35), pos = v(tx + 0.7, 3.7, tz - 0.5), color = rgb(40, 110, 50), material = M.Glass, transparency = 0.1 })
	for _, chair in Config.ChairOffsets do
		local cx, cz = tx + chair.dx, tz + chair.dz
		local alongX = chair.faceX ~= 0
		add({ name = "Assento", size = v(1.6, 0.25, 1.6), pos = v(cx, Config.SeatTop - 0.125, cz), color = plastic, material = M.Plastic })
		add({ name = "BaseCadeira", size = v(1.3, Config.SeatTop - 0.25, 1.3), pos = v(cx, (Config.SeatTop - 0.25) / 2, cz), color = plastic, material = M.Plastic })
		add({
			name = "Encosto",
			size = if alongX then v(0.2, 1.7, 1.6) else v(1.6, 1.7, 0.2),
			pos = v(cx - chair.faceX * 0.8, Config.SeatTop + 0.85, cz - chair.faceZ * 0.8),
			color = plastic,
			material = M.Plastic,
		})
	end
end

local function buildFridge(add, x, label, labelColor)
	add({ name = "Geladeira", size = v(4, 7, 3), pos = v(x, 3.5, 30.3), color = rgb(235, 235, 240), material = M.SmoothPlastic })
	add({ name = "PortaVidro", size = v(3.4, 5.8, 0.2), pos = v(x, 3.5, 28.7), color = rgb(160, 210, 255), material = M.Glass, transparency = 0.35 })
	for row = 0, 3 do
		add({ name = "Latas", size = v(3, 0.9, 0.3), pos = v(x, 1.3 + row * 1.35, 28.95), color = labelColor, material = M.Metal })
	end
	add({ name = "Letreiro", size = v(4, 1, 0.2), pos = v(x, 7.5, 28.7), color = labelColor, text = label, textColor = rgb(255, 255, 255) })
end

-- A loja que todo jogador recebe. As peças chamadas Caixa, Cardapio e PlacaFachada são usadas pelo servidor.
function Config.buildBase(add, ctx)
	local wine = Config.Theme.wine
	-- calçada
	add({ name = "Calcada", size = v(84, 0.1, 24), pos = v(0, 0.05, -6), color = rgb(196, 186, 170), material = M.Pavement })
	add({ name = "Corredor", size = v(20, 0.1, 24), pos = v(0, 0.05, -30), color = rgb(196, 186, 170), material = M.Pavement })
	-- loja
	add({ name = "PisoLoja", size = v(36, 0.3, 26), pos = v(0, 0.15, 19.5), color = rgb(222, 210, 188), material = M.Slate })
	add({ name = "ParedeFundo", size = v(38, 14, 1), pos = v(0, 7, 33), color = wine, material = M.Brick })
	add({ name = "ParedeEsquerda", size = v(1, 14, 27), pos = v(-18.5, 7, 19.5), color = wine, material = M.Brick })
	add({ name = "ParedeDireita", size = v(1, 14, 27), pos = v(18.5, 7, 19.5), color = wine, material = M.Brick })
	add({ name = "PilarEsquerdo", size = v(4, 14, 1), pos = v(-16, 7, 6.5), color = wine, material = M.Brick })
	add({ name = "PilarDireito", size = v(4, 14, 1), pos = v(16, 7, 6.5), color = wine, material = M.Brick })
	add({ name = "Viga", size = v(38, 4, 1), pos = v(0, 12, 6.5), color = rgb(35, 30, 35), material = M.Concrete })
	add({ name = "Telhado", size = v(38, 1, 28), pos = v(0, 14.5, 19.5), color = rgb(60, 60, 66), material = M.Concrete })
	add({ name = "PortaoEnrolado", size = v(28, 1.4, 1.4), pos = v(0, 9.3, 7.2), color = rgb(140, 140, 148), material = M.CorrodedMetal })
	for _, x in { -14, 14 } do
		add({ name = "TrilhoPortao", size = v(0.4, 9.3, 0.6), pos = v(x, 4.65, 7.2), color = rgb(120, 120, 128), material = M.Metal })
	end
	add({
		name = "PlacaFachada",
		size = v(20, 3, 0.3),
		pos = v(0, 12, 5.85),
		color = rgb(20, 18, 24),
		text = "ADEGA " .. string.upper(ctx.ownerName),
		textColor = Config.Theme.gold,
	})
	-- balcão
	add({ name = "Balcao", size = v(24, 3.6, 2.5), pos = v(0, 1.8, 9.25), color = rgb(105, 66, 38), material = M.WoodPlanks })
	add({ name = "TampoGranito", size = v(24.6, 0.35, 3), pos = v(0, 3.78, 9.25), color = rgb(30, 30, 34), material = M.Granite })
	add({ name = "Caixa", size = v(1.8, 1.1, 1.4), pos = v(-11, 4.5, 9.4), color = rgb(45, 45, 50), material = M.Metal })
	add({ name = "Engradados", size = v(2.4, 2.4, 2.4), pos = v(15.5, 1.2, 25), color = rgb(240, 190, 30), material = M.Plastic })
	add({ name = "Engradados", size = v(2.4, 2.4, 2.4), pos = v(15.5, 3.6, 25.3), color = rgb(30, 120, 60), material = M.Plastic })
	buildFridge(add, -14, "CERVEJA", rgb(200, 30, 35))
	add({ name = "Cardapio", size = v(11, 5, 0.2), pos = v(6, 10.3, 32.4), color = rgb(15, 15, 18), text = "", textColor = rgb(255, 255, 255), font = Enum.Font.GothamBold })
	add({ name = "Lampada", size = v(10, 0.3, 0.6), pos = v(0, 13.8, 19), color = rgb(255, 245, 225), material = M.Neon, light = { color = rgb(255, 236, 205), range = 26, brightness = 1.4 } })
	-- postes da rua
	for _, x in { -40, 40 } do
		add({ name = "Poste", size = v(0.5, 15, 0.5), pos = v(x, 7.5, -41), color = rgb(60, 60, 66), material = M.Metal })
		add({ name = "BracoPoste", size = v(3.5, 0.4, 0.4), pos = v(x - math.sign(x) * 1.5, 15, -41), color = rgb(60, 60, 66), material = M.Metal })
		add({ name = "Luminaria", size = v(1.6, 0.4, 1), pos = v(x - math.sign(x) * 3, 14.7, -41), color = rgb(255, 220, 160), material = M.Neon, light = { color = rgb(255, 210, 150), range = 34, brightness = 1.6 } })
	end
	-- muro
	add({ name = "MuroEsquerdo", size = v(1, 4, 36), pos = v(-41.5, 2, 24), color = rgb(176, 96, 74), material = M.Brick })
	add({ name = "MuroDireito", size = v(1, 4, 36), pos = v(41.5, 2, 24), color = rgb(176, 96, 74), material = M.Brick })
	add({ name = "MuroFundo", size = v(84, 4, 1), pos = v(0, 2, 41.5), color = rgb(176, 96, 74), material = M.Brick })
end

-- Melhorias. effects são somados por nível: seats (lugares), attraction (clientes/min), ambiance (pontos de
-- ambiente), stations (filas no balcão), waiters (garçons), capacity (lotação), rating (estrelas),
-- serviceSpeed (atendimento mais rápido) e autoCollect (recolhe o caixa sozinho).
-- build(add, level, ctx) cria as peças daquele nível; funcionários aparecem sozinhos.
Config.Items = {
	-- MESAS
	{
		id = "mesas",
		category = "mesas",
		name = "Mesa com 4 cadeiras",
		icon = "🍻",
		desc = "Clientes sentam e ficam mais tempo. Com garçom, pedem mais rodadas.",
		maxLevel = 12,
		basePrice = 60,
		growth = 1.28,
		levelReq = 1,
		effects = { seats = 4, attraction = 0.6 },
		build = function(add, level)
			buildTable(add, Config.TableSlots[level])
		end,
	},
	{
		id = "ampliacao",
		category = "mesas",
		name = "Ampliar a calçada",
		icon = "🏗",
		desc = "Pavimenta a área da frente e libera mais 12 mesas.",
		maxLevel = 1,
		basePrice = 5000,
		levelReq = 6,
		requires = { mesas = 12 },
		effects = { attraction = 2 },
		build = function(add)
			for _, x in { -26, 26 } do
				add({ name = "CalcadaNova", size = v(32, 0.1, 24), pos = v(x, 0.05, -30), color = rgb(196, 186, 170), material = M.Pavement })
			end
			for _, x in { -40, 40 } do
				add({ name = "Floreira", size = v(2.6, 2, 2.6), pos = v(x, 1, -20), color = rgb(170, 85, 50), material = M.Concrete })
				add({ name = "Planta", size = v(3, 3, 3), pos = v(x, 3.2, -20), shape = Enum.PartType.Ball, color = rgb(60, 140, 60), material = M.Grass })
			end
		end,
	},
	{
		id = "mesasExtra",
		category = "mesas",
		name = "Mesa na área nova",
		icon = "🍻",
		desc = "Mais mesas na calçada ampliada.",
		maxLevel = 12,
		basePrice = 1200,
		growth = 1.15,
		levelReq = 6,
		requires = { ampliacao = 1 },
		effects = { seats = 4, attraction = 0.6 },
		build = function(add, level)
			buildTable(add, Config.TableSlots[12 + level])
		end,
	},

	-- EQUIPE
	{
		id = "atendente",
		category = "equipe",
		name = "Atendente",
		icon = "🙋",
		desc = "Atende no balcão. Cada atendente abre mais uma fila.",
		maxLevel = 3,
		basePrice = 450,
		growth = 4,
		levelReq = 2,
		effects = { stations = 1 },
	},
	{
		id = "garcom",
		category = "equipe",
		name = "Garçom",
		icon = "🤵",
		desc = "Leva rodadas até as mesas. Sem garçom, quem senta só bebe uma vez.",
		maxLevel = 4,
		basePrice = 350,
		growth = 2.6,
		levelReq = 2,
		requires = { mesas = 2 },
		effects = { waiters = 1, rating = 0.1 },
	},
	{
		id = "caixa",
		category = "equipe",
		name = "Operador de caixa",
		icon = "💵",
		desc = "Recolhe o dinheiro do caixa sozinho. Você não precisa mais ir até o balcão.",
		maxLevel = 1,
		basePrice = 2500,
		levelReq = 4,
		effects = { autoCollect = true },
	},
	{
		id = "seguranca",
		category = "equipe",
		name = "Segurança",
		icon = "🕶",
		desc = "Deixa o ambiente tranquilo: cabe mais gente e a avaliação sobe.",
		maxLevel = 2,
		basePrice = 4000,
		growth = 2.5,
		levelReq = 7,
		effects = { capacity = 6, rating = 0.4 },
	},
	{
		id = "churrasqueiro",
		category = "equipe",
		name = "Churrasqueiro",
		icon = "🍢",
		desc = "Assa espetinho na brasa. Libera o espetinho no cardápio.",
		maxLevel = 1,
		basePrice = 3500,
		levelReq = 6,
		requires = { churrasqueira = 1 },
		effects = { attraction = 1 },
	},
	{
		id = "dj",
		category = "equipe",
		name = "DJ",
		icon = "🎧",
		desc = "Comanda o som da noite. Atrai muita gente.",
		maxLevel = 1,
		basePrice = 9000,
		levelReq = 9,
		requires = { paredao = 1 },
		effects = { attraction = 5, ambiance = 4 },
		build = function(add)
			add({ name = "CabineDJ", size = v(5, 3.4, 2), pos = v(27, 1.7, 9.6), color = rgb(25, 25, 30), material = M.Metal })
			add({ name = "NeonDJ", size = v(5, 0.25, 0.1), pos = v(27, 2.6, 8.55), color = Config.Theme.neon, material = M.Neon })
			for _, x in { 25.8, 28.2 } do
				add({ name = "TocaDisco", size = v(0.15, 1.6, 1.6), pos = v(x, 3.48, 9.6), rot = CFrame.Angles(0, 0, math.rad(90)), shape = Enum.PartType.Cylinder, color = rgb(15, 15, 15) })
			end
		end,
	},

	-- BAR
	{
		id = "prateleira",
		category = "bar",
		name = "Prateleira de destilados",
		icon = "🥃",
		desc = "Estante cheia de garrafas no fundo da loja.",
		maxLevel = 1,
		basePrice = 300,
		levelReq = 2,
		effects = { ambiance = 1 },
		build = function(add)
			add({ name = "Estante", size = v(14, 7, 1.4), pos = v(6, 3.5, 31.8), color = rgb(70, 45, 25), material = M.Wood })
			local i = 0
			for _, y in { 1.5, 3.8, 6.1 } do
				add({ name = "Tabua", size = v(14, 0.25, 1.8), pos = v(6, y, 31.4), color = rgb(95, 62, 36), material = M.Wood })
				for x = 0, 11 do
					i += 1
					add({
						name = "Garrafa",
						size = v(0.5, 1.5, 0.5),
						pos = v(0.5 + x, y + 0.875, 31),
						color = BOTTLE_COLORS[i % #BOTTLE_COLORS + 1],
						material = M.Glass,
						transparency = 0.12,
					})
				end
			end
		end,
	},
	{
		id = "freezerEnergetico",
		category = "bar",
		name = "Geladeira de energético",
		icon = "⚡",
		desc = "Energético gelado para misturar.",
		maxLevel = 1,
		basePrice = 700,
		levelReq = 3,
		build = function(add)
			buildFridge(add, -9.5, "ENERGÉTICO", rgb(30, 80, 210))
		end,
	},
	{
		id = "maquinaGelo",
		category = "bar",
		name = "Máquina de gelo",
		icon = "🧊",
		desc = "Gelo sempre pronto: o atendimento fica mais rápido.",
		maxLevel = 1,
		basePrice = 1100,
		levelReq = 3,
		effects = { serviceSpeed = 0.35 },
		build = function(add)
			add({ name = "MaquinaGelo", size = v(3, 5, 2.6), pos = v(15.5, 2.5, 30.4), color = rgb(190, 190, 196), material = M.DiamondPlate })
			add({ name = "PlacaGelo", size = v(3, 0.8, 0.2), pos = v(15.5, 5.6, 29), color = rgb(40, 150, 210), text = "GELO", textColor = rgb(255, 255, 255) })
		end,
	},
	{
		id = "bancada",
		category = "bar",
		name = "Bancada de caipirinha",
		icon = "🍹",
		desc = "Limão, açúcar e pilão no balcão. Libera a caipirinha.",
		maxLevel = 1,
		basePrice = 1600,
		levelReq = 4,
		build = function(add)
			add({ name = "TabuaCorte", size = v(2.2, 0.12, 1.3), pos = v(-3.5, 4.02, 9.4), color = rgb(160, 110, 60), material = M.Wood })
			for i = 0, 4 do
				add({ name = "Limao", size = v(0.45, 0.45, 0.45), pos = v(-4.3 + i * 0.4, 4.3, 9.6 - (i % 2) * 0.4), shape = Enum.PartType.Ball, color = rgb(110, 190, 50) })
			end
			add({ name = "PlacaCaipirinha", size = v(3, 1, 0.2), pos = v(-3.5, 5, 8.4), color = rgb(40, 140, 60), text = "CAIPIRINHA", textColor = rgb(255, 255, 255) })
		end,
	},
	{
		id = "estacaoCopao",
		category = "bar",
		name = "Estação do copão",
		icon = "🥤",
		desc = "Whisky, energético e gelo de coco. O carro-chefe da adega.",
		maxLevel = 1,
		basePrice = 2400,
		levelReq = 5,
		requires = { maquinaGelo = 1, prateleira = 1 },
		effects = { attraction = 2 },
		build = function(add)
			for i = 0, 2 do
				add({ name = "Copao", size = v(0.9, 1.4, 0.9), pos = v(9 + i * 1.1, 4.65, 9.6), color = rgb(255, 255, 255), material = M.Glass, transparency = 0.45 })
			end
			add({ name = "PlacaCopao", size = v(3.4, 1.1, 0.2), pos = v(10, 5.2, 8.4), color = rgb(255, 120, 20), material = M.Neon, text = "COPÃO", textColor = rgb(255, 255, 255) })
		end,
	},
	{
		id = "churrasqueira",
		category = "bar",
		name = "Churrasqueira",
		icon = "🔥",
		desc = "Churrasqueira com coifa na lateral da adega. Contrate um churrasqueiro para vender espetinho.",
		maxLevel = 1,
		basePrice = 2800,
		levelReq = 6,
		effects = { ambiance = 2 },
		build = function(add)
			add({ name = "Churrasqueira", size = v(5, 3.2, 2.2), pos = v(-30, 1.6, 10.6), color = rgb(45, 45, 50), material = M.Metal })
			add({ name = "Brasa", size = v(4.6, 0.2, 1.8), pos = v(-30, 3.25, 10.6), color = rgb(255, 110, 20), material = M.Neon, smoke = true, light = { color = rgb(255, 120, 40), range = 10, brightness = 1.5 } })
			for i = 0, 4 do
				add({ name = "Espeto", size = v(0.18, 0.18, 2.6), pos = v(-31.6 + i * 0.8, 3.45, 10.6), color = rgb(130, 70, 35) })
			end
			add({ name = "Coifa", size = v(5.6, 0.4, 3), pos = v(-30, 7.5, 10.8), color = rgb(150, 150, 156), material = M.Metal })
			for _, x in { -32.6, -27.4 } do
				add({ name = "HasteCoifa", size = v(0.3, 4.2, 0.3), pos = v(x, 5.4, 11.9), color = rgb(150, 150, 156), material = M.Metal })
			end
			add({ name = "PlacaEspetinho", size = v(5.6, 1.2, 0.2), pos = v(-30, 8.3, 9.4), color = rgb(245, 240, 230), text = "ESPETINHO", textColor = rgb(190, 30, 30) })
		end,
	},
	{
		id = "freezerExtra",
		category = "bar",
		name = "Freezer de baldes",
		icon = "🍻",
		desc = "Balde com gelo e seis cervejas. Libera o balde no cardápio.",
		maxLevel = 1,
		basePrice = 7500,
		levelReq = 8,
		build = function(add)
			buildFridge(add, -5, "BALDE", rgb(230, 120, 20))
		end,
	},

	-- AMBIENTE
	{
		id = "toldo",
		category = "ambiente",
		name = "Toldo listrado",
		icon = "⛱",
		desc = "Sombra na frente da adega.",
		maxLevel = 1,
		basePrice = 200,
		levelReq = 1,
		effects = { ambiance = 2 },
		build = function(add)
			for i = 0, 8 do
				add({
					name = "Toldo",
					size = v(4, 0.3, 7.4),
					pos = v(-16 + i * 4, 9.1, 2.5),
					rot = CFrame.Angles(math.rad(-15), 0, 0),
					color = if i % 2 == 0 then rgb(200, 30, 40) else rgb(250, 248, 240),
					material = M.Fabric,
				})
			end
		end,
	},
	{
		id = "plantas",
		category = "ambiente",
		name = "Vasos de plantas",
		icon = "🌿",
		desc = "Um pouco de verde na calçada.",
		maxLevel = 1,
		basePrice = 500,
		levelReq = 2,
		effects = { ambiance = 2 },
		build = function(add)
			for _, spot in { { -12, -40 }, { 12, -40 }, { -21, 4 }, { 21, 4 }, { -40, 3 }, { 40, 3 } } do
				add({ name = "Vaso", size = v(2, 1.8, 2), pos = v(spot[1], 0.9, spot[2]), color = rgb(170, 85, 50), material = M.Concrete })
				add({ name = "Folhagem", size = v(2.6, 2.6, 2.6), pos = v(spot[1], 2.8, spot[2]), shape = Enum.PartType.Ball, color = rgb(70, 150, 60), material = M.Grass })
			end
		end,
	},
	{
		id = "varal",
		category = "ambiente",
		name = "Varal de luzes",
		icon = "💡",
		desc = "Lâmpadas coloridas sobre as mesas. Fica lindo à noite.",
		maxLevel = 1,
		basePrice = 900,
		levelReq = 3,
		effects = { ambiance = 3 },
		build = function(add)
			local colors = { rgb(255, 210, 90), rgb(255, 120, 60), rgb(255, 90, 160), rgb(90, 220, 255) }
			for _, z in { -10, -26 } do
				for _, x in { -40, 40 } do
					add({ name = "PosteVaral", size = v(0.4, 11.5, 0.4), pos = v(x, 5.75, z), color = rgb(50, 50, 55), material = M.Wood })
				end
				add({ name = "Fio", size = v(80, 0.08, 0.08), pos = v(0, 11.3, z), color = rgb(20, 20, 20) })
				local i = 0
				for x = -38, 38, 4 do
					i += 1
					add({ name = "Lampada", size = v(0.6, 0.6, 0.6), pos = v(x, 10.9, z), shape = Enum.PartType.Ball, color = colors[i % #colors + 1], material = M.Neon })
				end
				for _, x in { -20, 20 } do
					add({ name = "LuzVaral", size = v(0.2, 0.2, 0.2), pos = v(x, 10.5, z), transparency = 1, light = { color = rgb(255, 200, 140), range = 20, brightness = 1 } })
				end
			end
		end,
	},
	{
		id = "led",
		category = "ambiente",
		name = "Neon na fachada",
		icon = "🌈",
		desc = "Contorno de LED roxo na fachada da adega.",
		maxLevel = 1,
		basePrice = 1400,
		levelReq = 4,
		effects = { ambiance = 3 },
		build = function(add)
			local neon = Config.Theme.neon
			for _, x in { -18.2, 18.2 } do
				add({ name = "NeonLado", size = v(0.3, 14, 0.3), pos = v(x, 7, 5.85), color = neon, material = M.Neon })
			end
			add({ name = "NeonTopo", size = v(36.7, 0.3, 0.3), pos = v(0, 14.15, 5.85), color = neon, material = M.Neon })
			add({ name = "NeonViga", size = v(28, 0.3, 0.3), pos = v(0, 9.95, 5.85), color = neon, material = M.Neon, light = { color = neon, range = 18, brightness = 2 } })
		end,
	},
	{
		id = "tv",
		category = "ambiente",
		name = "TV do futebol",
		icon = "📺",
		desc = "Dia de jogo enche a calçada.",
		maxLevel = 1,
		basePrice = 2000,
		levelReq = 5,
		effects = { ambiance = 3, attraction = 2 },
		build = function(add)
			add({ name = "TV", size = v(7, 3.8, 0.4), pos = v(-14, 12, 5.6), color = rgb(15, 15, 18), material = M.Metal })
			add({ name = "TelaTV", size = v(6.4, 3.3, 0.05), pos = v(-14, 12, 5.38), color = rgb(30, 130, 60), material = M.Neon, text = "⚽ AO VIVO  2 x 1", textColor = rgb(255, 255, 255) })
		end,
	},
	{
		id = "paredao",
		category = "ambiente",
		name = "Paredão de som",
		icon = "🔊",
		desc = "Duas caixas grandes na frente da adega.",
		maxLevel = 1,
		basePrice = 4200,
		levelReq = 6,
		effects = { ambiance = 4, attraction = 3 },
		build = function(add)
			local facing = CFrame.Angles(0, math.rad(90), 0)
			for _, x in { -21.5, 21.5 } do
				add({ name = "CaixaDeSom", size = v(4, 8, 3.4), pos = v(x, 4, 8), color = rgb(22, 22, 26), material = M.Metal })
				add({ name = "Grave", size = v(0.3, 3, 3), pos = v(x, 2.6, 6.2), rot = facing, shape = Enum.PartType.Cylinder, color = rgb(60, 60, 66) })
				add({ name = "Medio", size = v(0.3, 1.8, 1.8), pos = v(x, 5.6, 6.2), rot = facing, shape = Enum.PartType.Cylinder, color = rgb(60, 60, 66) })
				add({ name = "NeonCaixa", size = v(4, 0.2, 0.1), pos = v(x, 7.6, 6.25), color = Config.Theme.neon, material = M.Neon })
			end
		end,
	},
	{
		id = "porcelanato",
		category = "ambiente",
		name = "Porcelanato na calçada",
		icon = "✨",
		desc = "Piso claro e brilhante na frente da adega.",
		maxLevel = 1,
		basePrice = 5000,
		levelReq = 7,
		effects = { ambiance = 3 },
		build = function(add)
			add({ name = "Porcelanato", size = v(84, 0.06, 24), pos = v(0, 0.13, -6), color = rgb(232, 226, 216), material = M.Marble })
			add({ name = "PorcelanatoCorredor", size = v(20, 0.06, 24), pos = v(0, 0.13, -30), color = rgb(232, 226, 216), material = M.Marble })
		end,
	},
	{
		id = "sinuca",
		category = "ambiente",
		name = "Mesa de sinuca",
		icon = "🎱",
		desc = "Sinuca coberta na lateral. A galera fica até tarde.",
		maxLevel = 1,
		basePrice = 7000,
		levelReq = 8,
		effects = { ambiance = 4, attraction = 3 },
		build = function(add)
			add({ name = "Moldura", size = v(8.4, 0.7, 4.8), pos = v(31, 2.65, 22), color = rgb(90, 50, 25), material = M.Wood })
			add({ name = "Feltro", size = v(7.6, 0.1, 4), pos = v(31, 3.03, 22), color = rgb(30, 120, 60), material = M.Fabric })
			for _, x in { 27.4, 34.6 } do
				for _, z in { 20.2, 23.8 } do
					add({ name = "Pe", size = v(0.6, 2.3, 0.6), pos = v(x, 1.15, z), color = rgb(70, 40, 20), material = M.Wood })
				end
			end
			local ballColors = { rgb(255, 255, 255), rgb(240, 200, 30), rgb(200, 30, 30), rgb(30, 60, 200), rgb(20, 20, 20), rgb(240, 120, 20) }
			for i, color in ballColors do
				add({ name = "Bola", size = v(0.35, 0.35, 0.35), pos = v(29 + i * 0.7, 3.26, 21.6 + (i % 2) * 0.6), shape = Enum.PartType.Ball, color = color })
			end
			for _, x in { 25.5, 36.5 } do
				for _, z in { 16.5, 27.5 } do
					add({ name = "Pilar", size = v(0.4, 9, 0.4), pos = v(x, 4.5, z), color = rgb(60, 60, 66), material = M.Metal })
				end
			end
			add({ name = "Cobertura", size = v(12, 0.4, 12), pos = v(31, 9.2, 22), color = rgb(140, 30, 40), material = M.Metal })
			add({ name = "LuzSinuca", size = v(4, 0.3, 0.8), pos = v(31, 8.2, 22), color = rgb(255, 240, 200), material = M.Neon, light = { color = rgb(255, 235, 200), range = 14, brightness = 1.5 } })
		end,
	},
	{
		id = "letreiro",
		category = "ambiente",
		name = "Letreiro luminoso",
		icon = "🌟",
		desc = "Um letreiro enorme em cima da adega. Dá para ver da rua toda.",
		maxLevel = 1,
		basePrice = 14000,
		levelReq = 10,
		effects = { ambiance = 6, attraction = 3 },
		build = function(add, _, ctx)
			for _, x in { -8, 8 } do
				add({ name = "Suporte", size = v(0.5, 3, 0.5), pos = v(x, 16.5, 7.5), color = rgb(50, 50, 55), material = M.Metal })
			end
			add({
				name = "Letreiro",
				size = v(26, 6, 0.6),
				pos = v(0, 20.5, 7.2),
				color = rgb(15, 12, 22),
				text = "ADEGA " .. string.upper(ctx.ownerName),
				textColor = Config.Theme.gold,
				light = { color = Config.Theme.gold, range = 24, brightness = 1.5 },
			})
			for _, y in { 17.4, 23.6 } do
				add({ name = "Moldura", size = v(26.4, 0.3, 0.3), pos = v(0, y, 6.85), color = Config.Theme.gold, material = M.Neon })
			end
			for _, x in { -13.1, 13.1 } do
				add({ name = "Moldura", size = v(0.3, 6.5, 0.3), pos = v(x, 20.5, 6.85), color = Config.Theme.gold, material = M.Neon })
			end
		end,
	},
}

Config.ItemById = {}
for index, item in Config.Items do
	item.order = index
	Config.ItemById[item.id] = item
end

function Config.getStartLevel(itemId)
	return Config.StartingItems[itemId] or 0
end

function Config.getPrice(item, currentLevel)
	local bought = currentLevel - Config.getStartLevel(item.id)
	return math.floor(item.basePrice * (item.growth or 1) ^ bought)
end

function Config.xpForLevel(level)
	return math.floor(120 * 1.42 ^ (level - 1))
end

-- Diz se o item pode ser comprado agora. Devolve o status e um texto para a interface:
-- "max", "level", "requires", "money" ou "ok".
function Config.purchaseStatus(item, items, level, cash)
	local current = items[item.id] or 0
	if current >= item.maxLevel then
		return "max", "MÁXIMO"
	end
	if level < (item.levelReq or 1) then
		return "level", "Nível " .. item.levelReq
	end
	if item.requires then
		for id, needed in item.requires do
			if (items[id] or 0) < needed then
				local other = Config.ItemById[id]
				local text = other.name
				if needed > 1 then
					text = needed .. "x " .. other.name
				end
				return "requires", "Requer " .. text
			end
		end
	end
	if cash < Config.getPrice(item, current) then
		return "money", nil
	end
	return "ok", nil
end

function Config.unlockedProducts(items)
	local list = {}
	for _, product in Config.Products do
		if product.requires == nil or (items[product.requires] or 0) > 0 then
			table.insert(list, product)
		end
	end
	return list
end

function Config.formatMoney(amount)
	local digits = tostring(math.floor(amount))
	local grouped = digits:reverse():gsub("(%d%d%d)", "%1."):reverse()
	if grouped:sub(1, 1) == "." then
		grouped = grouped:sub(2)
	end
	return "R$ " .. grouped
end

function Config.formatDecimal(value)
	return (string.format("%.1f", value):gsub("%.", ","))
end

return Config
