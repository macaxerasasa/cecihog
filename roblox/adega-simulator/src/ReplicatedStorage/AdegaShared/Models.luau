-- Models: bebidas e comidas do cardápio em 3D e a bandeja.
-- Usado no servidor (mão dos bonecos, balcão) e na interface (ícones 3D).

local Models = {}

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
function Models.product(product, cframe)
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
function Models.tray(products)
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
		local item = Models.product(product, base.CFrame * CFrame.new(spot[1], 0.05, spot[2]) * CFrame.new(0, 0, 0))
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

Models.part = part
Models.CYLINDER = CYLINDER
Models.UPRIGHT = UPRIGHT

return Models
