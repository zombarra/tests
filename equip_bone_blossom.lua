-- Script automático integrado: Hatch → Sell → Place Eggs

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Servicios del juego
local PetsService = RS.GameEvents.PetsService
local ModelService = RS.GameEvents.Model
local PetEggService = RS.GameEvents.PetEggService

-- Estados del bot
local STATE = {
    HATCHING = 1,  -- Slot 3: Abrir huevos listos
    SELLING = 2,   -- Slot 2: Vender pets
    PLACING = 3    -- Slot 1: Colocar huevos
}

local currentState = STATE.PLACING

-- Lista global de pets para vender
local petsToSell = {
    "Scarlet Macaw",
    "Ostrich", 
    "Peacock",
    "Capybara",
    "Sparrow",
    "Canary",
    "Gorilla",
    "Toucan",
    "Dog",
    "Golden Lab",
    "Bunny"

}

-- Función para cambiar loadout
local function switchToLoadout(slotNumber)
    local args = {
        [1] = "SwapPetLoadout",
        [2] = slotNumber
    }
    PetsService:FireServer(unpack(args))
    task.wait(1)
end

-- Función para detectar huevos listos para hatch
local function checkEggsReady()
    local success = pcall(function()
        ModelService.EggReadyToHatch_RE:FireServer()
    end)
    
    if success then
        return true
    end
    
    -- Buscar huevos en workspace con indicadores visuales
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

-- Función para hacer hatch de huevos
local function hatchEggs()
    local args = {
        [1] = "HatchPet",
        [2] = workspace.Farm.Farm.Important.Objects_Physical.PetEgg
    }
    
    local success = pcall(function()
        PetEggService:FireServer(unpack(args))
    end)
    
    return success
end

-- Función para colocar huevos
local function placeEggs()
    -- Posición base
    local baseX = 10.392221450805664
    local baseY = 0.13552704453468323
    local baseZ = -100.19296264648438
    
    -- Agregar variación aleatoria
    local randomX = baseX + math.random(-5, 5) -- ±5 unidades en X
    local randomZ = baseZ + math.random(-5, 5) -- ±5 unidades en Z
    
    local args = {
        [1] = "CreateEgg",
        [2] = Vector3.new(randomX, baseY, randomZ)
    }
    
    local success = pcall(function()
        PetEggService:FireServer(unpack(args))
    end)
    
    return success
end

-- Función para detectar peso de pets
local function getPetWeight(petName)
    local weightPattern = "%[(%d+%.?%d*) KG%]"
    local weight = petName:match(weightPattern)
    return weight and tonumber(weight) or 0
end

-- Función simplificada para detectar favoritos
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

-- Función para vender pets
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
                            local args = {
                                [1] = character:FindFirstChild(tool.Name)
                            }
                            if args[1] then
                                RS.GameEvents.SellPet_RE:FireServer(unpack(args))
                                task.wait(1)
                                return true -- Vendió una pet
                            end
                        end
                    end
                    break
                end
            end
        end
    end
    
    -- Buscar en character
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            for _, petType in pairs(petsToSell) do
                if tool.Name:find(petType) then
                    local weight = getPetWeight(tool.Name)
                    if not isPetFavorited(tool) and weight < 2.40 and weight > 0 then
                        local args = {
                            [1] = tool
                        }
                        RS.GameEvents.SellPet_RE:FireServer(unpack(args))
                        task.wait(1)
                        return true -- Vendió una pet
                    end
                    break
                end
            end
        end
    end
    
    return false -- No vendió nada
end

-- Función para verificar si hay pets para vender
local function hasPetsToSell()
    local character = LocalPlayer.Character
    local backpack = LocalPlayer:WaitForChild("Backpack")
    if not character or not backpack then return false end
    
    -- Verificar backpack
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            for _, petType in pairs(petsToSell) do
                if tool.Name:find(petType) then
                    local weight = getPetWeight(tool.Name)
                    if not isPetFavorited(tool) and weight < 4 and weight > 0 then
                        return true
                    end
                end
            end
        end
    end
    
    -- Verificar character
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            for _, petType in pairs(petsToSell) do
                if tool.Name:find(petType) then
                    local weight = getPetWeight(tool.Name)
                    if not isPetFavorited(tool) and weight < 4 and weight > 0 then
                        return true
                    end
                end
            end
        end
    end
    
    return false
end

-- Loop principal del bot
local function mainLoop()
    while true do
        -- Prioridad 1: Si hay huevos listos → Hatch (Slot 3)
        if checkEggsReady() then
            if currentState ~= STATE.HATCHING then
                currentState = STATE.HATCHING
                switchToLoadout(3)
            end
            hatchEggs()
            task.wait(0.5)
            
        -- Prioridad 2: Si hay pets para vender → Sell (Slot 2)
        elseif hasPetsToSell() then
            if currentState ~= STATE.SELLING then
                currentState = STATE.SELLING
                switchToLoadout(2)
            end
            if sellPets() then
                RS.GameEvents.SaveSlotService.RememberUnlockage:FireServer()
            end
            task.wait(0.5)

        -- Prioridad 3: Colocar huevos → Place (Slot 1)
        else
            if currentState ~= STATE.PLACING then
                currentState = STATE.PLACING
                switchToLoadout(1)
            end
            placeEggs()
            task.wait(0.5)
        end
        
        task.wait(1) -- Espera general entre ciclos
    end
end

-- Iniciar el bot
mainLoop()
