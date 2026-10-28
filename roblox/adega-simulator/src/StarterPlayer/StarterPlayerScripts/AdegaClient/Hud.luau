-- Hud: o que fica sempre na tela.

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local UI = require(script.Parent.UI)

local Hud = {}

local T = UI.T
local F = UI.Fonts
local create = UI.create
local label = UI.label
local rgb = Color3.fromRGB

local App
local screen
local refs: { [string]: any } = {}

local STATE_STYLE = {
	waiting = { text = "❗ Anotar pedido", color = rgb(255, 160, 30) },
	open = { text = "⏳ Em preparo", color = rgb(70, 150, 255) },
}
local ITEM_COLORS = {
	new = rgb(70, 64, 92),
	pending = rgb(70, 64, 92),
	preparing = rgb(70, 150, 255),
	ready = rgb(56, 210, 116),
	carried = rgb(255, 196, 40),
	served = rgb(40, 34, 56),
}

-- Perfil e missão ----------------------------------------------------------------------------------

local function buildProfile()
	local profile = UI.scaled(UI.panel({ Name = "Perfil", Position = UDim2.fromOffset(12, 10), Size = UDim2.fromOffset(310, 78), Parent = screen }))
	local badge = create("Frame", { Position = UDim2.fromOffset(10, 10), Size = UDim2.fromOffset(58, 58), BackgroundColor3 = rgb(255, 255, 255), Parent = profile }, {
		UI.corner("full"),
		UI.gradient(T.gold, T.orange),
		UI.stroke(rgb(255, 255, 255), 2, 0.4),
	})
	label({ Text = "NÍVEL", Font = F.black, TextSize = 10, TextColor3 = rgb(80, 40, 0), TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(0, 7), Size = UDim2.new(1, 0, 0, 12), Parent = badge })
	refs.level = label({ Text = "1", Font = F.title, TextSize = 28, TextColor3 = rgb(60, 25, 0), TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(0, 18), Size = UDim2.new(1, 0, 0, 32), Parent = badge })
	label({ Text = "Adega de " .. Players.LocalPlayer.DisplayName, TextSize = 17, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(80, 10), Size = UDim2.fromOffset(220, 22), Parent = profile })
	local xpTrack, fill = UI.bar(profile, { Position = UDim2.fromOffset(80, 42), Size = UDim2.fromOffset(218, 18) })
	refs.xpFill = fill
	refs.xpText = label({ Text = "", TextSize = 11, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), ZIndex = 3, Parent = xpTrack })

	local quest = UI.scaled(UI.panel({ Name = "Missao", Position = UDim2.fromOffset(12, 96), Size = UDim2.fromOffset(310, 84), Parent = screen }))
	quest.UIStroke.Color = T.gold
	refs.quest = quest
	refs.questTitle = label({ Text = "MISSÃO", Font = F.black, TextSize = 11, TextColor3 = T.gold, Position = UDim2.fromOffset(14, 8), Size = UDim2.new(1, -28, 0, 14), Parent = quest })
	refs.questText = label({ Text = "", TextSize = 15, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Position = UDim2.fromOffset(14, 24), Size = UDim2.new(1, -28, 0, 36), Parent = quest })
	local qTrack, qFill = UI.bar(quest, { Position = UDim2.fromOffset(14, 62), Size = UDim2.new(1, -120, 0, 12), ColorA = T.gold, ColorB = T.orange })
	refs.questFill = qFill
	refs.questProgress = label({ Text = "", TextSize = 10, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), ZIndex = 3, Parent = qTrack })
	refs.questReward = label({ Text = "", Font = F.title, TextSize = 15, TextColor3 = T.green, TextXAlignment = Enum.TextXAlignment.Right, Position = UDim2.new(1, -102, 0, 58), Size = UDim2.fromOffset(88, 20), Parent = quest })
end

-- Dinheiro e resumo ---------------------------------------------------------------------------------

local function buildMoney()
	local money = UI.scaled(UI.panel({ Name = "Dinheiro", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 10), Size = UDim2.fromOffset(280, 62), Parent = screen }))
	money.UIStroke.Color = T.gold
	money.UIStroke.Thickness = 2
	money.UIStroke.Transparency = 0.1
	create("Frame", { Position = UDim2.fromOffset(9, 8), Size = UDim2.fromOffset(46, 46), BackgroundColor3 = rgb(255, 255, 255), Parent = money }, {
		UI.corner("full"),
		UI.gradient(T.gold, T.orange),
		label({ Text = "💰", TextSize = 24, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1) }),
	})
	refs.money = label({ Text = "R$ 0", Font = F.title, TextSize = 34, TextColor3 = T.gold, Position = UDim2.fromOffset(64, 4), Size = UDim2.fromOffset(206, 54), Parent = money })
	create("UIStroke", { Color = rgb(90, 50, 0), Thickness = 1.2, Transparency = 0.4, Parent = refs.money })
	refs.moneyCard = money
	refs.shownCash = create("NumberValue", { Value = 0 })
	refs.shownCash.Changed:Connect(function(value)
		refs.money.Text = App.Util.formatMoney(value)
	end)

	local chips = UI.scaled(create("Frame", { Name = "Resumo", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 78), Size = UDim2.fromOffset(520, 28), BackgroundTransparency = 1, Parent = screen }))
	create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Parent = chips })
	local function chip(order, color)
		local frame = create("Frame", { AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 26), BackgroundColor3 = T.panel, BackgroundTransparency = 0.1, LayoutOrder = order, Parent = chips }, {
			UI.corner("full"),
			UI.stroke(color, 1.2, 0.3),
			UI.pad(0, 10, 0, 10),
		})
		return label({ Text = "", TextSize = 13, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 26), Parent = frame }), frame
	end
	refs.chipPeople = chip(1, T.blue)
	refs.chipFree = chip(2, T.green)
	refs.chipDirty, refs.chipDirtyFrame = chip(3, T.cyan)
	refs.chipMoney, refs.chipMoneyFrame = chip(4, T.gold)
end

-- Relógio e avaliação -------------------------------------------------------------------------------

local function buildClock()
	local clock = UI.scaled(UI.panel({ Name = "Relogio", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 10), Size = UDim2.fromOffset(250, 84), Parent = screen }))
	refs.clockIcon = label({ Text = "☀️", TextSize = 26, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(8, 8), Size = UDim2.fromOffset(38, 36), Parent = clock })
	refs.clock = label({ Text = "16:30", Font = F.title, TextSize = 30, Position = UDim2.fromOffset(50, 4), Size = UDim2.fromOffset(100, 40), Parent = clock })
	refs.period = label({ Text = "", TextSize = 12, TextColor3 = T.muted, Position = UDim2.fromOffset(14, 50), Size = UDim2.fromOffset(226, 24), TextWrapped = true, Parent = clock })
	refs.stars = label({ Text = "", Font = F.black, TextSize = 16, TextColor3 = T.gold, TextXAlignment = Enum.TextXAlignment.Right, RichText = true, Position = UDim2.fromOffset(136, 8), Size = UDim2.fromOffset(102, 20), Parent = clock })
	refs.rating = label({ Text = "", Font = F.title, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Right, Position = UDim2.fromOffset(136, 28), Size = UDim2.fromOffset(102, 18), Parent = clock })
end

-- Pedidos -----------------------------------------------------------------------------------------

local function buildOrders()
	local panel = UI.scaled(UI.panel({ Name = "Pedidos", Position = UDim2.fromOffset(12, 190), Size = UDim2.fromOffset(310, 60), AutomaticSize = Enum.AutomaticSize.Y, Parent = screen }))
	UI.pad(10, 12, 12, 12).Parent = panel
	UI.list(Enum.FillDirection.Vertical, 6).Parent = panel
	label({ Text = "📋  PEDIDOS", Font = F.black, TextSize = 12, TextColor3 = T.muted, Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 0, Parent = panel })
	refs.ordersEmpty = label({ Text = "Nenhum pedido agora. Os clientes chegam pela calçada.", Font = F.body, TextSize = 12, TextColor3 = T.muted, TextWrapped = true, Size = UDim2.new(1, 0, 0, 30), LayoutOrder = 1, Parent = panel })
	refs.orders = panel
	refs.tickets = {}
end

local function ticket(index)
	local existing = refs.tickets[index]
	if existing then
		return existing
	end
	local frame = create("Frame", { Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = T.card, LayoutOrder = index + 1, Parent = refs.orders }, { UI.corner(10) })
	local chip = create("Frame", { Position = UDim2.fromOffset(6, 6), Size = UDim2.fromOffset(70, 22), BackgroundColor3 = T.blue, Parent = frame }, { UI.corner(8) })
	local place = label({ Text = "", Font = F.black, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), Parent = chip })
	local status = label({ Text = "", Font = F.body, TextSize = 11, TextColor3 = T.muted, Position = UDim2.fromOffset(6, 30), Size = UDim2.fromOffset(110, 14), Parent = frame })
	local icons = create("Frame", { Position = UDim2.fromOffset(122, 6), Size = UDim2.new(1, -128, 0, 30), BackgroundTransparency = 1, Parent = frame })
	UI.list(Enum.FillDirection.Horizontal, 4).Parent = icons
	local _, fill = UI.bar(frame, { Position = UDim2.new(0, 122, 1, -10), Size = UDim2.new(1, -128, 0, 5), ColorA = T.green, ColorB = T.green })
	local entry = { frame = frame, chip = chip, place = place, status = status, icons = icons, fill = fill, iconLabels = {} }
	refs.tickets[index] = entry
	return entry
end

local function updateOrders(state)
	local orders = state.orders
	refs.ordersEmpty.Visible = #orders == 0
	for index = 1, math.max(#orders, #refs.tickets) do
		local order = orders[index]
		if order == nil then
			if refs.tickets[index] then
				refs.tickets[index].frame.Visible = false
			end
			continue
		end
		local entry = ticket(index)
		entry.frame.Visible = true
		local style = STATE_STYLE[order.state] or STATE_STYLE.open
		entry.place.Text = order.label
		entry.chip.BackgroundColor3 = style.color
		entry.status.Text = style.text .. "  " .. order.wait .. "s"
		for i, icon in order.icons do
			local box = entry.iconLabels[i]
			if box == nil then
				box = create("Frame", { Size = UDim2.fromOffset(30, 30), BackgroundColor3 = T.locked, LayoutOrder = i, Parent = entry.icons }, { UI.corner(8) })
				label({ Name = "Icone", Text = "", TextSize = 18, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), Parent = box })
				entry.iconLabels[i] = box
			end
			box.Visible = true
			box.Icone.Text = icon[1]
			box.BackgroundColor3 = ITEM_COLORS[icon[2]] or T.locked
			box.Icone.TextTransparency = if icon[2] == "served" then 0.6 else 0
		end
		for i = #order.icons + 1, #entry.iconLabels do
			entry.iconLabels[i].Visible = false
		end
		local ratio = order.patience
		entry.fill.Size = UDim2.fromScale(ratio, 1)
		entry.fill.UIGradient.Color = ColorSequence.new(if ratio > 0.5 then T.green elseif ratio > 0.25 then T.gold else T.red)
	end
end

-- Bandeja e dica ---------------------------------------------------------------------------------------

local function buildCarry()
	local tray = UI.scaled(UI.panel({ Name = "Bandeja", AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -14), Size = UDim2.fromOffset(330, 86), Visible = false, Parent = screen }))
	tray.UIStroke.Color = T.gold
	refs.trayTitle = label({ Text = "✋ BANDEJA", Font = F.black, TextSize = 11, TextColor3 = T.gold, Position = UDim2.fromOffset(14, 6), Size = UDim2.fromOffset(200, 14), Parent = tray })
	local slots = create("Frame", { Position = UDim2.fromOffset(12, 24), Size = UDim2.new(1, -24, 0, 54), BackgroundTransparency = 1, Parent = tray })
	UI.list(Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Center).Parent = slots
	refs.traySlots = {}
	for i = 1, 6 do
		local slot = create("Frame", { Size = UDim2.fromOffset(70, 54), BackgroundColor3 = T.card, LayoutOrder = i, Visible = i <= 4, Parent = slots }, { UI.corner(10) })
		local icon = label({ Text = "", TextSize = 24, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 34), Parent = slot })
		local where = label({ Text = "", Font = F.bold, TextSize = 11, TextColor3 = T.muted, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(0, 34), Size = UDim2.new(1, 0, 0, 16), Parent = slot })
		refs.traySlots[i] = { frame = slot, icon = icon, where = where }
	end
	refs.tray = tray

	refs.hint = UI.scaled(create("Frame", {
		Name = "Dica",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -108),
		Size = UDim2.fromOffset(520, 34),
		BackgroundColor3 = T.panel,
		BackgroundTransparency = 0.1,
		Visible = false,
		Parent = screen,
	}, { UI.corner("full"), UI.stroke(T.neon, 1.5, 0.2) }))
	refs.hintText = label({ Text = "", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), Parent = refs.hint })
end

local function updateCarry(state)
	local carry = state.carry
	refs.tray.Visible = #carry > 0 and not refs.buildMode
	refs.trayTitle.Text = "✋ BANDEJA  " .. #carry .. "/" .. state.carryLimit
	for i, slot in refs.traySlots do
		slot.frame.Visible = i <= state.carryLimit
		local entry = carry[i]
		slot.icon.Text = if entry then entry[1] else ""
		slot.where.Text = if entry then entry[2] else ""
		slot.frame.BackgroundColor3 = if entry then T.cardLight else T.card
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
	local carrying = #state.carry > 0
	if carrying then
		text = "✋ Leve a bandeja até " .. state.carry[1][2] .. " e aperte E para entregar"
	elseif waiting then
		text = "❗ " .. waiting .. " está chamando: vá até lá e aperte E para anotar"
	elseif ready then
		text = "✅ Tem pedido pronto no balcão: aperte F para pegar"
	elseif pending then
		text = "🍺 Prepare os pedidos nas estações: chegue perto e segure E"
	elseif state.tableMoney > 0 then
		text = "💵 Tem dinheiro deixado nas mesas para você pegar"
	elseif state.dirtyTables > 0 then
		text = "🧽 Tem mesa suja: segure E perto dela para limpar"
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
		Position = UDim2.new(1, -12, 0.5, 30),
		Size = UDim2.fromOffset(78, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = screen,
	}))
	UI.list(Enum.FillDirection.Vertical, 8, Enum.HorizontalAlignment.Center).Parent = menu
	refs.menu = menu
	refs.menuBadges = {}
	local entries = {
		{ id = "construir", icon = "🔨", text = "Construir", colors = { T.gold, T.orange } },
		{ id = "equipe", icon = "👥", text = "Equipe", colors = { T.blue, rgb(60, 70, 210) } },
		{ id = "cardapio", icon = "📋", text = "Cardápio", colors = { rgb(255, 92, 70), rgb(200, 30, 60) } },
		{ id = "avaliacoes", icon = "⭐", text = "Avaliações", colors = { rgb(255, 210, 60), rgb(230, 140, 20) } },
		{ id = "expandir", icon = "📐", text = "Expandir", colors = { T.green, T.greenDark } },
		{ id = "estilo", icon = "🎨", text = "Estilo", colors = { T.pink, T.neon } },
		{ id = "voltar", icon = "🏠", text = "Minha adega", colors = { T.cardLight, T.card } },
	}
	for index, entry in entries do
		local button = create("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.fromOffset(74, 70), BackgroundColor3 = T.panel, BackgroundTransparency = 0.05, LayoutOrder = index, Parent = menu }, {
			UI.corner(16),
			UI.stroke(entry.colors[1], 2, 0.35),
		})
		create("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 6), Size = UDim2.fromOffset(40, 40), BackgroundColor3 = rgb(255, 255, 255), Parent = button }, {
			UI.corner(12),
			UI.gradient(entry.colors[1], entry.colors[2], 135),
			label({ Text = entry.icon, TextSize = 22, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1) }),
		})
		label({ Text = entry.text, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(0, 48), Size = UDim2.new(1, 0, 0, 16), Parent = button })
		local badge = label({
			Text = "!",
			Font = F.black,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Center,
			BackgroundColor3 = T.red,
			BackgroundTransparency = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(1, -6, 0, 6),
			Size = UDim2.fromOffset(20, 20),
			Visible = false,
			ZIndex = 3,
			Parent = button,
		})
		UI.corner("full").Parent = badge
		refs.menuBadges[entry.id] = badge
		local scale = create("UIScale", { Parent = button })
		button.MouseEnter:Connect(function()
			UI.tween(scale, 0.12, { Scale = 1.08 })
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
	compra = { icon = "✅", color = T.green },
	dinheiro = { icon = "💰", color = T.gold },
	nivel = { icon = "🎉", color = T.neon },
	erro = { icon = "⚠️", color = T.red },
	info = { icon = "💬", color = T.blue },
	missao = { icon = "🏅", color = T.gold },
}
local toastCount = 0

local function buildToasts()
	refs.toasts = UI.scaled(create("Frame", {
		Name = "Avisos",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 114),
		Size = UDim2.fromOffset(400, 300),
		BackgroundTransparency = 1,
		Parent = screen,
	}))
	UI.list(Enum.FillDirection.Vertical, 8, Enum.HorizontalAlignment.Center).Parent = refs.toasts

	local overlay = UI.newScreen("AdegaDestaques", 20, true)
	refs.overlay = overlay
	local banner = create("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.32), Size = UDim2.fromOffset(640, 150), BackgroundTransparency = 1, Visible = false, Parent = overlay })
	refs.bannerScale = create("UIScale", { Parent = banner })
	refs.bannerTitle = label({ Text = "", Font = F.title, TextSize = 68, TextColor3 = rgb(255, 255, 255), TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 84), Parent = banner })
	create("UIStroke", { Color = rgb(80, 20, 120), Thickness = 4, Parent = refs.bannerTitle })
	create("UIGradient", { Color = ColorSequence.new(T.gold, T.orange), Rotation = 90, Parent = refs.bannerTitle })
	refs.bannerSub = label({ Text = "", Font = F.bold, TextSize = 19, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(0, 86), Size = UDim2.new(1, 0, 0, 56), Parent = banner })
	create("UIStroke", { Color = rgb(30, 10, 50), Thickness = 2, Parent = refs.bannerSub })
	refs.banner = banner
end

function Hud.toast(text, kind)
	local style = TOAST_STYLE[kind] or TOAST_STYLE.info
	toastCount += 1
	local holder = create("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(400, 54), LayoutOrder = toastCount, Parent = refs.toasts })
	local box = create("Frame", { Position = UDim2.fromOffset(0, -20), Size = UDim2.fromScale(1, 1), BackgroundColor3 = T.panel, BackgroundTransparency = 1, Parent = holder }, {
		UI.corner(14),
		UI.stroke(style.color, 1.8, 0.15),
	})
	create("Frame", { Position = UDim2.fromOffset(8, 8), Size = UDim2.new(0, 5, 1, -16), BackgroundColor3 = style.color, BorderSizePixel = 0, Parent = box }, { UI.corner(3) })
	label({ Text = style.icon, TextSize = 22, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(16, 0), Size = UDim2.fromOffset(34, 54), Parent = box })
	label({ Text = text, TextSize = 14, TextWrapped = true, Position = UDim2.fromOffset(54, 0), Size = UDim2.new(1, -64, 1, 0), Parent = box })
	UI.tween(box, 0.3, { Position = UDim2.fromOffset(0, 0), BackgroundTransparency = 0.04 }, Enum.EasingStyle.Back)
	while #refs.toasts:GetChildren() > 6 do
		local oldest, oldestOrder = nil, math.huge
		for _, child in refs.toasts:GetChildren() do
			if child:IsA("Frame") and child.LayoutOrder < oldestOrder then
				oldest, oldestOrder = child, child.LayoutOrder
			end
		end
		if oldest == nil then
			break
		end
		oldest:Destroy()
	end
	task.delay(3.6, function()
		if holder.Parent then
			UI.tween(box, 0.25, { Position = UDim2.fromOffset(0, -12), BackgroundTransparency = 1 })
			for _, child in box:GetDescendants() do
				if child:IsA("TextLabel") then
					UI.tween(child, 0.25, { TextTransparency = 1 })
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
	refs.bannerTitle.TextTransparency = 0
	refs.bannerSub.TextTransparency = 0
	banner.Visible = true
	refs.bannerScale.Scale = 0.3 * UI.currentScale()
	UI.tween(refs.bannerScale, 0.5, { Scale = UI.currentScale() }, Enum.EasingStyle.Back)
	local token = {}
	refs.bannerToken = token
	task.delay(3, function()
		if refs.bannerToken ~= token then
			return
		end
		UI.tween(refs.bannerTitle, 0.4, { TextTransparency = 1 })
		UI.tween(refs.bannerSub, 0.4, { TextTransparency = 1 })
		task.wait(0.4)
		if refs.bannerToken == token then
			banner.Visible = false
		end
	end)
end

function Hud.summary(data)
	local win = refs.summary
	if win == nil then
		win = UI.window("Fim de expediente", "Como foi o dia na sua adega", "🌅", UDim2.fromOffset(520, 360))
		local body = win.body
		UI.list(Enum.FillDirection.Vertical, 10, Enum.HorizontalAlignment.Center).Parent = body
		local rows = {}
		for index, spec in { { "👥", "Clientes atendidos" }, { "💰", "Faturamento" }, { "⭐", "Nota média do dia" } } do
			local row = create("Frame", { Size = UDim2.new(1, 0, 0, 52), BackgroundColor3 = T.card, LayoutOrder = index, Parent = body }, { UI.corner(12) })
			label({ Text = spec[1], TextSize = 26, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromOffset(56, 52), Parent = row })
			label({ Text = spec[2], Font = F.body, TextSize = 16, TextColor3 = T.muted, Position = UDim2.fromOffset(56, 0), Size = UDim2.new(1, -200, 1, 0), Parent = row })
			rows[index] = label({ Text = "", Font = F.title, TextSize = 24, TextXAlignment = Enum.TextXAlignment.Right, Position = UDim2.new(1, -150, 0, 0), Size = UDim2.fromOffset(136, 52), Parent = row })
		end
		UI.button({ Style = "gold", Text = "Bora pra mais um dia!", Size = UDim2.fromOffset(260, 46), LayoutOrder = 5, Parent = body }, function()
			win.hide()
		end)
		win.rows = rows
		refs.summary = win
	end
	win.rows[1].Text = tostring(data.served or 0)
	win.rows[2].Text = App.Util.formatMoney(data.earned or 0)
	win.rows[3].Text = if data.rating then App.Util.formatDecimal(data.rating) .. " ★" else "—"
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
	refs.xpText.Text = if state.level >= App.Config.MaxLevel then "NÍVEL MÁXIMO" else App.Util.formatNumber(state.xp) .. " / " .. App.Util.formatNumber(state.xpNext) .. " XP"

	local quest = state.quest
	refs.quest.Visible = quest ~= nil
	if quest then
		refs.questTitle.Text = "MISSÃO " .. quest.index .. "/" .. quest.total
		refs.questText.Text = quest.text
		refs.questFill.Size = UDim2.fromScale(quest.progress / quest.target, 1)
		refs.questProgress.Text = quest.progress .. " / " .. quest.target
		refs.questReward.Text = "+" .. App.Util.formatMoney(quest.reward)
	end
	refs.orders.Position = UDim2.fromOffset(12, if quest then 190 else 96)

	refs.chipPeople.Text = "👥 " .. state.present .. " clientes"
	refs.chipFree.Text = "🍻 " .. state.freeTables .. " mesas livres"
	refs.chipDirty.Text = "🧽 " .. state.dirtyTables .. " sujas"
	refs.chipDirtyFrame.Visible = state.dirtyTables > 0
	refs.chipMoney.Text = "💵 " .. App.Util.formatMoney(state.tableMoney) .. " nas mesas"
	refs.chipMoneyFrame.Visible = state.tableMoney > 0

	refs.stars.Text = UI.stars(state.rating)
	refs.rating.Text = App.Util.formatDecimal(state.rating) .. " estrelas"

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
		Font = F.title,
		TextSize = 22,
		TextColor3 = T.green,
		TextXAlignment = Enum.TextXAlignment.Center,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 1, 0),
		Size = UDim2.fromOffset(200, 26),
		ZIndex = 5,
		Parent = refs.moneyCard,
	})
	local stroke = create("UIStroke", { Color = rgb(0, 60, 20), Thickness = 1.5, Parent = gain })
	UI.tween(gain, 1.1, { Position = UDim2.new(0.5, 0, 1, 34), TextTransparency = 1 })
	UI.tween(stroke, 1.1, { Transparency = 1 })
	task.delay(1.2, function()
		gain:Destroy()
	end)
end

function Hud.init(app)
	App = app
	screen = UI.newScreen("AdegaHUD", 1, false)
	buildProfile()
	buildMoney()
	buildClock()
	buildOrders()
	buildCarry()
	buildMenu()
	buildToasts()

	task.spawn(function()
		while true do
			task.wait(0.5)
			local hour = Lighting.ClockTime
			refs.clock.Text = App.Util.clockText(hour)
			if hour >= 18 or hour < 2 then
				refs.clockIcon.Text = "🌙"
				refs.period.Text = "Horário nobre • 50% mais clientes"
				refs.period.TextColor3 = T.gold
			elseif hour < 6 then
				refs.clockIcon.Text = "💤"
				refs.period.Text = "Madrugada • movimento fraco"
				refs.period.TextColor3 = T.muted
			else
				refs.clockIcon.Text = if hour < 17 then "☀️" else "🌅"
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
