-- King Hub FPS Flick
-- Toggle Aimbot: Right Click (hold) | Toggle UI: Right Ctrl
-- UI a tabs (Combat / Visuals / Player) by MIRKO KING YT

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = game:GetService("Workspace").CurrentCamera
local LocalPlayer = Players.LocalPlayer

local DISCORD_INVITE = "https://discord.com/invite/qfyfqMnBYK"
local YOUTUBE_CHANNEL = "https://www.youtube.com/@MIRKOKING"

-- Theme
local Theme = {
    Bg        = Color3.fromRGB(8, 8, 8),
    Bg2       = Color3.fromRGB(16, 16, 16),
    Bg3       = Color3.fromRGB(26, 26, 26),
    Accent    = Color3.fromRGB(224, 176, 16),   -- giallo oro scuro
    Accent2   = Color3.fromRGB(255, 214, 51),   -- giallo chiaro
    Text      = Color3.fromRGB(240, 240, 240),
    SubText   = Color3.fromRGB(140, 140, 140),
    Off       = Color3.fromRGB(45, 45, 45),
    Danger    = Color3.fromRGB(235, 60, 60),
    Discord   = Color3.fromRGB(88, 101, 242),
    YouTube   = Color3.fromRGB(255, 0, 0),
}

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
    ESPTeamCheck = false,
    MaxDistance = 1000,
    ESPColor = Color3.fromRGB(224, 176, 16),
}

local toggleKey = Enum.KeyCode.RightControl

-- Stato
local AimbotActive = false
local CurrentTarget = nil
local ESPObjects = {}
local Connections = {}
local Cleanup -- forward declaration (usata dal bottone Destroy)

-----------------------------------------------------------
-- ScreenGui
-----------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MirkoHubFlick"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-----------------------------------------------------------
-- Helpers
-----------------------------------------------------------
local function corner(parent, r)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, r or 6)
    return c
end

local function stroke(parent, col, thick, trans)
    local s = Instance.new("UIStroke", parent)
    s.Color = col or Theme.Bg3
    s.Thickness = thick or 1
    s.Transparency = trans or 0
    return s
end

local function pad(parent, p)
    local u = Instance.new("UIPadding", parent)
    u.PaddingLeft = UDim.new(0, p)
    u.PaddingRight = UDim.new(0, p)
    u.PaddingTop = UDim.new(0, p)
    u.PaddingBottom = UDim.new(0, p)
    return u
end

-- Notifica toast in basso a destra
local function notify(text, color)
    local toast = Instance.new("TextLabel")
    toast.AnchorPoint = Vector2.new(1, 1)
    toast.Position = UDim2.new(1, -16, 1, 10)
    toast.Size = UDim2.new(0, 240, 0, 36)
    toast.BackgroundColor3 = Theme.Bg2
    toast.TextColor3 = color or Theme.Text
    toast.Text = text
    toast.Font = Enum.Font.GothamMedium
    toast.TextSize = 13
    toast.TextWrapped = true
    toast.Parent = ScreenGui
    corner(toast, 8)
    stroke(toast, color or Theme.Accent, 1, 0.3)
    TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(1, -16, 1, -16)}):Play()
    task.delay(2.6, function()
        TweenService:Create(toast, TweenInfo.new(0.3), {Position = UDim2.new(1, -16, 1, 10), TextTransparency = 1, BackgroundTransparency = 1}):Play()
        task.wait(0.35)
        toast:Destroy()
    end)
end

local function copyLink(url, label, color)
    local ok = pcall(function()
        if setclipboard then setclipboard(url) end
    end)
    if ok then
        notify(label .. " copied to clipboard! Paste it into your browser.", color)
    else
        notify(url, color)
    end
end

local function joinDiscord() copyLink(DISCORD_INVITE, "Discord link", Theme.Discord) end
local function subYouTube() copyLink(YOUTUBE_CHANNEL, "YouTube channel", Theme.YouTube) end

-----------------------------------------------------------
-- Main window
-----------------------------------------------------------
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Size = UDim2.new(0, 480, 0, 340)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.BackgroundColor3 = Theme.Bg
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui
corner(Main, 6)
stroke(Main, Theme.Accent, 1.5, 0.4)
pad(Main, 2)

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 38)
TitleBar.BackgroundColor3 = Theme.Bg
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local accentLine = Instance.new("Frame")
accentLine.Size = UDim2.new(1, 0, 0, 2)
accentLine.Position = UDim2.new(0, 0, 1, -2)
accentLine.BackgroundColor3 = Theme.Accent
accentLine.BorderSizePixel = 0
accentLine.Parent = TitleBar
local accentGrad = Instance.new("UIGradient", accentLine)
accentGrad.Color = ColorSequence.new(Theme.Accent, Theme.Accent2)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text = "KING HUB"
TitleLabel.Size = UDim2.new(0, 200, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Theme.Text
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextSize = 15
TitleLabel.Parent = TitleBar

local Badge = Instance.new("TextLabel")
Badge.Text = "FPS FLICK"
Badge.Size = UDim2.new(0, 76, 0, 18)
Badge.Position = UDim2.new(0, 116, 0.5, -9)
Badge.BackgroundColor3 = Theme.Accent
Badge.TextColor3 = Color3.fromRGB(10, 10, 10)
Badge.Font = Enum.Font.GothamBold
Badge.TextSize = 11
Badge.Parent = TitleBar
corner(Badge, 5)

local credit = Instance.new("TextLabel")
credit.Text = "by MIRKO KING YT"
credit.Size = UDim2.new(0, 160, 1, 0)
credit.Position = UDim2.new(0, 200, 0, 0)
credit.BackgroundTransparency = 1
credit.TextColor3 = Theme.SubText
credit.TextXAlignment = Enum.TextXAlignment.Left
credit.Font = Enum.Font.GothamMedium
credit.TextSize = 11
credit.Parent = TitleBar

-- Close + minimize
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "✕"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -34, 0.5, -15)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Theme.SubText
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = TitleBar

local MinBtn = Instance.new("TextButton")
MinBtn.Text = "—"
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -66, 0.5, -15)
MinBtn.BackgroundTransparency = 1
MinBtn.TextColor3 = Theme.SubText
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 16
MinBtn.Parent = TitleBar

for _, b in pairs({CloseBtn, MinBtn}) do
    b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(0.15), {TextColor3 = Theme.Text}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(0.15), {TextColor3 = Theme.SubText}):Play() end)
end

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Position = UDim2.new(0, 8, 0, 46)
Sidebar.Size = UDim2.new(0, 124, 1, -54)
Sidebar.BackgroundColor3 = Theme.Bg2
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main
corner(Sidebar, 8)
local sideList = Instance.new("UIListLayout", Sidebar)
sideList.Padding = UDim.new(0, 4)
sideList.SortOrder = Enum.SortOrder.LayoutOrder
pad(Sidebar, 8)

-----------------------------------------------------------
-- Tab system
-----------------------------------------------------------
local Tabs = {}
local activeTab = nil

local function makePage()
    local page = Instance.new("ScrollingFrame")
    page.Position = UDim2.new(0, 140, 0, 46)
    page.Size = UDim2.new(1, -148, 1, -54)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Theme.Accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = Main
    local l = Instance.new("UIListLayout", page)
    l.Padding = UDim.new(0, 6)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    return page
end

local function selectTab(name)
    activeTab = name
    for n, t in pairs(Tabs) do
        local on = (n == name)
        t.Page.Visible = on
        TweenService:Create(t.Button, TweenInfo.new(0.15), {BackgroundColor3 = on and Theme.Accent or Theme.Bg2}):Play()
        TweenService:Create(t.Label, TweenInfo.new(0.15), {TextColor3 = on and Color3.fromRGB(10,10,10) or Theme.SubText}):Play()
        t.Indicator.Visible = on
    end
end

local function addTab(name, icon, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Theme.Bg2
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.LayoutOrder = order
    btn.Parent = Sidebar
    corner(btn, 6)

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 3, 0, 18)
    indicator.Position = UDim2.new(0, 0, 0.5, -9)
    indicator.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    indicator.BorderSizePixel = 0
    indicator.Visible = false
    indicator.Parent = btn
    corner(indicator, 2)

    local label = Instance.new("TextLabel")
    label.Text = name
    label.Size = UDim2.new(1, -24, 1, 0)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Theme.SubText
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.Parent = btn

    local page = makePage()
    Tabs[name] = { Button = btn, Label = label, Page = page, Indicator = indicator }

    btn.MouseButton1Click:Connect(function() selectTab(name) end)
    return page
end

-----------------------------------------------------------
-- Componenti (parented to a page)
-----------------------------------------------------------
local function CreateSection(parent, name, order)
    local s = Instance.new("TextLabel")
    s.Text = name:upper()
    s.Size = UDim2.new(1, 0, 0, 18)
    s.BackgroundTransparency = 1
    s.TextColor3 = Theme.Accent
    s.TextXAlignment = Enum.TextXAlignment.Left
    s.Font = Enum.Font.GothamBold
    s.TextSize = 11
    s.LayoutOrder = order
    s.Parent = parent
    return s
end

local function CreateToggle(parent, name, default, order, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 32)
    holder.BackgroundColor3 = Theme.Bg2
    holder.BorderSizePixel = 0
    holder.LayoutOrder = order
    holder.Parent = parent
    corner(holder, 7)

    local label = Instance.new("TextLabel")
    label.Text = name
    label.Size = UDim2.new(1, -56, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = holder

    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 38, 0, 20)
    toggleBg.Position = UDim2.new(1, -48, 0.5, -10)
    toggleBg.BackgroundColor3 = default and Theme.Accent or Theme.Off
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = holder
    corner(toggleBg, 10)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    circle.BackgroundColor3 = Color3.new(1, 1, 1)
    circle.BorderSizePixel = 0
    circle.Parent = toggleBg
    corner(circle, 8)

    local enabled = default
    local btn = Instance.new("TextButton")
    btn.Text = ""
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Parent = holder

    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        TweenService:Create(toggleBg, TweenInfo.new(0.2), {BackgroundColor3 = enabled and Theme.Accent or Theme.Off}):Play()
        TweenService:Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {Position = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
        callback(enabled)
    end)
    return holder
end

local function CreateSlider(parent, name, min, max, default, order, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 46)
    holder.BackgroundColor3 = Theme.Bg2
    holder.BorderSizePixel = 0
    holder.LayoutOrder = order
    holder.Parent = parent
    corner(holder, 7)

    local label = Instance.new("TextLabel")
    label.Text = name
    label.Size = UDim2.new(0.7, -12, 0, 18)
    label.Position = UDim2.new(0, 12, 0, 4)
    label.BackgroundTransparency = 1
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = holder

    local valLabel = Instance.new("TextLabel")
    valLabel.Text = tostring(default)
    valLabel.Size = UDim2.new(0.3, -12, 0, 18)
    valLabel.Position = UDim2.new(0.7, 0, 0, 4)
    valLabel.BackgroundTransparency = 1
    valLabel.TextColor3 = Theme.Accent
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 13
    valLabel.Parent = holder

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -24, 0, 6)
    sliderBg.Position = UDim2.new(0, 12, 0, 32)
    sliderBg.BackgroundColor3 = Theme.Off
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = holder
    corner(sliderBg, 3)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    corner(fill, 3)

    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new(1, 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.Parent = fill
    corner(knob, 6)

    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Text = ""
    sliderBtn.Size = UDim2.new(1, 0, 1, 16)
    sliderBtn.Position = UDim2.new(0, 0, 0, -8)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Parent = sliderBg

    local sliding = false
    local function update(x)
        local rel = math.clamp((x - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * rel)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        valLabel.Text = tostring(val)
        callback(val)
    end
    sliderBtn.MouseButton1Down:Connect(function(x) sliding = true; update(x) end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input.Position.X)
        end
    end)
    return holder
end

local function CreateDropdown(parent, name, options, default, order, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 32)
    holder.BackgroundColor3 = Theme.Bg2
    holder.BorderSizePixel = 0
    holder.LayoutOrder = order
    holder.Parent = parent
    corner(holder, 7)

    local label = Instance.new("TextLabel")
    label.Text = name
    label.Size = UDim2.new(0.45, -12, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = holder

    local current = default
    local idx = table.find(options, default) or 1

    local btn = Instance.new("TextButton")
    btn.Text = current .. "  v"
    btn.Size = UDim2.new(0.55, -12, 0, 22)
    btn.Position = UDim2.new(0.45, 0, 0.5, -11)
    btn.BackgroundColor3 = Theme.Bg3
    btn.TextColor3 = Theme.Accent
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = holder
    corner(btn, 5)

    btn.MouseButton1Click:Connect(function()
        idx = idx % #options + 1
        current = options[idx]
        btn.Text = current .. "  v"
        callback(current)
    end)
    return holder
end

local function CreateButton(parent, name, order, callback, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = color or Theme.Bg3
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.AutoButtonColor = true
    btn.LayoutOrder = order
    btn.Parent = parent
    corner(btn, 7)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function CreateInfo(parent, title, value, order)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 32)
    holder.BackgroundColor3 = Theme.Bg2
    holder.BorderSizePixel = 0
    holder.LayoutOrder = order
    holder.Parent = parent
    corner(holder, 7)

    local l = Instance.new("TextLabel")
    l.Text = title
    l.Size = UDim2.new(0.4, -12, 1, 0)
    l.Position = UDim2.new(0, 12, 0, 0)
    l.BackgroundTransparency = 1
    l.TextColor3 = Theme.SubText
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Font = Enum.Font.Gotham
    l.TextSize = 12
    l.Parent = holder

    local v = Instance.new("TextLabel")
    v.Text = value
    v.Size = UDim2.new(0.6, -12, 1, 0)
    v.Position = UDim2.new(0.4, 0, 0, 0)
    v.BackgroundTransparency = 1
    v.TextColor3 = Theme.Text
    v.TextXAlignment = Enum.TextXAlignment.Right
    v.Font = Enum.Font.GothamBold
    v.TextSize = 12
    v.Parent = holder
    return v
end

-- Spectrum color picker (SV square + hue bar). Fills `parent`.
local function CreateSpectrumPicker(parent, default, callback)
    local h, s, v = default:ToHSV()

    local sv = Instance.new("Frame")
    sv.Size = UDim2.new(1, 0, 1, -20)
    sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
    sv.BorderSizePixel = 0
    sv.Parent = parent
    corner(sv, 5)

    local white = Instance.new("Frame")
    white.Size = UDim2.new(1, 0, 1, 0)
    white.BackgroundColor3 = Color3.new(1, 1, 1)
    white.BorderSizePixel = 0
    white.Parent = sv
    corner(white, 5)
    local wg = Instance.new("UIGradient", white)
    wg.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })

    local black = Instance.new("Frame")
    black.Size = UDim2.new(1, 0, 1, 0)
    black.BackgroundColor3 = Color3.new(0, 0, 0)
    black.BorderSizePixel = 0
    black.Parent = sv
    corner(black, 5)
    local bg = Instance.new("UIGradient", black)
    bg.Rotation = 90
    bg.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })

    local svCur = Instance.new("Frame")
    svCur.Size = UDim2.new(0, 9, 0, 9)
    svCur.AnchorPoint = Vector2.new(0.5, 0.5)
    svCur.Position = UDim2.new(s, 0, 1 - v, 0)
    svCur.BackgroundColor3 = Color3.new(1, 1, 1)
    svCur.BorderSizePixel = 0
    svCur.ZIndex = 5
    svCur.Parent = sv
    corner(svCur, 5)
    stroke(svCur, Color3.new(0, 0, 0), 1, 0)

    local hue = Instance.new("Frame")
    hue.Size = UDim2.new(1, 0, 0, 12)
    hue.Position = UDim2.new(0, 0, 1, -12)
    hue.BorderSizePixel = 0
    hue.Parent = parent
    corner(hue, 6)
    local hg = Instance.new("UIGradient", hue)
    hg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
    })
    local hueCur = Instance.new("Frame")
    hueCur.Size = UDim2.new(0, 4, 1, 2)
    hueCur.AnchorPoint = Vector2.new(0.5, 0.5)
    hueCur.Position = UDim2.new(h, 0, 0.5, 0)
    hueCur.BackgroundColor3 = Color3.new(1, 1, 1)
    hueCur.BorderSizePixel = 0
    hueCur.ZIndex = 5
    hueCur.Parent = hue
    corner(hueCur, 2)
    stroke(hueCur, Color3.new(0, 0, 0), 1, 0)

    local function fire() callback(Color3.fromHSV(h, s, v)) end

    local dragSV, dragHue = false, false
    sv.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragSV = true end end)
    hue.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragHue = true end end)
    Connections.PickerEnd = UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragSV = false; dragHue = false end
    end)
    Connections.PickerMove = UserInputService.InputChanged:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        if dragSV then
            local rx = math.clamp((i.Position.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
            local ry = math.clamp((i.Position.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
            s, v = rx, 1 - ry
            svCur.Position = UDim2.new(rx, 0, ry, 0)
            fire()
        elseif dragHue then
            local rx = math.clamp((i.Position.X - hue.AbsolutePosition.X) / hue.AbsoluteSize.X, 0, 1)
            h = rx
            hueCur.Position = UDim2.new(rx, 0, 0.5, 0)
            sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            fire()
        end
    end)
end

-- Live ESP preview. Fills `parent`, reads Config. Returns update() to refresh.
local function CreateESPPreview(parent)
    local pv = Instance.new("Frame")
    pv.Size = UDim2.new(1, 0, 1, 0)
    pv.BackgroundColor3 = Theme.Bg3
    pv.BorderSizePixel = 0
    pv.ClipsDescendants = true
    pv.Parent = parent
    corner(pv, 6)

    local avatar = Instance.new("ImageLabel")
    avatar.AnchorPoint = Vector2.new(0.5, 0.5)
    avatar.Size = UDim2.new(0, 90, 0, 90)
    avatar.Position = UDim2.new(0.5, 6, 0.5, 4)
    avatar.BackgroundTransparency = 1
    avatar.Parent = pv
    task.spawn(function()
        local ok, content = pcall(function()
            return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size150x150)
        end)
        if ok and content then avatar.Image = content end
    end)

    local boxF = Instance.new("Frame")
    boxF.AnchorPoint = Vector2.new(0.5, 0.5)
    boxF.Size = UDim2.new(0, 64, 0, 96)
    boxF.Position = UDim2.new(0.5, 6, 0.5, 4)
    boxF.BackgroundTransparency = 1
    boxF.Parent = pv
    local boxStroke = stroke(boxF, Config.ESPColor, 1.5, 0)

    local nameL = Instance.new("TextLabel")
    nameL.AnchorPoint = Vector2.new(0.5, 1)
    nameL.Size = UDim2.new(1, 0, 0, 14)
    nameL.Position = UDim2.new(0.5, 6, 0.5, -48)
    nameL.BackgroundTransparency = 1
    nameL.Text = LocalPlayer.DisplayName
    nameL.TextColor3 = Color3.new(1, 1, 1)
    nameL.Font = Enum.Font.GothamBold
    nameL.TextSize = 11
    nameL.TextStrokeTransparency = 0.4
    nameL.Parent = pv

    local hpBg = Instance.new("Frame")
    hpBg.AnchorPoint = Vector2.new(0.5, 0.5)
    hpBg.Size = UDim2.new(0, 3, 0, 96)
    hpBg.Position = UDim2.new(0.5, -30, 0.5, 4)
    hpBg.BackgroundColor3 = Color3.new(0, 0, 0)
    hpBg.BorderSizePixel = 0
    hpBg.Parent = pv
    local hpBar = Instance.new("Frame")
    hpBar.AnchorPoint = Vector2.new(0.5, 1)
    hpBar.Size = UDim2.new(1, 0, 0.7, 0)
    hpBar.Position = UDim2.new(0.5, 0, 1, 0)
    hpBar.BackgroundColor3 = Color3.fromRGB(80, 230, 80)
    hpBar.BorderSizePixel = 0
    hpBar.Parent = hpBg

    local distL = Instance.new("TextLabel")
    distL.AnchorPoint = Vector2.new(0.5, 0)
    distL.Size = UDim2.new(1, 0, 0, 12)
    distL.Position = UDim2.new(0.5, 6, 0.5, 50)
    distL.BackgroundTransparency = 1
    distL.Text = "128m"
    distL.TextColor3 = Color3.fromRGB(200, 200, 200)
    distL.Font = Enum.Font.Gotham
    distL.TextSize = 10
    distL.TextStrokeTransparency = 0.4
    distL.Parent = pv

    local function update()
        local on = Config.ESP
        boxF.Visible = on and Config.ESPBoxes
        boxStroke.Color = Config.ESPColor
        nameL.Visible = on and Config.ESPNames
        hpBg.Visible = on and Config.ESPHealth
        distL.Visible = on and Config.ESPDistance
        avatar.ImageTransparency = on and 0 or 0.6
    end
    update()
    return update
end

local function CreateKeybind(parent, name, getKey, setKey, order)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 32)
    holder.BackgroundColor3 = Theme.Bg2
    holder.BorderSizePixel = 0
    holder.LayoutOrder = order
    holder.Parent = parent
    corner(holder, 7)

    local label = Instance.new("TextLabel")
    label.Text = name
    label.Size = UDim2.new(0.5, -12, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = holder

    local btn = Instance.new("TextButton")
    btn.Text = getKey().Name
    btn.Size = UDim2.new(0.5, -12, 0, 22)
    btn.Position = UDim2.new(0.5, 0, 0.5, -11)
    btn.BackgroundColor3 = Theme.Bg3
    btn.TextColor3 = Theme.Accent
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = holder
    corner(btn, 5)

    local listening = false
    btn.MouseButton1Click:Connect(function()
        listening = true
        btn.Text = "Press a key..."
    end)
    Connections.Keybind = UserInputService.InputBegan:Connect(function(input, gpe)
        if not listening or gpe then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            listening = false
            setKey(input.KeyCode)
            btn.Text = input.KeyCode.Name
        end
    end)
    return holder
end

-----------------------------------------------------------
-- Build tabs
-----------------------------------------------------------
local combatPage  = addTab("Combat",  "[A]", 1)
local visualsPage = addTab("Visuals", "[V]", 2)
local playerPage  = addTab("Info",  "[P]", 3)

-- COMBAT
CreateSection(combatPage, "Aimbot", 1)
CreateToggle(combatPage, "Aimbot Enabled", Config.Aimbot, 2, function(v) Config.Aimbot = v end)
CreateSlider(combatPage, "FOV Size", 50, 600, Config.AimbotFOV, 3, function(v) Config.AimbotFOV = v end)
CreateSlider(combatPage, "Smoothing", 1, 20, Config.AimbotSmooth, 4, function(v) Config.AimbotSmooth = v end)
CreateDropdown(combatPage, "Target", {"Head", "Torso", "HumanoidRootPart"}, Config.AimbotTarget, 5, function(v) Config.AimbotTarget = v end)
CreateToggle(combatPage, "Show FOV Circle", Config.ShowFOV, 6, function(v) Config.ShowFOV = v end)
CreateToggle(combatPage, "Team Check", Config.TeamCheck, 7, function(v) Config.TeamCheck = v end)
CreateSection(combatPage, "Range", 8)
CreateSlider(combatPage, "Max Distance", 100, 2000, Config.MaxDistance, 9, function(v) Config.MaxDistance = v end)

-- VISUALS
local updatePreview
local function refresh() if updatePreview then updatePreview() end end

CreateSection(visualsPage, "ESP", 1)
CreateToggle(visualsPage, "ESP Enabled", Config.ESP, 2, function(v) Config.ESP = v; refresh() end)
CreateToggle(visualsPage, "Boxes", Config.ESPBoxes, 3, function(v) Config.ESPBoxes = v; refresh() end)
CreateToggle(visualsPage, "Names", Config.ESPNames, 4, function(v) Config.ESPNames = v; refresh() end)
CreateToggle(visualsPage, "Health Bar", Config.ESPHealth, 5, function(v) Config.ESPHealth = v; refresh() end)
CreateToggle(visualsPage, "Distance", Config.ESPDistance, 6, function(v) Config.ESPDistance = v; refresh() end)
CreateToggle(visualsPage, "Team Check", Config.ESPTeamCheck, 7, function(v) Config.ESPTeamCheck = v end)

CreateSection(visualsPage, "ESP Color", 8)
local colorBox = Instance.new("Frame")
colorBox.Size = UDim2.new(1, 0, 0, 130)
colorBox.BackgroundColor3 = Theme.Bg2
colorBox.BorderSizePixel = 0
colorBox.LayoutOrder = 9
colorBox.Parent = visualsPage
corner(colorBox, 7)
pad(colorBox, 8)
CreateSpectrumPicker(colorBox, Config.ESPColor, function(c) Config.ESPColor = c; refresh() end)

-- PLAYER
CreateSection(playerPage, "Your Profile", 1)

local avatarHolder = Instance.new("Frame")
avatarHolder.Size = UDim2.new(1, 0, 0, 72)
avatarHolder.BackgroundColor3 = Theme.Bg2
avatarHolder.BorderSizePixel = 0
avatarHolder.LayoutOrder = 2
avatarHolder.Parent = playerPage
corner(avatarHolder, 7)

local avatar = Instance.new("ImageLabel")
avatar.Size = UDim2.new(0, 56, 0, 56)
avatar.Position = UDim2.new(0, 8, 0.5, -28)
avatar.BackgroundColor3 = Theme.Bg3
avatar.BorderSizePixel = 0
avatar.Parent = avatarHolder
corner(avatar, 28)
task.spawn(function()
    local ok, content = pcall(function()
        return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    end)
    if ok and content then avatar.Image = content end
end)

local nameLabel = Instance.new("TextLabel")
nameLabel.Text = LocalPlayer.DisplayName
nameLabel.Position = UDim2.new(0, 74, 0, 16)
nameLabel.Size = UDim2.new(1, -82, 0, 20)
nameLabel.BackgroundTransparency = 1
nameLabel.TextColor3 = Theme.Text
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextSize = 15
nameLabel.Parent = avatarHolder

local userLabel = Instance.new("TextLabel")
userLabel.Text = "@" .. LocalPlayer.Name
userLabel.Position = UDim2.new(0, 74, 0, 36)
userLabel.Size = UDim2.new(1, -82, 0, 18)
userLabel.BackgroundTransparency = 1
userLabel.TextColor3 = Theme.SubText
userLabel.TextXAlignment = Enum.TextXAlignment.Left
userLabel.Font = Enum.Font.Gotham
userLabel.TextSize = 12
userLabel.Parent = avatarHolder

CreateInfo(playerPage, "User ID", tostring(LocalPlayer.UserId), 3)

CreateSection(playerPage, "Community", 4)
CreateButton(playerPage, "Join Discord", 5, joinDiscord, Theme.Discord)
CreateButton(playerPage, "Sub to YouTube", 6, subYouTube, Theme.YouTube)

CreateSection(playerPage, "UI Settings", 7)
CreateKeybind(playerPage, "Toggle UI Key", function() return toggleKey end, function(k) toggleKey = k end, 8)

CreateSection(playerPage, "Danger Zone", 9)

CreateButton(playerPage, "Destroy Script", 10, function()
    notify("King Hub closed.", Theme.Danger)
    task.wait(0.2)
    if Cleanup then Cleanup() end
end, Theme.Danger)

selectTab("Combat")

-----------------------------------------------------------
-- ESP Preview panel (separate, to the right of the window)
-----------------------------------------------------------
local PreviewPanel = Instance.new("Frame")
PreviewPanel.Name = "ESPPreview"
PreviewPanel.AnchorPoint = Vector2.new(0, 0.5)
PreviewPanel.Size = UDim2.new(0, 150, 0, 200)
PreviewPanel.BackgroundColor3 = Theme.Bg
PreviewPanel.BorderSizePixel = 0
PreviewPanel.Parent = ScreenGui
corner(PreviewPanel, 6)
stroke(PreviewPanel, Theme.Accent, 1.5, 0.4)
pad(PreviewPanel, 8)

local pvTitle = Instance.new("TextLabel")
pvTitle.Size = UDim2.new(1, 0, 0, 16)
pvTitle.BackgroundTransparency = 1
pvTitle.Text = "ESP PREVIEW"
pvTitle.TextColor3 = Theme.Accent
pvTitle.TextXAlignment = Enum.TextXAlignment.Left
pvTitle.Font = Enum.Font.GothamBold
pvTitle.TextSize = 11
pvTitle.Parent = PreviewPanel

local pvContent = Instance.new("Frame")
pvContent.Size = UDim2.new(1, 0, 1, -22)
pvContent.Position = UDim2.new(0, 0, 0, 22)
pvContent.BackgroundColor3 = Theme.Bg2
pvContent.BorderSizePixel = 0
pvContent.Parent = PreviewPanel
corner(pvContent, 6)

updatePreview = CreateESPPreview(pvContent)

-- glue the panel to the right of the window at the same vertical level, only on Visuals
Connections.PreviewFollow = RunService.RenderStepped:Connect(function()
    PreviewPanel.Visible = (activeTab == "Visuals")
    PreviewPanel.Position = UDim2.new(
        Main.Position.X.Scale, Main.Position.X.Offset + Main.AbsoluteSize.X / 2 + 12,
        Main.Position.Y.Scale, Main.Position.Y.Offset
    )
end)

-----------------------------------------------------------
-- Drag
-----------------------------------------------------------
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
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- Minimize / Close
local isOpen = true
MinBtn.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    local goal = isOpen and UDim2.new(0, 480, 0, 340) or UDim2.new(0, 480, 0, 42)
    TweenService:Create(Main, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = goal}):Play()
end)
CloseBtn.MouseButton1Click:Connect(function()
    notify("King Hub closed.", Theme.Danger)
    task.wait(0.2)
    if Cleanup then Cleanup() end
end)

-- Intro pop animation
Main.Size = UDim2.new(0, 480, 0, 0)
TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 480, 0, 340)}):Play()

-----------------------------------------------------------
-- FOV Circle (Drawing API)
-----------------------------------------------------------
local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = Config.AimbotFOV
FOVCircle.Thickness = 1.5
FOVCircle.Color = Theme.Accent
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
    d.BoxOutline.Thickness = 3
    d.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
    d.BoxOutline.Filled = false
    d.BoxOutline.Visible = false

    d.Box.Thickness = 1.5
    d.Box.Color = Theme.Accent
    d.Box.Filled = false
    d.Box.Visible = false

    d.Name.Size = 13
    d.Name.Color = Color3.fromRGB(255, 255, 255)
    d.Name.Outline = true
    d.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
    d.Name.Center = true
    d.Name.Font = Drawing.Fonts.Plex
    d.Name.Visible = false

    d.HealthBg.Thickness = 4
    d.HealthBg.Color = Color3.fromRGB(0, 0, 0)
    d.HealthBg.Visible = false

    d.Health.Thickness = 2
    d.Health.Color = Color3.fromRGB(0, 255, 0)
    d.Health.Visible = false

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
    return player.Character
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

        if Config.ESPTeamCheck and player.Team == LocalPlayer.Team then
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

        if not ESPObjects[player] then
            ESPObjects[player] = CreateESPDrawings()
            SetupDrawings(ESPObjects[player])
        end

        local d = ESPObjects[player]

        if not Config.ESP then
            HideESP(d)
            continue
        end

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

        local tl = Vector2.new(centerX - width / 2, topScreen.Y)
        local tr = Vector2.new(centerX + width / 2, topScreen.Y)
        local bl = Vector2.new(centerX - width / 2, botScreen.Y)
        local br = Vector2.new(centerX + width / 2, botScreen.Y)

        if Config.ESPBoxes then
            d.BoxOutline.PointA = tl
            d.BoxOutline.PointB = tr
            d.BoxOutline.PointC = br
            d.BoxOutline.PointD = bl
            d.BoxOutline.Visible = true

            d.Box.Color = Config.ESPColor
            d.Box.PointA = tl
            d.Box.PointB = tr
            d.Box.PointC = br
            d.Box.PointD = bl
            d.Box.Visible = true
        else
            d.BoxOutline.Visible = false
            d.Box.Visible = false
        end

        if Config.ESPNames then
            d.Name.Text = player.DisplayName
            d.Name.Position = Vector2.new(centerX, topScreen.Y - 16)
            d.Name.Visible = true
        else
            d.Name.Visible = false
        end

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
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Position = center
    FOVCircle.Radius = Config.AimbotFOV
    FOVCircle.Visible = Config.ShowFOV and Config.Aimbot

    UpdateESP()

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
Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

-----------------------------------------------------------
-- Toggle UI visibility (Right Ctrl)
-----------------------------------------------------------
Connections.ToggleUI = UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == toggleKey then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-----------------------------------------------------------
-- Cleanup function
-----------------------------------------------------------
Cleanup = function()
    for _, conn in pairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end
    for player, _ in pairs(ESPObjects) do
        RemoveESP(player)
    end
    pcall(function() FOVCircle:Remove() end)
    pcall(function() ScreenGui:Destroy() end)
end

getgenv().MirkoHubCleanup = Cleanup
