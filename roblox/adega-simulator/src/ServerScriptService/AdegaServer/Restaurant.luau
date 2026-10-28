-- Restaurant: clientes, pedidos e tudo que o jogador e a equipe fazem na adega.
--
-- Ciclo de uma mesa: o grupo chega e senta -> lê o cardápio -> chama (❗) -> alguém anota ->
-- cada bebida é preparada numa estação -> alguém entrega -> o grupo bebe e pode pedir outra rodada ->
-- vai embora deixando dinheiro e sujeira -> alguém pega o dinheiro e limpa a mesa.
-- No balcão: o cliente entra na fila, pede, recebe e paga na hora.
--
-- Estados de um item do pedido: new (ainda não anotado), pending (esperando preparo),
-- preparing (alguém da equipe preparando), ready (pronto num balcão ou estação),
-- carried (na mão de alguém), served (entregue) e cancelled (o cliente foi embora).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local Shared = ReplicatedStorage:WaitForChild("AdegaShared")
local Config = require(Shared.Config)
local Util = require(Shared.Util)

local Rig = require(script.Parent.Rig)
local Props = require(script.Parent.Props)

local Restaurant = {}

local C = Config.Customer
local rgb = Color3.fromRGB
local formatMoney = Util.formatMoney

local function now()
	return os.clock()
end

local function randomIn(range)
	return range[1] + math.random() * (range[2] - range[1])
end

function Restaurant.nightFactor()
	local hour = Lighting.ClockTime
	if hour >= 18 or hour < 2 then
		return Config.NightBoost
	elseif hour < 6 then
		return Config.LateNightFactor
	end
	return 1
end

function Restaurant.staffCount(plot, role)
	local count = 0
	for _, staff in plot.staff or {} do
		if role == nil or staff.role.id == role then
			count += 1
		end
	end
	return count
end

-- Cardápio liberado: produtos cuja estação existe na adega e cujo nível já foi alcançado.
function Restaurant.menu(plot)
	local stations = {}
	for _, rec in plot.furniture do
		if rec.kind == "station" then
			stations[rec.id] = true
		end
	end
	local list = {}
	for _, product in Config.Products do
		if stations[product.station] and plot.level >= product.level then
			table.insert(list, product)
		end
	end
	return list
end

local function notify(plot, text, kind)
	local rt = plot.rt
	if rt and rt.callbacks.notify then
		rt.callbacks.notify(text, kind)
	end
end

local function notifyOnce(plot, key, text, kind, cooldown)
	local rt = plot.rt
	local last = rt.warnings[key]
	if last and now() - last < (cooldown or 45) then
		return
	end
	rt.warnings[key] = now()
	notify(plot, text, kind)
end

local function event(plot, name, amount)
	local rt = plot.rt
	if rt and rt.callbacks.event then
		rt.callbacks.event(name, amount or 1)
	end
end

local function markDirty(plot)
	if plot.rt then
		plot.rt.dirty = true
	end
end

-- Itens prontos --------------------------------------------------------------------------------------

local function relayoutReady(plot, place)
	local base = place.pickup or place.top
	for index, item in place.ready do
		if item.model then
			local slot = index - 1
			local offset = place.cframe:VectorToWorldSpace(Vector3.new((slot % 6) * 0.9, 0, -math.floor(slot / 6) * 0.9))
			item.model:PivotTo(CFrame.new(base + offset))
		end
	end
end

local function removeReady(plot, item)
	local place = item.place
	if place then
		local index = table.find(place.ready, item)
		if index then
			table.remove(place.ready, index)
		end
		relayoutReady(plot, place)
	end
	if item.model then
		item.model:Destroy()
		item.model = nil
	end
	item.place = nil
end

function Restaurant.putReady(plot, item, place)
	if item.state == "cancelled" or place.removed then
		return
	end
	item.state = "ready"
	item.actor = nil
	item.place = place
	table.insert(place.ready, item)
	item.model = Props.product(item.product, CFrame.new(place.pickup or place.top))
	item.model.Parent = plot.effectsFolder
	relayoutReady(plot, place)
	markDirty(plot)
end

-- Onde deixar um item pronto: o pedido do balcão vai para o próprio balcão; o da mesa vai para o
-- balcão mais perto da estação (ou fica na própria estação se não houver balcão).
function Restaurant.pickupPlaceFor(plot, item, station)
	local order = item.order
	if order.kind == "counter" and order.place and not order.place.removed then
		return order.place
	end
	local best, bestDistance = nil, math.huge
	for _, rec in plot.furniture do
		if (rec.kind == "counter" or rec.kind == "bar") and rec.staffPos then
			local distance = (rec.staffPos - station.use).Magnitude
			if distance < bestDistance then
				best, bestDistance = rec, distance
			end
		end
	end
	return best or station
end

-- Bandeja do jogador ---------------------------------------------------------------------------------

local function updateTray(plot)
	local player = plot.owner
	local character = player and player.Character
	if character == nil then
		return
	end
	local old = character:FindFirstChild("AdegaBandeja")
	if old then
		old:Destroy()
	end
	local carry = plot.rt.carry
	if #carry == 0 then
		return
	end
	local hand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
	if hand == nil then
		return
	end
	local products = {}
	for _, item in carry do
		table.insert(products, item.product)
	end
	local tray = Props.tray(products)
	tray.Name = "AdegaBandeja"
	for _, part in tray:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = false
			part.CanCollide = false
			part.CanQuery = false
			part.Massless = true
		end
	end
	local weld = Instance.new("Weld")
	weld.Part0 = hand
	weld.Part1 = tray.PrimaryPart
	weld.C0 = if hand.Name == "RightHand" then CFrame.new(0, -0.15, -0.75) else CFrame.new(0, -1.05, -0.75)
	weld.Parent = tray.PrimaryPart
	tray.Parent = character
end
Restaurant.updateTray = updateTray

local function removeFromCarry(plot, item)
	local carry = plot.rt.carry
	local index = table.find(carry, item)
	if index then
		table.remove(carry, index)
		updateTray(plot)
	end
end

-- Quando o jogador morre ou sai, o que estava na bandeja volta para a fila de preparo.
function Restaurant.dropCarry(plot)
	local rt = plot.rt
	if rt == nil then
		return
	end
	for _, item in rt.carry do
		if item.state == "carried" then
			item.state = "pending"
			item.actor = nil
		end
	end
	table.clear(rt.carry)
	markDirty(plot)
end

-- Pedidos ----------------------------------------------------------------------------------------------

local function newOrder(plot, party)
	local rt = plot.rt
	local menu = Restaurant.menu(plot)
	local order = {
		id = rt.nextId,
		party = party,
		kind = party.kind,
		items = {},
		state = "waiting",
		createdAt = now(),
		place = party.table or party.counter,
	}
	rt.nextId += 1
	for _, member in party.members do
		local product = menu[math.random(1, #menu)]
		member.served = false
		table.insert(order.items, { id = rt.nextId, order = order, product = product, member = member, state = "new" })
		rt.nextId += 1
	end
	table.insert(rt.orders, order)
	markDirty(plot)
	return order
end

local function closeOrder(plot, order)
	local index = table.find(plot.rt.orders, order)
	if index then
		table.remove(plot.rt.orders, index)
	end
	markDirty(plot)
end

local function cancelOrder(plot, order)
	for _, item in order.items do
		if item.state == "ready" then
			removeReady(plot, item)
		elseif item.state == "carried" and item.actor == plot.rt.playerActor then
			removeFromCarry(plot, item)
		end
		if item.state ~= "served" then
			item.state = "cancelled"
		end
	end
	order.state = "cancelled"
	closeOrder(plot, order)
end

function Restaurant.takeOrder(plot, order, actor)
	if order.state ~= "waiting" then
		return false
	end
	order.state = "open"
	order.takenAt = now()
	order.claim = nil
	for _, item in order.items do
		item.state = "pending"
	end
	if actor.kind == "player" then
		event(plot, "takeOrder")
	end
	markDirty(plot)
	return true
end

local function orderComplete(order)
	for _, item in order.items do
		if item.state ~= "served" then
			return false
		end
	end
	return true
end

function Restaurant.deliver(plot, order, items, actor)
	local count = 0
	for _, item in items do
		if item.order == order and item.state ~= "cancelled" and item.state ~= "served" then
			item.state = "served"
			item.actor = nil
			local member = item.member
			member.served = true
			if member.rig and Rig.isAlive(member.rig) then
				Rig.hold(member.rig, Props.product(item.product, member.rig.root.CFrame))
			end
			count += 1
		end
	end
	if count > 0 then
		order.lastDeliveryAt = now()
		if actor.kind == "player" then
			event(plot, "deliver", 1)
		end
		local where = if order.place then (order.place.top or order.place.queue) else nil
		if where then
			Props.popup(where + Vector3.new(0, 2, 0), "Entregue!", rgb(110, 255, 140))
		end
	end
	if orderComplete(order) then
		order.state = "done"
		order.servedAt = now()
		closeOrder(plot, order)
	end
	markDirty(plot)
	return count
end

-- Busca de tarefas (usada pela equipe e pelos prompts) --------------------------------------------------

function Restaurant.claimOrderToTake(plot, kind, actor)
	local best = nil
	for _, order in plot.rt.orders do
		if order.state == "waiting" and order.kind == kind and order.claim == nil and order.party.ready then
			if best == nil or order.createdAt < best.createdAt then
				best = order
			end
		end
	end
	if best then
		best.claim = actor
	end
	return best
end

local function stationsFor(plot, product)
	local list = {}
	for _, rec in plot.furniture do
		if rec.kind == "station" and rec.id == product.station then
			table.insert(list, rec)
		end
	end
	return list
end

local function nearest(list, position)
	local best, bestDistance = nil, math.huge
	for _, rec in list do
		local distance = ((rec.use or rec.staffPos or rec.cframe.Position) - position).Magnitude
		if distance < bestDistance then
			best, bestDistance = rec, distance
		end
	end
	return best
end
Restaurant.nearest = nearest

-- Próximo item a preparar. filter(item) opcional.
function Restaurant.claimPendingItem(plot, actor, position, filter)
	local best = nil
	for _, order in plot.rt.orders do
		for _, item in order.items do
			if item.state == "pending" and (filter == nil or filter(item)) then
				if best == nil or (order.takenAt or 0) < (best.order.takenAt or 0) then
					best = item
				end
			end
		end
	end
	if best == nil then
		return nil, nil
	end
	local station = nearest(stationsFor(plot, best.product), position)
	if station == nil then
		return nil, nil
	end
	best.state = "preparing"
	best.actor = actor
	best.station = station
	markDirty(plot)
	return best, station
end

function Restaurant.releaseItem(plot, item)
	if item.state == "preparing" or item.state == "carried" then
		item.state = "pending"
		item.actor = nil
		item.station = nil
		markDirty(plot)
	end
end

-- Itens prontos de pedidos de mesa (ou de balcão, se kind = "counter"), do mesmo lugar.
function Restaurant.claimReadyBatch(plot, actor, kind, limit)
	local place = nil
	local batch = {}
	for _, rec in plot.furniture do
		if rec.ready and #rec.ready > 0 then
			for _, item in rec.ready do
				if item.order.kind == kind and item.claim == nil and item.state == "ready" then
					if place == nil then
						place = rec
					end
					if rec == place and #batch < limit then
						item.claim = actor
						table.insert(batch, item)
					end
				end
			end
		end
		if place then
			break
		end
	end
	return batch, place
end

function Restaurant.pickUp(plot, item, actor)
	if item.state ~= "ready" then
		return false
	end
	removeReady(plot, item)
	item.claim = nil
	item.state = "carried"
	item.actor = actor
	markDirty(plot)
	return true
end

function Restaurant.claimTable(plot, actor, need)
	local list = {}
	for _, rec in plot.furniture do
		if rec.host then
			local wants = (need == "money" and rec.money > 0 and rec.moneyClaim == nil)
				or (need == "dirty" and rec.status == "dirty" and rec.cleanClaim == nil)
			if wants then
				table.insert(list, rec)
			end
		end
	end
	local rec = list[1]
	if rec then
		if need == "money" then
			rec.moneyClaim = actor
		else
			rec.cleanClaim = actor
		end
	end
	return rec
end

function Restaurant.collectMoney(plot, rec, actor)
	rec.moneyClaim = nil
	if rec.money <= 0 then
		return 0
	end
	local amount = rec.money
	rec.money = 0
	if rec.moneyModel then
		rec.moneyModel:Destroy()
		rec.moneyModel = nil
	end
	plot.rt.callbacks.earn(amount, rec.top)
	if actor.kind == "player" then
		event(plot, "collect")
	end
	markDirty(plot)
	return amount
end

function Restaurant.clean(plot, rec, actor)
	rec.cleanClaim = nil
	if rec.status ~= "dirty" then
		return false
	end
	if rec.dirtModel then
		rec.dirtModel:Destroy()
		rec.dirtModel = nil
	end
	rec.status = "free"
	plot:relink()
	Props.sparkle(rec.top + Vector3.new(0, 0.5, 0), rgb(120, 200, 255))
	if actor.kind == "player" then
		event(plot, "clean")
	end
	markDirty(plot)
	return true
end

-- Libera tudo que um funcionário tinha reservado (quando é demitido ou some).
function Restaurant.releaseActor(plot, actor)
	local rt = plot.rt
	if rt == nil then
		return
	end
	for _, order in rt.orders do
		if order.claim == actor then
			order.claim = nil
		end
		for _, item in order.items do
			if item.actor == actor then
				Restaurant.releaseItem(plot, item)
			end
			if item.claim == actor then
				item.claim = nil
			end
		end
	end
	for _, rec in plot.furniture do
		if rec.moneyClaim == actor then
			rec.moneyClaim = nil
		end
		if rec.cleanClaim == actor then
			rec.cleanClaim = nil
		end
	end
end

-- Avaliações e pagamento -------------------------------------------------------------------------------

local function satisfactionOf(plot, party)
	local appeal = plot:appeal()
	local score = 68 + math.min(20, appeal * 0.45) + Restaurant.staffCount(plot, "seguranca") * 3 + Restaurant.staffCount(plot, "dj") * 2
	score -= party.waitPenalty
	return math.clamp(score, 0, 100)
end

local function starsFor(score)
	return math.clamp(math.floor(score / 20) + 1, 1, 5)
end

local function addReview(plot, stars, name)
	local rt = plot.rt
	local phrases = Config.Reviews[stars]
	table.insert(rt.reviews, 1, { stars = stars, text = phrases[math.random(1, #phrases)], name = name })
	while #rt.reviews > 20 do
		table.remove(rt.reviews)
	end
	table.insert(rt.ratings, stars)
	while #rt.ratings > 40 do
		table.remove(rt.ratings, 1)
	end
	if rt.callbacks.review then
		rt.callbacks.review(stars)
	end
	markDirty(plot)
end

function Restaurant.rating(plot)
	local rt = plot.rt
	if rt == nil or #rt.ratings == 0 then
		return 3
	end
	local sum = 0
	for _, stars in rt.ratings do
		sum += stars
	end
	return sum / #rt.ratings
end

local CUSTOMER_NAMES = { "Fernanda", "Lucas", "Ana", "Rafael", "Juliana", "Bruno", "Camila", "Diego", "Aline", "Mateus", "Priscila", "Gustavo", "Renata", "Thiago", "Bianca", "Leandro" }

-- Grupos ----------------------------------------------------------------------------------------------

local function newParty(plot, kind, size)
	local rt = plot.rt
	local party = {
		id = rt.nextId,
		kind = kind,
		members = {},
		state = "arriving",
		rounds = 0,
		waitPenalty = 0,
		session = rt.session,
		spent = 0,
		ready = false,
	}
	rt.nextId += 1
	local side = if math.random() < 0.5 then -1 else 1
	party.side = side
	for i = 1, size do
		local start = plot:sidewalkPoint(side) + Vector3.new(-side * (i - 1) * 2.2, 0, (i % 2) * 1.5)
		local rig = Rig.new(plot.peopleFolder, start, Vector3.new(-side, 0, 0), Rig.randomLook(), "Cliente")
		table.insert(party.members, { rig = rig, served = false })
	end
	table.insert(rt.parties, party)
	rt.present += size
	markDirty(plot)
	return party
end

local function alive(plot, party)
	return plot.rt ~= nil and plot.rt.session == party.session and not party.gone
end

local function setBubble(plot, party, text)
	if party.bubble == nil then
		local adornee = if party.table then party.table.topPart else party.members[1].rig.head
		if adornee == nil then
			return
		end
		party.bubble = Props.bubble(adornee, if party.table then 4 else 2.6)
	end
	if text == "!" then
		party.bubble.call()
	else
		party.bubble.text(text)
	end
end

local function clearBubble(party)
	if party.bubble then
		party.bubble.destroy()
		party.bubble = nil
	end
end

local function orderProducts(order)
	local list = {}
	for _, item in order.items do
		if item.state ~= "served" then
			table.insert(list, item.product)
		end
	end
	return list
end

-- Espera até condition() ser verdadeira, mostrando a paciência no balão. Devolve false se acabou a paciência.
local function waitWithPatience(plot, party, condition, patience, label)
	local started = now()
	while alive(plot, party) do
		if condition() then
			return true, now() - started
		end
		local elapsed = now() - started
		if elapsed > patience then
			return false, elapsed
		end
		if party.bubble then
			if label then
				party.bubble.products(label())
			end
			party.bubble.bar(1 - elapsed / patience)
		end
		task.wait(0.4)
	end
	return false, now() - started
end

local function leaveAll(plot, party, angry)
	party.gone = true
	local rt = plot.rt
	clearBubble(party)
	for index, member in party.members do
		local rig = member.rig
		task.spawn(function()
			if not Rig.isAlive(rig) then
				return
			end
			if angry then
				Props.popup(rig.root.Position + Vector3.new(0, 2.5, 0), "Que demora!", rgb(255, 110, 100))
			end
			if member.seat and member.seated then
				Rig.stand(rig, member.seat.pos, -member.seat.face)
			end
			task.wait((index - 1) * 0.4)
			Rig.walkTo(rig, plot:sidewalkPoint(party.side), C.walkSpeed, function()
				return rt.session == party.session
			end)
			Rig.destroy(rig)
		end)
	end
	local index = table.find(rt.parties, party)
	if index then
		table.remove(rt.parties, index)
	end
	rt.present -= #party.members
	markDirty(plot)
end

local function finishTable(plot, party, angry)
	local rec = party.table
	local order = party.order
	if order and order.state ~= "done" and order.state ~= "cancelled" then
		cancelOrder(plot, order)
	end
	local name = CUSTOMER_NAMES[math.random(1, #CUSTOMER_NAMES)]
	if party.spent > 0 then
		-- quem já bebeu paga o que consumiu, mesmo indo embora bravo (só que sem gorjeta)
		local score = if angry then 0 else satisfactionOf(plot, party)
		local tip = party.spent * (score / 100) ^ 2 * 0.3
		local total = math.floor(party.spent + tip + 0.5)
		rec.money += total
		if rec.moneyModel then
			rec.moneyModel:Destroy()
		end
		rec.moneyModel = Props.money(CFrame.new(rec.top + rec.cframe:VectorToWorldSpace(Vector3.new(0.6, 0, 0.5))), rec.money)
		rec.moneyModel.Parent = plot.effectsFolder
		addReview(plot, if angry then 2 else starsFor(score), name)
		plot.rt.served += #party.members
		event(plot, "served", #party.members)
	elseif angry then
		addReview(plot, 1, name)
	end
	if party.spent > 0 or party.rounds > 0 then
		rec.status = "dirty"
		if rec.dirtModel then
			rec.dirtModel:Destroy()
		end
		rec.dirtModel = Props.dirt(CFrame.new(rec.top), #party.members)
		rec.dirtModel.Parent = plot.effectsFolder
	else
		rec.status = "free"
	end
	rec.party = nil
	if rec.status == "free" then
		plot:relink()
	end
	leaveAll(plot, party, angry)
end

local function runTable(plot, party)
	local rec = party.table
	rec.status = "reserved"
	rec.party = party

	-- cada pessoa anda até a sua cadeira
	local arrived, failed = 0, false
	for index, member in party.members do
		local seat = rec.seats[index]
		member.seat = seat
		task.spawn(function()
			task.wait((index - 1) * 0.5)
			local ok = Rig.walkTo(member.rig, seat.pos, C.walkSpeed, function()
				return alive(plot, party)
			end)
			if ok and alive(plot, party) then
				Rig.sit(member.rig, seat.pos, seat.face, seat.height)
				member.seated = true
			else
				failed = true
			end
			arrived += 1
		end)
	end
	local deadline = now() + 70
	while arrived < #party.members and now() < deadline and alive(plot, party) do
		task.wait(0.3)
	end
	if not alive(plot, party) then
		return
	end
	if failed or arrived < #party.members then
		rec.unreachableUntil = now() + 40
		notifyOnce(plot, "mesa" .. rec.number, "Os clientes não conseguem chegar na Mesa " .. rec.number .. ". Deixe um caminho livre até ela.", "erro")
		rec.status = "free"
		rec.party = nil
		plot:relink()
		leaveAll(plot, party, false)
		return
	end
	rec.status = "occupied"

	while alive(plot, party) do
		party.state = "reading"
		setBubble(plot, party, "...")
		party.bubble.bar(nil)
		task.wait(randomIn(C.readMenu))
		if not alive(plot, party) then
			return
		end
		if #Restaurant.menu(plot) == 0 then
			notifyOnce(plot, "semcardapio", "Seu cardápio está vazio! Coloque uma Geladeira de cerveja no modo construção.", "erro")
			finishTable(plot, party, true)
			return
		end

		party.state = "waitingOrder"
		local order = newOrder(plot, party)
		party.order = order
		party.ready = true
		setBubble(plot, party, "!")
		local taken, waited = waitWithPatience(plot, party, function()
			return order.state ~= "waiting"
		end, C.patienceOrder, nil)
		if not alive(plot, party) then
			return
		end
		if not taken then
			finishTable(plot, party, true)
			return
		end
		party.waitPenalty += math.max(0, waited - 10) * 1.0

		party.state = "waitingFood"
		local served, waitedFood = waitWithPatience(plot, party, function()
			return order.state == "done"
		end, C.patienceDelivery, function()
			return orderProducts(order)
		end)
		if not alive(plot, party) then
			return
		end
		for _, item in order.items do
			if item.state == "served" then
				party.spent += item.product.price
			end
		end
		if not served then
			finishTable(plot, party, party.spent == 0)
			return
		end
		party.waitPenalty += math.max(0, waitedFood - 18) * 0.7
		party.rounds += 1

		party.state = "drinking"
		clearBubble(party)
		local finishAt = now() + randomIn(C.drinkTime)
		while now() < finishAt and alive(plot, party) do
			task.wait(math.random(30, 70) / 10)
			if math.random() < 0.35 and alive(plot, party) then
				local member = party.members[math.random(1, #party.members)]
				if Rig.isAlive(member.rig) then
					Props.popup(member.rig.head.Position + Vector3.new(0, 1.2, 0), Rig.pick({ "Saúde!", "Hahaha", "Que delícia!", "Top demais!", "Bora mais uma?", "Esse lugar é bom!" }), rgb(255, 255, 255))
				end
			end
		end
		if not alive(plot, party) then
			return
		end
		for _, member in party.members do
			Rig.drop(member.rig)
		end
		local score = satisfactionOf(plot, party)
		local again = party.rounds < C.maxRounds and math.random() < C.reorderChance * (score / 80)
		if not again then
			break
		end
	end
	if alive(plot, party) then
		finishTable(plot, party, false)
	end
end

local function counterSpot(rec, position)
	return rec.queue + rec.front * ((position - 1) * 2.6)
end

local function runCounter(plot, party)
	local rec = party.counter
	local member = party.members[1]
	local rig = member.rig
	table.insert(rec.line, party)
	local function leaveLine()
		local index = table.find(rec.line, party)
		if index then
			table.remove(rec.line, index)
		end
	end
	local function check()
		return alive(plot, party) and not rec.removed
	end

	local spot = 0
	local joinedAt = now()
	while check() do
		local position = table.find(rec.line, party)
		if position == nil then
			break
		end
		if position ~= spot then
			spot = position
			if not Rig.walkTo(rig, counterSpot(rec, position), C.walkSpeed, check) then
				leaveLine()
				leaveAll(plot, party, false)
				return
			end
			Rig.face(rig, -rec.front)
		end
		if position == 1 then
			break
		end
		if now() - joinedAt > 120 then
			leaveLine()
			addReview(plot, 1, CUSTOMER_NAMES[math.random(1, #CUSTOMER_NAMES)])
			leaveAll(plot, party, true)
			return
		end
		task.wait(0.3)
	end
	if not check() then
		leaveLine()
		if alive(plot, party) then
			leaveAll(plot, party, false)
		end
		return
	end

	if #Restaurant.menu(plot) == 0 then
		leaveLine()
		leaveAll(plot, party, true)
		return
	end
	local order = newOrder(plot, party)
	party.order = order
	party.ready = true
	party.state = "waitingOrder"
	setBubble(plot, party, "!")
	member.prompt = Instance.new("ProximityPrompt")
	member.prompt.ObjectText = "Cliente do balcão"
	member.prompt.ActionText = "Anotar pedido"
	member.prompt.HoldDuration = 0.3
	member.prompt.MaxActivationDistance = 9
	member.prompt.RequiresLineOfSight = false
	member.prompt.Parent = rig.root
	member.prompt.Triggered:Connect(function(player)
		if player == plot.owner then
			Restaurant.playerCounterCustomer(plot, party)
		end
	end)
	party.prompt = member.prompt

	local taken, waited = waitWithPatience(plot, party, function()
		return order.state ~= "waiting"
	end, C.patienceOrder, nil)
	local served, waitedFood = false, 0
	if taken and alive(plot, party) then
		party.waitPenalty += math.max(0, waited - 10)
		party.state = "waitingFood"
		served, waitedFood = waitWithPatience(plot, party, function()
			return order.state == "done"
		end, C.patienceDelivery, function()
			return orderProducts(order)
		end)
		party.waitPenalty += math.max(0, waitedFood - 15) * 0.7
	end
	leaveLine()
	if member.prompt then
		member.prompt:Destroy()
		member.prompt = nil
	end
	if not alive(plot, party) then
		return
	end
	local name = CUSTOMER_NAMES[math.random(1, #CUSTOMER_NAMES)]
	if served then
		local score = satisfactionOf(plot, party)
		local price = order.items[1].product.price
		local total = math.floor(price * (1 + (score / 100) ^ 2 * 0.25) + 0.5)
		plot.rt.callbacks.earn(total, rig.root.Position)
		addReview(plot, starsFor(score), name)
		plot.rt.served += 1
		event(plot, "served", 1)
		leaveAll(plot, party, false)
	else
		if order.state ~= "cancelled" then
			cancelOrder(plot, order)
		end
		addReview(plot, 1, name)
		leaveAll(plot, party, true)
	end
end

-- Chegada de clientes ------------------------------------------------------------------------------

local function chooseSize(maxSize)
	local weights = C.partyWeights
	local total = 0
	for size = 1, maxSize do
		total += weights[size]
	end
	local roll = math.random() * total
	for size = 1, maxSize do
		roll -= weights[size]
		if roll <= 0 then
			return size
		end
	end
	return 1
end

function Restaurant.groupsPerMinute(plot)
	local rating = Restaurant.rating(plot)
	local base = C.baseGroupsPerMinute + plot:appeal() * 0.035 + plot.level * 0.12
	local staffBonus = 1 + Restaurant.staffCount(plot, "seguranca") * 0.05 + Restaurant.staffCount(plot, "dj") * 0.2
	return base * (0.55 + rating * 0.13) * Restaurant.nightFactor() * staffBonus
end

local function trySpawn(plot)
	local rt = plot.rt
	if rt.present >= C.maxPerPlot then
		return
	end
	if #Restaurant.menu(plot) == 0 then
		notifyOnce(plot, "semcardapio", "Seu cardápio está vazio! Coloque uma Geladeira de cerveja no modo construção.", "erro", 60)
		return
	end
	local tables, counters = {}, {}
	for _, rec in plot.furniture do
		if rec.host and rec.status == "free" and #rec.seats > 0 and (rec.unreachableUntil or 0) < now() then
			table.insert(tables, rec)
		elseif rec.kind == "counter" and #rec.line < 4 then
			table.insert(counters, rec)
		end
	end
	local useCounter = #counters > 0 and (#tables == 0 or math.random() < C.counterChance)
	if useCounter then
		local party = newParty(plot, "counter", 1)
		party.counter = counters[math.random(1, #counters)]
		task.spawn(runCounter, plot, party)
	elseif #tables > 0 then
		local rec = tables[math.random(1, #tables)]
		local size = chooseSize(math.min(4, #rec.seats))
		local party = newParty(plot, "table", size)
		party.table = rec
		rec.status = "reserved"
		task.spawn(runTable, plot, party)
	end
end

-- Prompts do jogador --------------------------------------------------------------------------------

local function carriedFor(plot, order)
	local list = {}
	for _, item in plot.rt.carry do
		if item.order == order then
			table.insert(list, item)
		end
	end
	return list
end

local function tableAction(plot, rec)
	local party = rec.party
	local order = party and party.order
	if order and order.state == "open" and #carriedFor(plot, order) > 0 then
		return "deliver", "Entregar pedido", 0
	end
	if order and order.state == "waiting" and party.ready then
		return "take", "Anotar pedido", 0.35
	end
	if rec.money > 0 then
		return "money", "Pegar " .. formatMoney(rec.money), 0
	end
	if rec.status == "dirty" then
		return "clean", "Limpar mesa", 1
	end
	return nil, nil, 0
end

local function nextPendingFor(plot, station)
	local best = nil
	for _, order in plot.rt.orders do
		for _, item in order.items do
			if item.state == "pending" and item.product.station == station.id then
				if best == nil or (order.takenAt or 0) < (best.order.takenAt or 0) then
					best = item
				end
			end
		end
	end
	return best
end

local function placeLabel(order)
	if order.kind == "counter" then
		return "Caixa"
	end
	local place = order.place
	if place and place.kind == "bar" then
		return "Balcão " .. place.number
	end
	return "Mesa " .. (place and place.number or "?")
end

function Restaurant.playerTable(plot, rec)
	local action = tableAction(plot, rec)
	local actor = plot.rt.playerActor
	if action == "deliver" then
		local order = rec.party.order
		local items = carriedFor(plot, order)
		for _, item in items do
			removeFromCarry(plot, item)
		end
		Restaurant.deliver(plot, order, items, actor)
	elseif action == "take" then
		if Restaurant.takeOrder(plot, rec.party.order, actor) then
			Props.popup(rec.top + Vector3.new(0, 2, 0), "Pedido anotado", rgb(255, 255, 255))
		end
	elseif action == "money" then
		Restaurant.collectMoney(plot, rec, actor)
	elseif action == "clean" then
		if rec.money > 0 then
			Restaurant.collectMoney(plot, rec, actor)
		end
		Restaurant.clean(plot, rec, actor)
	end
	markDirty(plot)
end

function Restaurant.playerCounterCustomer(plot, party)
	local order = party.order
	if order == nil then
		return
	end
	local actor = plot.rt.playerActor
	if order.state == "waiting" then
		Restaurant.takeOrder(plot, order, actor)
	elseif order.state == "open" then
		local items = carriedFor(plot, order)
		for _, item in items do
			removeFromCarry(plot, item)
		end
		if #items > 0 then
			Restaurant.deliver(plot, order, items, actor)
		end
	end
end

function Restaurant.playerPrepare(plot, station)
	local rt = plot.rt
	if #rt.carry >= Config.CarryLimit then
		notifyOnce(plot, "bandeja", "Sua bandeja está cheia. Entregue os pedidos primeiro.", "erro", 4)
		return
	end
	local item = nextPendingFor(plot, station)
	if item == nil then
		return
	end
	item.state = "carried"
	item.actor = rt.playerActor
	table.insert(rt.carry, item)
	updateTray(plot)
	Props.popup(station.use + Vector3.new(0, 5, 0), item.product.name, rgb(255, 255, 255))
	event(plot, "prepare")
	markDirty(plot)
end

function Restaurant.playerPickup(plot, place)
	local rt = plot.rt
	local picked = 0
	for _, item in table.clone(place.ready) do
		if #rt.carry >= Config.CarryLimit then
			break
		end
		if item.claim == nil and Restaurant.pickUp(plot, item, rt.playerActor) then
			table.insert(rt.carry, item)
			picked += 1
		end
	end
	if picked > 0 then
		updateTray(plot)
	elseif #rt.carry >= Config.CarryLimit then
		notifyOnce(plot, "bandeja", "Sua bandeja está cheia. Entregue os pedidos primeiro.", "erro", 4)
	end
end

local function newPrompt(part, key, holdDuration)
	local prompt = Instance.new("ProximityPrompt")
	prompt.MaxActivationDistance = 9
	prompt.RequiresLineOfSight = false
	prompt.HoldDuration = holdDuration or 0
	prompt.KeyboardKeyCode = key or Enum.KeyCode.E
	prompt.Enabled = false
	prompt.Parent = part
	return prompt
end

function Restaurant.attach(plot, rec)
	if rec.host then
		rec.prompt = newPrompt(rec.topPart)
		rec.prompt.ObjectText = (if rec.kind == "bar" then "Balcão " else "Mesa ") .. rec.number
		rec.prompt.Triggered:Connect(function(player)
			if player == plot.owner and plot.rt then
				Restaurant.playerTable(plot, rec)
			end
		end)
		if rec.kind == "bar" then
			rec.pickupPrompt = newPrompt(rec.topPart, Enum.KeyCode.F)
			rec.pickupPrompt.UIOffset = Vector2.new(0, 80)
			rec.pickupPrompt.Triggered:Connect(function(player)
				if player == plot.owner and plot.rt then
					Restaurant.playerPickup(plot, rec)
				end
			end)
		end
	elseif rec.kind == "station" then
		rec.prompt = newPrompt(rec.part)
		rec.prompt.Triggered:Connect(function(player)
			if player == plot.owner and plot.rt then
				Restaurant.playerPrepare(plot, rec)
			end
		end)
		rec.pickupPrompt = newPrompt(rec.part, Enum.KeyCode.F)
		rec.pickupPrompt.UIOffset = Vector2.new(0, 80)
		rec.pickupPrompt.Triggered:Connect(function(player)
			if player == plot.owner and plot.rt then
				Restaurant.playerPickup(plot, rec)
			end
		end)
	elseif rec.kind == "counter" then
		rec.pickupPrompt = newPrompt(rec.part, Enum.KeyCode.F)
		rec.pickupPrompt.Triggered:Connect(function(player)
			if player == plot.owner and plot.rt then
				Restaurant.playerPickup(plot, rec)
			end
		end)
	end
	markDirty(plot)
end

function Restaurant.detach(plot, rec)
	if rec.ready then
		for _, item in table.clone(rec.ready) do
			removeReady(plot, item)
			item.state = "pending"
		end
	end
	if rec.moneyModel then
		rec.moneyModel:Destroy()
	end
	if rec.dirtModel then
		rec.dirtModel:Destroy()
	end
	markDirty(plot)
end

function Restaurant.canModify(plot, rec)
	if rec.host and (rec.status ~= "free" or rec.money > 0) then
		return false, "A mesa " .. rec.number .. " está em uso. Espere ela ficar livre e limpa."
	end
	local host = rec.attached
	if rec.kind == "chair" and host and not host.removed and (host.status ~= "free" or host.money > 0) then
		return false, "Essa cadeira é da mesa " .. host.number .. ", que está em uso."
	end
	if rec.ready and #rec.ready > 0 then
		return false, "Tem pedido pronto em cima. Pegue antes de mexer."
	end
	if rec.kind == "counter" and #rec.line > 0 then
		return false, "Tem cliente na fila desse balcão."
	end
	if plot.rt then
		for _, order in plot.rt.orders do
			for _, item in order.items do
				if item.state == "preparing" and item.station == rec then
					return false, "Alguém está usando essa estação."
				end
			end
		end
	end
	return true, nil
end

local function refreshPrompts(plot)
	local rt = plot.rt
	for _, rec in plot.furniture do
		if rec.host and rec.prompt then
			local action, text, hold = tableAction(plot, rec)
			rec.prompt.Enabled = action ~= nil
			if action then
				rec.prompt.ActionText = text
				rec.prompt.HoldDuration = hold
			end
			if rec.pickupPrompt then
				local ready = #rec.ready
				rec.pickupPrompt.Enabled = ready > 0
				rec.pickupPrompt.ActionText = "Pegar pedidos prontos (" .. ready .. ")"
				rec.pickupPrompt.ObjectText = "Balcão " .. rec.number
			end
		elseif rec.kind == "station" and rec.prompt then
			local item = nextPendingFor(plot, rec)
			rec.prompt.Enabled = item ~= nil and #rt.carry < Config.CarryLimit
			if item then
				rec.prompt.ActionText = "Preparar " .. item.product.name
				rec.prompt.ObjectText = placeLabel(item.order)
				rec.prompt.HoldDuration = item.product.prep
			end
			local ready = #rec.ready
			rec.pickupPrompt.Enabled = ready > 0
			rec.pickupPrompt.ActionText = "Pegar pedidos prontos (" .. ready .. ")"
			rec.pickupPrompt.ObjectText = rec.item.name
		elseif rec.kind == "counter" and rec.pickupPrompt then
			local ready = #rec.ready
			rec.pickupPrompt.Enabled = ready > 0
			rec.pickupPrompt.ActionText = "Pegar pedidos prontos (" .. ready .. ")"
			rec.pickupPrompt.ObjectText = "Balcão"
		end
	end
	for _, party in rt.parties do
		if party.prompt and party.order then
			local order = party.order
			if order.state == "waiting" then
				party.prompt.Enabled = true
				party.prompt.ActionText = "Anotar pedido"
			elseif order.state == "open" and #carriedFor(plot, order) > 0 then
				party.prompt.Enabled = true
				party.prompt.ActionText = "Entregar " .. order.items[1].product.name
			else
				party.prompt.Enabled = false
			end
		end
	end
end

-- Ciclo de vida -------------------------------------------------------------------------------------

function Restaurant.setup(plot, callbacks, saved)
	plot.sessionCounter = (plot.sessionCounter or 0) + 1
	plot.rt = {
		session = plot.sessionCounter,
		parties = {},
		orders = {},
		carry = {},
		nextId = 1,
		present = 0,
		served = 0,
		reviews = {},
		ratings = {},
		warnings = {},
		callbacks = callbacks,
		nextSpawn = now() + 4,
		dirty = true,
		playerActor = { kind = "player", name = plot.owner.DisplayName },
	}
	if saved and type(saved.ratings) == "table" then
		for _, stars in saved.ratings do
			if type(stars) == "number" then
				table.insert(plot.rt.ratings, math.clamp(math.floor(stars), 1, 5))
			end
		end
	end
	plot.hooks.added = Restaurant.attach
	plot.hooks.removed = Restaurant.detach
	plot.hooks.canModify = Restaurant.canModify
	for _, rec in plot.furniture do
		Restaurant.attach(plot, rec)
	end
end

function Restaurant.teardown(plot)
	plot.rt = nil
	plot.hooks = {}
end

function Restaurant.tick(plot)
	local rt = plot.rt
	if rt == nil then
		return
	end
	if now() >= rt.nextSpawn then
		local rate = Restaurant.groupsPerMinute(plot)
		rt.nextSpawn = now() + (60 / rate) * (0.6 + math.random() * 0.8)
		trySpawn(plot)
	end
	refreshPrompts(plot)
end

-- Resumo para a interface.
function Restaurant.snapshot(plot)
	local rt = plot.rt
	local orders = {}
	for _, order in rt.orders do
		local icons = {}
		for _, item in order.items do
			table.insert(icons, { item.product.id, item.state })
		end
		local started = order.takenAt or order.createdAt
		local patience = if order.state == "waiting" then C.patienceOrder else C.patienceDelivery
		table.insert(orders, {
			label = placeLabel(order),
			state = order.state,
			icons = icons,
			wait = math.floor(now() - started),
			patience = math.clamp(1 - (now() - started) / patience, 0, 1),
		})
		if #orders >= 12 then
			break
		end
	end
	local carry = {}
	for _, item in rt.carry do
		table.insert(carry, { item.product.id, placeLabel(item.order) })
	end
	local free, dirty, money = 0, 0, 0
	for _, rec in plot.furniture do
		if rec.host and (#rec.seats > 0 or rec.status ~= "free") then
			if rec.status == "free" then
				free += 1
			elseif rec.status == "dirty" then
				dirty += 1
			end
			money += rec.money
		end
	end
	local menu = {}
	for _, product in Restaurant.menu(plot) do
		table.insert(menu, product.id)
	end
	return {
		orders = orders,
		carry = carry,
		present = rt.present,
		freeTables = free,
		dirtyTables = dirty,
		tableMoney = money,
		rating = Restaurant.rating(plot),
		reviews = rt.reviews,
		menu = menu,
		groupsPerMinute = Restaurant.groupsPerMinute(plot),
		night = Restaurant.nightFactor(),
	}
end

return Restaurant
