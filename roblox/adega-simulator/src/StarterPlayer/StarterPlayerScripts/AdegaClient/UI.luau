-- UI: tema e componentes da interface (painéis, botões, janelas, barras e animações).

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local UI = {}

local rgb = Color3.fromRGB

UI.T = {
	bg = rgb(16, 12, 26),
	panel = rgb(28, 22, 44),
	card = rgb(40, 32, 62),
	cardLight = rgb(56, 46, 86),
	line = rgb(98, 76, 152),
	text = rgb(248, 244, 255),
	muted = rgb(176, 166, 204),
	gold = rgb(255, 196, 40),
	orange = rgb(255, 128, 40),
	neon = rgb(178, 84, 255),
	pink = rgb(255, 80, 170),
	green = rgb(56, 210, 116),
	greenDark = rgb(26, 140, 76),
	red = rgb(236, 72, 88),
	blue = rgb(70, 150, 255),
	cyan = rgb(60, 210, 230),
	locked = rgb(70, 64, 92),
}
local T = UI.T

UI.Fonts = {
	title = Enum.Font.FredokaOne,
	bold = Enum.Font.GothamBold,
	black = Enum.Font.GothamBlack,
	body = Enum.Font.GothamMedium,
	light = Enum.Font.Gotham,
}

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
		Thickness = thickness or 1.5,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

function UI.gradient(a, b, rotation)
	return create("UIGradient", { Color = ColorSequence.new(a, b), Rotation = rotation or 90 })
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

function UI.list(direction, padding, align)
	return create("UIListLayout", {
		FillDirection = direction or Enum.FillDirection.Vertical,
		Padding = UDim.new(0, padding or 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = align or Enum.HorizontalAlignment.Left,
	})
end

function UI.label(props)
	local defaults = {
		BackgroundTransparency = 1,
		Font = UI.Fonts.bold,
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

function UI.panel(props)
	local frame = create("Frame", {
		BackgroundColor3 = T.panel,
		BackgroundTransparency = 0.06,
		BorderSizePixel = 0,
	})
	for key, value in props do
		frame[key] = value
	end
	UI.corner(16).Parent = frame
	UI.stroke(T.line, 1.5, 0.35).Parent = frame
	UI.gradient(rgb(255, 255, 255), rgb(208, 198, 232)).Parent = frame
	return frame
end

-- Botão com hover e clique animados. style: "green", "gold", "red", "dark", "neon", "blue"
local BUTTON_STYLES = {
	green = { T.green, T.greenDark, rgb(255, 255, 255) },
	gold = { T.gold, T.orange, rgb(60, 25, 0) },
	red = { T.red, rgb(170, 40, 60), rgb(255, 255, 255) },
	dark = { T.cardLight, T.card, T.text },
	neon = { T.neon, rgb(110, 40, 200), rgb(255, 255, 255) },
	blue = { T.blue, rgb(40, 90, 200), rgb(255, 255, 255) },
	locked = { T.locked, rgb(50, 46, 66), T.muted },
}

function UI.button(props, onClick)
	local style = props.Style or "green"
	props.Style = nil
	local colors = BUTTON_STYLES[style]
	local button = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = rgb(255, 255, 255),
		Font = UI.Fonts.black,
		TextSize = 15,
		TextColor3 = colors[3],
		Text = "",
		BorderSizePixel = 0,
	})
	for key, value in props do
		button[key] = value
	end
	UI.corner(12).Parent = button
	local grad = UI.gradient(colors[1], colors[2])
	grad.Name = "Cor"
	grad.Parent = button
	local scale = create("UIScale", { Parent = button })
	button.MouseEnter:Connect(function()
		UI.tween(scale, 0.12, { Scale = 1.05 })
	end)
	button.MouseLeave:Connect(function()
		UI.tween(scale, 0.12, { Scale = 1 })
	end)
	button.MouseButton1Down:Connect(function()
		UI.tween(scale, 0.08, { Scale = 0.93 })
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
	local grad = button:FindFirstChild("Cor")
	if grad then
		grad.Color = ColorSequence.new(colors[1], colors[2])
	end
	button.TextColor3 = colors[3]
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

function UI.bar(parent, props)
	local track = create("Frame", {
		BackgroundColor3 = T.bg,
		BorderSizePixel = 0,
		Parent = parent,
	}, { UI.corner("full") })
	for key, value in props do
		track[key] = value
	end
	local fill = create("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = rgb(255, 255, 255), BorderSizePixel = 0, Parent = track }, {
		UI.corner("full"),
		UI.gradient(props.ColorA or T.neon, props.ColorB or T.pink, 0),
	})
	return track, fill
end

function UI.stars(rating)
	local full = math.floor(rating)
	local half = rating - full >= 0.5
	local text = string.rep("★", full)
	local shown = full
	if half and full < 5 then
		text ..= '<font transparency="0.35">★</font>'
		shown += 1
	end
	if shown < 5 then
		text ..= '<font transparency="0.8">' .. string.rep("★", 5 - shown) .. "</font>"
	end
	return text
end

-- Escala ------------------------------------------------------------------------------------------

local scalers = {}

function UI.currentScale()
	local camera = workspace.CurrentCamera
	if camera == nil then
		return 1
	end
	local viewport = camera.ViewportSize
	return math.clamp(math.min(viewport.X / 1366, viewport.Y / 768), 0.48, 1.2)
end

function UI.scaled(frame)
	local scaler = create("UIScale", { Scale = UI.currentScale(), Parent = frame })
	table.insert(scalers, scaler)
	return frame, scaler
end

function UI.applyScale()
	local value = UI.currentScale()
	for _, scaler in scalers do
		if scaler.Parent and not scaler:GetAttribute("Animating") then
			scaler.Scale = value
		end
	end
end

function UI.isTouch()
	local input = game:GetService("UserInputService")
	return input.TouchEnabled and not input.KeyboardEnabled
end

-- Janelas modais ----------------------------------------------------------------------------------

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

local modalScreen = nil
local openWindow = nil

function UI.window(title, subtitle, icon, size)
	if modalScreen == nil then
		modalScreen = UI.newScreen("AdegaJanelas", 10, true)
	end
	local dim = create("TextButton", {
		Name = title,
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = rgb(5, 2, 12),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = modalScreen,
	})
	local frame = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = size or UDim2.fromOffset(880, 560),
		BackgroundColor3 = T.bg,
		Active = true,
		Parent = dim,
	}, { UI.corner(22), UI.stroke(T.neon, 2, 0.2) })
	local scale = create("UIScale", { Parent = frame })
	local header = create("Frame", { Size = UDim2.new(1, 0, 0, 76), BackgroundColor3 = rgb(255, 255, 255), BorderSizePixel = 0, Parent = frame }, {
		UI.corner(22),
		UI.gradient(rgb(140, 30, 70), rgb(90, 40, 180), 0),
	})
	create("Frame", { Position = UDim2.new(0, 0, 1, -22), Size = UDim2.new(1, 0, 0, 22), BackgroundColor3 = rgb(255, 255, 255), BorderSizePixel = 0, Parent = header }, {
		UI.gradient(rgb(140, 30, 70), rgb(90, 40, 180), 0),
	})
	UI.label({ Text = icon .. "  " .. title, Font = UI.Fonts.title, TextSize = 30, Position = UDim2.fromOffset(24, 8), Size = UDim2.new(1, -140, 0, 38), Parent = header })
	local sub = UI.label({ Text = subtitle or "", Font = UI.Fonts.body, TextSize = 14, TextColor3 = rgb(235, 220, 255), Position = UDim2.fromOffset(26, 44), Size = UDim2.new(1, -140, 0, 20), Parent = header })
	local close = UI.button({
		Style = "red",
		Text = "✕",
		TextSize = 20,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -18, 0, 17),
		Size = UDim2.fromOffset(42, 42),
		Parent = header,
	})
	close.UICorner.CornerRadius = UDim.new(1, 0)
	local body = create("Frame", { Position = UDim2.fromOffset(18, 92), Size = UDim2.new(1, -36, 1, -108), BackgroundTransparency = 1, Parent = frame })

	local win: { [string]: any } = { dim = dim, frame = frame, body = body, subtitle = sub, open = false }
	function win.show()
		if openWindow and openWindow ~= win then
			openWindow.hide()
		end
		openWindow = win
		win.open = true
		dim.Visible = true
		scale.Scale = UI.currentScale() * 0.85
		UI.tween(dim, 0.2, { BackgroundTransparency = 0.45 })
		UI.tween(scale, 0.32, { Scale = UI.currentScale() }, Enum.EasingStyle.Back)
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
		UI.tween(dim, 0.18, { BackgroundTransparency = 1 })
		UI.tween(scale, 0.18, { Scale = UI.currentScale() * 0.85 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		task.delay(0.18, function()
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
	close.Activated:Connect(win.hide)
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
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = T.neon,
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
