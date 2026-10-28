-- Util: formatação e a adega inicial que todo jogador novo recebe.

local Util = {}

function Util.formatMoney(amount)
	local negative = amount < 0
	local digits = tostring(math.floor(math.abs(amount)))
	local grouped = digits:reverse():gsub("(%d%d%d)", "%1."):reverse()
	if grouped:sub(1, 1) == "." then
		grouped = grouped:sub(2)
	end
	return (if negative then "-R$ " else "R$ ") .. grouped
end

function Util.formatNumber(amount)
	return (Util.formatMoney(amount):gsub("^R%$ ", ""))
end

function Util.formatDecimal(value)
	return (string.format("%.1f", value):gsub("%.", ","))
end

function Util.clockText(hour)
	local h = math.floor(hour)
	local m = math.floor((hour - h) * 6) * 10
	return string.format("%02d:%02d", h, m)
end

-- Adega inicial (terreno de 36 x 36): paredes, fachada com portas de enrolar, balcão,
-- geladeira e mesas na calçada. { id, x, z, rotação }.
Util.StarterLayout = {
	-- fundo
	{ "parede_reboco", -16, 35, 0 }, { "parede_reboco", -12, 35, 0 }, { "parede_reboco", -8, 35, 0 },
	{ "parede_reboco", -4, 35, 0 }, { "parede_reboco", 0, 35, 0 }, { "parede_reboco", 4, 35, 0 },
	{ "parede_reboco", 8, 35, 0 }, { "parede_reboco", 12, 35, 0 }, { "parede_reboco", 16, 35, 0 },
	-- laterais
	{ "parede_reboco", -17, 20, 1 }, { "parede_reboco", -17, 24, 1 }, { "parede_reboco", -17, 28, 1 }, { "parede_reboco", -17, 32, 1 },
	{ "parede_reboco", 17, 20, 1 }, { "parede_reboco", 17, 24, 1 }, { "parede_reboco", 17, 28, 1 }, { "parede_reboco", 17, 32, 1 },
	-- fachada
	{ "parede_tijolo", -16, 17, 0 }, { "parede_janela", -12, 17, 0 },
	{ "porta_enrolar", -8, 17, 0 }, { "porta_enrolar", -4, 17, 0 }, { "porta_enrolar", 0, 17, 0 },
	{ "porta_enrolar", 4, 17, 0 }, { "porta_enrolar", 8, 17, 0 },
	{ "parede_janela", 12, 17, 0 }, { "parede_tijolo", 16, 17, 0 },
	-- dentro
	{ "balcao_caixa", 0, 26, 0 },
	{ "geladeira_cerveja", -10, 33, 0 },
	{ "engradados", 13, 33, 0 }, { "engradados", 15, 33, 0 },
	{ "mesa_dupla", -11, 22, 0 }, { "mesa_dupla", 11, 22, 0 },
	-- calçada
	{ "mesa_plastico", -11, 7, 0 }, { "mesa_plastico", 11, 7, 0 },
	{ "vaso_planta", -15, 15, 0 }, { "vaso_planta", 15, 15, 0 },
	{ "poste_luz", -17, 1, 0 }, { "poste_luz", 17, 1, 0 },
}

return Util
