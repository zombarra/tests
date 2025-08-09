local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local skipCooking = true

-- Variable para controlar el bucle de obtener comida
local getFoodEnabled = true

local function getFoodFromPot()
    while getFoodEnabled do
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
        task.wait(2) -- Esperar 2 segundos entre cada obtención
    end
end

-- Iniciar el bucle de obtener comida en segundo plano
task.spawn(getFoodFromPot)
local function collectPlantFromWorld(plantName)
    local success, err = pcall(function()
        if plantName == "Bone Blossom" then
            local args = {
                [1] = {
                    [1] = workspace.Farm.Farm.Important.Plants_Physical:FindFirstChild("Bone Blossom").Fruits:FindFirstChild("Bone Blossom")
                }
            }
            game:GetService("ReplicatedStorage").GameEvents.Crops.Collect:FireServer(unpack(args))
            print("Recolectando Bone Blossom...")
        elseif plantName == "Tomato" then
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
                    print(plantName .. " " .. i .. "/" .. times .. " enviado exitosamente!")
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
    
    -- Verificar que todos los items del tipo se hayan enviado correctamente
    if plantName == "Bone Blossom" then
        print("Verificando que los 4 Bone Blossom se hayan subido correctamente...")
        task.wait(2) -- Esperar un poco para que se procesen
        local remainingBoneBlossoms = countPlantsInInventory("Bone Blossom")
        if remainingBoneBlossoms > 0 then
            print("Advertencia: Aún quedan " .. remainingBoneBlossoms .. " Bone Blossoms en inventario")
        else
            print("✓ Todos los Bone Blossoms han sido enviados correctamente")
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
local function confirmBoneBlossomCompletion()
    print("=== CONFIRMANDO ENVÍO DE BONE BLOSSOMS ===")
    local remainingBoneBlossoms = countPlantsInInventory("Bone Blossom")
    local attempts = 0
    local maxAttempts = 5
    
    while remainingBoneBlossoms > 0 and attempts < maxAttempts do
        attempts = attempts + 1
        print("Intento " .. attempts .. ": Aún quedan " .. remainingBoneBlossoms .. " Bone Blossoms en inventario")
        print("Esperando 3 segundos para verificar nuevamente...")
        task.wait(3)
        remainingBoneBlossoms = countPlantsInInventory("Bone Blossom")
    end
    
    if remainingBoneBlossoms == 0 then
        print("✓ CONFIRMADO: Todos los Bone Blossoms han sido procesados")
        print("✓ PROCEDIENDO CON EL TOMATO...")
        return true
    else
        print("⚠ ADVERTENCIA: Aún quedan " .. remainingBoneBlossoms .. " Bone Blossoms después de " .. maxAttempts .. " intentos")
        print("Continuando de todas formas...")
        return false
    end
end

local iteration = 1
while true do
    print("Iniciando iteración #" .. iteration)
    ensureInventoryStock()
    
    print("=== FASE 1: ENVIANDO BONE BLOSSOMS ===")
    equipAndSubmitPlant("Bone Blossom", 4)
    
    -- Confirmar que todos los Bone Blossoms se han procesado antes de continuar
    confirmBoneBlossomCompletion()
    
    print("=== FASE 2: ENVIANDO TOMATO ===")
    equipAndSubmitPlant("Tomato", 1)
    print("Ejecutando CookBest...")
    task.wait(0.5)
    local args = {
        [1] = "CookBest"
    }
    game:GetService("ReplicatedStorage").GameEvents.CookingPotService_RE:FireServer(unpack(args))
    
    -- Obtener comida del pot inmediatamente después de cocinar
    task.wait(1)
    local getFoodArgs = {
        [1] = "GetFoodFromPot"
    }
    game:GetService("ReplicatedStorage").GameEvents.CookingPotService_RE:FireServer(unpack(getFoodArgs))
    print("🍲 Obteniendo comida recién cocinada del pot...")
    
    print("Iteración #" .. iteration .. " completada. Esperando antes de la siguiente...")
    iteration = iteration + 1
    task.wait(5)
end