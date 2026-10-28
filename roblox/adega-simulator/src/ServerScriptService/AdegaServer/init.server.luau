-- AdegaServer (Script em ServerScriptService, com os módulos Data, Plot, Props, Restaurant, Rig e Staff dentro)
-- Liga tudo: mundo, iluminação, relógio, terrenos, jogadores, economia, missões e as ações da interface.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

print("[Adega] Servidor iniciando…")

local Shared = ReplicatedStorage:WaitForChild("AdegaShared", 15)
if Shared == nil then
	error("[Adega] Não achei a pasta AdegaShared dentro do ReplicatedStorage. Veja o README para instalar.")
end
local Config = require(Shared.Config)
local Catalog = require(Shared.Catalog)
local Util = require(Shared.Util)

local Data = require(script.Data)
local Plot = require(script.Plot)
local Props = require(script.Props)
local Restaurant = require(script.Restaurant)
local Rig = require(script.Rig)
local Staff = require(script.Staff)

local rgb = Color3.fromRGB
local formatMoney = Util.formatMoney

Data.init(Config.DataStoreName)
task.spawn(Rig.preload)

-- Comunicação com a interface -----------------------------------------------------------------------

local old = ReplicatedStorage:FindFirstChild("AdegaRemotes")
if old then
	old:Destroy()
end
local remotes = Instance.new("Folder")
remotes.Name = "AdegaRemotes"
local stateEvent = Instance.new("RemoteEvent")
stateEvent.Name = "Estado"
stateEvent.Parent = remotes
local noticeEvent = Instance.new("RemoteEvent")
noticeEvent.Name = "Aviso"
noticeEvent.Parent = remotes
local actionFunction = Instance.new("RemoteFunction")
actionFunction.Name = "Acao"
actionFunction.Parent = remotes
remotes.Parent = ReplicatedStorage

local function notify(player, text, kind, extra)
	if player and player.Parent then
		noticeEvent:FireClient(player, text, kind or "info", extra)
	end
end

-- Iluminação e relógio --------------------------------------------------------------------------------

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

Lighting.ClockTime = 16.5
Lighting.Brightness = 2
Lighting.EnvironmentDiffuseScale = 1
Lighting.EnvironmentSpecularScale = 0.4
Lighting.OutdoorAmbient = rgb(118, 104, 136)
Lighting.Ambient = rgb(40, 34, 56)
Lighting.ShadowSoftness = 0.3
ensureEffect("Atmosphere", "AdegaAtmosfera", { Density = 0.3, Offset = 0.15, Color = rgb(205, 175, 220), Decay = rgb(92, 62, 140), Glare = 0.35, Haze = 1.4 })
ensureEffect("BloomEffect", "AdegaBrilho", { Intensity = 0.45, Size = 22, Threshold = 1.6 })
ensureEffect("ColorCorrectionEffect", "AdegaCor", { Saturation = 0.12, Contrast = 0.05, Brightness = -0.03, TintColor = rgb(255, 247, 240) })
ensureEffect("SunRaysEffect", "AdegaRaios", { Intensity = 0.05, Spread = 0.6 })
ensureEffect("DepthOfFieldEffect", "AdegaFoco", { FarIntensity = 0.12, FocusDistance = 80, InFocusRadius = 70, NearIntensity = 0 })

-- Mundo: chão, rua, calçada, postes e prédios do outro lado ------------------------------------------

local world = Instance.new("Folder")
world.Name = "AdegaMundo"
world.Parent = workspace

local function worldPart(props)
	local part = Instance.new("Part")
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Material = Enum.Material.SmoothPlastic
	for key, value in props do
		part[key] = value
	end
	part.Parent = world
	return part
end

local totalWidth = Config.PlotCount * Config.PlotSpacing + 160
local front = Config.PlotFrontZ
if workspace:FindFirstChild("Baseplate") == nil then
	worldPart({ Name = "Chao", Size = Vector3.new(totalWidth + 400, 2, 700), Position = Vector3.new(0, -1, front), Color = rgb(80, 120, 60), Material = Enum.Material.Grass })
end
worldPart({ Name = "Calcada", Size = Vector3.new(totalWidth, 0.5, 8), Position = Vector3.new(0, 0.25, front - 4), Color = rgb(176, 170, 162), Material = Enum.Material.Pavement })
worldPart({ Name = "MeioFio", Size = Vector3.new(totalWidth, 0.55, 0.5), Position = Vector3.new(0, 0.27, front - 8.25), Color = rgb(225, 225, 225), Material = Enum.Material.Concrete })
worldPart({ Name = "Asfalto", Size = Vector3.new(totalWidth, 0.3, 20), Position = Vector3.new(0, 0.15, front - 18.5), Color = rgb(42, 42, 48), Material = Enum.Material.Asphalt })
worldPart({ Name = "CalcadaFrente", Size = Vector3.new(totalWidth, 0.5, 8), Position = Vector3.new(0, 0.25, front - 32.5), Color = rgb(176, 170, 162), Material = Enum.Material.Pavement })
for x = -totalWidth / 2 + 6, totalWidth / 2 - 6, 12 do
	worldPart({ Name = "Faixa", Size = Vector3.new(6, 0.05, 0.5), Position = Vector3.new(x, 0.32, front - 18.5), Color = rgb(250, 210, 60), CanCollide = false })
end
for x = -totalWidth / 2 + 20, totalWidth / 2 - 20, 40 do
	worldPart({ Name = "Poste", Size = Vector3.new(0.5, 16, 0.5), Position = Vector3.new(x, 8, front - 30), Color = rgb(50, 50, 56), Material = Enum.Material.Metal })
	worldPart({ Name = "BracoPoste", Size = Vector3.new(0.4, 0.4, 4), Position = Vector3.new(x, 16, front - 28.2), Color = rgb(50, 50, 56), Material = Enum.Material.Metal })
	local lamp = worldPart({ Name = "Luminaria", Size = Vector3.new(1.2, 0.4, 1.8), Position = Vector3.new(x, 15.7, front - 26.6), Color = rgb(255, 220, 160), Material = Enum.Material.Neon })
	local light = Instance.new("PointLight")
	light.Color = rgb(255, 205, 150)
	light.Range = 34
	light.Brightness = 1.4
	light.Parent = lamp
end

local BUILDING_COLORS = { rgb(214, 112, 90), rgb(240, 200, 120), rgb(120, 170, 200), rgb(200, 200, 190), rgb(160, 120, 180), rgb(110, 160, 120), rgb(230, 150, 170), rgb(180, 160, 130) }
local random = Random.new(7)
local x = -totalWidth / 2 + 14
while x < totalWidth / 2 - 14 do
	local width = random:NextInteger(18, 28)
	local height = random:NextInteger(16, 40)
	local depth = 18
	local center = Vector3.new(x + width / 2, height / 2, front - 37 - depth / 2)
	worldPart({ Name = "Predio", Size = Vector3.new(width, height, depth), Position = center, Color = BUILDING_COLORS[random:NextInteger(1, #BUILDING_COLORS)], Material = Enum.Material.Concrete })
	worldPart({ Name = "Topo", Size = Vector3.new(width + 0.6, 0.8, depth + 0.6), Position = center + Vector3.new(0, height / 2 + 0.4, 0), Color = rgb(70, 70, 76), Material = Enum.Material.Concrete })
	for wy = 4, height - 4, 6 do
		for wx = -width / 2 + 3, width / 2 - 3, 4.5 do
			local lit = random:NextNumber() < 0.55
			worldPart({
				Name = "Janela",
				Size = Vector3.new(2.4, 3, 0.2),
				Position = Vector3.new(center.X + wx, wy, center.Z + depth / 2 + 0.1),
				Color = if lit then rgb(255, 214, 140) else rgb(40, 50, 70),
				Material = if lit then Enum.Material.Neon else Enum.Material.Glass,
				CanCollide = false,
			})
		end
	end
	x += width + random:NextInteger(1, 4)
end

task.spawn(function()
	local hoursPerSecond = 24 / (Config.DayLengthMinutes * 60)
	local last = os.clock()
	while true do
		task.wait(0.1)
		local t = os.clock()
		Lighting.ClockTime = (Lighting.ClockTime + (t - last) * hoursPerSecond) % 24
		last = t
	end
end)

-- Terrenos e jogadores --------------------------------------------------------------------------------

local plots = {}
local plotOf = {}
for index = 1, Config.PlotCount do
	plots[index] = Plot.new(index)
end
print("[Adega] " .. Config.PlotCount .. " terrenos criados")

local function leaderstat(player, name, className)
	local stats = player:FindFirstChild("leaderstats")
	return stats and stats:FindFirstChild(name)
end

local function updateLeaderstats(plot)
	local player = plot.owner
	if player == nil then
		return
	end
	local cash = leaderstat(player, "Dinheiro")
	if cash then
		cash.Value = math.floor(plot.cash)
	end
	local level = leaderstat(player, "Nível")
	if level then
		level.Value = plot.level
	end
	local rating = leaderstat(player, "Avaliação")
	if rating and plot.rt then
		rating.Value = Util.formatDecimal(Restaurant.rating(plot)) .. " ★"
	end
end

local function markDirty(plot)
	plot.dirty = true
end

-- Missões -----------------------------------------------------------------------------------------

local function currentQuest(plot)
	return Config.Quests[plot.questIndex]
end

local completeQuestIfReady

local function questInstantCheck(plot)
	local quest = currentQuest(plot)
	if quest == nil then
		return
	end
	if quest.event == "rating4" and plot.rt and #plot.rt.ratings >= 10 and Restaurant.rating(plot) >= 4 then
		plot.questProgress = quest.target
	elseif quest.event == "level15" and plot.level >= 15 then
		plot.questProgress = quest.target
	elseif quest.event == "staffCount8" and #plot.staff >= 8 then
		plot.questProgress = quest.target
	end
	completeQuestIfReady(plot)
end

local function addCash(plot, amount)
	plot.cash += amount
	updateLeaderstats(plot)
	markDirty(plot)
end

completeQuestIfReady = function(plot)
	local quest = currentQuest(plot)
	if quest == nil or plot.questProgress < quest.target then
		return
	end
	addCash(plot, quest.reward)
	notify(plot.owner, "Missão cumprida: " .. quest.text .. " (+" .. formatMoney(quest.reward) .. ")", "missao")
	plot.questIndex += 1
	plot.questProgress = 0
	markDirty(plot)
	questInstantCheck(plot)
end

local function questEvent(plot, name, amount)
	local quest = currentQuest(plot)
	if quest and quest.event == name then
		plot.questProgress += amount or 1
		markDirty(plot)
		completeQuestIfReady(plot)
	end
end

-- Dinheiro e experiência ----------------------------------------------------------------------------

local function addXp(plot, amount)
	plot.xp += amount
	while plot.level < Config.MaxLevel and plot.xp >= Config.xpForLevel(plot.level) do
		plot.xp -= Config.xpForLevel(plot.level)
		plot.level += 1
		notify(plot.owner, "Sua adega chegou ao nível " .. plot.level .. "!", "nivel", { level = plot.level })
		Props.sparkle(plot:toWorld(0, 4, 8), rgb(200, 120, 255))
		questInstantCheck(plot)
	end
	updateLeaderstats(plot)
	markDirty(plot)
end

local function earn(plot, amount, position)
	addCash(plot, amount)
	addXp(plot, amount)
	plot.day.earned += amount
	if position then
		Props.popup(position + Vector3.new(0, 2, 0), "+" .. formatMoney(amount), rgb(110, 255, 140))
	end
end

-- Salvamento --------------------------------------------------------------------------------------

local function serialize(plot)
	local staff = {}
	for _, member in plot.staff do
		table.insert(staff, { role = member.role.id, name = member.name, level = member.level })
	end
	return {
		version = 3,
		cash = math.floor(plot.cash),
		xp = plot.xp,
		level = plot.level,
		sizeLevel = plot.sizeLevel,
		floor = plot.style.floor,
		wall = plot.style.wall,
		ownedFloors = plot.ownedFloors,
		ownedWalls = plot.ownedWalls,
		furniture = plot:serialize(),
		staff = staff,
		ratings = if plot.rt then plot.rt.ratings else {},
		questIndex = plot.questIndex,
		questProgress = plot.questProgress,
		totalServed = plot.totalServed,
	}
end

local function save(player)
	local plot = plotOf[player]
	if plot and plot.canSave then
		Data.save(player.UserId, serialize(plot))
	end
end

-- Entrada e saída ---------------------------------------------------------------------------------

local nextStaffId = 1
local function spawnStaff(plot, entry)
	local data = { id = nextStaffId, role = entry.role, name = entry.name, level = entry.level }
	nextStaffId += 1
	return Staff.spawn(plot, data)
end

local function moveToPlot(player, plot)
	local character = player.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		local spot = plot:toWorld(0, -4, 3)
		character:PivotTo(CFrame.lookAt(spot, spot + Vector3.new(0, 0, 1)))
	end
end

local function onPlayerAdded(player)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	local cash = Instance.new("IntValue")
	cash.Name = "Dinheiro"
	cash.Parent = stats
	local level = Instance.new("IntValue")
	level.Name = "Nível"
	level.Value = 1
	level.Parent = stats
	local rating = Instance.new("StringValue")
	rating.Name = "Avaliação"
	rating.Value = "3,0 ★"
	rating.Parent = stats
	stats.Parent = player

	local plot = nil
	for _, candidate in plots do
		if candidate.owner == nil and not candidate.loading then
			plot = candidate
			break
		end
	end
	if plot == nil then
		notify(player, "Servidor cheio: todas as adegas estão ocupadas. Visite as outras!", "erro")
		return
	end
	plot.loading = true
	plotOf[player] = plot

	local loaded, saved = Data.load(player.UserId)
	if player.Parent == nil then
		plot.loading = false
		plotOf[player] = nil
		return
	end
	if type(saved) ~= "table" or saved.version ~= 3 then
		saved = nil
	end

	plot.canSave = loaded
	plot.cash = if saved then tonumber(saved.cash) or Config.StartingCash else Config.StartingCash
	plot.xp = if saved then tonumber(saved.xp) or 0 else 0
	plot.level = if saved then math.clamp(tonumber(saved.level) or 1, 1, Config.MaxLevel) else 1
	plot.questIndex = if saved then tonumber(saved.questIndex) or 1 else 1
	plot.questProgress = if saved then tonumber(saved.questProgress) or 0 else 0
	plot.totalServed = if saved then tonumber(saved.totalServed) or 0 else 0
	plot.ownedFloors = if saved and type(saved.ownedFloors) == "table" then saved.ownedFloors else { cimento = true }
	plot.ownedWalls = if saved and type(saved.ownedWalls) == "table" then saved.ownedWalls else { branco = true }
	plot.day = { served = 0, earned = 0, reviews = 0, stars = 0 }
	plot.staff = {}

	plot:claim(player, saved)
	plot.loading = false
	Restaurant.setup(plot, {
		earn = function(amount, position)
			earn(plot, amount, position)
		end,
		event = function(name, amount)
			if name == "served" then
				plot.totalServed += amount
				plot.day.served += amount
			end
			questEvent(plot, name, amount)
		end,
		notify = function(text, kind)
			notify(player, text, kind)
		end,
		review = function(stars)
			plot.day.reviews += 1
			plot.day.stars += stars
			updateLeaderstats(plot)
			questInstantCheck(plot)
		end,
	}, saved)

	if saved and type(saved.staff) == "table" then
		for _, entry in saved.staff do
			if type(entry) == "table" and Config.staffById(entry.role) then
				spawnStaff(plot, entry)
			end
		end
	end

	updateLeaderstats(plot)
	markDirty(plot)

	player.CharacterAdded:Connect(function(character)
		character:WaitForChild("HumanoidRootPart", 10)
		task.wait(0.1)
		if plot.owner == player then
			moveToPlot(player, plot)
			Restaurant.updateTray(plot)
		end
	end)
	player.CharacterRemoving:Connect(function()
		if plot.owner == player then
			Restaurant.dropCarry(plot)
		end
	end)
	if player.Character then
		task.spawn(moveToPlot, player, plot)
	end
	if saved == nil then
		notify(player, "Bem-vindo! Essa adega agora é sua. Siga as missões para começar.", "nivel")
	end
	questInstantCheck(plot)
end

local function onPlayerRemoving(player)
	save(player)
	local plot = plotOf[player]
	plotOf[player] = nil
	if plot and plot.owner == player then
		Staff.clear(plot)
		Restaurant.teardown(plot)
		plot:release()
		plot.canSave = false
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
for _, player in Players:GetPlayers() do
	task.spawn(onPlayerAdded, player)
end

game:BindToClose(function()
	for _, player in Players:GetPlayers() do
		task.spawn(save, player)
	end
	task.wait(3)
end)

task.spawn(function()
	while true do
		task.wait(Config.AutoSaveInterval)
		for _, player in Players:GetPlayers() do
			task.spawn(save, player)
		end
	end
end)

-- Ações da interface --------------------------------------------------------------------------------

local function result(ok, message)
	return { ok = ok, msg = message }
end

local function unusedName(plot)
	local used = {}
	for _, member in plot.staff do
		used[member.name] = true
	end
	local options = {}
	for _, name in Config.StaffNames do
		if not used[name] then
			table.insert(options, name)
		end
	end
	if #options == 0 then
		return Config.StaffNames[math.random(1, #Config.StaffNames)] .. " " .. math.random(2, 9)
	end
	return options[math.random(1, #options)]
end

local function findStaff(plot, id)
	for _, member in plot.staff do
		if member.id == id then
			return member
		end
	end
	return nil
end

local actions = {}

function actions.colocar(player, plot, payload)
	local item = Catalog.ById[payload.id]
	if item == nil or type(payload.x) ~= "number" or type(payload.z) ~= "number" or type(payload.r) ~= "number" then
		return result(false, "Item inválido")
	end
	local rotation = math.floor(payload.r) % 4
	local w, d = Catalog.footprint(item, rotation)
	local x = Catalog.snap(payload.x, w)
	local z = Catalog.snap(payload.z, d)
	local ok, reason = plot:canPlace(item, x, z, rotation, nil, plot.level)
	if not ok then
		return result(false, reason)
	end
	if plot.cash < item.price then
		return result(false, "Falta dinheiro: " .. formatMoney(item.price))
	end
	addCash(plot, -item.price)
	plot:place(item.id, x, z, rotation, true)
	if item.kind == "seating" then
		questEvent(plot, "placeSeating", 1)
	end
	questEvent(plot, "place_" .. item.id, 1)
	return result(true, nil)
end

function actions.mover(player, plot, payload)
	local rec = plot.furniture[payload.uid]
	if rec == nil or type(payload.x) ~= "number" or type(payload.z) ~= "number" or type(payload.r) ~= "number" then
		return result(false, "Móvel não encontrado")
	end
	local canModify, why = Restaurant.canModify(plot, rec)
	if not canModify then
		return result(false, why)
	end
	local item = rec.item
	local rotation = math.floor(payload.r) % 4
	local w, d = Catalog.footprint(item, rotation)
	local x = Catalog.snap(payload.x, w)
	local z = Catalog.snap(payload.z, d)
	local ok, reason = plot:canPlace(item, x, z, rotation, rec.uid, nil)
	if not ok then
		return result(false, reason)
	end
	plot:remove(rec.uid)
	plot:place(item.id, x, z, rotation, true)
	return result(true, nil)
end

function actions.vender(player, plot, payload)
	local rec = plot.furniture[payload.uid]
	if rec == nil then
		return result(false, "Móvel não encontrado")
	end
	local canModify, why = Restaurant.canModify(plot, rec)
	if not canModify then
		return result(false, why)
	end
	local refund = math.floor(rec.item.price * Config.SellRefund)
	plot:remove(rec.uid)
	addCash(plot, refund)
	return result(true, "Vendido por " .. formatMoney(refund))
end

function actions.contratar(player, plot, payload)
	local role = Config.staffById(payload.role)
	if role == nil then
		return result(false, "Função inválida")
	end
	if plot.level < role.level then
		return result(false, "Libera no nível " .. role.level)
	end
	if #plot.staff >= Config.maxStaff(plot.level) then
		return result(false, "Limite de funcionários do seu nível. Suba de nível para contratar mais.")
	end
	if plot.cash < role.hire then
		return result(false, "Falta dinheiro: " .. formatMoney(role.hire))
	end
	addCash(plot, -role.hire)
	local member = spawnStaff(plot, { role = role.id, name = unusedName(plot), level = 1 })
	questEvent(plot, "hire_" .. role.id, 1)
	questInstantCheck(plot)
	markDirty(plot)
	return result(true, member and (member.name .. " foi contratado como " .. role.name) or nil)
end

function actions.treinar(player, plot, payload)
	local member = findStaff(plot, payload.id)
	if member == nil then
		return result(false, "Funcionário não encontrado")
	end
	if member.level >= Config.StaffMaxLevel then
		return result(false, "Já está no nível máximo")
	end
	local price = Config.trainPrice(member.role, member.level)
	if plot.cash < price then
		return result(false, "Falta dinheiro: " .. formatMoney(price))
	end
	addCash(plot, -price)
	member.level += 1
	Staff.updateTag(member)
	Props.sparkle(member.rig.root.Position, rgb(120, 200, 255))
	markDirty(plot)
	return result(true, member.name .. " agora está no nível " .. member.level)
end

function actions.demitir(player, plot, payload)
	local member = findStaff(plot, payload.id)
	if member == nil then
		return result(false, "Funcionário não encontrado")
	end
	Staff.remove(plot, member)
	markDirty(plot)
	return result(true, member.name .. " foi demitido")
end

function actions.expandir(player, plot)
	local nextSize = Config.PlotSizes[plot.sizeLevel + 1]
	if nextSize == nil then
		return result(false, "Seu terreno já está no tamanho máximo")
	end
	if plot.level < nextSize.level then
		return result(false, "Libera no nível " .. nextSize.level)
	end
	if plot.cash < nextSize.price then
		return result(false, "Falta dinheiro: " .. formatMoney(nextSize.price))
	end
	addCash(plot, -nextSize.price)
	plot.sizeLevel += 1
	plot.size = nextSize.size
	plot:applySize()
	Props.sparkle(plot:toWorld(0, plot.size / 2, 3))
	questEvent(plot, "expand", 1)
	markDirty(plot)
	return result(true, "Terreno ampliado para " .. nextSize.size .. " x " .. nextSize.size)
end

function actions.estilo(player, plot, payload)
	local list = if payload.kind == "floor" then Config.Floors elseif payload.kind == "wall" then Config.WallColors else nil
	local owned = if payload.kind == "floor" then plot.ownedFloors else plot.ownedWalls
	local option = list and Config.findById(list, payload.id)
	if option == nil then
		return result(false, "Opção inválida")
	end
	if not owned[option.id] then
		if plot.cash < option.price then
			return result(false, "Falta dinheiro: " .. formatMoney(option.price))
		end
		addCash(plot, -option.price)
		owned[option.id] = true
	end
	if payload.kind == "floor" then
		plot.style.floor = option.id
	else
		plot.style.wall = option.id
	end
	plot:applyStyle()
	questEvent(plot, "style", 1)
	markDirty(plot)
	return result(true, nil)
end

function actions.voltar(player, plot)
	moveToPlot(player, plot)
	return result(true, nil)
end

local lastAction = {}
actionFunction.OnServerInvoke = function(player, action, payload)
	local plot = plotOf[player]
	if plot == nil or plot.owner ~= player or plot.rt == nil then
		return result(false, "Sua adega ainda está carregando")
	end
	local handler = type(action) == "string" and actions[action]
	if handler == nil then
		return result(false, "Ação desconhecida")
	end
	local t = os.clock()
	if lastAction[player] and t - lastAction[player] < 0.12 then
		return result(false, "Calma!")
	end
	lastAction[player] = t
	if type(payload) ~= "table" then
		payload = {}
	end
	local ok, response = pcall(handler, player, plot, payload)
	if not ok then
		warn("[Adega] Erro na ação", action, response)
		return result(false, "Algo deu errado")
	end
	markDirty(plot)
	return response
end

-- Estado para a interface ---------------------------------------------------------------------------

local function buildState(plot)
	local snapshot = Restaurant.snapshot(plot)
	local staff = {}
	for _, member in plot.staff do
		table.insert(staff, {
			id = member.id,
			role = member.role.id,
			name = member.name,
			level = member.level,
			train = if member.level < Config.StaffMaxLevel then Config.trainPrice(member.role, member.level) else nil,
		})
	end
	local quest = currentQuest(plot)
	local reviews = {}
	for i = 1, math.min(8, #snapshot.reviews) do
		reviews[i] = snapshot.reviews[i]
	end
	return {
		cash = math.floor(plot.cash),
		level = plot.level,
		xp = plot.xp,
		xpNext = Config.xpForLevel(plot.level),
		plotIndex = plot.index,
		origin = plot.origin.Position,
		size = plot.size,
		sizeLevel = plot.sizeLevel,
		style = plot.style,
		ownedFloors = plot.ownedFloors,
		ownedWalls = plot.ownedWalls,
		staff = staff,
		maxStaff = Config.maxStaff(plot.level),
		quest = if quest then { text = quest.text, progress = math.min(plot.questProgress, quest.target), target = quest.target, reward = quest.reward, index = plot.questIndex, total = #Config.Quests } else nil,
		day = plot.day,
		totalServed = plot.totalServed,
		appeal = plot:appeal(),
		orders = snapshot.orders,
		carry = snapshot.carry,
		carryLimit = Config.CarryLimit,
		present = snapshot.present,
		freeTables = snapshot.freeTables,
		dirtyTables = snapshot.dirtyTables,
		tableMoney = snapshot.tableMoney,
		rating = snapshot.rating,
		ratingCount = #plot.rt.ratings,
		reviews = reviews,
		menu = snapshot.menu,
		groupsPerMinute = snapshot.groupsPerMinute,
		night = snapshot.night,
	}
end

-- Resumo da noite: quando o relógio passa das 6h.
local lastHour = Lighting.ClockTime
local function checkDayRollover()
	local hour = Lighting.ClockTime
	if lastHour < 6 and hour >= 6 then
		for _, plot in plots do
			if plot.owner and plot.day then
				local day = plot.day
				notify(plot.owner, "Resumo do dia", "resumo", {
					served = day.served,
					earned = day.earned,
					rating = if day.reviews > 0 then day.stars / day.reviews else nil,
				})
				plot.day = { served = 0, earned = 0, reviews = 0, stars = 0 }
			end
		end
	end
	lastHour = hour
end

local lastFull = 0
local lastSend = 0
while true do
	task.wait(0.25)
	local t = os.clock()
	for _, plot in plots do
		if plot.owner and plot.rt then
			local ok, err = pcall(Restaurant.tick, plot)
			if not ok then
				warn("[Adega] Erro na adega", plot.index, err)
			end
		end
	end
	checkDayRollover()
	if t - lastSend >= 0.5 then
		lastSend = t
		local full = t - lastFull >= 2
		if full then
			lastFull = t
		end
		for _, plot in plots do
			if plot.owner and plot.rt and (full or plot.dirty or plot.rt.dirty) then
				plot.dirty = false
				plot.rt.dirty = false
				local ok, state = pcall(buildState, plot)
				if ok then
					stateEvent:FireClient(plot.owner, state)
				else
					warn("[Adega] Erro montando o estado", state)
				end
			end
		end
	end
end
