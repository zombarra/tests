
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local function getPetWeight(petName)
    local weightPattern = "%[(%d+%.?%d*) KG%]"
    local weight = petName:match(weightPattern)
    return weight and tonumber(weight) or 0
end
local function isPetFavorited(tool)
    -- Método 1: Verificar todos los atributos posibles
    local attributes = {"favorited", "IsFavorite", "Starred", "IsFav", "Fav", "Favorite", "Star"}
    for _, attr in pairs(attributes) do
        if tool:GetAttribute(attr) then
            return true
        end
    end
    
    -- Método 2: Verificar en el Handle
    local handle = tool:FindFirstChild("Handle")
    if handle then
        -- Verificar atributos del handle también
        for _, attr in pairs(attributes) do
            if handle:GetAttribute(attr) then
                return true
            end
        end
        
        -- Buscar cualquier GUI relacionado con favoritos
        for _, child in pairs(handle:GetDescendants()) do
            local name = child.Name:lower()
            if name:find("favorited") or name:find("star") or name:find("fav") then
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
    
    -- Método 3: Verificar el nombre del tool
    local toolName = tool.Name:lower()
    if toolName:find("⭐") or toolName:find("★") or toolName:find("fav") then
        return true
    end
    
    -- Método 4: Verificar si el tool tiene propiedades especiales
    if tool:FindFirstChild("FavoriteIcon") or tool:FindFirstChild("StarIcon") or tool:FindFirstChild("Favorite") then
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
        "Moon Cat",
        "Squirrel",
        "Toucan",
        "Canary",
        "Gorilla",
        "Toucan"
    }
    
    -- Buscar SOLO UNA pet en backpack por ciclo
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and petsSold == 0 then -- Solo vender 1 por ciclo
            for _, petType in pairs(petsToSell) do
                if tool.Name:find(petType) then
                    local weight = getPetWeight(tool.Name)
                    if isPetFavorited(tool) then
                        -- No vender favoritos
                    elseif weight < 2.40 and weight > 0 then
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid:UnequipTools()
                            task.wait(0.5) -- Espera más larga
                            humanoid:EquipTool(tool)
                            task.wait(1) -- Espera más larga
                            local args = {
                                [1] = character:FindFirstChild(tool.Name)
                            }
                            if args[1] then
                                RS.GameEvents.SellPet_RE:FireServer(unpack(args))
                                petsSold = petsSold + 1
                                task.wait(2) -- Espera larga después de vender
                                return petsSold -- Salir inmediatamente
                            end
                        end
                    end
                    break
                end
            end
        end
    end
    
    -- Buscar SOLO UNA pet en character por ciclo (solo si no vendió en backpack)
    if petsSold == 0 then
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                for _, petType in pairs(petsToSell) do
                    if tool.Name:find(petType) then
                        local weight = getPetWeight(tool.Name)
                        if isPetFavorited(tool) then
                            -- No vender favoritos equipados
                        elseif weight < 2.40 and weight > 0 then
                            local args = {
                                [1] = tool
                            }
                            RS.GameEvents.SellPet_RE:FireServer(unpack(args))
                            petsSold = petsSold + 1
                            task.wait(2) -- Espera larga
                            return petsSold -- Salir inmediatamente
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

local function autoSellLoop()
    while true do
        local sold = sellSpecificPets()
        if sold > 0 then
            task.wait(15) -- Espera 15 segundos después de vender
        else
            task.wait(10) -- Espera 10 segundos si no vendió nada
        end
    end
end

autoSellLoop()
