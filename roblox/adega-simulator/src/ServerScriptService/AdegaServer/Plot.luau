-- Plot: um terreno. Cuida do chão, da área construível, do estilo e dos móveis colocados
-- (com a grade de ocupação). O comportamento dos clientes fica no módulo Restaurant, que
-- recebe avisos pelos ganchos plot.hooks.added / removed / canModify.

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("AdegaShared")
local Config = require(Shared.Config)
local Catalog = require(Shared.Catalog)
local Util = require(Shared.Util)

local Props = require(script.Parent.Props)

local Plot = {}
Plot.__index = Plot

local rgb = Color3.fromRGB
local GROUND_Y = 0.5
local FLOOR_Y = 0.6

local function makePart(parent, props)
	local part = Instance.new("Part")
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Material = Enum.Material.SmoothPlastic
	for key, value in props do
		part[key] = value
	end
	part.Parent = parent
	return part
end

local function signText(part, text, color)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.LightInfluence = 0
	gui.Parent = part
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Heavy)
	label.TextColor3 = color
	label.Text = text
	label.Parent = gui
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0.05, 0)
	padding.PaddingRight = UDim.new(0.05, 0)
	padding.PaddingTop = UDim.new(0.12, 0)
	padding.PaddingBottom = UDim.new(0.12, 0)
	padding.Parent = gui
	return label
end

function Plot.new(index)
	local x = (index - (Config.PlotCount + 1) / 2) * Config.PlotSpacing
	local self = setmetatable({}, Plot)
	self.index = index
	self.origin = CFrame.new(x, FLOOR_Y, Config.PlotFrontZ)
	self.owner = nil
	self.sizeLevel = 1
	self.size = Config.PlotSizes[1].size
	self.style = { floor = "cimento", wall = "branco" }
	self.furniture = {}
	self.occupied = {}
	self.nextUid = 1
	self.hooks = {}

	local model = Instance.new("Model")
	model.Name = "Adega" .. index
	self.model = model
	for _, name in { "Terreno", "Moveis", "Pessoas", "Efeitos" } do
		local folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = model
	end
	self.landFolder = model.Terreno
	self.furnitureFolder = model.Moveis
	self.peopleFolder = model.Pessoas
	self.effectsFolder = model.Efeitos

	local base = CFrame.new(x, 0, Config.PlotFrontZ)
	makePart(self.landFolder, {
		Name = "Grama",
		Size = Vector3.new(Config.LandWidth, GROUND_Y, Config.LandDepth),
		CFrame = base * CFrame.new(0, GROUND_Y / 2, Config.LandDepth / 2),
		Color = rgb(88, 130, 66),
		Material = Enum.Material.Grass,
	})
	self.floor = makePart(self.landFolder, {
		Name = "PisoConstrucao",
		Size = Vector3.new(self.size, FLOOR_Y - GROUND_Y, self.size),
		CFrame = self.origin * CFrame.new(0, -(FLOOR_Y - GROUND_Y) / 2, self.size / 2),
	})
	self.curbs = {}
	for i = 1, 4 do
		self.curbs[i] = makePart(self.landFolder, { Name = "Borda", Color = rgb(200, 196, 188), Material = Enum.Material.Concrete, CanCollide = false })
	end

	-- placa na frente do terreno
	makePart(self.landFolder, {
		Name = "PostePlaca",
		Size = Vector3.new(0.4, 7, 0.4),
		CFrame = base * CFrame.new(-Config.LandWidth / 2 + 4, GROUND_Y + 3.5, 1),
		Color = rgb(50, 50, 55),
		Material = Enum.Material.Metal,
	})
	local board = makePart(self.landFolder, {
		Name = "PlacaDono",
		Size = Vector3.new(9, 3, 0.3),
		CFrame = base * CFrame.new(-Config.LandWidth / 2 + 4, GROUND_Y + 8, 0.8),
		Color = rgb(22, 18, 30),
	})
	self.signLabel = signText(board, "TERRENO DISPONÍVEL", rgb(255, 196, 40))

	self:applySize()
	self:applyStyle()
	model.Parent = workspace
	return self
end

function Plot:toWorld(x, z, y)
	return (self.origin * CFrame.new(x, y or 0, z)).Position
end

function Plot:toLocal(position)
	return self.origin:PointToObjectSpace(position)
end

function Plot:sidewalkPoint(side)
	return self:toWorld(side * (Config.LandWidth / 2 + 6), -4, -(FLOOR_Y - GROUND_Y))
end

function Plot:entrancePoint()
	return self:toWorld(0, -3, -(FLOOR_Y - GROUND_Y))
end

-- Área construível e estilo -------------------------------------------------------------------------

function Plot:applySize()
	local size = self.size
	self.floor.Size = Vector3.new(size, FLOOR_Y - GROUND_Y, size)
	self.floor.CFrame = self.origin * CFrame.new(0, -(FLOOR_Y - GROUND_Y) / 2, size / 2)
	local h = 0.35
	local specs = {
		{ Vector3.new(size + 0.8, h, 0.4), CFrame.new(0, h / 2 - 0.05, -0.2) },
		{ Vector3.new(size + 0.8, h, 0.4), CFrame.new(0, h / 2 - 0.05, size + 0.2) },
		{ Vector3.new(0.4, h, size), CFrame.new(-size / 2 - 0.2, h / 2 - 0.05, size / 2) },
		{ Vector3.new(0.4, h, size), CFrame.new(size / 2 + 0.2, h / 2 - 0.05, size / 2) },
	}
	for i, spec in specs do
		self.curbs[i].Size = spec[1]
		self.curbs[i].CFrame = self.origin * spec[2]
	end
end

function Plot:wallColor()
	return Config.findById(Config.WallColors, self.style.wall).color
end

function Plot:applyStyle()
	local floor = Config.findById(Config.Floors, self.style.floor) or Config.Floors[1]
	self.floor.Color = floor.color
	self.floor.Material = floor.material
	local color = self:wallColor()
	for _, part in self.furnitureFolder:GetDescendants() do
		if part:IsA("BasePart") and part:GetAttribute("Pintura") then
			part.Color = color
		end
	end
end

-- Móveis ------------------------------------------------------------------------------------------

function Plot:canPlace(item, x, z, rotation, ignoreUid, ownerLevel)
	if ownerLevel and ownerLevel < item.level then
		return false, "Libera no nível " .. item.level
	end
	if not Catalog.inBounds(item, x, z, rotation, self.size) then
		return false, "Fora da área da adega"
	end
	for _, key in Catalog.cells(item, x, z, rotation) do
		local uid = self.occupied[key]
		if uid and uid ~= ignoreUid then
			return false, "Já tem algo nesse lugar"
		end
	end
	return true, nil
end

local function lowestFreeNumber(furniture)
	local used = {}
	for _, rec in furniture do
		if rec.number then
			used[rec.number] = true
		end
	end
	local n = 1
	while used[n] do
		n += 1
	end
	return n
end

-- Coloca um móvel sem cobrar nada (quem chama já validou e cobrou).
function Plot:place(itemId, x, z, rotation, animate)
	local item = Catalog.ById[itemId]
	if item == nil then
		return nil
	end
	local localCF = Catalog.localCFrame(x, z, rotation)
	local cframe = self.origin * localCF
	local model = Catalog.buildModel(item, cframe, { wallColor = self:wallColor() })
	local uid = self.nextUid
	self.nextUid += 1
	model:SetAttribute("Uid", uid)
	model:SetAttribute("ItemId", itemId)
	model:SetAttribute("X", x)
	model:SetAttribute("Z", z)
	model:SetAttribute("R", rotation)

	local rec = {
		uid = uid,
		id = itemId,
		item = item,
		kind = item.kind,
		x = x,
		z = z,
		r = rotation,
		cframe = cframe,
		model = model,
		cells = Catalog.cells(item, x, z, rotation),
	}
	for _, key in rec.cells do
		self.occupied[key] = uid
	end

	local front = cframe:VectorToWorldSpace(Vector3.new(0, 0, -1))
	rec.front = front
	if Catalog.isSeatingHost(item) then
		-- mesa ou balcão de bar: recebe os clientes das cadeiras viradas para ele
		rec.host = true
		rec.number = lowestFreeNumber(self.furniture)
		rec.status = "free"
		rec.money = 0
		rec.seats = {}
		rec.top = Catalog.point3(cframe, item.top)
		rec.topPart = model:FindFirstChild("Tampo") or model.PrimaryPart
		if item.kind == "bar" then
			rec.ready = {}
			rec.pickup = rec.top
			rec.staffPos = Catalog.floorPoint(cframe, { 0, item.size[2] * 2 / 2 + 1.4 })
		end
		local tag = Instance.new("BillboardGui")
		tag.Name = "Numero"
		tag.Size = UDim2.fromOffset(30, 30)
		tag.StudsOffset = Vector3.new(0, 1.3, 0)
		tag.MaxDistance = 40
		tag.LightInfluence = 0
		tag.Parent = rec.topPart
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundColor3 = rgb(255, 255, 255)
		label.BackgroundTransparency = 0.05
		label.TextColor3 = rgb(40, 34, 48)
		label.FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Heavy)
		label.TextScaled = true
		label.Text = tostring(rec.number)
		label.Parent = tag
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = label
		local padding = Instance.new("UIPadding")
		padding.PaddingTop = UDim.new(0.15, 0)
		padding.PaddingBottom = UDim.new(0.15, 0)
		padding.Parent = label
		rec.numberTag = tag
	elseif item.kind == "chair" then
		rec.seatList = {}
		for index, seat in Catalog.seatPoints(item, x, z, rotation) do
			rec.seatList[index] = {
				pos = (self.origin * CFrame.new(seat.pos.X, 0, seat.pos.Z)).Position,
				face = self.origin:VectorToWorldSpace(seat.face),
				height = seat.height,
				frontKey = seat.frontKey,
				chair = rec,
			}
		end
	elseif item.kind == "station" then
		rec.use = Catalog.floorPoint(cframe, item.use)
		rec.top = Catalog.point3(cframe, item.top)
		rec.part = model:FindFirstChild("Uso") or model.PrimaryPart
		rec.products = {}
		for _, product in Config.Products do
			if product.station == itemId then
				table.insert(rec.products, product)
			end
		end
		rec.ready = {}
	elseif item.kind == "counter" then
		rec.queue = Catalog.floorPoint(cframe, item.queue)
		rec.staffPos = Catalog.floorPoint(cframe, item.staff)
		rec.pickup = Catalog.point3(cframe, item.pickup)
		rec.part = model:FindFirstChild("Uso") or model.PrimaryPart
		rec.line = {}
		rec.ready = {}
	elseif item.staff then
		rec.staffPos = Catalog.floorPoint(cframe, item.staff)
	end

	if item.spin then
		local spinner = model:FindFirstChild(item.spin)
		if spinner then
			TweenService:Create(spinner, TweenInfo.new(8, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1), {
				Orientation = spinner.Orientation + Vector3.new(0, 360, 0),
			}):Play()
		end
	end

	if animate then
		for _, part in model:GetDescendants() do
			if part:IsA("BasePart") and part.Name ~= "Raiz" then
				local finalCFrame, finalTransparency = part.CFrame, part.Transparency
				part.CFrame = finalCFrame + Vector3.new(0, 2.5, 0)
				part.Transparency = 1
				TweenService:Create(part, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { CFrame = finalCFrame, Transparency = finalTransparency }):Play()
			end
		end
		Props.sparkle(cframe.Position + Vector3.new(0, 2, 0))
	end

	model.Parent = self.furnitureFolder
	self.furniture[uid] = rec
	if not self.batching then
		self:relink()
	end
	if self.hooks.added then
		self.hooks.added(self, rec)
	end
	return rec
end

-- Liga cada cadeira à mesa ou balcão que está na frente dela. Mesas em uso mantêm os
-- lugares que tinham, para não atrapalhar quem está sentado.
function Plot:relink()
	for _, rec in self.furniture do
		if rec.host and rec.status == "free" then
			rec.seats = {}
		end
		if rec.kind == "chair" then
			rec.attached = nil
		end
	end
	for _, rec in self.furniture do
		if rec.kind == "chair" then
			for _, seat in rec.seatList do
				local hostUid = self.occupied[seat.frontKey]
				local host = hostUid and self.furniture[hostUid]
				if host and host.host then
					rec.attached = host
					if host.status == "free" then
						table.insert(host.seats, seat)
					end
				end
			end
		end
	end
	for _, rec in self.furniture do
		if rec.host and rec.numberTag then
			rec.numberTag.Enabled = #rec.seats > 0 or rec.status ~= "free"
		end
	end
end

function Plot:remove(uid)
	local rec = self.furniture[uid]
	if rec == nil then
		return nil
	end
	if self.hooks.removed then
		self.hooks.removed(self, rec)
	end
	for _, key in rec.cells do
		if self.occupied[key] == uid then
			self.occupied[key] = nil
		end
	end
	self.furniture[uid] = nil
	rec.removed = true
	rec.model:Destroy()
	if not self.batching then
		self:relink()
	end
	return rec
end

function Plot:clearFurniture()
	self.batching = true
	for uid in self.furniture do
		self:remove(uid)
	end
	self.batching = false
	self.occupied = {}
	self.nextUid = 1
end

function Plot:serialize()
	local list = {}
	for _, rec in self.furniture do
		table.insert(list, { rec.id, rec.x, rec.z, rec.r })
	end
	return list
end

function Plot:loadLayout(list)
	self.batching = true
	for _, entry in list do
		local item = Catalog.ById[entry[1]]
		if item and type(entry[2]) == "number" and type(entry[3]) == "number" and type(entry[4]) == "number" then
			local rotation = math.floor(entry[4]) % 4
			if self:canPlace(item, entry[2], entry[3], rotation, nil, nil) then
				self:place(entry[1], entry[2], entry[3], rotation, false)
			end
		end
	end
	self.batching = false
	self:relink()
end

function Plot:appeal()
	local total = 0
	for _, rec in self.furniture do
		total += rec.item.appeal or 0
	end
	return total
end

function Plot:find(kind)
	local list = {}
	for _, rec in self.furniture do
		if rec.kind == kind then
			table.insert(list, rec)
		end
	end
	return list
end

-- Dono --------------------------------------------------------------------------------------------

function Plot:claim(player, saved)
	self.owner = player
	self.sizeLevel = math.clamp(saved and saved.sizeLevel or 1, 1, #Config.PlotSizes)
	self.size = Config.PlotSizes[self.sizeLevel].size
	self.style = {
		floor = if saved and Config.findById(Config.Floors, saved.floor) then saved.floor else "cimento",
		wall = if saved and Config.findById(Config.WallColors, saved.wall) then saved.wall else "branco",
	}
	self:applySize()
	self:loadLayout(if saved and type(saved.furniture) == "table" then saved.furniture else Util.StarterLayout)
	self:applyStyle()
	self.signLabel.Text = "ADEGA " .. string.upper(player.DisplayName)
end

function Plot:release()
	self:clearFurniture()
	self.peopleFolder:ClearAllChildren()
	self.effectsFolder:ClearAllChildren()
	self.owner = nil
	self.sizeLevel = 1
	self.size = Config.PlotSizes[1].size
	self.style = { floor = "cimento", wall = "branco" }
	self:applySize()
	self:applyStyle()
	self.signLabel.Text = "TERRENO DISPONÍVEL"
end

return Plot
