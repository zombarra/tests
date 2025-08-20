-- Auto Farm Bot Simplificado - Basado en funciones que funcionan

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Servicios del juego
local PetsService = RS.GameEvents.PetsService
local ModelService = RS.GameEvents.Model
local PetEggService = RS.GameEvents.PetEggService

print("🚀 Auto Farm Bot iniciado...")

-- Función para cambiar loadout (TU FUNCIÓN QUE FUNCIONA)
local function switchToLoadout(slotNumber)
    local args = {
        [1] = "SwapPetLoadout",
        [2] = slotNumber
    }
    PetsService:FireServer(unpack(args))
    print("📦 Cambiado al loadout " .. slotNumber)
    task.wait(1)
end

-- Función para detectar huevos listos (TU FUNCIÓN QUE FUNCIONA)
local function checkEggsReady()
    local success = pcall(function()
        ModelService.EggReadyToHatch_RE:FireServer()
    end)
    
    if success then
        return true
    end
    
    -- Método visual de respaldo
    local farm = workspace:FindFirstChild("Farm")
    if farm then
        for _, descendant in pairs(farm:GetDescendants()) do
            if descendant.Name:lower():find("egg") then
                local gui = descendant:FindFirstChildOfClass("BillboardGui")
                if gui then
                    local textLabel = gui:FindFirstChildOfClass("TextLabel")
                    if textLabel then
                        local text = textLabel.Text:lower()
                        if text:find("ready") or text:find("hatch") or text:find("!") then
                            return true
                        end
                    end
                end
                
                if descendant:GetAttribute("ReadyToHatch") or descendant:GetAttribute("CanHatch") then
                    return true
                end
            end
        end
    end
    
    return false
end

-- Función simple para hacer hatch
local function hatchEggs()
    print("🥚 Intentando hacer hatch...")
    local farm = workspace:FindFirstChild("Farm")
    if farm then
        for _, descendant in pairs(farm:GetDescendants()) do
            if descendant.Name:lower():find("egg") and descendant:IsA("Model") then
                local args = {
                    [1] = "HatchPet",
                    [2] = descendant
                }
                
                pcall(function()
                    PetEggService:FireServer(unpack(args))
                end)
                
                print("✅ Hatch enviado")
                return true
            end
        end
    end
    return false
end

-- Función simple para colocar huevos
local function placeEggs()
    local character = LocalPlayer.Character
    local backpack = LocalPlayer:WaitForChild("Backpack")
    if not character or not backpack then return false end
    
    -- Buscar Common Egg
    local commonEgg = nil
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:find("Common Egg") then
            commonEgg = tool
            break
        end
    end
    
    if not commonEgg then
        print("❌ No se encontró Common Egg")
        return false
    end
    
    -- Equipar huevo
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:UnequipTools()
        task.wait(0.3)
        humanoid:EquipTool(commonEgg)
        task.wait(0.5)
        
        -- Colocar en posición aleatoria
        local baseX = 10.392221450805664
        local baseY = 0.13552704453468323
        local baseZ = -100.19296264648438
        
        local randomX = baseX + math.random(-5, 5)
        local randomZ = baseZ + math.random(-5, 5)
        
        local args = {
            [1] = "CreateEgg",
            [2] = Vector3.new(randomX, baseY, randomZ)
        }
        
        pcall(function()
            PetEggService:FireServer(unpack(args))
        end)
        
        print("🥚 Huevo colocado")
        return true
    end
    
    return false
end

-- Función para detectar peso de pets
local function getPetWeight(petName)
    local weightPattern = "%[(%d+%.?%d*) KG%]"
    local weight = petName:match(weightPattern)
    return weight and tonumber(weight) or 0
end

-- Función para detectar favoritos
local function isPetFavorited(tool)
    local attributes = {"Favorited", "IsFavorite", "Starred", "IsFav", "Fav"}
    for _, attr in pairs(attributes) do
        if tool:GetAttribute(attr) then
            return true
        end
    end
    
    if tool.Name:find("⭐") or tool.Name:find("★") then
        return true
    end
    
    return false
end

-- Lista de pets para vender
local petsToSell = {
    "Scarlet Macaw", "Ostrich", "Peacock", "Capybara", "Sparrow",
    "Canary", "Gorilla", "Toucan", "Dog", "Golden Lab", "Bunny"
}

-- Función simple para vender pets
local function sellPets()
    local character = LocalPlayer.Character
    local backpack = LocalPlayer:WaitForChild("Backpack")
    if not character or not backpack then return false end
    
    -- Buscar en backpack
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            for _, petType in pairs(petsToSell) do
                if tool.Name:find(petType) then
                    local weight = getPetWeight(tool.Name)
                    if not isPetFavorited(tool) and weight < 2.40 and weight > 0 then
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid:UnequipTools()
                            task.wait(0.3)
                            humanoid:EquipTool(tool)
                            task.wait(0.5)
                            
                            local equippedTool = character:FindFirstChild(tool.Name)
                            if equippedTool then
                                local args = { [1] = equippedTool }
                                pcall(function()
                                    RS.GameEvents.SellPet_RE:FireServer(unpack(args))
                                end)
                                print("💰 Pet vendida: " .. tool.Name)
                                return true
                            end
                        end
                    end
                    break
                end
            end
        end
    end
    
    return false
end

-- Función para verificar si hay pets para vender
local function hasPetsToSell()
    local character = LocalPlayer.Character
    local backpack = LocalPlayer:WaitForChild("Backpack")
    if not character or not backpack then return false end
    
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            for _, petType in pairs(petsToSell) do
                if tool.Name:find(petType) then
                    local weight = getPetWeight(tool.Name)
                    if not isPetFavorited(tool) and weight < 2.40 and weight > 0 then
                        return true
                    end
                end
            end
        end
    end
    
    return false
end

-- LOOP PRINCIPAL SIMPLIFICADO
local function mainLoop()
    print("🔄 Iniciando loop principal...")
    
    while true do
        pcall(function()
            -- Prioridad 1: Huevos listos
            if checkEggsReady() then
                print("🥚 Huevos listos detectados!")
                switchToLoadout(3)
                hatchEggs()
                task.wait(2)
                
            -- Prioridad 2: Vender pets
            elseif hasPetsToSell() then
                print("💰 Pets para vender detectadas!")
                switchToLoadout(2)
                sellPets()
                task.wait(1)
                
            -- Prioridad 3: Colocar huevos
            else
                print("📦 Colocando huevos...")
                switchToLoadout(1)
                placeEggs()
                task.wait(1)
            end
        end)
        
        task.wait(3) -- Pausa entre ciclos
    end
end

-- INICIAR BOT
mainLoop()
