-- Staff: os funcionários. Cada um roda um laço que procura trabalho da sua função,
-- vai até o lugar, faz a tarefa e volta para o ponto de espera.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("AdegaShared")
local Config = require(Shared.Config)
local Looks = require(Shared.Looks)

local Rig = require(script.Parent.Rig)
local Props = require(script.Parent.Props)
local Restaurant = require(script.Parent.Restaurant)

local Staff = {}

local rgb = Color3.fromRGB

local function alive(staff)
	local plot = staff.plot
	return not staff.fired and plot.rt ~= nil and plot.rt.session == staff.session and Rig.isAlive(staff.rig)
end

local function speedOf(staff)
	return Config.staffSpeed(staff.level)
end

local function floorUnder(rec, point)
	return Vector3.new(point.X, rec.cframe.Position.Y, point.Z)
end

local function walk(staff, target, approach)
	if not alive(staff) then
		return false
	end
	return Rig.walkTo(staff.rig, target, 12 * speedOf(staff), function()
		return alive(staff)
	end, approach)
end

-- Faz uma tarefa parado, com um balão de progresso em cima da cabeça.
-- display: um produto (mostra a bebida em 3D) ou um texto curto.
local function work(staff, seconds, display)
	if not alive(staff) then
		return false
	end
	local bubble = Props.bubble(staff.rig.head, 5.4)
	if type(display) == "table" then
		bubble.products({ display })
	else
		bubble.text(display)
	end
	local duration = seconds / speedOf(staff)
	local started = os.clock()
	while os.clock() - started < duration do
		if not alive(staff) then
			bubble.destroy()
			return false
		end
		bubble.bar((os.clock() - started) / duration)
		task.wait(0.15)
	end
	bubble.destroy()
	return alive(staff)
end

local function holdProducts(staff, items)
	local products = {}
	for _, item in items do
		table.insert(products, item.product)
	end
	if #products == 0 then
		Rig.drop(staff.rig)
	else
		Rig.hold(staff.rig, Props.tray(products))
	end
end

local function idlePoint(staff)
	local plot = staff.plot
	local role = staff.role.id
	local index = staff.slot or 1
	if role == "seguranca" then
		local side = if index % 2 == 0 then 1 else -1
		return plot:toWorld(side * (3 + math.floor((index - 1) / 2) * 2), 1.2), Vector3.new(0, 0, -1)
	end
	if role == "dj" then
		for _, rec in plot.furniture do
			if rec.id == "cabine_dj" then
				return rec.staffPos, rec.front
			end
		end
	end
	local counters = plot:find("counter")
	if #counters > 0 then
		local counter = counters[1]
		local side = counter.cframe:VectorToWorldSpace(Vector3.new(1, 0, 0))
		local offset = ((index % 5) - 2) * 1.6
		return counter.staffPos + side * offset, counter.front
	end
	return plot:toWorld(((index % 5) - 2) * 2, plot.size * 0.6), Vector3.new(0, 0, -1)
end

local function goIdle(staff)
	local point, look = idlePoint(staff)
	if (Rig.feet(staff.rig) - point).Magnitude > 2.5 then
		walk(staff, point, true)
	end
	if alive(staff) and look then
		Rig.face(staff.rig, look)
	end
end

-- Leva itens para as mesas, agrupando por pedido.
local function deliverToTables(staff, carried)
	local plot = staff.plot
	while #carried > 0 and alive(staff) do
		local order = carried[1].order
		local group = {}
		for i = #carried, 1, -1 do
			if carried[i].order == order then
				table.insert(group, carried[i])
				table.remove(carried, i)
			end
		end
		if order.state == "open" and order.place and not order.place.removed then
			if walk(staff, floorUnder(order.place, order.place.top), true) and alive(staff) then
				Restaurant.deliver(plot, order, group, staff.actor)
			else
				for _, item in group do
					Restaurant.releaseItem(plot, item)
				end
			end
		end
		holdProducts(staff, carried)
	end
	for _, item in carried do
		Restaurant.releaseItem(plot, item)
	end
	Rig.drop(staff.rig)
end

-- Prepara um item numa estação. Devolve true se o item ficou pronto na mão do funcionário.
local function prepareAt(staff, item, station)
	if not walk(staff, station.use) then
		Restaurant.releaseItem(staff.plot, item)
		return false
	end
	Rig.face(staff.rig, -station.front)
	if not work(staff, item.product.prep, item.product) or item.state ~= "preparing" then
		if item.state == "preparing" then
			Restaurant.releaseItem(staff.plot, item)
		end
		return false
	end
	item.state = "carried"
	holdProducts(staff, { item })
	return true
end

local function waiterStep(staff)
	local plot = staff.plot
	local actor = staff.actor

	local batch, place = Restaurant.claimReadyBatch(plot, actor, "table", 4)
	if #batch > 0 then
		local stand = place.staffPos or place.use
		local carried = {}
		if walk(staff, stand) then
			for _, item in batch do
				if Restaurant.pickUp(plot, item, actor) then
					table.insert(carried, item)
				end
			end
		end
		for _, item in batch do
			item.claim = nil
		end
		holdProducts(staff, carried)
		deliverToTables(staff, carried)
		return true
	end

	local order = Restaurant.claimOrderToTake(plot, "table", actor)
	if order then
		if walk(staff, floorUnder(order.place, order.place.top), true) and order.state == "waiting" then
			if work(staff, 1.2, "Anotando") and order.state == "waiting" then
				Restaurant.takeOrder(plot, order, actor)
			end
		end
		if order.claim == actor then
			order.claim = nil
		end
		return true
	end

	local rec = Restaurant.claimTable(plot, actor, "money")
	if rec then
		if walk(staff, floorUnder(rec, rec.top), true) and work(staff, 0.5, "R$") then
			Restaurant.collectMoney(plot, rec, actor)
		end
		rec.moneyClaim = nil
		return true
	end

	-- Sem bartender, o garçom prepara as bebidas das mesas e já leva.
	if Restaurant.staffCount(plot, "bartender") == 0 then
		local item, station = Restaurant.claimPendingItem(plot, actor, Rig.feet(staff.rig), function(candidate)
			return candidate.order.kind == "table"
		end)
		if item then
			if prepareAt(staff, item, station) then
				deliverToTables(staff, { item })
			end
			return true
		end
	end
	return false
end

local function bartenderStep(staff)
	local plot = staff.plot
	local item, station = Restaurant.claimPendingItem(plot, staff.actor, Rig.feet(staff.rig))
	if item == nil then
		return false
	end
	if not prepareAt(staff, item, station) then
		return true
	end
	local place = Restaurant.pickupPlaceFor(plot, item, station)
	if place ~= station then
		walk(staff, place.staffPos or place.use)
	end
	Rig.drop(staff.rig)
	if item.state == "carried" and alive(staff) then
		Restaurant.putReady(plot, item, place)
	elseif item.state == "carried" then
		Restaurant.releaseItem(plot, item)
	end
	return true
end

local function cleanerStep(staff)
	local plot = staff.plot
	local rec = Restaurant.claimTable(plot, staff.actor, "dirty")
	if rec == nil then
		return false
	end
	if walk(staff, floorUnder(rec, rec.top), true) and work(staff, 2.2, "Limpando") then
		Restaurant.clean(plot, rec, staff.actor)
	end
	rec.cleanClaim = nil
	return true
end

local function handOver(staff, item)
	local order = item.order
	if order.state == "open" and order.place and not order.place.removed then
		walk(staff, order.place.staffPos)
		if alive(staff) then
			Restaurant.deliver(staff.plot, order, { item }, staff.actor)
		end
	else
		Restaurant.releaseItem(staff.plot, item)
	end
	Rig.drop(staff.rig)
end

local function clerkStep(staff)
	local plot = staff.plot
	local actor = staff.actor

	local batch, place = Restaurant.claimReadyBatch(plot, actor, "counter", 2)
	if #batch > 0 then
		local carried = {}
		if walk(staff, place.staffPos or place.use) then
			for _, item in batch do
				if Restaurant.pickUp(plot, item, actor) then
					table.insert(carried, item)
				end
			end
		end
		for _, item in batch do
			item.claim = nil
		end
		for _, item in carried do
			if alive(staff) then
				Restaurant.deliver(plot, item.order, { item }, actor)
			else
				Restaurant.releaseItem(plot, item)
			end
		end
		return true
	end

	local order = Restaurant.claimOrderToTake(plot, "counter", actor)
	if order then
		if walk(staff, order.place.staffPos) and order.state == "waiting" then
			-- o cliente pode ter desistido enquanto o atendente chegava ou anotava
			local done = work(staff, 0.8, "Anotando")
			if done and order.state == "waiting" then
				Restaurant.takeOrder(plot, order, actor)
			end
		end
		if order.claim == actor then
			order.claim = nil
		end
		return true
	end

	local item, station = Restaurant.claimPendingItem(plot, actor, Rig.feet(staff.rig), function(candidate)
		return candidate.order.kind == "counter"
	end)
	if item then
		if prepareAt(staff, item, station) then
			handOver(staff, item)
		end
		return true
	end
	return false
end

local STEPS = {
	garcom = waiterStep,
	bartender = bartenderStep,
	faxineiro = cleanerStep,
	atendente = clerkStep,
}

local function run(staff)
	local plot = staff.plot
	task.wait(0.5)
	Rig.walkTo(staff.rig, plot:entrancePoint(), 12, function()
		return alive(staff)
	end)
	while alive(staff) do
		local step = STEPS[staff.role.id]
		local ok, worked = true, false
		if step then
			ok, worked = pcall(step, staff)
			if not ok then
				warn("[Adega] Erro no funcionário", staff.name, worked)
				worked = false
			end
		end
		if not alive(staff) then
			break
		end
		if not worked then
			goIdle(staff)
			if staff.role.id == "dj" and math.random() < 0.25 then
				Props.popup(staff.rig.head.Position + Vector3.new(0, 1.5, 0), Rig.pick({ "♪", "♫", "♪ ♫" }), rgb(200, 140, 255))
			end
			task.wait(0.7)
		end
	end
end

local TAG_FONT = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Bold)

local function nameTag(staff)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(150, 46)
	gui.StudsOffset = Vector3.new(0, 3.3, 0)
	gui.MaxDistance = 45
	gui.LightInfluence = 0
	gui.Parent = staff.rig.head
	local pill = Instance.new("Frame")
	pill.AnchorPoint = Vector2.new(0.5, 0)
	pill.Position = UDim2.fromScale(0.5, 0)
	pill.Size = UDim2.fromOffset(150, 26)
	pill.AutomaticSize = Enum.AutomaticSize.X
	pill.BackgroundColor3 = rgb(255, 255, 255)
	pill.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = pill
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.Parent = pill
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = rgb(40, 34, 48)
	label.FontFace = TAG_FONT
	label.TextSize = 16
	label.RichText = true
	label.Parent = pill
	local role = Instance.new("TextLabel")
	role.AnchorPoint = Vector2.new(0.5, 0)
	role.Position = UDim2.new(0.5, 0, 0, 27)
	role.Size = UDim2.fromOffset(150, 16)
	role.BackgroundTransparency = 1
	role.TextColor3 = rgb(255, 255, 255)
	role.TextStrokeTransparency = 0.5
	role.FontFace = TAG_FONT
	role.TextSize = 13
	role.Text = staff.role.name
	role.Parent = gui
	staff.tag = label
end

function Staff.updateTag(staff)
	if staff.tag then
		staff.tag.Text = staff.name .. '  <font color="#FF9500">' .. string.rep("★", staff.level) .. "</font>"
	end
end

-- Muda a aparência do funcionário (cores, cabelo).
function Staff.setLook(staff, look)
	staff.look = Looks.sanitize(look, staff.role.look)
	if Rig.isAlive(staff.rig) then
		Looks.apply(staff.rig.model, staff.look)
	end
end

-- data = { id, role, name, level, look }
function Staff.spawn(plot, data)
	local role = Config.staffById(data.role)
	if role == nil or plot.rt == nil then
		return nil
	end
	local staff = {
		id = data.id,
		role = role,
		name = data.name,
		level = math.clamp(data.level or 1, 1, Config.StaffMaxLevel),
		plot = plot,
		session = plot.rt.session,
	}
	staff.actor = { kind = "staff", staff = staff, name = staff.name }
	local slot = 0
	for _, other in plot.staff do
		if other.role.id == role.id then
			slot += 1
		end
	end
	staff.slot = slot + 1
	local defaults = table.clone(role.look)
	defaults.skin = math.random(1, #Looks.Skins)
	staff.look = Looks.sanitize(data.look, defaults)
	staff.rig = Rig.new(plot.peopleFolder, plot:sidewalkPoint(1), Vector3.new(-1, 0, 0), staff.look, role.name)
	staff.rig.model:SetAttribute("StaffId", staff.id)
	nameTag(staff)
	Staff.updateTag(staff)
	table.insert(plot.staff, staff)
	task.spawn(run, staff)
	return staff
end

function Staff.remove(plot, staff)
	staff.fired = true
	Restaurant.releaseActor(plot, staff.actor)
	if Rig.isAlive(staff.rig) then
		local rig = staff.rig
		Rig.drop(rig)
		task.spawn(function()
			Rig.walkTo(rig, plot:sidewalkPoint(1), 12, function()
				return rig.model.Parent ~= nil
			end)
			Rig.destroy(rig)
		end)
	end
	local index = table.find(plot.staff, staff)
	if index then
		table.remove(plot.staff, index)
	end
end

function Staff.clear(plot)
	for _, staff in table.clone(plot.staff or {}) do
		staff.fired = true
		Rig.destroy(staff.rig)
	end
	plot.staff = {}
end

return Staff
