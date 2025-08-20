
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local function getPetWeight(petName)
    local weightPattern = "%[(%d+%.?%d*) KG%]"
    local weight = petName:match(weightPattern)
    return weight and tonumber(weight) or 0
end
local function isPetFavorited(tool)
    -- Método más directo basado en cómo funciona el sistema de favoritos
    
    -- Verificar atributos que el juego probablemente usa
    if tool:GetAttribute("Favorited") == true then
        return true
    end
    
    if tool:GetAttribute("IsFavorite") == true then
        return true
    end
    
    -- Verificar si el tool tiene algún indicador visual
    local handle = tool:FindFirstChild("Handle")
    if handle then
        -- Buscar GUI específico de favoritos
        local favoriteGui = handle:FindFirstChild("FavoriteGui") or handle:FindFirstChild("StarGui")
        if favoriteGui and favoriteGui.Visible then
            return true
        end
        
        -- Buscar imágenes de estrella visible
        for _, gui in pairs(handle:GetChildren()) do
            if gui:IsA("BillboardGui") and gui.Enabled then
                local star = gui:FindFirstChild("Star") or gui:FindFirstChild("Favorite")
                if star and star.Visible then
                    return true
                end
            end
        end
    end
    
    -- Método alternativo: verificar si el nombre del tool contiene algún indicador
    if tool.Name:find("⭐") or tool.Name:find("★") then
        return true
    end
    
    return false
end
local function sellSpecificPets()
    local character = LocalPlayer.Character
    local backpack = LocalPlayer:WaitForChild("Backpack")
    if not character or not backpack then return 0 end
    
    local petsSold = 0
    local petsToSell = {
        "Scarlet Macaw",
        "Blue Jay", 
        "Cardinal",
        "Robin",
        "Sparrow",
        "Canary",
        "Gorilla",
        "Finch"
    }
    
    -- Buscar en backpack
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            for _, petType in pairs(petsToSell) do
                if tool.Name:find(petType) then
                    local weight = getPetWeight(tool.Name)
                    -- Verificar favoritos antes de vender
                    if isPetFavorited(tool) then
                        -- No vender favoritos
                    elseif weight < 5 and weight > 0 then
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid:UnequipTools()
                            task.wait(0.1)
                            humanoid:EquipTool(tool)
                            task.wait(0.3)
                            local args = {
                                [1] = character:FindFirstChild(tool.Name)
                            }
                            if args[1] then
                                RS.GameEvents.SellPet_RE:FireServer(unpack(args))
                                petsSold = petsSold + 1
                                task.wait(0.5)
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
                    if isPetFavorited(tool) then
                        -- No vender favoritos equipados
                    elseif weight < 5 and weight > 0 then
                        local args = {
                            [1] = tool
                        }
                        RS.GameEvents.SellPet_RE:FireServer(unpack(args))
                        petsSold = petsSold + 1
                        task.wait(0.5)
                    end
                    break
                end
            end
        end
    end
    
    if petsSold > 0 then
        RS.GameEvents.SaveSlotService.RememberUnlockage:FireServer()
    end
    return petsSold
end

local function autoSellLoop()
    while true do
        local sold = sellSpecificPets()
        if sold > 0 then
            task.wait(5)
        else
            task.wait(10)
        end
    end
end

autoSellLoop()
