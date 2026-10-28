-- Props: bebidas e comidas em 3D, bandeja, dinheiro na mesa, sujeira, balões e efeitos.

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Models = require(ReplicatedStorage:WaitForChild("AdegaShared"):WaitForChild("Models"))

local Props = {}

Props.product = Models.product
Props.tray = Models.tray

local rgb = Color3.fromRGB
local v = Vector3.new
local M = Enum.Material
local part = Models.part
local CYLINDER = Models.CYLINDER
local UPRIGHT = Models.UPRIGHT

-- Dinheiro deixado na mesa.
function Props.money(cframe, amount)
	local model = Instance.new("Model")
	model.Name = "Dinheiro"
	local base = part(model, nil, v(1, 0.05, 0.6), cframe, rgb(60, 160, 80), M.SmoothPlastic, { Transparency = 1 })
	model.PrimaryPart = base
	local stacks = math.clamp(math.ceil(amount / 25), 1, 5)
	for i = 0, stacks - 1 do
		part(model, base, v(1, 0.12, 0.5), CFrame.new(0, 0.06 + i * 0.13, 0) * CFrame.Angles(0, math.rad(i * 14), 0), rgb(80, 180, 100), M.SmoothPlastic)
	end
	part(model, base, v(0.35, 0.08, 0.35), CFrame.new(0.55, 0.05, 0.3) * UPRIGHT, rgb(230, 190, 60), M.Metal, CYLINDER)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(110, 34)
	gui.StudsOffset = Vector3.new(0, 1.4, 0)
	gui.MaxDistance = 50
	gui.LightInfluence = 0
	gui.Parent = base
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = rgb(255, 255, 255)
	label.TextColor3 = rgb(30, 140, 70)
	label.FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Heavy)
	label.TextScaled = true
	label.Text = "R$ " .. amount
	label.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.4, 0)
	corner.Parent = label
	return model, label
end

-- Copos vazios e latas amassadas depois que os clientes vão embora.
function Props.dirt(cframe, count)
	local model = Instance.new("Model")
	model.Name = "Sujeira"
	local base = part(model, nil, v(0.2, 0.05, 0.2), cframe, rgb(0, 0, 0), M.SmoothPlastic, { Transparency = 1 })
	model.PrimaryPart = base
	for i = 1, math.max(2, count) do
		local angle = i * 2.1
		local offset = CFrame.new(math.cos(angle) * 0.6, 0, math.sin(angle) * 0.6)
		if i % 2 == 0 then
			part(model, base, v(0.42, 0.42, 0.42), offset * CFrame.new(0, 0.22, 0) * CFrame.Angles(0, angle, math.rad(90)), rgb(170, 170, 176), M.Metal, CYLINDER)
		else
			part(model, base, v(0.6, 0.45, 0.45), offset * CFrame.new(0, 0.3, 0) * UPRIGHT, rgb(225, 230, 235), M.Glass, { Shape = Enum.PartType.Cylinder, Transparency = 0.45 })
		end
	end
	part(model, base, v(0.6, 0.02, 0.5), CFrame.new(-0.3, 0.01, -0.4), rgb(230, 220, 180), M.SmoothPlastic)
	return model
end

-- Balão em cima da cabeça ou da mesa ----------------------------------------------------------------

local FONT_HEAVY = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Heavy)
local INK = rgb(40, 34, 48)

local function productViewport(parent, product, size, order)
	local viewport = Instance.new("ViewportFrame")
	viewport.Size = UDim2.fromOffset(size, size)
	viewport.BackgroundTransparency = 1
	viewport.Ambient = rgb(200, 196, 210)
	viewport.LightColor = rgb(255, 250, 240)
	viewport.LightDirection = Vector3.new(-0.5, -1, -0.6)
	viewport.LayoutOrder = order or 0
	local model = Models.product(product, CFrame.new())
	model.Parent = viewport
	local camera = Instance.new("Camera")
	camera.FieldOfView = 30
	local center, extent = model:GetBoundingBox()
	local distance = extent.Magnitude / 2 / math.tan(math.rad(15)) * 1.05
	camera.CFrame = CFrame.lookAt(center.Position + Vector3.new(0.35, 0.45, -1).Unit * distance, center.Position)
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	viewport.Parent = parent
	return viewport
end
Props.productViewport = productViewport

-- Balão: mode "text" (texto curto), "call" (cliente chamando) ou "products" (bebidas em 3D).
function Props.bubble(adornee, offsetY)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Balao"
	gui.Size = UDim2.fromOffset(64, 64)
	gui.StudsOffset = Vector3.new(0, offsetY or 2.8, 0)
	gui.MaxDistance = 80
	gui.LightInfluence = 0
	gui.Parent = adornee

	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromScale(0.5, 0.5)
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = rgb(255, 255, 255)
	frame.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 20)
	corner.Parent = frame
	local stroke = Instance.new("UIStroke")
	stroke.Color = rgb(255, 255, 255)
	stroke.Thickness = 3
	stroke.Transparency = 0
	stroke.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, -8)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.FontFace = FONT_HEAVY
	label.TextColor3 = INK
	label.Text = ""
	label.Parent = frame
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 8)
	padding.PaddingBottom = UDim.new(0, 4)
	padding.Parent = label

	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -12, 1, -14)
	row.Position = UDim2.fromOffset(6, 3)
	row.BackgroundTransparency = 1
	row.Visible = false
	row.Parent = frame
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 2)
	layout.Parent = row

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -18, 0, 6)
	track.Position = UDim2.new(0, 9, 1, -11)
	track.BackgroundColor3 = rgb(232, 228, 236)
	track.BorderSizePixel = 0
	track.Visible = false
	track.Parent = frame
	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(1, 0)
	trackCorner.Parent = track
	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(1, 1)
	fill.BackgroundColor3 = rgb(52, 199, 89)
	fill.BorderSizePixel = 0
	fill.Parent = track
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = fill

	local bubble = { gui = gui }
	local shownKey = nil

	function bubble.text(text)
		row.Visible = false
		label.Visible = true
		label.Text = text
		label.TextColor3 = INK
		frame.BackgroundColor3 = rgb(255, 255, 255)
		stroke.Color = rgb(255, 255, 255)
		gui.Size = UDim2.fromOffset(64, 56)
		shownKey = nil
	end

	function bubble.call()
		row.Visible = false
		label.Visible = true
		label.Text = "!"
		label.TextColor3 = rgb(255, 255, 255)
		frame.BackgroundColor3 = rgb(255, 149, 0)
		stroke.Color = rgb(255, 255, 255)
		gui.Size = UDim2.fromOffset(58, 66)
		shownKey = nil
	end

	-- products = lista de produtos ainda não entregues
	function bubble.products(products)
		local ids = {}
		for _, product in products do
			table.insert(ids, product.id)
		end
		local key = table.concat(ids, ",")
		if key == shownKey then
			return
		end
		shownKey = key
		label.Visible = false
		row.Visible = true
		frame.BackgroundColor3 = rgb(255, 255, 255)
		stroke.Color = rgb(255, 255, 255)
		for _, child in row:GetChildren() do
			if child:IsA("ViewportFrame") then
				child:Destroy()
			end
		end
		for index, product in products do
			productViewport(row, product, 40, index)
		end
		gui.Size = UDim2.fromOffset(math.max(64, #products * 42 + 16), 62)
	end

	function bubble.bar(ratio)
		if ratio == nil then
			track.Visible = false
			return
		end
		track.Visible = true
		ratio = math.clamp(ratio, 0, 1)
		fill.Size = UDim2.fromScale(ratio, 1)
		fill.BackgroundColor3 = if ratio > 0.5 then rgb(52, 199, 89) elseif ratio > 0.25 then rgb(255, 179, 0) else rgb(255, 69, 58)
	end

	function bubble.destroy()
		gui:Destroy()
	end
	return bubble
end

local function anchorAt(position)
	local holder = Instance.new("Part")
	holder.Anchored = true
	holder.CanCollide = false
	holder.CanQuery = false
	holder.CanTouch = false
	holder.Transparency = 1
	holder.Size = Vector3.new(0.2, 0.2, 0.2)
	holder.Position = position
	holder.Parent = workspace
	return holder
end

-- Texto que sobe e some (ganhos, emoções).
function Props.popup(position, text, color)
	local holder = anchorAt(position)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(150, 40)
	gui.StudsOffset = Vector3.new(0, 1, 0)
	gui.MaxDistance = 80
	gui.LightInfluence = 0
	gui.AlwaysOnTop = true
	gui.Parent = holder
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.FontFace = FONT_HEAVY
	label.Text = text
	label.TextColor3 = color or rgb(110, 255, 140)
	label.TextStrokeTransparency = 0.2
	label.Parent = gui
	TweenService:Create(gui, TweenInfo.new(1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { StudsOffset = Vector3.new(0, 4.5, 0) }):Play()
	TweenService:Create(label, TweenInfo.new(1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	Debris:AddItem(holder, 1.5)
end

function Props.sparkle(position, color)
	local holder = anchorAt(position)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Color = ColorSequence.new(color or rgb(255, 196, 40), rgb(255, 255, 255))
	emitter.LightEmission = 1
	emitter.Size = NumberSequence.new(0.5, 0)
	emitter.Speed = NumberRange.new(6, 12)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Lifetime = NumberRange.new(0.4, 0.8)
	emitter.Rate = 0
	emitter.Parent = holder
	emitter:Emit(24)
	Debris:AddItem(holder, 1.5)
end

return Props
