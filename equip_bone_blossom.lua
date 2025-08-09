local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- Variables de configuración (valores por defecto)
local config = {
    plant1Name = "Bone Blossom",
    plant1Amount = 4,
    plant2Name = "Tomato", 
    plant2Amount = 1,
    waitBetweenPlants = 2,
    waitBetweenIterations = 5,
    autoCollect = true,
    skipCooking = true
}

-- Estado del script
local scriptRunning = false

-- Función para crear la interfaz
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CookingBotConfig"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Frame principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Esquinas redondeadas
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    title.BorderSizePixel = 0
    title.Text = "🍳 Cooking Bot Configuration"
    title.TextColor3 = Color3.white
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = title
    
    -- Scroll frame para los controles
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -20, 1, -100)
    scrollFrame.Position = UDim2.new(0, 10, 0, 50)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
    scrollFrame.Parent = mainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.Parent = scrollFrame
    
    -- Función helper para crear controles
    local function createControl(parent, labelText, controlType, currentValue, callback)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 50)
        container.BackgroundTransparency = 1
        container.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.5, -5, 1, 0)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.TextColor3 = Color3.white
        label.TextScaled = true
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container
        
        if controlType == "TextBox" then
            local textBox = Instance.new("TextBox")
            textBox.Size = UDim2.new(0.5, -5, 0, 30)
            textBox.Position = UDim2.new(0.5, 5, 0, 10)
            textBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            textBox.BorderSizePixel = 0
            textBox.Text = tostring(currentValue)
            textBox.TextColor3 = Color3.white
            textBox.TextScaled = true
            textBox.Font = Enum.Font.Gotham
            textBox.Parent = container
            
            local textCorner = Instance.new("UICorner")
            textCorner.CornerRadius = UDim.new(0, 5)
            textCorner.Parent = textBox
            
            textBox.FocusLost:Connect(function()
                callback(textBox.Text)
            end)
            
        elseif controlType == "Toggle" then
            local toggleButton = Instance.new("TextButton")
            toggleButton.Size = UDim2.new(0, 60, 0, 30)
            toggleButton.Position = UDim2.new(0.5, 5, 0, 10)
            toggleButton.BackgroundColor3 = currentValue and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
            toggleButton.BorderSizePixel = 0
            toggleButton.Text = currentValue and "ON" or "OFF"
            toggleButton.TextColor3 = Color3.white
            toggleButton.TextScaled = true
            toggleButton.Font = Enum.Font.GothamBold
            toggleButton.Parent = container
            
            local toggleCorner = Instance.new("UICorner")
            toggleCorner.CornerRadius = UDim.new(0, 5)
            toggleCorner.Parent = toggleButton
            
            toggleButton.MouseButton1Click:Connect(function()
                currentValue = not currentValue
                toggleButton.BackgroundColor3 = currentValue and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
                toggleButton.Text = currentValue and "ON" or "OFF"
                callback(currentValue)
            end)
        end
    end
    
    -- Crear controles
    createControl(scrollFrame, "Planta 1 (Nombre):", "TextBox", config.plant1Name, function(value)
        config.plant1Name = value
    end)
    
    createControl(scrollFrame, "Planta 1 (Cantidad):", "TextBox", config.plant1Amount, function(value)
        config.plant1Amount = tonumber(value) or 4
    end)
    
    createControl(scrollFrame, "Planta 2 (Nombre):", "TextBox", config.plant2Name, function(value)
        config.plant2Name = value
    end)
    
    createControl(scrollFrame, "Planta 2 (Cantidad):", "TextBox", config.plant2Amount, function(value)
        config.plant2Amount = tonumber(value) or 1
    end)
    
    createControl(scrollFrame, "Espera entre plantas (seg):", "TextBox", config.waitBetweenPlants, function(value)
        config.waitBetweenPlants = tonumber(value) or 2
    end)
    
    createControl(scrollFrame, "Espera entre iteraciones (seg):", "TextBox", config.waitBetweenIterations, function(value)
        config.waitBetweenIterations = tonumber(value) or 5
    end)
    
    createControl(scrollFrame, "Auto-recolectar plantas:", "Toggle", config.autoCollect, function(value)
        config.autoCollect = value
    end)
    
    createControl(scrollFrame, "Skip cooking:", "Toggle", config.skipCooking, function(value)
        config.skipCooking = value
    end)
    
    -- Botones de control
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(1, -20, 0, 40)
    buttonContainer.Position = UDim2.new(0, 10, 1, -50)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = mainFrame
    
    local startButton = Instance.new("TextButton")
    startButton.Size = UDim2.new(0.45, 0, 1, 0)
    startButton.Position = UDim2.new(0, 0, 0, 0)
    startButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    startButton.BorderSizePixel = 0
    startButton.Text = "▶ INICIAR"
    startButton.TextColor3 = Color3.white
    startButton.TextScaled = true
    startButton.Font = Enum.Font.GothamBold
    startButton.Parent = buttonContainer
    
    local startCorner = Instance.new("UICorner")
    startCorner.CornerRadius = UDim.new(0, 5)
    startCorner.Parent = startButton
    
    local stopButton = Instance.new("TextButton")
    stopButton.Size = UDim2.new(0.45, 0, 1, 0)
    stopButton.Position = UDim2.new(0.55, 0, 0, 0)
    stopButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    stopButton.BorderSizePixel = 0
    stopButton.Text = "⏹ PARAR"
    stopButton.TextColor3 = Color3.white
    stopButton.TextScaled = true
    stopButton.Font = Enum.Font.GothamBold
    stopButton.Parent = buttonContainer
    
    local stopCorner = Instance.new("UICorner")
    stopCorner.CornerRadius = UDim.new(0, 5)
    stopCorner.Parent = stopButton
    
    -- Funcionalidad de los botones
    startButton.MouseButton1Click:Connect(function()
        if not scriptRunning then
            scriptRunning = true
            screenGui:Destroy()
            startScript()
        end
    end)
    
    stopButton.MouseButton1Click:Connect(function()
        scriptRunning = false
        screenGui:Destroy()
    end)
    
    -- Hacer la GUI arrastrable
    local dragging = false
    local dragInput, mousePos, framePos
    
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = mainFrame.Position
        end
    end)
    
    title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    title.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            mainFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

-- Función principal del script (usando la configuración)
local function startScript()
    print("🍳 Cooking Bot iniciado con configuración:")
    print("Planta 1:", config.plant1Name, "x" .. config.plant1Amount)
    print("Planta 2:", config.plant2Name, "x" .. config.plant2Amount)
    print("Auto-recolectar:", config.autoCollect and "Sí" or "No")
    
    local skipCooking = config.skipCooking

-- Función para recolectar plantas específicas del mundo
local function collectPlantFromWorld(plantName)
    if not config.autoCollect then return end
    
    local success, err = pcall(function()
        if plantName == "Bone Blossom" then
            -- Script específico para Bone Blossom
            local args = {
                [1] = {
                    [1] = workspace.Farm.Farm.Important.Plants_Physical:FindFirstChild("Bone Blossom").Fruits:FindFirstChild("Bone Blossom")
                }
            }
            game:GetService("ReplicatedStorage").GameEvents.Crops.Collect:FireServer(unpack(args))
            print("Recolectando " .. plantName .. "...")
        elseif plantName == "Tomato" then
            -- Script específico para Tomato
            local args = {
                [1] = {
                    [1] = workspace.Farm.Farm.Important.Plants_Physical.Tomato.Fruits.Tomato
                }
            }
            game:GetService("ReplicatedStorage").GameEvents.Crops.Collect:FireServer(unpack(args))
            print("Recolectando " .. plantName .. "...")
        else
            -- Fallback genérico para otras plantas
            local farm = workspace:FindFirstChild("Farm")
            if farm and farm:FindFirstChild("Farm") and farm.Farm:FindFirstChild("Important") then
                local plantsPhysical = farm.Farm.Important:FindFirstChild("Plants_Physical")
                if plantsPhysical then
                    local plantFolder = plantsPhysical:FindFirstChild(plantName)
                    if plantFolder and plantFolder:FindFirstChild("Fruits") then
                        local fruit = plantFolder.Fruits:FindFirstChild(plantName) or plantFolder.Fruits:GetChildren()[1]
                        if fruit then
                            local args = {
                                [1] = { [1] = fruit }
                            }
                            game:GetService("ReplicatedStorage").GameEvents.Crops.Collect:FireServer(unpack(args))
                            print("Recolectando " .. plantName .. "...")
                        end
                    end
                end
            end
        end
    end)
    if not success then
        warn("Error recolectando " .. plantName .. ": " .. tostring(err))
    end
end

-- Función para equipar y submitir planta
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
local function equipAndSubmitPlant(plantName, times)
    for i = 1, times do
        if not scriptRunning then break end
        print("Buscando " .. plantName .. " (" .. i .. "/" .. times .. ")")
        local plantFound = false
        while not plantFound and scriptRunning do
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
            if not plantFound and scriptRunning then
                print("No se encontró " .. plantName .. " en inventario, intentando recolectar...")
                collectPlantFromWorld(plantName)
                task.wait(2)
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
    if not config.autoCollect then return end
    
    print("Verificando inventario...")
    local plant1Count = countPlantsInInventory(config.plant1Name)
    print(config.plant1Name .. " en inventario: " .. plant1Count .. "/" .. config.plant1Amount)
    while plant1Count < config.plant1Amount and scriptRunning do
        print("Recolectando " .. config.plant1Name .. " adicional (" .. plant1Count .. "/" .. config.plant1Amount .. ")")
        collectPlantFromWorld(config.plant1Name)
        task.wait(2)
        plant1Count = countPlantsInInventory(config.plant1Name)
    end
    
    local plant2Count = countPlantsInInventory(config.plant2Name)
    print(config.plant2Name .. " en inventario: " .. plant2Count .. "/" .. config.plant2Amount)
    while plant2Count < config.plant2Amount and scriptRunning do
        print("Recolectando " .. config.plant2Name .. " adicional (" .. plant2Count .. "/" .. config.plant2Amount .. ")")
        collectPlantFromWorld(config.plant2Name)
        task.wait(2)
        plant2Count = countPlantsInInventory(config.plant2Name)
    end
    
    print("Inventario verificado: " .. countPlantsInInventory(config.plant1Name) .. " " .. config.plant1Name .. ", " .. countPlantsInInventory(config.plant2Name) .. " " .. config.plant2Name)
end

local iteration = 1
while scriptRunning do
    print("Iniciando iteración #" .. iteration)
    ensureInventoryStock()
    
    -- Enviar primera planta
    print("Equipando " .. config.plant1Name .. "...")
    equipAndSubmitPlant(config.plant1Name, config.plant1Amount)
    
    if scriptRunning then
        print(config.plant1Name .. " enviados, esperando antes de enviar " .. config.plant2Name .. "...")
        task.wait(config.waitBetweenPlants)
        
        -- Enviar segunda planta
        print("Equipando " .. config.plant2Name .. "...")
        equipAndSubmitPlant(config.plant2Name, config.plant2Amount)
        
        if scriptRunning then
            print("Ejecutando CookBest...")
            task.wait(0.5)
            local args = {
                [1] = "CookBest"
            }
            game:GetService("ReplicatedStorage").GameEvents.CookingPotService_RE:FireServer(unpack(args))
            print("Iteración #" .. iteration .. " completada. Esperando antes de la siguiente...")
            iteration = iteration + 1
            task.wait(config.waitBetweenIterations)
        end
    end
end

print("Script detenido.")
end

-- Iniciar la interfaz
createGUI()
