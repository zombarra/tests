-- Auto Farm Bot - Basado en scripts que SÍ funcionan

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Servicios del juego
local PetsService = RS.GameEvents.PetsService
local ModelService = RS.GameEvents.Model
local PetEggService = RS.GameEvents.PetEggService

print("🚀 Auto Farm Bot iniciado...")

-- Variables de control
local lastEggCheck = 0
local lastSellCheck = 0
local lastPlaceCheck = 0

-- Función para cambiar loadout (EXACTA como la tuya)
local function switchToLoadout3()
    local args = {
        [1] = "SwapPetLoadout",
        [2] = 3
    }
    PetsService:FireServer(unpack(args))
    print("📦 Cambiado al loadout 3")
    task.wait(0.5)
end

local function switchToLoadout2()
    local args = {
        [1] = "SwapPetLoadout",
        [2] = 2
    }
    PetsService:FireServer(unpack(args))
    print("📦 Cambiado al loadout 2")
    task.wait(0.5)
end

local function switchToLoadout1()
    local args = {
        [1] = "SwapPetLoadout",
        [2] = 1
    }
    PetsService:FireServer(unpack(args))
    print("📦 Cambiado al loadout 1")
    task.wait(0.5)
end

-- Función para detectar huevos listos (EXACTA como la tuya que funciona)
local function checkEggsReady()
    local success = pcall(function()
        ModelService.EggReadyToHatch_RE:FireServer()
    end)
    
    if success then
        return true
    end
    
    local function findReadyEggs()
        local readyEggs = 0
        
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
                                readyEggs = readyEggs + 1
                            end
                        end
                    end
                    
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

-- Función para hacer hatch con los args correctos
local function hatchEggs()
    print("🥚 Intentando hacer hatch...")
    
    local args = {
        [1] = "HatchPet",
        [2] = workspace.Farm.Farm.Important.Objects_Physical.PetEgg
    }
    
    local success = pcall(function()
        game:GetService("ReplicatedStorage").GameEvents.PetEggService:FireServer(unpack(args))
    end)
    
    if success then
        print("✅ Hatch enviado")
        return true
    else
        print("❌ Error al hacer hatch")
        return false
    end
end

-- Función para detectar peso (EXACTA como la tuya)
local function getPetWeight(petName)
    local weightPattern = "%[(%d+%.?%d*) KG%]"
    local weight = petName:match(weightPattern)
    return weight and tonumber(weight) or 0
end

-- Función para detectar favoritos (EXACTA como la tuya que funciona)
local function isPetFavorited(tool)
    local attributes = {"Favorited", "IsFavorite", "Starred", "IsFav", "Fav", "Favorite", "Star"}
    for _, attr in pairs(attributes) do
        if tool:GetAttribute(attr) then
            return true
        end
    end
    
    local handle = tool:FindFirstChild("Handle")
    if handle then
        for _, attr in pairs(attributes) do
            if handle:GetAttribute(attr) then
                return true
            end
        end
        
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
    
    local toolName = tool.Name:lower()
    if toolName:find("⭐") or toolName:find("★") or toolName:find("fav") then
        return true
    end
    
    if tool:FindFirstChild("FavoriteIcon") or tool:FindFirstChild("StarIcon") or tool:FindFirstChild("Favorite") then
        return true
    end
    
    return false
end

-- Función para vender pets (EXACTA como la tuya que funciona)
local function sellSpecificPets()
    local character = LocalPlayer.Character
    local backpack = LocalPlayer:WaitForChild("Backpack")
    if not character or not backpack then return 0 end
    
    local petsSold = 0
    local petsToSell = {
        "Scarlet Macaw", "Blue Jay", "Cardinal", "Robin", "Sparrow",
        "Canary", "Gorilla", "Toucan"
    }
    
    -- Buscar SOLO UNA pet en backpack por ciclo
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and petsSold == 0 then
            for _, petType in pairs(petsToSell) do
                if tool.Name:find(petType) then
                    local weight = getPetWeight(tool.Name)
                    if isPetFavorited(tool) then
                        -- No vender favoritos
                    elseif weight < 2.4 and weight > 0 then
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid:UnequipTools()
                            task.wait(0.5)
                            humanoid:EquipTool(tool)
                            task.wait(1)
                            local args = { [1] = character:FindFirstChild(tool.Name) }
                            if args[1] then
                                RS.GameEvents.SellPet_RE:FireServer(unpack(args))
                                petsSold = petsSold + 1
                                print("💰 Pet vendida: " .. tool.Name)
                                task.wait(2)
                                return petsSold
                            end
                        end
                    end
                    break
                end
            end
        end
    end
    
    if petsSold == 0 then
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                for _, petType in pairs(petsToSell) do
                    if tool.Name:find(petType) then
                        local weight = getPetWeight(tool.Name)
                        if isPetFavorited(tool) then
                            -- No vender favoritos equipados
                        elseif weight < 2.4 and weight > 0 then
                            local args = { [1] = tool }
                            RS.GameEvents.SellPet_RE:FireServer(unpack(args))
                            petsSold = petsSold + 1
                            print("💰 Pet vendida: " .. tool.Name)
                            task.wait(2)
                            return petsSold
                        end
                        break
                    end
                end
            end
        end
    end
    
    if petsSold > 0 then
        RS.GameEvents.SaveSlotService.RememberUnlockage:FireServer()
    end
    return petsSold
end

-- Función simple para colocar huevos
local function placeEggs()
    local character = LocalPlayer.Character
    local backpack = LocalPlayer:WaitForChild("Backpack")
    if not character or not backpack then return false end
    
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
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:UnequipTools()
        task.wait(0.3)
        humanoid:EquipTool(commonEgg)
        task.wait(0.5)
        
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

-- LOOP PRINCIPAL SIMPLE - Como tus scripts que funcionan
local function mainLoop()
    print("🔄 Iniciando loop principal...")
    
    while true do
        local currentTime = tick()
        
        -- Verificar huevos listos cada 5 segundos
        if currentTime - lastEggCheck > 5 then
            lastEggCheck = currentTime
            
            if checkEggsReady() then
                print("🥚 ¡Huevos detectados listos para hatch!")
                switchToLoadout3() -- Cambiar al SLOT 3 para hacer hatch
                print("✅ Loadout cambiado a 3 - Listo para hatch")
                task.wait(1) -- Esperar a que se aplique el cambio
                hatchEggs() -- HACER HATCH con los args correctos
                task.wait(30) -- Esperar como en tu script original
            end
        end
        
        -- Vender pets cada 10 segundos
        if currentTime - lastSellCheck > 10 then
            lastSellCheck = currentTime
            switchToLoadout2()
            local sold = sellSpecificPets()
            if sold > 0 then
                task.wait(15) -- Espera después de vender
            end
        end
        
        -- Colocar huevos cada 15 segundos
        if currentTime - lastPlaceCheck > 15 then
            lastPlaceCheck = currentTime
            switchToLoadout1()
            placeEggs()
            task.wait(2)
        end
        
        task.wait(1) -- Pausa general
    end
end

-- INICIAR BOT
mainLoop()
