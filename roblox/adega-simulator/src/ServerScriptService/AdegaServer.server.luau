-- AdegaServer (Script em ServerScriptService)
-- Dá uma adega para cada jogador, vende melhorias, contrata funcionários, simula os clientes
-- (fila no balcão, mesas e rodadas), controla dia e noite e salva o progresso.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")

print("[Adega] AdegaServer iniciou")

-- Procura o AdegaConfig sem ligar para maiúsculas e em qualquer pasta comum.
local function findConfig()
	for _, container in { ReplicatedStorage, game:GetService("ServerScriptService"), game:GetService("ServerStorage"), workspace } do
		for _, child in container:GetDescendants() do
			if child:IsA("ModuleScript") and child.Name:lower() == "adegaconfig" then
				return child
			end
		end
	end
	return nil
end

local configModule = findConfig()
local deadline = os.clock() + 10
while configModule == nil and os.clock() < deadline do
	task.wait(0.5)
	configModule = findConfig()
end
if configModule == nil then
	error("[Adega] Não achei o ModuleScript AdegaConfig. Crie um ModuleScript chamado AdegaConfig dentro de ReplicatedStorage e cole nele o código do AdegaConfig.luau.")
end
if configModule.Parent ~= ReplicatedStorage then
	-- A interface do jogador só enxerga o ReplicatedStorage.
	configModule.Parent = ReplicatedStorage
end

local Config = require(configModule)
if type(Config) ~= "table" or type(Config.Items) ~= "table" then
	error("[Adega] O AdegaConfig não tem o código certo. Apague tudo que está nele e cole de novo o conteúdo inteiro do AdegaConfig.luau.")
end

local storeOk, store = pcall(function()
	return DataStoreService:GetDataStore(Config.DataStoreName)
end)
if not storeOk then
	warn("[Adega] DataStore indisponível, o progresso não será salvo:", store)
	store = nil
end

local rgb = Color3.fromRGB
local formatMoney = Config.formatMoney
local STAND_Y = 3.05

-- Comunicação com a interface ---------------------------------------------------------------

local remotes = ReplicatedStorage:FindFirstChild("AdegaRemotes")
if remotes then
	remotes:Destroy()
end
remotes = Instance.new("Folder")
remotes.Name = "AdegaRemotes"
local stateEvent = Instance.new("RemoteEvent")
stateEvent.Name = "Estado"
stateEvent.Parent = remotes
local buyEvent = Instance.new("RemoteEvent")
buyEvent.Name = "Comprar"
buyEvent.Parent = remotes
local noticeEvent = Instance.new("RemoteEvent")
noticeEvent.Name = "Aviso"
noticeEvent.Parent = remotes
remotes.Parent = ReplicatedStorage

local function notify(player, text, kind)
	if player and player.Parent then
		noticeEvent:FireClient(player, text, kind or "info")
	end
end

-- Ambiente: céu, neblina, brilho do neon -------------------------------------------------------

local function ensureEffect(className, name, props)
	local effect = Lighting:FindFirstChild(name)
	if effect == nil then
		effect = Instance.new(className)
		effect.Name = name
		effect.Parent = Lighting
	end
	for key, value in props do
		effect[key] = value
	end
end

Lighting.ClockTime = 17.5
Lighting.Brightness = 2
Lighting.EnvironmentDiffuseScale = 1
Lighting.EnvironmentSpecularScale = 1
Lighting.OutdoorAmbient = rgb(110, 98, 128)
Lighting.Ambient = rgb(38, 32, 52)
ensureEffect("Atmosphere", "AdegaAtmosfera", { Density = 0.28, Offset = 0.2, Color = rgb(200, 170, 215), Decay = rgb(90, 60, 130), Glare = 0.3, Haze = 1.6 })
ensureEffect("BloomEffect", "AdegaBrilho", { Intensity = 0.7, Size = 28, Threshold = 0.95 })
ensureEffect("ColorCorrectionEffect", "AdegaCor", { Saturation = 0.12, Contrast = 0.08, TintColor = rgb(255, 246, 240) })
ensureEffect("SunRaysEffect", "AdegaRaios", { Intensity = 0.04, Spread = 0.6 })

local function nightMultiplier()
	local hour = Lighting.ClockTime
	if hour >= 18 or hour < 2 then
		return 1.5
	elseif hour < 6 then
		return 0.6
	end
	return 1
end

-- Construção ------------------------------------------------------------------------------------

local function makeText(parent, text, color, font)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextScaled = true
	label.Font = font or Enum.Font.FredokaOne
	label.TextColor3 = color or Color3.new(1, 1, 1)
	label.Parent = parent
	return label
end

local function makePart(parent, origin, props)
	local part = Instance.new("Part")
	part.Name = props.name or "Peca"
	part.Anchored = true
	part.Size = props.size
	part.CFrame = origin * CFrame.new(props.pos) * (props.rot or CFrame.identity)
	part.Color = props.color or rgb(200, 200, 200)
	part.Material = props.material or Enum.Material.SmoothPlastic
	part.Transparency = props.transparency or 0
	part.CanCollide = props.canCollide ~= false and part.Transparency < 1
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	if props.shape then
		part.Shape = props.shape
	end

	local label
	if props.text then
		local gui = Instance.new("SurfaceGui")
		gui.Face = Enum.NormalId.Front
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = 40
		gui.LightInfluence = 0
		gui.Parent = part
		local padding = Instance.new("UIPadding")
		padding.PaddingLeft = UDim.new(0.04, 0)
		padding.PaddingRight = UDim.new(0.04, 0)
		padding.PaddingTop = UDim.new(0.08, 0)
		padding.PaddingBottom = UDim.new(0.08, 0)
		padding.Parent = gui
		label = makeText(gui, props.text, props.textColor, props.font)
	end
	if props.light then
		local light = Instance.new("PointLight")
		light.Color = props.light.color
		light.Range = props.light.range
		light.Brightness = props.light.brightness
		light.Shadows = false
		light.Parent = part
	end
	if props.smoke then
		local smoke = Instance.new("Smoke")
		smoke.Size = 2
		smoke.Opacity = 0.12
		smoke.RiseVelocity = 3
		smoke.Color = rgb(200, 200, 200)
		smoke.Parent = part
	end

	part.Parent = parent
	return part, label
end

local function sparkle(position)
	local holder = Instance.new("Part")
	holder.Anchored = true
	holder.CanCollide = false
	holder.CanQuery = false
	holder.Transparency = 1
	holder.Size = Vector3.new(1, 1, 1)
	holder.Position = position
	local emitter = Instance.new("ParticleEmitter")
	emitter.Color = ColorSequence.new(Config.Theme.gold, rgb(255, 255, 255))
	emitter.LightEmission = 1
	emitter.Size = NumberSequence.new(0.6, 0)
	emitter.Speed = NumberRange.new(8, 14)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Lifetime = NumberRange.new(0.5, 0.9)
	emitter.Rate = 0
	emitter.Parent = holder
	holder.Parent = workspace
	emitter:Emit(30)
	Debris:AddItem(holder, 2)
end

-- Bonecos (clientes e funcionários) ------------------------------------------------------------

local LIMBS = {
	LeftArm = { size = Vector3.new(1, 2, 1), pivot = Vector3.new(-1.5, 0.5, 0), hang = Vector3.new(0, -0.5, 0) },
	RightArm = { size = Vector3.new(1, 2, 1), pivot = Vector3.new(1.5, 0.5, 0), hang = Vector3.new(0, -0.5, 0) },
	LeftLeg = { size = Vector3.new(1, 2, 1), pivot = Vector3.new(-0.5, -1, 0), hang = Vector3.new(0, -1, 0) },
	RightLeg = { size = Vector3.new(1, 2, 1), pivot = Vector3.new(0.5, -1, 0), hang = Vector3.new(0, -1, 0) },
}

local function limbC0(name, angle)
	local def = LIMBS[name]
	return CFrame.new(def.pivot) * CFrame.Angles(angle, 0, 0) * CFrame.new(def.hang)
end

local SKINS = { rgb(255, 224, 189), rgb(234, 192, 134), rgb(198, 134, 66), rgb(141, 85, 36), rgb(96, 58, 30) }
local SHIRTS = { rgb(230, 57, 70), rgb(29, 53, 87), rgb(42, 157, 143), rgb(244, 162, 97), rgb(250, 250, 250), rgb(25, 25, 28), rgb(255, 214, 10), rgb(120, 70, 200), rgb(0, 120, 70) }
local PANTS = { rgb(40, 60, 110), rgb(30, 30, 34), rgb(90, 90, 96), rgb(60, 110, 60), rgb(150, 120, 80), rgb(200, 200, 200) }
local HAIRS = { rgb(30, 22, 18), rgb(70, 45, 25), rgb(15, 15, 15), rgb(200, 160, 80), rgb(120, 60, 30) }

local function pick(list)
	return list[math.random(1, #list)]
end

local function weldPart(root, part, c0)
	part.Anchored = false
	part.Massless = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	local weld = Instance.new("Weld")
	weld.Part0 = root
	weld.Part1 = part
	weld.C0 = c0
	weld.Parent = part
	return weld
end

local function newPart(name, size, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	return part
end

-- look = { skin, shirt, pants, hat, hatColor, label, tray }
local function makeRig(parent, cframe, look)
	local model = Instance.new("Model")
	model.Name = look.label or "Cliente"

	local root = newPart("Tronco", Vector3.new(2, 2, 1), look.shirt)
	root.Anchored = true
	root.CanCollide = false
	root.CanQuery = false
	root.CanTouch = false
	root.CFrame = cframe
	root.Parent = model
	model.PrimaryPart = root

	local rig = { model = model, root = root, welds = {}, anims = {}, held = nil }

	local head = newPart("Cabeca", Vector3.new(1.2, 1.2, 1.2), look.skin)
	weldPart(root, head, CFrame.new(0, 1.6, 0))
	local face = Instance.new("Decal")
	face.Face = Enum.NormalId.Front
	face.Texture = "rbxasset://textures/face.png"
	face.Parent = head
	head.Parent = model
	rig.head = head

	for name in LIMBS do
		local isArm = name == "LeftArm" or name == "RightArm"
		local limb = newPart(name, LIMBS[name].size, if isArm then look.skin else look.pants)
		rig.welds[name] = weldPart(root, limb, limbC0(name, 0))
		limb.Parent = model
		if isArm then
			local sleeve = newPart("Manga", Vector3.new(1.05, 0.8, 1.05), look.shirt)
			weldPart(limb, sleeve, CFrame.new(0, 0.62, 0))
			sleeve.Parent = model
		end
	end

	local hat = look.hat
	local hatColor = look.hatColor or rgb(30, 22, 18)
	if hat == "hair" then
		local hair = newPart("Cabelo", Vector3.new(1.3, 0.35, 1.3), hatColor)
		weldPart(head, hair, CFrame.new(0, 0.68, 0.03))
		hair.Parent = model
		local back = newPart("Nuca", Vector3.new(1.3, 0.7, 0.25), hatColor)
		weldPart(head, back, CFrame.new(0, 0.3, 0.58))
		back.Parent = model
	elseif hat == "long" then
		local hair = newPart("Cabelo", Vector3.new(1.32, 0.35, 1.32), hatColor)
		weldPart(head, hair, CFrame.new(0, 0.68, 0.03))
		hair.Parent = model
		local back = newPart("CabeloLongo", Vector3.new(1.32, 1.6, 0.3), hatColor)
		weldPart(head, back, CFrame.new(0, -0.1, 0.6))
		back.Parent = model
	elseif hat == "cap" then
		local cap = newPart("Bone", Vector3.new(1.3, 0.4, 1.3), hatColor)
		weldPart(head, cap, CFrame.new(0, 0.7, 0))
		cap.Parent = model
		local brim = newPart("Aba", Vector3.new(1.2, 0.12, 0.7), hatColor)
		weldPart(head, brim, CFrame.new(0, 0.55, -0.85))
		brim.Parent = model
	elseif hat == "chef" then
		local chef = newPart("Touca", Vector3.new(1.25, 0.9, 1.25), rgb(250, 250, 250))
		weldPart(head, chef, CFrame.new(0, 1, 0))
		chef.Parent = model
	elseif hat == "headphones" then
		local band = newPart("Fone", Vector3.new(1.5, 0.2, 0.3), rgb(20, 20, 20))
		weldPart(head, band, CFrame.new(0, 0.7, 0))
		band.Parent = model
		for _, x in { -0.7, 0.7 } do
			local cup = newPart("Concha", Vector3.new(0.3, 0.6, 0.6), look.shirt, Enum.Material.Neon)
			weldPart(head, cup, CFrame.new(x, 0.1, 0))
			cup.Parent = model
		end
	end

	if look.tray then
		local tray = newPart("Bandeja", Vector3.new(1.4, 0.1, 1.4), rgb(190, 190, 196), Enum.Material.Metal)
		weldPart(rig.welds.RightArm.Part1, tray, CFrame.new(0, -1.05, -0.4) * CFrame.Angles(math.rad(-80), 0, 0))
		tray.Parent = model
		rig.welds.RightArm.C0 = limbC0("RightArm", math.rad(80))
		rig.held = tray
	end

	if look.label and look.label ~= "Cliente" then
		local gui = Instance.new("BillboardGui")
		gui.Size = UDim2.fromOffset(110, 26)
		gui.StudsOffset = Vector3.new(0, 3.2, 0)
		gui.MaxDistance = 45
		gui.LightInfluence = 0
		gui.Parent = head
		local tag = makeText(gui, look.label, rgb(255, 255, 255), Enum.Font.GothamBold)
		tag.TextStrokeTransparency = 0.4
	end

	model.Parent = parent
	return rig
end

local function setWalking(rig, walking)
	for _, tween in rig.anims do
		tween:Cancel()
	end
	table.clear(rig.anims)
	for name, weld in rig.welds do
		if name == "RightArm" and rig.held then
			continue
		end
		if walking then
			local sign = if name == "LeftLeg" or name == "RightArm" then 1 else -1
			weld.C0 = limbC0(name, math.rad(28) * sign)
			local tween = TweenService:Create(
				weld,
				TweenInfo.new(0.32, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
				{ C0 = limbC0(name, math.rad(-28) * sign) }
			)
			tween:Play()
			table.insert(rig.anims, tween)
		else
			weld.C0 = limbC0(name, 0)
		end
	end
end

local function setSitting(rig, sitting)
	setWalking(rig, false)
	local angle = if sitting then math.rad(90) else 0
	rig.welds.LeftLeg.C0 = limbC0("LeftLeg", angle)
	rig.welds.RightLeg.C0 = limbC0("RightLeg", angle)
end

local function holdItem(rig, color)
	if rig.held then
		rig.held:Destroy()
	end
	local cup = newPart("Bebida", Vector3.new(0.55, 0.9, 0.55), color, Enum.Material.Glass)
	cup.Transparency = 0.15
	weldPart(rig.welds.RightArm.Part1, cup, CFrame.new(0, -1.1, -0.35) * CFrame.Angles(math.rad(-55), 0, 0))
	cup.Parent = rig.model
	rig.held = cup
	rig.welds.RightArm.C0 = limbC0("RightArm", math.rad(55))
end

local function popup(rig, text, color)
	if rig.head.Parent == nil then
		return
	end
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(130, 36)
	gui.StudsOffset = Vector3.new(0, 2.4, 0)
	gui.MaxDistance = 70
	gui.LightInfluence = 0
	gui.AlwaysOnTop = true
	gui.Parent = rig.head
	local label = makeText(gui, text, color)
	label.TextStrokeTransparency = 0.2
	TweenService:Create(gui, TweenInfo.new(1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { StudsOffset = Vector3.new(0, 5, 0) }):Play()
	TweenService:Create(label, TweenInfo.new(1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	Debris:AddItem(gui, 1.5)
end

-- Balão de pedido em cima do cliente, com barra de progresso enquanto é atendido.
local function orderBubble(rig, icon)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Pedido"
	gui.Size = UDim2.fromOffset(64, 64)
	gui.StudsOffset = Vector3.new(0, 2.6, 0)
	gui.MaxDistance = 60
	gui.LightInfluence = 0
	gui.Parent = rig.head

	local bubble = Instance.new("Frame")
	bubble.Size = UDim2.fromScale(1, 1)
	bubble.BackgroundColor3 = rgb(255, 255, 255)
	bubble.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.3, 0)
	corner.Parent = bubble
	local stroke = Instance.new("UIStroke")
	stroke.Color = Config.Theme.wine
	stroke.Thickness = 3
	stroke.Parent = bubble

	local emoji = makeText(bubble, icon, rgb(0, 0, 0))
	emoji.Size = UDim2.fromScale(0.8, 0.62)
	emoji.Position = UDim2.fromScale(0.1, 0.08)

	local track = Instance.new("Frame")
	track.Size = UDim2.new(0.76, 0, 0, 7)
	track.Position = UDim2.fromScale(0.12, 0.76)
	track.BackgroundColor3 = rgb(225, 220, 230)
	track.Parent = bubble
	Instance.new("UICorner").Parent = track
	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = rgb(64, 214, 120)
	fill.Parent = track
	Instance.new("UICorner").Parent = fill

	return gui, fill
end

-- Terrenos ---------------------------------------------------------------------------------------

local plots = {}
local plotOf = {}

local function at(plot, x, z, y)
	return (plot.origin * CFrame.new(x, y or STAND_Y, z)).Position
end

local function facing(plot, x, z, dirX, dirZ, y)
	local position = at(plot, x, z, y)
	local direction = plot.origin:VectorToWorldSpace(Vector3.new(dirX, 0, dirZ))
	return CFrame.lookAt(position, position + direction)
end

local function computeStats(plot)
	local s = { seats = 0, attraction = 0, ambiance = 0, stations = 0, waiters = 0, capacity = 0, rating = 0, serviceSpeed = 0, autoCollect = false }
	for _, item in Config.Items do
		local level = plot.items[item.id] or 0
		if level > 0 and item.effects then
			for key, value in item.effects do
				if type(value) == "boolean" then
					s[key] = s[key] or value
				else
					s[key] += value * level
				end
			end
		end
	end
	s.stations = math.max(1, s.stations)
	s.ratingValue = math.clamp(1 + s.ambiance * 0.11 + s.rating + (s.stations - 1) * 0.15, 1, 5)
	s.cpm = (Config.BaseCustomersPerMinute + s.attraction + s.ambiance * 0.3 + plot.level * 0.4) * (0.8 + s.ratingValue * 0.1)
	s.capacityTotal = math.min(Config.MaxCustomersPerPlot, s.seats + s.stations * Config.QueuePerStation + s.capacity)
	s.products = Config.unlockedProducts(plot.items)
	s.tipRate = (s.ratingValue - 1) * 0.05
	local sum = 0
	for _, product in s.products do
		sum += product.price
	end
	s.ticket = sum / #s.products * (1 + s.tipRate)
	return s
end

local function markDirty(plot)
	plot.dirty = true
end

local function sendState(plot)
	local player = plot.owner
	if player == nil then
		return
	end
	plot.dirty = false
	local s = plot.stats
	local products = {}
	for _, product in s.products do
		table.insert(products, product.id)
	end
	stateEvent:FireClient(player, {
		cash = plot.cash,
		pending = plot.pending,
		level = plot.level,
		xp = plot.xp,
		xpNext = Config.xpForLevel(plot.level),
		rating = s.ratingValue,
		cpm = s.cpm * nightMultiplier(),
		present = plot.present,
		capacity = s.capacityTotal,
		seats = s.seats,
		staff = s.stations + s.waiters + (plot.items.caixa or 0) + (plot.items.seguranca or 0) + (plot.items.dj or 0) + (plot.items.churrasqueiro or 0),
		ticket = s.ticket,
		autoCollect = s.autoCollect,
		items = plot.items,
		products = products,
	})
end

local function updateLeaderstats(plot)
	local player = plot.owner
	local stats = player and player:FindFirstChild("leaderstats")
	if stats then
		stats.Dinheiro.Value = math.floor(plot.cash)
		stats["Nível"].Value = plot.level
	end
end

local function updateMenuBoard(plot)
	if plot.menuLabel == nil then
		return
	end
	local lines = { "CARDÁPIO" }
	for _, product in plot.stats.products do
		table.insert(lines, product.icon .. " " .. string.upper(product.name) .. "  " .. formatMoney(product.price))
	end
	plot.menuLabel.Text = table.concat(lines, "\n")
end

local function addCash(plot, amount)
	plot.cash += amount
	updateLeaderstats(plot)
	markDirty(plot)
end

local function addXp(plot, amount)
	plot.xp += amount
	while plot.level < Config.MaxLevel and plot.xp >= Config.xpForLevel(plot.level) do
		plot.xp -= Config.xpForLevel(plot.level)
		plot.level += 1
		plot.stats = computeStats(plot)
		notify(plot.owner, "Sua adega subiu para o nível " .. plot.level .. "!", "nivel")
		sparkle(at(plot, 0, 0, 8))
	end
	updateLeaderstats(plot)
end

local function pay(plot, rig, product)
	local s = plot.stats
	local amount = math.max(1, math.floor(product.price * (1 + s.tipRate) + 0.5))
	if s.autoCollect then
		addCash(plot, amount)
	else
		plot.pending += amount
		markDirty(plot)
	end
	addXp(plot, product.price)
	popup(rig, "+" .. formatMoney(amount), rgb(110, 255, 140))
end

local function collectRegister(plot, player)
	if player ~= plot.owner or plot.pending <= 0 then
		return
	end
	local amount = plot.pending
	plot.pending = 0
	addCash(plot, amount)
	notify(player, "Você recolheu " .. formatMoney(amount) .. " do caixa", "dinheiro")
	sparkle(plot.register.Position + Vector3.new(0, 1, 0))
end

-- Mesas e cadeiras -------------------------------------------------------------------------------

local function activeSlots(plot)
	local slots = {}
	for i = 1, plot.items.mesas or 0 do
		table.insert(slots, Config.TableSlots[i])
	end
	for i = 1, plot.items.mesasExtra or 0 do
		table.insert(slots, Config.TableSlots[12 + i])
	end
	return slots
end

local function rebuildSeats(plot)
	local existing = {}
	for _, seat in plot.seats do
		existing[seat.key] = seat
	end
	local seats = {}
	for _, slot in activeSlots(plot) do
		local tx, tz = slot[1], slot[2]
		for index, chair in Config.ChairOffsets do
			local key = tx .. ":" .. tz .. ":" .. index
			local seat = existing[key]
			if seat == nil then
				-- Chega pelo corredor ao lado da mesa (cadeiras laterais) ou pela faixa entre as fileiras.
				local aisleX = if chair.dx > 0 then tx + 4 else tx - 4
				local laneZ = if chair.dz > 0 then tz + 4 elseif chair.dz < 0 then tz - 4 else tz
				local finalX = if chair.dx ~= 0 then aisleX else tx
				seat = {
					key = key,
					x = tx + chair.dx,
					z = tz + chair.dz,
					faceX = chair.faceX,
					faceZ = chair.faceZ,
					approach = { { aisleX, 0 }, { aisleX, laneZ }, { finalX, laneZ } },
					occupant = nil,
				}
			end
			table.insert(seats, seat)
		end
	end
	plot.seats = seats
end

local function freeSeat(plot)
	local free = {}
	for _, seat in plot.seats do
		if seat.occupant == nil then
			table.insert(free, seat)
		end
	end
	if #free == 0 then
		return nil
	end
	return free[math.random(1, #free)]
end

-- Movimento --------------------------------------------------------------------------------------

local function walkTo(plot, rig, x, z, alive)
	if not alive() then
		return
	end
	local target = at(plot, x, z)
	local from = rig.root.Position
	local flat = Vector3.new(target.X - from.X, 0, target.Z - from.Z)
	local distance = flat.Magnitude
	if distance < 0.05 then
		return
	end
	local look = CFrame.lookAt(from, from + flat)
	rig.root.CFrame = look
	local tween = TweenService:Create(rig.root, TweenInfo.new(distance / Config.WalkSpeed, Enum.EasingStyle.Linear), {
		CFrame = look.Rotation + target,
	})
	tween:Play()
	tween.Completed:Wait()
end

local function walkPath(plot, rig, points, alive)
	setWalking(rig, true)
	for _, point in points do
		walkTo(plot, rig, point[1], point[2], alive)
		if not alive() then
			break
		end
	end
	setWalking(rig, false)
end

local function reversed(points)
	local list = {}
	for i = #points, 1, -1 do
		table.insert(list, points[i])
	end
	return list
end

-- Clientes ---------------------------------------------------------------------------------------

local function stationX(index)
	return Config.StaffSpots.atendente[index][1]
end

local function chooseStation(plot)
	local best, bestCount = 1, math.huge
	for index = 1, plot.stats.stations do
		local count = #plot.queues[index]
		if count < bestCount then
			best, bestCount = index, count
		end
	end
	return best
end

local function runCustomer(plot)
	local session = plot.session
	local side = if math.random() < 0.5 then -1 else 1
	local lookHat = pick({ "hair", "hair", "long", "cap", "none" })
	local rig = makeRig(plot.customers, facing(plot, side * 46, -44, -side, 0), {
		skin = pick(SKINS),
		shirt = pick(SHIRTS),
		pants = pick(PANTS),
		hat = lookHat,
		hatColor = if lookHat == "cap" then pick(SHIRTS) else pick(HAIRS),
	})
	local function alive()
		return plot.session == session and rig.model.Parent ~= nil
	end
	plot.present += 1
	markDirty(plot)

	local customer = { rig = rig, seated = false, waiting = false, served = false, wants = nil, bubble = nil }
	local seat = nil

	-- chega pela calçada e entra pelo corredor central
	walkPath(plot, rig, { { -2, -44 }, { -2, 2 } }, alive)

	-- fila do balcão
	local station = chooseStation(plot)
	local queue = plot.queues[station]
	table.insert(queue, customer)
	local sx = stationX(station)
	local spot = 0
	while alive() do
		local position = table.find(queue, customer)
		if position == nil then
			break
		end
		if position ~= spot then
			spot = position
			walkPath(plot, rig, { { sx, Config.CounterFrontZ - (position - 1) * 2.2 } }, alive)
			rig.root.CFrame = facing(plot, sx, Config.CounterFrontZ - (position - 1) * 2.2, 0, 1)
		end
		if position == 1 then
			break
		end
		task.wait(0.25)
	end

	if alive() then
		local products = plot.stats.products
		local product = products[math.random(1, #products)]
		local serviceTime = Config.BaseServiceTime / (1 + plot.stats.serviceSpeed)
		local bubble, fill = orderBubble(rig, product.icon)
		TweenService:Create(fill, TweenInfo.new(serviceTime, Enum.EasingStyle.Linear), { Size = UDim2.fromScale(1, 1) }):Play()
		task.wait(serviceTime)
		bubble:Destroy()
		if alive() then
			pay(plot, rig, product)
			holdItem(rig, product.color)
		end
	end
	local position = table.find(queue, customer)
	if position then
		table.remove(queue, position)
	end

	if alive() then
		seat = freeSeat(plot)
		if seat then
			seat.occupant = customer
			local route = { { sx, 0 } }
			for _, point in seat.approach do
				table.insert(route, point)
			end
			walkPath(plot, rig, route, alive)
			walkPath(plot, rig, { { seat.x, seat.z } }, alive)
			if alive() then
				rig.root.CFrame = facing(plot, seat.x, seat.z, seat.faceX, seat.faceZ, Config.SeatTop + 1.5)
				setSitting(rig, true)
				customer.seated = true
				local leaveAt = os.clock() + math.random(26, 42)
				local nextRound = os.clock() + Config.RoundInterval
				while alive() and os.clock() < leaveAt do
					if plot.stats.waiters > 0 and not customer.waiting and os.clock() >= nextRound then
						customer.waiting = true
						local item = plot.stats.products[math.random(1, #plot.stats.products)]
						customer.wants = item
						customer.bubble = orderBubble(rig, item.icon)
						table.insert(plot.roundRequests, { customer = customer, seat = seat })
					end
					if not customer.waiting and os.clock() >= nextRound then
						nextRound = os.clock() + Config.RoundInterval
					end
					if customer.served then
						customer.served = false
						customer.waiting = false
						nextRound = os.clock() + Config.RoundInterval
					end
					task.wait(0.5)
				end
				customer.seated = false
				if customer.bubble then
					customer.bubble:Destroy()
				end
				setSitting(rig, false)
				rig.root.CFrame = facing(plot, seat.x, seat.z, -seat.faceX, -seat.faceZ)
				local back = reversed(seat.approach)
				table.insert(back, { 2, 0 })
				walkPath(plot, rig, back, alive)
			end
			seat.occupant = nil
		else
			walkPath(plot, rig, { { sx, 0 }, { 2, 0 } }, alive)
		end
	end

	walkPath(plot, rig, { { 2, -44 }, { side * 46, -44 } }, alive)
	rig.model:Destroy()
	if plot.session == session then
		plot.present -= 1
		markDirty(plot)
	end
end

-- Funcionários -----------------------------------------------------------------------------------

local function runWaiter(plot, rig, post)
	local session = plot.session
	local function alive()
		return plot.session == session and rig.model.Parent ~= nil
	end
	while alive() do
		local request = table.remove(plot.roundRequests, 1)
		if request and request.customer.seated then
			local route = { { post[1], 0 } }
			for _, point in request.seat.approach do
				table.insert(route, point)
			end
			walkPath(plot, rig, route, alive)
			if alive() and request.customer.seated then
				task.wait(0.6)
				local customer = request.customer
				if customer.bubble then
					customer.bubble:Destroy()
					customer.bubble = nil
				end
				pay(plot, customer.rig, customer.wants)
				holdItem(customer.rig, customer.wants.color)
				customer.served = true
			elseif request.customer.waiting then
				request.customer.waiting = false
			end
			local back = reversed(route)
			table.insert(back, { post[1], post[2] })
			walkPath(plot, rig, back, alive)
			if alive() then
				rig.root.CFrame = facing(plot, post[1], post[2], 0, -1)
			end
		else
			task.wait(0.4)
		end
	end
end

local function spawnStaff(plot)
	plot.staff:ClearAllChildren()
	for role, spots in Config.StaffSpots do
		local outfit = Config.Outfits[role]
		local count = math.min(plot.items[role] or 0, #spots)
		for index = 1, count do
			local spot = spots[index]
			local rig = makeRig(plot.staff, facing(plot, spot[1], spot[2], 0, -1), {
				skin = SKINS[(index + #role) % #SKINS + 1],
				shirt = outfit.shirt,
				pants = outfit.pants,
				hat = outfit.hat,
				hatColor = outfit.hatColor or HAIRS[(index * 3) % #HAIRS + 1],
				label = outfit.label,
				tray = outfit.tray,
			})
			if role == "garcom" then
				task.spawn(runWaiter, plot, rig, spot)
			end
		end
	end
end

-- Compras e construção --------------------------------------------------------------------------

local function buildItemLevel(plot, item, level, animate)
	if item.build == nil then
		return
	end
	local folder = plot.built:FindFirstChild(item.id)
	if folder == nil then
		folder = Instance.new("Folder")
		folder.Name = item.id
		folder.Parent = plot.built
	end
	local ctx = { ownerName = if plot.owner then plot.owner.DisplayName else "" }
	local center = Vector3.zero
	local count = 0
	item.build(function(props)
		local part, label = makePart(folder, plot.origin, props)
		center += part.Position
		count += 1
		if animate then
			local finalCFrame, finalTransparency = part.CFrame, part.Transparency
			part.CFrame = finalCFrame + Vector3.new(0, 3, 0)
			part.Transparency = 1
			TweenService:Create(part, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				CFrame = finalCFrame,
				Transparency = finalTransparency,
			}):Play()
		end
		return part, label
	end, level, ctx)
	if animate and count > 0 then
		sparkle(center / count)
	end
end

local function refreshPlot(plot)
	plot.stats = computeStats(plot)
	while #plot.queues < plot.stats.stations do
		table.insert(plot.queues, {})
	end
	rebuildSeats(plot)
	updateMenuBoard(plot)
	markDirty(plot)
end

local lastBuy = {}

buyEvent.OnServerEvent:Connect(function(player, itemId)
	local plot = plotOf[player]
	local item = type(itemId) == "string" and Config.ItemById[itemId]
	if plot == nil or not plot.loaded or not item then
		return
	end
	local now = os.clock()
	if lastBuy[player] and now - lastBuy[player] < 0.2 then
		return
	end
	lastBuy[player] = now

	local status, reason = Config.purchaseStatus(item, plot.items, plot.level, plot.cash)
	if status == "money" then
		notify(player, "Falta dinheiro para " .. item.name, "erro")
		return
	elseif status ~= "ok" then
		notify(player, reason or "Não dá para comprar agora", "erro")
		return
	end

	local current = plot.items[item.id] or 0
	plot.cash -= Config.getPrice(item, current)
	plot.items[item.id] = current + 1
	updateLeaderstats(plot)
	buildItemLevel(plot, item, current + 1, true)
	refreshPlot(plot)
	if Config.StaffSpots[item.id] then
		spawnStaff(plot)
	end
	if plot.stats.autoCollect and plot.pending > 0 then
		local amount = plot.pending
		plot.pending = 0
		addCash(plot, amount)
	end
	notify(player, item.icon .. " " .. item.name .. " comprado!", "compra")
end)

local function createPlot(index)
	local x = (index - (Config.PlotCount + 1) / 2) * Config.PlotSpacing
	local origin = CFrame.new(x, 1, Config.PlotRowZ)
	local model = Instance.new("Model")
	model.Name = "Adega" .. index

	local plot = {
		origin = origin,
		model = model,
		owner = nil,
		loaded = false,
		cash = 0,
		pending = 0,
		xp = 0,
		level = 1,
		items = {},
		seats = {},
		queues = { {} },
		roundRequests = {},
		present = 0,
		session = 0,
		nextCustomer = 0,
		dirty = false,
		canSave = false,
	}
	plot.stats = computeStats(plot)

	makePart(model, origin, { name = "Terreno", size = Vector3.new(84, 1, 84), pos = Vector3.new(0, -0.5, 0), color = rgb(92, 128, 70), material = Enum.Material.Grass })

	for _, name in { "Construcoes", "Funcionarios", "Clientes" } do
		local folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = model
	end
	plot.built = model.Construcoes
	plot.staff = model.Funcionarios
	plot.customers = model.Clientes

	plot.freeSign = makePart(model, origin, {
		name = "PlacaDisponivel",
		size = Vector3.new(14, 4, 0.4),
		pos = Vector3.new(0, 5, -36),
		color = rgb(25, 22, 30),
		text = "TERRENO DISPONÍVEL",
		textColor = Config.Theme.gold,
	})

	model.Parent = workspace
	return plot
end

local function buildWorld()
	local first = plots[1].origin
	local last = plots[#plots].origin
	local width = (last.Position - first.Position).Magnitude + 84 + 40
	local center = (first.Position + last.Position) / 2
	local folder = Instance.new("Folder")
	folder.Name = "Rua"
	local base = CFrame.new(center.X, 1, Config.PlotRowZ)
	makePart(folder, base, { name = "Passeio", size = Vector3.new(width, 0.1, 4), pos = Vector3.new(0, 0.05, -44), color = rgb(170, 165, 158), material = Enum.Material.Pavement })
	makePart(folder, base, { name = "MeioFio", size = Vector3.new(width, 0.5, 0.4), pos = Vector3.new(0, 0.25, -46.2), color = rgb(220, 220, 220), material = Enum.Material.Concrete })
	makePart(folder, base, { name = "Asfalto", size = Vector3.new(width, 0.2, 18), pos = Vector3.new(0, 0.1, -55.4), color = rgb(45, 45, 50), material = Enum.Material.Asphalt })
	for offset = -width / 2 + 4, width / 2 - 4, 10 do
		makePart(folder, base, { name = "Faixa", size = Vector3.new(5, 0.05, 0.5), pos = Vector3.new(offset, 0.22, -55.4), color = rgb(250, 210, 60), material = Enum.Material.SmoothPlastic })
	end
	folder.Parent = workspace
end

local function setupBase(plot)
	plot.freeSign.Parent = nil
	local folder = Instance.new("Folder")
	folder.Name = "Base"
	folder.Parent = plot.built
	local ctx = { ownerName = plot.owner.DisplayName }
	Config.buildBase(function(props)
		return makePart(folder, plot.origin, props)
	end, ctx)

	plot.register = folder:FindFirstChild("Caixa")
	local menu = folder:FindFirstChild("Cardapio")
	plot.menuLabel = menu and menu:FindFirstChildWhichIsA("SurfaceGui"):FindFirstChildWhichIsA("TextLabel")
	if plot.menuLabel then
		plot.menuLabel.TextXAlignment = Enum.TextXAlignment.Left
	end

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Recolher dinheiro"
	prompt.ObjectText = "Caixa"
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = plot.register
	prompt.Triggered:Connect(function(player)
		collectRegister(plot, player)
	end)
end

local function resetPlot(plot)
	plot.owner = nil
	plot.loaded = false
	plot.canSave = false
	plot.session += 1
	plot.items = {}
	plot.cash, plot.pending, plot.xp, plot.level = 0, 0, 0, 1
	plot.seats = {}
	plot.queues = { {} }
	plot.roundRequests = {}
	plot.present = 0
	plot.register = nil
	plot.menuLabel = nil
	plot.built:ClearAllChildren()
	plot.staff:ClearAllChildren()
	plot.customers:ClearAllChildren()
	plot.stats = computeStats(plot)
	plot.freeSign.Parent = plot.model
end

-- Jogadores e salvamento -------------------------------------------------------------------------

local function dataKey(player)
	return "jogador_" .. player.UserId
end

local function saveData(player)
	local plot = plotOf[player]
	if store == nil or plot == nil or not plot.canSave then
		return
	end
	local data = {
		cash = math.floor(plot.cash + plot.pending),
		xp = plot.xp,
		level = plot.level,
		items = plot.items,
	}
	local ok, err = pcall(function()
		store:SetAsync(dataKey(player), data)
	end)
	if not ok then
		warn("[Adega] Falha ao salvar", player.Name, err)
	end
end

local function onPlayerAdded(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	local cashValue = Instance.new("IntValue")
	cashValue.Name = "Dinheiro"
	cashValue.Parent = leaderstats
	local levelValue = Instance.new("IntValue")
	levelValue.Name = "Nível"
	levelValue.Value = 1
	levelValue.Parent = leaderstats
	leaderstats.Parent = player

	local plot
	for _, candidate in plots do
		if candidate.owner == nil then
			plot = candidate
			break
		end
	end
	if plot == nil then
		warn("[Adega] Nenhuma adega livre para", player.Name)
		notify(player, "Servidor cheio: todas as adegas estão ocupadas.", "erro")
		return
	end
	plot.owner = player
	plot.session += 1
	plotOf[player] = plot

	local loaded, data = false, nil
	if store then
		loaded, data = pcall(function()
			return store:GetAsync(dataKey(player))
		end)
		if not loaded then
			warn("[Adega] Falha ao carregar", player.Name, data)
			data = nil
		end
	end
	if plot.owner ~= player then
		return -- o jogador saiu enquanto carregava
	end
	-- Só salva se o carregamento funcionou, para nunca apagar um progresso que não foi lido.
	plot.canSave = loaded

	plot.cash = Config.StartingCash
	plot.items = table.clone(Config.StartingItems)
	if type(data) == "table" then
		plot.cash = tonumber(data.cash) or Config.StartingCash
		plot.xp = tonumber(data.xp) or 0
		plot.level = math.clamp(tonumber(data.level) or 1, 1, Config.MaxLevel)
		if type(data.items) == "table" then
			for id, level in data.items do
				local item = Config.ItemById[id]
				if item and type(level) == "number" then
					plot.items[id] = math.clamp(math.floor(level), 0, item.maxLevel)
				end
			end
		end
	end

	setupBase(plot)
	for _, item in Config.Items do
		for level = 1, plot.items[item.id] or 0 do
			buildItemLevel(plot, item, level, false)
		end
	end
	refreshPlot(plot)
	spawnStaff(plot)
	plot.nextCustomer = os.clock() + 2
	plot.loaded = true
	updateLeaderstats(plot)
	sendState(plot)
	if data == nil then
		notify(player, "Bem-vindo! Essa adega agora é sua.", "nivel")
	end

	local function moveToPlot(character)
		if character:WaitForChild("HumanoidRootPart", 10) and plot.owner == player then
			task.wait()
			character:PivotTo(facing(plot, 0, -36, 0, 1, 4))
		end
	end
	player.CharacterAdded:Connect(moveToPlot)
	if player.Character then
		task.spawn(moveToPlot, player.Character)
	end
end

local function onPlayerRemoving(player)
	saveData(player)
	lastBuy[player] = nil
	local plot = plotOf[player]
	plotOf[player] = nil
	if plot then
		resetPlot(plot)
	end
end

for index = 1, Config.PlotCount do
	plots[index] = createPlot(index)
end
buildWorld()
print("[Adega] " .. Config.PlotCount .. " adegas criadas no Workspace")

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
for _, player in Players:GetPlayers() do
	task.spawn(onPlayerAdded, player)
end

game:BindToClose(function()
	for _, player in Players:GetPlayers() do
		saveData(player)
	end
end)

task.spawn(function()
	while true do
		task.wait(Config.AutoSaveInterval)
		for _, player in Players:GetPlayers() do
			task.spawn(saveData, player)
		end
	end
end)

-- O relógio do dia: um dia inteiro leva Config.DayLengthMinutes.
task.spawn(function()
	local hoursPerSecond = 24 / (Config.DayLengthMinutes * 60)
	local last = os.clock()
	while true do
		task.wait(0.1)
		local now = os.clock()
		Lighting.ClockTime = (Lighting.ClockTime + (now - last) * hoursPerSecond) % 24
		last = now
	end
end)

-- Chegada de clientes e envio do estado para a interface.
local lastStateSend = 0
local lastFullSend = 0
while true do
	task.wait(0.2)
	local now = os.clock()
	for _, plot in plots do
		if plot.owner and plot.loaded then
			if now >= plot.nextCustomer then
				local rate = plot.stats.cpm * nightMultiplier()
				plot.nextCustomer = now + (60 / rate) * (0.7 + math.random() * 0.6)
				if plot.present < plot.stats.capacityTotal then
					task.spawn(runCustomer, plot)
				end
			end
		end
	end
	if now - lastStateSend >= 0.25 then
		lastStateSend = now
		-- Reenvia de tempos em tempos mesmo sem mudança, para a interface que acabou de abrir.
		local force = now - lastFullSend >= 2
		if force then
			lastFullSend = now
		end
		for _, plot in plots do
			if plot.owner and plot.loaded and (plot.dirty or force) then
				sendState(plot)
			end
		end
	end
end
