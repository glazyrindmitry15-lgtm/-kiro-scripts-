-- ui.lua | Kiro Scripts UI Library (Valiant District) - Fixed & Enhanced
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer

local env = (getgenv and getgenv()) or _G or shared
local K = env.K or _G.K or shared.K or {}
env.K = K
_G.K = K

K.Settings = K.Settings or {}
K.Lang = K.Lang or "RU"
K.GameId = K.GameId or "valiant_district"
K.LoadedModules = K.LoadedModules or {}

function K.GetSetting(path)
    if type(path) ~= "string" then return nil end
    if K.Settings[path] ~= nil then return K.Settings[path] end
    local current = K.Settings
    for part in string.gmatch(path, "[^%.]+") do
        if type(current) == "table" and current[part] ~= nil then
            current = current[part]
        else return nil end
    end
    return current
end

function K.SetSetting(path, value)
    if type(path) ~= "string" then return end
    K.Settings[path] = value
    local parts = {}
    for part in string.gmatch(path, "[^%.]+") do table.insert(parts, part) end
    local current = K.Settings
    for i = 1, #parts - 1 do
        local key = parts[i]
        if type(current[key]) ~= "table" then current[key] = {} end
        current = current[key]
    end
    current[parts[#parts]] = value
    if type(K.OnSettingChanged) == "function" then pcall(K.OnSettingChanged, path, value) end
end

if not K.Notify then
    function K.Notify(title, text, ntype)
        print(string.format("[KIRO %s] %s: %s", ntype and ntype:upper() or "INFO", title, text))
    end
end

local Theme = {
    Background = Color3.fromRGB(18, 18, 26),
    Sidebar    = Color3.fromRGB(22, 22, 32),
    Content    = Color3.fromRGB(24, 24, 36),
    Element    = Color3.fromRGB(34, 34, 50),
    ElementHov = Color3.fromRGB(44, 44, 64),
    Accent     = Color3.fromRGB(138, 100, 255),
    Accent2    = Color3.fromRGB(170, 90, 240),
    Text       = Color3.fromRGB(245, 245, 255),
    SubText    = Color3.fromRGB(170, 170, 195),
    Danger     = Color3.fromRGB(235, 75, 95),
    Green      = Color3.fromRGB(80, 220, 140),
    Border     = Color3.fromRGB(60, 60, 85),
    OverlayDark = Color3.fromRGB(0, 0, 0),
}

local Translations = {
    RU = {
        Tab_Combat = "Бой", Tab_Visuals = "Визуалы", Tab_Utility = "Утилиты", Tab_Misc = "Разное", Tab_Console = "Консоль", Tab_Settings = "Настройки",
        Sec_Aimbot = "АИМБОТ", Sec_Valiant = "VALIANT", Sec_ESP = "ESP", Sec_Movement = "ПЕРЕДВИЖЕНИЕ", Sec_World = "МИР", Sec_Config = "Конфиг", Sec_UI = "Интерфейс", Sec_Info = "Инфо",
        Aimbot = "Включить Аимбот", SilentAim = "Сайлент Аим", ShowFOV = "Показать FOV", FOV = "Радиус FOV", Smoothness = "Плавность",
        WallCheck = "Проверка стен", TeamCheck = "Проверка команды",
        AutoRepair = "Авто-починка", AutoSkillCheck = "Авто скилл-чек",
        KillerESP = "ESP Маньяка", GeneratorESP = "ESP Генераторов",
        ESPEnabled = "Включить ESP", BoxESP = "Боксы", NameESP = "Имена", HealthESP = "Здоровье",
        Tracers = "Трейсеры", TracerOrigin = "Начало трейсера", Snaplines = "Снаплайны", Chams = "Чамсы",
        MaxDistance = "Макс. дистанция", Radar = "Радар",
        Fly = "Полёт", FlySpeed = "Скорость полёта", Noclip = "Ноклип", InfJump = "Инф. прыжок",
        WalkSpeed = "Скорость ходьбы", JumpPower = "Сила прыжка", BunnyHop = "Баннихоп", Fullbright = "Фулбрайт",
        SaveConfig = "Сохранить конфиг", LoadConfig = "Загрузить конфиг", ResetConfig = "Сбросить настройки",
        AccentColor = "Цвет акцента", UITransparency = "Прозрачность UI", UIScale = "Масштаб UI",
        SearchPlaceholder = "Поиск настроек...", FPS = "FPS", Ping = "Пинг",
        ModuleStatus_OK = "Загружен", ModuleStatus_FAIL = "Ошибка", ConsoleTitle = "Консоль", ClearConsole = "Очистить", NoErrors = "Ошибок нет",
    },
    EN = {
        Tab_Combat = "Combat", Tab_Visuals = "Visuals", Tab_Utility = "Utility", Tab_Misc = "Misc", Tab_Console = "Console", Tab_Settings = "Settings",
        Sec_Aimbot = "AIMBOT", Sec_Valiant = "VALIANT", Sec_ESP = "ESP", Sec_Movement = "Movement", Sec_World = "World", Sec_Config = "Config", Sec_UI = "UI", Sec_Info = "Info",
        Aimbot = "Enable Aimbot", SilentAim = "Silent Aim", ShowFOV = "Show FOV", FOV = "FOV Radius", Smoothness = "Smoothness",
        WallCheck = "Wall Check", TeamCheck = "Team Check",
        AutoRepair = "Auto Repair", AutoSkillCheck = "Auto Skill Check",
        KillerESP = "Killer ESP", GeneratorESP = "Generator ESP",
        ESPEnabled = "Enable ESP", BoxESP = "Box ESP", NameESP = "Name ESP", HealthESP = "Health Bar",
        Tracers = "Tracers", TracerOrigin = "Tracer Origin", Snaplines = "Snaplines", Chams = "Chams",
        MaxDistance = "Max Distance", Radar = "Radar",
        Fly = "Fly", FlySpeed = "Fly Speed", Noclip = "Noclip", InfJump = "Inf Jump",
        WalkSpeed = "Walk Speed", JumpPower = "Jump Power", BunnyHop = "Bunny Hop", Fullbright = "Fullbright",
        SaveConfig = "Save Config", LoadConfig = "Load Config", ResetConfig = "Reset Settings",
        AccentColor = "Accent Color", UITransparency = "UI Transparency", UIScale = "UI Scale",
        SearchPlaceholder = "Search settings...", FPS = "FPS", Ping = "Ping",
        ModuleStatus_OK = "Loaded", ModuleStatus_FAIL = "Failed", ConsoleTitle = "Console", ClearConsole = "Clear", NoErrors = "No errors",
    },
    JA = {
        Tab_Combat = "戦闘", Tab_Visuals = "ビジュアル", Tab_Utility = "ユーティリティ", Tab_Misc = "その他", Tab_Console = "コンソール", Tab_Settings = "設定",
        Sec_Aimbot = "エイムボット", Sec_Valiant = "VALIANT", Sec_ESP = "ESP", Sec_Movement = "移動", Sec_World = "ワールド", Sec_Config = "コンフィグ", Sec_UI = "UI", Sec_Info = "情報",
        Aimbot = "エイムボット有効", SilentAim = "サイレントエイム", ShowFOV = "FOV表示", FOV = "FOV半径", Smoothness = "滑らかさ",
        WallCheck = "壁チェック", TeamCheck = "チームチェック",
        AutoRepair = "自動修理", AutoSkillCheck = "自動スキルチェック",
        KillerESP = "キラーESP", GeneratorESP = "発電機ESP",
        ESPEnabled = "ESP有効", BoxESP = "ボックス", NameESP = "名前", HealthESP = "ヘルスバー",
        Tracers = "トレーサー", TracerOrigin = "始点", Snaplines = "スナップライン", Chams = "チャムス",
        MaxDistance = "最大距離", Radar = "レーダー",
        Fly = "フライ", FlySpeed = "フライ速度", Noclip = "ノックリップ", InfJump = "無限ジャンプ",
        WalkSpeed = "歩行速度", JumpPower = "ジャンプ力", BunnyHop = "バニーホップ", Fullbright = "フルブライト",
        SaveConfig = "保存", LoadConfig = "読み込み", ResetConfig = "リセット",
        AccentColor = "アクセント色", UITransparency = "透明度", UIScale = "スケール",
        SearchPlaceholder = "検索...", FPS = "FPS", Ping = "ピン",
        ModuleStatus_OK = "読み込み済み", ModuleStatus_FAIL = "失敗", ConsoleTitle = "コンソール", ClearConsole = "クリア", NoErrors = "エラーなし",
    }
}
local function Tr(key) return (Translations[K.Lang] or Translations.RU)[key] or key end

local GuiParent = (gethui and gethui()) or CoreGui
local OldGui = GuiParent:FindFirstChild("KiroScriptsUI") or LocalPlayer.PlayerGui:FindFirstChild("KiroScriptsUI")
if OldGui then OldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KiroScriptsUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = GuiParent

local clickSound = Instance.new("Sound")
clickSound.SoundId = "rbxassetid://6895079853"
clickSound.Volume = 0.3
clickSound.Parent = ScreenGui

local hoverSound = Instance.new("Sound")
hoverSound.SoundId = "rbxassetid://6895079853"
hoverSound.Volume = 0.15
hoverSound.Parent = ScreenGui

local function playClick() clickSound:Play() end
local function playHover() hoverSound:Play() end

local overlay = Instance.new("Frame")
overlay.Size = UDim2.new(1,0,1,0)
overlay.BackgroundColor3 = Theme.OverlayDark
overlay.BackgroundTransparency = 1
overlay.BorderSizePixel = 0
overlay.ZIndex = 1
overlay.Parent = ScreenGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 620, 0, 440)
Main.Position = UDim2.new(0.5, -310, 0.5, -220)
Main.BackgroundColor3 = Theme.Background
Main.BackgroundTransparency = 1
Main.BorderSizePixel = 0
Main.ZIndex = 10
Main.ClipsDescendants = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local bg = Instance.new("ImageLabel")
bg.Size = UDim2.new(1,0,1,0)
bg.BackgroundTransparency = 1
bg.Image = "rbxassetid://135051563569214"
bg.ScaleType = Enum.ScaleType.Crop
bg.ImageTransparency = 1
bg.ZIndex = 1
bg.Parent = Main

local bgOverlay = Instance.new("Frame")
bgOverlay.Size = UDim2.new(1,0,1,0)
bgOverlay.BackgroundColor3 = Theme.OverlayDark
bgOverlay.BackgroundTransparency = 1
bgOverlay.BorderSizePixel = 0
bgOverlay.ZIndex = 2
bgOverlay.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.Accent
MainStroke.Thickness = 1.5
MainStroke.Transparency = 1
MainStroke.Parent = Main

task.spawn(function()
    task.wait(0.05)
    TweenService:Create(overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.5}):Play()
    TweenService:Create(Main, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.05}):Play()
    TweenService:Create(bg, TweenInfo.new(0.4), {ImageTransparency = 0.25}):Play()
    TweenService:Create(bgOverlay, TweenInfo.new(0.35), {BackgroundTransparency = 0.4}):Play()
    TweenService:Create(MainStroke, TweenInfo.new(0.35), {Transparency = 0.3}):Play()
end)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1,0,0,48)
TopBar.BackgroundColor3 = Theme.Sidebar
TopBar.BackgroundTransparency = 1
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 11
TopBar.Parent = Main
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

local Logo = Instance.new("Frame")
Logo.Size = UDim2.new(0,36,0,36)
Logo.Position = UDim2.new(0,12,0.5,-18)
Logo.BackgroundColor3 = Theme.Accent
Logo.BorderSizePixel = 0
Logo.ZIndex = 12
Logo.Parent = TopBar
Instance.new("UICorner", Logo).CornerRadius = UDim.new(0, 8)
local logoGrad = Instance.new("UIGradient", Logo)
logoGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Theme.Accent),ColorSequenceKeypoint.new(0.5,Theme.Accent2),ColorSequenceKeypoint.new(1,Theme.Accent)}
task.spawn(function() while Logo.Parent do logoGrad.Rotation=(logoGrad.Rotation+1.5)%360 task.wait(0.03) end end)
local LogoK = Instance.new("TextLabel", Logo)
LogoK.Size = UDim2.new(1,0,1,0)
LogoK.BackgroundTransparency = 1
LogoK.Text = "K"
LogoK.TextColor3 = Color3.new(1,1,1)
LogoK.Font = Enum.Font.GothamBold
LogoK.TextSize = 20
LogoK.ZIndex = 13

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(0,200,0,22)
Title.Position = UDim2.new(0,56,0,6)
Title.BackgroundTransparency = 1
Title.Text = "KIRO SCRIPTS"
Title.TextColor3 = Theme.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 12

local Subtitle = Instance.new("TextLabel", TopBar)
Subtitle.Size = UDim2.new(0,200,0,14)
Subtitle.Position = UDim2.new(0,56,0,28)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "v1.2.0  •  [F4]"
Subtitle.TextColor3 = Theme.SubText
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 10
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.ZIndex = 12

local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.new(0,32,0,32)
Avatar.Position = UDim2.new(1,-220,0.5,-16)
Avatar.BackgroundColor3 = Theme.Element
Avatar.BorderSizePixel = 0
Avatar.ZIndex = 12
Avatar.Parent = TopBar
Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1,0)
task.spawn(function() local ok,img=pcall(function() return Players:GetUserThumbnailAsync(LocalPlayer.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48) end) if ok and img then Avatar.Image=img end end)

local NickLabel = Instance.new("TextLabel")
NickLabel.Size = UDim2.new(0,120,0,16)
NickLabel.Position = UDim2.new(1,-184,0.5,-16)
NickLabel.BackgroundTransparency = 1
NickLabel.Text = LocalPlayer.Name
NickLabel.TextColor3 = Theme.Text
NickLabel.Font = Enum.Font.GothamBold
NickLabel.TextSize = 12
NickLabel.TextXAlignment = Enum.TextXAlignment.Right
NickLabel.ZIndex = 12
NickLabel.Parent = TopBar

local TimeLabel = Instance.new("TextLabel")
TimeLabel.Size = UDim2.new(0,120,0,14)
TimeLabel.Position = UDim2.new(1,-184,0.5,0)
TimeLabel.BackgroundTransparency = 1
TimeLabel.Text = os.date("%H:%M:%S")
TimeLabel.TextColor3 = Theme.SubText
TimeLabel.Font = Enum.Font.Gotham
TimeLabel.TextSize = 10
TimeLabel.TextXAlignment = Enum.TextXAlignment.Right
TimeLabel.ZIndex = 12
TimeLabel.Parent = TopBar
task.spawn(function() while ScreenGui.Parent do TimeLabel.Text=os.date("%H:%M:%S") task.wait(1) end end)

local PerfLabel = Instance.new("TextLabel")
PerfLabel.Size = UDim2.new(0,100,0,14)
PerfLabel.Position = UDim2.new(1,-330,0.5,-7)
PerfLabel.BackgroundTransparency = 1
PerfLabel.Text = "FPS: 0 | Ping: 0ms"
PerfLabel.TextColor3 = Theme.SubText
PerfLabel.Font = Enum.Font.Gotham
PerfLabel.TextSize = 10
PerfLabel.TextXAlignment = Enum.TextXAlignment.Right
PerfLabel.ZIndex = 12
PerfLabel.Parent = TopBar

task.spawn(function()
    local lastFrame = tick()
    local frames = 0
    while ScreenGui.Parent do
        frames += 1
        local now = tick()
        if now - lastFrame >= 1 then
            local fps = frames
            frames = 0
            lastFrame = now
            local ping = 0
            pcall(function() ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            PerfLabel.Text = string.format("%s: %d | %s: %dms", Tr("FPS"), fps, Tr("Ping"), ping)
        end
        task.wait()
    end
end)

local LangButton = Instance.new("TextButton")
LangButton.Size = UDim2.new(0,48,0,28)
LangButton.Position = UDim2.new(1,-96,0.5,-14)
LangButton.BackgroundColor3 = Theme.Element
LangButton.BackgroundTransparency = 0.15
LangButton.BorderSizePixel = 0
LangButton.Text = K.Lang
LangButton.TextColor3 = Theme.Text
LangButton.Font = Enum.Font.GothamBold
LangButton.TextSize = 12
LangButton.ZIndex = 12
LangButton.Parent = TopBar
Instance.new("UICorner", LangButton).CornerRadius = UDim.new(0,6)

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0,32,0,32)
CloseButton.Position = UDim2.new(1,-40,0.5,-16)
CloseButton.BackgroundColor3 = Theme.Danger
CloseButton.BackgroundTransparency = 0.15
CloseButton.BorderSizePixel = 0
CloseButton.Text = "✕"
CloseButton.TextColor3 = Theme.Text
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.ZIndex = 12
CloseButton.Parent = TopBar
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(1,0)

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(0,180,0,26)
SearchBox.Position = UDim2.new(1,-530,0.5,-13)
SearchBox.BackgroundColor3 = Theme.Element
SearchBox.BackgroundTransparency = 0.2
SearchBox.BorderSizePixel = 0
SearchBox.Text = ""
SearchBox.PlaceholderText = Tr("SearchPlaceholder")
SearchBox.TextColor3 = Theme.Text
SearchBox.PlaceholderColor3 = Theme.SubText
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 12
SearchBox.ClearTextOnFocus = false
SearchBox.ZIndex = 12
SearchBox.Parent = TopBar
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0,6)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0,150,1,-58)
Sidebar.Position = UDim2.new(0,6,0,52)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BackgroundTransparency = 0.2
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 11
Sidebar.Parent = Main
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0,8)
local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0,6)
local SidebarPadding = Instance.new("UIPadding", Sidebar)
SidebarPadding.PaddingTop = UDim.new(0,8)
SidebarPadding.PaddingLeft = UDim.new(0,8)
SidebarPadding.PaddingRight = UDim.new(0,8)

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1,-168,1,-58)
ContentContainer.Position = UDim2.new(0,162,0,52)
ContentContainer.BackgroundColor3 = Theme.Content
ContentContainer.BackgroundTransparency = 0.2
ContentContainer.BorderSizePixel = 0
ContentContainer.ZIndex = 11
ContentContainer.Parent = Main
Instance.new("UICorner", ContentContainer).CornerRadius = UDim.new(0,8)

local windowDragging = false
local dragStartPos, mainStartPos
local activeSliderDragging = false
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and not activeSliderDragging then
        windowDragging = true
        dragStartPos = input.Position
        mainStartPos = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if windowDragging and input.UserInputType == Enum.UserInputType.MouseMovement and not activeSliderDragging then
        local delta = input.Position - dragStartPos
        Main.Position = UDim2.new(mainStartPos.X.Scale, mainStartPos.X.Offset + delta.X, mainStartPos.Y.Scale, mainStartPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then windowDragging = false end
end)

local TranslatableElements = {}
local function BindTranslation(inst, key, fmt)
    local function apply() local t=Tr(key) inst.Text = fmt and fmt(t) or t end
    table.insert(TranslatableElements, apply)
    apply()
end

local Tabs, ActiveTab = {}, nil
local function SelectTab(t)
    ActiveTab = t
    for _, tab in ipairs(Tabs) do
        local sel = tab == t
        tab.Page.Visible = sel
        TweenService:Create(tab.Button, TweenInfo.new(0.15), {BackgroundColor3 = sel and Theme.Accent or Theme.Element, BackgroundTransparency = sel and 0.1 or 0.35}):Play()
    end
end
local function CreateTab(key, order)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1,0,0,36)
    Btn.BackgroundColor3 = Theme.Element
    Btn.BackgroundTransparency = 0.35
    Btn.BorderSizePixel = 0
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Btn.TextColor3 = Theme.Text
    Btn.ZIndex = 12
    Btn.LayoutOrder = order
    Btn.Parent = Sidebar
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,6)
    BindTranslation(Btn, key)

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1,0,1,0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 4
    Page.ScrollBarImageColor3 = Theme.Accent
    Page.ScrollBarImageTransparency = 0.3
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.Visible = false
    Page.ZIndex = 12
    Page.Parent = ContentContainer
    Instance.new("UIListLayout", Page).Padding = UDim.new(0,8)
    local Pad = Instance.new("UIPadding", Page)
    Pad.PaddingTop = UDim.new(0,10)
    Pad.PaddingBottom = UDim.new(0,12)
    Pad.PaddingLeft = UDim.new(0,12)
    Pad.PaddingRight = UDim.new(0,12)

    local tab = {Button=Btn, Page=Page, NextOrder=0}
    Btn.MouseButton1Click:Connect(function() playClick() SelectTab(tab) end)
    Btn.MouseEnter:Connect(playHover)
    table.insert(Tabs, tab)
    if #Tabs == 1 then SelectTab(tab) end
    return tab
end

local function AddSection(tab, key)
    tab.NextOrder += 1
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1,0,0,22)
    Lbl.BackgroundTransparency = 1
    Lbl.Font = Enum.Font.GothamBold
    Lbl.TextSize = 12
    Lbl.TextColor3 = Theme.Accent
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.ZIndex = 13
    Lbl.LayoutOrder = tab.NextOrder
    Lbl.Parent = tab.Page
    BindTranslation(Lbl, key)
    return Lbl
end

local function AddToggle(tab, key, path)
    tab.NextOrder += 1
    local state = K.GetSetting(path) == true
    local Frame = Instance.new("TextButton")
    Frame.Size = UDim2.new(1,0,0,36)
    Frame.BackgroundColor3 = Theme.Element
    Frame.BackgroundTransparency = 0.2
    Frame.BorderSizePixel = 0
    Frame.Text = ""
    Frame.AutoButtonColor = false
    Frame.ZIndex = 13
    Frame.LayoutOrder = tab.NextOrder
    Frame.Parent = tab.Page
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,6)

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1,-65,1,0)
    Lbl.Position = UDim2.new(0,12,0,0)
    Lbl.BackgroundTransparency = 1
    Lbl.Font = Enum.Font.GothamSemibold
    Lbl.TextSize = 14
    Lbl.TextColor3 = Theme.Text
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.ZIndex = 14
    Lbl.Parent = Frame
    BindTranslation(Lbl, key)

    local SwBg = Instance.new("Frame")
    SwBg.Size = UDim2.new(0,40,0,20)
    SwBg.Position = UDim2.new(1,-52,0.5,-10)
    SwBg.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(55,55,75)
    SwBg.BorderSizePixel = 0
    SwBg.ZIndex = 14
    SwBg.Parent = Frame
    Instance.new("UICorner", SwBg).CornerRadius = UDim.new(1,0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0,16,0,16)
    Knob.Position = state and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
    Knob.BackgroundColor3 = Theme.Text
    Knob.BorderSizePixel = 0
    Knob.ZIndex = 15
    Knob.Parent = SwBg
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1,0)

    local function Update(s)
        state = s
        K.SetSetting(path, state)
        TweenService:Create(SwBg, TweenInfo.new(0.15), {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(55,55,75)}):Play()
        TweenService:Create(Knob, TweenInfo.new(0.15), {Position = state and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)}):Play()
        playClick()
        if type(K.OnSettingChanged) == "function" then pcall(K.OnSettingChanged, path, state) end
    end

    Frame.MouseButton1Click:Connect(function() Update(not state) end)
    Frame.MouseEnter:Connect(playHover)
    return Frame
end

local function AddSlider(tab, key, path, minV, maxV)
    tab.NextOrder += 1
    local saved = tonumber(K.GetSetting(path))
    local val = saved and math.clamp(saved, minV, maxV) or minV
    local alpha = math.clamp((val - minV) / math.max(maxV - minV, 1), 0, 1)

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1,0,0,50)
    Frame.BackgroundColor3 = Theme.Element
    Frame.BackgroundTransparency = 0.2
    Frame.BorderSizePixel = 0
    Frame.ZIndex = 13
    Frame.LayoutOrder = tab.NextOrder
    Frame.Parent = tab.Page
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,6)

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1,-90,0,22)
    Lbl.Position = UDim2.new(0,12,0,4)
    Lbl.BackgroundTransparency = 1
    Lbl.Font = Enum.Font.GothamSemibold
    Lbl.TextSize = 14
    Lbl.TextColor3 = Theme.Text
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.ZIndex = 14
    Lbl.Parent = Frame
    BindTranslation(Lbl, key)

    local ValLbl = Instance.new("TextLabel")
    ValLbl.Size = UDim2.new(0,70,0,22)
    ValLbl.Position = UDim2.new(1,-82,0,4)
    ValLbl.BackgroundTransparency = 1
    ValLbl.Font = Enum.Font.GothamBold
    ValLbl.TextSize = 14
    ValLbl.TextColor3 = Theme.Accent
    ValLbl.TextXAlignment = Enum.TextXAlignment.Right
    ValLbl.Text = tostring(val)
    ValLbl.ZIndex = 14
    ValLbl.Parent = Frame

    local Track = Instance.new("TextButton")
    Track.Name = "Track"
    Track.Size = UDim2.new(1,-24,0,8)
    Track.Position = UDim2.new(0,12,0,32)
    Track.BackgroundColor3 = Color3.fromRGB(20,20,30)
    Track.BorderSizePixel = 0
    Track.Text = ""
    Track.AutoButtonColor = false
    Track.Active = true
    Track.ZIndex = 14
    Track.Parent = Frame
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1,0)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new(alpha,0,1,0)
    Fill.BackgroundColor3 = Theme.Accent
    Fill.BorderSizePixel = 0
    Fill.ZIndex = 15
    Fill.Parent = Track
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1,0)
    local fillGrad = Instance.new("UIGradient", Fill)
    fillGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Theme.Accent),ColorSequenceKeypoint.new(1,Theme.Accent2)}
    fillGrad.Rotation = 90

    local Knob = Instance.new("TextButton")
    Knob.Name = "Knob"
    Knob.Size = UDim2.new(0,14,0,14)
    Knob.Position = UDim2.new(alpha,-7,0.5,-7)
    Knob.BackgroundColor3 = Theme.Text
    Knob.BorderSizePixel = 0
    Knob.Text = ""
    Knob.AutoButtonColor = false
    Knob.Active = true
    Knob.ZIndex = 16
    Knob.Parent = Track
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1,0)
    local knobStroke = Instance.new("UIStroke", Knob)
    knobStroke.Color = Theme.Accent
    knobStroke.Thickness = 2
    knobStroke.Transparency = 0.5

    local dragging = false
    local function UpdateFromInput(input)
        local absPos = Track.AbsolutePosition
        local absSize = Track.AbsoluteSize
        if absSize.X == 0 then return end
        local rel = math.clamp((input.Position.X - absPos.X) / absSize.X, 0, 1)
        local v = math.floor(minV + (maxV - minV) * rel + 0.5)
        local snappedRel = (v - minV) / math.max(maxV - minV, 1)
        Fill.Size = UDim2.new(snappedRel, 0, 1, 0)
        Knob.Position = UDim2.new(snappedRel, -7, 0.5, -7)
        ValLbl.Text = tostring(v)
        K.SetSetting(path, v)
    end

    Knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            activeSliderDragging = true
            UpdateFromInput(input)
        end
    end)
    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            activeSliderDragging = true
            UpdateFromInput(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateFromInput(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
            dragging = false
            activeSliderDragging = false
        end
    end)

    Track.MouseEnter:Connect(playHover)
    Knob.MouseEnter:Connect(playHover)
    return Frame
end

local function MakeDropdown(parent, current, options, onSelect)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0,120,0,24)
    Btn.BackgroundColor3 = Theme.Accent
    Btn.BackgroundTransparency = 0.2
    Btn.BorderSizePixel = 0
    Btn.Text = current
    Btn.TextColor3 = Theme.Text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 12
    Btn.ZIndex = 14
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,4)

    local open = false
    local OptFrame = nil
    local function Close()
        if OptFrame then OptFrame:Destroy() OptFrame=nil end
        open = false
    end
    Btn.MouseButton1Click:Connect(function() playClick()
        if open then Close() return end
        open = true
        OptFrame = Instance.new("Frame")
        OptFrame.Size = UDim2.new(0,120,0,#options*26)
        OptFrame.Position = UDim2.new(0,0,1,4)
        OptFrame.BackgroundColor3 = Theme.Content
        OptFrame.BackgroundTransparency = 0.1
        OptFrame.BorderSizePixel = 0
        OptFrame.ZIndex = 20
        OptFrame.ClipsDescendants = true
        OptFrame.Parent = Btn
        Instance.new("UICorner", OptFrame).CornerRadius = UDim.new(0,4)
        Instance.new("UIListLayout", OptFrame)
        for i,opt in ipairs(options) do
            local Ob = Instance.new("TextButton")
            Ob.Size = UDim2.new(1,0,0,24)
            Ob.BackgroundTransparency = 1
            Ob.Text = opt
            Ob.TextColor3 = Theme.Text
            Ob.Font = Enum.Font.Gotham
            Ob.TextSize = 12
            Ob.TextXAlignment = Enum.TextXAlignment.Center
            Ob.ZIndex = 21
            Ob.LayoutOrder = i
            Ob.Parent = OptFrame
            Ob.MouseButton1Click:Connect(function() playClick() current=opt Btn.Text=opt onSelect(opt) Close() end)
            Ob.MouseEnter:Connect(function() Ob.BackgroundTransparency=0.7 Ob.BackgroundColor3=Theme.Accent end)
            Ob.MouseLeave:Connect(function() Ob.BackgroundTransparency=1 end)
        end
    end)
    UserInputService.InputBegan:Connect(function(input)
        if open and input.UserInputType==Enum.UserInputType.MouseButton1 then
            local mp = input.Position
            local ap = OptFrame.AbsolutePosition
            local as = OptFrame.AbsoluteSize
            if mp.X<ap.X or mp.X>ap.X+as.X or mp.Y<ap.Y or mp.Y>ap.Y+as.Y then Close() end
        end
    end)
    return Btn
end

local function AddDropdown(tab, key, path, options)
    tab.NextOrder += 1
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1,0,0,36)
    Frame.BackgroundColor3 = Theme.Element
    Frame.BackgroundTransparency = 0.2
    Frame.BorderSizePixel = 0
    Frame.ZIndex = 13
    Frame.LayoutOrder = tab.NextOrder
    Frame.Parent = tab.Page
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,6)

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1,-140,1,0)
    Lbl.Position = UDim2.new(0,12,0,0)
    Lbl.BackgroundTransparency = 1
    Lbl.Font = Enum.Font.GothamSemibold
    Lbl.TextSize = 14
    Lbl.TextColor3 = Theme.Text
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.ZIndex = 14
    Lbl.Parent = Frame
    BindTranslation(Lbl, key)

    local current = K.GetSetting(path) or options[1]
    local Btn = MakeDropdown(Frame, current, options, function(val) K.SetSetting(path, val) end)
    Btn.Position = UDim2.new(1,-132,0.5,-12)
    Btn.Parent = Frame
    return Frame
end

local function AddButton(tab, key, path, callback)
    tab.NextOrder += 1
    local Frame = Instance.new("TextButton")
    Frame.Size = UDim2.new(1,0,0,36)
    Frame.BackgroundColor3 = Theme.Accent
    Frame.BackgroundTransparency = 0.15
    Frame.BorderSizePixel = 0
    Frame.Text = ""
    Frame.AutoButtonColor = false
    Frame.ZIndex = 13
    Frame.LayoutOrder = tab.NextOrder
    Frame.Parent = tab.Page
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,6)
    local btnGrad = Instance.new("UIGradient", Frame)
    btnGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Theme.Accent),ColorSequenceKeypoint.new(1,Theme.Accent2)}
    btnGrad.Rotation = 90

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1,0,1,0)
    Lbl.BackgroundTransparency = 1
    Lbl.Font = Enum.Font.GothamBold
    Lbl.TextSize = 14
    Lbl.TextColor3 = Theme.Text
    Lbl.TextXAlignment = Enum.TextXAlignment.Center
    Lbl.ZIndex = 14
    Lbl.Parent = Frame
    BindTranslation(Lbl, key)

    Frame.MouseButton1Click:Connect(function() playClick() if callback then callback() end end)
    Frame.MouseEnter:Connect(function() playHover() TweenService:Create(Frame, TweenInfo.new(0.1), {BackgroundTransparency = 0}):Play() end)
    Frame.MouseLeave:Connect(function() TweenService:Create(Frame, TweenInfo.new(0.1), {BackgroundTransparency = 0.15}):Play() end)
    return Frame
end

local function AddColorPicker(tab, key, path)
    tab.NextOrder += 1
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1,0,0,36)
    Frame.BackgroundColor3 = Theme.Element
    Frame.BackgroundTransparency = 0.2
    Frame.BorderSizePixel = 0
    Frame.ZIndex = 13
    Frame.LayoutOrder = tab.NextOrder
    Frame.Parent = tab.Page
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,6)

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1,-60,1,0)
    Lbl.Position = UDim2.new(0,12,0,0)
    Lbl.BackgroundTransparency = 1
    Lbl.Font = Enum.Font.GothamSemibold
    Lbl.TextSize = 14
    Lbl.TextColor3 = Theme.Text
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.ZIndex = 14
    Lbl.Parent = Frame
    BindTranslation(Lbl, key)

    local Preview = Instance.new("Frame")
    Preview.Size = UDim2.new(0,40,0,20)
    Preview.Position = UDim2.new(1,-52,0.5,-10)
    Preview.BackgroundColor3 = K.GetSetting(path) or Theme.Accent
    Preview.BorderSizePixel = 0
    Preview.ZIndex = 14
    Preview.Parent = Frame
    Instance.new("UICorner", Preview).CornerRadius = UDim.new(0,4)

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1,0,1,0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.ZIndex = 15
    Btn.Parent = Preview

    Btn.MouseButton1Click:Connect(function() playClick()
        local colors = {Theme.Accent, Theme.Accent2, Theme.Green, Theme.Danger, Color3.fromRGB(255,200,80), Color3.fromRGB(100,200,255)}
        local current = Preview.BackgroundColor3
        local idx = 1
        for i,c in ipairs(colors) do if c == current then idx = i break end end
        local nextColor = colors[(idx % #colors) + 1]
        Preview.BackgroundColor3 = nextColor
        K.SetSetting(path, nextColor)
    end)
    return Frame
end

local function AddKeybind(tab, key, path)
    tab.NextOrder += 1
    local current = K.GetSetting(path) or Enum.KeyCode.Unknown
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1,0,0,36)
    Frame.BackgroundColor3 = Theme.Element
    Frame.BackgroundTransparency = 0.2
    Frame.BorderSizePixel = 0
    Frame.ZIndex = 13
    Frame.LayoutOrder = tab.NextOrder
    Frame.Parent = tab.Page
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,6)

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1,-100,1,0)
    Lbl.Position = UDim2.new(0,12,0,0)
    Lbl.BackgroundTransparency = 1
    Lbl.Font = Enum.Font.GothamSemibold
    Lbl.TextSize = 14
    Lbl.TextColor3 = Theme.Text
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.ZIndex = 14
    Lbl.Parent = Frame
    BindTranslation(Lbl, key)

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0,90,0,24)
    Btn.Position = UDim2.new(1,-102,0.5,-12)
    Btn.BackgroundColor3 = Theme.Accent
    Btn.BackgroundTransparency = 0.2
    Btn.BorderSizePixel = 0
    Btn.Text = current.Name ~= "Unknown" and current.Name or "None"
    Btn.TextColor3 = Theme.Text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 12
    Btn.ZIndex = 14
    Btn.Parent = Frame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,4)

    local listening = false
    Btn.MouseButton1Click:Connect(function() playClick()
        listening = true
        Btn.Text = "..."
        Btn.TextColor3 = Theme.Accent2
    end)
    UserInputService.InputBegan:Connect(function(input, gp)
        if listening and not gp and input.UserInputType == Enum.UserInputType.Keyboard then
            listening = false
            current = input.KeyCode
            Btn.Text = current.Name
            Btn.TextColor3 = Theme.Text
            K.SetSetting(path, current)
        end
    end)
    return Frame
end

-- ============ TABS FOR VALIANT DISTRICT ============
local CombatTab  = CreateTab("Tab_Combat", 1)
local VisualsTab = CreateTab("Tab_Visuals", 2)
local UtilityTab = CreateTab("Tab_Utility", 3)
local MiscTab    = CreateTab("Tab_Misc", 4)
local ConsoleTab = CreateTab("Tab_Console", 5)
local SettingsTab = CreateTab("Tab_Settings", 6)

-- Combat
AddSection(CombatTab, "Sec_Aimbot")
if K.GetSetting("Combat.Aimbot")~=nil then AddToggle(CombatTab, "Aimbot", "Combat.Aimbot") end
if K.GetSetting("Combat.SilentAim")~=nil then AddToggle(CombatTab, "SilentAim", "Combat.SilentAim") end
if K.GetSetting("Combat.ShowFOV")~=nil then AddToggle(CombatTab, "ShowFOV", "Combat.ShowFOV") end
if K.GetSetting("Combat.FOV")~=nil then AddSlider(CombatTab, "FOV", "Combat.FOV", 20, 500) end
if K.GetSetting("Combat.Smoothness")~=nil then AddSlider(CombatTab, "Smoothness", "Combat.Smoothness", 1, 30) end
if K.GetSetting("Combat.WallCheck")~=nil then AddToggle(CombatTab, "WallCheck", "Combat.WallCheck") end
if K.GetSetting("Combat.TeamCheck")~=nil then AddToggle(CombatTab, "TeamCheck", "Combat.TeamCheck") end

-- Visuals
AddSection(VisualsTab, "Sec_ESP")
if K.GetSetting("Visuals.Enabled")~=nil then AddToggle(VisualsTab, "ESPEnabled", "Visuals.Enabled") end
if K.GetSetting("Visuals.BoxESP")~=nil then AddToggle(VisualsTab, "BoxESP", "Visuals.BoxESP") end
if K.GetSetting("Visuals.NameESP")~=nil then AddToggle(VisualsTab, "NameESP", "Visuals.NameESP") end
if K.GetSetting("Visuals.HealthESP")~=nil then AddToggle(VisualsTab, "HealthESP", "Visuals.HealthESP") end
if K.GetSetting("Visuals.Tracers")~=nil then AddToggle(VisualsTab, "Tracers", "Visuals.Tracers") end
if K.GetSetting("Visuals.TracerOrigin")~=nil then AddDropdown(VisualsTab, "TracerOrigin", "Visuals.TracerOrigin", {"Screen Bottom","Crosshair","Screen Center"}) end
if K.GetSetting("Visuals.Snaplines")~=nil then AddToggle(VisualsTab, "Snaplines", "Visuals.Snaplines") end
if K.GetSetting("Visuals.Chams")~=nil then AddToggle(VisualsTab, "Chams", "Visuals.Chams") end
if K.GetSetting("Visuals.KillerESP")~=nil then AddToggle(VisualsTab, "KillerESP", "Visuals.KillerESP") end
if K.GetSetting("Visuals.GeneratorESP")~=nil then AddToggle(VisualsTab, "GeneratorESP", "Visuals.GeneratorESP") end
if K.GetSetting("Visuals.MaxDistance")~=nil then AddSlider(VisualsTab, "MaxDistance", "Visuals.MaxDistance", 100, 5000) end
if K.GetSetting("Visuals.Radar")~=nil then AddToggle(VisualsTab, "Radar", "Visuals.Radar") end

-- Utility (Valiant)
AddSection(UtilityTab, "Sec_Valiant")
if K.GetSetting("Utility.AutoRepair")~=nil then AddToggle(UtilityTab, "AutoRepair", "Utility.AutoRepair") end
if K.GetSetting("Utility.AutoSkillCheck")~=nil then AddToggle(UtilityTab, "AutoSkillCheck", "Utility.AutoSkillCheck") end

-- Misc
AddSection(MiscTab, "Sec_Movement")
if K.GetSetting("Misc.Fly")~=nil then AddToggle(MiscTab, "Fly", "Misc.Fly") end
if K.GetSetting("Misc.FlySpeed")~=nil then AddSlider(MiscTab, "FlySpeed", "Misc.FlySpeed", 10, 300) end
if K.GetSetting("Misc.Noclip")~=nil then AddToggle(MiscTab, "Noclip", "Misc.Noclip") end
if K.GetSetting("Misc.InfJump")~=nil then AddToggle(MiscTab, "InfJump", "Misc.InfJump") end
if K.GetSetting("Misc.Speed")~=nil then AddToggle(MiscTab, "Speed", "Misc.Speed") end
if K.GetSetting("Misc.WalkSpeed")~=nil then AddSlider(MiscTab, "WalkSpeed", "Misc.WalkSpeed", 16, 250) end
if K.GetSetting("Misc.JumpPower")~=nil then AddSlider(MiscTab, "JumpPower", "Misc.JumpPower", 50, 300) end
if K.GetSetting("Misc.BunnyHop")~=nil then AddToggle(MiscTab, "BunnyHop", "Misc.BunnyHop") end
AddSection(MiscTab, "Sec_World")
if K.GetSetting("Misc.Fullbright")~=nil then AddToggle(MiscTab, "Fullbright", "Misc.Fullbright") end

-- Console Tab
AddSection(ConsoleTab, "ConsoleTitle")
local ConsoleContainer = Instance.new("Frame")
ConsoleContainer.Size = UDim2.new(1,0,1,-40)
ConsoleContainer.BackgroundColor3 = Color3.fromRGB(10,10,15)
ConsoleContainer.BackgroundTransparency = 0.1
ConsoleContainer.BorderSizePixel = 0
ConsoleContainer.ZIndex = 13
ConsoleContainer.Parent = ConsoleTab.Page
Instance.new("UICorner", ConsoleContainer).CornerRadius = UDim.new(0,6)
Instance.new("UIListLayout", ConsoleContainer).Padding = UDim.new(0,4)
local CPad = Instance.new("UIPadding", ConsoleContainer)
CPad.PaddingTop = UDim.new(0,8)
CPad.PaddingLeft = UDim.new(0,8)
CPad.PaddingRight = UDim.new(0,8)
CPad.PaddingBottom = UDim.new(0,8)

local function RefreshConsole()
    for _,ch in ipairs(ConsoleContainer:GetChildren()) do if ch:IsA("Frame") or ch:IsA("TextLabel") then ch:Destroy() end end
    local mods = K.LoadedModules or {}
    local hasErr = false
    for name, data in pairs(mods) do
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1,0,0, data.error and 48 or 24)
        Row.BackgroundTransparency = 1
        Row.ZIndex = 14
        Row.Parent = ConsoleContainer
        local St = Instance.new("TextLabel")
        St.Size = UDim2.new(1,0,0,20)
        St.BackgroundTransparency = 1
        St.Font = Enum.Font.GothamBold
        St.TextSize = 13
        St.TextColor3 = data.status=="OK" and Theme.Green or Theme.Danger
        St.TextXAlignment = Enum.TextXAlignment.Left
        St.ZIndex = 15
        St.Text = string.format("[%s] %s: %s", data.status=="OK" and "✓" or "✗", name, data.status=="OK" and Tr("ModuleStatus_OK") or Tr("ModuleStatus_FAIL"))
        St.Parent = Row
        if data.error then
            hasErr = true
            local Er = Instance.new("TextLabel")
            Er.Size = UDim2.new(1,-8,0,24)
            Er.Position = UDim2.new(0,8,0,20)
            Er.BackgroundTransparency = 1
            Er.Font = Enum.Font.Gotham
            Er.TextSize = 11
            Er.TextColor3 = Theme.Danger
            Er.TextWrapped = true
            Er.TextXAlignment = Enum.TextXAlignment.Left
            Er.ZIndex = 15
            Er.Text = tostring(data.error)
            Er.Parent = Row
        end
    end
    if not hasErr then
        local Ne = Instance.new("TextLabel")
        Ne.Size = UDim2.new(1,0,0,30)
        Ne.BackgroundTransparency = 1
        Ne.Font = Enum.Font.Gotham
        Ne.TextSize = 13
        Ne.TextColor3 = Theme.SubText
        Ne.Text = Tr("NoErrors")
        Ne.ZIndex = 14
        Ne.Parent = ConsoleContainer
    end
end

local ClearBtn = Instance.new("TextButton")
ClearBtn.Size = UDim2.new(1,0,0,30)
ClearBtn.BackgroundColor3 = Theme.Danger
ClearBtn.BackgroundTransparency = 0.2
ClearBtn.BorderSizePixel = 0
ClearBtn.Text = Tr("ClearConsole")
ClearBtn.TextColor3 = Theme.Text
ClearBtn.Font = Enum.Font.GothamBold
ClearBtn.TextSize = 12
ClearBtn.ZIndex = 13
ClearBtn.Parent = ConsoleTab.Page
Instance.new("UICorner", ClearBtn).CornerRadius = UDim.new(0,6)
ClearBtn.MouseButton1Click:Connect(function() playClick() K.LoadedModules={} RefreshConsole() end)
ClearBtn.MouseEnter:Connect(playHover)
task.spawn(function() while task.wait(1) do if ConsoleTab.Page.Visible then RefreshConsole() end end end)

-- Settings Tab
AddSection(SettingsTab, "Sec_Config")
AddButton(SettingsTab, "SaveConfig", "SaveConfig", function() K.SaveConfig() end)
AddButton(SettingsTab, "LoadConfig", "LoadConfig", function() K.LoadConfig() end)
AddButton(SettingsTab, "ResetConfig", "ResetConfig", function()
    for cat, tbl in pairs(K.Settings) do
        if type(tbl) == "table" then
            for k, v in pairs(tbl) do
                if type(v) == "boolean" then K.Settings[cat][k] = false
                elseif type(v) == "number" then K.Settings[cat][k] = 0 end
            end
        end
    end
    K.Notify("Config", "Settings reset to defaults", "success")
    RefreshConsole()
end)

AddSection(SettingsTab, "Sec_UI")
if K.GetSetting("UI.AccentColor") == nil then K.Settings.UI = K.Settings.UI or {} K.Settings.UI.AccentColor = Theme.Accent end
AddColorPicker(SettingsTab, "AccentColor", "UI.AccentColor")
if K.GetSetting("UI.Transparency") == nil then K.Settings.UI.Transparency = 0.05 end
AddSlider(SettingsTab, "UITransparency", "UI.Transparency", 0, 0.9)
if K.GetSetting("UI.Scale") == nil then K.Settings.UI.Scale = 1 end
AddSlider(SettingsTab, "UIScale", "UI.Scale", 0.5, 1.5)

AddSection(SettingsTab, "Sec_Info")
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1,0,0,60)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextSize = 12
InfoLabel.TextColor3 = Theme.SubText
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
InfoLabel.Text = "KIRO LOADER v1.2.0\nMulti-game cheat menu\nF4 - Toggle menu\nRight-click drag - Move window"
InfoLabel.ZIndex = 13
InfoLabel.Parent = SettingsTab.Page

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local query = SearchBox.Text:lower()
    for _, tab in ipairs(Tabs) do
        for _, child in ipairs(tab.Page:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") then
                local text = child.Text and child.Text:lower() or ""
                local lbl = child:FindFirstChild("Title")
                if lbl then text = lbl.Text:lower() end
                child.Visible = query == "" or text:find(query, 1, true)
            end
        end
    end
end)

LangButton.MouseButton1Click:Connect(function() playClick()
    local langs = {"RU","EN","JA"}
    local idx = 1
    for i,l in ipairs(langs) do if l==K.Lang then idx=i end end
    K.Lang = langs[(idx%#langs)+1]
    LangButton.Text = K.Lang
    for _,fn in ipairs(TranslatableElements) do pcall(fn) end
    SearchBox.PlaceholderText = Tr("SearchPlaceholder")
    RefreshConsole()
end)

CloseButton.MouseButton1Click:Connect(function() playClick()
    TweenService:Create(overlay, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1, Size = UDim2.new(0,600,0,400)}):Play()
    task.wait(0.2)
    ScreenGui.Enabled = false
end)

UserInputService.InputBegan:Connect(function(input,gp) if not gp and input.KeyCode==Enum.KeyCode.F4 then ScreenGui.Enabled=not ScreenGui.Enabled if ScreenGui.Enabled then playClick() end end end)

local customCursor = Instance.new("ImageLabel")
customCursor.Name = "CustomCursor"
customCursor.Size = UDim2.new(0,24,0,24)
customCursor.BackgroundTransparency = 1
customCursor.Image = "rbxassetid://7072725342"
customCursor.ZIndex = 999999
customCursor.Visible = false
customCursor.Parent = ScreenGui

RunService.RenderStepped:Connect(function()
    if ScreenGui.Enabled then
        if UserInputService.MouseBehavior~=Enum.MouseBehavior.Default then UserInputService.MouseBehavior=Enum.MouseBehavior.Default end
        if not UserInputService.MouseIconEnabled then UserInputService.MouseIconEnabled=true end
        local mp = UserInputService:GetMouseLocation()
        customCursor.Position = UDim2.new(0, mp.X - 12, 0, mp.Y - 12)
        customCursor.Visible = true
    else
        customCursor.Visible = false
    end
end)

K.UI = {ScreenGui=ScreenGui, Main=Main, AddSection=AddSection, AddToggle=AddToggle, AddSlider=AddSlider, AddDropdown=AddDropdown, AddButton=AddButton, AddColorPicker=AddColorPicker, AddKeybind=AddKeybind, RefreshConsole=RefreshConsole}
return K.UI