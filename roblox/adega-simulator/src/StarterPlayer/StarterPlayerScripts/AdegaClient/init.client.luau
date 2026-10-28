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
			table.insert(names, product.icon .. " " .. product.name)
		end
	end
	for _, role in Config.Staff do
		if role.level == level then
			table.insert(names, role.icon .. " " .. role.name)
		end
	end
	if #names == 0 then
		return "Mais clientes e mais vagas na equipe!"
	end
	if #names > 4 then
		return "Liberado: " .. table.concat(names, ", ", 1, 4) .. " e mais " .. (#names - 4)
	end
	return "Liberado: " .. table.concat(names, ", ")
end

Hud.init(App)
Panels.init(App)
Build.init(App)

stateEvent.OnClientEvent:Connect(function(state)
	local previous = App.state
	App.state = state
	Hud.update(state, previous)
	Panels.update(state)
	Build.update(state)
end)

noticeEvent.OnClientEvent:Connect(function(text, kind, extra)
	if kind == "resumo" then
		Hud.summary(extra or {})
	elseif kind == "nivel" and type(extra) == "table" and extra.level then
		Hud.banner("NÍVEL " .. extra.level .. "!", unlockText(extra.level))
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
