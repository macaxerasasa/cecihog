-- Build: modo construção. Catálogo com miniaturas 3D, prévia na grade, colocar, mover, girar e vender.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local UI = require(script.Parent.UI)

local Build = {}

local T = UI.T
local F = UI.Fonts
local create = UI.create
local label = UI.label
local rgb = Color3.fromRGB

local App
local Catalog
local player = Players.LocalPlayer

local active = false
local currentCategory = "mesas"
local refs: { [string]: any } = {}
local cards = {}
local ghost = nil
local selected = nil
local occupancy = nil
local gridFolder = nil
local gridSize = nil
local connections = {}
local savedZoom = nil

-- Terreno do jogador --------------------------------------------------------------------------------

local function plotModel()
	if App.state == nil then
		return nil
	end
	return workspace:FindFirstChild("Adega" .. App.state.plotIndex)
end

local function origin()
	return CFrame.new(App.state.origin)
end

local function furnitureFolder()
	local plot = plotModel()
	return plot and plot:FindFirstChild("Moveis")
end

local function rebuildOccupancy()
	occupancy = {}
	local folder = furnitureFolder()
	if folder == nil then
		return
	end
	for _, model in folder:GetChildren() do
		local item = Catalog.ById[model:GetAttribute("ItemId") or ""]
		local x, z, r, uid = model:GetAttribute("X"), model:GetAttribute("Z"), model:GetAttribute("R"), model:GetAttribute("Uid")
		if item and x and z and r then
			for _, key in Catalog.cells(item, x, z, r) do
				occupancy[key] = uid
			end
		end
	end
end

local function validity(item, x, z, rotation, ignoreUid)
	if App.state.level < item.level then
		return false, "Libera no nível " .. item.level
	end
	if not Catalog.inBounds(item, x, z, rotation, App.state.size) then
		return false, "Fora da área da adega"
	end
	if occupancy == nil then
		rebuildOccupancy()
	end
	for _, key in Catalog.cells(item, x, z, rotation) do
		local uid = occupancy[key]
		if uid and uid ~= ignoreUid then
			return false, "Já tem algo nesse lugar"
		end
	end
	if ignoreUid == nil and App.state.cash < item.price then
		return false, "Falta dinheiro"
	end
	return true, nil
end

-- Grade e paredes transparentes ----------------------------------------------------------------------

local function clearGrid()
	if gridFolder then
		gridFolder:Destroy()
		gridFolder = nil
	end
	gridSize = nil
end

local function drawGrid()
	clearGrid()
	local size = App.state.size
	gridSize = size
	gridFolder = Instance.new("Folder")
	gridFolder.Name = "GradeAdega"
	local base = origin()
	local function line(cframe, lineSize)
		create("Part", {
			Anchored = true,
			CanCollide = false,
			CanQuery = false,
			CanTouch = false,
			CastShadow = false,
			Material = Enum.Material.Neon,
			Color = rgb(255, 255, 255),
			Transparency = 0.82,
			Size = lineSize,
			CFrame = cframe,
			Parent = gridFolder,
		})
	end
	for x = -size / 2, size / 2, 2 do
		line(base * CFrame.new(x, 0.03, size / 2), Vector3.new(0.06, 0.02, size))
	end
	for z = 0, size, 2 do
		line(base * CFrame.new(0, 0.03, z), Vector3.new(size, 0.02, 0.06))
	end
	gridFolder.Parent = workspace.CurrentCamera
end

local function setWallsSeeThrough(on)
	local folder = furnitureFolder()
	if folder == nil then
		return
	end
	for _, model in folder:GetChildren() do
		local item = Catalog.ById[model:GetAttribute("ItemId") or ""]
		if item and Catalog.isWall(item) then
			for _, part in model:GetDescendants() do
				if part:IsA("BasePart") then
					part.LocalTransparencyModifier = if on then 0.7 else 0
				end
			end
		end
	end
end

-- Prévia --------------------------------------------------------------------------------------------

local function mouseHit(includeList)
	local camera = workspace.CurrentCamera
	local mouse = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mouse.X, mouse.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = includeList
	return workspace:Raycast(ray.Origin, ray.Direction * 600, params)
end

local function endGhost()
	if ghost then
		ghost.model:Destroy()
		if ghost.hidden then
			for _, part in ghost.hidden:GetDescendants() do
				if part:IsA("BasePart") then
					part.LocalTransparencyModifier = 0
				end
			end
			setWallsSeeThrough(active)
		end
		ghost = nil
	end
	if refs.touchBar then
		refs.touchBar.Visible = false
	end
	refs.ghostInfo.Visible = false
end

local function startGhost(item, rotation, moveUid, hiddenModel)
	endGhost()
	local model = Catalog.buildModel(item, CFrame.new(0, -500, 0), { ghost = true, noLights = true })
	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = 0.55
	highlight.OutlineColor = rgb(255, 255, 255)
	highlight.OutlineTransparency = 0.2
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = model
	model.Parent = workspace.CurrentCamera
	ghost = { item = item, model = model, highlight = highlight, rotation = rotation or 0, moveUid = moveUid, hidden = hiddenModel }
	if hiddenModel then
		for _, part in hiddenModel:GetDescendants() do
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = 0.85
			end
		end
	end
	refs.touchBar.Visible = UserInputService.TouchEnabled
	refs.ghostInfo.Visible = true
	refs.ghostName.Text = (if moveUid then "Movendo: " else "") .. item.name
	refs.ghostPrice.Text = if moveUid then "Grátis" else App.Util.formatMoney(item.price)
end

local function updateGhost()
	if ghost == nil or App.state == nil then
		return
	end
	local plot = plotModel()
	if plot == nil then
		return
	end
	local hit = mouseHit({ plot.Terreno })
	if hit == nil then
		return
	end
	local localPos = origin():PointToObjectSpace(hit.Position)
	local w, d = Catalog.footprint(ghost.item, ghost.rotation)
	local x = Catalog.snap(localPos.X, w)
	local z = Catalog.snap(localPos.Z, d)
	ghost.x, ghost.z = x, z
	ghost.model:PivotTo(origin() * Catalog.localCFrame(x, z, ghost.rotation) * CFrame.new(0, 0.1, 0))
	local ok, reason = validity(ghost.item, x, z, ghost.rotation, ghost.moveUid)
	ghost.valid = ok
	ghost.reason = reason
	ghost.highlight.FillColor = if ok then rgb(60, 230, 120) else rgb(240, 60, 70)
	refs.ghostReason.Text = if ok then "Clique para colocar" else reason
	refs.ghostReason.TextColor3 = if ok then T.green else T.red
end

local function rotateGhost()
	if ghost then
		ghost.rotation = (ghost.rotation + 1) % 4
		updateGhost()
	end
end

local function placeGhost()
	if ghost == nil or ghost.x == nil then
		return
	end
	if not ghost.valid then
		App.toast(ghost.reason or "Não dá para colocar aqui", "erro")
		return
	end
	local payload = { id = ghost.item.id, x = ghost.x, z = ghost.z, r = ghost.rotation, uid = ghost.moveUid }
	local action = if ghost.moveUid then "mover" else "colocar"
	local wasMove = ghost.moveUid ~= nil
	local result = App.invoke(action, payload, true)
	if result and result.ok then
		occupancy = nil
		if wasMove then
			endGhost()
		end
	end
end

-- Seleção de móveis já colocados ----------------------------------------------------------------------

local function deselect()
	if selected then
		if selected.highlight then
			selected.highlight:Destroy()
		end
		selected = nil
	end
	refs.selection.Visible = false
end

local function selectModel(model)
	deselect()
	local item = Catalog.ById[model:GetAttribute("ItemId") or ""]
	if item == nil then
		return
	end
	local highlight = Instance.new("Highlight")
	highlight.FillColor = rgb(70, 150, 255)
	highlight.FillTransparency = 0.7
	highlight.OutlineColor = rgb(120, 200, 255)
	highlight.Parent = model
	selected = { model = model, item = item, uid = model:GetAttribute("Uid"), highlight = highlight, confirmSell = false }
	refs.selName.Text = item.name
	refs.sellButton.Text = "💲 Vender " .. App.Util.formatMoney(math.floor(item.price * App.Config.SellRefund))
	refs.selection.Visible = true
end

local function trySelect()
	local folder = furnitureFolder()
	if folder == nil then
		return
	end
	local hit = mouseHit({ folder })
	if hit == nil then
		deselect()
		return
	end
	local instance = hit.Instance
	while instance and instance.Parent ~= folder do
		instance = instance.Parent
	end
	if instance and instance:IsA("Model") then
		selectModel(instance)
	else
		deselect()
	end
end

-- Catálogo ------------------------------------------------------------------------------------------

local function thumbnail(item, parent)
	local viewport = create("ViewportFrame", {
		Position = UDim2.fromOffset(6, 6),
		Size = UDim2.new(1, -12, 0, 84),
		BackgroundColor3 = rgb(36, 30, 56),
		Ambient = rgb(170, 165, 185),
		LightColor = rgb(255, 250, 240),
		LightDirection = Vector3.new(-0.6, -1, -0.4),
		Parent = parent,
	}, { UI.corner(10) })
	local model = Catalog.buildModel(item, CFrame.new(), { noLights = true })
	model.Parent = viewport
	local camera = Instance.new("Camera")
	camera.FieldOfView = 32
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	local cframe, size = model:GetBoundingBox()
	local radius = size.Magnitude / 2
	local distance = radius / math.tan(math.rad(camera.FieldOfView / 2)) * 0.95
	local direction = Vector3.new(0.7, 0.75, -1).Unit
	camera.CFrame = CFrame.lookAt(cframe.Position + direction * distance, cframe.Position)
	return viewport
end

local function refreshCards()
	if App.state == nil then
		return
	end
	for _, entry in cards do
		local item = entry.item
		local locked = App.state.level < item.level
		entry.lock.Visible = locked
		entry.price.TextColor3 = if App.state.cash >= item.price then T.gold else T.red
		entry.frame.UIStroke.Color = if ghost and ghost.item == item and not ghost.moveUid then T.gold else T.line
	end
end

local function showCategory(categoryId)
	currentCategory = categoryId
	for id, tab in refs.tabs do
		local on = id == categoryId
		tab.BackgroundTransparency = if on then 0 else 1
		tab.TextColor3 = if on then rgb(60, 25, 0) else T.muted
	end
	for _, entry in cards do
		entry.frame:Destroy()
	end
	table.clear(cards)
	for _, item in Catalog.Items do
		if item.category ~= categoryId then
			continue
		end
		local frame = create("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.fromOffset(132, 160), BackgroundColor3 = T.card, LayoutOrder = item.order, Parent = refs.items }, {
			UI.corner(14),
			UI.stroke(T.line, 1.5, 0.3),
		})
		thumbnail(item, frame)
		label({ Text = item.name, TextSize = 11, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Position = UDim2.fromOffset(8, 94), Size = UDim2.new(1, -16, 0, 28), Parent = frame })
		local extras = {}
		if item.seats then
			table.insert(extras, "🪑" .. #item.seats)
		end
		if (item.appeal or 0) > 0 then
			table.insert(extras, "✨+" .. item.appeal)
		end
		local price = label({ Text = App.Util.formatMoney(item.price), Font = F.title, TextSize = 14, TextColor3 = T.gold, Position = UDim2.fromOffset(8, 124), Size = UDim2.new(1, -16, 0, 16), Parent = frame })
		label({ Text = table.concat(extras, "  "), Font = F.bold, TextSize = 11, TextColor3 = T.muted, Position = UDim2.fromOffset(8, 140), Size = UDim2.new(1, -16, 0, 14), Parent = frame })
		local lock = create("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = rgb(10, 6, 18), BackgroundTransparency = 0.35, Visible = false, ZIndex = 5, Parent = frame }, { UI.corner(14) })
		label({ Text = "🔒\nNível " .. item.level, Font = F.black, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), ZIndex = 6, Parent = lock })
		local entry = { item = item, frame = frame, price = price, lock = lock }
		frame.Activated:Connect(function()
			if App.state.level < item.level then
				UI.shake(frame)
				App.toast(item.name .. " libera no nível " .. item.level, "erro")
				return
			end
			deselect()
			startGhost(item, 0, nil, nil)
			refreshCards()
		end)
		if item.desc then
			frame.MouseEnter:Connect(function()
				refs.tooltip.Text = item.desc
				refs.tooltip.Visible = true
			end)
			frame.MouseLeave:Connect(function()
				refs.tooltip.Visible = false
			end)
		end
		table.insert(cards, entry)
	end
	refs.items.CanvasPosition = Vector2.zero
	refreshCards()
end

local function buildUI()
	local screen = UI.newScreen("AdegaConstrucao", 5, false)
	refs.screen = screen
	screen.Enabled = false

	local drawer = UI.scaled(UI.panel({ Name = "Catalogo", AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -10), Size = UDim2.fromOffset(1060, 232), Parent = screen }))
	drawer.UIStroke.Color = T.gold
	label({ Text = "🔨 CONSTRUÇÃO", Font = F.title, TextSize = 20, TextColor3 = T.gold, Position = UDim2.fromOffset(16, 10), Size = UDim2.fromOffset(190, 30), Parent = drawer })
	local tabs = create("Frame", { Position = UDim2.fromOffset(200, 8), Size = UDim2.new(1, -330, 0, 34), BackgroundTransparency = 1, Parent = drawer })
	UI.list(Enum.FillDirection.Horizontal, 6).Parent = tabs
	refs.tabs = {}
	for index, category in Catalog.Categories do
		local tab = create("TextButton", {
			Text = category.icon .. " " .. category.name,
			Font = F.bold,
			TextSize = 14,
			TextColor3 = T.muted,
			AutoButtonColor = false,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 34),
			BackgroundColor3 = T.gold,
			BackgroundTransparency = 1,
			LayoutOrder = index,
			Parent = tabs,
		}, { UI.corner("full"), UI.pad(0, 14, 0, 14) })
		tab.Activated:Connect(function()
			showCategory(category.id)
		end)
		refs.tabs[category.id] = tab
	end
	UI.button({ Style = "red", Text = "✕ Sair", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 8), Size = UDim2.fromOffset(100, 34), Parent = drawer }, function()
		Build.setActive(false)
	end)
	refs.items = create("ScrollingFrame", {
		Position = UDim2.fromOffset(12, 50),
		Size = UDim2.new(1, -24, 0, 172),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = T.gold,
		ScrollingDirection = Enum.ScrollingDirection.X,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		Parent = drawer,
	})
	UI.list(Enum.FillDirection.Horizontal, 10).Parent = refs.items
	UI.pad(4, 4, 8, 4).Parent = refs.items

	refs.tooltip = label({
		Text = "",
		Font = F.body,
		TextSize = 13,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Center,
		BackgroundColor3 = T.bg,
		BackgroundTransparency = 0.05,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 0, -8),
		Size = UDim2.fromOffset(520, 40),
		Visible = false,
		Parent = drawer,
	})
	UI.corner(12).Parent = refs.tooltip

	-- informação da prévia e ajuda
	local info = UI.scaled(UI.panel({ Name = "Previa", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 116), Size = UDim2.fromOffset(460, 86), Visible = false, Parent = screen }))
	refs.ghostInfo = info
	refs.ghostName = label({ Text = "", TextSize = 17, Position = UDim2.fromOffset(16, 8), Size = UDim2.new(1, -150, 0, 22), TextTruncate = Enum.TextTruncate.AtEnd, Parent = info })
	refs.ghostPrice = label({ Text = "", Font = F.title, TextSize = 18, TextColor3 = T.gold, TextXAlignment = Enum.TextXAlignment.Right, Position = UDim2.new(1, -140, 0, 8), Size = UDim2.fromOffset(124, 22), Parent = info })
	refs.ghostReason = label({ Text = "", Font = F.bold, TextSize = 13, Position = UDim2.fromOffset(16, 32), Size = UDim2.new(1, -32, 0, 18), Parent = info })
	label({
		Text = if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then "Toque no chão para mover a prévia" else "R girar  •  Q ou botão direito cancela  •  clique coloca",
		Font = F.body,
		TextSize = 12,
		TextColor3 = T.muted,
		Position = UDim2.fromOffset(16, 56),
		Size = UDim2.new(1, -32, 0, 18),
		Parent = info,
	})

	local touchBar = create("Frame", { Position = UDim2.new(0, 0, 1, 10), Size = UDim2.new(1, 0, 0, 46), BackgroundTransparency = 1, Visible = false, Parent = info })
	UI.list(Enum.FillDirection.Horizontal, 10, Enum.HorizontalAlignment.Center).Parent = touchBar
	UI.button({ Style = "blue", Text = "⟳ Girar", Size = UDim2.fromOffset(130, 44), LayoutOrder = 1, Parent = touchBar }, rotateGhost)
	UI.button({ Style = "green", Text = "✓ Colocar", Size = UDim2.fromOffset(140, 44), LayoutOrder = 2, Parent = touchBar }, placeGhost)
	UI.button({ Style = "red", Text = "✕", Size = UDim2.fromOffset(60, 44), LayoutOrder = 3, Parent = touchBar }, endGhost)
	refs.touchBar = touchBar

	-- painel do móvel selecionado
	local selection = UI.scaled(UI.panel({ Name = "Selecionado", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 116), Size = UDim2.fromOffset(560, 104), Visible = false, Parent = screen }))
	selection.UIStroke.Color = T.blue
	refs.selection = selection
	refs.selName = label({ Text = "", TextSize = 17, Position = UDim2.fromOffset(16, 8), Size = UDim2.new(1, -32, 0, 24), TextTruncate = Enum.TextTruncate.AtEnd, Parent = selection })
	local row = create("Frame", { Position = UDim2.fromOffset(12, 42), Size = UDim2.new(1, -24, 0, 48), BackgroundTransparency = 1, Parent = selection })
	UI.list(Enum.FillDirection.Horizontal, 10, Enum.HorizontalAlignment.Center).Parent = row
	UI.button({ Style = "blue", Text = "✋ Mover", Size = UDim2.fromOffset(120, 44), LayoutOrder = 1, Parent = row }, function()
		if selected then
			local model, item = selected.model, selected.item
			local uid, rotation = selected.uid, model:GetAttribute("R") or 0
			deselect()
			startGhost(item, rotation, uid, model)
		end
	end)
	UI.button({ Style = "neon", Text = "⟳ Girar", Size = UDim2.fromOffset(110, 44), LayoutOrder = 2, Parent = row }, function()
		if selected then
			local model = selected.model
			local result = App.invoke("mover", { uid = selected.uid, x = model:GetAttribute("X"), z = model:GetAttribute("Z"), r = (model:GetAttribute("R") or 0) + 1 }, true)
			if result and result.ok then
				deselect()
				occupancy = nil
			end
		end
	end)
	refs.sellButton = UI.button({ Style = "red", Text = "💲 Vender", Size = UDim2.fromOffset(170, 44), LayoutOrder = 3, Parent = row }, function()
		if selected == nil then
			return
		end
		if not selected.confirmSell then
			selected.confirmSell = true
			refs.sellButton.Text = "Confirmar venda?"
			return
		end
		local result = App.invoke("vender", { uid = selected.uid })
		if result and result.ok then
			deselect()
			occupancy = nil
		end
	end)
	UI.button({ Style = "dark", Text = "✕", Size = UDim2.fromOffset(60, 44), LayoutOrder = 4, Parent = row }, deselect)
end

-- Ligar e desligar ----------------------------------------------------------------------------------

function Build.setActive(on)
	if on == active then
		return
	end
	if on and App.state == nil then
		return
	end
	active = on
	refs.screen.Enabled = on
	App.onBuildMode(on)
	for _, connection in connections do
		connection:Disconnect()
	end
	table.clear(connections)
	if on then
		UI.closeWindows()
		drawGrid()
		setWallsSeeThrough(true)
		occupancy = nil
		showCategory(currentCategory)
		savedZoom = player.CameraMaxZoomDistance
		player.CameraMaxZoomDistance = math.max(savedZoom, 140)
		local folder = furnitureFolder()
		if folder then
			table.insert(connections, folder.ChildAdded:Connect(function()
				occupancy = nil
				task.defer(function()
					if active then
						setWallsSeeThrough(true)
					end
				end)
			end))
			table.insert(connections, folder.ChildRemoved:Connect(function()
				occupancy = nil
			end))
		end
		table.insert(connections, RunService.RenderStepped:Connect(updateGhost))
	else
		endGhost()
		deselect()
		clearGrid()
		setWallsSeeThrough(false)
		if savedZoom then
			player.CameraMaxZoomDistance = savedZoom
		end
	end
end

function Build.toggle()
	Build.setActive(not active)
end

function Build.isActive()
	return active
end

function Build.update(state)
	if not active then
		return
	end
	if gridSize ~= state.size then
		drawGrid()
	end
	refreshCards()
end

function Build.init(app)
	App = app
	Catalog = app.Catalog
	buildUI()
	UserInputService.InputBegan:Connect(function(input, processed)
		if not active then
			return
		end
		if input.KeyCode == Enum.KeyCode.R and not processed then
			rotateGhost()
		elseif (input.KeyCode == Enum.KeyCode.Q and not processed) or input.UserInputType == Enum.UserInputType.MouseButton2 then
			if ghost then
				endGhost()
				refreshCards()
			else
				deselect()
			end
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 and not processed then
			if ghost then
				placeGhost()
			else
				trySelect()
			end
		elseif input.UserInputType == Enum.UserInputType.Touch and not processed and ghost == nil then
			task.defer(trySelect)
		end
	end)
end

return Build
