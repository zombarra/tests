local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
-- Variable para controlar el skip cooking
local skipCooking = true

-- Función para recolectar plantas específicas del mundo
local function collectPlantFromWorld(plantName)
    local success, err = pcall(function()
        if plantName == "Bone Blossom" then
            -- Usar la estructura original que funcionaba
            local args = {
                [1] = {
                    [1] = workspace.Farm.Farm.Important.Plants_Physical:FindFirstChild("Bone Blossom").Fruits:FindFirstChild("Bone Blossom")
                }
            }
            game:GetService("ReplicatedStorage").GameEvents.Crops.Collect:FireServer(unpack(args))
            print("Recolectando Bone Blossom...")
        elseif plantName == "Tomato" then
            -- Usar la estructura original que funcionaba
            local args = {
                [1] = {
                    [1] = workspace.Farm.Farm.Important.Plants_Physical.Tomato.Fruits.Tomato
                }
            }
            game:GetService("ReplicatedStorage").GameEvents.Crops.Collect:FireServer(unpack(args))
            print("Recolectando Tomato...")
        end
    end)
    if not success then
        warn("Error recolectando " .. plantName .. ": " .. tostring(err))
    end
end

-- Función para equipar y submitir planta (versión simplificada que funcionaba)
local function equipAndSubmitPlant(plantName, times)
    for i = 1, times do
        print("Buscando " .. plantName .. " (" .. i .. "/" .. times .. ")")
        local plantFound = false
        -- Buscar hasta encontrar la planta especificada (sin límite de intentos)
        while not plantFound do
            -- Buscar en el inventario
            for _, tool in ipairs(Backpack:GetChildren()) do
                if tool:IsA("Tool") and tool:GetAttribute("f") == plantName and not tool:GetAttribute("Seed") then
                    -- Desequipar cualquier herramienta actual
                    for _, t in ipairs(Character:GetChildren()) do
                        if t:IsA("Tool") then
                            t.Parent = Backpack
                        end
                    end
                    
                    -- Equipar la planta encontrada
                    tool.Parent = Character
                    task.wait(0.3)
                    
                    -- Ejecutar SubmitHeldPlant
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

-- Función para contar plantas en inventario
local function countPlantsInInventory(plantName)
    local count = 0
    for _, tool in ipairs(Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool:GetAttribute("f") == plantName and not tool:GetAttribute("Seed") then
            count = count + 1
        end
    end
    return count
end

-- Función para asegurar stock en inventario
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
-- Función para obtener comida de la olla constantemente (con control de frecuencia)
local function getFoodFromPotConstantly()
    spawn(function()
        while true do
            local args = {
                [1] = "GetFoodFromPot"
            }
            game:GetService("ReplicatedStorage").GameEvents.CookingPotService_RE:FireServer(unpack(args))
            print("GetFoodFromPot ejecutado en segundo plano")
            task.wait(2) -- Cambié de 0.1 a 2 segundos para evitar spam
        end
    end)
end

-- Iniciar la función de obtener comida constantemente
getFoodFromPotConstantly()

local iteration = 1
while true do
    print("Iniciando iteración #" .. iteration)
    
    -- Verificar inventario y recolectar solo lo necesario
    ensureInventoryStock()
    
    -- PASO 1: Subir las 4 Bone Blossom PRIMERO
    print("=== SUBIENDO 4 BONE BLOSSOM PRIMERO ===")
    equipAndSubmitPlant("Bone Blossom", 4)
    print("=== TODAS LAS BONE BLOSSOM SUBIDAS - ESPERANDO ANTES DEL TOMATE ===")
    task.wait(2) -- Espera adicional para asegurar que se procesen las Bone Blossom
    
    -- PASO 2: Ahora subir el tomate
    print("=== SUBIENDO TOMATE DESPUÉS ===")
    equipAndSubmitPlant("Tomato", 1)
    print("=== TOMATE SUBIDO - PROCEDIENDO A COCINAR ===")

    print("Ejecutando CookBest...")
    task.wait(0.5)
    local args = {
        [1] = "CookBest"
    }
    game:GetService("ReplicatedStorage").GameEvents.CookingPotService_RE:FireServer(unpack(args))
    task.wait(2) -- Esperar que se procese el CookBest
    
    -- Ejecutar GetFoodFromPot con precaución
    print("Ejecutando GetFoodFromPot...")
    local getFoodArgs = {
        [1] = "GetFoodFromPot"
    }
    game:GetService("ReplicatedStorage").GameEvents.CookingPotService_RE:FireServer(unpack(getFoodArgs))
    print("GetFoodFromPot ejecutado, esperando respuesta del servidor...")
    task.wait(3) -- Dar tiempo para que el servidor responda
    
    print("Iteración #" .. iteration .. " completada. Esperando antes de la siguiente...")
    iteration = iteration + 1
    
    task.wait(5)
end
