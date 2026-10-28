-- UI: tema e componentes da interface (cartões claros, botões, janelas, barras, ícones 3D).

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("AdegaShared")
local Models = require(Shared:WaitForChild("Models"))
local Looks = require(Shared:WaitForChild("Looks"))

local UI = {}

local rgb = Color3.fromRGB

UI.T = {
	panel = rgb(255, 255, 255),
	card = rgb(245, 243, 248),
	cardDark = rgb(232, 228, 238),
	bg = rgb(238, 235, 242),
	line = rgb(226, 221, 232),
	text = rgb(36, 31, 46),
	muted = rgb(132, 124, 146),
	gold = rgb(255, 149, 0),
	goldDark = rgb(222, 104, 0),
	green = rgb(52, 199, 89),
	greenDark = rgb(30, 150, 65),
	red = rgb(255, 69, 58),
	blue = rgb(0, 122, 255),
	purple = rgb(175, 82, 222),
	teal = rgb(48, 176, 199),
	pink = rgb(255, 55, 135),
	locked = rgb(214, 210, 220),
	dim = rgb(12, 8, 20),
}
local T = UI.T

local FAMILY = "rbxasset://fonts/families/BuilderSans.json"
UI.F = {
	regular = Font.new(FAMILY, Enum.FontWeight.Regular),
	medium = Font.new(FAMILY, Enum.FontWeight.Medium),
	bold = Font.new(FAMILY, Enum.FontWeight.Bold),
	extra = Font.new(FAMILY, Enum.FontWeight.ExtraBold),
	heavy = Font.new(FAMILY, Enum.FontWeight.Heavy),
}
local F = UI.F

function UI.create(className, props, children)
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
local create = UI.create

function UI.corner(radius)
	return create("UICorner", { CornerRadius = if radius == "full" then UDim.new(1, 0) else UDim.new(0, radius or 12) })
end

function UI.stroke(color, thickness, transparency)
	return create("UIStroke", {
		Color = color or T.line,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

function UI.pad(top, right, bottom, left)
	right = right or top
	bottom = bottom or top
	left = left or right
	return create("UIPadding", {
		PaddingTop = UDim.new(0, top),
		PaddingRight = UDim.new(0, right),
		PaddingBottom = UDim.new(0, bottom),
		PaddingLeft = UDim.new(0, left),
	})
end

function UI.list(direction, padding, align, valign)
	return create("UIListLayout", {
		FillDirection = direction or Enum.FillDirection.Vertical,
		Padding = UDim.new(0, padding or 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = align or Enum.HorizontalAlignment.Left,
		VerticalAlignment = valign or Enum.VerticalAlignment.Top,
	})
end

function UI.label(props)
	local defaults = {
		BackgroundTransparency = 1,
		FontFace = F.bold,
		TextColor3 = T.text,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
	}
	for key, value in props do
		defaults[key] = value
	end
	return create("TextLabel", defaults)
end

function UI.tween(instance, time, props, style, direction)
	local tween = TweenService:Create(instance, TweenInfo.new(time, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out), props)
	tween:Play()
	return tween
end

-- Cartão branco com borda suave.
function UI.panel(props)
	local frame = create("Frame", {
		BackgroundColor3 = T.panel,
		BorderSizePixel = 0,
	})
	for key, value in props do
		frame[key] = value
	end
	UI.corner(16).Parent = frame
	UI.stroke(rgb(0, 0, 0), 1, 0.9).Parent = frame
	return frame
end

-- Botões --------------------------------------------------------------------------------------------
-- A cor vem do BackgroundColor3; o degradê é só claro/escuro (branco -> cinza), então o texto não some.

local BUTTON_STYLES = {
	green = { T.green, rgb(255, 255, 255) },
	gold = { T.gold, rgb(255, 255, 255) },
	red = { T.red, rgb(255, 255, 255) },
	blue = { T.blue, rgb(255, 255, 255) },
	purple = { T.purple, rgb(255, 255, 255) },
	light = { T.card, T.text },
	ghost = { T.card, T.muted },
	locked = { T.locked, rgb(120, 114, 132) },
}

function UI.button(props, onClick)
	local style = props.Style or "green"
	props.Style = nil
	local colors = BUTTON_STYLES[style]
	local button = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = colors[1],
		FontFace = F.extra,
		TextSize = 16,
		TextColor3 = colors[2],
		Text = "",
		BorderSizePixel = 0,
	})
	for key, value in props do
		button[key] = value
	end
	UI.corner(12).Parent = button
	create("UIGradient", { Name = "Sombra", Color = ColorSequence.new(rgb(255, 255, 255), rgb(225, 225, 225)), Rotation = 90, Parent = button })
	local scale = create("UIScale", { Parent = button })
	button.MouseEnter:Connect(function()
		UI.tween(scale, 0.12, { Scale = 1.04 })
	end)
	button.MouseLeave:Connect(function()
		UI.tween(scale, 0.12, { Scale = 1 })
	end)
	button.MouseButton1Down:Connect(function()
		UI.tween(scale, 0.08, { Scale = 0.94 })
	end)
	button.MouseButton1Up:Connect(function()
		UI.tween(scale, 0.18, { Scale = 1 }, Enum.EasingStyle.Back)
	end)
	if onClick then
		button.Activated:Connect(onClick)
	end
	return button
end

function UI.setButtonStyle(button, style)
	local colors = BUTTON_STYLES[style]
	button.BackgroundColor3 = colors[1]
	button.TextColor3 = colors[2]
end

function UI.shake(frame)
	task.spawn(function()
		local origin = frame.Position
		for _, dx in { -8, 8, -5, 5, -2, 0 } do
			frame.Position = origin + UDim2.fromOffset(dx, 0)
			task.wait(0.035)
		end
		frame.Position = origin
	end)
end

-- Barra de progresso. Devolve (trilho, preenchimento).
function UI.bar(parent, props, color)
	local track = create("Frame", { BackgroundColor3 = T.cardDark, BorderSizePixel = 0, Parent = parent }, { UI.corner("full") })
	for key, value in props do
		track[key] = value
	end
	local fill = create("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = color or T.gold, BorderSizePixel = 0, Parent = track }, { UI.corner("full") })
	return track, fill
end

function UI.stars(rating)
	local full = math.floor(rating)
	local half = rating - full >= 0.5
	local text = string.rep("★", full)
	local shown = full
	if half and full < 5 then
		text ..= '<font transparency="0.45">★</font>'
		shown += 1
	end
	if shown < 5 then
		text ..= '<font transparency="0.82">' .. string.rep("★", 5 - shown) .. "</font>"
	end
	return text
end

-- Pílula pequena com texto (etiquetas).
function UI.chip(parent, text, color, props)
	local chip = create("TextLabel", {
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 22),
		BackgroundColor3 = color or T.gold,
		Text = text,
		TextColor3 = rgb(255, 255, 255),
		FontFace = F.extra,
		TextSize = 12,
		Parent = parent,
	}, { UI.corner("full"), UI.pad(0, 9, 0, 9) })
	for key, value in props or {} do
		chip[key] = value
	end
	return chip
end

-- Objetos 3D em ViewportFrame ------------------------------------------------------------------------

local function frameCamera(viewport, model, direction, fov, tighten)
	local camera = Instance.new("Camera")
	camera.FieldOfView = fov or 30
	local center, extent = model:GetBoundingBox()
	local distance = extent.Magnitude / 2 / math.tan(math.rad(camera.FieldOfView / 2)) * (tighten or 1)
	camera.CFrame = CFrame.lookAt(center.Position + direction.Unit * distance, center.Position)
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	return camera
end

-- Bebida do cardápio em 3D.
function UI.product(product, size, props)
	local viewport = create("ViewportFrame", {
		Size = UDim2.fromOffset(size, size),
		BackgroundTransparency = 1,
		Ambient = rgb(205, 200, 215),
		LightColor = rgb(255, 250, 240),
		LightDirection = Vector3.new(-0.5, -1, -0.6),
	})
	for key, value in props or {} do
		viewport[key] = value
	end
	local model = Models.product(product, CFrame.new())
	model.Parent = viewport
	frameCamera(viewport, model, Vector3.new(0.35, 0.45, -1), 30, 1.02)
	return viewport
end

-- Retrato do boneco com a aparência dada. Devolve (viewport, modelo).
function UI.avatar(look, size, props, fullBody)
	local viewport = create("ViewportFrame", {
		Size = UDim2.fromOffset(size, size),
		BackgroundTransparency = 1,
		Ambient = rgb(200, 196, 210),
		LightColor = rgb(255, 250, 244),
		LightDirection = Vector3.new(-0.4, -0.8, -1),
	})
	for key, value in props or {} do
		viewport[key] = value
	end
	local template = Shared:FindFirstChild("BonecoModelo")
	if template == nil then
		return viewport, nil
	end
	local world = create("WorldModel", { Parent = viewport })
	local model = template:Clone()
	model:PivotTo(CFrame.new(0, 0, 0) * CFrame.Angles(0, math.pi, 0))
	model.Parent = world
	Looks.apply(model, look)
	local camera = Instance.new("Camera")
	camera.FieldOfView = 28
	local head = model:FindFirstChild("Head")
	if fullBody or head == nil then
		local center, extent = model:GetBoundingBox()
		local distance = extent.Y / 2 / math.tan(math.rad(14)) * 1.08
		camera.CFrame = CFrame.lookAt(center.Position + Vector3.new(0.25, 0.1, 1).Unit * distance, center.Position)
	else
		local focus = head.Position - Vector3.new(0, 0.55, 0)
		camera.CFrame = CFrame.lookAt(focus + Vector3.new(0.35, 0.15, 1).Unit * 6.2, focus)
	end
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	return viewport, model
end

-- Escala ------------------------------------------------------------------------------------------

local scalers = {}

function UI.currentScale()
	local camera = workspace.CurrentCamera
	if camera == nil then
		return 1
	end
	local viewport = camera.ViewportSize
	if viewport.X < 50 then
		return 1
	end
	return math.clamp(math.min(viewport.X / 1366, viewport.Y / 768), 0.55, 1.2)
end

function UI.scaled(frame)
	local scaler = create("UIScale", { Scale = UI.currentScale(), Parent = frame })
	table.insert(scalers, scaler)
	return frame, scaler
end

function UI.applyScale()
	local value = UI.currentScale()
	for _, scaler in scalers do
		if scaler.Parent then
			scaler.Scale = value
		end
	end
end

function UI.isTouch()
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

function UI.newScreen(name, order, ignoreInset)
	return create("ScreenGui", {
		Name = name,
		ResetOnSpawn = false,
		IgnoreGuiInset = ignoreInset == true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = order or 0,
		Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
	})
end

-- Janelas -------------------------------------------------------------------------------------------

local modalScreen = nil
local openWindow = nil

function UI.closeButton(parent, onClick)
	local button = create("TextButton", {
		Text = "",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -16, 0, 16),
		Size = UDim2.fromOffset(40, 40),
		BackgroundColor3 = T.card,
		Parent = parent,
	}, { UI.corner("full") })
	for _, angle in { 45, -45 } do
		create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(18, 3),
			Rotation = angle,
			BackgroundColor3 = T.muted,
			BorderSizePixel = 0,
			Parent = button,
		}, { UI.corner("full") })
	end
	button.MouseEnter:Connect(function()
		button.BackgroundColor3 = T.cardDark
	end)
	button.MouseLeave:Connect(function()
		button.BackgroundColor3 = T.card
	end)
	button.Activated:Connect(onClick)
	return button
end

-- accent: cor da faixa ao lado do título
function UI.window(title, subtitle, accent, size)
	if modalScreen == nil then
		modalScreen = UI.newScreen("AdegaJanelas", 10, true)
	end
	local dim = create("TextButton", {
		Name = title,
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = T.dim,
		BackgroundTransparency = 1,
		Visible = false,
		Parent = modalScreen,
	})
	local frame = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = size or UDim2.fromOffset(900, 580),
		BackgroundColor3 = T.bg,
		Active = true,
		Parent = dim,
	}, { UI.corner(24) })
	local scale = create("UIScale", { Parent = frame })
	local header = create("Frame", { Size = UDim2.new(1, 0, 0, 84), BackgroundColor3 = T.panel, BorderSizePixel = 0, Parent = frame }, { UI.corner(24) })
	create("Frame", { Position = UDim2.new(0, 0, 1, -24), Size = UDim2.new(1, 0, 0, 24), BackgroundColor3 = T.panel, BorderSizePixel = 0, Parent = header })
	create("Frame", { Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = T.line, BorderSizePixel = 0, Parent = header })
	create("Frame", { Position = UDim2.fromOffset(28, 22), Size = UDim2.fromOffset(6, 40), BackgroundColor3 = accent or T.gold, BorderSizePixel = 0, Parent = header }, { UI.corner("full") })
	UI.label({ Text = title, FontFace = F.heavy, TextSize = 30, Position = UDim2.fromOffset(46, 14), Size = UDim2.new(1, -140, 0, 34), Parent = header })
	local sub = UI.label({ Text = subtitle or "", FontFace = F.medium, TextSize = 15, TextColor3 = T.muted, Position = UDim2.fromOffset(46, 48), Size = UDim2.new(1, -140, 0, 20), Parent = header })
	local body = create("Frame", { Position = UDim2.fromOffset(22, 102), Size = UDim2.new(1, -44, 1, -122), BackgroundTransparency = 1, Parent = frame })

	local win: { [string]: any } = { dim = dim, frame = frame, body = body, subtitle = sub, open = false }
	function win.show()
		if openWindow and openWindow ~= win then
			openWindow.hide()
		end
		openWindow = win
		win.open = true
		dim.Visible = true
		scale.Scale = UI.currentScale() * 0.9
		UI.tween(dim, 0.2, { BackgroundTransparency = 0.5 })
		UI.tween(scale, 0.3, { Scale = UI.currentScale() }, Enum.EasingStyle.Back)
		if win.onShow then
			win.onShow()
		end
	end
	function win.hide()
		if not win.open then
			return
		end
		win.open = false
		if openWindow == win then
			openWindow = nil
		end
		if win.onHide then
			win.onHide()
		end
		UI.tween(dim, 0.16, { BackgroundTransparency = 1 })
		UI.tween(scale, 0.16, { Scale = UI.currentScale() * 0.9 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		task.delay(0.16, function()
			if not win.open then
				dim.Visible = false
			end
		end)
	end
	function win.toggle()
		if win.open then
			win.hide()
		else
			win.show()
		end
	end
	UI.closeButton(header, win.hide).Position = UDim2.new(1, -22, 0, 22)
	dim.Activated:Connect(win.hide)
	return win
end

function UI.closeWindows()
	if openWindow then
		openWindow.hide()
	end
end

function UI.scroll(parent, props)
	local frame = create("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 5,
		ScrollBarImageColor3 = rgb(180, 172, 190),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Parent = parent,
	})
	for key, value in props do
		frame[key] = value
	end
	return frame
end

return UI
