local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local skipCooking = true

-- Función para monitorear el timer y ejecutar GetFoodFromPot cuando llegue a 0
local function monitorCookingTimer()
    spawn(function()
        while true do
            local success, err = pcall(function()
                -- Buscar el TimeLabel en la jerarquía especificada
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if playerGui then
                    local ingredientsBoard = playerGui:FindFirstChild("IngredientsBoard")
                    if ingredientsBoard then
                        local cookTimeDisplay = ingredientsBoard:FindFirstChild("CookTimeDisplay")
                        if cookTimeDisplay then
                            local face = cookTimeDisplay:FindFirstChild("Face")
                            if face then
                                local surfaceGui = face:FindFirstChild("SurfaceGui")
                                if surfaceGui then
                                    local timeDisplayFrame = surfaceGui:FindFirstChild("TimeDisplayFrame")
                                    if timeDisplayFrame then
                                        local timeLabel = timeDisplayFrame:FindFirstChild("TimeLabel")
                                        if timeLabel and timeLabel.Text then
                                            -- Verificar si el tiempo llegó a 0
                                            if timeLabel.Text == "00:00" or timeLabel.Text == "0" then
                                                print("¡Tiempo de cocción completado! Ejecutando GetFoodFromPot...")
                                                local args = {
                                                    [1] = "GetFoodFromPot"
                                                }
                                                game:GetService("ReplicatedStorage").GameEvents.CookingPotService_RE:FireServer(unpack(args))
                                                task.wait(2) -- Esperar un poco antes de volver a verificar para evitar spam
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            if not success then
                -- No mostrar error si simplemente no encuentra la GUI (es normal)
            end
            task.wait(0.5) -- Verificar cada medio segundo
        end
    end)
end

-- Iniciar el monitoreo del timer
monitorCookingTimer()

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
    
    -- Primero, enviar los 4 Bone Blossoms completamente
    print("Equipando Bone Blossom...")
    equipAndSubmitPlant("Bone Blossom", 4)
    
    -- Esperar un poco para asegurar que se procesaron los Bone Blossoms
    print("Bone Blossoms enviados, esperando antes de enviar Tomato...")
    task.wait(2)
    
    -- Luego enviar el Tomato
    print("Equipando Tomato...")
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
