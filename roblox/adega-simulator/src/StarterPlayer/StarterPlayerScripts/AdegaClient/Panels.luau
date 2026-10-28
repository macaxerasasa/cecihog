-- Panels: janelas de Equipe, Cardápio, Avaliações, Expandir e Estilo.

local UI = require(script.Parent.UI)

local Panels = {}

local T = UI.T
local F = UI.Fonts
local create = UI.create
local label = UI.label
local rgb = Color3.fromRGB

local App
local windows = {}

local function title(parent, text, order)
	return label({ Text = text, Font = F.black, TextSize = 13, TextColor3 = T.muted, Size = UDim2.new(1, 0, 0, 18), LayoutOrder = order or 0, Parent = parent })
end

local function card(parent, height, order)
	return create("Frame", { Size = UDim2.new(1, -8, 0, height), BackgroundColor3 = T.card, LayoutOrder = order or 0, Parent = parent }, {
		UI.corner(14),
		UI.stroke(T.line, 1.2, 0.5),
	})
end

local function iconCircle(parent, icon, colors, size, position)
	return create("Frame", { Position = position, Size = UDim2.fromOffset(size, size), BackgroundColor3 = rgb(255, 255, 255), Parent = parent }, {
		UI.corner(14),
		UI.gradient(colors[1], colors[2], 135),
		label({ Text = icon, TextSize = math.floor(size * 0.55), TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1) }),
	})
end

local function clear(container)
	for _, child in container:GetChildren() do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
end

-- Equipe ------------------------------------------------------------------------------------------

local ROLE_COLORS = {
	garcom = { rgb(245, 245, 245), rgb(160, 160, 170) },
	bartender = { rgb(255, 196, 40), rgb(220, 120, 20) },
	faxineiro = { rgb(60, 150, 220), rgb(40, 90, 170) },
	atendente = { rgb(255, 120, 80), rgb(210, 50, 60) },
	seguranca = { rgb(80, 80, 90), rgb(20, 20, 26) },
	dj = { rgb(190, 90, 255), rgb(120, 40, 200) },
}

local function buildStaff()
	local win = UI.window("Equipe", "Contrate gente para tocar a adega com você", "👥")
	local left = create("Frame", { Size = UDim2.new(0.48, -8, 1, 0), BackgroundTransparency = 1, Parent = win.body })
	local right = create("Frame", { Position = UDim2.new(0.48, 8, 0, 0), Size = UDim2.new(0.52, -8, 1, 0), BackgroundTransparency = 1, Parent = win.body })
	title(left, "CONTRATAR").Position = UDim2.new()
	win.teamTitle = title(right, "SUA EQUIPE")
	local hireList = UI.scroll(left, { Position = UDim2.fromOffset(0, 24), Size = UDim2.new(1, 0, 1, -24) })
	UI.list(Enum.FillDirection.Vertical, 8).Parent = hireList
	local teamList = UI.scroll(right, { Position = UDim2.fromOffset(0, 24), Size = UDim2.new(1, 0, 1, -24) })
	UI.list(Enum.FillDirection.Vertical, 8).Parent = teamList
	win.empty = label({ Text = "Ninguém contratado ainda. Comece por um garçom!", Font = F.body, TextSize = 14, TextColor3 = T.muted, TextWrapped = true, Size = UDim2.new(1, -8, 0, 40), Parent = teamList })

	win.hireButtons = {}
	for index, role in App.Config.Staff do
		local frame = card(hireList, 96, index)
		iconCircle(frame, role.icon, ROLE_COLORS[role.id], 56, UDim2.fromOffset(12, 20))
		label({ Text = role.name, TextSize = 17, Position = UDim2.fromOffset(80, 10), Size = UDim2.new(1, -230, 0, 22), Parent = frame })
		label({ Text = role.desc, Font = F.light, TextSize = 12, TextColor3 = T.muted, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Position = UDim2.fromOffset(80, 34), Size = UDim2.new(1, -230, 0, 54), Parent = frame })
		local button = UI.button({ AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(136, 40), TextSize = 13, Parent = frame }, function()
			local status = win.hireStatus and win.hireStatus[role.id]
			if status == "ok" then
				App.invoke("contratar", { role = role.id })
			else
				UI.shake(frame)
			end
		end)
		win.hireButtons[role.id] = button
	end

	win.teamCards = {}
	function win.refresh(state)
		win.subtitle.Text = "Funcionários: " .. #state.staff .. " de " .. state.maxStaff .. " (o limite sobe com o nível)"
		win.teamTitle.Text = "SUA EQUIPE (" .. #state.staff .. "/" .. state.maxStaff .. ")"
		win.hireStatus = {}
		for _, role in App.Config.Staff do
			local button = win.hireButtons[role.id]
			local status
			if state.level < role.level then
				status = "level"
				button.Text = "🔒 Nível " .. role.level
				UI.setButtonStyle(button, "locked")
			elseif #state.staff >= state.maxStaff then
				status = "full"
				button.Text = "Limite atingido"
				UI.setButtonStyle(button, "locked")
			else
				status = if state.cash >= role.hire then "ok" else "money"
				button.Text = "Contratar " .. App.Util.formatMoney(role.hire)
				UI.setButtonStyle(button, if status == "ok" then "green" else "dark")
			end
			win.hireStatus[role.id] = status
		end

		win.empty.Visible = #state.staff == 0
		local seen = {}
		for index, member in state.staff do
			seen[member.id] = true
			local entry = win.teamCards[member.id]
			local role = App.Config.staffById(member.role)
			if entry == nil then
				local frame = card(teamList, 76, index)
				iconCircle(frame, role.icon, ROLE_COLORS[role.id], 48, UDim2.fromOffset(12, 14))
				local name = label({ Text = "", TextSize = 16, Position = UDim2.fromOffset(70, 12), Size = UDim2.new(1, -300, 0, 22), TextTruncate = Enum.TextTruncate.AtEnd, Parent = frame })
				local info = label({ Text = "", Font = F.body, TextSize = 12, TextColor3 = T.gold, RichText = true, Position = UDim2.fromOffset(70, 38), Size = UDim2.new(1, -300, 0, 20), Parent = frame })
				local train = UI.button({ Style = "blue", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -104, 0.5, 0), Size = UDim2.fromOffset(128, 38), TextSize = 12, Parent = frame })
				local fire = UI.button({ Style = "red", Text = "Demitir", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(84, 38), TextSize = 12, Parent = frame })
				entry = { frame = frame, name = name, info = info, train = train, fire = fire, confirm = false }
				train.Activated:Connect(function()
					if entry.canTrain then
						App.invoke("treinar", { id = member.id })
					else
						UI.shake(frame)
					end
				end)
				fire.Activated:Connect(function()
					if entry.confirm then
						App.invoke("demitir", { id = member.id })
					else
						entry.confirm = true
						fire.Text = "Certeza?"
						task.delay(2.5, function()
							entry.confirm = false
							if fire.Parent then
								fire.Text = "Demitir"
							end
						end)
					end
				end)
				win.teamCards[member.id] = entry
			end
			entry.frame.LayoutOrder = index
			entry.name.Text = member.name .. "  •  " .. role.name
			entry.info.Text = UI.stars(member.level) .. '  <font color="#B0A6CC">velocidade ' .. App.Util.formatDecimal(App.Config.staffSpeed(member.level)) .. "x</font>"
			if member.train then
				entry.train.Text = "Treinar " .. App.Util.formatMoney(member.train)
				entry.canTrain = state.cash >= member.train
				UI.setButtonStyle(entry.train, if entry.canTrain then "blue" else "dark")
			else
				entry.train.Text = "Nível máximo"
				entry.canTrain = false
				UI.setButtonStyle(entry.train, "locked")
			end
		end
		for id, entry in win.teamCards do
			if not seen[id] then
				entry.frame:Destroy()
				win.teamCards[id] = nil
			end
		end
	end
	return win
end

-- Cardápio ------------------------------------------------------------------------------------------

local function buildMenu()
	local win = UI.window("Cardápio", "Cada estação do modo construção libera produtos novos", "📋")
	local grid = UI.scroll(win.body, { Size = UDim2.fromScale(1, 1) })
	create("UIGridLayout", { CellSize = UDim2.fromOffset(198, 188), CellPadding = UDim2.fromOffset(12, 12), SortOrder = Enum.SortOrder.LayoutOrder, Parent = grid })
	UI.pad(2, 2, 12, 2).Parent = grid
	win.cards = {}
	for index, product in App.Config.Products do
		local frame = create("Frame", { BackgroundColor3 = T.card, LayoutOrder = index, Parent = grid }, { UI.corner(16), UI.stroke(T.line, 1.2, 0.5) })
		local top = create("Frame", { Position = UDim2.fromOffset(8, 8), Size = UDim2.new(1, -16, 0, 70), BackgroundColor3 = rgb(255, 255, 255), Parent = frame }, {
			UI.corner(12),
			UI.gradient(rgb(255, 120, 70), rgb(190, 30, 70), 135),
		})
		local icon = label({ Text = product.icon, TextSize = 40, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), Parent = top })
		label({ Text = product.name, TextSize = 14, TextWrapped = true, Position = UDim2.fromOffset(12, 82), Size = UDim2.new(1, -24, 0, 34), TextYAlignment = Enum.TextYAlignment.Top, Parent = frame })
		label({ Text = App.Util.formatMoney(product.price) .. "   ⏱ " .. App.Util.formatDecimal(product.prep) .. " s", Font = F.title, TextSize = 15, TextColor3 = T.gold, Position = UDim2.fromOffset(12, 116), Size = UDim2.new(1, -24, 0, 20), Parent = frame })
		local station = App.Catalog.ById[product.station]
		local status = label({ Text = "", Font = F.bold, TextSize = 11, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Center, BackgroundTransparency = 0, BackgroundColor3 = T.locked, Position = UDim2.fromOffset(10, 142), Size = UDim2.new(1, -20, 0, 36), Parent = frame })
		UI.corner(10).Parent = status
		win.cards[product.id] = { frame = frame, top = top, icon = icon, status = status, station = station, product = product }
	end
	function win.refresh(state)
		local onMenu = {}
		for _, id in state.menu do
			onMenu[id] = true
		end
		for _, entry in win.cards do
			local product = entry.product
			if onMenu[product.id] then
				entry.status.Text = "✅ No cardápio"
				entry.status.BackgroundColor3 = T.greenDark
				entry.status.TextColor3 = rgb(255, 255, 255)
				entry.icon.TextTransparency = 0
			elseif state.level < product.level then
				entry.status.Text = "🔒 Libera no nível " .. product.level
				entry.status.BackgroundColor3 = T.locked
				entry.status.TextColor3 = T.muted
				entry.icon.TextTransparency = 0.5
			else
				entry.status.Text = "🔨 Coloque: " .. entry.station.name
				entry.status.BackgroundColor3 = rgb(110, 70, 20)
				entry.status.TextColor3 = T.gold
				entry.icon.TextTransparency = 0.2
			end
		end
	end
	return win
end

-- Avaliações ---------------------------------------------------------------------------------------

local function buildReviews()
	local win = UI.window("Avaliações", "O que os clientes estão achando da sua adega", "⭐")
	local left = UI.panel({ Size = UDim2.new(0, 290, 1, 0), Parent = win.body })
	UI.pad(16).Parent = left
	UI.list(Enum.FillDirection.Vertical, 8, Enum.HorizontalAlignment.Center).Parent = left
	win.big = label({ Text = "3,0", Font = F.title, TextSize = 64, TextColor3 = T.gold, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 70), LayoutOrder = 1, Parent = left })
	win.stars = label({ Text = "", Font = F.black, TextSize = 26, TextColor3 = T.gold, RichText = true, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 30), LayoutOrder = 2, Parent = left })
	win.count = label({ Text = "", Font = F.body, TextSize = 12, TextColor3 = T.muted, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 18), LayoutOrder = 3, Parent = left })
	win.rows = {}
	for index, spec in { { "👥", "Atendidos hoje" }, { "💰", "Faturado hoje" }, { "🏆", "Total atendidos" }, { "✨", "Ambiente" }, { "🚶", "Grupos por minuto" } } do
		local row = create("Frame", { Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = T.card, LayoutOrder = 10 + index, Parent = left }, { UI.corner(9) })
		label({ Text = spec[1], TextSize = 16, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromOffset(32, 32), Parent = row })
		label({ Text = spec[2], Font = F.body, TextSize = 13, TextColor3 = T.muted, Position = UDim2.fromOffset(34, 0), Size = UDim2.new(1, -40, 1, 0), Parent = row })
		win.rows[index] = label({ Text = "", Font = F.title, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(1, -10, 1, 0), Parent = row })
	end
	label({ Text = "Atendimento rápido, ambiente bonito (decoração) e seguranças deixam os clientes mais felizes. Mais estrelas trazem mais gente e mais gorjeta.", Font = F.light, TextSize = 11, TextColor3 = T.muted, TextWrapped = true, Size = UDim2.new(1, 0, 0, 56), LayoutOrder = 30, Parent = left })

	local list = UI.scroll(win.body, { Position = UDim2.fromOffset(306, 0), Size = UDim2.new(1, -306, 1, 0) })
	UI.list(Enum.FillDirection.Vertical, 8).Parent = list
	win.list = list
	function win.refresh(state)
		win.big.Text = App.Util.formatDecimal(state.rating)
		win.stars.Text = UI.stars(state.rating)
		win.count.Text = "Média das últimas " .. state.ratingCount .. " avaliações"
		win.rows[1].Text = tostring(state.day.served)
		win.rows[2].Text = App.Util.formatMoney(state.day.earned)
		win.rows[3].Text = App.Util.formatNumber(state.totalServed)
		win.rows[4].Text = tostring(state.appeal)
		win.rows[5].Text = App.Util.formatDecimal(state.groupsPerMinute)
		local first = state.reviews[1]
		local signature = #state.reviews .. ":" .. (if first then first.name .. first.text .. state.ratingCount else "")
		if signature == win.signature then
			return
		end
		win.signature = signature
		clear(list)
		if #state.reviews == 0 then
			label({ Text = "Ainda sem avaliações. Atenda os primeiros clientes!", Font = F.body, TextSize = 14, TextColor3 = T.muted, Size = UDim2.new(1, -8, 0, 40), Parent = list })
		end
		for index, review in state.reviews do
			local frame = card(list, 74, index)
			label({ Text = review.name, TextSize = 15, Position = UDim2.fromOffset(14, 10), Size = UDim2.new(1, -150, 0, 20), Parent = frame })
			label({ Text = UI.stars(review.stars), Font = F.black, TextSize = 16, TextColor3 = T.gold, RichText = true, TextXAlignment = Enum.TextXAlignment.Right, Position = UDim2.new(1, -134, 0, 10), Size = UDim2.fromOffset(120, 20), Parent = frame })
			label({ Text = "“" .. review.text .. "”", Font = F.body, TextSize = 13, TextColor3 = T.muted, TextWrapped = true, Position = UDim2.fromOffset(14, 34), Size = UDim2.new(1, -28, 0, 32), Parent = frame })
		end
	end
	return win
end

-- Expandir -------------------------------------------------------------------------------------------

local function buildExpand()
	local win = UI.window("Expandir terreno", "Mais espaço para mesas, estações e decoração", "📐", UDim2.fromOffset(760, 520))
	local preview = create("Frame", { Size = UDim2.fromOffset(300, 300), BackgroundColor3 = rgb(70, 110, 60), Parent = win.body }, { UI.corner(16) })
	win.squares = {}
	local maxSize = App.Config.PlotSizes[#App.Config.PlotSizes].size
	for index = #App.Config.PlotSizes, 1, -1 do
		local tier = App.Config.PlotSizes[index]
		local side = 280 * tier.size / maxSize
		local square = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -10),
			Size = UDim2.fromOffset(side, side),
			BackgroundColor3 = rgb(150, 150, 152),
			BackgroundTransparency = 0.7,
			ZIndex = 10 - index,
			Parent = preview,
		}, { UI.stroke(rgb(255, 255, 255), 2, 0.4), UI.corner(6) })
		win.squares[index] = square
	end
	label({ Text = "A frente fica na calçada; a adega cresce para os lados e para o fundo.", Font = F.light, TextSize = 12, TextColor3 = T.muted, TextWrapped = true, Position = UDim2.fromOffset(0, 310), Size = UDim2.fromOffset(300, 40), Parent = win.body })
	local list = create("Frame", { Position = UDim2.fromOffset(320, 0), Size = UDim2.new(1, -320, 1, 0), BackgroundTransparency = 1, Parent = win.body })
	UI.list(Enum.FillDirection.Vertical, 8).Parent = list
	win.rowsList = {}
	for index, tier in App.Config.PlotSizes do
		local frame = card(list, 62, index)
		label({ Text = tier.size .. " x " .. tier.size, Font = F.title, TextSize = 22, Position = UDim2.fromOffset(16, 0), Size = UDim2.fromOffset(120, 62), Parent = frame })
		local info = label({ Text = "", Font = F.body, TextSize = 12, TextColor3 = T.muted, Position = UDim2.fromOffset(130, 0), Size = UDim2.new(1, -290, 1, 0), Parent = frame })
		local button = UI.button({ AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(150, 40), TextSize = 13, Parent = frame }, function()
			if win.canBuy == index then
				App.invoke("expandir", {})
			else
				UI.shake(frame)
			end
		end)
		win.rowsList[index] = { frame = frame, info = info, button = button }
	end
	function win.refresh(state)
		win.canBuy = nil
		for index, row in win.rowsList do
			local tier = App.Config.PlotSizes[index]
			win.squares[index].BackgroundTransparency = if index <= state.sizeLevel then 0.15 else 0.75
			win.squares[index].BackgroundColor3 = if index == state.sizeLevel then T.gold elseif index < state.sizeLevel then rgb(150, 150, 152) else rgb(110, 140, 100)
			if index <= state.sizeLevel then
				row.info.Text = if index == state.sizeLevel then "Seu tamanho atual" else "Já comprado"
				row.button.Text = "✓"
				UI.setButtonStyle(row.button, "dark")
			elseif index == state.sizeLevel + 1 then
				row.info.Text = "Libera no nível " .. tier.level
				if state.level < tier.level then
					row.button.Text = "🔒 Nível " .. tier.level
					UI.setButtonStyle(row.button, "locked")
				else
					row.button.Text = App.Util.formatMoney(tier.price)
					UI.setButtonStyle(row.button, if state.cash >= tier.price then "green" else "dark")
					if state.cash >= tier.price then
						win.canBuy = index
					end
				end
			else
				row.info.Text = "Nível " .. tier.level .. " • " .. App.Util.formatMoney(tier.price)
				row.button.Text = "🔒"
				UI.setButtonStyle(row.button, "locked")
			end
		end
	end
	return win
end

-- Estilo ------------------------------------------------------------------------------------------

local function buildStyle()
	local win = UI.window("Estilo", "Piso da adega e cor das paredes rebocadas", "🎨")
	local scroll = UI.scroll(win.body, { Size = UDim2.fromScale(1, 1) })
	UI.list(Enum.FillDirection.Vertical, 10).Parent = scroll
	win.entries = {}
	local function section(order, text, kind, list)
		title(scroll, text, order)
		local grid = create("Frame", { Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = order + 1, Parent = scroll })
		create("UIGridLayout", { CellSize = UDim2.fromOffset(196, 128), CellPadding = UDim2.fromOffset(10, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = grid })
		for index, option in list do
			local frame = create("Frame", { BackgroundColor3 = T.card, LayoutOrder = index, Parent = grid }, { UI.corner(14), UI.stroke(T.line, 1.5, 0.5) })
			create("Frame", { Position = UDim2.fromOffset(10, 10), Size = UDim2.new(1, -20, 0, 50), BackgroundColor3 = option.color, Parent = frame }, { UI.corner(10), UI.stroke(rgb(0, 0, 0), 1, 0.7) })
			label({ Text = option.name, TextSize = 14, Position = UDim2.fromOffset(12, 64), Size = UDim2.new(1, -24, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd, Parent = frame })
			local button = UI.button({ Position = UDim2.fromOffset(10, 86), Size = UDim2.new(1, -20, 0, 32), TextSize = 12, Parent = frame }, function()
				App.invoke("estilo", { kind = kind, id = option.id })
			end)
			table.insert(win.entries, { kind = kind, option = option, frame = frame, button = button })
		end
	end
	section(1, "PISO", "floor", App.Config.Floors)
	section(10, "PAREDES", "wall", App.Config.WallColors)
	function win.refresh(state)
		for _, entry in win.entries do
			local owned = if entry.kind == "floor" then state.ownedFloors else state.ownedWalls
			local active = if entry.kind == "floor" then state.style.floor else state.style.wall
			local id = entry.option.id
			if active == id then
				entry.button.Text = "✓ Em uso"
				UI.setButtonStyle(entry.button, "gold")
				entry.frame.UIStroke.Color = T.gold
				entry.frame.UIStroke.Transparency = 0
			else
				entry.frame.UIStroke.Color = T.line
				entry.frame.UIStroke.Transparency = 0.5
				if owned[id] then
					entry.button.Text = "Usar"
					UI.setButtonStyle(entry.button, "blue")
				else
					entry.button.Text = App.Util.formatMoney(entry.option.price)
					UI.setButtonStyle(entry.button, if state.cash >= entry.option.price then "green" else "dark")
				end
			end
		end
	end
	return win
end

local BUILDERS = {
	equipe = buildStaff,
	cardapio = buildMenu,
	avaliacoes = buildReviews,
	expandir = buildExpand,
	estilo = buildStyle,
}

function Panels.open(name)
	local win = windows[name]
	if win == nil then
		local builder = BUILDERS[name]
		if builder == nil then
			return
		end
		win = builder()
		windows[name] = win
	end
	if win.open then
		win.hide()
		return
	end
	if App.state then
		win.refresh(App.state)
	end
	win.show()
end

function Panels.update(state)
	for _, win in windows do
		if win.open then
			win.refresh(state)
		end
	end
end

function Panels.init(app)
	App = app
end

return Panels
