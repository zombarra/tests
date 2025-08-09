local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

function getNil(name,class) for _,v in pairs(getnilinstances())do if v.ClassName==class and v.Name==name then return v;end end end

-- Variable para controlar el skip cooking
local skipCooking = true

-- Función para recolectar plantas específicas del mundo
local function collectPlantFromWorld(plantName)
    local success, err = pcall(function()
        if plantName == "Bone Blossom" then
            -- Usar getNil para encontrar Bone Blossom
            local args = {
                [1] = {
                    [1] = getNil("Bone Blossom", "Model")
                }
            }
            game:GetService("ReplicatedStorage").GameEvents.Crops.Collect:FireServer(unpack(args))
            print("Recolectando Bone Blossom usando getNil...")
        elseif plantName == "Tomato" then
            -- Usar getNil para encontrar Tomato
            local args = {
                [1] = {
                    [1] = getNil("Tomato", "Model")
                }
            }
            game:GetService("ReplicatedStorage").GameEvents.Crops.Collect:FireServer(unpack(args))
            print("Recolectando Tomato usando getNil...")
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
    
    -- También ejecutar GetFoodFromPot aquí por si acaso
    local getFoodArgs = {
        [1] = "GetFoodFromPot"
    }
    game:GetService("ReplicatedStorage").GameEvents.CookingPotService_RE:FireServer(unpack(getFoodArgs))
    
    print("Iteración #" .. iteration .. " completada. Esperando antes de la siguiente...")
    iteration = iteration + 1
    
    task.wait(2)
end
