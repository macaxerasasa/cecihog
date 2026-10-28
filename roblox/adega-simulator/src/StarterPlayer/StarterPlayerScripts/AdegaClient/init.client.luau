-- AdegaClient (LocalScript em StarterPlayer > StarterPlayerScripts, com os módulos UI, Hud, Panels e Build dentro)
-- Recebe o estado do servidor e distribui para a HUD, as janelas e o modo construção.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("AdegaShared")
local Config = require(Shared:WaitForChild("Config"))
local Catalog = require(Shared:WaitForChild("Catalog"))
local Util = require(Shared:WaitForChild("Util"))

local UI = require(script:WaitForChild("UI"))
local Hud = require(script:WaitForChild("Hud"))
local Panels = require(script:WaitForChild("Panels"))
local Build = require(script:WaitForChild("Build"))

local remotes = ReplicatedStorage:WaitForChild("AdegaRemotes")
local stateEvent = remotes:WaitForChild("Estado")
local noticeEvent = remotes:WaitForChild("Aviso")
local actionFunction = remotes:WaitForChild("Acao")

local App = {
	Config = Config,
	Catalog = Catalog,
	Util = Util,
	state = nil,
}

function App.toast(text, kind)
	Hud.toast(text, kind)
end

-- Chama uma ação no servidor. Mostra o erro como aviso; com quiet = true não mostra a mensagem de sucesso.
function App.invoke(action, payload, quiet)
	local ok, result = pcall(function()
		return actionFunction:InvokeServer(action, payload)
	end)
	if not ok or type(result) ~= "table" then
		Hud.toast("Sem resposta do servidor. Tente de novo.", "erro")
		return nil
	end
	if not result.ok then
		Hud.toast(result.msg or "Não deu certo", "erro")
	elseif result.msg and not quiet then
		Hud.toast(result.msg, "compra")
	end
	return result
end

function App.openMenu(id)
	if id == "construir" then
		Build.toggle()
	elseif id == "voltar" then
		App.invoke("voltar", {}, true)
	else
		if Build.isActive() then
			Build.setActive(false)
		end
		Panels.open(id)
	end
end

function App.onBuildMode(on)
	Hud.setBuildMode(on)
end

-- Itens novos quando a adega sobe de nível, para o banner.
local function unlockText(level)
	local names = {}
	for _, item in Catalog.Items do
		if item.level == level then
			table.insert(names, item.name)
		end
	end
	for _, product in Config.Products do
		if product.level == level then
			table.insert(names, product.name)
		end
	end
	for _, role in Config.Staff do
		if role.level == level then
			table.insert(names, role.name)
		end
	end
	if #names == 0 then
		return "Mais clientes e mais vagas na equipe!"
	end
	if #names > 4 then
		return "Liberou " .. table.concat(names, ", ", 1, 4) .. " e mais " .. (#names - 4) .. " itens"
	end
	return "Liberou " .. table.concat(names, ", ")
end

local function start(name, module)
	local ok, err = pcall(module.init, App)
	if not ok then
		warn("[Adega] Erro iniciando " .. name .. ":", err)
	end
end
start("Hud", Hud)
start("Panels", Panels)
start("Build", Build)

stateEvent.OnClientEvent:Connect(function(state)
	local previous = App.state
	App.state = state
	for name, update in { Hud = Hud.update, Panels = Panels.update, Build = Build.update } do
		local ok, err = pcall(update, state, previous)
		if not ok then
			warn("[Adega] Erro atualizando " .. name .. ":", err)
		end
	end
end)

noticeEvent.OnClientEvent:Connect(function(text, kind, extra)
	if kind == "resumo" then
		Hud.summary(extra or {})
	elseif kind == "nivel" and type(extra) == "table" and extra.level then
		Hud.banner("Nível " .. extra.level, unlockText(extra.level))
	else
		Hud.toast(text, kind)
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.KeyCode == Enum.KeyCode.B then
		App.openMenu("construir")
	elseif input.KeyCode == Enum.KeyCode.G and not Build.isActive() then
		App.openMenu("equipe")
	elseif input.KeyCode == Enum.KeyCode.M and not Build.isActive() then
		App.openMenu("cardapio")
	end
end)

local camera = workspace.CurrentCamera
if camera then
	camera:GetPropertyChangedSignal("ViewportSize"):Connect(UI.applyScale)
end
UI.applyScale()
-- No começo a câmera ainda pode estar com tamanho errado; reaplica a escala algumas vezes.
for _, delay in { 0.5, 2, 5 } do
	task.delay(delay, UI.applyScale)
end
