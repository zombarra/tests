-- Auto Detector con cambio inteligente de loadouts

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PetsService = RS.GameEvents.PetsService
local ModelService = RS.GameEvents.Model

-- Función para obtener el peso de una pet
local function getPetWeight(petName)
    local weightPattern = "%[(%d+%.?%d*) KG%]"
    local weight = petName:match(weightPattern)
    return weight and tonumber(weight) or 0
end

-- Función para verificar si una pet está en favoritos
local function isPetFavorited(tool)
    -- Método 1: Verificar todos los atributos posibles
    local attributes = {"Favorited", "IsFavorite", "Starred", "IsFav", "Fav", "Favorite", "Star"}
    for _, attr in pairs(attributes) do
        if tool:GetAttribute(attr) then
            return true
        end
    end
    
    -- Método 2: Verificar en el Handle
    local handle = tool:FindFirstChild("Handle")
    if handle then
        -- Verificar atributos del handle también
        for _, attr in pairs(attributes) do
            if handle:GetAttribute(attr) then
                return true
            end
        end
        
        -- Buscar cualquier GUI relacionado con favoritos
        for _, child in pairs(handle:GetDescendants()) do
            local name = child.Name:lower()
            if name:find("favorite") or name:find("star") or name:find("fav") then
                if child:IsA("BillboardGui") or child:IsA("SurfaceGui") then
                    if child.Enabled and child.Visible then
                        return true
                    end
                elseif child:IsA("ImageLabel") or child:IsA("TextLabel") then
                    if child.Visible then
                        return true
                    end
                end
            end
        end
    end
    
    -- Método 3: Verificar el nombre del tool
    local toolName = tool.Name:lower()
    if toolName:find("⭐") or toolName:find("★") or toolName:find("fav") then
        return true
    end
    
    -- Método 4: Verificar si el tool tiene propiedades especiales
    if tool:FindFirstChild("FavoriteIcon") or tool:FindFirstChild("StarIcon") or tool:FindFirstChild("Favorite") then
        return true
    end
    
    return false
end

-- Función para cambiar loadout
local function switchToLoadout(loadoutNumber)
    local args = {
        [1] = "SwapPetLoadout",
        [2] = 1
    }
    PetsService:FireServer(unpack(args))
    print("📦 Cambiado al loadout 1")
    task.wait(0.5)
end

-- Función para detectar huevos listos para hatch
local function checkEggsReady()
    -- Método 1: Usar el RemoteEvent que proporcionaste
    local success = pcall(function()
        ModelService.EggReadyToHatch_RE:FireServer()
    end)
    
    if success then
        return true
    end
    
    -- Método 2: Buscar huevos en workspace con indicadores visuales
    local function findReadyEggs()
        local readyEggs = 0
        
        -- Buscar en Farm
        local farm = workspace:FindFirstChild("Farm")
        if farm then
            for _, descendant in pairs(farm:GetDescendants()) do
                if descendant.Name:lower():find("egg") then
                    -- Verificar si tiene indicadores de "ready"
                    local gui = descendant:FindFirstChildOfClass("BillboardGui")
                    if gui then
                        local textLabel = gui:FindFirstChildOfClass("TextLabel")
                        if textLabel then
                            local text = textLabel.Text:lower()
                            if text:find("ready") or text:find("hatch") or text:find("!") then
                                readyEggs = readyEggs + 1
                            end
                        end
                    end
                    
                    -- Verificar atributos
                    if descendant:GetAttribute("ReadyToHatch") or descendant:GetAttribute("CanHatch") then
                        readyEggs = readyEggs + 1
                    end
                end
            end
        end
        
        return readyEggs > 0
    end
    
    return findReadyEggs()
end

-- Función para detectar pets que se pueden vender (SIN venderlas)
local function checkPetsToSell()
    local character = LocalPlayer.Character
    local backpack = LocalPlayer:WaitForChild("Backpack")
    if not character or not backpack then return false end
    
    local petsToSell = {
        "Scarlet Macaw", "Ostrich", "Peacock", "Capybara", "Sparrow",
        "Canary", "Gorilla", "Toucan"
    }
    
    -- Verificar en backpack
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            for _, petType in pairs(petsToSell) do
                if tool.Name:find(petType) then
                    local weight = getPetWeight(tool.Name)
                    if not isPetFavorited(tool) and weight < 7 and weight > 0 then
                        return true -- Hay al menos una pet para vender
                    end
                    break
                end
            end
        end
    end
    
    -- Verificar en character
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            for _, petType in pairs(petsToSell) do
                if tool.Name:find(petType) then
                    local weight = getPetWeight(tool.Name)
                    if not isPetFavorited(tool) and weight < 4 and weight > 0 then
                        return true -- Hay al menos una pet para vender
                    end
                    break
                end
            end
        end
    end
    
    return false -- No hay pets para vender
end

-- Loop principal de detección inteligente
local function autoDetectAndSwitch()
    print("🔍 Iniciando detección automática inteligente...")
    
    while true do
        local eggsReady = checkEggsReady()
        local petsToSell = checkPetsToSell()
        
        if eggsReady then
            print("🥚 ¡Huevos detectados listos para hatch!")
            print("⏳ Esperando...")
            task.wait(10)
        elseif petsToSell then
            print("💰 ¡Pets detectadas para vender!")
            print("⏳ Esperando...")
            task.wait(10)
        else
            print("🎯 No hay huevos listos ni pets para vender")
            switchToLoadout(1)
            print("✅ Loadout cambiado a 1 - Modo normal")
            task.wait(10)
        end
    end
end

-- Iniciar detección automática
autoDetectAndSwitch()