--[[ 
    GAMESENSE.PUB (Skeet) for BloxStrike
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Загрузка интерфейса
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Глобальные настройки
getgenv().SkeetConfig = {
    Aimbot = false,
    AimPart = "Head",
    AimFOV = 150,
    ESP = false,
    Tracers = false,
    Bhop = false,
    TeamCheck = true
}

local Window = Rayfield:CreateWindow({
   Name = "BloxStrike | Skeet.cc",
   LoadingTitle = "GAMESENSE.PUB",
   ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("Main", 4483362458)

Tab:CreateSection("Combat")
Tab:CreateToggle({
    Name = "Aimbot (Right Click)", 
    CurrentValue = false, 
    Callback = function(v) getgenv().SkeetConfig.Aimbot = v end
})
Tab:CreateSlider({
    Name = "FOV Radius", 
    Min = 50, Max = 800, CurrentValue = 150, 
    Callback = function(v) getgenv().SkeetConfig.AimFOV = v end
})

Tab:CreateSection("Visuals")
Tab:CreateToggle({
    Name = "Box ESP", 
    CurrentValue = false, 
    Callback = function(v) getgenv().SkeetConfig.ESP = v end
})
Tab:CreateToggle({
    Name = "Tracers", 
    CurrentValue = false, 
    Callback = function(v) getgenv().SkeetConfig.Tracers = v end
})

Tab:CreateSection("Movement")
Tab:CreateToggle({
    Name = "BunnyHop", 
    CurrentValue = false, 
    Callback = function(v) getgenv().SkeetConfig.Bhop = v end
})

-- РЕНДЕР-ДВИЖОК ДЛЯ ВХ (BOX & TRACERS)
local function API_RenderESP(Player)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(255, 255, 255)
    Box.Thickness = 1
    Box.Filled = false

    local Tracer = Drawing.new("Line")
    Tracer.Visible = false
    Tracer.Color = Color3.fromRGB(255, 255, 255)
    Tracer.Thickness = 1

    RunService.RenderStepped:Connect(function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0 then
            local RootPart = Player.Character.HumanoidRootPart
            local Pos, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)

            if OnScreen and (not getgenv().SkeetConfig.TeamCheck or Player.Team ~= LocalPlayer.Team) then
                local Color = (Player.Team == LocalPlayer.Team) and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                
                -- Отрисовка Бокса
                if getgenv().SkeetConfig.ESP then
                    local SizeX = 2000 / Pos.Z
                    local SizeY = 3000 / Pos.Z
                    Box.Size = Vector2.new(SizeX, SizeY)
                    Box.Position = Vector2.new(Pos.X - SizeX / 2, Pos.Y - SizeY / 2)
                    Box.Color = Color
                    Box.Visible = true
                else
                    Box.Visible = false
                end

                -- Отрисовка Линий
                if getgenv().SkeetConfig.Tracers then
                    Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    Tracer.To = Vector2.new(Pos.X, Pos.Y)
                    Tracer.Color = Color
                    Tracer.Visible = true
                else
                    Tracer.Visible = false
                end
            else
                Box.Visible = false
                Tracer.Visible = false
            end
        else
            Box.Visible = false
            Tracer.Visible = false
        end
    end)
end

-- Применяем ВХ ко всем игрокам
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then API_RenderESP(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then API_RenderESP(p) end end)

-- ЛОГИКА АИМБОТА И БХОПА
local FOVring = Drawing.new("Circle")
FOVring.Thickness = 1
FOVring.Color = Color3.new(1, 1, 1)

RunService.RenderStepped:Connect(function()
    -- Кольцо FOV
    FOVring.Radius = getgenv().SkeetConfig.AimFOV
    FOVring.Position = UIS:GetMouseLocation()
    FOVring.Visible = getgenv().SkeetConfig.Aimbot

    -- Аимбот
    if getgenv().SkeetConfig.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = nil
        local dist = getgenv().SkeetConfig.AimFOV
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
                if not getgenv().SkeetConfig.TeamCheck or v.Team ~= LocalPlayer.Team then
                    local pos, onScreen = Camera:WorldToViewportPoint(v.Character.Head.Position)
                    if onScreen then
                        local mag = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                        if mag < dist then
                            target = v
                            dist = mag
                        end
                    end
                end
            end
        end
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end

    -- Бхоп
    if getgenv().SkeetConfig.Bhop and UIS:IsKeyDown(Enum.KeyCode.Space) then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Jump = true
        end
    end
end)

Rayfield:Notify({Title = "Skeet Loaded", Content = "RightShift to toggle", Duration = 5})
