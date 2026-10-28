-- Hud: o que fica sempre na tela.

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local UI = require(script.Parent.UI)
local Icons = require(script.Parent.Icons)

local Hud = {}

local T = UI.T
local F = UI.F
local create = UI.create
local label = UI.label
local rgb = Color3.fromRGB

local App
local screen
local refs: { [string]: any } = {}

local ITEM_COLORS = {
	new = T.cardDark,
	pending = T.cardDark,
	preparing = rgb(204, 228, 255),
	ready = rgb(206, 244, 214),
	carried = rgb(255, 232, 196),
	served = T.card,
}

local function productById(id)
	return App.Config.productById(id)
end

-- Perfil e missão ----------------------------------------------------------------------------------

local function buildProfile()
	local profile = UI.scaled(UI.panel({ Name = "Perfil", Position = UDim2.fromOffset(16, 12), Size = UDim2.fromOffset(300, 76), Parent = screen }))
	local badge = create("Frame", { Position = UDim2.fromOffset(12, 12), Size = UDim2.fromOffset(52, 52), BackgroundColor3 = T.gold, Parent = profile }, { UI.corner("full") })
	label({ Text = "NÍVEL", FontFace = F.heavy, TextSize = 10, TextColor3 = rgb(255, 236, 200), TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(0, 8), Size = UDim2.new(1, 0, 0, 10), Parent = badge })
	refs.level = label({ Text = "1", FontFace = F.heavy, TextSize = 26, TextColor3 = rgb(255, 255, 255), TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(0, 16), Size = UDim2.new(1, 0, 0, 30), Parent = badge })
	label({ Text = "Adega de " .. Players.LocalPlayer.DisplayName, FontFace = F.extra, TextSize = 17, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(76, 12), Size = UDim2.fromOffset(212, 22), Parent = profile })
	local _, fill = UI.bar(profile, { Position = UDim2.fromOffset(76, 42), Size = UDim2.fromOffset(212, 10) })
	refs.xpFill = fill
	refs.xpText = label({ Text = "", FontFace = F.bold, TextSize = 12, TextColor3 = T.muted, Position = UDim2.fromOffset(76, 54), Size = UDim2.fromOffset(212, 14), Parent = profile })

	local quest = UI.scaled(UI.panel({ Name = "Missao", Position = UDim2.fromOffset(16, 96), Size = UDim2.fromOffset(300, 92), Parent = screen }))
	refs.quest = quest
	refs.questTitle = label({ Text = "MISSÃO", FontFace = F.heavy, TextSize = 11, TextColor3 = T.gold, Position = UDim2.fromOffset(16, 10), Size = UDim2.new(1, -110, 0, 14), Parent = quest })
	refs.questReward = UI.chip(quest, "", T.green, { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 8) })
	refs.questText = label({ Text = "", FontFace = F.bold, TextSize = 16, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Position = UDim2.fromOffset(16, 30), Size = UDim2.new(1, -32, 0, 38), Parent = quest })
	local _, qFill = UI.bar(quest, { Position = UDim2.fromOffset(16, 72), Size = UDim2.new(1, -90, 0, 8) }, T.green)
	refs.questFill = qFill
	refs.questProgress = label({ Text = "", FontFace = F.extra, TextSize = 12, TextColor3 = T.muted, TextXAlignment = Enum.TextXAlignment.Right, Position = UDim2.new(1, -70, 0, 66), Size = UDim2.fromOffset(56, 18), Parent = quest })
end

-- Barra de status (dinheiro, relógio, avaliação) --------------------------------------------------------

local function divider(parent, order)
	create("Frame", { Size = UDim2.fromOffset(1, 36), BackgroundColor3 = T.line, BorderSizePixel = 0, LayoutOrder = order, Parent = parent })
end

local function buildStatus()
	local bar = UI.scaled(UI.panel({ Name = "Status", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 12), Size = UDim2.fromOffset(0, 64), AutomaticSize = Enum.AutomaticSize.X, Parent = screen }))
	UI.pad(0, 18, 0, 18).Parent = bar
	UI.list(Enum.FillDirection.Horizontal, 16, nil, Enum.VerticalAlignment.Center).Parent = bar

	local money = create("Frame", { Size = UDim2.fromOffset(0, 64), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, LayoutOrder = 1, Parent = bar })
	UI.list(Enum.FillDirection.Horizontal, 10, nil, Enum.VerticalAlignment.Center).Parent = money
	Icons.coin(34).Parent = money
	refs.money = label({ Text = "R$ 0", FontFace = F.heavy, TextSize = 30, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 40), Parent = money })
	refs.moneyAnchor = money
	refs.shownCash = create("NumberValue", { Value = 0 })
	refs.shownCash.Changed:Connect(function(value)
		refs.money.Text = App.Util.formatMoney(value)
	end)
	divider(bar, 2)

	local clock = create("Frame", { Size = UDim2.fromOffset(0, 64), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, LayoutOrder = 3, Parent = bar })
	UI.list(Enum.FillDirection.Horizontal, 10, nil, Enum.VerticalAlignment.Center).Parent = clock
	local clockIcon, setClock = Icons.clock(30)
	clockIcon.Parent = clock
	refs.setClock = setClock
	local clockText = create("Frame", { Size = UDim2.fromOffset(150, 44), BackgroundTransparency = 1, Parent = clock })
	refs.clock = label({ Text = "16:30", FontFace = F.heavy, TextSize = 24, Size = UDim2.new(1, 0, 0, 26), Parent = clockText })
	refs.period = label({ Text = "", FontFace = F.bold, TextSize = 12, TextColor3 = T.muted, Position = UDim2.fromOffset(0, 26), Size = UDim2.new(1, 0, 0, 16), Parent = clockText })
	divider(bar, 4)

	local rating = create("Frame", { Size = UDim2.fromOffset(0, 64), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, LayoutOrder = 5, Parent = bar })
	UI.list(Enum.FillDirection.Horizontal, 8, nil, Enum.VerticalAlignment.Center).Parent = rating
	Icons.star(30, T.gold).Parent = rating
	local ratingText = create("Frame", { Size = UDim2.fromOffset(86, 44), BackgroundTransparency = 1, Parent = rating })
	refs.rating = label({ Text = "3,0", FontFace = F.heavy, TextSize = 24, Size = UDim2.new(1, 0, 0, 26), Parent = ratingText })
	label({ Text = "avaliação", FontFace = F.bold, TextSize = 12, TextColor3 = T.muted, Position = UDim2.fromOffset(0, 26), Size = UDim2.new(1, 0, 0, 16), Parent = ratingText })

	local chips = UI.scaled(create("Frame", { Name = "Resumo", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 84), Size = UDim2.fromOffset(640, 28), BackgroundTransparency = 1, Parent = screen }))
	UI.list(Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Center).Parent = chips
	local function chip(order, color)
		local frame = create("Frame", { AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 26), BackgroundColor3 = T.panel, BackgroundTransparency = 0.04, LayoutOrder = order, Parent = chips }, {
			UI.corner("full"),
			UI.pad(0, 12, 0, 10),
			UI.list(Enum.FillDirection.Horizontal, 7, nil, Enum.VerticalAlignment.Center),
		})
		Icons.dot(8, color).Parent = frame
		local text = label({ Text = "", FontFace = F.bold, TextSize = 13, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 26), Parent = frame })
		return text, frame
	end
	refs.chipPeople = chip(1, T.blue)
	refs.chipFree = chip(2, T.green)
	refs.chipDirty, refs.chipDirtyFrame = chip(3, T.teal)
	refs.chipMoney, refs.chipMoneyFrame = chip(4, T.gold)
end

-- Pedidos -----------------------------------------------------------------------------------------

local function buildOrders()
	local panel = UI.scaled(UI.panel({ Name = "Pedidos", Position = UDim2.fromOffset(16, 200), Size = UDim2.fromOffset(300, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = screen }))
	UI.pad(12, 12, 12, 12).Parent = panel
	UI.list(Enum.FillDirection.Vertical, 8).Parent = panel
	local header = create("Frame", { Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, LayoutOrder = 0, Parent = panel })
	Icons.clipboard(18, T.text).Parent = header
	label({ Text = "Pedidos", FontFace = F.heavy, TextSize = 17, Position = UDim2.fromOffset(26, 0), Size = UDim2.new(1, -60, 1, 0), Parent = header })
	refs.ordersCount = label({ Text = "", FontFace = F.heavy, TextSize = 14, TextColor3 = T.muted, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.fromScale(1, 1), Parent = header })
	refs.ordersEmpty = label({ Text = "Nenhum pedido agora. Os clientes chegam pela calçada.", FontFace = F.medium, TextSize = 13, TextColor3 = T.muted, TextWrapped = true, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = 1, Parent = panel })
	refs.orders = panel
	refs.tickets = {}
end

local function ticket(index)
	local existing = refs.tickets[index]
	if existing then
		return existing
	end
	local frame = create("Frame", { Size = UDim2.new(1, 0, 0, 62), BackgroundColor3 = T.card, LayoutOrder = index + 1, Parent = refs.orders }, { UI.corner(12) })
	local place = UI.chip(frame, "", T.blue, { Position = UDim2.fromOffset(8, 8) })
	local status = label({ Text = "", FontFace = F.bold, TextSize = 12, TextColor3 = T.muted, Position = UDim2.fromOffset(10, 34), Size = UDim2.fromOffset(100, 16), Parent = frame })
	local icons = create("Frame", { Position = UDim2.fromOffset(112, 6), Size = UDim2.new(1, -118, 0, 40), BackgroundTransparency = 1, Parent = frame })
	UI.list(Enum.FillDirection.Horizontal, 4, Enum.HorizontalAlignment.Right).Parent = icons
	local _, fill = UI.bar(frame, { Position = UDim2.new(0, 10, 1, -9), Size = UDim2.new(1, -20, 0, 4) }, T.green)
	local entry = { frame = frame, place = place, status = status, icons = icons, fill = fill, boxes = {} }
	refs.tickets[index] = entry
	return entry
end

local STATE_TEXT = {
	new = "Anotar",
	pending = "Preparar",
	preparing = "Preparando",
	ready = "Pronto",
	carried = "Na bandeja",
	served = "Entregue",
}

local function updateOrders(state)
	local orders = state.orders
	refs.ordersEmpty.Visible = #orders == 0
	refs.ordersCount.Text = if #orders > 0 then tostring(#orders) else ""
	for index = 1, math.max(#orders, #refs.tickets) do
		local order = orders[index]
		local entry = refs.tickets[index]
		if order == nil then
			if entry then
				entry.frame.Visible = false
			end
			continue
		end
		entry = ticket(index)
		entry.frame.Visible = true
		entry.place.Text = order.label
		if order.state == "waiting" then
			entry.place.BackgroundColor3 = T.gold
			entry.status.Text = "Chamando  " .. order.wait .. "s"
			entry.status.TextColor3 = T.goldDark
		else
			entry.place.BackgroundColor3 = T.blue
			local first = order.icons[1]
			for _, icon in order.icons do
				if icon[2] ~= "served" then
					first = icon
					break
				end
			end
			entry.status.Text = (STATE_TEXT[first[2]] or "") .. "  " .. order.wait .. "s"
			entry.status.TextColor3 = T.muted
		end
		for i, icon in order.icons do
			local box = entry.boxes[i]
			if box == nil or box.productId ~= icon[1] then
				if box then
					box.frame:Destroy()
				end
				local frame = create("Frame", { Size = UDim2.fromOffset(40, 40), BackgroundColor3 = T.cardDark, LayoutOrder = i, Parent = entry.icons }, { UI.corner(10) })
				local product = productById(icon[1])
				if product then
					UI.product(product, 38, { Position = UDim2.fromOffset(1, 1), Parent = frame })
				end
				box = { frame = frame, productId = icon[1] }
				entry.boxes[i] = box
			end
			box.frame.Visible = true
			box.frame.BackgroundColor3 = ITEM_COLORS[icon[2]] or T.cardDark
			box.frame.BackgroundTransparency = if icon[2] == "served" then 0.5 else 0
		end
		for i = #order.icons + 1, #entry.boxes do
			entry.boxes[i].frame.Visible = false
		end
		local ratio = order.patience
		entry.fill.Size = UDim2.fromScale(ratio, 1)
		entry.fill.BackgroundColor3 = if ratio > 0.5 then T.green elseif ratio > 0.25 then T.gold else T.red
	end
end

-- Bandeja e dica ---------------------------------------------------------------------------------------

local function buildCarry()
	local tray = UI.scaled(UI.panel({ Name = "Bandeja", AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -16), Size = UDim2.fromOffset(0, 104), AutomaticSize = Enum.AutomaticSize.X, Visible = false, Parent = screen }))
	UI.pad(10, 14, 10, 14).Parent = tray
	refs.trayTitle = label({ Text = "BANDEJA", FontFace = F.heavy, TextSize = 12, TextColor3 = T.gold, Size = UDim2.fromOffset(200, 14), Parent = tray })
	local slots = create("Frame", { Position = UDim2.fromOffset(0, 20), Size = UDim2.fromOffset(0, 64), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Parent = tray })
	UI.list(Enum.FillDirection.Horizontal, 8).Parent = slots
	refs.traySlots = {}
	for i = 1, 6 do
		local slot = create("Frame", { Size = UDim2.fromOffset(72, 64), BackgroundColor3 = T.card, LayoutOrder = i, Visible = i <= 4, Parent = slots }, { UI.corner(12) })
		local where = label({ Text = "", FontFace = F.extra, TextSize = 11, TextColor3 = T.muted, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.new(0, 0, 1, -16), Size = UDim2.new(1, 0, 0, 14), Parent = slot })
		refs.traySlots[i] = { frame = slot, where = where, view = nil, productId = nil }
	end
	refs.tray = tray

	refs.hint = UI.scaled(create("Frame", {
		Name = "Dica",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -128),
		Size = UDim2.fromOffset(0, 38),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = T.panel,
		Visible = false,
		Parent = screen,
	}, { UI.corner("full"), UI.pad(0, 18, 0, 14), UI.list(Enum.FillDirection.Horizontal, 10, nil, Enum.VerticalAlignment.Center) }))
	refs.hintDot = Icons.dot(10, T.gold)
	refs.hintDot.Parent = refs.hint
	refs.hintText = label({ Text = "", FontFace = F.bold, TextSize = 15, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 38), Parent = refs.hint })
end

local function updateCarry(state)
	local carry = state.carry
	refs.tray.Visible = #carry > 0 and not refs.buildMode
	refs.trayTitle.Text = "BANDEJA  " .. #carry .. "/" .. state.carryLimit
	for i, slot in refs.traySlots do
		slot.frame.Visible = i <= state.carryLimit
		local entry = carry[i]
		local id = entry and entry[1]
		if slot.productId ~= id then
			if slot.view then
				slot.view:Destroy()
				slot.view = nil
			end
			slot.productId = id
			local product = id and productById(id)
			if product then
				slot.view = UI.product(product, 46, { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 2), Parent = slot.frame })
			end
		end
		slot.where.Text = if entry then entry[2] else ""
		slot.frame.BackgroundColor3 = if entry then rgb(255, 240, 214) else T.card
	end
end

local function updateHint(state)
	local text = nil
	local waiting, pending, ready = nil, false, false
	for _, order in state.orders do
		if order.state == "waiting" and waiting == nil then
			waiting = order.label
		end
		for _, icon in order.icons do
			if icon[2] == "pending" then
				pending = true
			elseif icon[2] == "ready" then
				ready = true
			end
		end
	end
	if #state.carry > 0 then
		text = "Leve a bandeja até " .. state.carry[1][2] .. " e aperte E para entregar"
	elseif waiting then
		text = waiting .. " está chamando: vá até lá e aperte E para anotar"
	elseif ready then
		text = "Tem pedido pronto no balcão: aperte F perto dele para pegar"
	elseif pending then
		text = "Prepare os pedidos: chegue perto da geladeira ou estação e segure E"
	elseif state.tableMoney > 0 then
		text = "Tem dinheiro deixado nas mesas para você pegar"
	elseif state.dirtyTables > 0 then
		text = "Tem mesa suja: segure E perto dela para limpar"
	end
	local show = text ~= nil and state.level < 10 and not refs.buildMode
	refs.hint.Visible = show
	if show then
		refs.hintText.Text = text
	end
end

-- Menu lateral ---------------------------------------------------------------------------------

local function buildMenu()
	local menu = UI.scaled(create("Frame", {
		Name = "Menu",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -16, 0.56, 0),
		Size = UDim2.fromOffset(80, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = screen,
	}))
	UI.list(Enum.FillDirection.Vertical, 8, Enum.HorizontalAlignment.Center).Parent = menu
	refs.menu = menu
	refs.menuBadges = {}
	local entries = {
		{ id = "construir", icon = Icons.hammer, text = "Construir", color = T.gold },
		{ id = "equipe", icon = Icons.people, text = "Equipe", color = T.blue },
		{ id = "cardapio", icon = Icons.clipboard, text = "Cardápio", color = T.red },
		{ id = "avaliacoes", icon = Icons.star, text = "Avaliações", color = rgb(255, 179, 0) },
		{ id = "expandir", icon = Icons.expand, text = "Expandir", color = T.green },
		{ id = "estilo", icon = Icons.palette, text = "Estilo", color = T.purple },
		{ id = "voltar", icon = Icons.home, text = "Minha adega", color = T.muted },
	}
	for index, entry in entries do
		local button = create("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.fromOffset(78, 76), BackgroundColor3 = T.panel, LayoutOrder = index, Parent = menu }, {
			UI.corner(18),
			UI.stroke(rgb(0, 0, 0), 1, 0.9),
		})
		local square = create("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 8), Size = UDim2.fromOffset(42, 42), BackgroundColor3 = entry.color, Parent = button }, { UI.corner(12) })
		local icon = entry.icon(26, rgb(255, 255, 255), entry.color)
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.Position = UDim2.fromScale(0.5, 0.5)
		icon.Parent = square
		label({ Text = entry.text, FontFace = F.extra, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(0, 54), Size = UDim2.new(1, 0, 0, 16), Parent = button })
		local badge = create("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -8, 0, 8), Size = UDim2.fromOffset(16, 16), BackgroundColor3 = T.red, Visible = false, ZIndex = 3, Parent = button }, {
			UI.corner("full"),
			UI.stroke(rgb(255, 255, 255), 2, 0),
		})
		refs.menuBadges[entry.id] = badge
		local scale = create("UIScale", { Parent = button })
		button.MouseEnter:Connect(function()
			UI.tween(scale, 0.12, { Scale = 1.07 })
		end)
		button.MouseLeave:Connect(function()
			UI.tween(scale, 0.12, { Scale = 1 })
		end)
		button.Activated:Connect(function()
			UI.tween(scale, 0.08, { Scale = 0.92 })
			task.delay(0.08, function()
				UI.tween(scale, 0.18, { Scale = 1 }, Enum.EasingStyle.Back)
			end)
			App.openMenu(entry.id)
		end)
	end
end

-- Avisos, banner e resumo -----------------------------------------------------------------------------

local TOAST_STYLE = {
	compra = { icon = Icons.check, color = T.green },
	dinheiro = { icon = Icons.coin, color = T.gold },
	nivel = { icon = Icons.star, color = T.purple },
	erro = { icon = Icons.alert, color = T.red },
	info = { icon = Icons.info, color = T.blue },
	missao = { icon = Icons.star, color = T.gold },
}
local toastCount = 0

local function buildToasts()
	refs.toasts = UI.scaled(create("Frame", {
		Name = "Avisos",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 120),
		Size = UDim2.fromOffset(420, 300),
		BackgroundTransparency = 1,
		Parent = screen,
	}))
	UI.list(Enum.FillDirection.Vertical, 8, Enum.HorizontalAlignment.Center).Parent = refs.toasts

	local overlay = UI.newScreen("AdegaDestaques", 20, true)
	local banner = UI.panel({ AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.36), Size = UDim2.fromOffset(460, 190), Visible = false, Parent = overlay })
	banner.UICorner.CornerRadius = UDim.new(0, 26)
	refs.bannerScale = create("UIScale", { Parent = banner })
	local top = create("Frame", { Size = UDim2.new(1, 0, 0, 70), BackgroundColor3 = T.gold, BorderSizePixel = 0, Parent = banner }, { UI.corner(26) })
	create("Frame", { Position = UDim2.new(0, 0, 1, -26), Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = T.gold, BorderSizePixel = 0, Parent = top })
	refs.bannerKicker = label({ Text = "NOVO NÍVEL", FontFace = F.heavy, TextSize = 15, TextColor3 = rgb(255, 236, 200), TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(0, 10), Size = UDim2.new(1, 0, 0, 18), Parent = top })
	refs.bannerTitle = label({ Text = "", FontFace = F.heavy, TextSize = 36, TextColor3 = rgb(255, 255, 255), TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(0, 26), Size = UDim2.new(1, 0, 0, 40), Parent = top })
	refs.bannerSub = label({ Text = "", FontFace = F.bold, TextSize = 16, TextWrapped = true, TextColor3 = T.text, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(24, 80), Size = UDim2.new(1, -48, 0, 96), Parent = banner })
	refs.banner = banner
end

function Hud.toast(text, kind)
	local style = TOAST_STYLE[kind] or TOAST_STYLE.info
	toastCount += 1
	local holder = create("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(420, 52), LayoutOrder = toastCount, Parent = refs.toasts })
	local box = UI.panel({ Position = UDim2.fromOffset(0, -16), Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = holder })
	create("Frame", { Position = UDim2.fromOffset(0, 0), Size = UDim2.new(0, 6, 1, 0), BackgroundColor3 = style.color, BorderSizePixel = 0, Parent = box }, { UI.corner(3) })
	local icon = style.icon(26, style.color)
	icon.Position = UDim2.fromOffset(18, 13)
	icon.Parent = box
	label({ Text = text, FontFace = F.bold, TextSize = 15, TextWrapped = true, Position = UDim2.fromOffset(56, 0), Size = UDim2.new(1, -68, 1, 0), Parent = box })
	UI.tween(box, 0.28, { Position = UDim2.fromOffset(0, 0), BackgroundTransparency = 0 }, Enum.EasingStyle.Back)
	local frames = {}
	for _, child in refs.toasts:GetChildren() do
		if child:IsA("Frame") then
			table.insert(frames, child)
		end
	end
	if #frames > 4 then
		table.sort(frames, function(a, b)
			return a.LayoutOrder < b.LayoutOrder
		end)
		for i = 1, #frames - 4 do
			frames[i]:Destroy()
		end
	end
	task.delay(3.6, function()
		if holder.Parent then
			UI.tween(box, 0.25, { Position = UDim2.fromOffset(0, -10), BackgroundTransparency = 1 })
			for _, child in box:GetDescendants() do
				if child:IsA("TextLabel") then
					UI.tween(child, 0.25, { TextTransparency = 1 })
				elseif child:IsA("Frame") then
					UI.tween(child, 0.25, { BackgroundTransparency = 1 })
				elseif child:IsA("UIStroke") then
					UI.tween(child, 0.25, { Transparency = 1 })
				end
			end
			task.wait(0.27)
			holder:Destroy()
		end
	end)
end

function Hud.banner(title, subtitle)
	local banner = refs.banner
	refs.bannerTitle.Text = title
	refs.bannerSub.Text = subtitle or ""
	banner.Visible = true
	refs.bannerScale.Scale = 0.4 * UI.currentScale()
	UI.tween(refs.bannerScale, 0.45, { Scale = UI.currentScale() }, Enum.EasingStyle.Back)
	local token = {}
	refs.bannerToken = token
	task.delay(3.4, function()
		if refs.bannerToken ~= token then
			return
		end
		UI.tween(refs.bannerScale, 0.25, { Scale = 0.4 * UI.currentScale() }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		task.wait(0.25)
		if refs.bannerToken == token then
			banner.Visible = false
		end
	end)
end

function Hud.summary(data)
	local win = refs.summary
	if win == nil then
		win = UI.window("Fim de expediente", "Como foi o dia na sua adega", T.gold, UDim2.fromOffset(520, 420))
		local body = win.body
		UI.list(Enum.FillDirection.Vertical, 10, Enum.HorizontalAlignment.Center).Parent = body
		local rows = {}
		for index, spec in { { Icons.people, T.blue, "Clientes atendidos" }, { Icons.coin, T.gold, "Faturamento" }, { Icons.star, T.gold, "Nota média do dia" } } do
			local row = UI.panel({ Size = UDim2.new(1, 0, 0, 62), LayoutOrder = index, Parent = body })
			local icon = spec[1](30, spec[2])
			icon.Position = UDim2.fromOffset(18, 16)
			icon.Parent = row
			label({ Text = spec[3], FontFace = F.bold, TextSize = 17, TextColor3 = T.muted, Position = UDim2.fromOffset(62, 0), Size = UDim2.new(1, -220, 1, 0), Parent = row })
			rows[index] = label({ Text = "", FontFace = F.heavy, TextSize = 26, TextXAlignment = Enum.TextXAlignment.Right, Position = UDim2.new(1, -170, 0, 0), Size = UDim2.fromOffset(150, 62), Parent = row })
		end
		UI.button({ Style = "gold", Text = "Bora pra mais um dia", Size = UDim2.fromOffset(280, 50), LayoutOrder = 5, Parent = body }, function()
			win.hide()
		end)
		win.rows = rows
		refs.summary = win
	end
	win.rows[1].Text = tostring(data.served or 0)
	win.rows[2].Text = App.Util.formatMoney(data.earned or 0)
	win.rows[3].Text = if data.rating then App.Util.formatDecimal(data.rating) else "—"
	win.show()
end

-- Atualização ------------------------------------------------------------------------------------

function Hud.update(state, previous)
	UI.tween(refs.shownCash, 0.45, { Value = state.cash })
	if previous and state.cash > previous.cash then
		refs.pendingGain = (refs.pendingGain or 0) + state.cash - previous.cash
	end
	refs.level.Text = tostring(state.level)
	local ratio = if state.level >= App.Config.MaxLevel then 1 else math.clamp(state.xp / state.xpNext, 0, 1)
	UI.tween(refs.xpFill, 0.3, { Size = UDim2.fromScale(ratio, 1) })
	refs.xpText.Text = if state.level >= App.Config.MaxLevel then "Nível máximo" else App.Util.formatNumber(state.xp) .. " / " .. App.Util.formatNumber(state.xpNext) .. " XP"

	local quest = state.quest
	refs.quest.Visible = quest ~= nil
	if quest then
		refs.questTitle.Text = "MISSÃO " .. quest.index .. " DE " .. quest.total
		refs.questText.Text = quest.text
		refs.questFill.Size = UDim2.fromScale(quest.progress / quest.target, 1)
		refs.questProgress.Text = quest.progress .. "/" .. quest.target
		refs.questReward.Text = "+" .. App.Util.formatMoney(quest.reward)
	end
	refs.orders.Position = UDim2.fromOffset(16, if quest then 200 else 96)

	refs.chipPeople.Text = state.present .. (if state.present == 1 then " cliente" else " clientes")
	refs.chipFree.Text = state.freeTables .. (if state.freeTables == 1 then " mesa livre" else " mesas livres")
	refs.chipDirty.Text = state.dirtyTables .. (if state.dirtyTables == 1 then " mesa suja" else " mesas sujas")
	refs.chipDirtyFrame.Visible = state.dirtyTables > 0
	refs.chipMoney.Text = App.Util.formatMoney(state.tableMoney) .. " nas mesas"
	refs.chipMoneyFrame.Visible = state.tableMoney > 0

	refs.rating.Text = App.Util.formatDecimal(state.rating)

	updateOrders(state)
	updateCarry(state)
	updateHint(state)

	refs.menuBadges.equipe.Visible = #state.staff == 0 and state.cash >= 300
	local nextSize = App.Config.PlotSizes[state.sizeLevel + 1]
	refs.menuBadges.expandir.Visible = nextSize ~= nil and state.level >= nextSize.level and state.cash >= nextSize.price
end

function Hud.setBuildMode(on)
	refs.buildMode = on
	refs.menu.Visible = not on
	refs.orders.Visible = not on
	if App.state then
		updateCarry(App.state)
		updateHint(App.state)
	end
end

local function floatingGain(amount)
	local gain = label({
		Text = "+" .. App.Util.formatMoney(amount),
		FontFace = F.heavy,
		TextSize = 22,
		TextColor3 = T.green,
		TextXAlignment = Enum.TextXAlignment.Center,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 1, 4),
		Size = UDim2.fromOffset(200, 26),
		ZIndex = 5,
		Parent = refs.moneyAnchor,
	})
	local stroke = create("UIStroke", { Color = rgb(255, 255, 255), Thickness = 2, Parent = gain })
	UI.tween(gain, 1.1, { Position = UDim2.new(0.5, 0, 1, 36), TextTransparency = 1 })
	UI.tween(stroke, 1.1, { Transparency = 1 })
	task.delay(1.2, function()
		gain:Destroy()
	end)
end

function Hud.init(app)
	App = app
	screen = UI.newScreen("AdegaHUD", 1, false)
	buildProfile()
	buildStatus()
	buildOrders()
	buildCarry()
	buildMenu()
	buildToasts()

	task.spawn(function()
		while true do
			task.wait(0.25)
			local hour = Lighting.ClockTime
			refs.clock.Text = App.Util.clockText(hour)
			refs.setClock(hour)
			if hour >= 18 or hour < 2 then
				refs.period.Text = "Horário nobre"
				refs.period.TextColor3 = T.goldDark
			elseif hour < 6 then
				refs.period.Text = "Madrugada calma"
				refs.period.TextColor3 = T.muted
			else
				refs.period.Text = "Movimento normal"
				refs.period.TextColor3 = T.muted
			end
			if refs.pendingGain and refs.pendingGain > 0 then
				floatingGain(refs.pendingGain)
				refs.pendingGain = 0
			end
		end
	end)
end

return Hud
