-- Props: bebidas e comidas em 3D, bandeja, dinheiro na mesa, sujeira, balões e efeitos.

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Props = {}

local rgb = Color3.fromRGB
local v = Vector3.new
local M = Enum.Material

local function part(model, primary, size, offset, color, material, props)
	local p = Instance.new("Part")
	p.Size = size
	p.Color = color
	p.Material = material or M.SmoothPlastic
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Massless = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if props then
		for key, value in props do
			p[key] = value
		end
	end
	if primary then
		p.CFrame = primary.CFrame * offset
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = primary
		weld.Part1 = p
		weld.Parent = p
	else
		p.CFrame = offset
	end
	p.Parent = model
	return p
end

local CYLINDER = { Shape = Enum.PartType.Cylinder }
local UPRIGHT = CFrame.Angles(0, 0, math.rad(90))

-- Desenha um produto do cardápio. O ponto de apoio (PrimaryPart) fica na base.
function Props.product(product, cframe)
	local model = Instance.new("Model")
	model.Name = product.id
	local base = part(model, nil, v(0.5, 0.05, 0.5), cframe, product.color, M.SmoothPlastic, { Transparency = 1 })
	model.PrimaryPart = base
	local kind = product.visual
	if kind == "lata" then
		part(model, base, v(0.75, 0.42, 0.42), CFrame.new(0, 0.4, 0) * UPRIGHT, product.color, M.Metal, CYLINDER)
		part(model, base, v(0.05, 0.36, 0.36), CFrame.new(0, 0.79, 0) * UPRIGHT, rgb(200, 200, 205), M.Metal, CYLINDER)
	elseif kind == "garrafa" then
		part(model, base, v(0.8, 0.38, 0.38), CFrame.new(0, 0.42, 0) * UPRIGHT, product.color, M.Glass, CYLINDER)
		part(model, base, v(0.45, 0.16, 0.16), CFrame.new(0, 1.02, 0) * UPRIGHT, product.color, M.Glass, CYLINDER)
		part(model, base, v(0.3, 0.39, 0.39), CFrame.new(0, 0.42, 0) * UPRIGHT, rgb(240, 230, 210), M.SmoothPlastic, CYLINDER)
	elseif kind == "dose" then
		part(model, base, v(0.4, 0.34, 0.34), CFrame.new(0, 0.2, 0) * UPRIGHT, rgb(230, 240, 255), M.Glass, { Shape = Enum.PartType.Cylinder, Transparency = 0.5 })
		part(model, base, v(0.26, 0.28, 0.28), CFrame.new(0, 0.15, 0) * UPRIGHT, product.color, M.Glass, CYLINDER)
	elseif kind == "copo" or kind == "taca" then
		local height = if kind == "taca" then 0.55 else 0.7
		if kind == "taca" then
			part(model, base, v(0.45, 0.08, 0.08), CFrame.new(0, 0.25, 0) * UPRIGHT, rgb(230, 240, 255), M.Glass, CYLINDER)
		end
		local y = if kind == "taca" then 0.5 + height / 2 else height / 2
		part(model, base, v(height, 0.5, 0.5), CFrame.new(0, y, 0) * UPRIGHT, rgb(230, 240, 255), M.Glass, { Shape = Enum.PartType.Cylinder, Transparency = 0.55 })
		part(model, base, v(height * 0.8, 0.44, 0.44), CFrame.new(0, y - height * 0.08, 0) * UPRIGHT, product.color, M.Glass, { Shape = Enum.PartType.Cylinder, Transparency = 0.15 })
		part(model, base, v(0.2, 0.2, 0.2), CFrame.new(0.15, y + height / 2, 0), rgb(120, 200, 60), M.SmoothPlastic, { Shape = Enum.PartType.Ball })
	elseif kind == "copao" then
		part(model, base, v(1.1, 0.62, 0.62), CFrame.new(0, 0.55, 0) * UPRIGHT, rgb(235, 240, 255), M.Glass, { Shape = Enum.PartType.Cylinder, Transparency = 0.5 })
		part(model, base, v(0.9, 0.55, 0.55), CFrame.new(0, 0.47, 0) * UPRIGHT, product.color, M.Glass, { Shape = Enum.PartType.Cylinder, Transparency = 0.1 })
		for i = 0, 2 do
			part(model, base, v(0.18, 0.18, 0.18), CFrame.new(-0.12 + i * 0.12, 0.95, 0.05 * i), rgb(240, 250, 255), M.Glass, { Transparency = 0.2 })
		end
		part(model, base, v(0.06, 0.8, 0.06), CFrame.new(0.12, 1.25, 0) * CFrame.Angles(0, 0, math.rad(-12)), rgb(255, 60, 120), M.SmoothPlastic)
	elseif kind == "caneca" then
		part(model, base, v(0.8, 0.5, 0.5), CFrame.new(0, 0.4, 0) * UPRIGHT, product.color, M.Glass, { Shape = Enum.PartType.Cylinder, Transparency = 0.2 })
		part(model, base, v(0.18, 0.52, 0.52), CFrame.new(0, 0.86, 0) * UPRIGHT, rgb(255, 255, 250), M.SmoothPlastic, CYLINDER)
		part(model, base, v(0.1, 0.45, 0.25), CFrame.new(0.33, 0.42, 0), rgb(230, 240, 255), M.Glass, { Transparency = 0.4 })
	elseif kind == "espeto" then
		part(model, base, v(0.06, 1.3, 0.06), CFrame.new(0, 0.65, 0), rgb(200, 160, 100), M.Wood)
		for i = 0, 3 do
			part(model, base, v(0.28, 0.24, 0.28), CFrame.new(0, 0.55 + i * 0.22, 0), if i % 2 == 0 then product.color else rgb(190, 60, 40), M.SmoothPlastic)
		end
	elseif kind == "balde" then
		part(model, base, v(0.8, 0.9, 0.9), CFrame.new(0, 0.4, 0) * UPRIGHT, rgb(200, 205, 215), M.Metal, CYLINDER)
		for i = 0, 3 do
			local angle = i * math.pi / 2
			part(model, base, v(0.6, 0.22, 0.22), CFrame.new(math.cos(angle) * 0.2, 0.95, math.sin(angle) * 0.2) * UPRIGHT, rgb(40, 110, 50), M.Glass, CYLINDER)
		end
	elseif kind == "porcao" then
		part(model, base, v(0.08, 0.9, 0.9), CFrame.new(0, 0.05, 0) * UPRIGHT, rgb(250, 250, 250), M.SmoothPlastic, CYLINDER)
		for i = 0, 6 do
			local angle = i * 0.9
			part(model, base, v(0.1, 0.1, 0.45), CFrame.new(math.cos(angle) * 0.18, 0.15 + (i % 3) * 0.05, math.sin(angle) * 0.18) * CFrame.Angles(0, angle, math.rad(10)), product.color, M.SmoothPlastic)
		end
	else
		part(model, base, v(0.5, 0.8, 0.5), CFrame.new(0, 0.4, 0), product.color, M.Glass)
	end
	return model
end

-- Bandeja com até 6 itens, usada por jogadores e garçons.
function Props.tray(products)
	local model = Instance.new("Model")
	model.Name = "Bandeja"
	local base = part(model, nil, v(1.6, 0.1, 1.6), CFrame.new(), rgb(190, 192, 200), M.Metal)
	model.PrimaryPart = base
	part(model, base, v(0.06, 1.7, 1.7), CFrame.new(0, 0, 0) * UPRIGHT, rgb(170, 172, 180), M.Metal, CYLINDER)
	local spots = { { -0.42, -0.42 }, { 0.42, -0.42 }, { -0.42, 0.42 }, { 0.42, 0.42 }, { 0, 0 }, { 0, -0.7 } }
	for index, product in products do
		local spot = spots[index]
		if spot == nil then
			break
		end
		local item = Props.product(product, base.CFrame * CFrame.new(spot[1], 0.05, spot[2]) * CFrame.new(0, 0, 0))
		for _, p in item:GetDescendants() do
			if p:IsA("BasePart") and p ~= item.PrimaryPart then
				p.Size *= 0.75
			end
		end
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = base
		weld.Part1 = item.PrimaryPart
		weld.Parent = item.PrimaryPart
		item.Parent = model
	end
	return model
end

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
	label.BackgroundColor3 = rgb(30, 120, 60)
	label.TextColor3 = rgb(255, 255, 255)
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.Text = "💵 " .. amount
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

function Props.bubble(adornee, offsetY)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Balao"
	gui.Size = UDim2.fromOffset(70, 70)
	gui.StudsOffset = Vector3.new(0, offsetY or 2.8, 0)
	gui.MaxDistance = 80
	gui.LightInfluence = 0
	gui.AlwaysOnTop = false
	gui.Parent = adornee

	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = rgb(255, 255, 255)
	frame.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 18)
	corner.Parent = frame
	local stroke = Instance.new("UIStroke")
	stroke.Color = rgb(112, 26, 44)
	stroke.Thickness = 3
	stroke.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -10, 0.7, 0)
	label.Position = UDim2.fromOffset(5, 4)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.Font = Enum.Font.FredokaOne
	label.TextColor3 = rgb(30, 20, 40)
	label.Text = ""
	label.Parent = frame

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -16, 0, 7)
	track.Position = UDim2.new(0, 8, 1, -13)
	track.BackgroundColor3 = rgb(225, 220, 230)
	track.Visible = false
	track.Parent = frame
	Instance.new("UICorner").Parent = track
	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(1, 1)
	fill.BackgroundColor3 = rgb(64, 214, 120)
	fill.Parent = track
	Instance.new("UICorner").Parent = fill

	local bubble = { gui = gui }
	function bubble.set(text, width)
		label.Text = text
		gui.Size = UDim2.fromOffset(width or 70, 70)
	end
	function bubble.bar(ratio)
		if ratio == nil then
			track.Visible = false
			return
		end
		track.Visible = true
		ratio = math.clamp(ratio, 0, 1)
		fill.Size = UDim2.fromScale(ratio, 1)
		fill.BackgroundColor3 = if ratio > 0.5 then rgb(64, 214, 120) elseif ratio > 0.25 then rgb(250, 190, 40) else rgb(236, 72, 88)
	end
	function bubble.color(color)
		stroke.Color = color
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
	label.Font = Enum.Font.FredokaOne
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
