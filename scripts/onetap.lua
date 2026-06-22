-- ============================================
-- MIRKO HUB - Universal FPS
-- Rayfield GUI | ESP, Aimbot, Bhop, Noclip, Speed, Wallbang, InfJump, Fullbright
-- ============================================

-- Cleanup
if _G.HubCleanup then _G.HubCleanup() end

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ═══ STATE ═══
local espEnabled = false
local aimbotEnabled = false
local aimFOV = 200
local aimSmoothing = 1
local bhopEnabled = false
local noclipEnabled = false
local wallbangEnabled = false
local speedEnabled = false
local speedValue = 22
local infJumpEnabled = false
local fovValue = 70
local rightHeld = false
local lockedTarget = nil
local spaceHeld = false

local espObjects = {}
local connections = {}
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.fromRGB(100, 200, 255)
fovCircle.Thickness = 1.5
fovCircle.Transparency = 0.5
fovCircle.Filled = false
fovCircle.Visible = false

-- ═══ UTILITY ═══
local function isAlive(p)
    local char = p and p.Character
    if not char then return false end
    local hum = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    return hum and root and hum.Health > 0
end

local function isValidTarget(p)
    if p == player then return false end
    if not isAlive(p) then return false end
    local myRoot = player.Character and (player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Torso"))
    local root = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Torso")
    if myRoot and root and root.Position.Y < myRoot.Position.Y - 30 then return false end
    return true
end

local function getClosestEnemy()
    local closest = nil
    local closestDist = aimFOV
    local screenCenter = camera.ViewportSize / 2
    for _, p in pairs(Players:GetPlayers()) do
        if isValidTarget(p) then
            local head = p.Character:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if dist2D < closestDist then closestDist = dist2D closest = p end
                end
            end
        end
    end
    return closest
end

-- ═══ ESP ═══
local function createESP(target)
    if espObjects[target] then return end
    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.FillColor = Color3.fromRGB(255, 50, 50)
    highlight.OutlineColor = Color3.fromRGB(255, 50, 50)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 200, 0, 50)
    bb.StudsOffset = Vector3.new(0, 3.5, 0)
    bb.AlwaysOnTop = true

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.Parent = bb

    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, 0, 0.5, 0)
    infoLabel.Position = UDim2.new(0, 0, 0.5, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    infoLabel.TextSize = 11
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextStrokeTransparency = 0.3
    infoLabel.Parent = bb

    espObjects[target] = { highlight = highlight, billboard = bb, nameLabel = nameLabel, infoLabel = infoLabel }
end

local function removeESP(target)
    local esp = espObjects[target]
    if esp then esp.highlight:Destroy() esp.billboard:Destroy() espObjects[target] = nil end
end

-- ═══ RENDER LOOP ═══
connections.render = RunService.RenderStepped:Connect(function()
    local myChar = player.Character
    local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))

    fovCircle.Visible = aimbotEnabled
    if aimbotEnabled then
        fovCircle.Position = camera.ViewportSize / 2
        fovCircle.Radius = aimFOV
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            if espEnabled and isValidTarget(p) then
                local char = p.Character
                local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
                local hum = char:FindFirstChild("Humanoid")
                createESP(p)
                local esp = espObjects[p]
                esp.highlight.Parent = char
                esp.billboard.Parent = root
                esp.nameLabel.Text = p.DisplayName
                local dist = myRoot and math.floor((myRoot.Position - root.Position).Magnitude) or "?"
                esp.infoLabel.Text = "HP: " .. math.floor(hum.Health) .. " | " .. dist .. "m"
            else
                removeESP(p)
            end
        end
    end

    if aimbotEnabled and rightHeld then
        if lockedTarget and not isValidTarget(lockedTarget) then lockedTarget = nil end
        if not lockedTarget then lockedTarget = getClosestEnemy() end
        if lockedTarget and lockedTarget.Character then
            local head = lockedTarget.Character:FindFirstChild("Head")
            if head then
                local targetCF = CFrame.new(camera.CFrame.Position, head.Position)
                if aimSmoothing <= 1 then camera.CFrame = targetCF
                else camera.CFrame = camera.CFrame:Lerp(targetCF, 1 / aimSmoothing) end
            end
        end
    end
end)

-- ═══ INPUT ═══
connections.inputBegan = UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then rightHeld = true lockedTarget = nil end
    if input.KeyCode == Enum.KeyCode.Space then
        spaceHeld = true
        if infJumpEnabled then
            local hum = player.Character and player.Character:FindFirstChild("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

connections.inputEnded = UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then rightHeld = false lockedTarget = nil end
    if input.KeyCode == Enum.KeyCode.Space then spaceHeld = false end
end)

-- ═══ HEARTBEAT ═══
connections.heartbeat = RunService.Heartbeat:Connect(function()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    if not hum or not root then return end

    if bhopEnabled and spaceHeld and hum.FloorMaterial ~= Enum.Material.Air then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        root.Velocity = Vector3.new(root.Velocity.X, 50, root.Velocity.Z)
    end

    if noclipEnabled then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    if speedEnabled then hum.WalkSpeed = speedValue end
end)

-- ═══ WALLBANG ═══
local geometryParts = {}
local map = workspace:FindFirstChild("Map")
if map then
    for _, obj in pairs(map:GetDescendants()) do
        if obj:IsA("BasePart") then table.insert(geometryParts, obj) end
    end
end

local function setWallbang(state)
    for _, part in pairs(geometryParts) do
        if part and part.Parent then part.CanQuery = not state end
    end
end

connections.removing = Players.PlayerRemoving:Connect(function(p) removeESP(p) end)

-- ═══ RAYFIELD GUI ═══
local Window = Rayfield:CreateWindow({
    Name = "mirko hub",
    LoadingTitle = "mirko hub",
    LoadingSubtitle = "loading...",
    Theme = "Default",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

-- ── TAB: Welcome ──
local WelcomeTab = Window:CreateTab("Welcome", 4483362458)

WelcomeTab:CreateLabel("Welcome to mirko hub!")
WelcomeTab:CreateLabel("Made by MIRKO KING")
WelcomeTab:CreateLabel("Player: " .. player.DisplayName)

local gameName = "Unknown"
pcall(function()
    gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
end)
WelcomeTab:CreateLabel("Game: " .. gameName)

WelcomeTab:CreateButton({
    Name = "Subscribe to my YouTube!",
    Callback = function()
        setclipboard("https://www.youtube.com/@MIRKOKING")
        Rayfield:Notify({
            Title = "YouTube Link Copied!",
            Content = "https://www.youtube.com/@MIRKOKING - Paste in your browser!",
            Duration = 5
        })
    end
})

WelcomeTab:CreateLabel("Features: ESP, Aimbot, Bhop, Speed, Noclip, Wallbang, InfJump, FOV, Fullbright, TP")

-- ── TAB: Combat ──
local CombatTab = Window:CreateTab("Combat", 4483362458)

CombatTab:CreateToggle({
    Name = "Aimbot (Hold Right Click)",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(v) aimbotEnabled = v if not v then lockedTarget = nil end end
})

CombatTab:CreateSlider({
    Name = "Aimbot FOV",
    Range = {50, 500},
    Increment = 25,
    CurrentValue = 200,
    Flag = "AimbotFOV",
    Callback = function(v) aimFOV = v end
})

CombatTab:CreateSlider({
    Name = "Smoothing (1 = instant)",
    Range = {1, 10},
    Increment = 1,
    CurrentValue = 1,
    Flag = "AimbotSmooth",
    Callback = function(v) aimSmoothing = v end
})

CombatTab:CreateToggle({
    Name = "Wallbang (Shoot Through Walls)",
    CurrentValue = false,
    Flag = "WallbangToggle",
    Callback = function(v) wallbangEnabled = v setWallbang(v) end
})

-- ── TAB: Visuals ──
local VisualsTab = Window:CreateTab("Visuals", 4483362458)

VisualsTab:CreateToggle({
    Name = "ESP (All Enemies)",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(v)
        espEnabled = v
        if not v then for _, p in pairs(Players:GetPlayers()) do removeESP(p) end end
    end
})

VisualsTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Color3.fromRGB(255, 50, 50),
    Flag = "ESPColor",
    Callback = function(v)
        for _, esp in pairs(espObjects) do
            esp.highlight.FillColor = v
            esp.highlight.OutlineColor = v
            esp.nameLabel.TextColor3 = v
        end
    end
})

VisualsTab:CreateSlider({
    Name = "Camera FOV",
    Range = {30, 120},
    Increment = 5,
    CurrentValue = 70,
    Flag = "CameraFOV",
    Callback = function(v) camera.FieldOfView = v end
})

VisualsTab:CreateButton({
    Name = "Fullbright",
    Callback = function()
        local l = game:GetService("Lighting")
        l.Brightness = 2
        l.ClockTime = 14
        l.FogEnd = 100000
        l.GlobalShadows = false
        for _, e in pairs(l:GetDescendants()) do
            if e:IsA("PostEffect") or e:IsA("Atmosphere") then e:Destroy() end
        end
    end
})

-- ── TAB: Movement ──
local MovementTab = Window:CreateTab("Movement", 4483362458)

MovementTab:CreateToggle({
    Name = "Bhop (Hold Space)",
    CurrentValue = false,
    Flag = "BhopToggle",
    Callback = function(v) bhopEnabled = v end
})

MovementTab:CreateToggle({
    Name = "Speed Hack",
    CurrentValue = false,
    Flag = "SpeedToggle",
    Callback = function(v)
        speedEnabled = v
        if not v then
            local hum = player.Character and player.Character:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = 22 end
        end
    end
})

MovementTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 150},
    Increment = 2,
    CurrentValue = 22,
    Flag = "SpeedValue",
    Callback = function(v) speedValue = v end
})

MovementTab:CreateToggle({
    Name = "Noclip (Walk Through Walls)",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(v) noclipEnabled = v end
})

MovementTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfJumpToggle",
    Callback = function(v) infJumpEnabled = v end
})

-- ── TAB: Player ──
local PlayerTab = Window:CreateTab("Player", 4483362458)

PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {30, 200},
    Increment = 5,
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(v)
        local hum = player.Character and player.Character:FindFirstChild("Humanoid")
        if hum then hum.UseJumpPower = true hum.JumpPower = v end
    end
})

PlayerTab:CreateButton({
    Name = "Respawn",
    Callback = function()
        local hum = player.Character and player.Character:FindFirstChild("Humanoid")
        if hum then hum.Health = 0 end
    end
})

PlayerTab:CreateButton({
    Name = "Teleport to Nearest Player",
    Callback = function()
        local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        local closest, closestDist = nil, math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and isAlive(p) then
                local root = p.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local d = (myRoot.Position - root.Position).Magnitude
                    if d < closestDist then closest = root closestDist = d end
                end
            end
        end
        if closest then myRoot.CFrame = closest.CFrame * CFrame.new(0, 0, 5) end
    end
})

-- ═══ CLEANUP ═══
_G.HubCleanup = function()
    for _, c in pairs(connections) do
        if typeof(c) == "RBXScriptConnection" then c:Disconnect() end
    end
    connections = {}
    for _, p in pairs(Players:GetPlayers()) do removeESP(p) end
    espObjects = {}
    fovCircle:Remove()
    setWallbang(false)
    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = 22 end
    Rayfield:Destroy()
    _G.HubCleanup = nil
end
