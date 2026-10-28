-- Looks: aparência dos bonecos (clientes e funcionários).
-- Uma aparência é guardada só com números e nomes, para caber no salvamento:
-- { skin = 1..#Skins, shirt = 1..#Colors, pants = 1..#Colors, shoes = 1..#Colors, hair = id do estilo, hairColor = 1..#HairColors }
-- O mesmo código pinta o boneco no servidor e na prévia da tela de personalização.

local Looks = {}

local rgb = Color3.fromRGB

Looks.Skins = {
	rgb(255, 224, 196), rgb(242, 200, 160), rgb(224, 172, 128), rgb(198, 140, 92),
	rgb(160, 104, 64), rgb(124, 78, 48), rgb(92, 58, 36), rgb(66, 42, 28),
}

Looks.Colors = {
	rgb(245, 245, 245), rgb(30, 30, 34), rgb(120, 120, 128), rgb(214, 48, 49),
	rgb(255, 127, 80), rgb(253, 203, 110), rgb(0, 148, 50), rgb(85, 239, 196),
	rgb(9, 132, 227), rgb(29, 53, 87), rgb(108, 92, 231), rgb(232, 67, 147),
	rgb(116, 76, 46), rgb(196, 160, 112), rgb(112, 26, 44), rgb(0, 98, 102),
}

Looks.HairColors = {
	rgb(24, 18, 14), rgb(66, 40, 22), rgb(120, 72, 36), rgb(196, 150, 84),
	rgb(236, 206, 150), rgb(160, 50, 30), rgb(150, 150, 156), rgb(240, 240, 240),
	rgb(214, 48, 49), rgb(9, 132, 227), rgb(232, 67, 147), rgb(253, 203, 110),
}

Looks.Hairs = {
	{ id = "careca", name = "Careca" },
	{ id = "curto", name = "Curto" },
	{ id = "longo", name = "Longo" },
	{ id = "coque", name = "Coque" },
	{ id = "afro", name = "Black power" },
	{ id = "trancas", name = "Tranças" },
	{ id = "bone", name = "Boné" },
	{ id = "bone_tras", name = "Boné pra trás" },
	{ id = "gorro", name = "Gorro" },
	{ id = "chef", name = "Touca de chef" },
	{ id = "fone", name = "Fone de DJ" },
}

local HAIR_BY_ID = {}
for index, hair in Looks.Hairs do
	HAIR_BY_ID[hair.id] = index
end

-- Partes do avatar R15 por grupo de cor.
local SHIRT = { UpperTorso = true, LeftUpperArm = true, RightUpperArm = true, Manga = true }
local PANTS = { LowerTorso = true, LeftUpperLeg = true, LeftLowerLeg = true, RightUpperLeg = true, RightLowerLeg = true, LeftLeg = true, RightLeg = true }
local SHOES = { LeftFoot = true, RightFoot = true }
local SKIN = { Head = true, LeftLowerArm = true, RightLowerArm = true, LeftHand = true, RightHand = true, LeftArm = true, RightArm = true }

local function clampIndex(value, list, default)
	if type(value) ~= "number" then
		return default
	end
	return math.clamp(math.floor(value), 1, #list)
end

-- Garante que uma aparência vinda de fora (salvamento, cliente) é válida.
function Looks.sanitize(look, defaults)
	look = if type(look) == "table" then look else {}
	defaults = defaults or {}
	return {
		skin = clampIndex(look.skin, Looks.Skins, defaults.skin or 2),
		shirt = clampIndex(look.shirt, Looks.Colors, defaults.shirt or 1),
		pants = clampIndex(look.pants, Looks.Colors, defaults.pants or 2),
		shoes = clampIndex(look.shoes, Looks.Colors, defaults.shoes or 2),
		hair = if type(look.hair) == "string" and HAIR_BY_ID[look.hair] then look.hair else (defaults.hair or "curto"),
		hairColor = clampIndex(look.hairColor, Looks.HairColors, defaults.hairColor or 1),
	}
end

function Looks.random(random)
	random = random or Random.new()
	local hairs = { "curto", "curto", "longo", "longo", "coque", "afro", "trancas", "bone", "bone_tras", "gorro", "careca" }
	return {
		skin = random:NextInteger(1, #Looks.Skins),
		shirt = random:NextInteger(1, #Looks.Colors),
		pants = ({ 2, 3, 10, 13, 14, 1, 9 })[random:NextInteger(1, 7)],
		shoes = ({ 1, 2, 3, 13 })[random:NextInteger(1, 4)],
		hair = hairs[random:NextInteger(1, #hairs)],
		hairColor = random:NextInteger(1, 6),
	}
end

-- Tamanho visível da cabeça (a cabeça clássica é uma peça 2x1x1 com malha).
local function headSize(head)
	if head:IsA("MeshPart") then
		return head.Size
	end
	local mesh = head:FindFirstChildOfClass("SpecialMesh")
	if mesh and mesh.MeshType == Enum.MeshType.Head then
		local s = mesh.Scale.X / 1.25
		return Vector3.new(1.2 * s, 1.2 * s, 1.2 * s)
	end
	return Vector3.new(math.min(head.Size.X, head.Size.Z), head.Size.Y, math.min(head.Size.X, head.Size.Z))
end

local function accessory(folder, head, name, size, offset, color, shape, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Massless = true
	part.Anchored = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	if shape == "ellipsoid" then
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.Sphere
		mesh.Parent = part
	elseif shape == "cylinder" then
		part.Shape = Enum.PartType.Cylinder
	end
	part.CFrame = head.CFrame * offset
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = head
	weld.Part1 = part
	weld.Parent = part
	part.Parent = folder
	return part
end

local function buildHair(folder, head, style, color, shirtColor)
	local s = headSize(head)
	local w, h = s.X, s.Y
	local up = CFrame.Angles(0, 0, math.rad(90))
	if style == "curto" then
		accessory(folder, head, "Cabelo", Vector3.new(w * 1.1, h * 0.72, w * 1.14), CFrame.new(0, h * 0.22, w * 0.05), color, "ellipsoid")
	elseif style == "longo" then
		accessory(folder, head, "Cabelo", Vector3.new(w * 1.12, h * 0.74, w * 1.16), CFrame.new(0, h * 0.22, w * 0.05), color, "ellipsoid")
		accessory(folder, head, "CabeloTras", Vector3.new(w * 1.02, h * 1.45, w * 0.5), CFrame.new(0, -h * 0.28, w * 0.36), color, "ellipsoid")
	elseif style == "coque" then
		accessory(folder, head, "Cabelo", Vector3.new(w * 1.1, h * 0.7, w * 1.14), CFrame.new(0, h * 0.22, w * 0.05), color, "ellipsoid")
		accessory(folder, head, "Coque", Vector3.new(w * 0.5, w * 0.5, w * 0.5), CFrame.new(0, h * 0.6, w * 0.3), color, "ellipsoid")
	elseif style == "afro" then
		accessory(folder, head, "Cabelo", Vector3.new(w * 1.6, h * 1.25, w * 1.55), CFrame.new(0, h * 0.32, w * 0.12), color, "ellipsoid", Enum.Material.Fabric)
	elseif style == "trancas" then
		accessory(folder, head, "Cabelo", Vector3.new(w * 1.08, h * 0.66, w * 1.1), CFrame.new(0, h * 0.24, w * 0.05), color, "ellipsoid")
		for _, x in { -0.28, 0, 0.28 } do
			accessory(folder, head, "Tranca", Vector3.new(w * 0.2, h * 1.1, w * 0.2), CFrame.new(x * w, -h * 0.25, w * 0.46), color, "ellipsoid")
		end
	elseif style == "bone" or style == "bone_tras" then
		local back = style == "bone_tras"
		accessory(folder, head, "Bone", Vector3.new(w * 1.1, h * 0.62, w * 1.12), CFrame.new(0, h * 0.28, 0), shirtColor, "ellipsoid")
		local brimZ = if back then w * 0.55 else -w * 0.55
		accessory(folder, head, "Aba", Vector3.new(0.08, w * 0.85, w * 0.85), CFrame.new(0, h * 0.2, brimZ) * up, shirtColor, "cylinder")
	elseif style == "gorro" then
		accessory(folder, head, "Gorro", Vector3.new(w * 1.12, h * 0.85, w * 1.14), CFrame.new(0, h * 0.3, 0.02), shirtColor, "ellipsoid", Enum.Material.Fabric)
		accessory(folder, head, "Barra", Vector3.new(h * 0.18, w * 1.16, w * 1.16), CFrame.new(0, h * 0.08, 0.02) * up, shirtColor, "cylinder", Enum.Material.Fabric)
	elseif style == "chef" then
		accessory(folder, head, "Touca", Vector3.new(h * 0.65, w * 0.98, w * 0.98), CFrame.new(0, h * 0.62, 0) * up, rgb(250, 250, 250), "cylinder")
		accessory(folder, head, "TopoTouca", Vector3.new(w * 1.2, h * 0.55, w * 1.2), CFrame.new(0, h * 0.95, 0), rgb(250, 250, 250), "ellipsoid")
	elseif style == "fone" then
		accessory(folder, head, "Cabelo", Vector3.new(w * 1.1, h * 0.7, w * 1.14), CFrame.new(0, h * 0.22, w * 0.05), color, "ellipsoid")
		accessory(folder, head, "Arco", Vector3.new(w * 1.25, 0.14, 0.22), CFrame.new(0, h * 0.58, 0), rgb(25, 25, 28))
		for _, x in { -1, 1 } do
			accessory(folder, head, "Concha", Vector3.new(0.22, w * 0.5, w * 0.5), CFrame.new(x * w * 0.56, 0.02, 0), rgb(25, 25, 28), "cylinder")
			accessory(folder, head, "LuzFone", Vector3.new(0.05, w * 0.32, w * 0.32), CFrame.new(x * w * 0.68, 0.02, 0), shirtColor, "cylinder", Enum.Material.Neon)
		end
	end
end

-- Pinta o boneco e refaz cabelo/chapéu. Funciona no avatar R15 e no boneco de blocos.
function Looks.apply(model, look)
	look = Looks.sanitize(look)
	local skin = Looks.Skins[look.skin]
	local shirt = Looks.Colors[look.shirt]
	local pants = Looks.Colors[look.pants]
	local shoes = Looks.Colors[look.shoes]
	local blocky = model:GetAttribute("Blocos") == true
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") and part.Parent == model then
			local name = part.Name
			if name == "HumanoidRootPart" then
				if blocky then
					part.Color = shirt
				end
			elseif SHIRT[name] then
				part.Color = shirt
			elseif PANTS[name] then
				part.Color = pants
			elseif SHOES[name] then
				part.Color = shoes
			elseif SKIN[name] then
				part.Color = skin
			end
		end
	end
	local old = model:FindFirstChild("Acessorios")
	if old then
		old:Destroy()
	end
	local head = model:FindFirstChild("Head")
	if head then
		local folder = Instance.new("Folder")
		folder.Name = "Acessorios"
		folder.Parent = model
		buildHair(folder, head, look.hair, Looks.HairColors[look.hairColor], shirt)
	end
end

return Looks
