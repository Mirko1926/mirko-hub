-- Mirko Hub Rivals
-- Toggle Aimbot: Right Click (hold)
-- UI draggabile con toggle per ESP, Aimbot, e impostazioni

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = game:GetService("Workspace").CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Config
local Config = {
    ESP = true,
    ESPBoxes = true,
    ESPNames = true,
    ESPHealth = true,
    ESPDistance = true,
    Aimbot = true,
    AimbotFOV = 250,
    AimbotSmooth = 5,
    AimbotTarget = "Head", -- Head / HitboxHead / HumanoidRootPart
    ShowFOV = true,
    TeamCheck = false,
    MaxDistance = 1000,
}

-- Stato
local AimbotActive = false
local CurrentTarget = nil
local Highlights = {}
local ESPObjects = {}
local Connections = {}

-----------------------------------------------------------
-- UI
-----------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MirkoHubRivals"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

-- Main Frame
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 280, 0, 0)
Main.Position = UDim2.new(0.5, -140, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 8)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Color3.fromRGB(120, 80, 255)
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.3

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 32)
TitleBar.BackgroundColor3 = Color3.fromRGB(120, 80, 255)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local TitleCorner = Instance.new("UICorner", TitleBar)
TitleCorner.CornerRadius = UDim.new(0, 8)

-- bottom cover for title bar corners
local TitleCover = Instance.new("Frame")
TitleCover.Size = UDim2.new(1, 0, 0, 10)
TitleCover.Position = UDim2.new(0, 0, 1, -10)
TitleCover.BackgroundColor3 = Color3.fromRGB(120, 80, 255)
TitleCover.BorderSizePixel = 0
TitleCover.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text = "MIRKO HUB - RIVALS"
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.Parent = TitleBar

-- Minimize button
local MinBtn = Instance.new("TextButton")
MinBtn.Text = "-"
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -30, 0, 2)
MinBtn.BackgroundTransparency = 1
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18
MinBtn.Parent = TitleBar

-- Content
local Content = Instance.new("ScrollingFrame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -16, 1, -40)
Content.Position = UDim2.new(0, 8, 0, 36)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = Color3.fromRGB(120, 80, 255)
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.Parent = Main

local ContentLayout = Instance.new("UIListLayout", Content)
ContentLayout.Padding = UDim.new(0, 4)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Drag
local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Minimize
local isOpen = true
local targetSize = UDim2.new(0, 280, 0, 320)
Main.Size = targetSize

MinBtn.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    MinBtn.Text = isOpen and "-" or "+"
    local goal = isOpen and UDim2.new(0, 280, 0, 320) or UDim2.new(0, 280, 0, 32)
    game:GetService("TweenService"):Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = goal}):Play()
end)

-----------------------------------------------------------
-- UI Components
-----------------------------------------------------------
local function CreateSection(name, order)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 22)
    section.BackgroundTransparency = 1
    section.LayoutOrder = order
    section.Parent = Content

    local label = Instance.new("TextLabel")
    label.Text = "-- " .. name .. " --"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(120, 80, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Parent = section

    return section
end

local function CreateToggle(name, default, order, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 28)
    holder.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    holder.BorderSizePixel = 0
    holder.LayoutOrder = order
    holder.Parent = Content
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Text = name
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 210)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.Parent = holder

    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 36, 0, 18)
    toggleBg.Position = UDim2.new(1, -44, 0.5, -9)
    toggleBg.BackgroundColor3 = default and Color3.fromRGB(120, 80, 255) or Color3.fromRGB(50, 50, 60)
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = holder
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 14, 0, 14)
    circle.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.BorderSizePixel = 0
    circle.Parent = toggleBg
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local enabled = default
    local btn = Instance.new("TextButton")
    btn.Text = ""
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Parent = holder

    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        local ts = game:GetService("TweenService")
        ts:Create(toggleBg, TweenInfo.new(0.2), {BackgroundColor3 = enabled and Color3.fromRGB(120, 80, 255) or Color3.fromRGB(50, 50, 60)}):Play()
        ts:Create(circle, TweenInfo.new(0.2), {Position = enabled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
        callback(enabled)
    end)

    return holder
end

local function CreateSlider(name, min, max, default, order, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 40)
    holder.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    holder.BorderSizePixel = 0
    holder.LayoutOrder = order
    holder.Parent = Content
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Text = name
    label.Size = UDim2.new(0.6, -10, 0, 18)
    label.Position = UDim2.new(0, 10, 0, 2)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 210)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.Parent = holder

    local valLabel = Instance.new("TextLabel")
    valLabel.Text = tostring(default)
    valLabel.Size = UDim2.new(0.4, -10, 0, 18)
    valLabel.Position = UDim2.new(0.6, 0, 0, 2)
    valLabel.BackgroundTransparency = 1
    valLabel.TextColor3 = Color3.fromRGB(120, 80, 255)
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 11
    valLabel.Parent = holder

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -20, 0, 6)
    sliderBg.Position = UDim2.new(0, 10, 0, 28)
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = holder
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(120, 80, 255)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Text = ""
    sliderBtn.Size = UDim2.new(1, 0, 1, 10)
    sliderBtn.Position = UDim2.new(0, 0, 0, -5)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Parent = sliderBg

    local sliding = false
    sliderBtn.MouseButton1Down:Connect(function() sliding = true end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            local absPos = sliderBg.AbsolutePosition.X
            local absSize = sliderBg.AbsoluteSize.X
            local rel = math.clamp((input.Position.X - absPos) / absSize, 0, 1)
            local val = math.floor(min + (max - min) * rel)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            valLabel.Text = tostring(val)
            callback(val)
        end
    end)

    return holder
end

local function CreateDropdown(name, options, default, order, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 28)
    holder.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    holder.BorderSizePixel = 0
    holder.LayoutOrder = order
    holder.Parent = Content
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Text = name
    label.Size = UDim2.new(0.5, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 210)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.Parent = holder

    local current = default
    local idx = table.find(options, default) or 1

    local btn = Instance.new("TextButton")
    btn.Text = current .. "  >"
    btn.Size = UDim2.new(0.5, -10, 1, 0)
    btn.Position = UDim2.new(0.5, 0, 0, 0)
    btn.BackgroundTransparency = 1
    btn.TextColor3 = Color3.fromRGB(120, 80, 255)
    btn.TextXAlignment = Enum.TextXAlignment.Right
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = holder

    btn.MouseButton1Click:Connect(function()
        idx = idx % #options + 1
        current = options[idx]
        btn.Text = current .. "  >"
        callback(current)
    end)

    return holder
end

-----------------------------------------------------------
-- Build UI
-----------------------------------------------------------
CreateSection("ESP", 1)
CreateToggle("ESP Enabled", Config.ESP, 2, function(v) Config.ESP = v end)
CreateToggle("Boxes", Config.ESPBoxes, 3, function(v) Config.ESPBoxes = v end)
CreateToggle("Names", Config.ESPNames, 4, function(v) Config.ESPNames = v end)
CreateToggle("Health Bar", Config.ESPHealth, 5, function(v) Config.ESPHealth = v end)
CreateToggle("Distance", Config.ESPDistance, 6, function(v) Config.ESPDistance = v end)

CreateSection("AIMBOT", 10)
CreateToggle("Aimbot Enabled", Config.Aimbot, 11, function(v) Config.Aimbot = v end)
CreateSlider("FOV Size", 50, 600, Config.AimbotFOV, 12, function(v) Config.AimbotFOV = v end)
CreateSlider("Smoothing", 1, 20, Config.AimbotSmooth, 13, function(v) Config.AimbotSmooth = v end)
CreateDropdown("Target Part", {"Head", "HitboxHead", "HumanoidRootPart"}, Config.AimbotTarget, 14, function(v) Config.AimbotTarget = v end)
CreateToggle("Show FOV Circle", Config.ShowFOV, 15, function(v) Config.ShowFOV = v end)

CreateSection("MISC", 20)
CreateSlider("Max Distance", 100, 2000, Config.MaxDistance, 21, function(v) Config.MaxDistance = v end)

-----------------------------------------------------------
-- FOV Circle (Drawing API)
-----------------------------------------------------------
local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = Config.AimbotFOV
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(120, 80, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 0.6
FOVCircle.Visible = Config.ShowFOV

-----------------------------------------------------------
-- ESP Drawing per player
-----------------------------------------------------------
local function CreateESPDrawings()
    return {
        BoxOutline = Drawing.new("Quad"),
        Box = Drawing.new("Quad"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Line"),
        HealthBg = Drawing.new("Line"),
        Distance = Drawing.new("Text"),
    }
end

local function SetupDrawings(d)
    -- Box outline
    d.BoxOutline.Thickness = 3
    d.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
    d.BoxOutline.Filled = false
    d.BoxOutline.Visible = false

    -- Box
    d.Box.Thickness = 1.5
    d.Box.Color = Color3.fromRGB(120, 80, 255)
    d.Box.Filled = false
    d.Box.Visible = false

    -- Name
    d.Name.Size = 13
    d.Name.Color = Color3.fromRGB(255, 255, 255)
    d.Name.Outline = true
    d.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
    d.Name.Center = true
    d.Name.Font = Drawing.Fonts.Plex
    d.Name.Visible = false

    -- Health bar bg
    d.HealthBg.Thickness = 4
    d.HealthBg.Color = Color3.fromRGB(0, 0, 0)
    d.HealthBg.Visible = false

    -- Health bar
    d.Health.Thickness = 2
    d.Health.Color = Color3.fromRGB(0, 255, 0)
    d.Health.Visible = false

    -- Distance
    d.Distance.Size = 12
    d.Distance.Color = Color3.fromRGB(180, 180, 190)
    d.Distance.Outline = true
    d.Distance.OutlineColor = Color3.fromRGB(0, 0, 0)
    d.Distance.Center = true
    d.Distance.Font = Drawing.Fonts.Plex
    d.Distance.Visible = false
end

local function RemoveESP(player)
    if ESPObjects[player] then
        for _, d in pairs(ESPObjects[player]) do
            pcall(function() d:Remove() end)
        end
        ESPObjects[player] = nil
    end
end

local function HideESP(drawings)
    for _, d in pairs(drawings) do
        d.Visible = false
    end
end

-----------------------------------------------------------
-- Utility
-----------------------------------------------------------
local function GetCharacter(player)
    return game:GetService("Workspace"):FindFirstChild(player.Name)
end

local function IsAlive(character)
    local hum = character:FindFirstChildOfClass("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    return hum and hrp and hum.Health > 0
end

local function GetTargetPart(character)
    local partName = Config.AimbotTarget
    return character:FindFirstChild(partName) or character:FindFirstChild("Head")
end

local function WorldToScreen(pos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

-----------------------------------------------------------
-- ESP Update Loop
-----------------------------------------------------------
local function UpdateESP()
    local localChar = GetCharacter(LocalPlayer)
    if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return end
    local localPos = localChar.HumanoidRootPart.Position

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        local character = GetCharacter(player)
        if not character or not IsAlive(character) then
            if ESPObjects[player] then HideESP(ESPObjects[player]) end
            continue
        end

        -- Team check
        if Config.TeamCheck and player.Team == LocalPlayer.Team then
            if ESPObjects[player] then HideESP(ESPObjects[player]) end
            continue
        end

        local hrp = character:FindFirstChild("HumanoidRootPart")
        local head = character:FindFirstChild("Head")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not hrp or not head or not humanoid then
            if ESPObjects[player] then HideESP(ESPObjects[player]) end
            continue
        end

        local dist = (localPos - hrp.Position).Magnitude
        if dist > Config.MaxDistance then
            if ESPObjects[player] then HideESP(ESPObjects[player]) end
            continue
        end

        -- Create drawings if needed
        if not ESPObjects[player] then
            ESPObjects[player] = CreateESPDrawings()
            SetupDrawings(ESPObjects[player])
        end

        local d = ESPObjects[player]

        if not Config.ESP then
            HideESP(d)
            continue
        end

        -- Calculate 3D bounding box corners
        local rootPos = hrp.Position
        local topPos = rootPos + Vector3.new(0, 3.2, 0)
        local botPos = rootPos - Vector3.new(0, 3.2, 0)

        local topScreen, topOnScreen = WorldToScreen(topPos)
        local botScreen, botOnScreen = WorldToScreen(botPos)

        if not topOnScreen and not botOnScreen then
            HideESP(d)
            continue
        end

        local height = math.abs(botScreen.Y - topScreen.Y)
        local width = height * 0.55

        local centerX = (topScreen.X + botScreen.X) / 2

        -- Box corners
        local tl = Vector2.new(centerX - width / 2, topScreen.Y)
        local tr = Vector2.new(centerX + width / 2, topScreen.Y)
        local bl = Vector2.new(centerX - width / 2, botScreen.Y)
        local br = Vector2.new(centerX + width / 2, botScreen.Y)

        -- Boxes
        if Config.ESPBoxes then
            d.BoxOutline.PointA = tl
            d.BoxOutline.PointB = tr
            d.BoxOutline.PointC = br
            d.BoxOutline.PointD = bl
            d.BoxOutline.Visible = true

            d.Box.PointA = tl
            d.Box.PointB = tr
            d.Box.PointC = br
            d.Box.PointD = bl
            d.Box.Visible = true
        else
            d.BoxOutline.Visible = false
            d.Box.Visible = false
        end

        -- Name
        if Config.ESPNames then
            d.Name.Text = player.DisplayName
            d.Name.Position = Vector2.new(centerX, topScreen.Y - 16)
            d.Name.Visible = true
        else
            d.Name.Visible = false
        end

        -- Health
        if Config.ESPHealth then
            local hp = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
            local barX = tl.X - 5

            d.HealthBg.From = Vector2.new(barX, botScreen.Y)
            d.HealthBg.To = Vector2.new(barX, topScreen.Y)
            d.HealthBg.Visible = true

            d.Health.From = Vector2.new(barX, botScreen.Y)
            d.Health.To = Vector2.new(barX, botScreen.Y - height * hp)
            d.Health.Color = Color3.fromRGB(255 * (1 - hp), 255 * hp, 0)
            d.Health.Visible = true
        else
            d.HealthBg.Visible = false
            d.Health.Visible = false
        end

        -- Distance
        if Config.ESPDistance then
            d.Distance.Text = math.floor(dist) .. "m"
            d.Distance.Position = Vector2.new(centerX, botScreen.Y + 2)
            d.Distance.Visible = true
        else
            d.Distance.Visible = false
        end
    end
end

-----------------------------------------------------------
-- Aimbot
-----------------------------------------------------------
local function GetClosestTarget()
    local closest = nil
    local closestDist = Config.AimbotFOV
    local localChar = GetCharacter(LocalPlayer)
    if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return nil end
    local localPos = localChar.HumanoidRootPart.Position
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Config.TeamCheck and player.Team == LocalPlayer.Team then continue end

        local character = GetCharacter(player)
        if not character or not IsAlive(character) then continue end

        local targetPart = GetTargetPart(character)
        if not targetPart then continue end

        local dist3d = (localPos - targetPart.Position).Magnitude
        if dist3d > Config.MaxDistance then continue end

        local screenPos, onScreen = WorldToScreen(targetPart.Position)
        if not onScreen then continue end

        local screenDist = (screenPos - screenCenter).Magnitude
        if screenDist < closestDist then
            closestDist = screenDist
            closest = targetPart
        end
    end

    return closest
end

-- Right click hold = aimbot active
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimbotActive = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimbotActive = false
        CurrentTarget = nil
    end
end)

-----------------------------------------------------------
-- Main Loop
-----------------------------------------------------------
Connections.Render = RunService.RenderStepped:Connect(function()
    -- FOV Circle
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Position = center
    FOVCircle.Radius = Config.AimbotFOV
    FOVCircle.Visible = Config.ShowFOV and Config.Aimbot

    -- ESP
    UpdateESP()

    -- Aimbot
    if Config.Aimbot and AimbotActive then
        if CurrentTarget and CurrentTarget.Parent and CurrentTarget.Parent:FindFirstChildOfClass("Humanoid") then
            local hum = CurrentTarget.Parent:FindFirstChildOfClass("Humanoid")
            if hum.Health <= 0 then
                CurrentTarget = nil
            end
        else
            CurrentTarget = nil
        end

        if not CurrentTarget then
            CurrentTarget = GetClosestTarget()
        end

        if CurrentTarget then
            local targetScreen, onScreen = WorldToScreen(CurrentTarget.Position)
            if onScreen then
                local currentAim = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local diff = (targetScreen - currentAim) / Config.AimbotSmooth
                mousemoverel(diff.X, diff.Y)
            end
        end
    end
end)

-----------------------------------------------------------
-- Cleanup on player leave
-----------------------------------------------------------
Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

-----------------------------------------------------------
-- Toggle UI visibility (Right Ctrl)
-----------------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-----------------------------------------------------------
-- Cleanup function
-----------------------------------------------------------
local function Cleanup()
    for _, conn in pairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end
    for player, _ in pairs(ESPObjects) do
        RemoveESP(player)
    end
    FOVCircle:Remove()
    ScreenGui:Destroy()
end

-- Store cleanup for external access
getgenv().MirkoHubCleanup = Cleanup
