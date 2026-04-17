--[[ 
    GAMESENSE.PUB (Skeet) for BloxStrike
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Подгружаем Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Глобальные настройки
getgenv().SkeetConfig = {
    Aimbot = false,
    AimPart = "Head",
    AimFOV = 150,
    ESP = false,
    Bhop = false,
    TeamCheck = true
}

local Window = Rayfield:CreateWindow({
   Name = "BloxStrike | Gamesense.pub",
   LoadingTitle = "Skeet.cc Loading...",
   ConfigurationSaving = { Enabled = true, FileName = "SkeetConfig" }
})

local Tab = Window:CreateTab("Main")

Tab:CreateSection("Combat")

Tab:CreateToggle({
   Name = "Aimbot (Hold Right Click)",
   CurrentValue = false,
   Callback = function(Value) getgenv().SkeetConfig.Aimbot = Value end,
})

Tab:CreateSlider({
   Name = "Aim FOV",
   Min = 50, Max = 500, CurrentValue = 150,
   Callback = function(Value) getgenv().SkeetConfig.AimFOV = Value end,
})

Tab:CreateSection("Visuals")

Tab:CreateToggle({
   Name = "ESP (Chams)",
   CurrentValue = false,
   Callback = function(Value) getgenv().SkeetConfig.ESP = Value end,
})

Tab:CreateSection("Misc")

Tab:CreateToggle({
   Name = "BunnyHop",
   CurrentValue = false,
   Callback = function(Value) getgenv().SkeetConfig.Bhop = Value end,
})

-- Отрисовка FOV кольца
local FOVring = Drawing.new("Circle")
FOVring.Visible = true
FOVring.Thickness = 1
FOVring.Color = Color3.fromRGB(0, 255, 0)
FOVring.Filled = false

-- Функция поиска ближайшего игрока
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = getgenv().SkeetConfig.AimFOV

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(getgenv().SkeetConfig.AimPart) then
            if not getgenv().SkeetConfig.TeamCheck or v.Team ~= LocalPlayer.Team then
                local pos, onScreen = Camera:WorldToViewportPoint(v.Character[getgenv().SkeetConfig.AimPart].Position)
                if onScreen then
                    local mousePos = UIS:GetMouseLocation()
                    local magnitude = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if magnitude < shortestDistance then
                        closestPlayer = v
                        shortestDistance = magnitude
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- Логика Чамсов (ESP)
local function CreateESP(Player)
    local Highlight = Instance.new("Highlight")
    Highlight.Name = "SkeetHighlight"
    Highlight.Parent = game:GetService("CoreGui")
    Highlight.FillTransparency = 0.5
    Highlight.OutlineTransparency = 0
    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    RunService.RenderStepped:Connect(function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and getgenv().SkeetConfig.ESP then
            Highlight.Adornee = Player.Character
            Highlight.Enabled = true
            Highlight.FillColor = (Player.Team == LocalPlayer.Team) and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
        else
            Highlight.Enabled = false
        end
    end)
end

-- Запуск ESP для всех
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CreateESP(p) end
end
Players.PlayerAdded:Connect(CreateESP)

-- Основной цикл
RunService.RenderStepped:Connect(function()
    -- Обновляем кольцо FOV
    FOVring.Radius = getgenv().SkeetConfig.AimFOV
    FOVring.Position = UIS:GetMouseLocation()
    FOVring.Visible = getgenv().SkeetConfig.Aimbot

    -- Работа Аимбота
    if getgenv().SkeetConfig.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestPlayer()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character[getgenv().SkeetConfig.AimPart].Position)
        end
    end

    -- Работа Бхопа
    if getgenv().SkeetConfig.Bhop and UIS:IsKeyDown(Enum.KeyCode.Space) then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Jump = true
        end
    end
end)

Rayfield:Notify({
   Title = "Skeet.cc Loaded",
   Content = "Welcome back, legend. Menu: RightShift",
   Duration = 5
})
