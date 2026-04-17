-- Службы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "BloxStrike | Gamesense.pub",
   LoadingTitle = "Skeet.cc Loading...",
   ConfigurationSaving = { Enabled = true, FileName = "SkeetConfig" }
})

-- Настройки (Config)
local Settings = {
    Aimbot = true,
    AimPart = "Head",
    AimFOV = 150,
    ESP = true,
    Bhop = true,
    SkinChanger = true
}

-- Проверка FOV для Аимбота
local FOVring = Drawing.new("Circle")
FOVring.Visible = true
FOVring.Thickness = 1
FOVring.Radius = Settings.AimFOV
FOVring.Color = Color3.fromRGB(255, 255, 255)
FOVring.Filled = false


function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = Settings.AimFOV

    for i, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(Settings.AimPart) then
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character[Settings.AimPart].Position)
            if onScreen then
                local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if magnitude < shortestDistance then
                    closestPlayer = v
                    shortestDistance = magnitude
                end
            end
        end
    end
    return closestPlayer
end

-- Цикл аимбота
RunService.RenderStepped:Connect(function()
    FOVring.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    if Settings.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestPlayer()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character[Settings.AimPart].Position)
        end
    end
end)


-- Простое создание боксов вокруг игроков
local function CreateESP(Player)
    -- Создаем Чамсы (заливка игрока через стены)
    local Highlight = Instance.new("Highlight")
    Highlight.Parent = game:GetService("CoreGui") -- Чтобы не удалили из Character
    Highlight.FillColor = Color3.fromRGB(150, 150, 255)
    Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    Highlight.FillTransparency = 0.5
    Highlight.OutlineTransparency = 0
    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    -- Создаем 2D элементы (Box и HealthBar)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(255, 255, 255)
    Box.Thickness = 1
    
    local HealthBar = Drawing.new("Line")
    HealthBar.Visible = false
    HealthBar.Color = Color3.fromRGB(0, 255, 0)
    HealthBar.Thickness = 2

    local function Update()
        local Connection
        Connection = RunService.RenderStepped:Connect(function()
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character:FindFirstChild("Humanoid") then
                local RootPart = Player.Character.HumanoidRootPart
                local Humanoid = Player.Character.Humanoid
                local Pos, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)

                if OnScreen then
                    -- Обновляем чамсы
                    Highlight.Adornee = Player.Character
                    Highlight.Enabled = true

                    -- Рассчитываем размер бокса в зависимости от дистанции
                    local SizeX = 2000 / Pos.Z
                    local SizeY = 3000 / Pos.Z

                    Box.Size = Vector2.new(SizeX, SizeY)
                    Box.Position = Vector2.new(Pos.X - SizeX / 2, Pos.Y - SizeY / 2)
                    Box.Visible = true
                  
-- Полоска здоровья (слева от бокса)
                    local HealthPercent = Humanoid.Health / Humanoid.MaxHealth
                    HealthBar.From = Vector2.new(Box.Position.X - 5, Box.Position.Y + Box.Size.Y)
                    HealthBar.To = Vector2.new(Box.Position.X - 5, Box.Position.Y + (Box.Size.Y * (1 - HealthPercent)))
                    HealthBar.Color = Color3.fromHSV(HealthPercent * 0.3, 1, 1) -- Меняет цвет с зеленого на красный
                    HealthBar.Visible = true
                else
                    Box.Visible = false
                    HealthBar.Visible = false
                    Highlight.Enabled = false
                end
            else
                Box.Visible = false
                HealthBar.Visible = false
                Highlight.Enabled = false
                if not Player.Parent then Connection:Disconnect() end
            end
        end)
    end
    coroutine.wrap(Update)()
end

-- Применяем ко всем
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CreateESP(p) end
end
Players.PlayerAdded:Connect(CreateESP)


RunService.RenderStepped:Connect(function()
    if Settings.Bhop and game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Jump = true
        end
    end
end)
