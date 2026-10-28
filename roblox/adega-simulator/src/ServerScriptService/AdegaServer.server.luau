-- AdegaServer (Script em ServerScriptService)
-- Cria os terrenos, dá um para cada jogador, vende as melhorias, manda clientes e salva o progresso.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local TweenService = game:GetService("TweenService")

print("[Adega] AdegaServer iniciou")

-- Procura o AdegaConfig sem ligar para maiúsculas e em qualquer pasta comum, porque é fácil
-- criar o ModuleScript com outro nome ou no lugar errado.
local function findConfig()
	local containers = { ReplicatedStorage, game:GetService("ServerScriptService"), game:GetService("ServerStorage"), workspace }
	for _, container in containers do
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

local Config = require(configModule)
if type(Config) ~= "table" or type(Config.Upgrades) ~= "table" then
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

local plots = {}
local plotOf = {} -- [Player] = terreno

local upgradeById = {}
for index, upgrade in Config.Upgrades do
	upgrade.slot = index
	upgradeById[upgrade.id] = upgrade
end

local refreshButtons

local function formatMoney(amount)
	local digits = tostring(math.floor(amount))
	local grouped = digits:reverse():gsub("(%d%d%d)", "%1."):reverse()
	if grouped:sub(1, 1) == "." then
		grouped = grouped:sub(2)
	end
	return "R$ " .. grouped
end

local function makeText(parent, text, color)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextScaled = true
	label.Font = Enum.Font.FredokaOne
	label.TextColor3 = color or Color3.new(1, 1, 1)
	label.Parent = parent
	return label
end

local function makeBillboard(part, offsetY, width, height)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(width, height)
	gui.StudsOffset = Vector3.new(0, offsetY, 0)
	gui.MaxDistance = 60
	gui.Parent = part
	local label = makeText(gui, "")
	label.TextStrokeTransparency = 0.3
	return label
end

-- Cria uma peça ancorada a partir de uma tabela como as de AdegaConfig.
local function makePart(parent, origin, props)
	local part = Instance.new("Part")
	part.Name = props.name or "Peca"
	part.Anchored = true
	part.Size = props.size
	part.CFrame = origin * CFrame.new(props.pos) * (props.rot or CFrame.identity)
	part.Color = props.color or rgb(200, 200, 200)
	part.Material = props.material or Enum.Material.SmoothPlastic
	part.Transparency = props.transparency or 0
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
		gui.PixelsPerStud = 50
		gui.Parent = part
		label = makeText(gui, props.text, props.textColor)
	end
	if props.light then
		local light = Instance.new("PointLight")
		light.Color = props.light.color
		light.Range = props.light.range
		light.Brightness = props.light.brightness
		light.Parent = part
	end
	if props.smoke then
		local smoke = Instance.new("Smoke")
		smoke.Size = 2
		smoke.Opacity = 0.15
		smoke.RiseVelocity = 3
		smoke.Parent = part
	end

	part.Parent = parent
	return part, label
end

local function getPlayerFromHit(hit)
	return Players:GetPlayerFromCharacter(hit.Parent)
end

local function updateLabels(plot)
	if not plot.owner then
		plot.signLabel.Text = "Terreno livre"
		plot.registerLabel.Text = ""
		return
	end
	plot.signLabel.Text = string.format(
		"Adega de %s\n%d clientes/min • %s por cliente",
		plot.owner.DisplayName,
		plot.cpm,
		formatMoney(plot.ticket)
	)
	if plot.autoCollect then
		plot.registerLabel.Text = "Caixa\nMaquininha: coleta automática"
	else
		plot.registerLabel.Text = "Caixa: " .. formatMoney(plot.pending) .. "\nPise aqui para coletar"
	end
end

local function collect(plot, hit)
	local player = getPlayerFromHit(hit)
	if player == nil or player ~= plot.owner or plot.pending <= 0 then
		return
	end
	plot.cashValue.Value += plot.pending
	plot.pending = 0
	updateLabels(plot)
end

local function recalcStats(plot)
	local cpm, ticket, autoCollect = 0, 0, false
	for _, upgrade in Config.Upgrades do
		if plot.owned[upgrade.id] then
			cpm += upgrade.customers or 0
			ticket += upgrade.ticket or 0
			autoCollect = autoCollect or upgrade.autoCollect == true
		end
	end
	if plot.cpm == 0 and cpm > 0 then
		plot.nextCustomer = os.clock() + 2
	end
	plot.cpm, plot.ticket, plot.autoCollect = cpm, ticket, autoCollect
	if autoCollect and plot.pending > 0 and plot.cashValue then
		plot.cashValue.Value += plot.pending
		plot.pending = 0
	end
	updateLabels(plot)
end

local function requirementsMet(plot, upgrade)
	local requires = upgrade.requires
	if requires == nil then
		return true
	end
	if type(requires) == "string" then
		return plot.owned[requires] == true
	end
	for _, id in requires do
		if not plot.owned[id] then
			return false
		end
	end
	return true
end

local function buildUpgrade(plot, upgrade, animate)
	local folder = Instance.new("Folder")
	folder.Name = upgrade.id
	folder.Parent = plot.built

	local ctx = { ownerName = plot.owner and plot.owner.DisplayName or "" }
	upgrade.build(function(props)
		local part = makePart(folder, plot.origin, props)
		if animate then
			local finalCFrame, finalTransparency = part.CFrame, part.Transparency
			part.CFrame = finalCFrame - Vector3.new(0, 2, 0)
			part.Transparency = 1
			TweenService:Create(part, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				CFrame = finalCFrame,
				Transparency = finalTransparency,
			}):Play()
		end
		return part
	end, ctx)
end

local function describe(upgrade)
	local bits = {}
	if upgrade.customers then
		table.insert(bits, "+" .. upgrade.customers .. " clientes/min")
	end
	if upgrade.ticket then
		table.insert(bits, "+" .. formatMoney(upgrade.ticket) .. " por cliente")
	end
	if upgrade.autoCollect then
		table.insert(bits, "coleta automática")
	end
	return table.concat(bits, " • ")
end

local function paintButtons(plot)
	local cash = if plot.cashValue then plot.cashValue.Value else 0
	for id, button in plot.buttons do
		button.Color = if cash >= upgradeById[id].price then rgb(60, 220, 90) else rgb(200, 60, 60)
	end
end

local function tryBuy(plot, upgrade, hit)
	local player = getPlayerFromHit(hit)
	if player == nil or player ~= plot.owner or plot.owned[upgrade.id] then
		return
	end
	if plot.cashValue.Value < upgrade.price then
		return
	end
	plot.cashValue.Value -= upgrade.price
	plot.owned[upgrade.id] = true
	buildUpgrade(plot, upgrade, true)
	recalcStats(plot)
	refreshButtons(plot)
end

-- Mostra os botões das melhorias já liberadas. Cada melhoria tem uma vaga fixa (duas colunas
-- na lateral direita), assim um botão novo nunca aparece embaixo do jogador que acabou de comprar.
refreshButtons = function(plot)
	for id, button in plot.buttons do
		if plot.owner == nil or plot.owned[id] or not requirementsMet(plot, upgradeById[id]) then
			button:Destroy()
			plot.buttons[id] = nil
		end
	end
	if plot.owner == nil then
		return
	end

	for _, upgrade in Config.Upgrades do
		if not plot.owned[upgrade.id] and not plot.buttons[upgrade.id] and requirementsMet(plot, upgrade) then
			local slot = upgrade.slot - 1
			local button = makePart(plot.model, plot.origin, {
				name = "Botao_" .. upgrade.id,
				size = Vector3.new(3, 0.4, 3),
				pos = Vector3.new(24 + (slot % 2) * 4, 0.2, -26 + math.floor(slot / 2) * 5),
				material = Enum.Material.Neon,
			})
			local label = makeBillboard(button, 3, 240, 90)
			label.Text = upgrade.name .. "\n" .. formatMoney(upgrade.price) .. "\n" .. describe(upgrade)
			button.Touched:Connect(function(hit)
				tryBuy(plot, upgrade, hit)
			end)
			plot.buttons[upgrade.id] = button
		end
	end
	paintButtons(plot)
end

local SKINS = { rgb(255, 224, 189), rgb(234, 192, 134), rgb(198, 134, 66), rgb(141, 85, 36), rgb(96, 58, 30) }
local SHIRTS = { rgb(230, 57, 70), rgb(29, 53, 87), rgb(42, 157, 143), rgb(244, 162, 97), rgb(255, 255, 255), rgb(20, 20, 20), rgb(255, 214, 10) }
local SHORTS = { rgb(40, 60, 110), rgb(30, 30, 30), rgb(90, 90, 90), rgb(60, 110, 60) }

local function pick(list)
	return list[math.random(1, #list)]
end

local function pay(plot)
	if plot.autoCollect then
		plot.cashValue.Value += plot.ticket
	else
		plot.pending += plot.ticket
	end
	updateLabels(plot)
end

local function spawnCustomer(plot)
	local session = plot.session
	local lane = math.random() * 2 - 1
	local function at(x, z)
		return (plot.origin * CFrame.new(x + lane, 3, z)).Position
	end

	local model = Instance.new("Model")
	model.Name = "Cliente"
	local function bodyPart(name, size, cframe, color, shape)
		local part = Instance.new("Part")
		part.Name = name
		part.Size = size
		part.CFrame = cframe
		part.Color = color
		part.Material = Enum.Material.SmoothPlastic
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		if shape then
			part.Shape = shape
		end
		part.Parent = model
		return part
	end

	local torso = bodyPart("Tronco", Vector3.new(2, 2, 1), CFrame.new(), pick(SHIRTS))
	bodyPart("Pernas", Vector3.new(2, 2, 1), CFrame.new(0, -2, 0), pick(SHORTS))
	local head = bodyPart("Cabeca", Vector3.new(1.3, 1.3, 1.3), CFrame.new(0, 1.65, 0), pick(SKINS), Enum.PartType.Ball)
	model.PrimaryPart = torso

	local start, counter, side, exit = at(-3, -36), at(-3, -3), at(3, -3), at(3, -36)
	local driver = Instance.new("CFrameValue")
	driver.Value = CFrame.lookAt(start, counter)
	driver.Changed:Connect(function(cframe)
		if model.Parent then
			model:PivotTo(cframe)
		end
	end)
	model:PivotTo(driver.Value)
	model.Parent = plot.customers
	plot.activeCustomers += 1

	local function walkTo(target)
		local from = driver.Value.Position
		local direction = (target - from).Unit
		driver.Value = CFrame.lookAt(from, target)
		local tween = TweenService:Create(driver, TweenInfo.new((target - from).Magnitude / Config.WalkSpeed, Enum.EasingStyle.Linear), {
			Value = CFrame.lookAt(target, target + direction),
		})
		tween:Play()
		tween.Completed:Wait()
	end

	task.spawn(function()
		walkTo(counter)
		task.wait(1.5)
		if plot.session == session then
			pay(plot)
			if plot.owned.copao then
				bodyPart("Copao", Vector3.new(0.6, 1, 0.6), torso.CFrame * CFrame.new(1.3, 0, -0.5), rgb(240, 170, 40))
			end
			local popup = makeBillboard(head, 2, 120, 40)
			popup.Text = "+" .. formatMoney(plot.ticket)
			popup.TextColor3 = rgb(90, 255, 120)
		end
		walkTo(side)
		walkTo(exit)
		model:Destroy()
		driver:Destroy()
		if plot.session == session then
			plot.activeCustomers -= 1
		end
	end)
end

local function createPlot(index)
	local x = (index - (Config.PlotCount + 1) / 2) * Config.PlotSpacing
	local origin = CFrame.new(x, 1, Config.PlotRowZ)
	local model = Instance.new("Model")
	model.Name = "Terreno" .. index

	local plot = {
		origin = origin,
		model = model,
		owner = nil,
		cashValue = nil,
		owned = {},
		buttons = {},
		pending = 0,
		cpm = 0,
		ticket = 0,
		autoCollect = false,
		session = 0,
		activeCustomers = 0,
		nextCustomer = 0,
		canSave = false,
	}

	makePart(model, origin, { name = "Chao", size = Vector3.new(60, 1, 60), pos = Vector3.new(0, -0.5, 0), color = rgb(105, 105, 105), material = Enum.Material.Concrete })

	plot.built = Instance.new("Folder")
	plot.built.Name = "Construcoes"
	plot.built.Parent = model
	plot.customers = Instance.new("Folder")
	plot.customers.Name = "Clientes"
	plot.customers.Parent = model

	plot.register = makePart(model, origin, { name = "Caixa", size = Vector3.new(5, 0.4, 5), pos = Vector3.new(-25, 0.2, -27), color = rgb(255, 200, 0), material = Enum.Material.Neon })
	plot.registerLabel = makeBillboard(plot.register, 3, 220, 70)
	plot.register.Touched:Connect(function(hit)
		collect(plot, hit)
	end)

	makePart(model, origin, { name = "Poste", size = Vector3.new(0.4, 6, 0.4), pos = Vector3.new(-9, 3, -29), color = rgb(60, 60, 60) })
	local _, signLabel = makePart(model, origin, { name = "PlacaDono", size = Vector3.new(10, 3.5, 0.4), pos = Vector3.new(-9, 7.5, -29), color = rgb(30, 30, 30), text = "" })
	plot.signLabel = signLabel

	updateLabels(plot)
	model.Parent = workspace
	return plot
end

local function resetPlot(plot)
	plot.owner = nil
	plot.cashValue = nil
	plot.owned = {}
	plot.pending = 0
	plot.session += 1
	plot.activeCustomers = 0
	plot.canSave = false
	plot.built:ClearAllChildren()
	plot.customers:ClearAllChildren()
	refreshButtons(plot)
	recalcStats(plot)
end

local function dataKey(player)
	return "jogador_" .. player.UserId
end

local function saveData(player)
	local plot = plotOf[player]
	if store == nil or plot == nil or not plot.canSave then
		return
	end
	local owned = {}
	for id in plot.owned do
		table.insert(owned, id)
	end
	local data = { cash = plot.cashValue.Value + plot.pending, owned = owned }
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
	leaderstats.Parent = player
	local cash = Instance.new("IntValue")
	cash.Name = "Dinheiro"
	cash.Value = Config.StartingCash
	cash.Parent = leaderstats

	local plot
	for _, candidate in plots do
		if candidate.owner == nil then
			plot = candidate
			break
		end
	end
	if plot == nil then
		warn("[Adega] Nenhum terreno livre para", player.Name)
		return
	end
	plot.owner = player
	plot.cashValue = cash
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

	if type(data) == "table" then
		cash.Value = data.cash or Config.StartingCash
		for _, id in data.owned or {} do
			if upgradeById[id] then
				plot.owned[id] = true
			end
		end
	end
	for _, upgrade in Config.Upgrades do
		if plot.owned[upgrade.id] then
			buildUpgrade(plot, upgrade, false)
		end
	end
	recalcStats(plot)
	refreshButtons(plot)
	cash.Changed:Connect(function()
		paintButtons(plot)
	end)

	local function moveToPlot(character)
		if character:WaitForChild("HumanoidRootPart", 10) and plot.owner == player then
			task.wait()
			character:PivotTo(plot.origin * CFrame.new(0, 4, -26) * CFrame.Angles(0, math.pi, 0))
		end
	end
	player.CharacterAdded:Connect(moveToPlot)
	if player.Character then
		task.spawn(moveToPlot, player.Character)
	end
end

local function onPlayerRemoving(player)
	saveData(player)
	local plot = plotOf[player]
	plotOf[player] = nil
	if plot then
		resetPlot(plot)
	end
end

for index = 1, Config.PlotCount do
	plots[index] = createPlot(index)
end
print("[Adega] " .. Config.PlotCount .. " terrenos criados no Workspace")

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

-- Chegada de clientes: cada terreno recebe gente no ritmo de "clientes por minuto".
while true do
	task.wait(0.2)
	local now = os.clock()
	for _, plot in plots do
		if plot.owner and plot.cpm > 0 and now >= plot.nextCustomer then
			plot.nextCustomer = now + (60 / plot.cpm) * (0.75 + math.random() * 0.5)
			if plot.activeCustomers < Config.MaxCustomersPerPlot then
				spawnCustomer(plot)
			end
		end
	end
end
