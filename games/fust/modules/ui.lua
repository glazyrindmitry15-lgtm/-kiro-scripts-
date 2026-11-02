-- =====================================================================
-- KIRO HACK | UI MODULE (FULL - FUST)
-- =====================================================================
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

local parentGui = gethui and gethui() or game:GetService("CoreGui")
for _, v in pairs(parentGui:GetChildren()) do
    if v.Name == "KiroUI" or (v:IsA("ScreenGui") and v.DisplayOrder == 99999) then v:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KiroUI_" .. HttpService:GenerateGUID(false)
ScreenGui.ResetOnSpawn = false; ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global; ScreenGui.DisplayOrder = 99999; ScreenGui.Parent = parentGui
K.ScreenGui = ScreenGui

-- Уведомления
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

-- Главное окно (Сокращено для читаемости, но код полный)
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
    TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size=UDim2.new(0,740,0,500), Position=UDim2.new(0.5,-370,0.5,-250), BackgroundTransparency=1}):Play()
    task.delay(0.25, function() if not K.MenuOpen then Main.Visible = false end end)
end
local function openMenu()
    K.MenuOpen = true; K.Zooming = false
    if Settings.Aimbot.AimMode == "Hold" then K.Aiming = false end
    Main.Visible = true
    Main.Size = UDim2.new(0,740,0,500); Main.Position = UDim2.new(0.5,-370,0.5,-250); Main.BackgroundTransparency = 1
    TweenService:Create(Main, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=UDim2.new(0,780,0,540), Position=UDim2.new(0.5,-390,0.5,-270), BackgroundTransparency=0.02}):Play()
end
CloseBtn.MouseButton1Click:Connect(closeMenu)
MinBtn.MouseButton1Click:Connect(closeMenu)

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
    table.insert(tabs, {btn=btn, page=page, ind=ind, idx=idx})
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
end

local function Toggle(parent, text, path)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1,0,0,36); btn.BackgroundColor3 = Theme.Glass; btn.Text = ""; btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1,-60,1,0); lbl.Position = UDim2.new(0,12,0,0); lbl.Text = text; lbl.TextXAlignment = Enum.TextXAlignment.Left
    local state = K.GetSetting(path) or false
    local track = Instance.new("Frame", btn); track.Size = UDim2.new(0,36,0,18); track.Position = UDim2.new(1,-46,0.5,-9)
    track.BackgroundColor3 = state and Theme.Accent or Theme.GlassLight; Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)
    local dot = Instance.new("Frame", track); dot.Size = UDim2.new(0,14,0,14); dot.Position = state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)
    dot.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
    btn.MouseButton1Click:Connect(function()
        state = not state; K.SetSetting(path, state)
        TweenService:Create(track, TweenInfo.new(0.15), {BackgroundColor3=state and Theme.Accent or Theme.GlassLight}):Play()
        TweenService:Create(dot, TweenInfo.new(0.15), {Position=state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)}):Play()
    end)
end

local function Slider(parent, text, min, max, path)
    local frame = Instance.new("Frame", parent); frame.Size = UDim2.new(1,0,0,46); frame.BackgroundColor3 = Theme.Glass
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)
    local lbl = Instance.new("TextLabel", frame); lbl.Size = UDim2.new(1,-20,0,18); lbl.Position = UDim2.new(0,12,0,4); lbl.Text = text
    local val = Instance.new("TextLabel", frame); val.Size = UDim2.new(0,50,0,18); val.Position = UDim2.new(1,-60,0,4); val.Text = tostring(K.GetSetting(path))
    local bar = Instance.new("Frame", frame); bar.Size = UDim2.new(1,-24,0,4); bar.Position = UDim2.new(0,12,0,30); bar.BackgroundColor3 = Theme.GlassLight
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((K.GetSetting(path)-min)/(max-min),0,1,0); fill.BackgroundColor3 = Theme.Accent
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
    local drag = false
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
    UIS.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local p = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local v = math.floor((min + (max-min)*p) * 100) / 100
            fill.Size = UDim2.new(p,0,1,0); val.Text = tostring(v); K.SetSetting(path, v)
        end
    end)
end

-- ============ ВКЛАДКИ (FUST) ============
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
Toggle(pCombat, "Сайлент Аим", "Aimbot.SilentAim")
Toggle(pCombat, "Wall Check", "Aimbot.WallCheck")
Toggle(pCombat, "Целиться в Тело", "Aimbot.AimAtBody")
Slider(pCombat, "FOV", 50, 600, "Aimbot.FOV")
Slider(pCombat, "Плавность", 0.05, 1, "Aimbot.Smoothness")
Section(pCombat, "Оружие")
Toggle(pCombat, "Вкл Триггер Бот", "Combat.TriggerBot")

Section(pVisual, "Player ESP")
Toggle(pVisual, "Вкл ESP", "ESP.Enabled")
Toggle(pVisual, "Квадраты", "ESP.Box")
Toggle(pVisual, "Ники", "ESP.Name")
Toggle(pVisual, "Здоровье", "ESP.Health")
Toggle(pVisual, "Скелет", "ESP.Skeleton")
Slider(pVisual, "Дистанция", 50, 2000, "ESP.MaxDist")

Section(pWorld, "Освещение")
Toggle(pWorld, "Фикс Ночи", "World.Fullbright")
Toggle(pWorld, "Убрать Туман", "World.NoFog")

Section(pUtils, "Хитбоксы")
Toggle(pUtils, "Большие Головы", "Utils.HeadExpander")
Slider(pUtils, "Размер Головы", 1, 8, "Utils.HeadSize")

Section(pSec, "Защита")
Toggle(pSec, "Кто смотрит", "Security.ObserverAlert")
Toggle(pSec, "Anti-AFK", "Security.AntiAFK")

Section(pFun, "Приколы")
Toggle(pFun, "Hitmarker", "Fun.Hitmarker")
Toggle(pFun, "Kill-сообщения", "Fun.KillMessages")

-- Открытие
local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = i.Position; startPos = Main.Position end end)
UIS.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
    end
end)
UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F4 then
        if K.MenuOpen then closeMenu() else openMenu() end
    end
end)

RunService.RenderStepped:Connect(function()
    if K.MenuOpen then
        if UIS.MouseBehavior ~= Enum.MouseBehavior.Default then UIS.MouseBehavior = Enum.MouseBehavior.Default end
        if not UIS.MouseIconEnabled then UIS.MouseIconEnabled = true end
    end
end)

K.Loading = false
openMenu()
task.delay(0.5, function() K.Notify("KIRO FUST", "Загружено! F4 - меню", false) end)
