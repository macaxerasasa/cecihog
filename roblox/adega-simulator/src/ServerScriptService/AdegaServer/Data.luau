-- Data: salvar e carregar o progresso, com novas tentativas quando o DataStore falha.

local DataStoreService = game:GetService("DataStoreService")

local Data = {}

local store = nil

function Data.init(name)
	local ok, result = pcall(function()
		return DataStoreService:GetDataStore(name)
	end)
	if ok then
		store = result
	else
		warn("[Adega] DataStore indisponível, o progresso não será salvo:", result)
	end
	return store ~= nil
end

local function key(userId)
	return "jogador_" .. userId
end

-- Devolve (true, dados ou nil) se a leitura funcionou, ou (false, nil) se falhou.
function Data.load(userId)
	if store == nil then
		return false, nil
	end
	for attempt = 1, 3 do
		local ok, result = pcall(function()
			return store:GetAsync(key(userId))
		end)
		if ok then
			return true, result
		end
		warn("[Adega] Falha ao carregar (tentativa " .. attempt .. "):", result)
		task.wait(attempt)
	end
	return false, nil
end

function Data.save(userId, data)
	if store == nil then
		return false
	end
	for attempt = 1, 3 do
		local ok, err = pcall(function()
			store:SetAsync(key(userId), data)
		end)
		if ok then
			return true
		end
		warn("[Adega] Falha ao salvar (tentativa " .. attempt .. "):", err)
		task.wait(attempt)
	end
	return false
end

return Data
