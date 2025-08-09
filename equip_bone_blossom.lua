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
            print("Intentando recolectar todas las Bone Blossom disponibles...")
            -- Buscar todas las Bone Blossom en el mundo
            local plantsPhysical = workspace.Farm.Farm.Important.Plants_Physical
            local boneBlossom = plantsPhysical:FindFirstChild("Bone Blossom")
            
            if boneBlossom then
                local fruits = boneBlossom:FindFirstChild("Fruits")
                if fruits then
                    -- Recolectar todas las frutas de Bone Blossom disponibles
                    for _, fruit in pairs(fruits:GetChildren()) do
                        if fruit.Name == "Bone Blossom" then
                            local args = {
                                [1] = {
                                    [1] = fruit
                                }
                            }
                            game:GetService("ReplicatedStorage").GameEvents.Crops.Collect:FireServer(unpack(args))
                            print("Recolectando Bone Blossom individual...")
                            task.wait(0.1) -- Pequeña pausa entre recolecciones
                        end
                    end
                else
                    warn("No se encontró carpeta Fruits para Bone Blossom")
                end
            else
                warn("No se encontró planta Bone Blossom en el mundo")
            end
            
        elseif plantName == "Tomato" then
            print("Intentando recolectar todos los Tomatoes disponibles...")
            -- Buscar todos los Tomatoes en el mundo
            local plantsPhysical = workspace.Farm.Farm.Important.Plants_Physical
            local tomato = plantsPhysical:FindFirstChild("Tomato")
            
            if tomato then
                local fruits = tomato:FindFirstChild("Fruits")
                if fruits then
                    -- Recolectar todas las frutas de Tomato disponibles
                    for _, fruit in pairs(fruits:GetChildren()) do
                        if fruit.Name == "Tomato" then
                            local args = {
                                [1] = {
                                    [1] = fruit
                                }
                            }
                            game:GetService("ReplicatedStorage").GameEvents.Crops.Collect:FireServer(unpack(args))
                            print("Recolectando Tomato individual...")
                            task.wait(0.1) -- Pequeña pausa entre recolecciones
                        end
                    end
                else
                    warn("No se encontró carpeta Fruits para Tomato")
                end
            else
                warn("No se encontró planta Tomato en el mundo")
            end
        end
    end)
    if not success then
        warn("Error recolectando " .. plantName .. ": " .. tostring(err))
    end
end
-- Función para equipar y submitir planta
local function equipAndSubmitPlant(plantName, times)
    for i = 1, times do
        print("Buscando " .. plantName .. " (" .. i .. "/" .. times .. ")")
        local plantSubmitted = false
        
        -- Repetir hasta que la planta se haya enviado exitosamente
        while not plantSubmitted do
            local plantFound = false
            local toolToSubmit = nil
            
            -- Buscar en el inventario
            for _, tool in ipairs(Backpack:GetChildren()) do
                if tool:IsA("Tool") and tool:GetAttribute("f") == plantName and not tool:GetAttribute("Seed") then
                    toolToSubmit = tool
                    plantFound = true
                    break
                end
            end
            
            if plantFound and toolToSubmit then
                -- Desequipar cualquier herramienta actual
                for _, t in ipairs(Character:GetChildren()) do
                    if t:IsA("Tool") then
                        t.Parent = Backpack
                    end
                end
                
                -- Equipar la planta encontrada
                toolToSubmit.Parent = Character
                task.wait(0.3)
                
                -- Ejecutar SubmitHeldPlant
                local args = {
                    [1] = "SubmitHeldPlant"
                }
                game:GetService("ReplicatedStorage").GameEvents.CookingPotService_RE:FireServer(unpack(args))
                task.wait(0.5)
                
                -- Verificar si la planta realmente se envió (ya no está en el inventario)
                local stillInInventory = false
                for _, tool in ipairs(Backpack:GetChildren()) do
                    if tool == toolToSubmit then
                        stillInInventory = true
                        break
                    end
                end
                
                -- También verificar si no está equipada
                local stillEquipped = false
                for _, tool in ipairs(Character:GetChildren()) do
                    if tool == toolToSubmit then
                        stillEquipped = true
                        break
                    end
                end
                
                if not stillInInventory and not stillEquipped then
                    plantSubmitted = true
                    print(plantName .. " enviado y verificado exitosamente! (" .. i .. "/" .. times .. ")")
                else
                    print(plantName .. " no se envió correctamente, reintentando...")
                    task.wait(1)
                end
            else
                print("No se encontró " .. plantName .. " en inventario, intentando recolectar...")
                collectPlantFromWorld(plantName)
                task.wait(2) -- Esperar 2 segundos antes de buscar nuevamente
            end
        end
    end
end
-- Función para obtener comida de la olla constantemente
local function getFoodFromPotConstantly()
    spawn(function()
        while true do
            local args = {
                [1] = "GetFoodFromPot"
            }
            game:GetService("ReplicatedStorage").GameEvents.CookingPotService_RE:FireServer(unpack(args))
            task.wait(0.1) -- Ejecutar cada 0.1 segundos
        end
    end)
end

-- Iniciar la función de obtener comida constantemente
getFoodFromPotConstantly()

local iteration = 1
while true do
    print("Iniciando iteración #" .. iteration)
    
    -- PASO 0: RECOLECTAR PLANTAS AL INICIO DE CADA ITERACIÓN
    print("=== RECOLECTANDO PLANTAS DEL MUNDO ===")
    print("Recolectando Bone Blossom del mundo...")
    collectPlantFromWorld("Bone Blossom")
    task.wait(1)
    print("Recolectando Tomato del mundo...")
    collectPlantFromWorld("Tomato")
    task.wait(1)
    print("=== RECOLECCIÓN COMPLETADA ===")
    
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
    
    -- También ejecutar GetFoodFromPot aquí por si acaso
    local getFoodArgs = {
        [1] = "GetFoodFromPot"
    }
    game:GetService("ReplicatedStorage").GameEvents.CookingPotService_RE:FireServer(unpack(getFoodArgs))
    
    print("Iteración #" .. iteration .. " completada. Esperando antes de la siguiente...")
    iteration = iteration + 1
    
    task.wait(3)
end
