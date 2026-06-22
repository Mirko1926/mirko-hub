-- King Hub Phantom Forces (ESP-only)
-- PF usa un motore custom con nomi offuscati: ESP via workspace.Roots (box + distanza).
-- No aimbot, no names/team/health (not reliably readable). by MIRKO KING YT
-- Toggle UI: Right Ctrl

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local DISCORD_INVITE = "https://discord.com/invite/qfyfqMnBYK"
local YOUTUBE_CHANNEL = "https://www.youtube.com/@MIRKOKING"

local Theme = {
    Bg = Color3.fromRGB(8, 8, 8), Bg2 = Color3.fromRGB(16, 16, 16), Bg3 = Color3.fromRGB(26, 26, 26),
    Accent = Color3.fromRGB(224, 176, 16), Accent2 = Color3.fromRGB(255, 214, 51),
    Text = Color3.fromRGB(240, 240, 240), SubText = Color3.fromRGB(140, 140, 140),
    Off = Color3.fromRGB(45, 45, 45), Danger = Color3.fromRGB(235, 60, 60),
    Discord = Color3.fromRGB(88, 101, 242), YouTube = Color3.fromRGB(255, 0, 0),
}

local Config = {
    ESP = true,
    Boxes = true,
    Distance = true,
    Tracers = false,
    MaxDistance = 3000,
    ESPColor = Color3.fromRGB(224, 176, 16),
    -- aimbot (camera-lock on Roots; no team data on PF, targets everyone)
    Aimbot = false,
    AimbotFOV = 120,
    AimbotSmooth = 8,
    AimHeight = 2,
    ShowFOV = false,
}
local toggleKey = Enum.KeyCode.RightControl

local Connections = {}
local Cleanup

-----------------------------------------------------------
-- ScreenGui
-----------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MirkoHubPF"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local function corner(p, r) local c = Instance.new("UICorner", p); c.CornerRadius = UDim.new(0, r or 6); return c end
local function stroke(p, col, t, tr) local s = Instance.new("UIStroke", p); s.Color = col or Theme.Bg3; s.Thickness = t or 1; s.Transparency = tr or 0; return s end
local function pad(p, n) local u = Instance.new("UIPadding", p); u.PaddingLeft = UDim.new(0,n); u.PaddingRight = UDim.new(0,n); u.PaddingTop = UDim.new(0,n); u.PaddingBottom = UDim.new(0,n); return u end

local function notify(text, color)
    local t = Instance.new("TextLabel")
    t.AnchorPoint = Vector2.new(1, 1); t.Position = UDim2.new(1, -16, 1, 10); t.Size = UDim2.new(0, 240, 0, 36)
    t.BackgroundColor3 = Theme.Bg2; t.TextColor3 = color or Theme.Text; t.Text = text
    t.Font = Enum.Font.GothamMedium; t.TextSize = 13; t.TextWrapped = true; t.Parent = ScreenGui
    corner(t, 8); stroke(t, color or Theme.Accent, 1, 0.3)
    TweenService:Create(t, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -16, 1, -16)}):Play()
    task.delay(2.6, function()
        TweenService:Create(t, TweenInfo.new(0.3), {Position = UDim2.new(1, -16, 1, 10), TextTransparency = 1, BackgroundTransparency = 1}):Play()
        task.wait(0.35); t:Destroy()
    end)
end

local function copyLink(url, label, color)
    local ok = pcall(function() if setclipboard then setclipboard(url) end end)
    notify(ok and (label .. " copied to clipboard! Paste it into your browser.") or url, color)
end
local function joinDiscord() copyLink(DISCORD_INVITE, "Discord link", Theme.Discord) end
local function subYouTube() copyLink(YOUTUBE_CHANNEL, "YouTube channel", Theme.YouTube) end

-----------------------------------------------------------
-- Window
-----------------------------------------------------------
local Main = Instance.new("Frame")
Main.AnchorPoint = Vector2.new(0.5, 0.5); Main.Size = UDim2.new(0, 460, 0, 300)
Main.Position = UDim2.new(0.5, 0, 0.5, 0); Main.BackgroundColor3 = Theme.Bg
Main.BorderSizePixel = 0; Main.ClipsDescendants = true; Main.Parent = ScreenGui
corner(Main, 6); stroke(Main, Theme.Accent, 1.5, 0.4); pad(Main, 2)

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 38); TitleBar.BackgroundColor3 = Theme.Bg; TitleBar.BorderSizePixel = 0; TitleBar.Parent = Main
local accentLine = Instance.new("Frame")
accentLine.Size = UDim2.new(1, 0, 0, 2); accentLine.Position = UDim2.new(0, 0, 1, -2); accentLine.BackgroundColor3 = Theme.Accent; accentLine.BorderSizePixel = 0; accentLine.Parent = TitleBar
Instance.new("UIGradient", accentLine).Color = ColorSequence.new(Theme.Accent, Theme.Accent2)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text = "KING HUB"; TitleLabel.Size = UDim2.new(0, 110, 1, 0); TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1; TitleLabel.TextColor3 = Theme.Text; TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Font = Enum.Font.GothamBlack; TitleLabel.TextSize = 15; TitleLabel.Parent = TitleBar

local Badge = Instance.new("TextLabel")
Badge.Text = "PHANTOM FORCES"; Badge.Size = UDim2.new(0, 112, 0, 18); Badge.Position = UDim2.new(0, 112, 0.5, -9)
Badge.BackgroundColor3 = Theme.Accent; Badge.TextColor3 = Color3.fromRGB(10, 10, 10); Badge.Font = Enum.Font.GothamBold; Badge.TextSize = 10; Badge.Parent = TitleBar
corner(Badge, 5)

local credit = Instance.new("TextLabel")
credit.Text = "by MIRKO KING YT"; credit.Size = UDim2.new(0, 150, 1, 0); credit.Position = UDim2.new(0, 236, 0, 0)
credit.BackgroundTransparency = 1; credit.TextColor3 = Theme.SubText; credit.TextXAlignment = Enum.TextXAlignment.Left
credit.Font = Enum.Font.GothamMedium; credit.TextSize = 10; credit.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"; CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -34, 0.5, -15)
CloseBtn.BackgroundTransparency = 1; CloseBtn.TextColor3 = Theme.SubText; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 14; CloseBtn.Parent = TitleBar
local MinBtn = Instance.new("TextButton")
MinBtn.Text = "—"; MinBtn.Size = UDim2.new(0, 30, 0, 30); MinBtn.Position = UDim2.new(1, -66, 0.5, -15)
MinBtn.BackgroundTransparency = 1; MinBtn.TextColor3 = Theme.SubText; MinBtn.Font = Enum.Font.GothamBold; MinBtn.TextSize = 16; MinBtn.Parent = TitleBar
for _, b in pairs({CloseBtn, MinBtn}) do
    b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(0.15), {TextColor3 = Theme.Text}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(0.15), {TextColor3 = Theme.SubText}):Play() end)
end

local Sidebar = Instance.new("Frame")
Sidebar.Position = UDim2.new(0, 8, 0, 46); Sidebar.Size = UDim2.new(0, 124, 1, -54); Sidebar.BackgroundColor3 = Theme.Bg2; Sidebar.BorderSizePixel = 0; Sidebar.Parent = Main
corner(Sidebar, 8)
local sideList = Instance.new("UIListLayout", Sidebar); sideList.Padding = UDim.new(0, 4); sideList.SortOrder = Enum.SortOrder.LayoutOrder
pad(Sidebar, 8)

-----------------------------------------------------------
-- Tabs
-----------------------------------------------------------
local Tabs = {}
local activeTab
local function makePage()
    local page = Instance.new("ScrollingFrame")
    page.Position = UDim2.new(0, 140, 0, 46); page.Size = UDim2.new(1, -148, 1, -54); page.BackgroundTransparency = 1
    page.BorderSizePixel = 0; page.ScrollBarThickness = 3; page.ScrollBarImageColor3 = Theme.Accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0); page.AutomaticCanvasSize = Enum.AutomaticSize.Y; page.Visible = false; page.Parent = Main
    local l = Instance.new("UIListLayout", page); l.Padding = UDim.new(0, 6); l.SortOrder = Enum.SortOrder.LayoutOrder
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
local function addTab(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34); btn.BackgroundColor3 = Theme.Bg2; btn.Text = ""; btn.AutoButtonColor = false; btn.LayoutOrder = order; btn.Parent = Sidebar
    corner(btn, 6)
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 3, 0, 18); indicator.Position = UDim2.new(0, 0, 0.5, -9); indicator.BackgroundColor3 = Color3.fromRGB(10,10,10); indicator.BorderSizePixel = 0; indicator.Visible = false; indicator.Parent = btn
    corner(indicator, 2)
    local label = Instance.new("TextLabel")
    label.Text = name; label.Size = UDim2.new(1, -24, 1, 0); label.Position = UDim2.new(0, 14, 0, 0); label.BackgroundTransparency = 1
    label.TextColor3 = Theme.SubText; label.TextXAlignment = Enum.TextXAlignment.Left; label.Font = Enum.Font.GothamBold; label.TextSize = 13; label.Parent = btn
    local page = makePage()
    Tabs[name] = { Button = btn, Label = label, Page = page, Indicator = indicator }
    btn.MouseButton1Click:Connect(function() selectTab(name) end)
    return page
end

-----------------------------------------------------------
-- Components
-----------------------------------------------------------
local function CreateSection(parent, name, order)
    local s = Instance.new("TextLabel")
    s.Text = name:upper(); s.Size = UDim2.new(1, 0, 0, 18); s.BackgroundTransparency = 1; s.TextColor3 = Theme.Accent
    s.TextXAlignment = Enum.TextXAlignment.Left; s.Font = Enum.Font.GothamBold; s.TextSize = 11; s.LayoutOrder = order; s.Parent = parent
end
local function CreateToggle(parent, name, default, order, callback)
    local h = Instance.new("Frame"); h.Size = UDim2.new(1, 0, 0, 32); h.BackgroundColor3 = Theme.Bg2; h.BorderSizePixel = 0; h.LayoutOrder = order; h.Parent = parent; corner(h, 7)
    local l = Instance.new("TextLabel"); l.Text = name; l.Size = UDim2.new(1, -56, 1, 0); l.Position = UDim2.new(0, 12, 0, 0); l.BackgroundTransparency = 1; l.TextColor3 = Theme.Text; l.TextXAlignment = Enum.TextXAlignment.Left; l.Font = Enum.Font.Gotham; l.TextSize = 13; l.Parent = h
    local bg = Instance.new("Frame"); bg.Size = UDim2.new(0, 38, 0, 20); bg.Position = UDim2.new(1, -48, 0.5, -10); bg.BackgroundColor3 = default and Theme.Accent or Theme.Off; bg.BorderSizePixel = 0; bg.Parent = h; corner(bg, 10)
    local c = Instance.new("Frame"); c.Size = UDim2.new(0, 16, 0, 16); c.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8); c.BackgroundColor3 = Color3.new(1,1,1); c.BorderSizePixel = 0; c.Parent = bg; corner(c, 8)
    local en = default
    local b = Instance.new("TextButton"); b.Text = ""; b.Size = UDim2.new(1, 0, 1, 0); b.BackgroundTransparency = 1; b.Parent = h
    b.MouseButton1Click:Connect(function()
        en = not en
        TweenService:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = en and Theme.Accent or Theme.Off}):Play()
        TweenService:Create(c, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {Position = en and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
        callback(en)
    end)
end
local function CreateSlider(parent, name, min, max, default, order, callback)
    local h = Instance.new("Frame"); h.Size = UDim2.new(1, 0, 0, 46); h.BackgroundColor3 = Theme.Bg2; h.BorderSizePixel = 0; h.LayoutOrder = order; h.Parent = parent; corner(h, 7)
    local l = Instance.new("TextLabel"); l.Text = name; l.Size = UDim2.new(0.7, -12, 0, 18); l.Position = UDim2.new(0, 12, 0, 4); l.BackgroundTransparency = 1; l.TextColor3 = Theme.Text; l.TextXAlignment = Enum.TextXAlignment.Left; l.Font = Enum.Font.Gotham; l.TextSize = 13; l.Parent = h
    local v = Instance.new("TextLabel"); v.Text = tostring(default); v.Size = UDim2.new(0.3, -12, 0, 18); v.Position = UDim2.new(0.7, 0, 0, 4); v.BackgroundTransparency = 1; v.TextColor3 = Theme.Accent; v.TextXAlignment = Enum.TextXAlignment.Right; v.Font = Enum.Font.GothamBold; v.TextSize = 13; v.Parent = h
    local sb = Instance.new("Frame"); sb.Size = UDim2.new(1, -24, 0, 6); sb.Position = UDim2.new(0, 12, 0, 32); sb.BackgroundColor3 = Theme.Off; sb.BorderSizePixel = 0; sb.Parent = h; corner(sb, 3)
    local fill = Instance.new("Frame"); fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Theme.Accent; fill.BorderSizePixel = 0; fill.Parent = sb; corner(fill, 3)
    local btn = Instance.new("TextButton"); btn.Text = ""; btn.Size = UDim2.new(1, 0, 1, 16); btn.Position = UDim2.new(0, 0, 0, -8); btn.BackgroundTransparency = 1; btn.Parent = sb
    local sliding = false
    local function upd(x)
        local rel = math.clamp((x - sb.AbsolutePosition.X) / sb.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max-min)*rel); fill.Size = UDim2.new(rel, 0, 1, 0); v.Text = tostring(val); callback(val)
    end
    btn.MouseButton1Down:Connect(function(x) sliding = true; upd(x) end)
    Connections[#Connections+1] = UserInputService.InputEnded:Connect(function(i) if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then sliding = false end end)
    Connections[#Connections+1] = UserInputService.InputChanged:Connect(function(i) if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i.Position.X) end end)
end
local function CreateButton(parent, name, order, callback, color)
    local b = Instance.new("TextButton"); b.Size = UDim2.new(1, 0, 0, 34); b.BackgroundColor3 = color or Theme.Bg3; b.TextColor3 = Color3.new(1,1,1); b.Text = name; b.Font = Enum.Font.GothamBold; b.TextSize = 13; b.AutoButtonColor = true; b.LayoutOrder = order; b.Parent = parent; corner(b, 7)
    b.MouseButton1Click:Connect(callback)
end
local function CreateKeybind(parent, name, getKey, setKey, order)
    local h = Instance.new("Frame"); h.Size = UDim2.new(1, 0, 0, 32); h.BackgroundColor3 = Theme.Bg2; h.BorderSizePixel = 0; h.LayoutOrder = order; h.Parent = parent; corner(h, 7)
    local l = Instance.new("TextLabel"); l.Text = name; l.Size = UDim2.new(0.5, -12, 1, 0); l.Position = UDim2.new(0, 12, 0, 0); l.BackgroundTransparency = 1; l.TextColor3 = Theme.Text; l.TextXAlignment = Enum.TextXAlignment.Left; l.Font = Enum.Font.Gotham; l.TextSize = 13; l.Parent = h
    local b = Instance.new("TextButton"); b.Text = getKey().Name; b.Size = UDim2.new(0.5, -12, 0, 22); b.Position = UDim2.new(0.5, 0, 0.5, -11); b.BackgroundColor3 = Theme.Bg3; b.TextColor3 = Theme.Accent; b.Font = Enum.Font.GothamBold; b.TextSize = 12; b.Parent = h; corner(b, 5)
    local listening = false
    b.MouseButton1Click:Connect(function() listening = true; b.Text = "Press a key..." end)
    Connections[#Connections+1] = UserInputService.InputBegan:Connect(function(i, gpe)
        if not listening or gpe then return end
        if i.UserInputType == Enum.UserInputType.Keyboard then listening = false; setKey(i.KeyCode); b.Text = i.KeyCode.Name end
    end)
end
local function CreateSpectrumPicker(parent, default, callback)
    local hh, ss, vv = default:ToHSV()
    local sv = Instance.new("Frame"); sv.Size = UDim2.new(1, 0, 1, -20); sv.BackgroundColor3 = Color3.fromHSV(hh,1,1); sv.BorderSizePixel = 0; sv.Parent = parent; sv.Active = true; corner(sv, 5)
    local white = Instance.new("Frame"); white.Size = UDim2.new(1,0,1,0); white.BackgroundColor3 = Color3.new(1,1,1); white.BorderSizePixel = 0; white.Parent = sv; corner(white, 5)
    Instance.new("UIGradient", white).Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1)})
    local black = Instance.new("Frame"); black.Size = UDim2.new(1,0,1,0); black.BackgroundColor3 = Color3.new(0,0,0); black.BorderSizePixel = 0; black.Parent = sv; corner(black, 5)
    local bgr = Instance.new("UIGradient", black); bgr.Rotation = 90; bgr.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)})
    local svc = Instance.new("Frame"); svc.Size = UDim2.new(0,9,0,9); svc.AnchorPoint = Vector2.new(0.5,0.5); svc.Position = UDim2.new(ss,0,1-vv,0); svc.BackgroundColor3 = Color3.new(1,1,1); svc.BorderSizePixel = 0; svc.ZIndex = 5; svc.Parent = sv; corner(svc, 5); stroke(svc, Color3.new(0,0,0), 1, 0)
    local hue = Instance.new("Frame"); hue.Size = UDim2.new(1,0,0,12); hue.Position = UDim2.new(0,0,1,-12); hue.BorderSizePixel = 0; hue.Parent = parent; hue.Active = true; corner(hue, 6)
    Instance.new("UIGradient", hue).Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,0,0)), ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)), ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,255,255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)), ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,0,0)) })
    local hc = Instance.new("Frame"); hc.Size = UDim2.new(0,4,1,2); hc.AnchorPoint = Vector2.new(0.5,0.5); hc.Position = UDim2.new(hh,0,0.5,0); hc.BackgroundColor3 = Color3.new(1,1,1); hc.BorderSizePixel = 0; hc.ZIndex = 5; hc.Parent = hue; corner(hc, 2); stroke(hc, Color3.new(0,0,0), 1, 0)
    local function fire() callback(Color3.fromHSV(hh, ss, vv)) end
    local dSV, dH = false, false
    sv.InputBegan:Connect(function(i) if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then dSV = true end end)
    hue.InputBegan:Connect(function(i) if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then dH = true end end)
    Connections[#Connections+1] = UserInputService.InputEnded:Connect(function(i) if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then dSV = false; dH = false end end)
    Connections[#Connections+1] = UserInputService.InputChanged:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch then return end
        if dSV then
            local rx = math.clamp((i.Position.X - sv.AbsolutePosition.X)/sv.AbsoluteSize.X, 0, 1)
            local ry = math.clamp((i.Position.Y - sv.AbsolutePosition.Y)/sv.AbsoluteSize.Y, 0, 1)
            ss, vv = rx, 1-ry; svc.Position = UDim2.new(rx, 0, ry, 0); fire()
        elseif dH then
            local rx = math.clamp((i.Position.X - hue.AbsolutePosition.X)/hue.AbsoluteSize.X, 0, 1)
            hh = rx; hc.Position = UDim2.new(rx, 0, 0.5, 0); sv.BackgroundColor3 = Color3.fromHSV(hh,1,1); fire()
        end
    end)
end

-----------------------------------------------------------
-- Build tabs
-----------------------------------------------------------
local combatPage = addTab("Combat", 1)
local visualsPage = addTab("Visuals", 2)
local infoPage = addTab("Info", 3)

CreateSection(combatPage, "Aimbot", 1)
CreateToggle(combatPage, "Aimbot Enabled", Config.Aimbot, 2, function(v) Config.Aimbot = v end)
CreateSlider(combatPage, "FOV Size", 40, 500, Config.AimbotFOV, 3, function(v) Config.AimbotFOV = v end)
CreateSlider(combatPage, "Smoothing", 1, 25, Config.AimbotSmooth, 4, function(v) Config.AimbotSmooth = v end)
CreateSlider(combatPage, "Aim Height", 0, 5, Config.AimHeight, 5, function(v) Config.AimHeight = v end)
CreateToggle(combatPage, "Show FOV Circle", Config.ShowFOV, 6, function(v) Config.ShowFOV = v end)
local aimNote = Instance.new("TextLabel")
aimNote.Text = "Hold Right Click to aim. No team data on PF: targets everyone (incl. teammates)."
aimNote.Size = UDim2.new(1, 0, 0, 40); aimNote.BackgroundColor3 = Theme.Bg2; aimNote.BorderSizePixel = 0; aimNote.LayoutOrder = 7
aimNote.TextColor3 = Theme.SubText; aimNote.TextWrapped = true; aimNote.Font = Enum.Font.Gotham; aimNote.TextSize = 11; aimNote.Parent = combatPage
corner(aimNote, 7); local anP = Instance.new("UIPadding", aimNote); anP.PaddingLeft = UDim.new(0,10); anP.PaddingRight = UDim.new(0,10)

CreateSection(visualsPage, "ESP", 1)
CreateToggle(visualsPage, "ESP Enabled", Config.ESP, 2, function(v) Config.ESP = v end)
CreateToggle(visualsPage, "Boxes", Config.Boxes, 3, function(v) Config.Boxes = v end)
CreateToggle(visualsPage, "Distance", Config.Distance, 4, function(v) Config.Distance = v end)
CreateToggle(visualsPage, "Tracers", Config.Tracers, 5, function(v) Config.Tracers = v end)
CreateSlider(visualsPage, "Max Distance", 100, 5000, Config.MaxDistance, 6, function(v) Config.MaxDistance = v end)
CreateSection(visualsPage, "ESP Color", 7)
local colorBox = Instance.new("Frame")
colorBox.Size = UDim2.new(1, 0, 0, 120); colorBox.BackgroundColor3 = Theme.Bg2; colorBox.BorderSizePixel = 0; colorBox.LayoutOrder = 8; colorBox.Parent = visualsPage
corner(colorBox, 7); pad(colorBox, 8)
CreateSpectrumPicker(colorBox, Config.ESPColor, function(c) Config.ESPColor = c end)

CreateSection(infoPage, "Note", 1)
local note = Instance.new("TextLabel")
note.Text = "PF hides names/team/health: ESP shows boxes + distance only. Aimbot has no team data, so it targets everyone."
note.Size = UDim2.new(1, 0, 0, 50); note.BackgroundColor3 = Theme.Bg2; note.BorderSizePixel = 0; note.LayoutOrder = 2; note.TextColor3 = Theme.SubText
note.TextWrapped = true; note.Font = Enum.Font.Gotham; note.TextSize = 12; note.Parent = infoPage
corner(note, 7); local notePad = Instance.new("UIPadding", note); notePad.PaddingLeft = UDim.new(0,10); notePad.PaddingRight = UDim.new(0,10)

CreateSection(infoPage, "Community", 3)
CreateButton(infoPage, "Join Discord", 4, joinDiscord, Theme.Discord)
CreateButton(infoPage, "Sub to YouTube", 5, subYouTube, Theme.YouTube)
CreateSection(infoPage, "UI Settings", 6)
CreateKeybind(infoPage, "Toggle UI Key", function() return toggleKey end, function(k) toggleKey = k end, 7)
CreateSection(infoPage, "Danger Zone", 8)
CreateButton(infoPage, "Destroy Script", 9, function() notify("King Hub closed.", Theme.Danger); task.wait(0.2); if Cleanup then Cleanup() end end, Theme.Danger)

selectTab("Combat")

-----------------------------------------------------------
-- Drag / minimize / close
-----------------------------------------------------------
local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(i) if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then dragging = true; dragStart = i.Position; startPos = Main.Position end end)

-- Make the whole window draggable from any empty area (edges/sides/bottom) so it can't get stuck
Main.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = i.Position; startPos = Main.Position
    end
end)
Connections[#Connections+1] = UserInputService.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
Connections[#Connections+1] = UserInputService.InputEnded:Connect(function(i) if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then dragging = false end end)
local isOpen = true
MinBtn.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    TweenService:Create(Main, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = isOpen and UDim2.new(0,460,0,300) or UDim2.new(0,460,0,42)}):Play()
end)
CloseBtn.MouseButton1Click:Connect(function() notify("King Hub closed.", Theme.Danger); task.wait(0.2); if Cleanup then Cleanup() end end)
Main.Size = UDim2.new(0, 460, 0, 0)
TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 460, 0, 300)}):Play()

-----------------------------------------------------------
-- ESP (Drawing) - pool keyed by index over workspace.Roots
-----------------------------------------------------------
local pool = {}
local function getDraw(i)
    if not pool[i] then
        local d = { outline = Drawing.new("Square"), box = Drawing.new("Square"), dist = Drawing.new("Text"), tracer = Drawing.new("Line") }
        d.outline.Thickness = 3; d.outline.Filled = false; d.outline.Color = Color3.new(0,0,0); d.outline.Visible = false
        d.box.Thickness = 1; d.box.Filled = false; d.box.Visible = false
        d.dist.Size = 12; d.dist.Center = true; d.dist.Outline = true; d.dist.OutlineColor = Color3.new(0,0,0); d.dist.Font = Drawing.Fonts.Plex; d.dist.Visible = false
        d.tracer.Thickness = 1; d.tracer.Visible = false
        pool[i] = d
    end
    return pool[i]
end
local function hideDraw(d) d.outline.Visible = false; d.box.Visible = false; d.dist.Visible = false; d.tracer.Visible = false end

Connections[#Connections+1] = RunService.RenderStepped:Connect(function()
    local roots = workspace:FindFirstChild("Roots")
    local used = 0
    if Config.ESP and roots then
        local camPos = Camera.CFrame.Position
        local vh = Camera.ViewportSize.Y
        for _, part in ipairs(roots:GetChildren()) do
            if not part:IsA("BasePart") then continue end
            local pos = part.Position
            local dist = (camPos - pos).Magnitude
            if dist < 6 or dist > Config.MaxDistance then continue end
            local topV, onTop = Camera:WorldToViewportPoint(pos + Vector3.new(0, 3, 0))
            local botV, onBot = Camera:WorldToViewportPoint(pos - Vector3.new(0, 3.2, 0))
            if not onTop and not onBot then continue end
            used = used + 1
            local d = getDraw(used)
            local h = math.abs(botV.Y - topV.Y)
            local w = h * 0.5
            local cx = (topV.X + botV.X) / 2
            local x = cx - w / 2
            local y = math.min(topV.Y, botV.Y)
            if Config.Boxes then
                d.outline.Size = Vector2.new(w, h); d.outline.Position = Vector2.new(x, y); d.outline.Visible = true
                d.box.Color = Config.ESPColor; d.box.Size = Vector2.new(w, h); d.box.Position = Vector2.new(x, y); d.box.Visible = true
            else d.outline.Visible = false; d.box.Visible = false end
            if Config.Distance then
                d.dist.Color = Config.ESPColor; d.dist.Text = math.floor(dist) .. "m"; d.dist.Position = Vector2.new(cx, y + h + 2); d.dist.Visible = true
            else d.dist.Visible = false end
            if Config.Tracers then
                d.tracer.Color = Config.ESPColor; d.tracer.From = Vector2.new(Camera.ViewportSize.X/2, vh); d.tracer.To = Vector2.new(cx, y + h); d.tracer.Visible = true
            else d.tracer.Visible = false end
        end
    end
    for i = used + 1, #pool do hideDraw(pool[i]) end
end)

-----------------------------------------------------------
-- Aimbot (camera-lock on nearest Root in FOV, hold Right Click)
-----------------------------------------------------------
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5; FOVCircle.Filled = false; FOVCircle.Transparency = 0.6; FOVCircle.Visible = false

local aimHold = false
Connections[#Connections+1] = UserInputService.InputBegan:Connect(function(i, gpe)
    if gpe then return end
    if i.UserInputType == Enum.UserInputType.MouseButton2 then aimHold = true end
end)
Connections[#Connections+1] = UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton2 then aimHold = false end
end)

Connections[#Connections+1] = RunService.RenderStepped:Connect(function()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Position = center
    FOVCircle.Radius = Config.AimbotFOV
    FOVCircle.Color = Config.ESPColor
    FOVCircle.Visible = Config.ShowFOV and Config.Aimbot

    if not (Config.Aimbot and aimHold) then return end
    local roots = workspace:FindFirstChild("Roots")
    if not roots then return end
    local camPos = Camera.CFrame.Position
    local best, bestDist = nil, Config.AimbotFOV
    for _, part in ipairs(roots:GetChildren()) do
        if part:IsA("BasePart") then
            local d3 = (camPos - part.Position).Magnitude
            if d3 >= 6 and d3 <= Config.MaxDistance then
                local aimPos = part.Position + Vector3.new(0, Config.AimHeight, 0)
                local sp, on = Camera:WorldToViewportPoint(aimPos)
                if on then
                    local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if d < bestDist then bestDist = d; best = aimPos end
                end
            end
        end
    end
    if best then
        local sp = Camera:WorldToViewportPoint(best)
        local diff = (Vector2.new(sp.X, sp.Y) - center) / math.max(1, Config.AimbotSmooth)
        pcall(function() mousemoverel(diff.X, diff.Y) end)
    end
end)

-----------------------------------------------------------
-- Toggle UI
-----------------------------------------------------------
Connections[#Connections+1] = UserInputService.InputBegan:Connect(function(i, gpe)
    if gpe then return end
    if i.KeyCode == toggleKey then ScreenGui.Enabled = not ScreenGui.Enabled end
end)

-----------------------------------------------------------
-- Cleanup
-----------------------------------------------------------
-----------------------------------------------------------
-- Mobile support (auto-detected): floating toggle + AIM button
-----------------------------------------------------------
if UserInputService.TouchEnabled and not UserInputService.MouseEnabled and not UserInputService.KeyboardEnabled then
    local mToggle = Instance.new("TextButton")
    mToggle.Size = UDim2.new(0, 46, 0, 46); mToggle.Position = UDim2.new(0, 14, 0, 150)
    mToggle.BackgroundColor3 = Theme.Accent; mToggle.TextColor3 = Color3.fromRGB(10, 10, 10)
    mToggle.Text = "KH"; mToggle.Font = Enum.Font.GothamBlack; mToggle.TextSize = 15; mToggle.Parent = ScreenGui
    corner(mToggle, 23)
    mToggle.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

    local mAim = Instance.new("TextButton")
    mAim.AnchorPoint = Vector2.new(1, 1); mAim.Size = UDim2.new(0, 78, 0, 78); mAim.Position = UDim2.new(1, -28, 1, -150)
    mAim.BackgroundColor3 = Theme.Accent; mAim.BackgroundTransparency = 0.4; mAim.TextColor3 = Color3.fromRGB(10, 10, 10)
    mAim.Text = "AIM"; mAim.Font = Enum.Font.GothamBold; mAim.TextSize = 18; mAim.Parent = ScreenGui
    corner(mAim, 39)
    mAim.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then aimHold = true end
    end)
    mAim.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then aimHold = false end
    end)
end

Cleanup = function()
    for _, c in pairs(Connections) do pcall(function() c:Disconnect() end) end
    for _, d in pairs(pool) do for _, o in pairs(d) do pcall(function() o:Remove() end) end end
    pcall(function() FOVCircle:Remove() end)
    pcall(function() ScreenGui:Destroy() end)
end
getgenv().MirkoHubCleanup = Cleanup
