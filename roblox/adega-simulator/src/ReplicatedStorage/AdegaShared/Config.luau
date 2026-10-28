-- Config: números do jogo, cardápio, equipe, estilos, missões e avaliações.
-- Tudo que dá para balancear sem mexer na lógica fica aqui.

local Config = {}

Config.DataStoreName = "AdegaSimulator_v3"
Config.AutoSaveInterval = 60

-- Terrenos
Config.PlotCount = 6 -- coloque o máximo de jogadores do servidor igual a este número
Config.PlotSpacing = 124
Config.PlotFrontZ = 40 -- linha da frente dos terrenos no mundo (a rua fica em z menor)
Config.Grid = 2 -- tamanho de cada quadrado da grade, em studs
Config.LandWidth = 110
Config.LandDepth = 92
Config.WallHeight = 12
-- Área construível: largura = profundidade = size. A frente fica colada na calçada.
Config.PlotSizes = {
	{ size = 36, price = 0, level = 1 },
	{ size = 48, price = 6000, level = 5 },
	{ size = 60, price = 25000, level = 10 },
	{ size = 72, price = 90000, level = 16 },
	{ size = 84, price = 250000, level = 24 },
}

-- Progresso
Config.StartingCash = 600
Config.MaxLevel = 40
function Config.xpForLevel(level)
	return math.floor(100 * 1.33 ^ (level - 1))
end
Config.SellRefund = 0.6
Config.CarryLimit = 4

-- Dia e noite: um dia inteiro dura DayLengthMinutes. Das 18h às 2h é o horário nobre.
Config.DayLengthMinutes = 14
Config.NightBoost = 1.5
Config.LateNightFactor = 0.55

-- Clientes
Config.Customer = {
	walkSpeed = 10,
	baseGroupsPerMinute = 3.2,
	maxPerPlot = 30,
	readMenu = { 3, 6 },
	drinkTime = { 16, 28 },
	patienceOrder = 60, -- segundos esperando alguém anotar o pedido
	patienceDelivery = 80, -- segundos esperando a bebida chegar
	reorderChance = 0.4,
	maxRounds = 3,
	counterChance = 0.3, -- chance de um cliente sozinho preferir comprar no balcão
	partyWeights = { 30, 36, 20, 14 }, -- grupos de 1, 2, 3 e 4 pessoas
}

-- Cardápio. "station" é o equipamento do catálogo que prepara o produto.
Config.Products = {
	{ id = "cerveja", name = "Cerveja lata", icon = "🍺", price = 8, prep = 1.2, station = "geladeira_cerveja", level = 1, visual = "lata", color = Color3.fromRGB(250, 196, 40) },
	{ id = "longneck", name = "Long neck", icon = "🍾", price = 13, prep = 1.4, station = "geladeira_cerveja", level = 3, visual = "garrafa", color = Color3.fromRGB(120, 70, 25) },
	{ id = "dose", name = "Dose de cachaça", icon = "🥃", price = 12, prep = 1.8, station = "prateleira_destilados", level = 2, visual = "dose", color = Color3.fromRGB(215, 160, 60) },
	{ id = "energetico", name = "Energético", icon = "⚡", price = 11, prep = 1.2, station = "freezer_energetico", level = 2, visual = "lata", color = Color3.fromRGB(40, 110, 230) },
	{ id = "caipirinha", name = "Caipirinha", icon = "🍹", price = 20, prep = 3.2, station = "bancada_caipirinha", level = 3, visual = "copo", color = Color3.fromRGB(170, 225, 90) },
	{ id = "copao", name = "Copão de whisky com energético", icon = "🥤", price = 28, prep = 3.8, station = "estacao_copao", level = 4, visual = "copao", color = Color3.fromRGB(255, 150, 30) },
	{ id = "chopp", name = "Chopp", icon = "🍻", price = 15, prep = 2.4, station = "chopeira", level = 6, visual = "caneca", color = Color3.fromRGB(250, 205, 60) },
	{ id = "espetinho", name = "Espetinho", icon = "🍢", price = 16, prep = 4.5, station = "churrasqueira", level = 7, visual = "espeto", color = Color3.fromRGB(150, 70, 35) },
	{ id = "gin", name = "Gin tônica", icon = "🍸", price = 26, prep = 3.4, station = "bar_drinks", level = 8, visual = "taca", color = Color3.fromRGB(200, 235, 255) },
	{ id = "balde", name = "Balde de cerveja", icon = "🧊", price = 55, prep = 3, station = "freezer_baldes", level = 9, visual = "balde", color = Color3.fromRGB(220, 225, 235) },
	{ id = "porcao", name = "Porção de batata frita", icon = "🍟", price = 24, prep = 6, station = "fritadeira", level = 11, visual = "porcao", color = Color3.fromRGB(250, 205, 70) },
	{ id = "premium", name = "Copão premium", icon = "🏆", price = 45, prep = 4.5, station = "estacao_premium", level = 14, visual = "copao", color = Color3.fromRGB(200, 60, 255) },
}

-- Equipe
Config.Staff = {
	{
		id = "garcom",
		name = "Garçom",
		icon = "🤵",
		desc = "Anota os pedidos das mesas, entrega o que está pronto e recolhe o dinheiro.",
		hire = 300,
		level = 1,
		outfit = { shirt = Color3.fromRGB(245, 245, 245), pants = Color3.fromRGB(25, 25, 30), hat = "hair", tray = true },
	},
	{
		id = "bartender",
		name = "Bartender",
		icon = "🍸",
		desc = "Prepara as bebidas nas estações e deixa no balcão para o garçom levar.",
		hire = 650,
		level = 2,
		outfit = { shirt = Color3.fromRGB(20, 20, 24), pants = Color3.fromRGB(20, 20, 24), hat = "cap", hatColor = Color3.fromRGB(255, 196, 40) },
	},
	{
		id = "faxineiro",
		name = "Faxineiro",
		icon = "🧹",
		desc = "Limpa as mesas sujas para os próximos clientes sentarem.",
		hire = 250,
		level = 2,
		outfit = { shirt = Color3.fromRGB(60, 150, 220), pants = Color3.fromRGB(40, 60, 110), hat = "cap", hatColor = Color3.fromRGB(60, 150, 220) },
	},
	{
		id = "atendente",
		name = "Atendente de balcão",
		icon = "🙋",
		desc = "Atende quem compra no balcão: anota, prepara e entrega na hora.",
		hire = 500,
		level = 3,
		outfit = { shirt = Color3.fromRGB(255, 196, 40), pants = Color3.fromRGB(35, 35, 45), hat = "long" },
	},
	{
		id = "seguranca",
		name = "Segurança",
		icon = "🕶",
		desc = "Fica na porta. Clientes se sentem seguros: avaliações e gorjetas sobem.",
		hire = 2500,
		level = 6,
		outfit = { shirt = Color3.fromRGB(15, 15, 18), pants = Color3.fromRGB(15, 15, 18), hat = "bald" },
	},
	{
		id = "dj",
		name = "DJ",
		icon = "🎧",
		desc = "Comanda o som e atrai muita gente à noite. Fica na cabine de DJ, se você tiver uma.",
		hire = 6000,
		level = 9,
		outfit = { shirt = Color3.fromRGB(150, 60, 230), pants = Color3.fromRGB(30, 30, 40), hat = "headphones" },
	},
}
Config.StaffMaxLevel = 5
function Config.trainPrice(role, level)
	return math.floor(role.hire * 0.8 * 1.9 ^ (level - 1))
end
function Config.staffSpeed(level)
	return 1 + 0.18 * (level - 1)
end
function Config.maxStaff(level)
	return math.min(24, 2 + math.floor(level / 2))
end
Config.StaffNames = {
	"Seu Zé", "Dona Cida", "Tião", "Jéssica", "Kauã", "Bruna", "Marquinhos", "Thaís", "Juninho", "Rose",
	"Edinho", "Paty", "Neguinho", "Vanessa", "Biel", "Larissa", "Toninho", "Gabi", "Pedrão", "Dani",
	"Wesley", "Kelly", "Fabinho", "Sheila", "Rafa", "Carol", "Nando", "Lu", "Claudinho", "Mari",
}

-- Estilo: piso da área construível e cor das paredes rebocadas.
Config.Floors = {
	{ id = "cimento", name = "Cimento queimado", price = 0, color = Color3.fromRGB(150, 150, 152), material = Enum.Material.Concrete },
	{ id = "ceramica", name = "Cerâmica bege", price = 800, color = Color3.fromRGB(214, 196, 166), material = Enum.Material.Slate },
	{ id = "madeira", name = "Piso de madeira", price = 2500, color = Color3.fromRGB(150, 98, 58), material = Enum.Material.WoodPlanks },
	{ id = "pedra", name = "Pedra portuguesa", price = 3500, color = Color3.fromRGB(205, 200, 190), material = Enum.Material.Cobblestone },
	{ id = "granito", name = "Granito preto", price = 6000, color = Color3.fromRGB(38, 38, 42), material = Enum.Material.Granite },
	{ id = "porcelanato", name = "Porcelanato", price = 9000, color = Color3.fromRGB(236, 232, 226), material = Enum.Material.Marble },
}
Config.WallColors = {
	{ id = "branco", name = "Branco gelo", price = 0, color = Color3.fromRGB(214, 206, 192) },
	{ id = "amarelo", name = "Amarelo adega", price = 300, color = Color3.fromRGB(245, 196, 50) },
	{ id = "vinho", name = "Vinho", price = 300, color = Color3.fromRGB(116, 28, 46) },
	{ id = "verde", name = "Verde bandeira", price = 300, color = Color3.fromRGB(0, 120, 70) },
	{ id = "azul", name = "Azul petróleo", price = 300, color = Color3.fromRGB(24, 74, 96) },
	{ id = "preto", name = "Preto fosco", price = 600, color = Color3.fromRGB(28, 28, 32) },
	{ id = "rosa", name = "Rosa neon", price = 900, color = Color3.fromRGB(230, 60, 150) },
	{ id = "roxo", name = "Roxo noturno", price = 900, color = Color3.fromRGB(80, 40, 140) },
}

-- Missões: aparecem uma de cada vez, em ordem, e pagam uma recompensa.
-- "event" é o que o servidor conta; "target" é quantas vezes.
Config.Quests = {
	{ id = "q1", text = "Anote o pedido de uma mesa", event = "takeOrder", target = 1, reward = 50 },
	{ id = "q2", text = "Prepare uma bebida na geladeira", event = "prepare", target = 1, reward = 50 },
	{ id = "q3", text = "Entregue um pedido na mesa", event = "deliver", target = 1, reward = 80 },
	{ id = "q4", text = "Pegue o dinheiro deixado na mesa", event = "collect", target = 1, reward = 80 },
	{ id = "q5", text = "Limpe uma mesa suja", event = "clean", target = 1, reward = 80 },
	{ id = "q6", text = "Coloque uma mesa nova no modo construção", event = "placeSeating", target = 1, reward = 150 },
	{ id = "q7", text = "Contrate um garçom", event = "hire_garcom", target = 1, reward = 250 },
	{ id = "q8", text = "Coloque uma Prateleira de destilados", event = "place_prateleira_destilados", target = 1, reward = 300 },
	{ id = "q9", text = "Atenda 25 clientes", event = "served", target = 25, reward = 450 },
	{ id = "q10", text = "Contrate um bartender", event = "hire_bartender", target = 1, reward = 600 },
	{ id = "q11", text = "Mude o piso ou a cor das paredes", event = "style", target = 1, reward = 400 },
	{ id = "q12", text = "Coloque uma Estação do copão", event = "place_estacao_copao", target = 1, reward = 1000 },
	{ id = "q13", text = "Chegue a 4 estrelas de avaliação", event = "rating4", target = 1, reward = 1200 },
	{ id = "q14", text = "Expanda o terreno da adega", event = "expand", target = 1, reward = 2500 },
	{ id = "q15", text = "Atenda 250 clientes", event = "served", target = 250, reward = 4000 },
	{ id = "q16", text = "Tenha 8 funcionários", event = "staffCount8", target = 1, reward = 6000 },
	{ id = "q17", text = "Chegue ao nível 15", event = "level15", target = 1, reward = 10000 },
	{ id = "q18", text = "Atenda 1.000 clientes", event = "served", target = 1000, reward = 25000 },
}

-- Comentários das avaliações, por número de estrelas.
Config.Reviews = {
	[5] = {
		"Melhor adega da quebrada! 🔥",
		"Copão no capricho e atendimento nota 10.",
		"Ambiente top, volto toda sexta!",
		"Cerveja trincando de gelada. Perfeito.",
		"Atendimento rápido demais, amei.",
		"Que lugar lindo à noite! Recomendo.",
	},
	[4] = {
		"Muito bom, só demorou um pouquinho.",
		"Gostei bastante, preço justo.",
		"Lugar animado, voltarei.",
		"Bebida boa, atendimento ok.",
	},
	[3] = {
		"Normal. Dava pra ser mais rápido.",
		"Ok, mas o ambiente podia ser melhor.",
		"Nada demais, mas também nada de errado.",
	},
	[2] = {
		"Esperei muito pra ser atendido.",
		"A bebida chegou quente…",
		"Mesa suja e demora. Hmm.",
	},
	[1] = {
		"Ninguém veio anotar meu pedido! 😡",
		"Fui embora sem beber nada.",
		"Pior atendimento que já vi.",
	},
}

function Config.productById(id)
	for _, product in Config.Products do
		if product.id == id then
			return product
		end
	end
	return nil
end

function Config.staffById(id)
	for _, role in Config.Staff do
		if role.id == id then
			return role
		end
	end
	return nil
end

function Config.findById(list, id)
	for _, entry in list do
		if entry.id == id then
			return entry
		end
	end
	return nil
end

return Config
