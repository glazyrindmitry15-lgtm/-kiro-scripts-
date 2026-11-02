-- KIRO HACK | UI MODULE (FULL WITH MOUSE FIX)
local K = shared.KIRO
if not K then warn("[KIRO] Config не загружен!") return end

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")
local Theme = K.Theme
local Font_Main, Font_Bold, Font_Black = K.Fonts.Main, K.Fonts.Bold, K.Fonts.Black
local Settings = K.Settings

local parentGui
pcall(function() parentGui = gethui and gethui() or game:GetService("CoreGui") end)
if not parentGui then parentGui = K.LP:WaitForChild("PlayerGui") end

for _, v in pairs(parentGui:GetChildren()) do
    if v.Name == "KiroUI" or (v:IsA("ScreenGui") and v.DisplayOrder == 99999) then v:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KiroUI_" .. HttpService:GenerateGUID(false)
ScreenGui.ResetOnSpawn = false; ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global; ScreenGui.DisplayOrder = 99999; ScreenGui.Parent = parentGui
K.ScreenGui = ScreenGui

-- ================= УВЕДОМЛЕНИЯ =================
local NotifyContainer = Instance.new("Frame", ScreenGui)
NotifyContainer.Size = UDim2.new(0,300,1,-100); NotifyContainer.Position = UDim2.new(1,-310,0,60)
NotifyContainer.BackgroundTransparency = 1; NotifyContainer.ZIndex = 1000
local NL = Instance.new("UIListLayout", NotifyContainer)
NL.VerticalAlignment = Enum.VerticalAlignment.Top; NL.HorizontalAlignment = Enum.HorizontalAlignment.Right; NL.Padding = UDim.new(0,8)

K.Notify = function(title, text, isErr)
    local n = Instance.new("Frame", NotifyContainer)
    n.Size = UDim2.new(1,0,0,58); n.BackgroundColor3 = Theme.Glass; n.BackgroundTransparency = 0.05
    n.BorderSizePixel = 0; n.ZIndex = 1001; n.ClipsDescendants = true
    Instance.new("UICorner", n).CornerRadius = UDim.new(0,10)
    local stroke = Instance.new("UIStroke", n)
    stroke.Color = isErr and Theme.Red or Theme.Accent; stroke.Thickness = 1; stroke.Transparency = 0.3
    local acc = Instance.new("Frame", n)
    acc.Size = UDim2.new(0,3,0.6,0); acc.Position = UDim2.new(0,8,0.2,0)
    acc.BackgroundColor3 = isErr and Theme.Red or Theme.Accent; acc.BorderSizePixel = 0; acc.ZIndex = 1002
    Instance.new("UICorner", acc).CornerRadius = UDim.new(1,0)
    local t1 = Instance.new("TextLabel", n)
    t1.Size = UDim2.new(1,-28,0,18); t1.Position = UDim2.new(0,18,0,8); t1.BackgroundTransparency = 1
    t1.Text = title; t1.TextColor3 = isErr and Theme.Red or Theme.Accent
    t1.Font = Font_Bold; t1.TextSize = 12; t1.TextXAlignment = Enum.TextXAlignment.Left; t1.ZIndex = 1002
    local t2 = Instance.new("TextLabel", n)
    t2.Size = UDim2.new(1,-28,0,26); t2.Position = UDim2.new(0,18,0,26); t2.BackgroundTransparency = 1
    t2.Text = text; t2.TextColor3 = Theme.Text; t2.Font = Font_Main; t2.TextSize = 11
    t2.TextWrapped = true; t2.TextXAlignment = Enum.TextXAlignment.Left; t2.ZIndex = 1002
    n.Position = UDim2.new(1,0,0,0)
    TweenService:Create(n, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0,0,0,0)}):Play()
    task.delay(3, function()
        if n and n.Parent then
            TweenService:Create(n, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            for _, c in ipairs(n:GetDescendants()) do
                if c:IsA("TextLabel") then TweenService:Create(c, TweenInfo.new(0.2), {TextTransparency = 1}):Play() end
            end
            task.wait(0.25); if n and n.Parent then n:Destroy() end
        end
    end)
end

-- ================= СТАТУС БАР =================
local StatusBar = Instance.new("Frame", ScreenGui)
StatusBar.Size = UDim2.new(0,870,0,34); StatusBar.Position = UDim2.new(0.5,-435,0,15)
StatusBar.BackgroundColor3 = Theme.BG; StatusBar.BackgroundTransparency = 0.05
StatusBar.BorderSizePixel = 0; StatusBar.Visible = false; StatusBar.ZIndex = 50; StatusBar.ClipsDescendants = true
Instance.new("UICorner", StatusBar).CornerRadius = UDim.new(0,10)
local SBStroke = Instance.new("UIStroke", StatusBar); SBStroke.Color = Theme.Accent; SBStroke.Thickness = 1; SBStroke.Transparency = 0.4
local SBL = Instance.new("UIListLayout", StatusBar)
SBL.FillDirection = Enum.FillDirection.Horizontal; SBL.Padding = UDim.new(0,14)
SBL.HorizontalAlignment = Enum.HorizontalAlignment.Center; SBL.VerticalAlignment = Enum.VerticalAlignment.Center
local function StatusText(t, w)
    local lbl = Instance.new("TextLabel", StatusBar)
    lbl.Size = UDim2.new(0,w,1,0); lbl.BackgroundTransparency = 1; lbl.Text = t
    lbl.TextColor3 = Theme.Text; lbl.Font = Font_Bold; lbl.TextSize = 12; lbl.ZIndex = 51
    return lbl
end
local UITitle = StatusText("KIRO v18.1",100); UITitle.TextColor3 = Theme.Accent
local UITime = StatusText("00:00:00",70)
local UIFps = StatusText("FPS: 0",60)
local UIPing = StatusText("PING: 0ms",80)
local UIPlayers = StatusText("NEAR: 0",70); UIPlayers.TextColor3 = Theme.Green
local UIUser = StatusText(K.LP.Name,100)
local KillLabel = StatusText("KILLS: 0",80); KillLabel.TextColor3 = Color3.fromRGB(255,100,120)
local ModeLabel = StatusText("MODE: —",130); ModeLabel.TextColor3 = Theme.Accent

-- ================= ГЛАВНОЕ ОКНО =================
local GlowBorder = Instance.new("Frame", ScreenGui)
GlowBorder.Size = UDim2.new(0,784,0,544); GlowBorder.Position = UDim2.new(0.5,-392,0.5,-272)
GlowBorder.BackgroundColor3 = Theme.Accent; GlowBorder.BorderSizePixel = 0; GlowBorder.Visible = false; GlowBorder.ZIndex = 9
Instance.new("UICorner", GlowBorder).CornerRadius = UDim.new(0,18)
local GlowGrad = Instance.new("UIGradient", GlowBorder)
GlowGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Theme.Accent), ColorSequenceKeypoint.new(0.5,Theme.Accent2), ColorSequenceKeypoint.new(1,Theme.Accent)}
GlowGrad.Rotation = 135
task.spawn(function() while GlowBorder and GlowBorder.Parent do GlowGrad.Rotation = (GlowGrad.Rotation + 0.5) % 360; task.wait(0.03) end end)

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0,780,0,540); Main.Position = UDim2.new(0.5,-390,0.5,-270)
Main.BackgroundColor3 = Theme.BG; Main.BackgroundTransparency = 0.02
Main.BorderSizePixel = 0; Main.ClipsDescendants = true; Main.Visible = false; Main.ZIndex = 10
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,16)
local MG = Instance.new("UIGradient", Main)
MG.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(12,12,18)), ColorSequenceKeypoint.new(1,Color3.fromRGB(4,4,8))}
MG.Rotation = 135

local TitleBar = Instance.new("Frame", Main)
TitleBar.Size = UDim2.new(1,0,0,46); TitleBar.BackgroundTransparency = 1; TitleBar.ZIndex = 15
local TitleText = Instance.new("TextLabel", TitleBar)
TitleText.Size = UDim2.new(1,-200,1,0); TitleText.Position = UDim2.new(0,20,0,0)
TitleText.BackgroundTransparency = 1; TitleText.Text = "KIRO HACK"
TitleText.TextColor3 = Theme.Text; TitleText.Font = Font_Black; TitleText.TextSize = 16
TitleText.TextXAlignment = Enum.TextXAlignment.Left; TitleText.ZIndex = 16
local VerText = Instance.new("TextLabel", TitleBar)
VerText.Size = UDim2.new(0,65,0,22); VerText.Position = UDim2.new(0,125,0.5,-11)
VerText.BackgroundColor3 = Theme.GlassLight; VerText.BackgroundTransparency = 0.2
VerText.Text = "v18.1"; VerText.TextColor3 = Theme.Accent; VerText.Font = Font_Bold; VerText.TextSize = 10
VerText.BorderSizePixel = 0; VerText.ZIndex = 16
Instance.new("UICorner", VerText).CornerRadius = UDim.new(1,0)
local VS = Instance.new("UIStroke", VerText); VS.Color = Theme.Accent; VS.Thickness = 1; VS.Transparency = 0.4

local function TitleBtn(txt, x, color)
    local b = Instance.new("TextButton", TitleBar)
    b.Size = UDim2.new(0,30,0,30); b.Position = UDim2.new(1,x,0.5,-15)
    b.BackgroundColor3 = Theme.GlassLight; b.BackgroundTransparency = 0.3
    b.Text = txt; b.TextColor3 = color; b.Font = Font_Bold; b.TextSize = 14
    b.BorderSizePixel = 0; b.AutoButtonColor = false; b.ZIndex = 17
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3=color, TextColor3=Color3.new(1,1,1), BackgroundTransparency=0}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3=Theme.GlassLight, TextColor3=color, BackgroundTransparency=0.3}):Play() end)
    return b
end
local CloseBtn = TitleBtn("✕", -44, Theme.Red)
local MinBtn = TitleBtn("—", -82, Theme.Accent)

local function closeMenu()
    K.MenuOpen = false; K.Zooming = false
    if Settings.Aimbot.AimMode == "Hold" then K.Aiming = false end
    pcall(function() K.Camera.FieldOfView = Settings.Camera.DefaultFOV end)
    GlowBorder.Visible = false
    TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size=UDim2.new(0,740,0,500), Position=UDim2.new(0.5,-370,0.5,-250), BackgroundTransparency=1}):Play()
    task.delay(0.25, function() if not K.MenuOpen then Main.Visible = false end end)
end
local function openMenu()
    K.MenuOpen = true; K.Zooming = false
    if Settings.Aimbot.AimMode == "Hold" then K.Aiming = false end
    Main.Visible = true; GlowBorder.Visible = true
    Main.Size = UDim2.new(0,740,0,500); Main.Position = UDim2.new(0.5,-370,0.5,-250); Main.BackgroundTransparency = 1
    GlowBorder.Size = UDim2.new(0,744,0,504); GlowBorder.Position = UDim2.new(0.5,-372,0.5,-252)
    TweenService:Create(Main, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=UDim2.new(0,780,0,540), Position=UDim2.new(0.5,-390,0.5,-270), BackgroundTransparency=0.02}):Play()
    TweenService:Create(GlowBorder, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=UDim2.new(0,784,0,544), Position=UDim2.new(0.5,-392,0.5,-272)}):Play()
end
CloseBtn.MouseButton1Click:Connect(closeMenu)
MinBtn.MouseButton1Click:Connect(closeMenu)

-- ================= TOP TAB =================
local TopTabContainer = Instance.new("ScrollingFrame", Main)
TopTabContainer.Size = UDim2.new(1,-28,0,36); TopTabContainer.Position = UDim2.new(0,14,0,52)
TopTabContainer.BackgroundTransparency = 1; TopTabContainer.BorderSizePixel = 0; TopTabContainer.ScrollBarThickness = 0; TopTabContainer.ZIndex = 16
TopTabContainer.CanvasSize = UDim2.new(0,900,0,0)
local TTLL = Instance.new("UIListLayout", TopTabContainer)
TTLL.FillDirection = Enum.FillDirection.Horizontal; TTLL.Padding = UDim.new(0,6); TTLL.VerticalAlignment = Enum.VerticalAlignment.Center
local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1,-28,1,-106); Content.Position = UDim2.new(0,14,0,96)
Content.BackgroundTransparency = 1; Content.ZIndex = 15

local tabs = {}
local function CreateTab(name)
    local idx = #tabs + 1
    local btn = Instance.new("TextButton", TopTabContainer)
    btn.Size = UDim2.new(0,80,0,32); btn.BackgroundColor3 = Theme.Glass
    btn.BackgroundTransparency = 1; btn.Text = name
    btn.TextColor3 = Theme.TextDim; btn.Font = Font_Bold; btn.TextSize = 11
    btn.BorderSizePixel = 0; btn.AutoButtonColor = false; btn.ZIndex = 17
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    local ind = Instance.new("Frame", btn)
    ind.Size = UDim2.new(0.8,0,0,3); ind.Position = UDim2.new(0.1,0,1,-4)
    ind.BackgroundColor3 = Theme.Accent; ind.BorderSizePixel = 0; ind.Visible = false; ind.ZIndex = 18
    Instance.new("UICorner", ind).CornerRadius = UDim.new(1,0)
    local page = Instance.new("ScrollingFrame", Content)
    page.Size = UDim2.new(1,0,1,0); page.BackgroundTransparency = 1; page.BorderSizePixel = 0
    page.ScrollBarThickness = 3; page.ScrollBarImageColor3 = Theme.Accent; page.ScrollBarImageTransparency = 0.4
    page.Visible = false; page.ZIndex = 16
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y; page.CanvasSize = UDim2.new(0,0,0,0)
    local pl = Instance.new("UIListLayout", page); pl.Padding = UDim.new(0,8); pl.SortOrder = Enum.SortOrder.LayoutOrder
    local pp = Instance.new("UIPadding", page)
    pp.PaddingTop = UDim.new(0,4); pp.PaddingBottom = UDim.new(0,12); pp.PaddingLeft = UDim.new(0,4); pp.PaddingRight = UDim.new(0,4)
    table.insert(tabs, {btn=btn, page=page, ind=ind, idx=idx})
    btn.MouseEnter:Connect(function() if not ind.Visible then TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency=0.7, TextColor3=Theme.Text}):Play() end end)
    btn.MouseLeave:Connect(function() if not ind.Visible then TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency=1, TextColor3=Theme.TextDim}):Play() end end)
    btn.MouseButton1Click:Connect(function()
        for i, t in ipairs(tabs) do
            t.page.Visible = (i == idx); t.ind.Visible = (i == idx)
            if i == idx then TweenService:Create(t.btn, TweenInfo.new(0.2), {BackgroundTransparency=0.5, TextColor3=Theme.Text}):Play()
            else TweenService:Create(t.btn, TweenInfo.new(0.2), {BackgroundTransparency=1, TextColor3=Theme.TextDim}):Play() end
        end
    end)
    return page
end

local function Section(parent, text)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1,0,0,24); lbl.BackgroundTransparency = 1
    lbl.Text = text; lbl.TextColor3 = Theme.Accent; lbl.Font = Font_Bold; lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 17
    Instance.new("UIPadding", lbl).PaddingLeft = UDim.new(0,4)
end

local function Toggle(parent, text, path, cb)
    local default = K.GetSetting(path) or false
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1,0,0,40); frame.BackgroundColor3 = Theme.Glass
    frame.BackgroundTransparency = 0.1; frame.BorderSizePixel = 0; frame.ZIndex = 17
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)
    local fs = Instance.new("UIStroke", frame); fs.Color = Theme.TextDim; fs.Thickness = 1; fs.Transparency = 0.8
    local accentBar = Instance.new("Frame", frame)
    accentBar.Size = UDim2.new(0,3,0.6,0); accentBar.Position = UDim2.new(0,6,0.2,0)
    accentBar.BackgroundColor3 = Theme.Accent; accentBar.BorderSizePixel = 0; accentBar.ZIndex = 18
    Instance.new("UICorner", accentBar).CornerRadius = UDim.new(1,0)
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1,-80,1,0); label.Position = UDim2.new(0,18,0,0)
    label.BackgroundTransparency = 1; label.Text = text; label.TextColor3 = Theme.Text
    label.Font = Font_Main; label.TextSize = 13; label.TextXAlignment = Enum.TextXAlignment.Left; label.ZIndex = 18
    local track = Instance.new("Frame", frame)
    track.Size = UDim2.new(0,44,0,22); track.Position = UDim2.new(1,-58,0.5,-11)
    track.BackgroundColor3 = default and Theme.Accent or Theme.GlassLight; track.BorderSizePixel = 0; track.ZIndex = 18
    Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)
    local dot = Instance.new("Frame", track)
    dot.Size = UDim2.new(0,16,0,16)
    dot.Position = default and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
    dot.BackgroundColor3 = Color3.fromRGB(255,255,255); dot.BorderSizePixel = 0; dot.ZIndex = 19
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 20
    local state = default
    local function setV(v)
        state = v
        TweenService:Create(track, TweenInfo.new(0.2), {BackgroundColor3=v and Theme.Accent or Theme.GlassLight}):Play()
        TweenService:Create(dot, TweenInfo.new(0.2), {Position=v and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)}):Play()
    end
    btn.MouseButton1Click:Connect(function() setV(not state); K.SetSetting(path, state); if cb then cb(state) end end)
    table.insert(K.UIControls, {path=path, setter=setV})
end

local function Slider(parent, text, min, max, path, cb)
    local default = K.GetSetting(path) or min
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1,0,0,50); frame.BackgroundColor3 = Theme.Glass
    frame.BackgroundTransparency = 0.1; frame.BorderSizePixel = 0; frame.ZIndex = 17
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)
    local fs = Instance.new("UIStroke", frame); fs.Color = Theme.TextDim; fs.Thickness = 1; fs.Transparency = 0.8
    local accentBar = Instance.new("Frame", frame)
    accentBar.Size = UDim2.new(0,3,0.6,0); accentBar.Position = UDim2.new(0,6,0.2,0)
    accentBar.BackgroundColor3 = Theme.Accent; accentBar.BorderSizePixel = 0; accentBar.ZIndex = 18
    Instance.new("UICorner", accentBar).CornerRadius = UDim.new(1,0)
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1,-110,0,18); label.Position = UDim2.new(0,18,0,6)
    label.BackgroundTransparency = 1; label.Text = text; label.TextColor3 = Theme.Text
    label.Font = Font_Main; label.TextSize = 13; label.TextXAlignment = Enum.TextXAlignment.Left; label.ZIndex = 18
    local valLbl = Instance.new("TextLabel", frame)
    valLbl.Size = UDim2.new(0,80,0,18); valLbl.Position = UDim2.new(1,-96,0,6)
    valLbl.BackgroundTransparency = 1; valLbl.Text = string.format("%.2f", default)
    valLbl.TextColor3 = Theme.Accent; valLbl.Font = Font_Bold; valLbl.TextSize = 12
    valLbl.TextXAlignment = Enum.TextXAlignment.Right; valLbl.ZIndex = 18
    local bar = Instance.new("Frame", frame)
    bar.Size = UDim2.new(1,-32,0,4); bar.Position = UDim2.new(0,16,0,36)
    bar.BackgroundColor3 = Theme.GlassLight; bar.BorderSizePixel = 0; bar.ZIndex = 18
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = Theme.Accent; fill.BorderSizePixel = 0; fill.ZIndex = 19
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
    local glowDot = Instance.new("Frame", fill)
    glowDot.Size = UDim2.new(0,12,0,12); glowDot.Position = UDim2.new(1,-6,0.5,-6)
    glowDot.BackgroundColor3 = Color3.new(1,1,1); glowDot.BorderSizePixel = 0; glowDot.ZIndex = 20
    Instance.new("UICorner", glowDot).CornerRadius = UDim.new(1,0)
    local gs = Instance.new("UIStroke", glowDot); gs.Color = Theme.Accent; gs.Thickness = 2; gs.Transparency = 0.5
    local dragging = false
    local function apply(v)
        local pct = math.clamp((v-min)/(max-min), 0, 1)
        fill.Size = UDim2.new(pct,0,1,0); valLbl.Text = string.format("%.2f", v)
        K.SetSetting(path, v); if cb then cb(v) end
    end
    local function update(i)
        local pct = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        apply(min + (max-min)*pct)
    end
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update(i) end end)
    UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    table.insert(K.UIControls, {path=path, setter=apply})
end

local function Button(parent, text, cb)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1,0,0,38); btn.BackgroundColor3 = Theme.Glass
    btn.BackgroundTransparency = 0.1; btn.Text = text; btn.TextColor3 = Theme.Accent
    btn.Font = Font_Bold; btn.TextSize = 13; btn.BorderSizePixel = 0; btn.AutoButtonColor = false; btn.ZIndex = 17
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    local bs = Instance.new("UIStroke", btn); bs.Color = Theme.Accent; bs.Thickness = 1; bs.Transparency = 0.6
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency=0.3}):Play(); TweenService:Create(bs, TweenInfo.new(0.15), {Transparency=0.2}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency=0.1}):Play(); TweenService:Create(bs, TweenInfo.new(0.15), {Transparency=0.6}):Play() end)
    btn.MouseButton1Click:Connect(function() if cb then pcall(cb) end end)
end

local function ColorPicker(parent, text, cb)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1,0,0,50); frame.BackgroundColor3 = Theme.Glass
    frame.BackgroundTransparency = 0.1; frame.BorderSizePixel = 0; frame.ZIndex = 17
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)
    local fs = Instance.new("UIStroke", frame); fs.Color = Theme.TextDim; fs.Thickness = 1; fs.Transparency = 0.8
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1,-28,0,18); label.Position = UDim2.new(0,16,0,6)
    label.BackgroundTransparency = 1; label.Text = text; label.TextColor3 = Theme.Text
    label.Font = Font_Main; label.TextSize = 13; label.TextXAlignment = Enum.TextXAlignment.Left; label.ZIndex = 18
    local row = Instance.new("Frame", frame)
    row.Size = UDim2.new(1,-28,0,20); row.Position = UDim2.new(0,16,0,24)
    row.BackgroundTransparency = 1; row.ZIndex = 18
    local rl = Instance.new("UIListLayout", row); rl.FillDirection = Enum.FillDirection.Horizontal; rl.Padding = UDim.new(0,8)
    for _, c in ipairs({Color3.fromRGB(120,180,255), Color3.fromRGB(255,90,110), Color3.fromRGB(80,230,150),
                        Color3.fromRGB(255,220,80), Color3.fromRGB(180,100,255), Color3.fromRGB(255,255,255)}) do
        local b = Instance.new("TextButton", row)
        b.Size = UDim2.new(0,20,0,20); b.BackgroundColor3 = c; b.Text = ""; b.BorderSizePixel = 0; b.ZIndex = 19
        Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)
        b.MouseButton1Click:Connect(function() cb(c) end)
    end
end

local function Keybind(parent, text, currentKey, cb)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1,0,0,40); frame.BackgroundColor3 = Theme.Glass
    frame.BackgroundTransparency = 0.1; frame.BorderSizePixel = 0; frame.ZIndex = 17
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)
    local fs = Instance.new("UIStroke", frame); fs.Color = Theme.TextDim; fs.Thickness = 1; fs.Transparency = 0.8
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1,-120,1,0); label.Position = UDim2.new(0,16,0,0)
    label.BackgroundTransparency = 1; label.Text = text; label.TextColor3 = Theme.Text
    label.Font = Font_Main; label.TextSize = 13; label.TextXAlignment = Enum.TextXAlignment.Left; label.ZIndex = 18
    local function ks(k)
        if not k then return "?" end
        if typeof(k) == "EnumItem" then return k.Name else return tostring(k):gsub("Enum.UserInputType.", "") end
    end
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0,90,0,26); btn.Position = UDim2.new(1,-102,0.5,-13)
    btn.BackgroundColor3 = Theme.GlassLight; btn.BackgroundTransparency = 0.2
    btn.Text = ks(currentKey); btn.TextColor3 = Theme.Accent; btn.Font = Font_Bold
    btn.TextSize = 11; btn.BorderSizePixel = 0; btn.AutoButtonColor = false; btn.ZIndex = 19
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    local listening = false
    btn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true; btn.Text = "..."
        local conn
        conn = UIS.InputBegan:Connect(function(input, gpe)
            if gpe or input.UserInputType == Enum.UserInputType.MouseMovement then return end
            conn:Disconnect(); listening = false
            local nk = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or input.UserInputType
            btn.Text = ks(nk); cb(nk)
        end)
    end)
end

local function AimModeSelector(parent)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1,0,0,56); frame.BackgroundColor3 = Theme.Glass
    frame.BackgroundTransparency = 0.1; frame.BorderSizePixel = 0; frame.ZIndex = 17
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)
    local fs = Instance.new("UIStroke", frame); fs.Color = Theme.Accent; fs.Thickness = 1; fs.Transparency = 0.6
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1,-20,0,16); lbl.Position = UDim2.new(0,16,0,6)
    lbl.BackgroundTransparency = 1; lbl.Text = "Режим Аима"; lbl.TextColor3 = Theme.Accent
    lbl.Font = Font_Bold; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 18
    local row = Instance.new("Frame", frame)
    row.Size = UDim2.new(1,-20,0,24); row.Position = UDim2.new(0,16,0,24)
    row.BackgroundTransparency = 1; row.ZIndex = 18
    local rl = Instance.new("UIListLayout", row); rl.FillDirection = Enum.FillDirection.Horizontal; rl.Padding = UDim.new(0,4)
    local modes = {"Hold", "Toggle", "AlwaysOn"}
    local labels = {Hold="Держать", Toggle="Тоггл", AlwaysOn="Всегда ВКЛ"}
    local btns = {}
    for _, mode in ipairs(modes) do
        local b = Instance.new("TextButton", row)
        b.Size = UDim2.new(0,110,1,0); b.BackgroundColor3 = Theme.GlassLight; b.BackgroundTransparency = 0.3
        b.Text = labels[mode]; b.TextColor3 = Theme.TextDim; b.Font = Font_Bold; b.TextSize = 10
        b.BorderSizePixel = 0; b.AutoButtonColor = false; b.ZIndex = 19
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
        btns[mode] = b
        b.MouseButton1Click:Connect(function()
            Settings.Aimbot.AimMode = mode
            for m, btn in pairs(btns) do
                if m == mode then btn.BackgroundColor3 = Theme.Accent; btn.TextColor3 = Theme.Text; btn.BackgroundTransparency = 0
                else btn.BackgroundColor3 = Theme.GlassLight; btn.TextColor3 = Theme.TextDim; btn.BackgroundTransparency = 0.3 end
            end
        end)
    end
    local cur = Settings.Aimbot.AimMode or "Hold"
    if btns[cur] then btns[cur].BackgroundColor3 = Theme.Accent; btns[cur].TextColor3 = Theme.Text; btns[cur].BackgroundTransparency = 0 end
end

-- ================= ВКЛАДКИ =================
local pCombat = CreateTab("Бой")
local pVisual = CreateTab("Визуал")
local pWorld = CreateTab("Снаряды")
local pUtils = CreateTab("Утилиты")
local pSec = CreateTab("Защита")
local pCam = CreateTab("Камера")
local pKeys = CreateTab("Бинды")
local pFun = CreateTab("Приколы")

if #tabs > 0 then tabs[1].page.Visible = true; tabs[1].ind.Visible = true; tabs[1].btn.BackgroundTransparency = 0.5; tabs[1].btn.TextColor3 = Theme.Text end

Section(pCombat, "Аимбот")
Toggle(pCombat, "Вкл Аимбот", "Aimbot.Enabled")
AimModeSelector(pCombat)
Toggle(pCombat, "Ignore Friends", "Aimbot.IgnoreFriends")
Toggle(pCombat, "Only Armed", "Aimbot.OnlyArmed")
Toggle(pCombat, "MultiPointVis", "Aimbot.MultiPointVis")
Toggle(pCombat, "Snap Aim", "Aimbot.SnapAim")
Toggle(pCombat, "Сайлент Аим", "Aimbot.SilentAim")
Toggle(pCombat, "Проверка стен (Silent)", "Aimbot.SilentWallCheck")
Toggle(pCombat, "Wall Check (Camera)", "Aimbot.WallCheck")
Toggle(pCombat, "Целиться в Тело", "Aimbot.AimAtBody")
Toggle(pCombat, "Гуманизация (jitter)", "Aimbot.Humanize")
Slider(pCombat, "Сила jitter (°)", 0, 2, "Aimbot.Jitter")
Slider(pCombat, "FOV", 50, 600, "Aimbot.FOV")
Slider(pCombat, "Плавность", 0.05, 1, "Aimbot.Smoothness")
Slider(pCombat, "Предсказание", 0, 0.3, "Aimbot.Prediction")
Slider(pCombat, "Макс. дистанция", 100, 2000, "Aimbot.MaxDistance")

Section(pCombat, "Оружие")
Toggle(pCombat, "Без Отдачи", "Combat.NoRecoil")
Toggle(pCombat, "Без Разброса", "Combat.NoSpread")
Toggle(pCombat, "Магнит Снарядов", "Combat.ProjMagnet")
Toggle(pCombat, "Вкл Триггер Бот", "Combat.TriggerBot")

Section(pVisual, "Player ESP")
Toggle(pVisual, "Вкл ESP", "ESP.Enabled")
Toggle(pVisual, "Квадраты", "ESP.Box")
Toggle(pVisual, "Ники", "ESP.Name")
Toggle(pVisual, "Оружие", "ESP.Weapon")
Toggle(pVisual, "Здоровье (полоска)", "ESP.Health")
Toggle(pVisual, "Здоровье (цифра)", "ESP.HealthNum")
Toggle(pVisual, "Скелет", "ESP.Skeleton")
Toggle(pVisual, "Подсветка", "ESP.Highlight")
Toggle(pVisual, "Трейсеры", "ESP.Tracer")
Toggle(pVisual, "Показывать NPC", "ESP.ShowNPCs")
Slider(pVisual, "Дистанция", 50, 2000, "ESP.MaxDist")
Slider(pVisual, "Прозрачность", 0, 1, "ESP.ChamsTransparency")
ColorPicker(pVisual, "Цвет ESP", function(c) Settings.ESP.Color = {math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255)} end)

Section(pWorld, "Освещение и Мир")
Toggle(pWorld, "Фикс Ночи", "World.Fullbright")
Toggle(pWorld, "Убрать Туман", "World.NoFog")
Toggle(pWorld, "Performance Mode", "World.PerformanceMode")

Section(pUtils, "Хитбоксы (Fixed)")
Toggle(pUtils, "Большие Головы", "Utils.HeadExpander")
Slider(pUtils, "Размер Головы", 1, 8, "Utils.HeadSize")
Toggle(pUtils, "Большой Торс", "Utils.TorsoExpander")
Slider(pUtils, "Размер Торса", 1, 8, "Utils.TorsoSize")

Section(pSec, "Защита")
Toggle(pSec, "Кто смотрит", "Security.ObserverAlert")
Toggle(pSec, "Anti-AFK (VirtualUser)", "Security.AntiAFK")

Section(pCam, "Камера")
Slider(pCam, "Обычный FOV", 50, 120, "Camera.DefaultFOV", function(v) if not K.Zooming then K.Camera.FieldOfView = v end end)
Slider(pCam, "FOV Зума", 10, 120, "Camera.ZoomFOV", function(v) if K.Zooming then K.Camera.FieldOfView = v end end)
Keybind(pCam, "Кнопка Зума", Settings.Camera.ZoomKey, function(k) Settings.Camera.ZoomKey = k end)

Section(pKeys, "Бинды")
Keybind(pKeys, "Кнопка Аима", Settings.Aimbot.Key, function(k) Settings.Aimbot.Key = k end)
Keybind(pKeys, "Panic Key", Settings.Keybinds.Panic, function(k) Settings.Keybinds.Panic = k end)

Section(pFun, "Приколы")
Toggle(pFun, "Hitmarker", "Fun.Hitmarker")
Toggle(pFun, "Kill-сообщения", "Fun.KillMessages")

-- Перетаскивание окна
local dragging, dragStart, startPos, glowStart
TitleBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = i.Position; startPos = Main.Position; glowStart = GlowBorder.Position end end)
UIS.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
        GlowBorder.Position = UDim2.new(glowStart.X.Scale, glowStart.X.Offset+d.X, glowStart.Y.Scale, glowStart.Y.Offset+d.Y)
    end
end)
UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- Открытие/Закрытие
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F4 then
        if K.MenuOpen then closeMenu() else openMenu() end
    end
    if K.MatchesKeybind(input, Settings.Camera.ZoomKey) and Settings.Camera.ZoomFOV ~= Settings.Camera.DefaultFOV then
        K.Zooming = true; K.Camera.FieldOfView = Settings.Camera.ZoomFOV
    end
    if K.MatchesKeybind(input, Settings.Keybinds.Panic) then
        Settings.ESP.Enabled = false; Settings.Aimbot.Enabled = false; Settings.Aimbot.SilentAim = false
        Settings.Combat.TriggerBot = false; Settings.Combat.ProjMagnet = false
        K.Aiming = false; K.CurrentAimCFrame = nil
        K.Notify("PANIC", "Всё выключено", true)
    end
end)
UIS.InputEnded:Connect(function(input)
    if K.MatchesKeybind(input, Settings.Camera.ZoomKey) then
        K.Zooming = false; K.Camera.FieldOfView = Settings.Camera.DefaultFOV
    end
end)

-- Статы
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            UITime.Text = os.date("%H:%M:%S")
            UIFps.Text = "FPS: " .. math.floor(K.FPS)
            local pi = Stats.Network.ServerStatsItem:FindFirstChild("Data Ping")
            if pi then UIPing.Text = "PING: " .. math.floor(pi:GetValue()) .. "ms" end
            UIUser.Text = K.LP.Name
            local nc = 0
            for _, t in ipairs(K.CachedTargets) do if t.hrp and t.hrp.Parent and t.type == "P" then nc = nc + 1 end end
            UIPlayers.Text = "NEAR: " .. nc
            
            local m = Settings.Aimbot.AimMode or "?"
            local k = Settings.Aimbot.Key and Settings.Aimbot.Key.Name or "?"
            ModeLabel.Text = "AIM " .. m .. " [" .. k .. "] " .. (K.Aiming and "●" or "○")
            ModeLabel.TextColor3 = K.Aiming and Theme.Green or Theme.TextDim
        end)
    end
end)

-- ================= ФИКС МЫШКИ ДЛЯ МЕНЮ =================
RunService.RenderStepped:Connect(function()
    if K.MenuOpen then
        if UIS.MouseBehavior ~= Enum.MouseBehavior.Default then
            UIS.MouseBehavior = Enum.MouseBehavior.Default
        end
        if not UIS.MouseIconEnabled then
            UIS.MouseIconEnabled = true
        end
    end
end)

K.Loading = false
StatusBar.Visible = true
openMenu()
task.delay(0.5, function() K.Notify("KIRO v18.1", "Успешно загружен! F4 - меню", false) end)
print("[KIRO UI] Загружено (FULL).")
