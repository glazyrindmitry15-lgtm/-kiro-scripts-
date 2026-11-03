-- =====================================================================
-- KIRO UI | Frozen Style (Full Featured)
-- =====================================================================
local K = shared.KIRO
if not K then return end
if not K.GetSetting then K.GetSetting = function(path) return nil end end
if not K.SetSetting then K.SetSetting = function(path, v) end end
if not K.Notify then K.Notify = function(title, text, ntype) end end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer

local Theme = {
    BG = Color3.fromRGB(12, 15, 22),
    Sidebar = Color3.fromRGB(18, 22, 33),
    Component = Color3.fromRGB(28, 34, 48),
    ComponentHover = Color3.fromRGB(38, 45, 62),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(150, 160, 180),
    Accent = Color3.fromRGB(99, 102, 241),
    Accent2 = Color3.fromRGB(139, 92, 246),
    Red = Color3.fromRGB(239, 68, 68),
    Green = Color3.fromRGB(34, 197, 94),
    Orange = Color3.fromRGB(255, 165, 0),
    Border = Color3.fromRGB(40, 46, 62),
    Gold = Color3.fromRGB(255, 200, 80)
}

local FontMain = Enum.Font.GothamMedium
local FontBold = Enum.Font.GothamBold
local FontBlack = Enum.Font.GothamBlack

-- Language support
local Lang = (K.Settings and K.Settings.Language) or "ru"
local Translations = {
    ru = {
        visual = "Визуал", combat = "Бой", misc = "Миск", extra = "Доп", settings = "Настройки",
        esp_enabled = "ESP Вкл", boxes = "Боксы", names = "Ники", health = "Здоровье",
        distance = "Дистанция", teamcheck = "TeamCheck", aimbot = "Аимбот",
        drawfov = "FOV круг", wallcheck = "Wall Check", triggerbot = "Триггербот",
        bhop = "Баннихоп", speed = "Скорость", fly = "Полёт", noclip = "Ноклип",
        fullbright = "Фуллбрайт", noflash = "Без вспышки", antiafk = "Анти-АФК",
        save = "Сохранить", load = "Загрузить", close = "Закрыть",
    },
    en = {
        visual = "Visual", combat = "Combat", misc = "Misc", extra = "Extra", settings = "Settings",
        esp_enabled = "ESP On", boxes = "Boxes", names = "Names", health = "Health",
        distance = "Distance", teamcheck = "TeamCheck", aimbot = "Aimbot",
        drawfov = "Draw FOV", wallcheck = "Wall Check", triggerbot = "Triggerbot",
        bhop = "Bunnyhop", speed = "Speed", fly = "Fly", noclip = "Noclip",
        fullbright = "Fullbright", noflash = "No Flash", antiafk = "Anti-AFK",
        save = "Save", load = "Load", close = "Close",
    },
    ar = {
        visual = "بصري", combat = "قتال", misc = "متفرقات", extra = "إضافي", settings = "إعدادات",
        esp_enabled = "ESP تشغيل", boxes = "صناديق", names = "أسماء", health = "صحة",
        distance = "مسافة", teamcheck = "فحص فريق", aimbot = "تصويب تلقائي",
        drawfov = "رسم FOV", wallcheck = "فحص جدران", triggerbot = "إطلاق تلقائي",
        bhop = "قفز أرنب", speed = "سرعة", fly = "طيران", noclip = "لا تصادم",
        fullbright = "إضاءة كاملة", noflash = "لا وميض", antiafk = "مناهض AFK",
        save = "حفظ", load = "تحميل", close = "إغلاق",
    },
}
local function T(key) return (Translations[Lang] and Translations[Lang][key]) or key end

local function gs(path)
    local v = K.GetSetting(path)
    if v == nil then return false end
    return v
end

-- blur
local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting

-- parent gui
local parentGui = gethui and gethui() or game:GetService("CoreGui")
for _, v in pairs(parentGui:GetChildren()) do
    if v.Name == "KiroCheatUI" then v:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KiroCheatUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.DisplayOrder = 99999
ScreenGui.Parent = parentGui
K.ScreenGui = ScreenGui

-- ============ NOTIFICATIONS ============
local NotifyContainer = Instance.new("Frame", ScreenGui)
NotifyContainer.Size = UDim2.new(0, 300, 1, -100)
NotifyContainer.Position = UDim2.new(1, -310, 0, 60)
NotifyContainer.BackgroundTransparency = 1
NotifyContainer.ZIndex = 1000
local NL = Instance.new("UIListLayout", NotifyContainer)
NL.VerticalAlignment = Enum.VerticalAlignment.Top
NL.HorizontalAlignment = Enum.HorizontalAlignment.Right
NL.Padding = UDim.new(0, 8)

local function Notify(title, text, ntype)
    ntype = ntype or "info"
    local color = Theme.Accent
    if ntype == "success" then color = Theme.Green
    elseif ntype == "error" then color = Theme.Red
    elseif ntype == "warn" then color = Theme.Orange
    elseif ntype == "info" then color = Theme.Accent end

    local n = Instance.new("Frame", NotifyContainer)
    n.Size = UDim2.new(1, 0, 0, 60)
    n.BackgroundColor3 = Theme.Glass or Theme.Component
    n.BackgroundTransparency = 0.05
    n.BorderSizePixel = 0
    n.ClipsDescendants = true
    n.ZIndex = 1001
    Instance.new("UICorner", n).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", n)
    stroke.Color = color
    stroke.Thickness = 1
    stroke.Transparency = 0.4

    local acc = Instance.new("Frame", n)
    acc.Size = UDim2.new(0, 3, 0.6, 0)
    acc.Position = UDim2.new(0, 8, 0.2, 0)
    acc.BackgroundColor3 = color
    acc.BorderSizePixel = 0
    Instance.new("UICorner", acc).CornerRadius = UDim.new(1, 0)

    local t1 = Instance.new("TextLabel", n)
    t1.Size = UDim2.new(1, -24, 0, 18)
    t1.Position = UDim2.new(0, 16, 0, 8)
    t1.BackgroundTransparency = 1
    t1.Text = title
    t1.TextColor3 = color
    t1.Font = FontBold
    t1.TextSize = 13
    t1.TextXAlignment = Enum.TextXAlignment.Left
    t1.ZIndex = 1002

    local t2 = Instance.new("TextLabel", n)
    t2.Size = UDim2.new(1, -24, 0, 26)
    t2.Position = UDim2.new(0, 16, 0, 26)
    t2.BackgroundTransparency = 1
    t2.Text = text
    t2.TextColor3 = Theme.Text
    t2.Font = FontMain
    t2.TextSize = 11
    t2.TextWrapped = true
    t2.TextXAlignment = Enum.TextXAlignment.Left
    t2.ZIndex = 1002

    n.Position = UDim2.new(1, 0, 0, 0)
    TweenService:Create(n, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()

    task.delay(3, function()
        if n and n.Parent then
            TweenService:Create(n, TweenInfo.new(0.25), {BackgroundTransparency = 1, Position = UDim2.new(1, 0, 0, 0)}):Play()
            for _, c in ipairs(n:GetDescendants()) do
                if c:IsA("TextLabel") then TweenService:Create(c, TweenInfo.new(0.25), {TextTransparency = 1}):Play() end
                if c:IsA("UIStroke") then TweenService:Create(c, TweenInfo.new(0.25), {Transparency = 1}):Play() end
                if c:IsA("Frame") then TweenService:Create(c, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play() end
            end
            task.wait(0.3)
            if n and n.Parent then n:Destroy() end
        end
    end)
end

K.Notify = Notify

-- ============ MAIN WINDOW ============
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 600, 0, 420)
Main.Position = UDim2.new(0.5, -300, 0.5, -210)
Main.BackgroundColor3 = Theme.BG
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Visible = false
Main.Active = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Theme.Accent
MainStroke.Thickness = 1
MainStroke.Transparency = 0.5

local MainGrad = Instance.new("UIGradient", Main)
MainGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 20, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 10, 15))
}
MainGrad.Rotation = 135

-- snow inside menu (optimized, few particles)
local snowContainer = Instance.new("Frame", Main)
snowContainer.Size = UDim2.new(1, 0, 1, 0)
snowContainer.BackgroundTransparency = 1
snowContainer.ClipsDescendants = true
snowContainer.ZIndex = 0

local snowflakes = {}
task.spawn(function()
    while ScreenGui and ScreenGui.Parent do
        if Main.Visible and #snowflakes < 15 then
            local flake = Instance.new("Frame", snowContainer)
            flake.Size = UDim2.new(0, math.random(2, 3), 0, math.random(2, 3))
            flake.Position = UDim2.new(math.random() * 0.9 + 0.05, 0, -0.02, 0)
            flake.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            flake.BackgroundTransparency = 0.5
            flake.BorderSizePixel = 0
            flake.ZIndex = 0
            Instance.new("UICorner", flake).CornerRadius = UDim.new(1, 0)
            table.insert(snowflakes, flake)
        end
        for i = #snowflakes, 1, -1 do
            local f = snowflakes[i]
            if f and f.Parent then
                local p = f.Position
                local ny = p.Y.Scale + 0.002
                if ny > 1.02 then
                    f.Position = UDim2.new(math.random() * 0.9 + 0.05, 0, -0.02, 0)
                else
                    f.Position = UDim2.new(p.X.Scale + (math.random(-1, 1) * 0.0003), 0, ny, 0)
                end
            else
                table.remove(snowflakes, i)
            end
        end
        task.wait(0.05)
    end
end)

-- ============ STATUS BAR (top) ============
local statusBar = Instance.new("Frame", Main)
statusBar.Size = UDim2.new(1, 0, 0, 22)
statusBar.Position = UDim2.new(0, 0, 0, 0)
statusBar.BackgroundColor3 = Theme.Component
statusBar.BorderSizePixel = 0
statusBar.ZIndex = 5

local statusFix = Instance.new("Frame", statusBar)
statusFix.Size = UDim2.new(1, 0, 0, 10)
statusFix.Position = UDim2.new(0, 0, 1, -10)
statusFix.BackgroundColor3 = Theme.Component
statusFix.BorderSizePixel = 0
statusFix.ZIndex = 5

local statusTitle = Instance.new("TextLabel", statusBar)
statusTitle.Size = UDim2.new(0, 100, 1, 0)
statusTitle.Position = UDim2.new(0, 8, 0, 0)
statusTitle.BackgroundTransparency = 1
statusTitle.Text = "KiroHack v" .. (K.Version or "1.2.0")
statusTitle.TextColor3 = Theme.Accent
statusTitle.Font = FontBlack
statusTitle.TextSize = 11
statusTitle.TextXAlignment = Enum.TextXAlignment.Left
statusTitle.ZIndex = 6

local statusTime = Instance.new("TextLabel", statusBar)
statusTime.Size = UDim2.new(0, 70, 1, 0)
statusTime.Position = UDim2.new(0, 110, 0, 0)
statusTime.BackgroundTransparency = 1
statusTime.Text = "00:00:00"
statusTime.TextColor3 = Theme.TextDim
statusTime.Font = Enum.Font.Code
statusTime.TextSize = 10
statusTime.TextXAlignment = Enum.TextXAlignment.Left
statusTime.ZIndex = 6

local statusNick = Instance.new("TextLabel", statusBar)
statusNick.Size = UDim2.new(0, 120, 1, 0)
statusNick.Position = UDim2.new(0, 185, 0, 0)
statusNick.BackgroundTransparency = 1
statusNick.Text = LP.Name
statusNick.TextColor3 = Theme.Text
statusNick.Font = FontBold
statusNick.TextSize = 10
statusNick.TextXAlignment = Enum.TextXAlignment.Left
statusNick.ZIndex = 6

local statusGame = Instance.new("TextLabel", statusBar)
statusGame.Size = UDim2.new(1, -310, 1, 0)
statusGame.Position = UDim2.new(0, 310, 0, 0)
statusGame.BackgroundTransparency = 1
statusGame.Text = tostring(K.GameId or "Unknown")
statusGame.TextColor3 = Theme.Accent
statusGame.Font = FontBold
statusGame.TextSize = 10
statusGame.TextXAlignment = Enum.TextXAlignment.Left
statusGame.ZIndex = 6

task.spawn(function()
    while ScreenGui and ScreenGui.Parent do
        statusTime.Text = os.date("%H:%M:%S")
        task.wait(1)
    end
end)

-- ============ SIDEBAR ============
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 150, 1, -22)
Sidebar.Position = UDim2.new(0, 0, 0, 22)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

local SidebarFix = Instance.new("Frame", Sidebar)
SidebarFix.Size = UDim2.new(0, 12, 1, 0)
SidebarFix.Position = UDim2.new(1, -12, 0, 0)
SidebarFix.BackgroundColor3 = Theme.Sidebar
SidebarFix.BorderSizePixel = 0

local Logo = Instance.new("TextLabel", Sidebar)
Logo.Size = UDim2.new(1, 0, 0, 40)
Logo.BackgroundTransparency = 1
Logo.Text = "KiroHack"
Logo.TextColor3 = Theme.Accent
Logo.Font = FontBlack
Logo.TextSize = 20
Logo.Position = UDim2.new(0, 0, 0, 8)

local GameLbl = Instance.new("TextLabel", Sidebar)
GameLbl.Size = UDim2.new(1, -10, 0, 14)
GameLbl.Position = UDim2.new(0, 5, 0, 44)
GameLbl.BackgroundTransparency = 1
GameLbl.Text = tostring(K.GameId or "Unknown")

local VersionLbl = Instance.new("TextLabel", Sidebar)
VersionLbl.Size = UDim2.new(1, -10, 0, 12)
VersionLbl.Position = UDim2.new(0, 5, 0, 60)
VersionLbl.BackgroundTransparency = 1
VersionLbl.Text = "v" .. (K.Version or "1.2.0")
VersionLbl.TextColor3 = Theme.TextDim
VersionLbl.Font = Enum.Font.Gotham
VersionLbl.TextSize = 9
VersionLbl.TextXAlignment = Enum.TextXAlignment.Center
GameLbl.TextColor3 = Theme.TextDim
GameLbl.Font = Enum.Font.Gotham
GameLbl.TextSize = 10
GameLbl.TextXAlignment = Enum.TextXAlignment.Center

local TabContainer = Instance.new("Frame", Sidebar)
TabContainer.Size = UDim2.new(1, -16, 1, -135)
TabContainer.Position = UDim2.new(0, 8, 0, 76)
TabContainer.BackgroundTransparency = 1
local tabList = Instance.new("UIListLayout", TabContainer)
tabList.Padding = UDim.new(0, 4)
tabList.SortOrder = Enum.SortOrder.LayoutOrder

-- player profile (bottom sidebar)
local profileFrame = Instance.new("Frame", Sidebar)
profileFrame.Size = UDim2.new(1, -16, 0, 50)
profileFrame.Position = UDim2.new(0, 8, 1, -58)
profileFrame.BackgroundColor3 = Theme.Component
profileFrame.BorderSizePixel = 0
Instance.new("UICorner", profileFrame).CornerRadius = UDim.new(0, 8)

local avatar = Instance.new("ImageLabel", profileFrame)
avatar.Size = UDim2.new(0, 36, 0, 36)
avatar.Position = UDim2.new(0, 6, 0.5, -18)
avatar.BackgroundColor3 = Theme.Glass
avatar.BorderSizePixel = 0
Instance.new("UICorner", avatar).CornerRadius = UDim.new(0, 6)
-- load avatar
task.spawn(function()
    local ok, img = pcall(function()
        return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    end)
    if ok and img then avatar.Image = img end
end)

local nameLabel = Instance.new("TextLabel", profileFrame)
nameLabel.Size = UDim2.new(1, -50, 0, 16)
nameLabel.Position = UDim2.new(0, 46, 0, 8)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = LP.Name
nameLabel.TextColor3 = Theme.Text
nameLabel.Font = FontBold
nameLabel.TextSize = 11
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.TextTruncate = Enum.TextTruncate.AtEnd

local idLabel = Instance.new("TextLabel", profileFrame)
idLabel.Size = UDim2.new(1, -50, 0, 12)
idLabel.Position = UDim2.new(0, 46, 0, 26)
idLabel.BackgroundTransparency = 1
idLabel.Text = "ID: " .. LP.UserId
idLabel.TextColor3 = Theme.TextDim
idLabel.Font = Enum.Font.Gotham
idLabel.TextSize = 9
idLabel.TextXAlignment = Enum.TextXAlignment.Left

-- ============ CONTENT AREA ============
local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, -170, 1, -60)
Content.Position = UDim2.new(0, 160, 0, 37)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = Theme.Accent
Content.ScrollBarImageTransparency = 0.4
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
local contentList = Instance.new("UIListLayout", Content)
contentList.Padding = UDim.new(0, 6)
contentList.SortOrder = Enum.SortOrder.LayoutOrder


-- ============ HELPERS ============
local pages = {}
local tabButtons = {}
local tabOrder = 0

local function CreateTab(name, key)
    tabOrder = tabOrder + 1
    local btn = Instance.new("TextButton", TabContainer)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Theme.Component
    btn.Text = name
    btn.TextColor3 = Theme.TextDim
    btn.Font = FontBold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.LayoutOrder = tabOrder
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local pad = Instance.new("UIPadding", btn)
    pad.PaddingLeft = UDim.new(0, 10)

    local page = Instance.new("Frame", Content)
    page.Size = UDim2.new(1, -10, 0, 0)
    page.AutomaticSize = Enum.AutomaticSize.Y
    page.BackgroundTransparency = 1
    page.Visible = false
    local pl = Instance.new("UIListLayout", page)
    pl.Padding = UDim.new(0, 4)
    pl.SortOrder = Enum.SortOrder.LayoutOrder

    pages[key] = page
    tabButtons[key] = btn

    btn.MouseButton1Click:Connect(function()
        for k, p in pairs(pages) do p.Visible = (k == key) end
        for k, b in pairs(tabButtons) do
            b.BackgroundColor3 = (k == key) and Theme.Accent or Theme.Component
            b.TextColor3 = (k == key) and Theme.Text or Theme.TextDim
        end
    end)
    btn.MouseEnter:Connect(function()
        if not pages[key].Visible then
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.ComponentHover}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if not pages[key].Visible then
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Component}):Play()
        end
    end)
    return page
end

local function AddSection(parent, text)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text = text:upper()
    lbl.TextColor3 = Theme.Accent
    lbl.Font = FontBold
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
end

local function AddToggle(parent, text, path)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Theme.Component
    btn.Text = ""
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, -46, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.Text
    lbl.Font = FontMain
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local sw = Instance.new("Frame", btn)
    sw.Size = UDim2.new(0, 30, 0, 14)
    sw.Position = UDim2.new(1, -38, 0.5, -7)
    sw.BackgroundColor3 = gs(path) and Theme.Accent or Color3.fromRGB(50, 55, 70)
    sw.BorderSizePixel = 0
    Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", sw)
    knob.Size = UDim2.new(0, 10, 0, 10)
    knob.Position = gs(path) and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local function refresh()
        local st = gs(path)
        TweenService:Create(sw, TweenInfo.new(0.15), {BackgroundColor3 = st and Theme.Accent or Color3.fromRGB(50, 55, 70)}):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {Position = st and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)}):Play()
        lbl.TextColor3 = st and Theme.Text or Theme.TextDim
    end

    btn.MouseButton1Click:Connect(function()
        K.SetSetting(path, not gs(path))
        refresh()
        if gs(path) then
            Notify(text, "Enabled", "success")
        else
            Notify(text, "Disabled", "info")
        end
    end)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.ComponentHover}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Component}):Play()
    end)
end

local function AddSlider(parent, text, min, max, path)
    local cur = K.GetSetting(path)
    if cur == nil then return end
    cur = tonumber(cur) or min

    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = Theme.Component
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, -16, 0, 16)
    lbl.Position = UDim2.new(0, 8, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.Text
    lbl.Font = FontMain
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local val = Instance.new("TextLabel", frame)
    val.Size = UDim2.new(0, 50, 0, 16)
    val.Position = UDim2.new(1, -58, 0, 4)
    val.BackgroundTransparency = 1
    val.Text = tostring(cur)
    val.TextColor3 = Theme.Accent
    val.Font = FontBold
    val.TextSize = 11
    val.TextXAlignment = Enum.TextXAlignment.Right

    local track = Instance.new("Frame", frame)
    track.Size = UDim2.new(1, -16, 0, 4)
    track.Position = UDim2.new(0, 8, 0, 26)
    track.BackgroundColor3 = Color3.fromRGB(50, 55, 70)
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", track)
    local rel = math.clamp((cur - min) / (max - min), 0, 1)
    fill.Size = UDim2.new(rel, 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local dragging = false
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local r = math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local v = math.floor((min + (max - min) * r) * 100) / 100
            K.SetSetting(path, v)
            val.Text = tostring(v)
            fill.Size = UDim2.new(r, 0, 1, 0)
        end
    end)
end

-- ============ TABS ============
local hasExtra = K.GetSetting("Skins") or K.GetSetting("ThirdPerson") or K.GetSetting("Teleport")
local pVisual = CreateTab("Visuals", "visual")
local pCombat = CreateTab(T("combat"), "combat")
local pMisc = CreateTab(T("misc"), "misc")
local pExtra = nil
if hasExtra then
    local tabName = "Extra"
    if K.GetSetting("Skins") then tabName = "Skins" end
    if K.GetSetting("Teleport") then tabName = "TP" end
    pExtra = CreateTab(tabName, "extra")
end

-- Visual
AddSection(pVisual, "ESP")
AddToggle(pVisual, "ESP Enabled", "ESP.Enabled")
AddToggle(pVisual, "Boxes", "ESP.Box")
AddToggle(pVisual, "Names", "ESP.Name")
AddToggle(pVisual, "Health", "ESP.Health")
AddToggle(pVisual, "Distance", "ESP.Distance")
if K.GetSetting("ESP.Weapon") ~= nil then AddToggle(pVisual, "Weapon", "ESP.Weapon") end
if K.GetSetting("ESP.Skeleton") ~= nil then AddToggle(pVisual, "Skeleton", "ESP.Skeleton") end
AddToggle(pVisual, "Team Check", "ESP.TeamCheck")
AddSlider(pVisual, "Max Distance", 100, 5000, "ESP.MaxDist")

-- Combat
AddSection(pCombat, "Aimbot")
AddToggle(pCombat, "Aimbot", "Aimbot.Enabled")
AddToggle(pCombat, "Draw FOV", "Aimbot.DrawFOV")
AddToggle(pCombat, "Wall Check", "Aimbot.VisibleOnly")
AddToggle(pCombat, "Team Check", "Aimbot.TeamCheck")
AddToggle(pCombat, "Silent Aim", "Aimbot.SilentAim")
AddSlider(pCombat, "FOV", 30, 500, "Aimbot.FOV")
AddSlider(pCombat, "Smoothness", 0.05, 1, "Aimbot.Smoothness")
if K.GetSetting("Combat") then
    AddSection(pCombat, "Combat")
    if K.GetSetting("Combat.TriggerBot") ~= nil then AddToggle(pCombat, "Triggerbot", "Combat.TriggerBot") end
    if K.GetSetting("Combat.NoRecoil") ~= nil then AddToggle(pCombat, "No Recoil", "Combat.NoRecoil") end
    if K.GetSetting("Combat.NoSpread") ~= nil then AddToggle(pCombat, "No Spread", "Combat.NoSpread") end
    if K.GetSetting("Combat.TriggerDelay") ~= nil then AddSlider(pCombat, "Trigger Delay", 0, 0.5, "Combat.TriggerDelay") end
end

-- Misc
AddSection(pMisc, "Movement")
AddToggle(pMisc, "Bunnyhop", "Misc.Bunnyhop")
AddToggle(pMisc, "Speed", "Misc.Speed")
AddToggle(pMisc, "Fly", "Misc.Fly")
AddToggle(pMisc, "Noclip", "Misc.Noclip")
AddToggle(pMisc, "Inf Jump", "Misc.InfiniteJump")
AddSection(pMisc, "Visual")
AddToggle(pMisc, "Fullbright", "Misc.Fullbright")
AddToggle(pMisc, "No-Flash", "Misc.NoFlash")
AddSection(pMisc, "Security")
AddToggle(pMisc, "Anti-AFK", "Security.AntiAFK")
if K.GetSetting("Utils.AutoBuy") ~= nil then AddToggle(pMisc, "Auto Buy", "Utils.AutoBuy") end
if K.GetSetting("Utils.AutoRepair") ~= nil then AddToggle(pMisc, "Auto Repair", "Utils.AutoRepair") end
if K.GetSetting("Utils.AutoSkillCheck") ~= nil then AddToggle(pMisc, "Auto Skill Check", "Utils.AutoSkillCheck") end
if K.GetSetting("Utils.AutoCollect") ~= nil then AddToggle(pMisc, "Auto Collect", "Utils.AutoCollect") end
AddToggle(pMisc, "Staff Detect", "Security.StaffDetect")

-- Extra
if pExtra then
    if K.GetSetting("Skins") then
        AddSection(pExtra, "Skins")
        AddToggle(pExtra, "Skin Changer", "Skins.Enabled")
    end
    if K.GetSetting("ThirdPerson") then
        AddSection(pExtra, "Third Person")
        AddToggle(pExtra, "Third Person", "ThirdPerson.Enabled")
        AddToggle(pExtra, "Char Preview", "ThirdPerson.Preview")
    end
    if K.GetSetting("Teleport") then
        AddSection(pExtra, "Teleport")
        AddToggle(pExtra, "Teleport (T)", "Teleport.Enabled")
    end
end

-- Config save/load
AddSection(pSettings, "Config")
local saveBtn = Instance.new("TextButton", pSettings)
saveBtn.Size = UDim2.new(1, 0, 0, 28)
saveBtn.BackgroundColor3 = Theme.Component
saveBtn.Text = "Save Config"
saveBtn.TextColor3 = Theme.Text
saveBtn.Font = FontBold
saveBtn.TextSize = 12
saveBtn.BorderSizePixel = 0
Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 6)
saveBtn.MouseButton1Click:Connect(function()
    if K.SaveConfig then K.SaveConfig() end
end)

local loadBtn = Instance.new("TextButton", pSettings)
loadBtn.Size = UDim2.new(1, 0, 0, 28)
loadBtn.BackgroundColor3 = Theme.Component
loadBtn.Text = "Load Config"
loadBtn.TextColor3 = Theme.Text
loadBtn.Font = FontBold
loadBtn.TextSize = 12
loadBtn.BorderSizePixel = 0
Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0, 6)
loadBtn.MouseButton1Click:Connect(function()
    if K.LoadConfig then K.LoadConfig() end
end)

-- activate first tab
local firstKey = nil
for k, _ in pairs(pages) do firstKey = k break end
if firstKey then
    pages[firstKey].Visible = true
    tabButtons[firstKey].BackgroundColor3 = Theme.Accent
    tabButtons[firstKey].TextColor3 = Theme.Text
end

-- ============ MENU SETTINGS (вкладка Settings) ============
local pSettings = CreateTab("Settings", "settings")
AddSection(pSettings, "Language")\nlocal langLbl = Instance.new("TextLabel", pSettings)\nlangLbl.Size = UDim2.new(1, 0, 0, 16)\nlangLbl.BackgroundTransparency = 1\nlangLbl.Text = "Language: " .. Lang\nlangLbl.TextColor3 = Theme.Text\nlangLbl.Font = FontMain\nlangLbl.TextSize = 12\nlangLbl.TextXAlignment = Enum.TextXAlignment.Left\n\nlocal langBtns = Instance.new("Frame", pSettings)\nlangBtns.Size = UDim2.new(1, 0, 0, 26)\nlangBtns.BackgroundTransparency = 1\nlocal lbl2 = Instance.new("UIListLayout", langBtns)\nlbl2.FillDirection = Enum.FillDirection.Horizontal\nlbl2.Padding = UDim.new(0, 6)\nfor _, l in ipairs({"ru", "en", "ar"}) do\n    local b = Instance.new("TextButton", langBtns)\n    b.Size = UDim2.new(0, 50, 0, 22)\n    b.BackgroundColor3 = (Lang == l) and Theme.Accent or Theme.Component\n    b.Text = l:upper()\n    b.TextColor3 = Theme.Text\n    b.Font = FontBold\n    b.TextSize = 10\n    b.BorderSizePixel = 0\n    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)\n    b.MouseButton1Click:Connect(function()\n        K.Settings.Language = l\n        Lang = l\n        Notify("Language", "Changed to " .. l:upper(), "success")\n    end)\nend\n\nAddSection(pSettings, "Profile")
-- avatar already in sidebar, show user info here
local infoLbl = Instance.new("TextLabel", pSettings)
infoLbl.Size = UDim2.new(1, 0, 0, 30)
infoLbl.BackgroundTransparency = 1
infoLbl.Text = "User: " .. LP.Name .. "\nID: " .. LP.UserId
infoLbl.TextColor3 = Theme.Text
infoLbl.Font = FontMain
infoLbl.TextSize = 12
infoLbl.TextXAlignment = Enum.TextXAlignment.Left

AddSection(pSettings, "Appearance")
local colorLbl = Instance.new("TextLabel", pSettings)
colorLbl.Size = UDim2.new(1, 0, 0, 16)
colorLbl.BackgroundTransparency = 1
colorLbl.Text = "Accent Color"
colorLbl.TextColor3 = Theme.Text
colorLbl.Font = FontMain
colorLbl.TextSize = 12
colorLbl.TextXAlignment = Enum.TextXAlignment.Left

local colorBtns = Instance.new("Frame", pSettings)
colorBtns.Size = UDim2.new(1, 0, 0, 30)
colorBtns.BackgroundTransparency = 1
local cbl = Instance.new("UIListLayout", colorBtns)
cbl.FillDirection = Enum.FillDirection.Horizontal
cbl.Padding = UDim.new(0, 6)

local colors = {
    {name = "Blue", color = Color3.fromRGB(99, 102, 241)},
    {name = "Red", color = Color3.fromRGB(239, 68, 68)},
    {name = "Green", color = Color3.fromRGB(34, 197, 94)},
    {name = "Orange", color = Color3.fromRGB(255, 165, 0)},
    {name = "Pink", color = Color3.fromRGB(236, 72, 153)},
}
for _, c in ipairs(colors) do
    local btn = Instance.new("TextButton", colorBtns)
    btn.Size = UDim2.new(0, 40, 0, 24)
    btn.BackgroundColor3 = c.color
    btn.Text = ""
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(function()
        Theme.Accent = c.color
        MainStroke.Color = c.color
        Notify("Theme", "Accent changed to " .. c.name, "success")
    end)
end

AddSection(pSettings, "Toggle Parts")
AddToggle(pSettings, "Show Notifications", "UI.ShowNotify")
AddToggle(pSettings, "Show Snow", "UI.ShowSnow")
AddToggle(pSettings, "Show Blur", "UI.ShowBlur")

-- ============ DRAG ============
local dragging, dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- ============ HOTKEY ============
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F4 then
        Main.Visible = not Main.Visible
        if Main.Visible then
            UIS.MouseBehavior = Enum.MouseBehavior.Default
            UIS.MouseIconEnabled = true
        end
    end
end)

-- ============ MOUSE FIX ============
RunService.RenderStepped:Connect(function()
    if Main.Visible then
        if UIS.MouseBehavior ~= Enum.MouseBehavior.Default then UIS.MouseBehavior = Enum.MouseBehavior.Default end
        if not UIS.MouseIconEnabled then UIS.MouseIconEnabled = true end
    end
end)

-- ============ BLUR ============
task.spawn(function()
    while Main and Main.Parent do
        if Main.Visible then
            if blur.Size < 6 then blur.Size = blur.Size + 2 end
        else
            if blur.Size > 0 then blur.Size = blur.Size - 2 end
        end
        task.wait(0.05)
    end
end)

K.Loading = false
task.delay(0.4, function()
    Notify("KiroHack", "Loaded! F4 - menu", "success")
end)
print("[KIRO UI] Menu loaded (Frozen style).")
