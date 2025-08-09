local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local skipCooking = true

-- Función para obtener comida del pot constantemente
local function getFoodLoop()
    while true do
        local success, err = pcall(function()
            local args = {
                [1] = "GetFoodFromPot"
            }
            game:GetService("ReplicatedStorage").GameEvents.CookingPotService_RE:FireServer(unpack(args))
            print("🍲 Obteniendo comida del pot...")
        end)
        if not success then
            warn("Error obteniendo comida del pot: " .. tostring(err))
        end
        task.wait(1.5) -- Obtener comida cada 1.5 segundos
    end
end

-- Iniciar el bucle de obtener comida en segundo plano
task.spawn(getFoodLoop)
local function collectPlantFromWorld(plantName)
    local success, err = pcall(function()
        if plantName == "Bone Blossom" then
            -- Buscar cualquier Bone Blossom disponible, no solo el primero
            local plantsContainer = workspace.Farm.Farm.Important.Plants_Physical:FindFirstChild("Bone Blossom")
            if plantsContainer and plantsContainer.Fruits then
                local availablePlants = {}
                for _, plant in ipairs(plantsContainer.Fruits:GetChildren()) do
                    if plant.Name == "Bone Blossom" then
                        table.insert(availablePlants, plant)
                    end
                end
                
                if #availablePlants > 0 then
                    -- Tomar una planta aleatoria de las disponibles
                    local randomPlant = availablePlants[math.random(1, #availablePlants)]
                    local args = {
                        [1] = {
                            [1] = randomPlant
                        }
                    }
                    game:GetService("ReplicatedStorage").GameEvents.Crops.Collect:FireServer(unpack(args))
                    print("Recolectando Bone Blossom (planta #" .. math.random(1, #availablePlants) .. " de " .. #availablePlants .. " disponibles)...")
                else
                    print("No hay Bone Blossoms disponibles para recolectar")
                end
            end
        elseif plantName == "Tomato" then
            -- Buscar cualquier Tomato disponible
            local plantsContainer = workspace.Farm.Farm.Important.Plants_Physical.Tomato
            if plantsContainer and plantsContainer.Fruits then
                local availableTomatoes = {}
                for _, tomato in ipairs(plantsContainer.Fruits:GetChildren()) do
                    if tomato.Name == "Tomato" then
                        table.insert(availableTomatoes, tomato)
                    end
                end
                
                if #availableTomatoes > 0 then
                    -- Tomar un tomate aleatorio de los disponibles
                    local randomTomato = availableTomatoes[math.random(1, #availableTomatoes)]
                    local args = {
                        [1] = {
                            [1] = randomTomato
                        }
                    }
                    game:GetService("ReplicatedStorage").GameEvents.Crops.Collect:FireServer(unpack(args))
                    print("Recolectando Tomato (tomate #" .. math.random(1, #availableTomatoes) .. " de " .. #availableTomatoes .. " disponibles)...")
                else
                    print("No hay Tomatos disponibles para recolectar")
                end
            end
        end
    end)
    if not success then
        warn("Error recolectando " .. plantName .. ": " .. tostring(err))
    end
end
local function equipAndSubmitPlant(plantName, times)
    for i = 1, times do
        print("Buscando " .. plantName .. " (" .. i .. "/" .. times .. ")")
        local plantFound = false
        while not plantFound do
            for _, tool in ipairs(Backpack:GetChildren()) do
                if tool:IsA("Tool") and tool:GetAttribute("f") == plantName and not tool:GetAttribute("Seed") then
                    for _, t in ipairs(Character:GetChildren()) do
                        if t:IsA("Tool") then
                            t.Parent = Backpack
                        end
                    end
                    tool.Parent = Character
                    task.wait(0.3)
                    local args = {
                        [1] = "SubmitHeldPlant"
                    }
                    game:GetService("ReplicatedStorage").GameEvents.CookingPotService_RE:FireServer(unpack(args))
                    task.wait(0.5)
                    plantFound = true
                    print(plantName .. " enviado exitosamente!")
                    break
                end
            end
            if not plantFound then
                print("No se encontró " .. plantName .. " en inventario, intentando recolectar...")
                collectPlantFromWorld(plantName)
                task.wait(2) -- Esperar 2 segundos antes de buscar nuevamente
            end
        end
    end
end
local function countPlantsInInventory(plantName)
    local count = 0
    for _, tool in ipairs(Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool:GetAttribute("f") == plantName and not tool:GetAttribute("Seed") then
            count = count + 1
        end
    end
    return count
end
local function ensureInventoryStock()
    print("Verificando inventario...")
    local boneBlossomsCount = countPlantsInInventory("Bone Blossom")
    print("Bone Blossoms en inventario: " .. boneBlossomsCount .. "/4")
    while boneBlossomsCount < 4 do
        print("Recolectando Bone Blossom adicional (" .. boneBlossomsCount .. "/4)")
        collectPlantFromWorld("Bone Blossom")
        task.wait(2)
        boneBlossomsCount = countPlantsInInventory("Bone Blossom")
    end
    local tomatoCount = countPlantsInInventory("Tomato")
    print("Tomatos en inventario: " .. tomatoCount .. "/1")
    
    while tomatoCount < 1 do
        print("Recolectando Tomato adicional (" .. tomatoCount .. "/1)")
        collectPlantFromWorld("Tomato")
        task.wait(2)
        tomatoCount = countPlantsInInventory("Tomato")
    end
    
    print("Inventario verificado: " .. countPlantsInInventory("Bone Blossom") .. " Bone Blossoms, " .. countPlantsInInventory("Tomato") .. " Tomatos")
end
local iteration = 1
while true do
    print("Iniciando iteración #" .. iteration)
    ensureInventoryStock()
    print("Equipando Bone Blossom...")
    equipAndSubmitPlant("Bone Blossom", 4)
    print("Equipando Coconut...")
    equipAndSubmitPlant("Tomato", 1)
    print("Ejecutando CookBest...")
    task.wait(0.5)
    local args = {
        [1] = "CookBest"
    }
    game:GetService("ReplicatedStorage").GameEvents.CookingPotService_RE:FireServer(unpack(args))
    print("Iteración #" .. iteration .. " completada. Esperando antes de la siguiente...")
    iteration = iteration + 1
    task.wait(5)
end