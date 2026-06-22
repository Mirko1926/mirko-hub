--[[
    MIRKO HUB - Main Loader
    Auto-detects game and loads the correct script from the GitHub repo.

    Usage (in executor):
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Mirko1926/mirko-hub/main/loader.lua"))()
]]

-- Repo base URL (raw)
local BASE_URL = "https://raw.githubusercontent.com/Mirko1926/mirko-hub/main/"

-- Local fallback folder (used only if HttpGet fails, handy for testing)
local LOCAL_BASE = "C:/Users/mirko/Desktop/mcpexecutor/mirko-hub-repo/"

-- Cleanup previous instances
if _G.MirkoHub then
    pcall(function() for _, c in pairs(_G.MirkoHub.Connections or {}) do pcall(function() c:Disconnect() end) end end)
    pcall(function() _G.MirkoHub.FOV:Remove() end)
    pcall(function() _G.MirkoHub.GUI:Destroy() end)
    pcall(function() for _, d in pairs(_G.MirkoHub.ESP or {}) do for _, o in pairs(d) do pcall(function() o:Remove() end) end end end)
    _G.MirkoHub = nil
end
if _G.HubCleanup then pcall(_G.HubCleanup) end
pcall(function()
    for _, g in pairs(game:GetService("CoreGui"):GetChildren()) do
        if g:IsA("ScreenGui") and (g.Name == "MirkoHub" or g.Name == "MirkoHubLoader") then g:Destroy() end
    end
end)

-- Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- Supported games (File is relative to the repo scripts/ folder)
local Games = {
    [286090429] = {
        Name = "Arsenal",
        File = "scripts/arsenal.lua"
    },
    [90568084448279] = {
        Name = "One Tap",
        File = "scripts/onetap.lua"
    },
    [17625359962] = {
        Name = "Rivals",
        File = "scripts/rivals.lua"
    },
    [301549746] = {
        Name = "Counter Blox",
        File = "scripts/counterblox.lua"
    },
    [136801880565837] = {
        Name = "FPS Flick",
        File = "scripts/fpsflick.lua"
    }
}

---------------------------------------------
-- INTRO SCREEN
---------------------------------------------

local IntroGUI = Instance.new("ScreenGui")
IntroGUI.Name = "MirkoHubLoader"
IntroGUI.ResetOnSpawn = false
IntroGUI.IgnoreGuiInset = true
IntroGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
IntroGUI.DisplayOrder = 999
pcall(function() IntroGUI.Parent = game:GetService("CoreGui") end)
if not IntroGUI.Parent then IntroGUI.Parent = LP.PlayerGui end

-- Background
local BG = Instance.new("Frame")
BG.Size = UDim2.new(1, 0, 1, 0)
BG.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
BG.BackgroundTransparency = 0
BG.BorderSizePixel = 0
BG.Parent = IntroGUI

-- Gradient overlay
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 18, 8)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(14, 13, 6)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 8))
})
gradient.Rotation = 45
gradient.Parent = BG

-- Logo text "M"
local LogoM = Instance.new("TextLabel")
LogoM.Size = UDim2.new(0, 100, 0, 100)
LogoM.Position = UDim2.new(0.5, -50, 0.35, -50)
LogoM.BackgroundTransparency = 1
LogoM.Text = "M"
LogoM.TextColor3 = Color3.fromRGB(255, 200, 30)
LogoM.TextSize = 80
LogoM.Font = Enum.Font.GothamBlack
LogoM.TextTransparency = 1
LogoM.Parent = BG

-- Glow effect behind logo
local LogoGlow = Instance.new("ImageLabel")
LogoGlow.Size = UDim2.new(0, 200, 0, 200)
LogoGlow.Position = UDim2.new(0.5, -100, 0.35, -100)
LogoGlow.BackgroundTransparency = 1
LogoGlow.Image = "rbxassetid://7669684091"
LogoGlow.ImageColor3 = Color3.fromRGB(255, 200, 30)
LogoGlow.ImageTransparency = 1
LogoGlow.Parent = BG

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 300, 0, 40)
Title.Position = UDim2.new(0.5, -150, 0.35, 55)
Title.BackgroundTransparency = 1
Title.Text = "MIRKO HUB"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 28
Title.Font = Enum.Font.GothamBlack
Title.TextTransparency = 1
Title.Parent = BG

-- Subtitle
local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(0, 300, 0, 25)
Subtitle.Position = UDim2.new(0.5, -150, 0.35, 90)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "made by MIRKO KING YT"
Subtitle.TextColor3 = Color3.fromRGB(120, 120, 140)
Subtitle.TextSize = 14
Subtitle.Font = Enum.Font.GothamMedium
Subtitle.TextTransparency = 1
Subtitle.Parent = BG

-- Status text
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(0, 400, 0, 25)
Status.Position = UDim2.new(0.5, -200, 0.65, 0)
Status.BackgroundTransparency = 1
Status.Text = ""
Status.TextColor3 = Color3.fromRGB(180, 180, 200)
Status.TextSize = 14
Status.Font = Enum.Font.GothamMedium
Status.TextTransparency = 1
Status.Parent = BG

-- Progress bar background
local ProgressBG = Instance.new("Frame")
ProgressBG.Size = UDim2.new(0, 300, 0, 4)
ProgressBG.Position = UDim2.new(0.5, -150, 0.7, 0)
ProgressBG.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
ProgressBG.BorderSizePixel = 0
ProgressBG.BackgroundTransparency = 1
ProgressBG.Parent = BG
Instance.new("UICorner", ProgressBG).CornerRadius = UDim.new(0, 2)

-- Progress bar fill
local ProgressFill = Instance.new("Frame")
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Color3.fromRGB(224, 176, 16)
ProgressFill.BorderSizePixel = 0
ProgressFill.Parent = ProgressBG
Instance.new("UICorner", ProgressFill).CornerRadius = UDim.new(0, 2)

-- Particle dots (decorative)
local dots = {}
for i = 1, 12 do
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
    dot.Position = UDim2.new(math.random() * 0.8 + 0.1, 0, math.random() * 0.6 + 0.2, 0)
    dot.BackgroundColor3 = Color3.fromRGB(255, 200, 30)
    dot.BackgroundTransparency = 1
    dot.BorderSizePixel = 0
    dot.Parent = BG
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    dots[i] = dot
end

---------------------------------------------
-- ANIMATION SEQUENCE
---------------------------------------------

local function tween(obj, duration, props)
    local t = TweenService:Create(obj, TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function setStatus(text)
    Status.Text = text
end

local function setProgress(pct)
    tween(ProgressFill, 0.3, {Size = UDim2.new(pct, 0, 1, 0)})
end

-- Loads a script's source: try the repo over HTTP first, fall back to local file.
local function fetchScript(file)
    local src
    pcall(function() src = game:HttpGet(BASE_URL .. file) end)
    if (not src or #src == 0) and readfile then
        pcall(function() src = readfile(LOCAL_BASE .. file) end)
    end
    return src
end

-- Phase 1: Fade in particles
for i, dot in pairs(dots) do
    task.delay(i * 0.05, function()
        tween(dot, 0.8, {BackgroundTransparency = math.random() * 0.4 + 0.5})
        -- Float animation
        local startPos = dot.Position
        task.spawn(function()
            while dot.Parent do
                tween(dot, 2 + math.random(), {Position = startPos + UDim2.new(0, math.random(-20, 20), 0, math.random(-15, 15))})
                task.wait(2 + math.random())
                tween(dot, 2 + math.random(), {Position = startPos})
                task.wait(2 + math.random())
            end
        end)
    end)
end

task.wait(0.3)

-- Phase 2: Logo appears with scale effect
LogoM.TextTransparency = 1
LogoM.TextSize = 40
tween(LogoM, 0.6, {TextTransparency = 0, TextSize = 80})
tween(LogoGlow, 0.8, {ImageTransparency = 0.6})

task.wait(0.4)

-- Phase 3: Title slides in
tween(Title, 0.5, {TextTransparency = 0})
task.wait(0.2)
tween(Subtitle, 0.4, {TextTransparency = 0})

task.wait(0.5)

-- Phase 4: Status + progress bar
tween(Status, 0.3, {TextTransparency = 0})
tween(ProgressBG, 0.3, {BackgroundTransparency = 0})

setStatus("Initializing...")
setProgress(0.1)
task.wait(0.4)

setStatus("Checking environment...")
setProgress(0.25)
task.wait(0.3)

setStatus("Scanning for game...")
setProgress(0.4)
task.wait(0.5)

-- Phase 5: Game detection
local placeId = game.PlaceId
local gameInfo = Games[placeId]

if gameInfo then
    setStatus("Detected: " .. gameInfo.Name)
    setProgress(0.6)
    Status.TextColor3 = Color3.fromRGB(100, 255, 140)
    task.wait(0.5)

    setStatus("Loading " .. gameInfo.Name .. " module...")
    setProgress(0.8)
    task.wait(0.4)

    setStatus("Ready! Launching...")
    setProgress(1)

    -- Logo pulse
    tween(LogoM, 0.3, {TextColor3 = Color3.fromRGB(100, 255, 140)})
    tween(LogoGlow, 0.3, {ImageColor3 = Color3.fromRGB(100, 255, 140)})
    task.wait(0.8)

    -- Phase 6: Fade out
    tween(BG, 0.5, {BackgroundTransparency = 1})
    tween(LogoM, 0.4, {TextTransparency = 1})
    tween(LogoGlow, 0.4, {ImageTransparency = 1})
    tween(Title, 0.4, {TextTransparency = 1})
    tween(Subtitle, 0.3, {TextTransparency = 1})
    tween(Status, 0.3, {TextTransparency = 1})
    tween(ProgressBG, 0.3, {BackgroundTransparency = 1})
    for _, dot in pairs(dots) do
        tween(dot, 0.3, {BackgroundTransparency = 1})
    end
    task.wait(0.6)

    -- Destroy intro
    IntroGUI:Destroy()

    -- Load game script from repo (with local fallback)
    local file = fetchScript(gameInfo.File)
    if file then
        local fn, err = loadstring(file)
        if fn then
            fn()
        else
            warn("Mirko Hub: Script error - " .. tostring(err))
        end
    else
        warn("Mirko Hub: Could not fetch script - " .. gameInfo.File)
    end

else
    -- Game not supported
    setStatus("Game not supported (PlaceId: " .. placeId .. ")")
    setProgress(1)
    Status.TextColor3 = Color3.fromRGB(255, 100, 100)
    ProgressFill.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    tween(LogoM, 0.3, {TextColor3 = Color3.fromRGB(255, 100, 100)})
    tween(LogoGlow, 0.3, {ImageColor3 = Color3.fromRGB(255, 100, 100)})

    task.wait(3)

    tween(BG, 0.5, {BackgroundTransparency = 1})
    tween(LogoM, 0.4, {TextTransparency = 1})
    tween(LogoGlow, 0.4, {ImageTransparency = 1})
    tween(Title, 0.4, {TextTransparency = 1})
    tween(Subtitle, 0.3, {TextTransparency = 1})
    tween(Status, 0.3, {TextTransparency = 1})
    tween(ProgressBG, 0.3, {BackgroundTransparency = 1})
    for _, dot in pairs(dots) do
        tween(dot, 0.3, {BackgroundTransparency = 1})
    end
    task.wait(0.6)
    IntroGUI:Destroy()
end
