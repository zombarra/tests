
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local function getPetWeight(petName)
    local weightPattern = "%[(%d+%.?%d*) KG%]"
    local weight = petName:match(weightPattern)
    return weight and tonumber(weight) or 0
end
local function isPetFavorited(tool)
    -- Verificar si la pet está marcada como favorita
    -- Basado en el RemoteEvent Favorite_Item que usa el juego
    
    -- Método 1: Atributos comunes de favoritos
    if tool:GetAttribute("Favorited") or tool:GetAttribute("IsFavorite") or tool:GetAttribute("Starred") then
        return true
    end
    
    -- Método 2: Verificar si hay un indicador visual de favorito
    local handle = tool:FindFirstChild("Handle")
    if handle then
        -- Buscar GUI de favorito
        for _, gui in pairs(handle:GetChildren()) do
            if gui:IsA("BillboardGui") or gui:IsA("SurfaceGui") then
                if gui.Name:lower():find("favorite") or gui.Name:lower():find("star") then
                    return true
                end
                
                -- Verificar contenido del GUI
                for _, child in pairs(gui:GetDescendants()) do
                    if child:IsA("ImageLabel") then
                        local image = child.Image:lower()
                        if image:find("star") or image:find("favorite") then
                            return true
                        end
                    end
                end
            end
        end
    end
    
    -- Método 3: Verificar atributos específicos del sistema de favoritos
    if tool:GetAttribute("IsFav") or tool:GetAttribute("Fav") then
        return true
    end
    
    return false
end
local function sellSpecificPets()
    local character = LocalPlayer.Character
    local backpack = LocalPlayer:WaitForChild("Backpack")
    if not character or not backpack then return end
    local petsFound = 0
    local petsSold = 0
    local petsToSell = {
        "Scarlet Macaw",
        "Blue Jay",
        "Cardinal",
        "Robin",
        "Sparrow",
        "Canary",
        "Gorilla",
        "Toucan"
    }
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            for _, petType in pairs(petsToSell) do
                if tool.Name:find(petType) then
                    petsFound = petsFound + 1
                    local weight = getPetWeight(tool.Name)
                    if isPetFavorited(tool) then
                    elseif weight < 7 and weight > 0 then
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
                    end
                end
            end
        end
    end
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            for _, petType in pairs(petsToSell) do
                if tool.Name:find(petType) then
                    petsFound = petsFound + 1
                    local weight = getPetWeight(tool.Name)
                    if isPetFavorited(tool) then
                    elseif weight < 4 and weight > 0 then
                        local args = {
                            [1] = tool
                        }
                        RS.GameEvents.SellPet_RE:FireServer(unpack(args))
                        petsSold = petsSold + 1
                        task.wait(0.5)
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
            task.wait(5)
        else
            task.wait(10)
        end
    end
end
autoSellLoop()
