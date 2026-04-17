local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "BloxStrike | Gamesense.pub",
   LoadingTitle = "Loading Skeet...",
   LoadingSubtitle = "by xxenokatana",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "SkeetConfigs",
      FileName = "MainConfig"
   }
})

local Tab = Window:CreateTab("Main", 4483362458) -- Иконка

Tab:CreateSection("Combat")

Tab:CreateToggle({
   Name = "Aimbot",
   CurrentValue = false,
   Callback = function(Value)
      print("Aimbot is now:", Value)
      -- Сюда вставляем логику аимбота
   end,
})

Tab:CreateSection("Visuals")

Tab:CreateToggle({
   Name = "ESP (Box & Chams)",
   CurrentValue = false,
   Callback = function(Value)
      _G.ESP_Enabled = Value
   end,
})

Rayfield:Notify({
   Title = "Success!",
   Content = "Gamesense loaded. Press RightShift to hide menu.",
   Duration = 5,
   Image = 4483362458,
})
