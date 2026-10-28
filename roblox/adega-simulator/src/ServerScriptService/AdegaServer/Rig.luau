-- Rig: bonecos dos clientes e funcionários.
-- Usa avatares R15 com as animações padrão do Roblox. Se não der para criar o avatar,
-- cai para um boneco de blocos animado por solda. O corpo fica ancorado e é movido com
-- TweenService ao longo de caminhos calculados pelo PathfindingService.

local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local TweenService = game:GetService("TweenService")

local Rig = {}

local rgb = Color3.fromRGB

local ANIMATIONS = {
	walk = "rbxassetid://507777826",
	idle = "rbxassetid://507766388",
	sit = "rbxassetid://2506281703",
}

Rig.Skins = { rgb(255, 224, 189), rgb(234, 192, 134), rgb(198, 134, 66), rgb(141, 85, 36), rgb(96, 58, 30), rgb(250, 205, 170) }
Rig.Shirts = { rgb(230, 57, 70), rgb(29, 53, 87), rgb(42, 157, 143), rgb(244, 162, 97), rgb(250, 250, 250), rgb(25, 25, 28), rgb(255, 214, 10), rgb(120, 70, 200), rgb(0, 120, 70), rgb(240, 120, 170), rgb(90, 160, 230) }
Rig.Pants = { rgb(40, 60, 110), rgb(30, 30, 34), rgb(90, 90, 96), rgb(60, 110, 60), rgb(150, 120, 80), rgb(200, 200, 200), rgb(70, 50, 40) }
Rig.Hairs = { rgb(30, 22, 18), rgb(70, 45, 25), rgb(15, 15, 15), rgb(200, 160, 80), rgb(120, 60, 30), rgb(180, 60, 60) }

local function pick(list)
	return list[math.random(1, #list)]
end
Rig.pick = pick

function Rig.randomLook()
	local hat = pick({ "hair", "hair", "long", "long", "cap", "none", "curly" })
	return {
		skin = pick(Rig.Skins),
		shirt = pick(Rig.Shirts),
		pants = pick(Rig.Pants),
		shoes = pick({ rgb(20, 20, 20), rgb(240, 240, 240), rgb(120, 70, 40) }),
		hat = hat,
		hatColor = if hat == "cap" then pick(Rig.Shirts) else pick(Rig.Hairs),
	}
end

-- Avatar R15 base, criado uma vez e clonado para cada boneco ----------------------------------

local template = nil
local templateTried = false
local templateLoading = false

local function getTemplate()
	-- quem pedir enquanto o avatar base ainda está sendo criado espera por ele
	while templateLoading do
		task.wait(0.1)
	end
	if templateTried then
		return template
	end
	templateTried = true
	templateLoading = true
	local ok, result = pcall(function()
		local description = Instance.new("HumanoidDescription")
		return Players:CreateHumanoidModelFromDescription(description, Enum.HumanoidRigType.R15)
	end)
	if ok and result and result:FindFirstChild("HumanoidRootPart") then
		template = result
		for _, item in template:GetDescendants() do
			if item:IsA("BodyColors") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") or item:IsA("Accessory") then
				item:Destroy()
			end
		end
		local humanoid = template:FindFirstChildOfClass("Humanoid")
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		humanoid.BreakJointsOnDeath = false
		humanoid.RequiresNeck = false
		if humanoid:FindFirstChildOfClass("Animator") == nil then
			Instance.new("Animator").Parent = humanoid
		end
		for _, part in template:GetDescendants() do
			if part:IsA("BasePart") then
				part.CanCollide = false
				part.CanQuery = false
				part.CanTouch = false
				part.Massless = true
			end
		end
		template.HumanoidRootPart.Anchored = true
		template.HumanoidRootPart.Transparency = 1
	else
		warn("[Adega] Não deu para criar avatares R15, usando bonecos de blocos:", result)
	end
	templateLoading = false
	return template
end
Rig.preload = getTemplate

local SHIRT_PARTS = { UpperTorso = true, LeftUpperArm = true, RightUpperArm = true }
local PANTS_PARTS = { LowerTorso = true, LeftUpperLeg = true, LeftLowerLeg = true, RightUpperLeg = true, RightLowerLeg = true }
local SHOE_PARTS = { LeftFoot = true, RightFoot = true }

local function weld(part0, part1, c0)
	part1.Anchored = false
	part1.Massless = true
	part1.CanCollide = false
	part1.CanQuery = false
	part1.CanTouch = false
	local w = Instance.new("Weld")
	w.Part0 = part0
	w.Part1 = part1
	w.C0 = c0
	w.Parent = part1
	return w
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
Rig.newPart = newPart
Rig.weld = weld

-- Chapéus e cabelos feitos de peças, presos na cabeça.
local function addHeadwear(model, head, look, headSize)
	local hat = look.hat
	local color = look.hatColor or rgb(30, 22, 18)
	local top = headSize.Y / 2
	-- a cabeça do R6/R15 clássico é uma peça 2x1x1 com malha; a menor medida é a largura visível
	local width = math.min(headSize.X, headSize.Z) * 1.1 + 0.1
	local function add(name, size, offset, partColor, material)
		local part = newPart(name, size, partColor or color, material)
		weld(head, part, offset)
		part.Parent = model
		return part
	end
	if hat == "hair" then
		add("Cabelo", Vector3.new(width, 0.32, width), CFrame.new(0, top - 0.05, 0.03))
		add("Nuca", Vector3.new(width, 0.7, 0.25), CFrame.new(0, top - 0.45, headSize.Z / 2))
	elseif hat == "curly" then
		add("Cabelo", Vector3.new(width + 0.3, width * 0.7, width + 0.3), CFrame.new(0, top + 0.05, 0.08), nil, Enum.Material.Fabric).Shape = Enum.PartType.Ball
	elseif hat == "long" then
		add("Cabelo", Vector3.new(width, 0.32, width), CFrame.new(0, top - 0.05, 0.03))
		add("CabeloLongo", Vector3.new(width, 1.7, 0.3), CFrame.new(0, top - 1.1, headSize.Z / 2 + 0.05))
	elseif hat == "cap" then
		add("Bone", Vector3.new(width, 0.42, width), CFrame.new(0, top + 0.05, 0))
		add("Aba", Vector3.new(width - 0.1, 0.1, 0.7), CFrame.new(0, top - 0.1, -width / 2 - 0.3))
	elseif hat == "chef" then
		add("Touca", Vector3.new(width - 0.1, 0.9, width - 0.1), CFrame.new(0, top + 0.4, 0), rgb(250, 250, 250))
	elseif hat == "headphones" then
		add("Fone", Vector3.new(width + 0.3, 0.2, 0.3), CFrame.new(0, top + 0.05, 0), rgb(20, 20, 20))
		for _, x in { -1, 1 } do
			add("Concha", Vector3.new(0.3, 0.6, 0.6), CFrame.new(x * (width / 2 + 0.1), 0, 0), look.shirt, Enum.Material.Neon)
		end
	end
end

-- Boneco de blocos (plano B) ---------------------------------------------------------------------

local LIMBS = {
	LeftArm = { pivot = Vector3.new(-1.5, 0.5, 0), hang = Vector3.new(0, -0.5, 0) },
	RightArm = { pivot = Vector3.new(1.5, 0.5, 0), hang = Vector3.new(0, -0.5, 0) },
	LeftLeg = { pivot = Vector3.new(-0.5, -1, 0), hang = Vector3.new(0, -1, 0) },
	RightLeg = { pivot = Vector3.new(0.5, -1, 0), hang = Vector3.new(0, -1, 0) },
}

local function limbC0(name, angle)
	local def = LIMBS[name]
	return CFrame.new(def.pivot) * CFrame.Angles(angle, 0, 0) * CFrame.new(def.hang)
end

local function buildBlocky(model, look)
	local root = newPart("HumanoidRootPart", Vector3.new(2, 2, 1), look.shirt)
	root.Anchored = true
	root.CanCollide = false
	root.CanQuery = false
	root.CanTouch = false
	root.Parent = model
	local head = newPart("Head", Vector3.new(1.2, 1.2, 1.2), look.skin)
	weld(root, head, CFrame.new(0, 1.6, 0))
	local face = Instance.new("Decal")
	face.Texture = "rbxasset://textures/face.png"
	face.Parent = head
	head.Parent = model
	local welds = {}
	for name in LIMBS do
		local isArm = name == "LeftArm" or name == "RightArm"
		local limb = newPart(name, Vector3.new(1, 2, 1), if isArm then look.skin else look.pants)
		welds[name] = weld(root, limb, limbC0(name, 0))
		limb.Parent = model
		if isArm then
			local sleeve = newPart("Manga", Vector3.new(1.05, 0.8, 1.05), look.shirt)
			weld(limb, sleeve, CFrame.new(0, 0.62, 0))
			sleeve.Parent = model
		end
	end
	return root, head, welds
end

-- API --------------------------------------------------------------------------------------------

-- Cria um boneco em pé em `feet` (posição do chão), olhando para `lookDir`.
function Rig.new(parent, feet, lookDir, look, name)
	local base = getTemplate()
	local model
	local rig = { look = look, pose = nil, tracks = {}, alive = true }

	if base then
		model = base:Clone()
		for _, part in model:GetDescendants() do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				if SHIRT_PARTS[part.Name] then
					part.Color = look.shirt
				elseif PANTS_PARTS[part.Name] then
					part.Color = look.pants
				elseif SHOE_PARTS[part.Name] then
					part.Color = look.shoes or rgb(25, 25, 25)
				else
					part.Color = look.skin
				end
			end
		end
		rig.root = model.HumanoidRootPart
		rig.head = model:FindFirstChild("Head")
		rig.hand = model:FindFirstChild("RightHand")
		rig.humanoid = model:FindFirstChildOfClass("Humanoid")
		rig.standOffset = rig.humanoid.HipHeight + rig.root.Size.Y / 2
		rig.sitOffset = rig.root.Size.Y / 2 + 0.55
		rig.isR15 = true
	else
		model = Instance.new("Model")
		local root, head, welds = buildBlocky(model, look)
		rig.root = root
		rig.head = head
		rig.welds = welds
		rig.hand = welds.RightArm.Part1
		rig.standOffset = 3.05
		rig.sitOffset = 1.5
		rig.isR15 = false
		rig.anims = {}
	end
	model.Name = name or "Cliente"
	model.PrimaryPart = rig.root
	rig.model = model
	addHeadwear(model, rig.head, look, rig.head.Size)

	rig.root.CFrame = CFrame.lookAt(feet + Vector3.new(0, rig.standOffset, 0), feet + Vector3.new(lookDir.X, rig.standOffset, lookDir.Z))
	model.Parent = parent

	if rig.isR15 then
		local animator = rig.humanoid:FindFirstChildOfClass("Animator")
		for key, id in ANIMATIONS do
			local animation = Instance.new("Animation")
			animation.AnimationId = id
			local ok, track = pcall(function()
				return animator:LoadAnimation(animation)
			end)
			if ok and track then
				track.Looped = true
				track.Priority = if key == "idle" then Enum.AnimationPriority.Idle else Enum.AnimationPriority.Movement
				rig.tracks[key] = track
			end
		end
	end
	Rig.setPose(rig, "idle")
	return rig
end

function Rig.isAlive(rig)
	return rig.alive and rig.model.Parent ~= nil
end

function Rig.destroy(rig)
	rig.alive = false
	rig.model:Destroy()
end

function Rig.feet(rig)
	return rig.root.Position - Vector3.new(0, rig.standOffset, 0)
end

local function setBlockyPose(rig, pose)
	for _, tween in rig.anims do
		tween:Cancel()
	end
	table.clear(rig.anims)
	for name, w in rig.welds do
		if name == "RightArm" and rig.held then
			continue
		end
		if pose == "walk" then
			local sign = if name == "LeftLeg" or name == "RightArm" then 1 else -1
			w.C0 = limbC0(name, math.rad(28) * sign)
			local tween = TweenService:Create(w, TweenInfo.new(0.32, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { C0 = limbC0(name, math.rad(-28) * sign) })
			tween:Play()
			table.insert(rig.anims, tween)
		elseif pose == "sit" and (name == "LeftLeg" or name == "RightLeg") then
			w.C0 = limbC0(name, math.rad(90))
		else
			w.C0 = limbC0(name, 0)
		end
	end
end

function Rig.setPose(rig, pose)
	if rig.pose == pose then
		return
	end
	rig.pose = pose
	if rig.isR15 then
		for key, track in rig.tracks do
			if key == pose then
				if not track.IsPlaying then
					track:Play(0.15)
				end
			elseif track.IsPlaying then
				track:Stop(0.15)
			end
		end
	else
		setBlockyPose(rig, pose)
	end
end

function Rig.face(rig, direction)
	local position = rig.root.Position
	local flat = Vector3.new(direction.X, 0, direction.Z)
	if flat.Magnitude > 0.01 then
		rig.root.CFrame = CFrame.lookAt(position, position + flat)
	end
end

function Rig.sit(rig, seatPosition, faceDir, seatHeight)
	local position = seatPosition + Vector3.new(0, seatHeight + rig.sitOffset, 0)
	rig.root.CFrame = CFrame.lookAt(position, position + Vector3.new(faceDir.X, 0, faceDir.Z))
	Rig.setPose(rig, "sit")
end

function Rig.stand(rig, feet, faceDir)
	local position = feet + Vector3.new(0, rig.standOffset, 0)
	rig.root.CFrame = CFrame.lookAt(position, position + Vector3.new(faceDir.X, 0, faceDir.Z))
	Rig.setPose(rig, "idle")
end

-- Segura um modelo (bebida, bandeja) na mão direita.
function Rig.hold(rig, model)
	Rig.drop(rig)
	if model == nil or rig.hand == nil then
		return
	end
	local offset = if rig.isR15 then CFrame.new(0, -0.35, -0.45) else CFrame.new(0, -1.1, -0.35)
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = false
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Massless = true
		end
	end
	local primary = model.PrimaryPart
	local w = Instance.new("Weld")
	w.Part0 = rig.hand
	w.Part1 = primary
	w.C0 = offset
	w.Parent = primary
	model.Parent = rig.model
	rig.held = model
	if not rig.isR15 then
		rig.welds.RightArm.C0 = limbC0("RightArm", math.rad(55))
	end
end

function Rig.drop(rig)
	if rig.held then
		rig.held:Destroy()
		rig.held = nil
	end
end

-- Caminhos ----------------------------------------------------------------------------------------

local AGENT = { AgentRadius = 1.2, AgentHeight = 5, AgentCanJump = false, AgentCanClimb = false, WaypointSpacing = 5 }
local OFFSETS = {}
for i = 0, 7 do
	local angle = i * math.pi / 4
	table.insert(OFFSETS, Vector3.new(math.cos(angle), 0, math.sin(angle)))
end

local function compute(from, to)
	local path = PathfindingService:CreatePath(AGENT)
	local ok = pcall(function()
		path:ComputeAsync(from, to)
	end)
	if ok and path.Status == Enum.PathStatus.Success then
		return path:GetWaypoints()
	end
	return nil
end

-- Acha um caminho do ponto `from` até `to`. Se o destino ou a saída estiverem colados num
-- móvel, tenta pontos vizinhos e completa o trecho final em linha reta.
function Rig.findPath(from, to)
	local points = compute(from, to)
	if points then
		return points, nil, nil
	end
	local starts = { from }
	for _, offset in OFFSETS do
		table.insert(starts, from + offset * 2.6)
	end
	local goals = { to }
	for _, radius in { 2, 3.2 } do
		for _, offset in OFFSETS do
			table.insert(goals, to + offset * radius)
		end
	end
	-- 1) destino ao lado do original
	for gi = 2, #goals do
		local found = compute(from, goals[gi])
		if found then
			return found, nil, to
		end
	end
	-- 2) saída ao lado da original (quem está sentado colado na mesa)
	for si = 2, #starts do
		local found = compute(starts[si], to)
		if found then
			return found, starts[si], nil
		end
	end
	-- 3) os dois ajustados, só com os vizinhos mais próximos
	for si = 2, #starts, 2 do
		for gi = 2, 9, 2 do
			local found = compute(starts[si], goals[gi])
			if found then
				return found, starts[si], to
			end
		end
	end
	return nil, nil, nil
end

local function stepTo(rig, target, speed)
	local from = rig.root.Position
	local destination = target + Vector3.new(0, rig.standOffset, 0)
	local flat = Vector3.new(destination.X - from.X, 0, destination.Z - from.Z)
	local distance = (destination - from).Magnitude
	if distance < 0.15 then
		return
	end
	local look = if flat.Magnitude > 0.05 then CFrame.lookAt(from, from + flat) else rig.root.CFrame
	rig.root.CFrame = look
	local duration = distance / speed
	TweenService:Create(rig.root, TweenInfo.new(duration, Enum.EasingStyle.Linear), { CFrame = look.Rotation + destination }):Play()
	task.wait(duration)
end

-- Anda até `target` (posição do chão). Devolve true se chegou.
-- Com approach = true, para ao lado do destino quando ele está dentro de um móvel (uma mesa).
function Rig.walkTo(rig, target, speed, alive, approach)
	alive = alive or function()
		return true
	end
	local from = Rig.feet(rig)
	if (from - target).Magnitude < 0.3 then
		return true
	end
	local waypoints, startFix, endFix = Rig.findPath(from, target)
	if waypoints == nil then
		return false
	end
	if approach then
		endFix = nil
	end
	Rig.setPose(rig, "walk")
	if rig.tracks.walk then
		rig.tracks.walk:AdjustSpeed(speed / 12)
	end
	if startFix then
		stepTo(rig, startFix, speed)
	end
	for index, waypoint in waypoints do
		if not (Rig.isAlive(rig) and alive()) then
			break
		end
		if index > 1 or (waypoint.Position - Rig.feet(rig)).Magnitude > 0.5 then
			stepTo(rig, waypoint.Position, speed)
		end
	end
	if endFix and Rig.isAlive(rig) and alive() then
		stepTo(rig, endFix, speed)
	end
	if Rig.isAlive(rig) then
		Rig.setPose(rig, "idle")
	end
	return Rig.isAlive(rig) and alive()
end

-- Anda em linha reta, sem calcular caminho (trechos curtos, como sentar e levantar).
function Rig.slide(rig, target, speed)
	Rig.setPose(rig, "walk")
	stepTo(rig, target, speed)
	Rig.setPose(rig, "idle")
end

return Rig
