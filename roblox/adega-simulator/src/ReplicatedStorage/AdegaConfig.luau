-- AdegaConfig (ModuleScript em ReplicatedStorage)
-- Tudo que dá para ajustar no jogo sem mexer na lógica: preços, ganhos e o que cada melhoria constrói.
-- As posições ("pos") são relativas ao centro do terreno; a rua fica do lado -Z.

local Config = {}

Config.DataStoreName = "AdegaSimulator_v1"
Config.StartingCash = 100
Config.PlotCount = 6 -- coloque o máximo de jogadores do servidor igual a este número
Config.PlotSpacing = 80
Config.PlotRowZ = 90
Config.MaxCustomersPerPlot = 12
Config.WalkSpeed = 10
Config.AutoSaveInterval = 60

local rgb = Color3.fromRGB
local v = Vector3.new
local M = Enum.Material

local BOTTLE_COLORS = { rgb(46, 120, 50), rgb(150, 90, 30), rgb(220, 220, 230), rgb(120, 30, 40), rgb(30, 60, 120) }

-- Cada melhoria: id, name, price, requires (id ou lista de ids), customers (clientes por minuto),
-- ticket (R$ que cada cliente gasta), autoCollect e build(add, ctx), que cria as peças com add{...}.
-- A ordem da lista define a posição do botão no terreno.
Config.Upgrades = {
	{
		id = "balcao",
		name = "Balcão e piso",
		price = 50,
		customers = 12,
		ticket = 10,
		build = function(add)
			add({ name = "Piso", size = v(40, 0.2, 32), pos = v(0, 0.1, 8), color = rgb(214, 205, 186), material = M.Slate })
			add({ name = "Balcao", size = v(16, 3.5, 2.5), pos = v(0, 1.75, 0), color = rgb(120, 78, 45), material = M.WoodPlanks })
			add({ name = "TampoGranito", size = v(16.4, 0.3, 3), pos = v(0, 3.65, 0), color = rgb(40, 40, 45), material = M.Granite })
			add({ name = "CaixaRegistradora", size = v(1.6, 1, 1.2), pos = v(5, 4.3, 0.3), color = rgb(60, 60, 60) })
		end,
	},
	{
		id = "freezer",
		name = "Freezer de cerveja",
		price = 200,
		requires = "balcao",
		customers = 2,
		ticket = 5,
		build = function(add)
			add({ name = "Freezer", size = v(4, 6, 3), pos = v(-15, 3, 21), color = rgb(235, 235, 235) })
			add({ name = "PortaVidro", size = v(3.4, 5, 0.2), pos = v(-15, 3, 19.4), color = rgb(150, 200, 255), material = M.Glass, transparency = 0.4 })
			add({ name = "Letreiro", size = v(4, 1, 0.2), pos = v(-15, 6.5, 19.4), color = rgb(200, 30, 30), text = "CERVEJA GELADA" })
		end,
	},
	{
		id = "paredes",
		name = "Paredes, teto e portão",
		price = 400,
		requires = "balcao",
		customers = 3,
		build = function(add)
			local wall = rgb(245, 200, 60)
			add({ name = "ParedeFundo", size = v(42, 12, 1), pos = v(0, 6, 24.5), color = wall })
			add({ name = "ParedeEsquerda", size = v(1, 12, 33), pos = v(-20.5, 6, 8.5), color = wall })
			add({ name = "ParedeDireita", size = v(1, 12, 33), pos = v(20.5, 6, 8.5), color = wall })
			add({ name = "VigaFrente", size = v(42, 3, 1), pos = v(0, 10.5, -8.5), color = wall })
			add({ name = "Teto", size = v(42, 1, 34.5), pos = v(0, 12.5, 8.25), color = rgb(150, 150, 150), material = M.Concrete })
			add({ name = "PortaoDeEnrolar", size = v(40, 1.5, 1.2), pos = v(0, 8.25, -8.3), color = rgb(130, 130, 135), material = M.CorrodedMetal })
		end,
	},
	{
		id = "placa",
		name = "Placa da adega",
		price = 700,
		requires = "paredes",
		customers = 6,
		build = function(add, ctx)
			add({
				name = "Placa",
				size = v(24, 4.5, 0.6),
				pos = v(0, 15.25, -8.6),
				color = rgb(20, 20, 20),
				text = "ADEGA " .. string.upper(ctx.ownerName),
				textColor = rgb(255, 210, 0),
			})
		end,
	},
	{
		id = "prateleira",
		name = "Prateleira de destilados",
		price = 1200,
		requires = "paredes",
		ticket = 10,
		build = function(add)
			add({ name = "Estante", size = v(16, 9, 1.2), pos = v(0, 4.5, 23.4), color = rgb(70, 45, 25), material = M.Wood })
			local i = 0
			for _, y in { 2, 4.5, 7 } do
				add({ name = "Tabua", size = v(16, 0.25, 1.6), pos = v(0, y, 23.2), color = rgb(90, 60, 35), material = M.Wood })
				for x = -7, 7 do
					i += 1
					add({
						name = "Garrafa",
						size = v(0.5, 1.4, 0.5),
						pos = v(x, y + 0.825, 22.9),
						color = BOTTLE_COLORS[i % #BOTTLE_COLORS + 1],
						material = M.Glass,
						transparency = 0.15,
					})
				end
			end
		end,
	},
	{
		id = "som",
		name = "Paredão de som",
		price = 2000,
		requires = "paredes",
		customers = 6,
		build = function(add)
			local facing = CFrame.Angles(0, math.rad(90), 0)
			for _, x in { -17.5, 17.5 } do
				add({ name = "CaixaDeSom", size = v(3, 7, 3), pos = v(x, 3.5, -5.5), color = rgb(25, 25, 25) })
				add({ name = "Grave", size = v(0.3, 2.4, 2.4), pos = v(x, 2.2, -7.05), rot = facing, shape = Enum.PartType.Cylinder, color = rgb(70, 70, 70) })
				add({ name = "Agudo", size = v(0.3, 1.2, 1.2), pos = v(x, 5.2, -7.05), rot = facing, shape = Enum.PartType.Cylinder, color = rgb(70, 70, 70) })
			end
		end,
	},
	{
		id = "copao",
		name = "Estação do copão",
		price = 3000,
		requires = "prateleira",
		ticket = 15,
		build = function(add)
			add({ name = "MaquinaDeGelo", size = v(3, 4.5, 2.5), pos = v(13, 2.25, 21), color = rgb(185, 185, 190), material = M.DiamondPlate })
			add({ name = "PlacaGelo", size = v(3, 0.8, 0.2), pos = v(13, 5, 19.7), color = rgb(40, 140, 200), text = "GELO DE COCO" })
			add({ name = "Cardapio", size = v(12, 2.5, 0.2), pos = v(0, 10.5, 23.9), color = rgb(15, 15, 15), text = "COPÃO • BALDE • DOSE", textColor = rgb(255, 255, 255) })
			for i = 0, 3 do
				add({ name = "Copo", size = v(0.6, 0.9, 0.6), pos = v(-6 + i * 0.8, 4.25, 0), color = rgb(255, 255, 255), material = M.Glass, transparency = 0.5 })
			end
		end,
	},
	{
		id = "mesas",
		name = "Mesas e cadeiras de plástico",
		price = 5000,
		requires = "balcao",
		customers = 6,
		build = function(add)
			local plastic = rgb(200, 40, 40)
			for _, spot in { { -11, -14 }, { -19, -14 }, { -11, -22 }, { -19, -22 }, { 12, -14 }, { 12, -22 } } do
				local x, z = spot[1], spot[2]
				add({ name = "Mesa", size = v(3.2, 0.25, 3.2), pos = v(x, 2.6, z), color = plastic })
				add({ name = "PeMesa", size = v(0.4, 2.5, 0.4), pos = v(x, 1.25, z), color = plastic })
				for _, side in { -1, 1 } do
					add({ name = "Assento", size = v(1.4, 0.2, 1.4), pos = v(x + side * 2.3, 1.5, z), color = plastic })
					add({ name = "Encosto", size = v(0.2, 1.6, 1.4), pos = v(x + side * 3, 2.4, z), color = plastic })
				end
			end
		end,
	},
	{
		id = "maquininha",
		name = "Maquininha de cartão",
		price = 7000,
		requires = "balcao",
		autoCollect = true,
		build = function(add)
			add({ name = "Maquininha", size = v(0.7, 0.2, 1.1), pos = v(3, 3.9, 0), color = rgb(30, 30, 30) })
		end,
	},
	{
		id = "toldo",
		name = "Toldo listrado",
		price = 10000,
		requires = "placa",
		customers = 5,
		build = function(add)
			for i = 0, 6 do
				add({ name = "Toldo", size = v(6, 0.3, 7), pos = v(-18 + i * 6, 9.5, -12), color = i % 2 == 0 and rgb(210, 30, 40) or rgb(250, 250, 250), material = M.Fabric })
			end
			for _, x in { -20.6, 20.6 } do
				add({ name = "Haste", size = v(0.3, 9.5, 0.3), pos = v(x, 4.75, -15.3), color = rgb(160, 160, 160), material = M.Metal })
			end
		end,
	},
	{
		id = "freezer2",
		name = "Freezer de energético",
		price = 14000,
		requires = "freezer",
		ticket = 10,
		build = function(add)
			add({ name = "Freezer", size = v(4, 6, 3), pos = v(-10, 3, 21), color = rgb(235, 235, 235) })
			add({ name = "PortaVidro", size = v(3.4, 5, 0.2), pos = v(-10, 3, 19.4), color = rgb(150, 200, 255), material = M.Glass, transparency = 0.4 })
			add({ name = "Letreiro", size = v(4, 1, 0.2), pos = v(-10, 6.5, 19.4), color = rgb(30, 70, 200), text = "ENERGÉTICO" })
		end,
	},
	{
		id = "led",
		name = "Fita de LED neon",
		price = 20000,
		requires = "toldo",
		customers = 8,
		build = function(add)
			local neon = rgb(170, 60, 255)
			add({ name = "LedBaixo", size = v(42, 0.25, 0.25), pos = v(0, 9.1, -9.15), color = neon, material = M.Neon, light = { color = neon, range = 18, brightness = 2 } })
			add({ name = "LedCima", size = v(42, 0.25, 0.25), pos = v(0, 11.9, -9.15), color = neon, material = M.Neon })
			for _, x in { -21.15, 21.15 } do
				add({ name = "LedLado", size = v(0.25, 12, 0.25), pos = v(x, 6, -9.15), color = neon, material = M.Neon })
			end
		end,
	},
	{
		id = "espetinho",
		name = "Churrasqueira de espetinho",
		price = 28000,
		requires = "mesas",
		ticket = 12,
		build = function(add)
			add({ name = "Churrasqueira", size = v(4, 3, 2), pos = v(-25, 1.5, -12), color = rgb(50, 50, 50), material = M.Metal })
			add({ name = "Brasa", size = v(3.6, 0.2, 1.6), pos = v(-25, 3.1, -12), color = rgb(255, 110, 20), material = M.Neon, smoke = true })
			for i = 0, 3 do
				add({ name = "Espeto", size = v(0.15, 0.15, 2.2), pos = v(-26.2 + i * 0.8, 3.3, -12), color = rgb(120, 70, 40) })
			end
			add({ name = "PostePlaca", size = v(0.2, 5, 0.2), pos = v(-27, 2.5, -10.8), color = rgb(160, 160, 160) })
			add({ name = "PlacaEspetinho", size = v(4, 1.2, 0.2), pos = v(-25, 5.6, -10.8), color = rgb(240, 240, 240), text = "ESPETINHO", textColor = rgb(200, 30, 30) })
		end,
	},
	{
		id = "arcondicionado",
		name = "Ar-condicionado",
		price = 40000,
		requires = "led",
		customers = 7,
		build = function(add)
			for _, x in { -19.4, 19.4 } do
				add({ name = "ArCondicionado", size = v(1.2, 1.6, 5), pos = v(x, 10, 10), color = rgb(250, 250, 250) })
			end
		end,
	},
	{
		id = "premium",
		name = "Adega Premium",
		price = 60000,
		requires = { "arcondicionado", "copao" },
		ticket = 18,
		build = function(add)
			add({ name = "Porcelanato", size = v(39.8, 0.05, 31.8), pos = v(0, 0.225, 8), color = rgb(240, 240, 240), material = M.Marble })
			add({ name = "FrisoDourado", size = v(16.4, 0.4, 0.15), pos = v(0, 3.3, -1.33), color = rgb(212, 175, 55), material = M.Foil })
			add({ name = "Lustre", size = v(2, 2, 2), pos = v(0, 10.5, 8), shape = Enum.PartType.Ball, color = rgb(255, 230, 170), material = M.Neon, light = { color = rgb(255, 220, 160), range = 30, brightness = 1.5 } })
		end,
	},
}

return Config
