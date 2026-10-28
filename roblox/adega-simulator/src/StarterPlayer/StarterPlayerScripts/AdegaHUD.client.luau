-- AdegaHUD (LocalScript em StarterPlayer > StarterPlayerScripts)
-- A interface do jogo: dinheiro, nível, relógio, painel da adega, loja e avisos.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer

local function findConfig()
	for _, child in ReplicatedStorage:GetDescendants() do
		if child:IsA("ModuleScript") and child.Name:lower() == "adegaconfig" then
			return child
		end
	end
	return nil
end

local configModule = findConfig()
while configModule == nil do
	task.wait(0.5)
	configModule = findConfig()
end
local Config = require(configModule)

local remotes = ReplicatedStorage:WaitForChild("AdegaRemotes")
local stateEvent = remotes:WaitForChild("Estado")
local buyEvent = remotes:WaitForChild("Comprar")
local noticeEvent = remotes:WaitForChild("Aviso")

local formatMoney = Config.formatMoney
local rgb = Color3.fromRGB

local T = {
	bg = rgb(16, 12, 26),
	panel = rgb(28, 22, 44),
	card = rgb(40, 32, 62),
	cardLight = rgb(54, 44, 82),
	line = rgb(96, 74, 150),
	text = rgb(248, 244, 255),
	muted = rgb(176, 166, 204),
	gold = rgb(255, 196, 40),
	orange = rgb(255, 128, 40),
	neon = rgb(178, 84, 255),
	pink = rgb(255, 80, 170),
	green = rgb(56, 210, 116),
	greenDark = rgb(30, 150, 80),
	red = rgb(236, 72, 88),
	blue = rgb(70, 150, 255),
	locked = rgb(70, 64, 92),
}

local CATEGORY_COLORS = {
	mesas = { rgb(255, 92, 70), rgb(200, 30, 60) },
	equipe = { rgb(70, 150, 255), rgb(60, 70, 210) },
	bar = { rgb(255, 196, 40), rgb(230, 110, 20) },
	ambiente = { rgb(190, 90, 255), rgb(120, 40, 200) },
}

-- Pequena fábrica de instâncias ----------------------------------------------------------------

local function create(className, props, children)
	local instance = Instance.new(className)
	local parent = props.Parent
	for key, value in props do
		if key ~= "Parent" then
			instance[key] = value
		end
	end
	for _, child in children or {} do
		child.Parent = instance
	end
	if parent then
		instance.Parent = parent
	end
	return instance
end

local function corner(radius)
	return create("UICorner", { CornerRadius = UDim.new(0, radius) })
end

local function stroke(color, thickness, transparency)
	return create("UIStroke", {
		Color = color,
		Thickness = thickness or 1.5,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function gradient(top, bottom, rotation)
	return create("UIGradient", { Color = ColorSequence.new(top, bottom), Rotation = rotation or 90 })
end

local function pad(all)
	return create("UIPadding", {
		PaddingLeft = UDim.new(0, all),
		PaddingRight = UDim.new(0, all),
		PaddingTop = UDim.new(0, all),
		PaddingBottom = UDim.new(0, all),
	})
end

local function label(props)
	local defaults = {
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextColor3 = T.text,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
	}
	for key, value in props do
		defaults[key] = value
	end
	return create("TextLabel", defaults)
end

local function tween(instance, time, props, style, direction)
	local t = TweenService:Create(instance, TweenInfo.new(time, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

local function formatNumber(value)
	if value == math.floor(value) then
		return tostring(value)
	end
	return Config.formatDecimal(value)
end

-- Tela ------------------------------------------------------------------------------------------

local gui = create("ScreenGui", {
	Name = "AdegaHUD",
	ResetOnSpawn = false,
	IgnoreGuiInset = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = player:WaitForChild("PlayerGui"),
})

-- Cada bloco da tela tem um UIScale para a interface caber em celular e em monitor grande.
local scalers = {}
local function scaled(frame)
	table.insert(scalers, create("UIScale", { Parent = frame }))
	return frame
end
local function currentScale()
	local camera = workspace.CurrentCamera
	if camera == nil then
		return 1
	end
	local viewport = camera.ViewportSize
	return math.clamp(math.min(viewport.X / 1366, viewport.Y / 768), 0.5, 1.15)
end

local function panel(props)
	local frame = create("Frame", {
		BackgroundColor3 = T.panel,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
	})
	for key, value in props do
		frame[key] = value
	end
	corner(16).Parent = frame
	stroke(T.line, 1.5, 0.35).Parent = frame
	gradient(rgb(255, 255, 255), rgb(205, 195, 230)).Parent = frame
	return frame
end

-- Perfil: nível e XP
local profile = scaled(panel({ Name = "Perfil", AnchorPoint = Vector2.new(0, 0), Position = UDim2.fromOffset(14, 14), Size = UDim2.fromOffset(310, 80), Parent = gui }))
local badge = create("Frame", { Position = UDim2.fromOffset(11, 11), Size = UDim2.fromOffset(58, 58), BackgroundColor3 = T.gold, Parent = profile }, {
	create("UICorner", { CornerRadius = UDim.new(1, 0) }),
	gradient(T.gold, T.orange),
	stroke(rgb(255, 255, 255), 2, 0.5),
})
label({ Text = "NÍVEL", Font = Enum.Font.GothamBlack, TextSize = 10, TextColor3 = rgb(80, 40, 0), TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(0, 8), Size = UDim2.new(1, 0, 0, 12), Parent = badge })
local levelText = label({ Text = "1", Font = Enum.Font.FredokaOne, TextSize = 28, TextColor3 = rgb(60, 25, 0), TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(0, 18), Size = UDim2.new(1, 0, 0, 32), Parent = badge })
label({ Text = "Adega de " .. player.DisplayName, TextSize = 18, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(82, 12), Size = UDim2.fromOffset(214, 22), Parent = profile })
local xpTrack = create("Frame", { Position = UDim2.fromOffset(82, 44), Size = UDim2.fromOffset(214, 18), BackgroundColor3 = T.bg, BorderSizePixel = 0, Parent = profile }, { corner(9) })
local xpFill = create("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = T.neon, BorderSizePixel = 0, Parent = xpTrack }, { corner(9), gradient(T.neon, T.pink, 0) })
local xpText = label({ Text = "0 / 120 XP", TextSize = 11, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), ZIndex = 2, Parent = xpTrack })

-- Dinheiro
local moneyCard = scaled(panel({ Name = "Dinheiro", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 14), Size = UDim2.fromOffset(290, 66), Parent = gui }))
moneyCard.UIStroke.Color = T.gold
moneyCard.UIStroke.Transparency = 0.1
moneyCard.UIStroke.Thickness = 2
create("Frame", { Position = UDim2.fromOffset(10, 9), Size = UDim2.fromOffset(48, 48), BackgroundColor3 = T.gold, Parent = moneyCard }, {
	create("UICorner", { CornerRadius = UDim.new(1, 0) }),
	gradient(T.gold, T.orange),
	label({ Text = "💰", TextSize = 26, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1) }),
})
local moneyText = label({ Text = "R$ 0", Font = Enum.Font.FredokaOne, TextSize = 34, TextColor3 = T.gold, Position = UDim2.fromOffset(68, 6), Size = UDim2.fromOffset(212, 54), Parent = moneyCard })
create("UIStroke", { Color = rgb(90, 50, 0), Thickness = 1.2, Transparency = 0.4, Parent = moneyText })

local registerPill = scaled(create("Frame", {
	Name = "Caixa",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 88),
	Size = UDim2.fromOffset(360, 34),
	BackgroundColor3 = T.gold,
	Visible = false,
	Parent = gui,
}, { corner(17), gradient(T.gold, T.orange, 0), stroke(rgb(255, 255, 255), 2, 0.3) }))
local registerText = label({ Text = "", TextSize = 14, TextColor3 = rgb(60, 25, 0), TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), Parent = registerPill })

-- Relógio e avaliação
local clockCard = scaled(panel({ Name = "Relogio", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 14), Size = UDim2.fromOffset(250, 80), Parent = gui }))
local clockIcon = label({ Text = "☀️", TextSize = 28, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(8, 10), Size = UDim2.fromOffset(40, 36), Parent = clockCard })
local clockText = label({ Text = "17:30", Font = Enum.Font.FredokaOne, TextSize = 30, Position = UDim2.fromOffset(52, 6), Size = UDim2.fromOffset(100, 40), Parent = clockCard })
local periodText = label({ Text = "", TextSize = 12, TextColor3 = T.muted, Position = UDim2.fromOffset(14, 50), Size = UDim2.fromOffset(226, 20), Parent = clockCard })
local starsText = label({ Text = "★★★★★", Font = Enum.Font.GothamBlack, TextSize = 15, TextColor3 = T.gold, TextXAlignment = Enum.TextXAlignment.Right, RichText = true, Position = UDim2.fromOffset(140, 10), Size = UDim2.fromOffset(98, 18), Parent = clockCard })
local ratingText = label({ Text = "1,0", Font = Enum.Font.FredokaOne, TextSize = 16, TextColor3 = T.text, TextXAlignment = Enum.TextXAlignment.Right, Position = UDim2.fromOffset(140, 28), Size = UDim2.fromOffset(98, 18), Parent = clockCard })

-- Painel da adega
local statsPanel = scaled(panel({ Name = "Painel", AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 14, 0.5, 10), Size = UDim2.fromOffset(240, 300), Parent = gui }))
pad(14).Parent = statsPanel
create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = statsPanel })
label({ Text = "SUA ADEGA", Font = Enum.Font.GothamBlack, TextSize = 12, TextColor3 = T.muted, Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 0, Parent = statsPanel })

local statRows = {}
local function statRow(order, icon, title)
	local row = create("Frame", { BackgroundColor3 = T.card, BackgroundTransparency = 0.2, Size = UDim2.new(1, 0, 0, 30), LayoutOrder = order, Parent = statsPanel }, { corner(9) })
	label({ Text = icon, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromOffset(30, 30), Parent = row })
	label({ Text = title, Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = T.muted, Position = UDim2.fromOffset(32, 0), Size = UDim2.new(1, -40, 1, 0), Parent = row })
	local value = label({ Text = "-", Font = Enum.Font.FredokaOne, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Right, Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, -10, 1, 0), Parent = row })
	statRows[order] = value
	return value
end
local cpmValue = statRow(1, "🚶", "Clientes por minuto")
local presentValue = statRow(2, "🏠", "Na adega agora")
local seatsValue = statRow(3, "🍻", "Lugares nas mesas")
local staffValue = statRow(4, "👥", "Funcionários")
local ticketValue = statRow(5, "🧾", "Gasto por cliente")
label({ Text = "CARDÁPIO", Font = Enum.Font.GothamBlack, TextSize = 12, TextColor3 = T.muted, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = 10, Parent = statsPanel })
local menuRow = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = 11, Parent = statsPanel })
create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), Parent = menuRow })
local productChips = {}
for _, product in Config.Products do
	local chip = create("Frame", { Size = UDim2.fromOffset(26, 34), BackgroundColor3 = T.card, Parent = menuRow }, { corner(8) })
	productChips[product.id] = {
		frame = chip,
		icon = label({ Text = product.icon, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), Parent = chip }),
	}
end
statsPanel.AutomaticSize = Enum.AutomaticSize.Y
statsPanel.Size = UDim2.fromOffset(240, 0)

-- Avisos ----------------------------------------------------------------------------------------

local toastArea = scaled(create("Frame", {
	Name = "Avisos",
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -14, 0, 104),
	Size = UDim2.fromOffset(330, 420),
	BackgroundTransparency = 1,
	Parent = gui,
}))
create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Right, Parent = toastArea })

local TOAST_STYLE = {
	compra = { icon = "✅", color = T.green },
	dinheiro = { icon = "💰", color = T.gold },
	nivel = { icon = "🎉", color = T.neon },
	erro = { icon = "⚠️", color = T.red },
	info = { icon = "💬", color = T.blue },
}
local toastCount = 0

local function toast(text, kind)
	local style = TOAST_STYLE[kind] or TOAST_STYLE.info
	toastCount += 1
	local holder = create("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(330, 54), LayoutOrder = toastCount, Parent = toastArea })
	local box = create("Frame", {
		Position = UDim2.fromOffset(360, 0),
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = T.panel,
		BackgroundTransparency = 0.05,
		Parent = holder,
	}, { corner(12), stroke(style.color, 1.5, 0.2) })
	create("Frame", { Size = UDim2.new(0, 6, 1, -16), Position = UDim2.fromOffset(8, 8), BackgroundColor3 = style.color, BorderSizePixel = 0, Parent = box }, { corner(3) })
	label({ Text = style.icon, TextSize = 22, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(18, 0), Size = UDim2.fromOffset(34, 54), Parent = box })
	label({ Text = text, TextSize = 14, TextWrapped = true, Position = UDim2.fromOffset(56, 0), Size = UDim2.new(1, -66, 1, 0), Parent = box })
	tween(box, 0.35, { Position = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Back)
	task.delay(3.4, function()
		tween(box, 0.3, { Position = UDim2.fromOffset(360, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		task.wait(0.3)
		holder:Destroy()
	end)
end

local banner = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.3),
	Size = UDim2.fromOffset(520, 130),
	BackgroundTransparency = 1,
	Visible = false,
	Parent = gui,
})
local bannerScale = create("UIScale", { Parent = banner })
local bannerTitle = label({ Text = "", Font = Enum.Font.FredokaOne, TextSize = 64, TextColor3 = T.gold, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 80), Parent = banner })
create("UIStroke", { Color = rgb(80, 20, 120), Thickness = 4, Parent = bannerTitle })
create("UIGradient", { Color = ColorSequence.new(T.gold, T.orange), Rotation = 90, Parent = bannerTitle })
local bannerSub = label({ Text = "Novos itens liberados na loja", Font = Enum.Font.GothamBold, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(0, 82), Size = UDim2.new(1, 0, 0, 30), Parent = banner })
create("UIStroke", { Color = rgb(30, 10, 50), Thickness = 2, Parent = bannerSub })

local function showBanner(title, subtitle)
	bannerTitle.Text = title
	bannerSub.Text = subtitle
	banner.Visible = true
	bannerScale.Scale = 0.3 * currentScale()
	bannerTitle.TextTransparency = 0
	bannerSub.TextTransparency = 0
	tween(bannerScale, 0.5, { Scale = currentScale() }, Enum.EasingStyle.Back)
	task.delay(2.4, function()
		tween(bannerTitle, 0.4, { TextTransparency = 1 })
		tween(bannerSub, 0.4, { TextTransparency = 1 })
		task.wait(0.4)
		banner.Visible = false
	end)
end

-- Loja ------------------------------------------------------------------------------------------

local state = nil
local shopOpen = false
local currentTab = "mesas"
local cards = {}

local dim = create("TextButton", {
	Name = "Fundo",
	Text = "",
	AutoButtonColor = false,
	Size = UDim2.fromScale(1, 1),
	Position = UDim2.fromOffset(0, -60),
	BackgroundColor3 = rgb(0, 0, 0),
	BackgroundTransparency = 1,
	Visible = false,
	ZIndex = 20,
	Parent = gui,
})
dim.Size = UDim2.new(1, 0, 1, 60)

local shop = create("Frame", {
	Name = "Loja",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(900, 560),
	BackgroundColor3 = T.bg,
	Visible = false,
	ZIndex = 21,
	Parent = gui,
}, { corner(22), stroke(T.neon, 2, 0.2) })
local shopScale = create("UIScale", { Parent = shop })

local header = create("Frame", { Size = UDim2.new(1, 0, 0, 78), BackgroundColor3 = T.neon, ZIndex = 22, Parent = shop }, {
	corner(22),
	gradient(rgb(140, 30, 70), rgb(90, 40, 180), 0),
})
create("Frame", { Position = UDim2.new(0, 0, 1, -22), Size = UDim2.new(1, 0, 0, 22), BackgroundColor3 = rgb(255, 255, 255), BorderSizePixel = 0, ZIndex = 22, Parent = header }, {
	gradient(rgb(140, 30, 70), rgb(90, 40, 180), 0),
})
label({ Text = "🛒  Loja da Adega", Font = Enum.Font.FredokaOne, TextSize = 30, Position = UDim2.fromOffset(24, 10), Size = UDim2.fromOffset(500, 36), ZIndex = 23, Parent = header })
label({ Text = "Compre mesas, contrate a equipe e deixe sua adega a mais bonita da rua", Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = rgb(235, 220, 255), Position = UDim2.fromOffset(26, 46), Size = UDim2.fromOffset(560, 20), ZIndex = 23, Parent = header })
local shopMoney = label({ Text = "R$ 0", Font = Enum.Font.FredokaOne, TextSize = 24, TextColor3 = T.gold, TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -78, 0, 20), Size = UDim2.fromOffset(220, 36), ZIndex = 23, Parent = header })
local closeButton = create("TextButton", {
	Text = "✕",
	Font = Enum.Font.GothamBlack,
	TextSize = 20,
	TextColor3 = T.text,
	AutoButtonColor = false,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -20, 0, 18),
	Size = UDim2.fromOffset(42, 42),
	BackgroundColor3 = T.red,
	ZIndex = 23,
	Parent = header,
}, { create("UICorner", { CornerRadius = UDim.new(1, 0) }), stroke(rgb(255, 255, 255), 2, 0.5) })

local sidebar = create("Frame", { Position = UDim2.fromOffset(16, 94), Size = UDim2.new(0, 190, 1, -110), BackgroundColor3 = T.panel, ZIndex = 22, Parent = shop }, { corner(16), pad(10) })
create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = sidebar })

local content = create("ScrollingFrame", {
	Position = UDim2.fromOffset(222, 94),
	Size = UDim2.new(1, -238, 1, -110),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 6,
	ScrollBarImageColor3 = T.neon,
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ZIndex = 22,
	Parent = shop,
}, {
	create("UIGridLayout", { CellSize = UDim2.fromOffset(202, 272), CellPadding = UDim2.fromOffset(12, 12), SortOrder = Enum.SortOrder.LayoutOrder }),
	create("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingLeft = UDim.new(0, 2), PaddingBottom = UDim.new(0, 12) }),
})

local tabButtons = {}

local function effectsText(item)
	local effects = item.effects or {}
	local bits = {}
	if effects.seats then
		table.insert(bits, "+" .. effects.seats .. " lugares")
	end
	if effects.attraction then
		table.insert(bits, "+" .. formatNumber(effects.attraction) .. " clientes/min")
	end
	if effects.ambiance then
		table.insert(bits, "+" .. effects.ambiance .. " de ambiente")
	end
	if effects.stations then
		table.insert(bits, "+1 fila no balcão")
	end
	if effects.waiters then
		table.insert(bits, "leva rodadas às mesas")
	end
	if effects.capacity then
		table.insert(bits, "+" .. effects.capacity .. " de lotação")
	end
	if effects.rating and not effects.waiters then
		table.insert(bits, "+" .. formatNumber(effects.rating) .. " ★")
	end
	if effects.serviceSpeed then
		table.insert(bits, "atende " .. math.floor(effects.serviceSpeed * 100) .. "% mais rápido")
	end
	if effects.autoCollect then
		table.insert(bits, "caixa automático")
	end
	for _, product in Config.Products do
		if product.requires == item.id then
			table.insert(bits, "libera " .. product.icon .. " " .. product.name .. " (" .. formatMoney(product.price) .. ")")
		end
	end
	return table.concat(bits, " • ")
end

local function press(button)
	local scale = button:FindFirstChildOfClass("UIScale") or create("UIScale", { Parent = button })
	scale.Scale = 0.9
	tween(scale, 0.25, { Scale = 1 }, Enum.EasingStyle.Back)
end

local function shake(frame)
	local origin = frame.Position
	for _, dx in { -8, 8, -5, 5, 0 } do
		frame.Position = origin + UDim2.fromOffset(dx, 0)
		task.wait(0.04)
	end
	frame.Position = origin
end

local function refreshCard(card)
	if state == nil then
		return
	end
	local item = card.item
	local level = state.items[item.id] or 0
	local status, reason = Config.purchaseStatus(item, state.items, state.level, state.cash)
	card.status = status
	card.levelChip.Text = level .. "/" .. item.maxLevel
	card.levelFill.Size = UDim2.fromScale(level / item.maxLevel, 1)

	local button = card.button
	local locked = status == "level" or status == "requires"
	card.iconBox.BackgroundTransparency = if locked then 0.6 else 0
	card.icon.TextTransparency = if locked then 0.5 else 0
	if status == "max" then
		button.Text = "✓  MÁXIMO"
		button.BackgroundColor3 = rgb(110, 90, 30)
		button.TextColor3 = T.gold
	elseif locked then
		button.Text = "🔒  " .. reason
		button.BackgroundColor3 = T.locked
		button.TextColor3 = T.muted
	else
		local price = formatMoney(Config.getPrice(item, level))
		local verb = if item.category == "equipe" then "Contratar" else "Comprar"
		button.Text = verb .. "  " .. price
		if status == "ok" then
			button.BackgroundColor3 = T.green
			button.TextColor3 = rgb(255, 255, 255)
		else
			button.BackgroundColor3 = rgb(120, 50, 64)
			button.TextColor3 = rgb(255, 190, 200)
		end
	end
	card.buttonGradient.Enabled = status == "ok"
end

local function buildCards()
	for _, card in cards do
		card.frame:Destroy()
	end
	table.clear(cards)
	local colors = CATEGORY_COLORS[currentTab]
	for _, item in Config.Items do
		if item.category ~= currentTab then
			continue
		end
		local frame = create("Frame", { BackgroundColor3 = T.card, LayoutOrder = item.order, ZIndex = 23, Parent = content }, { corner(16), stroke(T.line, 1.2, 0.5) })
		local iconBox = create("Frame", { Position = UDim2.fromOffset(8, 8), Size = UDim2.new(1, -16, 0, 82), BackgroundColor3 = colors[1], ZIndex = 24, Parent = frame }, {
			corner(12),
			gradient(colors[1], colors[2], 135),
		})
		local icon = label({ Text = item.icon, TextSize = 46, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), ZIndex = 25, Parent = iconBox })
		local levelChip = label({
			Text = "0/1",
			Font = Enum.Font.GothamBlack,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Center,
			BackgroundTransparency = 0.35,
			BackgroundColor3 = rgb(0, 0, 0),
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -6, 0, 6),
			Size = UDim2.fromOffset(40, 18),
			ZIndex = 26,
			Parent = iconBox,
		})
		corner(9).Parent = levelChip
		label({ Text = item.name, TextSize = 16, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(12, 96), Size = UDim2.new(1, -24, 0, 20), ZIndex = 24, Parent = frame })
		label({
			Text = item.desc,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = T.muted,
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
			Position = UDim2.fromOffset(12, 118),
			Size = UDim2.new(1, -24, 0, 46),
			ZIndex = 24,
			Parent = frame,
		})
		label({
			Text = effectsText(item),
			TextSize = 12,
			TextColor3 = T.gold,
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
			Position = UDim2.fromOffset(12, 166),
			Size = UDim2.new(1, -24, 0, 42),
			ZIndex = 24,
			Parent = frame,
		})
		local levelTrack = create("Frame", { Position = UDim2.fromOffset(12, 212), Size = UDim2.new(1, -24, 0, 6), BackgroundColor3 = T.bg, BorderSizePixel = 0, ZIndex = 24, Parent = frame }, { corner(3) })
		local levelFill = create("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = colors[1], BorderSizePixel = 0, ZIndex = 25, Parent = levelTrack }, { corner(3) })
		local buttonGradient = gradient(rgb(255, 255, 255), rgb(190, 190, 190))
		local button = create("TextButton", {
			Text = "",
			Font = Enum.Font.GothamBlack,
			TextSize = 14,
			AutoButtonColor = false,
			Position = UDim2.fromOffset(10, 226),
			Size = UDim2.new(1, -20, 0, 38),
			BackgroundColor3 = T.green,
			ZIndex = 24,
			Parent = frame,
		}, { corner(12), buttonGradient })

		local card = {
			item = item,
			frame = frame,
			iconBox = iconBox,
			icon = icon,
			levelChip = levelChip,
			levelFill = levelFill,
			button = button,
			buttonGradient = buttonGradient,
			status = nil,
		}
		button.MouseButton1Click:Connect(function()
			press(button)
			if card.status == "ok" then
				buyEvent:FireServer(item.id)
			elseif card.status ~= "max" then
				task.spawn(shake, frame)
			end
		end)
		frame.MouseEnter:Connect(function()
			tween(frame.UIStroke, 0.15, { Transparency = 0, Color = T.neon })
		end)
		frame.MouseLeave:Connect(function()
			tween(frame.UIStroke, 0.15, { Transparency = 0.5, Color = T.line })
		end)
		table.insert(cards, card)
		refreshCard(card)
	end
	content.CanvasPosition = Vector2.zero
end

local function affordableCount(categoryId)
	if state == nil then
		return 0
	end
	local count = 0
	for _, item in Config.Items do
		if item.category == categoryId and Config.purchaseStatus(item, state.items, state.level, state.cash) == "ok" then
			count += 1
		end
	end
	return count
end

local function selectTab(categoryId)
	currentTab = categoryId
	for id, tab in tabButtons do
		local selected = id == categoryId
		tab.button.BackgroundTransparency = if selected then 0 else 1
		tab.gradient.Enabled = selected
		tab.title.TextColor3 = if selected then T.text else T.muted
	end
	buildCards()
end

for index, category in Config.Categories do
	local colors = CATEGORY_COLORS[category.id]
	local button = create("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.new(1, 0, 0, 54),
		BackgroundColor3 = rgb(255, 255, 255),
		BackgroundTransparency = 1,
		LayoutOrder = index,
		ZIndex = 23,
		Parent = sidebar,
	}, { corner(12) })
	local tabGradient = gradient(colors[1], colors[2], 0)
	tabGradient.Parent = button
	label({ Text = category.icon, TextSize = 24, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(6, 0), Size = UDim2.fromOffset(40, 54), ZIndex = 24, Parent = button })
	local title = label({ Text = category.name, TextSize = 17, TextColor3 = T.muted, Position = UDim2.fromOffset(50, 0), Size = UDim2.new(1, -90, 1, 0), ZIndex = 24, Parent = button })
	local count = label({
		Text = "",
		Font = Enum.Font.GothamBlack,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Center,
		BackgroundColor3 = T.green,
		BackgroundTransparency = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(26, 22),
		Visible = false,
		ZIndex = 25,
		Parent = button,
	})
	corner(11).Parent = count
	tabButtons[category.id] = { button = button, gradient = tabGradient, title = title, count = count }
	button.MouseButton1Click:Connect(function()
		press(button)
		selectTab(category.id)
	end)
end

local function setShopOpen(open, categoryId)
	if categoryId then
		selectTab(categoryId)
	end
	if open == shopOpen then
		return
	end
	shopOpen = open
	if open then
		if categoryId == nil then
			selectTab(currentTab)
		end
		dim.Visible = true
		shop.Visible = true
		shopScale.Scale = currentScale() * 0.85
		tween(dim, 0.25, { BackgroundTransparency = 0.45 })
		tween(shopScale, 0.35, { Scale = currentScale() }, Enum.EasingStyle.Back)
	else
		tween(dim, 0.2, { BackgroundTransparency = 1 })
		tween(shopScale, 0.2, { Scale = currentScale() * 0.85 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		task.delay(0.2, function()
			if not shopOpen then
				dim.Visible = false
				shop.Visible = false
			end
		end)
	end
end

closeButton.MouseButton1Click:Connect(function()
	setShopOpen(false)
end)
dim.MouseButton1Click:Connect(function()
	setShopOpen(false)
end)

-- Barra de botões embaixo
local dock = scaled(create("Frame", {
	Name = "Dock",
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -16),
	Size = UDim2.fromOffset(4 * 96 + 3 * 12, 92),
	BackgroundTransparency = 1,
	Parent = gui,
}))
create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 12), HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = dock })
local dockBadges = {}
for _, category in Config.Categories do
	local colors = CATEGORY_COLORS[category.id]
	local button = create("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.fromOffset(96, 88),
		BackgroundColor3 = T.panel,
		BackgroundTransparency = 0.05,
		Parent = dock,
	}, { corner(20), stroke(colors[1], 2, 0.3) })
	local glow = create("Frame", { Position = UDim2.fromOffset(6, 6), Size = UDim2.new(1, -12, 0, 50), BackgroundColor3 = colors[1], Parent = button }, {
		corner(14),
		gradient(colors[1], colors[2], 135),
	})
	label({ Text = category.icon, TextSize = 30, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), Parent = glow })
	label({ Text = category.name, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(0, 58), Size = UDim2.new(1, 0, 0, 24), Parent = button })
	local badgeLabel = label({
		Text = "",
		Font = Enum.Font.GothamBlack,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Center,
		BackgroundColor3 = T.green,
		BackgroundTransparency = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, -6, 0, 6),
		Size = UDim2.fromOffset(26, 26),
		Visible = false,
		ZIndex = 3,
		Parent = button,
	})
	create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = badgeLabel })
	stroke(rgb(255, 255, 255), 2, 0).Parent = badgeLabel
	dockBadges[category.id] = badgeLabel
	local buttonScale = create("UIScale", { Parent = button })
	button.MouseEnter:Connect(function()
		tween(buttonScale, 0.15, { Scale = 1.08 })
	end)
	button.MouseLeave:Connect(function()
		tween(buttonScale, 0.15, { Scale = 1 })
	end)
	button.MouseButton1Click:Connect(function()
		if shopOpen and currentTab == category.id then
			setShopOpen(false)
		else
			setShopOpen(true, category.id)
		end
	end)
end
if UserInputService.KeyboardEnabled then
	label({
		Text = "Aperte B para abrir a loja",
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		TextColor3 = T.muted,
		TextXAlignment = Enum.TextXAlignment.Center,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -110),
		Size = UDim2.fromOffset(300, 16),
		Parent = gui,
	})
end

-- Atualização com o estado do servidor -----------------------------------------------------------

local shownCash = create("NumberValue", { Value = 0 })
shownCash.Changed:Connect(function(value)
	moneyText.Text = formatMoney(value)
end)

local function floatingGain(amount)
	local gain = label({
		Text = "+" .. formatMoney(amount),
		Font = Enum.Font.FredokaOne,
		TextSize = 22,
		TextColor3 = T.green,
		TextXAlignment = Enum.TextXAlignment.Center,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 1, 2),
		Size = UDim2.fromOffset(200, 26),
		Parent = moneyCard,
	})
	create("UIStroke", { Color = rgb(0, 60, 20), Thickness = 1.5, Parent = gain })
	tween(gain, 1.1, { Position = UDim2.new(0.5, 0, 1, 40), TextTransparency = 1 })
	tween(gain.UIStroke, 1.1, { Transparency = 1 })
	task.delay(1.2, function()
		gain:Destroy()
	end)
end

local pendingGain = 0
local function applyState(previous)
	tween(shownCash, 0.45, { Value = state.cash })
	if previous and state.cash > previous.cash then
		pendingGain += state.cash - previous.cash
	end
	shopMoney.Text = formatMoney(state.cash)

	levelText.Text = tostring(state.level)
	local ratio = if state.level >= Config.MaxLevel then 1 else math.clamp(state.xp / state.xpNext, 0, 1)
	tween(xpFill, 0.3, { Size = UDim2.fromScale(ratio, 1) })
	xpText.Text = if state.level >= Config.MaxLevel
		then "NÍVEL MÁXIMO"
		else string.format("%s / %s XP", formatMoney(state.xp):sub(4), formatMoney(state.xpNext):sub(4))

	local full = math.floor(state.rating)
	local half = state.rating - full >= 0.5
	local stars = string.rep("★", full)
	if half and full < 5 then
		stars ..= "<font transparency=\"0.35\">★</font>"
		full += 1
	end
	if full < 5 then
		stars ..= "<font transparency=\"0.8\">" .. string.rep("★", 5 - full) .. "</font>"
	end
	starsText.Text = stars
	ratingText.Text = Config.formatDecimal(state.rating) .. " estrelas"

	cpmValue.Text = Config.formatDecimal(state.cpm)
	presentValue.Text = state.present .. " / " .. state.capacity
	seatsValue.Text = tostring(state.seats)
	staffValue.Text = tostring(state.staff)
	ticketValue.Text = formatMoney(state.ticket)

	local unlocked = {}
	for _, id in state.products do
		unlocked[id] = true
	end
	for id, chip in productChips do
		chip.icon.TextTransparency = if unlocked[id] then 0 else 0.75
		chip.frame.BackgroundTransparency = if unlocked[id] then 0 else 0.6
	end

	if state.pending > 0 and not state.autoCollect then
		registerPill.Visible = true
		registerText.Text = "🧾  Caixa: " .. formatMoney(state.pending) .. "  •  vá ao balcão para recolher"
	else
		registerPill.Visible = false
	end

	for id, badgeLabel in dockBadges do
		local count = affordableCount(id)
		badgeLabel.Visible = count > 0
		badgeLabel.Text = tostring(count)
		tabButtons[id].count.Visible = count > 0
		tabButtons[id].count.Text = tostring(count)
	end
	for _, card in cards do
		refreshCard(card)
	end

	if previous and state.level > previous.level then
		showBanner("NÍVEL " .. state.level .. "!", "Novos itens liberados na loja")
	end
end

stateEvent.OnClientEvent:Connect(function(newState)
	local previous = state
	state = newState
	applyState(previous)
	if previous == nil and state.level == 1 and (state.items.mesas or 0) == 0 then
		task.spawn(function()
			task.wait(1.5)
			toast("Os clientes já estão chegando! 🍺", "info")
			task.wait(2.5)
			toast("O dinheiro cai no caixa do balcão. Vá até lá para recolher.", "dinheiro")
			task.wait(2.5)
			toast("Abra a aba Mesas e compre sua primeira mesa.", "info")
		end)
	end
end)

noticeEvent.OnClientEvent:Connect(function(text, kind)
	if kind == "nivel" and text:find("subiu") then
		return -- o banner de nível já mostra isso
	end
	toast(text, kind)
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.KeyCode == Enum.KeyCode.B then
		setShopOpen(not shopOpen)
	end
end)

-- Relógio, ganhos flutuantes e escala da tela
local function applyScale()
	local value = currentScale()
	for _, scaler in scalers do
		scaler.Scale = value
	end
	if shopOpen then
		shopScale.Scale = value
	end
end
applyScale()
if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(applyScale)
end

local pulse = 0
while true do
	task.wait(0.5)
	local hour = Lighting.ClockTime
	local h = math.floor(hour)
	local m = math.floor((hour - h) * 60 / 10) * 10
	clockText.Text = string.format("%02d:%02d", h, m)
	if hour >= 18 or hour < 2 then
		clockIcon.Text = "🌙"
		periodText.Text = "Horário nobre • clientes x1,5"
		periodText.TextColor3 = T.gold
	elseif hour < 6 then
		clockIcon.Text = "💤"
		periodText.Text = "Madrugada • movimento fraco"
		periodText.TextColor3 = T.muted
	else
		clockIcon.Text = if hour < 17 then "☀️" else "🌅"
		periodText.Text = "Movimento normal"
		periodText.TextColor3 = T.muted
	end

	if pendingGain > 0 then
		floatingGain(pendingGain)
		pendingGain = 0
	end

	pulse += 1
	if registerPill.Visible then
		registerPill.UIStroke.Transparency = if pulse % 2 == 0 then 0 else 0.7
	end
end
