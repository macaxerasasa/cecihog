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

-- Adega inicial (terreno de 36 x 36): paredes, fachada com portas de enrolar, balcão com caixa,
-- geladeira, um bar com banquetas e mesas com cadeiras. { id, x, z, rotação }.
-- Rotação 1 vira o móvel para -X, 2 para +Z (o fundo) e 3 para +X.
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
	-- balcão, geladeira e bar
	{ "balcao_caixa", 0, 26, 0 },
	{ "geladeira_cerveja", -10, 33, 0 },
	{ "engradados", -15, 33, 0 }, { "engradados", -13, 33, 0 },
	{ "balcao_bar_reto", 10, 31, 0 }, { "balcao_bar_reto", 14, 31, 0 },
	{ "banqueta", 9, 29, 2 }, { "banqueta", 11, 29, 2 }, { "banqueta", 13, 29, 2 }, { "banqueta", 15, 29, 2 },
	-- mesas de dentro
	{ "mesa_plastico", -12, 22, 0 },
	{ "cadeira_vermelha", -15, 21, 3 }, { "cadeira_vermelha", -15, 23, 3 }, { "cadeira_vermelha", -9, 21, 1 }, { "cadeira_vermelha", -9, 23, 1 },
	{ "mesa_plastico", 12, 22, 0 },
	{ "cadeira_vermelha", 9, 21, 3 }, { "cadeira_vermelha", 9, 23, 3 }, { "cadeira_vermelha", 15, 21, 1 }, { "cadeira_vermelha", 15, 23, 1 },
	-- calçada
	{ "mesa_plastico", -10, 8, 0 },
	{ "cadeira_vermelha", -13, 7, 3 }, { "cadeira_vermelha", -13, 9, 3 }, { "cadeira_vermelha", -7, 7, 1 }, { "cadeira_vermelha", -7, 9, 1 },
	{ "mesa_plastico", 10, 8, 0 },
	{ "cadeira_vermelha", 7, 7, 3 }, { "cadeira_vermelha", 7, 9, 3 }, { "cadeira_vermelha", 13, 7, 1 }, { "cadeira_vermelha", 13, 9, 1 },
	{ "vaso_planta", -15, 15, 0 }, { "vaso_planta", 15, 15, 0 },
	{ "poste_luz", -17, 1, 0 }, { "poste_luz", 17, 1, 0 },
}

return Util
