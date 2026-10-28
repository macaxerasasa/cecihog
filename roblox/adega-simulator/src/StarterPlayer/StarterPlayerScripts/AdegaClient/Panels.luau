-- Panels: janelas de Equipe (com retratos e personalização), Cardápio, Avaliações, Expandir e Estilo.

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UI = require(script.Parent.UI)
local Looks = require(ReplicatedStorage:WaitForChild("AdegaShared"):WaitForChild("Looks"))

local Panels = {}

local T = UI.T
local F = UI.F
local create = UI.create
local label = UI.label
local rgb = Color3.fromRGB

local App
local windows: { [string]: any } = {}

local ROLE_COLORS = {
	garcom = T.blue,
	bartender = T.gold,
	faxineiro = T.teal,
	atendente = T.pink,
	seguranca = rgb(70, 70, 82),
	dj = T.purple,
}

local function lighten(color, amount)
	return color:Lerp(rgb(255, 255, 255), amount)
end

local function lookKey(look)
	return table.concat({ look.skin, look.shirt, look.pants, look.shoes, look.hair, look.hairColor }, ":")
end

local function clear(container)
	for _, child in container:GetChildren() do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
end

local function sectionTitle(parent, text, order)
	return label({ Text = text, FontFace = F.heavy, TextSize = 14, TextColor3 = T.muted, Size = UDim2.new(1, 0, 0, 20), LayoutOrder = order or 0, Parent = parent })
end

-- Abas no topo de uma janela.
local function tabs(parent, entries, onSelect)
	local bar = create("Frame", { Size = UDim2.fromOffset(0, 40), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = T.cardDark, Parent = parent }, {
		UI.corner("full"),
		UI.pad(4),
		UI.list(Enum.FillDirection.Horizontal, 4),
	})
	local buttons = {}
	local function choose(id)
		for key, button in buttons do
			local on = key == id
			button.BackgroundTransparency = if on then 0 else 1
			button.TextColor3 = if on then T.text else T.muted
		end
		onSelect(id)
	end
	for index, entry in entries do
		local button = create("TextButton", {
			Text = entry.text,
			FontFace = F.extra,
			TextSize = 15,
			AutoButtonColor = false,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 32),
			BackgroundColor3 = T.panel,
			LayoutOrder = index,
			Parent = bar,
		}, { UI.corner("full"), UI.pad(0, 18, 0, 18) })
		buttons[entry.id] = button
		button.Activated:Connect(function()
			choose(entry.id)
		end)
	end
	return bar, choose, buttons
end

-- Personalização de funcionário ---------------------------------------------------------------------

local function swatchRow(parent, colors, order, onPick)
	local row = create("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = order, Parent = parent })
	create("UIGridLayout", { CellSize = UDim2.fromOffset(38, 38), CellPadding = UDim2.fromOffset(8, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = row })
	local buttons = {}
	for index, color in colors do
		local button = create("TextButton", { Text = "", AutoButtonColor = false, BackgroundColor3 = color, LayoutOrder = index, Parent = row }, {
			UI.corner("full"),
			UI.stroke(rgb(0, 0, 0), 1, 0.85),
		})
		buttons[index] = button
		button.Activated:Connect(function()
			onPick(index)
		end)
	end
	local function mark(selected)
		for index, button in buttons do
			local stroke = button:FindFirstChildOfClass("UIStroke")
			stroke.Color = if index == selected then T.gold else rgb(0, 0, 0)
			stroke.Thickness = if index == selected then 3 else 1
			stroke.Transparency = if index == selected then 0 else 0.85
		end
	end
	return mark
end

local function buildCustomizer()
	local win = UI.window("Visual do funcionário", "Escolha roupa, cabelo e cor de pele", T.blue, UDim2.fromOffset(960, 620))
	local body = win.body

	local stage = UI.panel({ Size = UDim2.new(0, 330, 1, 0), BackgroundColor3 = T.panel, Parent = body })
	create("Frame", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -86), Size = UDim2.fromOffset(220, 30), BackgroundColor3 = T.cardDark, Parent = stage }, { UI.corner("full") })
	local nameBox = create("TextBox", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -18),
		Size = UDim2.new(1, -36, 0, 46),
		BackgroundColor3 = T.card,
		Text = "",
		PlaceholderText = "Nome",
		FontFace = F.extra,
		TextSize = 20,
		TextColor3 = T.text,
		ClearTextOnFocus = false,
		Parent = stage,
	}, { UI.corner(12) })
	win.nameBox = nameBox

	local right = create("Frame", { Position = UDim2.fromOffset(346, 0), Size = UDim2.new(1, -346, 1, 0), BackgroundTransparency = 1, Parent = body })
	local scroll = UI.scroll(right, { Size = UDim2.new(1, 0, 1, -64) })
	UI.list(Enum.FillDirection.Vertical, 10).Parent = scroll
	UI.pad(0, 8, 8, 0).Parent = scroll

	win.marks = {}
	local function refreshPreview()
		if win.model then
			Looks.apply(win.model, win.look)
		end
		win.marks.skin(win.look.skin)
		win.marks.shirt(win.look.shirt)
		win.marks.pants(win.look.pants)
		win.marks.shoes(win.look.shoes)
		win.marks.hairColor(win.look.hairColor)
		for id, button in win.hairButtons do
			local on = id == win.look.hair
			button.BackgroundColor3 = if on then T.gold else T.panel
			button.TextColor3 = if on then rgb(255, 255, 255) else T.text
		end
	end
	local function picker(order, title, field, colors)
		sectionTitle(scroll, title, order)
		win.marks[field] = swatchRow(scroll, colors, order + 1, function(index)
			win.look[field] = index
			refreshPreview()
		end)
	end
	picker(1, "PELE", "skin", Looks.Skins)
	picker(3, "CAMISA E BONÉ", "shirt", Looks.Colors)
	picker(5, "CALÇA", "pants", Looks.Colors)
	picker(7, "SAPATO", "shoes", Looks.Colors)
	sectionTitle(scroll, "CABELO OU CHAPÉU", 9)
	local hairRow = create("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 10, Parent = scroll })
	create("UIGridLayout", { CellSize = UDim2.fromOffset(128, 38), CellPadding = UDim2.fromOffset(8, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = hairRow })
	win.hairButtons = {}
	for index, hair in Looks.Hairs do
		local button = create("TextButton", { Text = hair.name, FontFace = F.extra, TextSize = 14, AutoButtonColor = false, BackgroundColor3 = T.panel, TextColor3 = T.text, LayoutOrder = index, Parent = hairRow }, {
			UI.corner(10),
			UI.stroke(rgb(0, 0, 0), 1, 0.88),
		})
		win.hairButtons[hair.id] = button
		button.Activated:Connect(function()
			win.look.hair = hair.id
			refreshPreview()
		end)
	end
	picker(11, "COR DO CABELO", "hairColor", Looks.HairColors)

	local actions = create("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 52), BackgroundTransparency = 1, Parent = right })
	UI.list(Enum.FillDirection.Horizontal, 10, Enum.HorizontalAlignment.Right).Parent = actions
	UI.button({ Style = "light", Text = "Sortear", Size = UDim2.fromOffset(150, 50), LayoutOrder = 1, Parent = actions }, function()
		local random = Looks.random()
		random.shirt, random.pants = win.look.shirt, win.look.pants
		win.look = random
		refreshPreview()
	end)
	UI.button({ Style = "green", Text = "Salvar visual", Size = UDim2.fromOffset(200, 50), LayoutOrder = 2, Parent = actions }, function()
		local result = App.invoke("visual", { id = win.staffId, look = win.look, name = nameBox.Text })
		if result and result.ok then
			win.hide()
		end
	end)

	function win.edit(member)
		win.staffId = member.id
		win.look = table.clone(Looks.sanitize(member.look))
		nameBox.Text = member.name
		if win.viewport then
			win.viewport:Destroy()
		end
		local viewport, model = UI.avatar(win.look, 300, { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 10), Size = UDim2.new(1, -20, 1, -110) }, true)
		viewport.Parent = stage
		win.viewport, win.model = viewport, model
		refreshPreview()
		win.show()
	end
	win.onShow = function()
		local angle = 0
		win.spin = RunService.RenderStepped:Connect(function(dt)
			angle += dt * 0.8
			if win.model and win.model.PrimaryPart then
				win.model:PivotTo(CFrame.new(win.model:GetPivot().Position) * CFrame.Angles(0, math.pi + math.sin(angle) * 0.6, 0))
			end
		end)
	end
	win.onHide = function()
		if win.spin then
			win.spin:Disconnect()
			win.spin = nil
		end
	end
	return win
end

-- Equipe ------------------------------------------------------------------------------------------

local function staffCard(parent, look, color, order)
	local card = UI.panel({ LayoutOrder = order, Parent = parent })
	local portrait = create("Frame", { Position = UDim2.fromOffset(10, 10), Size = UDim2.new(1, -20, 0, 150), BackgroundColor3 = lighten(color, 0.78), ClipsDescendants = true, Parent = card }, { UI.corner(12) })
	local viewport = UI.avatar(look, 150, { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 4), Size = UDim2.fromOffset(170, 150), Parent = portrait })
	return card, portrait, viewport
end

local function buildStaff()
	local win = UI.window("Equipe", "Contrate gente para tocar a adega com você", T.blue, UDim2.fromOffset(940, 620))
	local body = win.body
	local pages = {}
	local _, selectTab, tabButtons = tabs(body, { { id = "equipe", text = "Sua equipe" }, { id = "contratar", text = "Contratar" } }, function(id)
		for key, page in pages do
			page.Visible = key == id
		end
	end)
	win.tabButtons = tabButtons

	local function grid(name)
		local page = UI.scroll(body, { Name = name, Position = UDim2.fromOffset(0, 54), Size = UDim2.new(1, 0, 1, -54) })
		create("UIGridLayout", { CellSize = UDim2.fromOffset(204, 336), CellPadding = UDim2.fromOffset(12, 12), SortOrder = Enum.SortOrder.LayoutOrder, Parent = page })
		UI.pad(2, 2, 12, 2).Parent = page
		pages[name] = page
		return page
	end
	local teamPage = grid("equipe")
	local hirePage = grid("contratar")
	win.empty = label({ Text = "Ninguém contratado ainda. Comece por um garçom na aba Contratar.", FontFace = F.bold, TextSize = 16, TextColor3 = T.muted, TextWrapped = true, Position = UDim2.fromOffset(0, 70), Size = UDim2.new(1, 0, 0, 40), Visible = false, Parent = body })

	-- contratar
	win.hireButtons = {}
	for index, role in App.Config.Staff do
		local look = Looks.sanitize(role.look)
		look.skin = (index % #Looks.Skins) + 1
		local card = staffCard(hirePage, look, ROLE_COLORS[role.id], index)
		label({ Text = role.name, FontFace = F.heavy, TextSize = 19, Position = UDim2.fromOffset(14, 168), Size = UDim2.new(1, -28, 0, 22), Parent = card })
		label({ Text = role.desc, FontFace = F.medium, TextSize = 13, TextColor3 = T.muted, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Position = UDim2.fromOffset(14, 194), Size = UDim2.new(1, -28, 0, 72), Parent = card })
		local button = UI.button({ Position = UDim2.new(0, 12, 1, -56), Size = UDim2.new(1, -24, 0, 44), TextSize = 15, Parent = card }, function()
			if win.hireStatus and win.hireStatus[role.id] == "ok" then
				App.invoke("contratar", { role = role.id })
			else
				UI.shake(card)
			end
		end)
		win.hireButtons[role.id] = button
	end

	win.cards = {}
	function win.refresh(state)
		win.subtitle.Text = "Funcionários: " .. #state.staff .. " de " .. state.maxStaff .. ". O limite aumenta conforme a adega sobe de nível."
		tabButtons.equipe.Text = "Sua equipe (" .. #state.staff .. ")"
		win.hireStatus = {}
		for _, role in App.Config.Staff do
			local button = win.hireButtons[role.id]
			local status
			if state.level < role.level then
				status = "level"
				button.Text = "Libera no nível " .. role.level
				UI.setButtonStyle(button, "locked")
			elseif #state.staff >= state.maxStaff then
				status = "full"
				button.Text = "Equipe cheia"
				UI.setButtonStyle(button, "locked")
			else
				status = if state.cash >= role.hire then "ok" else "money"
				button.Text = "Contratar  " .. App.Util.formatMoney(role.hire)
				UI.setButtonStyle(button, if status == "ok" then "green" else "light")
			end
			win.hireStatus[role.id] = status
		end

		win.empty.Visible = #state.staff == 0 and pages.equipe.Visible
		local seen = {}
		for index, member in state.staff do
			seen[member.id] = true
			local role = App.Config.staffById(member.role)
			local entry = win.cards[member.id]
			local key = lookKey(member.look)
			if entry and entry.key ~= key then
				entry.card:Destroy()
				entry = nil
			end
			if entry == nil then
				local card = staffCard(teamPage, member.look, ROLE_COLORS[role.id], index)
				local name = label({ Text = "", FontFace = F.heavy, TextSize = 19, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(14, 168), Size = UDim2.new(1, -28, 0, 22), Parent = card })
				UI.chip(card, role.name, ROLE_COLORS[role.id], { Position = UDim2.fromOffset(14, 194) })
				local stars = label({ Text = "", FontFace = F.heavy, TextSize = 16, TextColor3 = T.gold, RichText = true, Position = UDim2.fromOffset(14, 220), Size = UDim2.new(1, -28, 0, 18), Parent = card })
				local custom = UI.button({ Style = "blue", Text = "Personalizar", Position = UDim2.new(0, 12, 1, -94), Size = UDim2.new(1, -24, 0, 38), TextSize = 14, Parent = card })
				local train = UI.button({ Position = UDim2.new(0, 12, 1, -50), Size = UDim2.new(1, -64, 0, 38), TextSize = 14, Parent = card })
				local fire = UI.button({ Style = "light", Text = "", Position = UDim2.new(1, -46, 1, -50), Size = UDim2.fromOffset(34, 38), Parent = card })
				for _, angle in { 45, -45 } do
					create("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(14, 3), Rotation = angle, BackgroundColor3 = T.red, BorderSizePixel = 0, Parent = fire }, { UI.corner("full") })
				end
				entry = { card = card, name = name, stars = stars, train = train, fire = fire, key = key, confirm = false }
				custom.Activated:Connect(function()
					if win.members[member.id] then
						Panels.customizer().edit(win.members[member.id])
					end
				end)
				train.Activated:Connect(function()
					if entry.canTrain then
						App.invoke("treinar", { id = member.id })
					else
						UI.shake(card)
					end
				end)
				fire.Activated:Connect(function()
					if entry.confirm then
						App.invoke("demitir", { id = member.id })
					else
						entry.confirm = true
						App.toast("Clique de novo no X para demitir " .. member.name, "erro")
						task.delay(3, function()
							entry.confirm = false
						end)
					end
				end)
				win.cards[member.id] = entry
			end
			entry.card.LayoutOrder = index
			entry.name.Text = member.name
			entry.stars.Text = UI.stars(member.level) .. '  <font color="#847C92" size="13">' .. App.Util.formatDecimal(App.Config.staffSpeed(member.level)) .. "x mais rápido</font>"
			if member.train then
				entry.train.Text = "Treinar  " .. App.Util.formatMoney(member.train)
				entry.canTrain = state.cash >= member.train
				UI.setButtonStyle(entry.train, if entry.canTrain then "green" else "light")
			else
				entry.train.Text = "Nível máximo"
				entry.canTrain = false
				UI.setButtonStyle(entry.train, "locked")
			end
		end
		win.members = {}
		for _, member in state.staff do
			win.members[member.id] = member
		end
		for id, entry in win.cards do
			if not seen[id] then
				entry.card:Destroy()
				win.cards[id] = nil
			end
		end
	end
	selectTab("equipe")
	return win
end

-- Cardápio ------------------------------------------------------------------------------------------

local function buildMenu()
	local win = UI.window("Cardápio", "Cada estação do modo construção libera produtos novos", T.red)
	local grid = UI.scroll(win.body, { Size = UDim2.fromScale(1, 1) })
	create("UIGridLayout", { CellSize = UDim2.fromOffset(200, 236), CellPadding = UDim2.fromOffset(12, 12), SortOrder = Enum.SortOrder.LayoutOrder, Parent = grid })
	UI.pad(2, 2, 12, 2).Parent = grid
	win.cards = {}
	for index, product in App.Config.Products do
		local card = UI.panel({ LayoutOrder = index, Parent = grid })
		local stage = create("Frame", { Position = UDim2.fromOffset(10, 10), Size = UDim2.new(1, -20, 0, 104), BackgroundColor3 = T.card, Parent = card }, { UI.corner(12) })
		local view = UI.product(product, 96, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Parent = stage })
		label({ Text = product.name, FontFace = F.extra, TextSize = 15, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Position = UDim2.fromOffset(14, 120), Size = UDim2.new(1, -28, 0, 36), Parent = card })
		label({ Text = App.Util.formatMoney(product.price), FontFace = F.heavy, TextSize = 20, TextColor3 = T.goldDark, Position = UDim2.fromOffset(14, 156), Size = UDim2.fromOffset(90, 22), Parent = card })
		label({ Text = "Preparo " .. App.Util.formatDecimal(product.prep) .. "s", FontFace = F.bold, TextSize = 13, TextColor3 = T.muted, TextXAlignment = Enum.TextXAlignment.Right, Position = UDim2.new(1, -110, 0, 158), Size = UDim2.fromOffset(96, 20), Parent = card })
		local status = label({ Text = "", FontFace = F.extra, TextSize = 12, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Center, BackgroundTransparency = 0, Position = UDim2.new(0, 10, 1, -48), Size = UDim2.new(1, -20, 0, 38), Parent = card })
		UI.corner(10).Parent = status
		win.cards[product.id] = { status = status, view = view, station = App.Catalog.ById[product.station], product = product }
	end
	function win.refresh(state)
		local onMenu = {}
		for _, id in state.menu do
			onMenu[id] = true
		end
		for _, entry in win.cards do
			local product = entry.product
			if onMenu[product.id] then
				entry.status.Text = "No cardápio"
				entry.status.BackgroundColor3 = rgb(222, 247, 228)
				entry.status.TextColor3 = T.greenDark
				entry.view.ImageTransparency = 0
			elseif state.level < product.level then
				entry.status.Text = "Libera no nível " .. product.level
				entry.status.BackgroundColor3 = T.card
				entry.status.TextColor3 = T.muted
				entry.view.ImageTransparency = 0.55
			else
				entry.status.Text = "Coloque: " .. entry.station.name
				entry.status.BackgroundColor3 = rgb(255, 240, 214)
				entry.status.TextColor3 = T.goldDark
				entry.view.ImageTransparency = 0.25
			end
		end
	end
	return win
end

-- Avaliações ---------------------------------------------------------------------------------------

local function buildReviews()
	local win = UI.window("Avaliações", "O que os clientes estão achando da sua adega", rgb(255, 179, 0))
	local left = UI.panel({ Size = UDim2.new(0, 300, 1, 0), Parent = win.body })
	UI.pad(18).Parent = left
	UI.list(Enum.FillDirection.Vertical, 8, Enum.HorizontalAlignment.Center).Parent = left
	win.big = label({ Text = "3,0", FontFace = F.heavy, TextSize = 64, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 66), LayoutOrder = 1, Parent = left })
	win.stars = label({ Text = "", FontFace = F.heavy, TextSize = 28, TextColor3 = rgb(255, 179, 0), RichText = true, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 30), LayoutOrder = 2, Parent = left })
	win.count = label({ Text = "", FontFace = F.medium, TextSize = 13, TextColor3 = T.muted, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 18), LayoutOrder = 3, Parent = left })
	win.rows = {}
	for index, name in { "Atendidos hoje", "Faturado hoje", "Total atendidos", "Pontos de ambiente", "Grupos por minuto" } do
		local row = create("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = T.card, LayoutOrder = 10 + index, Parent = left }, { UI.corner(10) })
		label({ Text = name, FontFace = F.bold, TextSize = 14, TextColor3 = T.muted, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -24, 1, 0), Parent = row })
		win.rows[index] = label({ Text = "", FontFace = F.heavy, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Right, Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, -12, 1, 0), Parent = row })
	end
	label({ Text = "Atendimento rápido, decoração bonita e seguranças deixam os clientes mais felizes. Mais estrelas trazem mais gente e gorjeta maior.", FontFace = F.medium, TextSize = 12, TextColor3 = T.muted, TextWrapped = true, Size = UDim2.new(1, 0, 0, 52), LayoutOrder = 30, Parent = left })

	local list = UI.scroll(win.body, { Position = UDim2.fromOffset(316, 0), Size = UDim2.new(1, -316, 1, 0) })
	UI.list(Enum.FillDirection.Vertical, 10).Parent = list
	UI.pad(0, 6, 8, 0).Parent = list
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
			label({ Text = "Ainda sem avaliações. Atenda os primeiros clientes!", FontFace = F.bold, TextSize = 15, TextColor3 = T.muted, Size = UDim2.new(1, 0, 0, 40), Parent = list })
		end
		for index, review in state.reviews do
			local card = UI.panel({ Size = UDim2.new(1, 0, 0, 82), LayoutOrder = index, Parent = list })
			local initial = create("Frame", { Position = UDim2.fromOffset(14, 16), Size = UDim2.fromOffset(40, 40), BackgroundColor3 = lighten(T.blue, 0.75), Parent = card }, { UI.corner("full") })
			label({ Text = string.sub(review.name, 1, 1), FontFace = F.heavy, TextSize = 18, TextColor3 = T.blue, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), Parent = initial })
			label({ Text = review.name, FontFace = F.extra, TextSize = 16, Position = UDim2.fromOffset(66, 12), Size = UDim2.new(1, -200, 0, 20), Parent = card })
			label({ Text = UI.stars(review.stars), FontFace = F.heavy, TextSize = 17, TextColor3 = rgb(255, 179, 0), RichText = true, TextXAlignment = Enum.TextXAlignment.Right, Position = UDim2.new(1, -134, 0, 12), Size = UDim2.fromOffset(120, 20), Parent = card })
			label({ Text = review.text, FontFace = F.medium, TextSize = 14, TextColor3 = T.muted, TextWrapped = true, Position = UDim2.fromOffset(66, 36), Size = UDim2.new(1, -80, 0, 36), Parent = card })
		end
	end
	return win
end

-- Expandir -------------------------------------------------------------------------------------------

local function buildExpand()
	local win = UI.window("Expandir terreno", "Mais espaço para mesas, bar e decoração", T.green, UDim2.fromOffset(780, 560))
	local preview = UI.panel({ Size = UDim2.fromOffset(300, 300), BackgroundColor3 = rgb(214, 232, 206), Parent = win.body })
	win.squares = {}
	local maxSize = App.Config.PlotSizes[#App.Config.PlotSizes].size
	for index = #App.Config.PlotSizes, 1, -1 do
		local tier = App.Config.PlotSizes[index]
		local side = 270 * tier.size / maxSize
		win.squares[index] = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -15),
			Size = UDim2.fromOffset(side, side),
			BackgroundColor3 = T.panel,
			ZIndex = 10 - index,
			Parent = preview,
		}, { UI.corner(8), UI.stroke(rgb(0, 0, 0), 1, 0.85) })
	end
	label({ Text = "A frente fica na calçada; a adega cresce para os lados e para o fundo.", FontFace = F.medium, TextSize = 13, TextColor3 = T.muted, TextWrapped = true, Position = UDim2.fromOffset(0, 312), Size = UDim2.fromOffset(300, 40), Parent = win.body })
	local list = create("Frame", { Position = UDim2.fromOffset(318, 0), Size = UDim2.new(1, -318, 1, 0), BackgroundTransparency = 1, Parent = win.body })
	UI.list(Enum.FillDirection.Vertical, 10).Parent = list
	win.rowsList = {}
	for index, tier in App.Config.PlotSizes do
		local row = UI.panel({ Size = UDim2.new(1, 0, 0, 66), LayoutOrder = index, Parent = list })
		label({ Text = tier.size .. " x " .. tier.size, FontFace = F.heavy, TextSize = 22, Position = UDim2.fromOffset(18, 0), Size = UDim2.fromOffset(120, 66), Parent = row })
		local info = label({ Text = "", FontFace = F.bold, TextSize = 13, TextColor3 = T.muted, Position = UDim2.fromOffset(132, 0), Size = UDim2.new(1, -300, 1, 0), Parent = row })
		local button = UI.button({ AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(156, 44), TextSize = 15, Parent = row }, function()
			if win.canBuy == index then
				App.invoke("expandir", {})
			else
				UI.shake(row)
			end
		end)
		win.rowsList[index] = { info = info, button = button }
	end
	function win.refresh(state)
		win.canBuy = nil
		for index, row in win.rowsList do
			local tier = App.Config.PlotSizes[index]
			win.squares[index].BackgroundColor3 = if index == state.sizeLevel then T.gold elseif index < state.sizeLevel then rgb(255, 214, 150) else T.panel
			win.squares[index].BackgroundTransparency = if index <= state.sizeLevel then 0 else 0.35
			if index <= state.sizeLevel then
				row.info.Text = if index == state.sizeLevel then "Seu tamanho atual" else "Já comprado"
				row.button.Text = "Comprado"
				UI.setButtonStyle(row.button, "ghost")
			elseif index == state.sizeLevel + 1 then
				row.info.Text = "Libera no nível " .. tier.level
				if state.level < tier.level then
					row.button.Text = "Nível " .. tier.level
					UI.setButtonStyle(row.button, "locked")
				else
					row.button.Text = App.Util.formatMoney(tier.price)
					local can = state.cash >= tier.price
					UI.setButtonStyle(row.button, if can then "green" else "light")
					if can then
						win.canBuy = index
					end
				end
			else
				row.info.Text = "Nível " .. tier.level .. " • " .. App.Util.formatMoney(tier.price)
				row.button.Text = "Bloqueado"
				UI.setButtonStyle(row.button, "locked")
			end
		end
	end
	return win
end

-- Estilo ------------------------------------------------------------------------------------------

local function buildStyle()
	local win = UI.window("Estilo", "Piso da adega e cor das paredes rebocadas", T.purple)
	local scroll = UI.scroll(win.body, { Size = UDim2.fromScale(1, 1) })
	UI.list(Enum.FillDirection.Vertical, 10).Parent = scroll
	UI.pad(0, 6, 10, 0).Parent = scroll
	win.entries = {}
	local function section(order, text, kind, list)
		sectionTitle(scroll, text, order)
		local grid = create("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = order + 1, Parent = scroll })
		create("UIGridLayout", { CellSize = UDim2.fromOffset(196, 150), CellPadding = UDim2.fromOffset(10, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = grid })
		for index, option in list do
			local card = UI.panel({ LayoutOrder = index, Parent = grid })
			create("Frame", { Position = UDim2.fromOffset(10, 10), Size = UDim2.new(1, -20, 0, 60), BackgroundColor3 = option.color, Parent = card }, { UI.corner(10), UI.stroke(rgb(0, 0, 0), 1, 0.85) })
			label({ Text = option.name, FontFace = F.extra, TextSize = 15, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(14, 76), Size = UDim2.new(1, -28, 0, 20), Parent = card })
			local button = UI.button({ Position = UDim2.new(0, 10, 1, -46), Size = UDim2.new(1, -20, 0, 36), TextSize = 14, Parent = card }, function()
				App.invoke("estilo", { kind = kind, id = option.id }, true)
			end)
			table.insert(win.entries, { kind = kind, option = option, card = card, button = button })
		end
	end
	section(1, "PISO", "floor", App.Config.Floors)
	section(10, "COR DAS PAREDES", "wall", App.Config.WallColors)
	function win.refresh(state)
		for _, entry in win.entries do
			local owned = if entry.kind == "floor" then state.ownedFloors else state.ownedWalls
			local active = if entry.kind == "floor" then state.style.floor else state.style.wall
			local id = entry.option.id
			local stroke = entry.card:FindFirstChildOfClass("UIStroke")
			if active == id then
				entry.button.Text = "Em uso"
				UI.setButtonStyle(entry.button, "gold")
				stroke.Color = T.gold
				stroke.Thickness = 2
				stroke.Transparency = 0
			else
				stroke.Color = rgb(0, 0, 0)
				stroke.Thickness = 1
				stroke.Transparency = 0.9
				if owned[id] then
					entry.button.Text = "Usar"
					UI.setButtonStyle(entry.button, "blue")
				else
					entry.button.Text = App.Util.formatMoney(entry.option.price)
					UI.setButtonStyle(entry.button, if state.cash >= entry.option.price then "green" else "light")
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

function Panels.customizer()
	if windows.visual == nil then
		windows.visual = buildCustomizer()
		windows.visual.refresh = function() end
	end
	return windows.visual
end

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
