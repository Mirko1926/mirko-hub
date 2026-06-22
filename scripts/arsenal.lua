--[[
    Mirko Hub - Arsenal
    Custom lightweight UI - no external libraries
]]

-- Cleanup previous executions
if _G.MirkoHub then
    pcall(function()
        for _, conn in pairs(_G.MirkoHub.Connections) do
            pcall(function() conn:Disconnect() end)
        end
    end)
    pcall(function() _G.MirkoHub.FOV:Remove() end)
    pcall(function() _G.MirkoHub.GUI:Destroy() end)
    pcall(function()
        for _, data in pairs(_G.MirkoHub.ESP or {}) do
            for _, obj in pairs(data) do pcall(function() obj:Remove() end) end
        end
    end)
end
_G.MirkoHub = { Connections = {}, ESP = {} }

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

-- Settings
local S = {
    Aimbot = false,
    AimbotFOV = 150,
    AimbotSmooth = 5,
    AimbotWallCheck = true,
    AimbotTeamCheck = true,
    AimbotPart = "Head",
    ShowFOV = false,

    ESP = false,
    ESPBoxes = true,
    ESPNames = true,
    ESPHealth = true,
    ESPTracers = false,
    ESPTeamCheck = true,
    ESPColor = Color3.fromRGB(255, 50, 50),

    Fly = false,
    FlySpeed = 50,
    FlyUndetected = false,
    Speed = false,
    SpeedValue = 30,
    InfJump = false,

    TpKill = false,
    TpKillDelay = 0.5,
    Fullbright = false,
    AntiAFK = false,
}

local Conn = _G.MirkoHub.Connections

---------------------------------------------
-- CUSTOM UI
---------------------------------------------

local GUI = Instance.new("ScreenGui")
GUI.Name = "MirkoHub"
GUI.ResetOnSpawn = false
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() GUI.Parent = game:GetService("CoreGui") end)
if not GUI.Parent then GUI.Parent = LP.PlayerGui end
_G.MirkoHub.GUI = GUI

-- Main Frame
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 450, 0, 350)
Main.Position = UDim2.new(0.5, -225, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BorderSizePixel = 0
Main.Parent = GUI
Main.ClipsDescendants = true
Main.Active = true
Main.Draggable = true

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Main

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 32)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 10)
TitleFix.Position = UDim2.new(0, 0, 1, -10)
TitleFix.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Mirko Hub | Arsenal"
TitleLabel.TextColor3 = Color3.new(1, 1, 1)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Minimize button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 24, 0, 24)
MinBtn.Position = UDim2.new(1, -28, 0, 4)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.TextSize = 16
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 4)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    local targetSize = minimized and UDim2.new(0, 450, 0, 32) or UDim2.new(0, 450, 0, 350)
    TweenService:Create(Main, TweenInfo.new(0.2), {Size = targetSize}):Play()
    MinBtn.Text = minimized and "+" or "-"
end)

-- Tab buttons
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, 100, 1, -32)
TabBar.Position = UDim2.new(0, 0, 0, 32)
TabBar.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
TabBar.BorderSizePixel = 0
TabBar.Parent = Main

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -100, 1, -32)
ContentFrame.Position = UDim2.new(0, 100, 0, 32)
ContentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = Main

-- Tab system
local tabs = {}
local currentTab = nil

local function createTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, #tabs * 30)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamSemibold
    btn.BorderSizePixel = 0
    btn.Parent = TabBar

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -10, 1, -5)
    page.Position = UDim2.new(0, 5, 0, 5)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = ContentFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.Parent = page

    local tab = {Button = btn, Page = page, Layout = layout, YOffset = 0}
    table.insert(tabs, tab)

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.Page.Visible = false
            t.Button.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
        tab.Page.Visible = true
        tab.Button.TextColor3 = Color3.fromRGB(100, 180, 255)
        currentTab = tab
    end)

    return tab
end

local function addToggle(tab, name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 28)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    frame.BorderSizePixel = 0
    frame.Parent = tab.Page
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 36, 0, 18)
    btn.Position = UDim2.new(1, -44, 0.5, -9)
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 9)

    local state = default
    local function update()
        btn.BackgroundColor3 = state and Color3.fromRGB(80, 170, 255) or Color3.fromRGB(60, 60, 70)
        callback(state)
    end
    update()

    btn.MouseButton1Click:Connect(function()
        state = not state
        update()
    end)
    return btn
end

local function addSlider(tab, name, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 38)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    frame.BorderSizePixel = 0
    frame.Parent = tab.Page
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 0, 18)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(0, 50, 0, 18)
    valLabel.Position = UDim2.new(1, -58, 0, 0)
    valLabel.BackgroundTransparency = 1
    valLabel.TextColor3 = Color3.fromRGB(100, 180, 255)
    valLabel.TextSize = 12
    valLabel.Font = Enum.Font.GothamBold
    valLabel.Parent = frame

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -20, 0, 6)
    sliderBg.Position = UDim2.new(0, 10, 0, 26)
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0, 3)

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(80, 170, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0, 3)

    local value = default
    valLabel.Text = tostring(math.floor(value))
    callback(value)

    local dragging = false
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (max - min) * rel)
            sliderFill.Size = UDim2.new(rel, 0, 1, 0)
            valLabel.Text = tostring(value)
            callback(value)
        end
    end)
end

local function addLabel(tab, text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 22)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(100, 180, 255)
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = tab.Page
end

local function addButton(tab, name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamSemibold
    btn.BorderSizePixel = 0
    btn.Parent = tab.Page
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(callback)
end

---------------------------------------------
-- UTILITIES
---------------------------------------------

local function isAlive(player)
    local char = player.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function isTeammate(player)
    return LP.Team and player.Team and LP.Team == player.Team
end

local function isVisible(part)
    if not part then return false end
    local ray = RaycastParams.new()
    ray.FilterType = Enum.RaycastFilterType.Exclude
    local myChar = LP.Character
    if myChar then ray.FilterDescendantsInstances = {myChar} end
    local res = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position), ray)
    if res then return res.Instance:IsDescendantOf(part.Parent) end
    return true
end

---------------------------------------------
-- FOV CIRCLE
---------------------------------------------

local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.new(1, 1, 1)
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7
FOVCircle.Radius = S.AimbotFOV
FOVCircle.Visible = false
_G.MirkoHub.FOV = FOVCircle

Conn[#Conn+1] = RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UIS:GetMouseLocation()
    FOVCircle.Radius = S.AimbotFOV
    FOVCircle.Visible = S.ShowFOV and S.Aimbot
end)

---------------------------------------------
-- AIMBOT (right click hold)
---------------------------------------------

local aimHold = false

local function getTarget()
    local best, bestDist = nil, S.AimbotFOV
    for _, p in pairs(Players:GetPlayers()) do
        if p == LP or not isAlive(p) then continue end
        if S.AimbotTeamCheck and isTeammate(p) then continue end
        local part = p.Character:FindFirstChild(S.AimbotPart) or p.Character:FindFirstChild("Head")
        if not part then continue end
        if S.AimbotWallCheck and not isVisible(part) then continue end
        local sp, onScreen = Camera:WorldToScreenPoint(part.Position)
        if not onScreen then continue end
        local d = (Vector2.new(sp.X, sp.Y) - UIS:GetMouseLocation()).Magnitude
        if d < bestDist then bestDist = d; best = part end
    end
    return best
end

Conn[#Conn+1] = UIS.InputBegan:Connect(function(i, gpe)
    if gpe then return end
    if i.UserInputType == Enum.UserInputType.MouseButton2 then aimHold = true end
end)

Conn[#Conn+1] = UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton2 then aimHold = false end
end)

Conn[#Conn+1] = RunService.RenderStepped:Connect(function()
    if not S.Aimbot or not aimHold then return end
    local t = getTarget()
    if t then
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, t.Position), 1 / S.AimbotSmooth)
    end
end)

---------------------------------------------
-- ESP
---------------------------------------------

local ESPObjects = _G.MirkoHub.ESP

local function createESP(player)
    if player == LP then return end
    ESPObjects[player] = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        HBg = Drawing.new("Square"),
        HBar = Drawing.new("Square"),
        Tracer = Drawing.new("Line"),
    }
    local d = ESPObjects[player]
    d.Box.Thickness = 1.5; d.Box.Filled = false; d.Box.Visible = false
    d.Name.Size = 14; d.Name.Center = true; d.Name.Outline = true; d.Name.Visible = false; d.Name.Color = Color3.new(1,1,1)
    d.HBg.Filled = true; d.HBg.Visible = false; d.HBg.Color = Color3.new(0,0,0)
    d.HBar.Filled = true; d.HBar.Visible = false
    d.Tracer.Thickness = 1.5; d.Tracer.Visible = false
end

local function removeESP(player)
    if ESPObjects[player] then
        for _, o in pairs(ESPObjects[player]) do o:Remove() end
        ESPObjects[player] = nil
    end
end

for _, p in pairs(Players:GetPlayers()) do createESP(p) end
Conn[#Conn+1] = Players.PlayerAdded:Connect(createESP)
Conn[#Conn+1] = Players.PlayerRemoving:Connect(removeESP)

Conn[#Conn+1] = RunService.RenderStepped:Connect(function()
    for player, d in pairs(ESPObjects) do
        if not player or not player.Parent then removeESP(player) continue end
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local show = S.ESP and hrp and hum and hum.Health > 0
        if show and S.ESPTeamCheck and isTeammate(player) then show = false end

        if not show then
            d.Box.Visible = false; d.Name.Visible = false; d.HBg.Visible = false; d.HBar.Visible = false; d.Tracer.Visible = false
            continue
        end

        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then
            d.Box.Visible = false; d.Name.Visible = false; d.HBg.Visible = false; d.HBar.Visible = false; d.Tracer.Visible = false
            continue
        end

        local sf = 1 / (pos.Z * math.tan(math.rad(Camera.FieldOfView / 2)) * 2) * 1000
        local bw, bh = 4 * sf, 5.5 * sf
        local bx, by = pos.X - bw/2, pos.Y - bh/2

        d.Box.Color = S.ESPColor; d.Tracer.Color = S.ESPColor
        if S.ESPBoxes then d.Box.Size = Vector2.new(bw, bh); d.Box.Position = Vector2.new(bx, by); d.Box.Visible = true else d.Box.Visible = false end
        if S.ESPNames then d.Name.Text = player.DisplayName; d.Name.Position = Vector2.new(pos.X, by - 16); d.Name.Visible = true else d.Name.Visible = false end
        if S.ESPHealth then
            local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            d.HBg.Size = Vector2.new(3, bh); d.HBg.Position = Vector2.new(bx - 6, by); d.HBg.Visible = true
            d.HBar.Size = Vector2.new(3, bh * hp); d.HBar.Position = Vector2.new(bx - 6, by + bh * (1 - hp))
            d.HBar.Color = Color3.fromRGB(255*(1-hp), 255*hp, 0); d.HBar.Visible = true
        else d.HBg.Visible = false; d.HBar.Visible = false end
        if S.ESPTracers then
            d.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y); d.Tracer.To = Vector2.new(pos.X, pos.Y); d.Tracer.Visible = true
        else d.Tracer.Visible = false end
    end
end)

---------------------------------------------
-- FLY
---------------------------------------------

local flyBV, flyBG

local function startFly()
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if S.FlyUndetected then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = true end
    else
        flyBV = Instance.new("BodyVelocity"); flyBV.MaxForce = Vector3.one * math.huge; flyBV.Velocity = Vector3.zero; flyBV.Parent = hrp
        flyBG = Instance.new("BodyGyro"); flyBG.MaxTorque = Vector3.one * math.huge; flyBG.D = 200; flyBG.P = 40000; flyBG.Parent = hrp
    end
end

local function stopFly()
    if flyBV then flyBV:Destroy(); flyBV = nil end
    if flyBG then flyBG:Destroy(); flyBG = nil end
    local char = LP.Character
    if char then local h = char:FindFirstChildOfClass("Humanoid"); if h then h.PlatformStand = false end end
end

Conn[#Conn+1] = RunService.Heartbeat:Connect(function()
    if not S.Fly then return end
    local char = LP.Character; if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local dir = Vector3.zero
    if UIS:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.yAxis end
    if dir.Magnitude > 0 then dir = dir.Unit * S.FlySpeed end
    if S.FlyUndetected then hrp.CFrame += dir * (1/60); hrp.Velocity = Vector3.zero
    else if flyBV then flyBV.Velocity = dir end; if flyBG then flyBG.CFrame = Camera.CFrame end end
end)

---------------------------------------------
-- SPEED / INF JUMP
---------------------------------------------

Conn[#Conn+1] = RunService.Heartbeat:Connect(function()
    if not S.Speed then return end
    local char = LP.Character; if not char then return end
    local h = char:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed = S.SpeedValue end
end)

Conn[#Conn+1] = UIS.JumpRequest:Connect(function()
    if not S.InfJump then return end
    local char = LP.Character; if not char then return end
    local h = char:FindFirstChildOfClass("Humanoid"); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

---------------------------------------------
-- TELEPORT KILL
---------------------------------------------

local tpKillActive = false
local function doTpKill()
    if tpKillActive then return end; tpKillActive = true
    task.spawn(function()
        while S.TpKill do
            local char = LP.Character; if not char then task.wait(0.1); continue end
            local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then task.wait(0.1); continue end
            local hum = char:FindFirstChildOfClass("Humanoid"); if not hum or hum.Health <= 0 then task.wait(0.1); continue end
            local orig = hrp.CFrame
            for _, p in pairs(Players:GetPlayers()) do
                if not S.TpKill then break end
                if p == LP or (S.AimbotTeamCheck and isTeammate(p)) then continue end
                local ec = p.Character; if not ec then continue end
                local eh = ec:FindFirstChild("HumanoidRootPart"); local ehum = ec:FindFirstChildOfClass("Humanoid")
                if not eh or not ehum or ehum.Health <= 0 then continue end
                hrp.CFrame = eh.CFrame * CFrame.new(0, 0, -3)
                task.wait(S.TpKillDelay)
            end
            if hrp.Parent then hrp.CFrame = orig end
            task.wait(0.5)
        end
        tpKillActive = false
    end)
end

---------------------------------------------
-- FULLBRIGHT
---------------------------------------------

local origLight = {}
local function setFullbright(on)
    local L = game:GetService("Lighting")
    if on then
        origLight = {L.Ambient, L.Brightness, L.FogEnd, L.GlobalShadows}
        L.Ambient = Color3.new(1,1,1); L.Brightness = 2; L.FogEnd = 1e9; L.GlobalShadows = false
    elseif origLight[1] then
        L.Ambient = origLight[1]; L.Brightness = origLight[2]; L.FogEnd = origLight[3]; L.GlobalShadows = origLight[4]
    end
end

---------------------------------------------
-- ANTI AFK
---------------------------------------------

local vu = game:GetService("VirtualUser")
Conn[#Conn+1] = LP.Idled:Connect(function()
    if S.AntiAFK then vu:Button2Down(Vector2.zero, Camera.CFrame); task.wait(1); vu:Button2Up(Vector2.zero, Camera.CFrame) end
end)

---------------------------------------------
-- BUILD UI TABS
---------------------------------------------

local combatTab = createTab("Combat")
local visualsTab = createTab("Visuals")
local moveTab = createTab("Movement")
local miscTab = createTab("Misc")

-- Select Combat by default
tabs[1].Button.TextColor3 = Color3.fromRGB(100, 180, 255)
tabs[1].Page.Visible = true
currentTab = tabs[1]

-- COMBAT
addLabel(combatTab, "Aimbot")
addToggle(combatTab, "Enable Aimbot", false, function(v) S.Aimbot = v end)
addToggle(combatTab, "Show FOV Circle", false, function(v) S.ShowFOV = v end)
addSlider(combatTab, "FOV Radius", 50, 500, 150, function(v) S.AimbotFOV = v end)
addSlider(combatTab, "Smoothing", 1, 20, 5, function(v) S.AimbotSmooth = v end)
addToggle(combatTab, "Wall Check", true, function(v) S.AimbotWallCheck = v end)
addToggle(combatTab, "Team Check", true, function(v) S.AimbotTeamCheck = v end)
addLabel(combatTab, "Teleport Kill")
addToggle(combatTab, "Teleport Kill", false, function(v) S.TpKill = v; if v then doTpKill() end end)
addSlider(combatTab, "TP Kill Delay", 1, 20, 5, function(v) S.TpKillDelay = v / 10 end)

-- VISUALS
addLabel(visualsTab, "ESP")
addToggle(visualsTab, "Enable ESP", false, function(v) S.ESP = v end)
addToggle(visualsTab, "Boxes", true, function(v) S.ESPBoxes = v end)
addToggle(visualsTab, "Names", true, function(v) S.ESPNames = v end)
addToggle(visualsTab, "Health Bars", true, function(v) S.ESPHealth = v end)
addToggle(visualsTab, "Tracers", false, function(v) S.ESPTracers = v end)
addToggle(visualsTab, "Team Check", true, function(v) S.ESPTeamCheck = v end)

-- MOVEMENT
addLabel(moveTab, "Fly")
addToggle(moveTab, "Enable Fly", false, function(v) S.Fly = v; if v then startFly() else stopFly() end end)
addSlider(moveTab, "Fly Speed", 10, 200, 50, function(v) S.FlySpeed = v end)
addToggle(moveTab, "Undetected (CFrame)", false, function(v) S.FlyUndetected = v; if S.Fly then stopFly(); startFly() end end)
addLabel(moveTab, "Speed")
addToggle(moveTab, "Speed Hack", false, function(v) S.Speed = v; if not v then local c = LP.Character; if c then local h = c:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed = 16 end end end end)
addSlider(moveTab, "Walk Speed", 16, 150, 30, function(v) S.SpeedValue = v end)
addToggle(moveTab, "Infinite Jump", false, function(v) S.InfJump = v end)

-- MISC
addToggle(miscTab, "Fullbright", false, function(v) S.Fullbright = v; setFullbright(v) end)
addToggle(miscTab, "Anti AFK", false, function(v) S.AntiAFK = v end)
addButton(miscTab, "Rejoin Server", function() game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId) end)
addButton(miscTab, "Server Hop", function() game:GetService("TeleportService"):Teleport(game.PlaceId) end)
addButton(miscTab, "Destroy Script", function()
    for _, c in pairs(Conn) do pcall(function() c:Disconnect() end) end
    for _, p in pairs(Players:GetPlayers()) do removeESP(p) end
    FOVCircle:Remove(); stopFly(); setFullbright(false); GUI:Destroy()
    _G.MirkoHub = nil
end)

-- Toggle visibility with RightControl
Conn[#Conn+1] = UIS.InputBegan:Connect(function(i, gpe)
    if gpe then return end
    if i.KeyCode == Enum.KeyCode.RightControl then
        GUI.Enabled = not GUI.Enabled
    end
end)
