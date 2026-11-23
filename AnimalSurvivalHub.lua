-- Animal Survival Hub
-- LocalScript demonstrativo para Roblox Studio em um jogo que você controla.
-- Coloque em StarterPlayer > StarterPlayerScripts.

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local autoFarm, animalESP, playerESP, autoCombat = false, false, false, false
local espObjects = {}

local gui = Instance.new("ScreenGui")
gui.Name = "AnimalSurvivalHub"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 460, 0, 330)
main.Position = UDim2.new(0.5, -230, 0.5, -165)
main.BackgroundColor3 = Color3.fromRGB(23, 23, 30)
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, 0, 0, 45)
header.BackgroundColor3 = Color3.fromRGB(35, 35, 46)
header.Text = "  ANIMAL SURVIVAL HUB"
header.TextColor3 = Color3.new(1, 1, 1)
header.Font = Enum.Font.GothamBold
header.TextSize = 16
header.TextXAlignment = Enum.TextXAlignment.Left
header.Parent = main
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

local dragging, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging, dragStart, startPos = true, input.Position, main.Position
    end
end)
header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local sidebar = Instance.new("Frame")
sidebar.Position = UDim2.new(0, 0, 0, 45)
sidebar.Size = UDim2.new(0, 120, 1, -45)
sidebar.BackgroundColor3 = Color3.fromRGB(29, 29, 37)
sidebar.Parent = main

local content = Instance.new("Frame")
content.Position = UDim2.new(0, 130, 0, 55)
content.Size = UDim2.new(1, -140, 1, -65)
content.BackgroundTransparency = 1
content.Parent = main

local function clearContent()
    for _, child in ipairs(content:GetChildren()) do child:Destroy() end
end

local function button(text, callback, parent, position, width)
    local b = Instance.new("TextButton")
    b.Size = width or UDim2.new(1, -10, 0, 38)
    b.Position = position
    b.BackgroundColor3 = Color3.fromRGB(42, 42, 54)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Text = text
    b.Font = Enum.Font.Gotham
    b.TextSize = 13
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    b.MouseButton1Click:Connect(callback)
    return b
end

local function toggle(text, getter, setter, parent, position)
    local b
    b = button(text .. (getter() and " [ON]" or " [OFF]"), function()
        setter(not getter())
        b.Text = text .. (getter() and " [ON]" or " [OFF]")
    end, parent, position)
    return b
end

local function addHighlight(model, color)
    if not model or not model:IsA("Model") or espObjects[model] then return end
    local h = Instance.new("Highlight")
    h.FillColor, h.OutlineColor, h.FillTransparency = color, Color3.new(1,1,1), 0.55
    h.Adornee, h.Parent = model, gui
    espObjects[model] = h
end

local function removeHighlights()
    for _, highlight in pairs(espObjects) do if highlight then highlight:Destroy() end end
    table.clear(espObjects)
end

local function refreshESP()
    removeHighlights()
    if animalESP then
        for _, animal in ipairs(CollectionService:GetTagged("Animal")) do
            addHighlight(animal, Color3.fromRGB(70, 255, 100))
        end
    end
    if playerESP then
        for _, other in ipairs(Players:GetPlayers()) do
            if other ~= player and other.Character then
                addHighlight(other.Character, Color3.fromRGB(255, 70, 70))
            end
        end
    end
end

local function makeTab(name, callback, index)
    button(name, callback, sidebar, UDim2.new(0, 5, 0, (index - 1) * 43 + 5))
end

local function farmTab()
    clearContent()
    toggle("Auto Farm (demo)", function() return autoFarm end,
        function(v) autoFarm = v end, content, UDim2.new(0, 5, 0, 5))
    local info = Instance.new("TextLabel")
    info.Size, info.Position = UDim2.new(1, -10, 0, 100), UDim2.new(0, 5, 0, 55)
    info.BackgroundTransparency, info.TextColor3 = 1, Color3.fromRGB(180,180,190)
    info.TextWrapped, info.Font, info.TextSize = true, Enum.Font.Gotham, 12
    info.Text = "Demo: coleta deve ser implementada e validada no servidor do seu próprio jogo usando objetos com a tag Food."
    info.Parent = content
end

local function espTab()
    clearContent()
    toggle("Animal ESP", function() return animalESP end,
        function(v) animalESP = v; refreshESP() end, content, UDim2.new(0, 5, 0, 5))
    toggle("Player ESP", function() return playerESP end,
        function(v) playerESP = v; refreshESP() end, content, UDim2.new(0, 5, 0, 50))
end

local function combatTab()
    clearContent()
    toggle("Auto Combat (demo)", function() return autoCombat end,
        function(v) autoCombat = v end, content, UDim2.new(0, 5, 0, 5))
    local info = Instance.new("TextLabel")
    info.Size, info.Position = UDim2.new(1, -10, 0, 100), UDim2.new(0, 5, 0, 55)
    info.BackgroundTransparency, info.TextColor3 = 1, Color3.fromRGB(180,180,190)
    info.TextWrapped, info.Font, info.TextSize = true, Enum.Font.Gotham, 12
    info.Text = "Demo: configure ataques e dano no servidor do seu próprio jogo."
    info.Parent = content
end

local function teleportTab()
    clearContent()
    local points = CollectionService:GetTagged("TeleportPoint")
    if #points == 0 then
        local info = Instance.new("TextLabel")
        info.Size, info.Position = UDim2.new(1, -10, 0, 100), UDim2.new(0, 5, 0, 5)
        info.BackgroundTransparency, info.TextColor3 = 1, Color3.fromRGB(180,180,190)
        info.TextWrapped, info.Font, info.TextSize = true, Enum.Font.Gotham, 12
        info.Text = "Adicione a tag TeleportPoint a locais no seu próprio projeto para configurar destinos."
        info.Parent = content
        return
    end
    for i, point in ipairs(points) do
        button(point.Name, function()
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root and point:IsA("BasePart") then root.CFrame = point.CFrame + Vector3.new(0,4,0)
            elseif root and point:IsA("Model") then root.CFrame = point:GetPivot() + Vector3.new(0,4,0) end
        end, content, UDim2.new(0, 5, 0, (i - 1) * 43 + 5))
    end
end

makeTab("Farm", farmTab, 1)
makeTab("ESP", espTab, 2)
makeTab("Combat", combatTab, 3)
makeTab("Teleport", teleportTab, 4)

button("X", function() main.Visible = not main.Visible end,
    header, UDim2.new(1, -40, 0, 3), UDim2.new(0, 35, 0, 35))

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        main.Visible = not main.Visible
    end
end)

task.spawn(function()
    while task.wait(1) do
        if autoFarm then
            for _, food in ipairs(CollectionService:GetTagged("Food")) do
                if food:IsA("BasePart") then print("Food encontrado:", food.Name) end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(3) do
        if animalESP or playerESP then refreshESP() end
    end
end)
