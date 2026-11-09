-- ui.lua | Kiro Scripts UI Library
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Получение глобальной таблицы K (совместимость с любым лоадером)
local env = (getgenv and getgenv()) or _G or shared
local K = env.K or _G.K or shared.K or {}
env.K = K
_G.K = K

K.Settings = K.Settings or {}
K.Lang = K.Lang or "RU"
K.GameId = K.GameId or "Universal"
K.LoadedModules = K.LoadedModules or {}

-- Безопасные функции чтения и записи настроек по пути "Раздел.Функция"
if type(K.GetSetting) ~= "function" then
    function K.GetSetting(path)
        if type(path) ~= "string" then return nil end
        if K.Settings[path] ~= nil then
            return K.Settings[path]
        end
        local current = K.Settings
        for part in string.gmatch(path, "[^%.]+") do
            if type(current) == "table" and current[part] ~= nil then
                current = current[part]
            else
                return nil
            end
        end
        return current
    end
end

if type(K.SetSetting) ~= "function" then
    function K.SetSetting(path, value)
        if type(path) ~= "string" then return end
        K.Settings[path] = value
        local parts = {}
        for part in string.gmatch(path, "[^%.]+") do
            table.insert(parts, part)
        end
        local current = K.Settings
        for i = 1, #parts - 1 do
            local key = parts[i]
            if type(current[key]) ~= "table" then
                current[key] = {}
            end
            current = current[key]
        end
        current[parts[#parts]] = value
        if type(K.OnSettingChanged) == "function" then
            pcall(K.OnSettingChanged, path, value)
        end
    end
end

-- Авто-определение игры по PlaceId, если K.GameId не задан явно
local function DetectGame()
    local gId = tostring(K.GameId or ""):lower()
    if gId:find("valiant") or gId:find("vd") then return "ValiantDistrict" end
    if gId:find("csgo") or gId:find("cs") or gId:find("cb") or gId:find("counter") then return "CSGO" end
    if gId:find("fust") or gId:find("rust") then return "FUST" end
    return "All"
end

-- Палитра темы
local Theme = {
    Background = Color3.fromRGB(18, 18, 26),
    Sidebar    = Color3.fromRGB(22, 22, 32),
    Content    = Color3.fromRGB(24, 24, 36),
    Element    = Color3.fromRGB(34, 34, 50),
    ElementHov = Color3.fromRGB(44, 44, 64),
    Accent     = Color3.fromRGB(138, 100, 255),
    AccentDark = Color3.fromRGB(95, 65, 190),
    Accent2    = Color3.fromRGB(170, 90, 240),
    Text       = Color3.fromRGB(245, 245, 255),
    SubText    = Color3.fromRGB(170, 170, 195),
    Danger     = Color3.fromRGB(235, 75, 95),
    Green      = Color3.fromRGB(80, 220, 140),
    Border     = Color3.fromRGB(60, 60, 85),
    OverlayDark = Color3.fromRGB(0, 0, 0),
}

-- Словарь локализации (RU / EN / JA)
local Translations = {
    RU = {
        Tab_Combat = "Бой",
        Tab_Visuals = "Визуалы",
        Tab_Utility = "Утилиты",
        Tab_Misc = "Разное",
        Tab_Console = "Консоль",

        Sec_Aimbot = "АИМБОТ И ОРУЖИЕ",
        Sec_CSGO = "CS:GO ФУНКЦИИ",
        Sec_ESP = "ESP И ПОДСВЕТКА",
        Sec_Valiant = "VALIANT DISTRICT",
        Sec_FUST = "FUST ФУНКЦИИ",
        Sec_Movement = "ПЕРЕДВИЖЕНИЕ",
        Sec_World = "МИР И ИГРОК",

        Aimbot = "Включить Аимбот",
        SilentAim = "Сайлент Аим",
        ShowFOV = "Показать радиус FOV",
        FOV = "Радиус FOV",
        Smoothness = "Плавность наводки",
        WallCheck = "Проверка стен",
        TeamCheck = "Проверка команды",

        Triggerbot = "Триггербот (Triggerbot)",
        TriggerDelay = "Задержка триггера (мс)",
        RCS = "Контроль отдачи (RCS)",
        RCSStrength = "Сила контроля отдачи (%)",
        AutoBuy = "Авто-Закуп (Auto-Buy)",

        ESPEnabled = "Включить ESP",
        BoxESP = "Боксы (Box ESP)",
        NameESP = "Имена игроков",
        HealthESP = "Полоска здоровья",
        Tracers = "Линии до игроков (Tracers)",
        TracerOrigin = "Откуда рисовать трейсеры",
        Snaplines = "Snaplines (от краев экрана)",
        Chams = "Чамсы (Подсветка моделей)",
        MaxDistance = "Макс. дистанция ESP",
        Radar = "Радар",

        AutoRepair = "Авто-Починка (Auto Repair)",
        AutoSkillCheck = "Авто Скилл-Чек (Auto Skill Check)",
        KillerESP = "ESP на Маньяка",
        GeneratorESP = "ESP на Генераторы",

        AutoFarm = "Авто-Фарм ресурсов (Auto-Farm)",
        Speed = "Ускорение (Speed Hack)",
        ChestESP = "ESP на сундуки",
        AutoSwing = "Авто-удар по ресурсам",
        AutoCollect = "Авто-сбор лута",

        Fly = "Полет (Fly)",
        FlySpeed = "Скорость полета",
        Noclip = "Сквозь стены (Noclip)",
        InfJump = "Бесконечный прыжок (Inf Jump)",
        WalkSpeed = "Скорость ходьбы (WalkSpeed)",
        JumpPower = "Сила прыжка (JumpPower)",
        BunnyHop = "Баннихоп (BunnyHop)",
        Fullbright = "Яркое освещение (Fullbright)",

        ModuleStatus_OK = "Загружен",
        ModuleStatus_FAIL = "Ошибка",
        ConsoleTitle = "Системная консоль",
        ClearConsole = "Очистить консоль",
        NoErrors = "Ошибок нет",
    },
    EN = {
        Tab_Combat = "Combat",
        Tab_Visuals = "Visuals",
        Tab_Utility = "Utility",
        Tab_Misc = "Misc",
        Tab_Console = "Console",

        Sec_Aimbot = "AIMBOT & WEAPON",
        Sec_CSGO = "CS:GO FEATURES",
        Sec_ESP = "ESP & VISUALS",
        Sec_Valiant = "VALIANT DISTRICT",
        Sec_FUST = "FUST FEATURES",
        Sec_Movement = "MOVEMENT",
        Sec_World = "WORLD & PLAYER",

        Aimbot = "Enable Aimbot",
        SilentAim = "Silent Aim",
        ShowFOV = "Show FOV Circle",
        FOV = "FOV Radius",
        Smoothness = "Aim Smoothness",
        WallCheck = "Wall Check",
        TeamCheck = "Team Check",

        Triggerbot = "Triggerbot",
        TriggerDelay = "Trigger Delay (ms)",
        RCS = "Recoil Control (RCS)",
        RCSStrength = "RCS Strength (%)",
        AutoBuy = "Auto-Buy Gear",

        ESPEnabled = "Enable ESP",
        BoxESP = "Box ESP",
        NameESP = "Name ESP",
        HealthESP = "Health Bar",
        Tracers = "Tracers",
        TracerOrigin = "Tracer Origin",
        Snaplines = "Snaplines (Screen Edges)",
        Chams = "Chams Highlight",
        MaxDistance = "ESP Max Distance",
        Radar = "Radar",

        AutoRepair = "Auto Repair",
        AutoSkillCheck = "Auto Skill Check",
        KillerESP = "Killer ESP",
        GeneratorESP = "Generator ESP",

        AutoFarm = "Auto-Farm",
        Speed = "Speed Hack",
        ChestESP = "Chest ESP",
        AutoSwing = "Auto Swing",
        AutoCollect = "Auto Collect",

        Fly = "Fly",
        FlySpeed = "Fly Speed",
        Noclip = "Noclip",
        InfJump = "Infinite Jump",
        WalkSpeed = "WalkSpeed",
        JumpPower = "JumpPower",
        BunnyHop = "BunnyHop",
        Fullbright = "Fullbright",

        ModuleStatus_OK = "Loaded",
        ModuleStatus_FAIL = "Failed",
        ConsoleTitle = "System Console",
        ClearConsole = "Clear Console",
        NoErrors = "No errors",
    },
    JA = {
        Tab_Combat = "戦闘",
        Tab_Visuals = "ビジュアル",
        Tab_Utility = "ユーティリティ",
        Tab_Misc = "その他",
        Tab_Console = "コンソール",

        Sec_Aimbot = "エイムボットと武器",
        Sec_CSGO = "CS:GO機能",
        Sec_ESP = "ESPと視覚化",
        Sec_Valiant = "VALIANT DISTRICT",
        Sec_FUST = "FUST機能",
        Sec_Movement = "移動",
        Sec_World = "ワールドとプレイヤー",

        Aimbot = "エイムボットを有効化",
        SilentAim = "サイレントエイム",
        ShowFOV = "FOV円を表示",
        FOV = "FOV半径",
        Smoothness = "エイムの滑らかさ",
        WallCheck = "壁チェック",
        TeamCheck = "チームチェック",

        Triggerbot = "トリガーボット",
        TriggerDelay = "トリガー遅延 (ms)",
        RCS = "リコイル制御 (RCS)",
        RCSStrength = "RCS強度 (%)",
        AutoBuy = "自動購入",

        ESPEnabled = "ESPを有効化",
        BoxESP = "ボックス ESP",
        NameESP = "名前 ESP",
        HealthESP = "ヘルスバー",
        Tracers = "トレーサー",
        TracerOrigin = "トレーサーの始点",
        Snaplines = "スナップライン (画面端)",
        Chams = "チャムス (モデルハイライト)",
        MaxDistance = "ESP最大距離",
        Radar = "レーダー",

        AutoRepair = "自動修理",
        AutoSkillCheck = "自動スキルチェック",
        KillerESP = "キラー ESP",
        GeneratorESP = "発電機 ESP",

        AutoFarm = "自動ファーム",
        Speed = "スピードハック",
        ChestESP = "チェスト ESP",
        AutoSwing = "自動スイング",
        AutoCollect = "自動収集",

        Fly = "フライ",
        FlySpeed = "フライ速度",
        Noclip = "ノックリップ",
        InfJump = "無限ジャンプ",
        WalkSpeed = "歩行速度",
        JumpPower = "ジャンプ力",
        BunnyHop = "バニーホップ",
        Fullbright = "フルブライト",

        ModuleStatus_OK = "読み込み済み",
        ModuleStatus_FAIL = "失敗",
        ConsoleTitle = "システムコンソール",
        ClearConsole = "コンソールをクリア",
        NoErrors = "エラーなし",
    }
}

local function Tr(key)
    local langTable = Translations[K.Lang] or Translations.RU
    return langTable[key] or key
end

-- Удаление старого UI при перезапуске
local GuiParent = (gethui and gethui()) or CoreGui
local OldGui = GuiParent:FindFirstChild("KiroScriptsUI") or (LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("KiroScriptsUI"))
if OldGui then
    OldGui:Destroy()
end

-- 1. Создание ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KiroScriptsUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local okParent = pcall(function()
    ScreenGui.Parent = GuiParent
end)
if not okParent or not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Полноэкранный затемненный оверлей (ZIndex = 1)
local overlay = Instance.new("Frame")
overlay.Name = "Overlay"
overlay.Parent = ScreenGui
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.Position = UDim2.new(0, 0, 0, 0)
overlay.BackgroundColor3 = Theme.OverlayDark
overlay.BackgroundTransparency = 0.5
overlay.BorderSizePixel = 0
overlay.ZIndex = 1

-- 2. Главное окно
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = ScreenGui
Main.Size = UDim2.new(0, 620, 0, 440)
Main.Position = UDim2.new(0.5, -310, 0.5, -220)
Main.BackgroundColor3 = Theme.Background
Main.BackgroundTransparency = 0.05
Main.BorderSizePixel = 0
Main.ZIndex = 10
Main.ClipsDescendants = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

-- Аниме-фон внутри окна (ZIndex = 1)
local bg = Instance.new("ImageLabel")
bg.Name = "AnimeBackground"
bg.Parent = Main
bg.Size = UDim2.new(1, 0, 1, 0)
bg.Position = UDim2.new(0, 0, 0, 0)
bg.BackgroundTransparency = 1
bg.Image = "rbxassetid://135051563569214"
bg.ScaleType = Enum.ScaleType.Crop
bg.ImageTransparency = 0.25
bg.ZIndex = 1

-- Затемнение поверх фона для читаемости
local bgOverlay = Instance.new("Frame")
bgOverlay.Name = "BackgroundOverlay"
bgOverlay.Parent = Main
bgOverlay.Size = UDim2.new(1, 0, 1, 0)
bgOverlay.Position = UDim2.new(0, 0, 0, 0)
bgOverlay.BackgroundColor3 = Theme.OverlayDark
bgOverlay.BackgroundTransparency = 0.4
bgOverlay.BorderSizePixel = 0
bgOverlay.ZIndex = 2

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.Accent
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.3
MainStroke.Parent = Main

-- Верхняя панель (TopBar)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = Main
TopBar.Size = UDim2.new(1, 0, 0, 48)
TopBar.Position = UDim2.new(0, 0, 0, 0)
TopBar.BackgroundColor3 = Theme.Sidebar
TopBar.BackgroundTransparency = 0.2
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 11

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 12)
TopBarCorner.Parent = TopBar

-- Фикс скругления только верхних углов
local TopBarFix = Instance.new("Frame")
TopBarFix.Parent = TopBar
TopBarFix.Size = UDim2.new(1, 0, 0, 12)
TopBarFix.Position = UDim2.new(0, 0, 1, -12)
TopBarFix.BackgroundColor3 = Theme.Sidebar
TopBarFix.BackgroundTransparency = 0.2
TopBarFix.BorderSizePixel = 0
TopBarFix.ZIndex = 11

-- Логотип
local Logo = Instance.new("Frame")
Logo.Size = UDim2.new(0, 36, 0, 36)
Logo.Position = UDim2.new(0, 12, 0.5, -18)
Logo.BackgroundColor3 = Theme.Accent
Logo.BorderSizePixel = 0
Logo.ZIndex = 12
Instance.new("UICorner", Logo).CornerRadius = UDim.new(0, 8)

local logoGrad = Instance.new("UIGradient", Logo)
logoGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Theme.Accent),
    ColorSequenceKeypoint.new(0.5, Theme.Accent2),
    ColorSequenceKeypoint.new(1, Theme.Accent)
}
logoGrad.Rotation = 0

local LogoK = Instance.new("TextLabel", Logo)
LogoK.Size = UDim2.new(1, 0, 1, 0)
LogoK.BackgroundTransparency = 1
LogoK.Text = "K"
LogoK.TextColor3 = Color3.fromRGB(255, 255, 255)
LogoK.Font = Enum.Font.GothamBold
LogoK.TextSize = 20
LogoK.ZIndex = 13

task.spawn(function()
    while Logo and Logo.Parent do
        logoGrad.Rotation = (logoGrad.Rotation + 1.5) % 360
        task.wait(0.03)
    end
end)

-- Заголовок
local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(0, 200, 0, 22)
Title.Position = UDim2.new(0, 56, 0, 6)
Title.BackgroundTransparency = 1
Title.Text = "KIRO SCRIPTS"
Title.TextColor3 = Theme.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 12

-- Версия и F4 подсказка
local Subtitle = Instance.new("TextLabel", TopBar)
Subtitle.Size = UDim2.new(0, 200, 0, 14)
Subtitle.Position = UDim2.new(0, 56, 0, 28)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "v1.2.0  •  [F4] Toggle"
Subtitle.TextColor3 = Theme.SubText
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 10
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.ZIndex = 12

-- Аватарка
local Avatar = Instance.new("ImageLabel")
Avatar.Name = "Avatar"
Avatar.Parent = TopBar
Avatar.Size = UDim2.new(0, 32, 0, 32)
Avatar.Position = UDim2.new(1, -220, 0.5, -16)
Avatar.BackgroundColor3 = Theme.Element
Avatar.BorderSizePixel = 0
Avatar.ZIndex = 12
Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)

task.spawn(function()
    local ok, img = pcall(function()
        return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    end)
    if ok and img then Avatar.Image = img end
end)

-- Никнейм
local NickLabel = Instance.new("TextLabel")
NickLabel.Name = "Nick"
NickLabel.Parent = TopBar
NickLabel.Size = UDim2.new(0, 120, 0, 16)
NickLabel.Position = UDim2.new(1, -184, 0.5, -16)
NickLabel.BackgroundTransparency = 1
NickLabel.Text = LocalPlayer.Name
NickLabel.TextColor3 = Theme.Text
NickLabel.Font = Enum.Font.GothamBold
NickLabel.TextSize = 12
NickLabel.TextXAlignment = Enum.TextXAlignment.Right
NickLabel.ZIndex = 12

-- Живое время
local TimeLabel = Instance.new("TextLabel")
TimeLabel.Name = "Time"
TimeLabel.Parent = TopBar
TimeLabel.Size = UDim2.new(0, 120, 0, 14)
TimeLabel.Position = UDim2.new(1, -184, 0.5, 0)
TimeLabel.BackgroundTransparency = 1
TimeLabel.Text = os.date("%H:%M:%S")
TimeLabel.TextColor3 = Theme.SubText
TimeLabel.Font = Enum.Font.Gotham
TimeLabel.TextSize = 10
TimeLabel.TextXAlignment = Enum.TextXAlignment.Right
TimeLabel.ZIndex = 12

task.spawn(function()
    while ScreenGui and ScreenGui.Parent do
        TimeLabel.Text = os.date("%H:%M:%S")
        task.wait(1)
    end
end)

-- Переключатель языка (RU/EN/JA)
local LangButton = Instance.new("TextButton")
LangButton.Name = "LangButton"
LangButton.Parent = TopBar
LangButton.Size = UDim2.new(0, 48, 0, 28)
LangButton.Position = UDim2.new(1, -96, 0.5, -14)
LangButton.BackgroundColor3 = Theme.Element
LangButton.BackgroundTransparency = 0.15
LangButton.BorderSizePixel = 0
LangButton.Text = K.Lang
LangButton.TextColor3 = Theme.Text
LangButton.Font = Enum.Font.GothamBold
LangButton.TextSize = 12
LangButton.ZIndex = 12
Instance.new("UICorner", LangButton).CornerRadius = UDim.new(0, 6)

-- Кастомный круглый крестик
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = TopBar
CloseButton.Size = UDim2.new(0, 32, 0, 32)
CloseButton.Position = UDim2.new(1, -40, 0.5, -16)
CloseButton.BackgroundColor3 = Theme.Danger
CloseButton.BackgroundTransparency = 0.15
CloseButton.BorderSizePixel = 0
CloseButton.Text = "✕"
CloseButton.TextColor3 = Theme.Text
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.ZIndex = 12
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(1, 0)

-- 3. Сайдбар и Контент
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Parent = Main
Sidebar.Size = UDim2.new(0, 150, 1, -58)
Sidebar.Position = UDim2.new(0, 6, 0, 52)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BackgroundTransparency = 0.2
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 11

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 8)
SidebarCorner.Parent = Sidebar

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Parent = Sidebar
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 6)

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.Parent = Sidebar
SidebarPadding.PaddingTop = UDim.new(0, 8)
SidebarPadding.PaddingLeft = UDim.new(0, 8)
SidebarPadding.PaddingRight = UDim.new(0, 8)

local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "Content"
ContentContainer.Parent = Main
ContentContainer.Size = UDim2.new(1, -168, 1, -58)
ContentContainer.Position = UDim2.new(0, 162, 0, 52)
ContentContainer.BackgroundColor3 = Theme.Content
ContentContainer.BackgroundTransparency = 0.2
ContentContainer.BorderSizePixel = 0
ContentContainer.ZIndex = 11

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 8)
ContentCorner.Parent = ContentContainer

-- Перетаскивание главного окна за TopBar
local windowDragging = false
local dragStartPos = nil
local mainStartPos = nil
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
        Main.Position = UDim2.new(
            mainStartPos.X.Scale,
            mainStartPos.X.Offset + delta.X,
            mainStartPos.Y.Scale,
            mainStartPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        windowDragging = false
    end
end)

-- Хранилище для динамического обновления текстов при смене языка
local TranslatableElements = {}
local function BindTranslation(instance, key, formatter)
    local function apply()
        local baseText = Tr(key)
        if formatter then
            instance.Text = formatter(baseText)
        else
            instance.Text = baseText
        end
    end
    table.insert(TranslatableElements, apply)
    apply()
end

-- Система вкладок
local Tabs = {}
local ActiveTab = nil

local function SelectTab(tabObj)
    ActiveTab = tabObj
    for _, t in ipairs(Tabs) do
        local isSelected = (t == tabObj)
        t.Page.Visible = isSelected
        TweenService:Create(t.Button, TweenInfo.new(0.15), {
            BackgroundColor3 = isSelected and Theme.Accent or Theme.Element,
            BackgroundTransparency = isSelected and 0.1 or 0.35
        }):Play()
    end
end

local function CreateTab(langKey, order)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = langKey
    TabButton.Parent = Sidebar
    TabButton.LayoutOrder = order
    TabButton.Size = UDim2.new(1, 0, 0, 36)
    TabButton.BackgroundColor3 = Theme.Element
    TabButton.BackgroundTransparency = 0.35
    TabButton.BorderSizePixel = 0
    TabButton.Font = Enum.Font.GothamBold
    TabButton.TextSize = 14
    TabButton.TextScaled = false
    TabButton.TextColor3 = Theme.Text
    TabButton.ZIndex = 12

    local TabBtnCorner = Instance.new("UICorner")
    TabBtnCorner.CornerRadius = UDim.new(0, 6)
    TabBtnCorner.Parent = TabButton

    BindTranslation(TabButton, langKey)

    local Page = Instance.new("ScrollingFrame")
    Page.Name = langKey .. "_Page"
    Page.Parent = ContentContainer
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.Position = UDim2.new(0, 0, 0, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 4
    Page.ScrollBarImageColor3 = Theme.Accent
    Page.ScrollBarImageTransparency = 0.3
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.Visible = false
    Page.ZIndex = 12

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Parent = Page
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 8)

    local PagePadding = Instance.new("UIPadding")
    PagePadding.Parent = Page
    PagePadding.PaddingTop = UDim.new(0, 10)
    PagePadding.PaddingBottom = UDim.new(0, 12)
    PagePadding.PaddingLeft = UDim.new(0, 12)
    PagePadding.PaddingRight = UDim.new(0, 12)

    local tabObj = {
        Button = TabButton,
        Page = Page,
        NextOrder = 0
    }

    TabButton.MouseButton1Click:Connect(function()
        SelectTab(tabObj)
    end)

    table.insert(Tabs, tabObj)
    if #Tabs == 1 then
        SelectTab(tabObj)
    end

    return tabObj
end

-- 4. Рабочие функции AddSection, AddToggle, AddSlider

-- Заголовки секций
local function AddSection(tabObj, langKey)
    tabObj.NextOrder = tabObj.NextOrder + 1

    local SectionLabel = Instance.new("TextLabel")
    SectionLabel.Name = "Section_" .. langKey
    SectionLabel.Parent = tabObj.Page
    SectionLabel.LayoutOrder = tabObj.NextOrder
    SectionLabel.Size = UDim2.new(1, 0, 0, 22)
    SectionLabel.BackgroundTransparency = 1
    SectionLabel.Font = Enum.Font.GothamBold
    SectionLabel.TextSize = 12
    SectionLabel.TextScaled = false
    SectionLabel.TextColor3 = Theme.Accent
    SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    SectionLabel.ZIndex = 13

    BindTranslation(SectionLabel, langKey)
    return SectionLabel
end

-- Тумблеры
local function AddToggle(tabObj, langKey, settingPath, callback)
    tabObj.NextOrder = tabObj.NextOrder + 1
    local state = (K.GetSetting(settingPath) == true)

    local ToggleFrame = Instance.new("TextButton")
    ToggleFrame.Name = "Toggle_" .. settingPath
    ToggleFrame.Parent = tabObj.Page
    ToggleFrame.LayoutOrder = tabObj.NextOrder
    ToggleFrame.Size = UDim2.new(1, 0, 0, 36)
    ToggleFrame.BackgroundColor3 = Theme.Element
    ToggleFrame.BackgroundTransparency = 0.2
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Text = ""
    ToggleFrame.AutoButtonColor = false
    ToggleFrame.ZIndex = 13

    local FrameCorner = Instance.new("UICorner")
    FrameCorner.CornerRadius = UDim.new(0, 6)
    FrameCorner.Parent = ToggleFrame

    local Label = Instance.new("TextLabel")
    Label.Name = "Title"
    Label.Parent = ToggleFrame
    Label.Size = UDim2.new(1, -65, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 14
    Label.TextScaled = false
    Label.TextColor3 = Theme.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 14

    BindTranslation(Label, langKey)

    local SwitchBg = Instance.new("Frame")
    SwitchBg.Name = "SwitchBg"
    SwitchBg.Parent = ToggleFrame
    SwitchBg.Size = UDim2.new(0, 40, 0, 20)
    SwitchBg.Position = UDim2.new(1, -52, 0.5, -10)
    SwitchBg.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(55, 55, 75)
    SwitchBg.BorderSizePixel = 0
    SwitchBg.ZIndex = 14

    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = SwitchBg

    local Knob = Instance.new("Frame")
    Knob.Name = "Knob"
    Knob.Parent = SwitchBg
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    Knob.BackgroundColor3 = Theme.Text
    Knob.BorderSizePixel = 0
    Knob.ZIndex = 15

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    local function UpdateVisual(newState)
        state = newState
        K.SetSetting(settingPath, state)
        TweenService:Create(SwitchBg, TweenInfo.new(0.15), {
            BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(55, 55, 75)
        }):Play()
        TweenService:Create(Knob, TweenInfo.new(0.15), {
            Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        }):Play()
        if type(callback) == "function" then
            pcall(callback, state)
        end
    end

    ToggleFrame.MouseButton1Click:Connect(function()
        UpdateVisual(not state)
    end)

    return ToggleFrame
end

-- Слайдеры (ИСПРАВЛЕННЫЕ - РАБОЧИЕ)
local function AddSlider(tabObj, langKey, settingPath, minVal, maxVal, callback)
    tabObj.NextOrder = tabObj.NextOrder + 1

    local savedVal = tonumber(K.GetSetting(settingPath))
    local currentValue = savedVal and math.clamp(savedVal, minVal, maxVal) or minVal
    local initialAlpha = math.clamp((currentValue - minVal) / math.max(maxVal - minVal, 1), 0, 1)

    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = "Slider_" .. settingPath
    SliderFrame.Parent = tabObj.Page
    SliderFrame.LayoutOrder = tabObj.NextOrder
    SliderFrame.Size = UDim2.new(1, 0, 0, 50)
    SliderFrame.BackgroundColor3 = Theme.Element
    SliderFrame.BackgroundTransparency = 0.2
    SliderFrame.BorderSizePixel = 0
    SliderFrame.ZIndex = 13

    local FrameCorner = Instance.new("UICorner")
    FrameCorner.CornerRadius = UDim.new(0, 6)
    FrameCorner.Parent = SliderFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Parent = SliderFrame
    TitleLabel.Size = UDim2.new(1, -90, 0, 22)
    TitleLabel.Position = UDim2.new(0, 12, 0, 4)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamSemibold
    TitleLabel.TextSize = 14
    TitleLabel.TextScaled = false
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 14

    BindTranslation(TitleLabel, langKey)

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Name = "Value"
    ValueLabel.Parent = SliderFrame
    ValueLabel.Size = UDim2.new(0, 70, 0, 22)
    ValueLabel.Position = UDim2.new(1, -82, 0, 4)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextSize = 14
    ValueLabel.TextScaled = false
    ValueLabel.TextColor3 = Theme.Accent
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Text = tostring(currentValue)
    ValueLabel.ZIndex = 14

    -- Дорожка слайдера (track) - кликабельная
    local track = Instance.new("TextButton")
    track.Name = "Track"
    track.Parent = SliderFrame
    track.Size = UDim2.new(1, -24, 0, 8)
    track.Position = UDim2.new(0, 12, 0, 32)
    track.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    track.BorderSizePixel = 0
    track.Text = ""
    track.AutoButtonColor = false
    track.ZIndex = 14

    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(1, 0)
    TrackCorner.Parent = track

    -- Заполнение слайдера (fill)
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Parent = track
    fill.Size = UDim2.new(initialAlpha, 0, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    fill.ZIndex = 15

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = fill

    -- Ползунок (knob Frame)
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Parent = track
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(initialAlpha, -7, 0.5, -7)
    knob.BackgroundColor3 = Theme.Text
    knob.BorderSizePixel = 0
    knob.ZIndex = 16

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = knob

    local dragging = false

    local function UpdateSliderFromInput(input)
        local trackAbsPos = track.AbsolutePosition
        local trackAbsSize = track.AbsoluteSize
        if trackAbsSize.X == 0 then return end
        local rel = math.clamp((input.Position.X - trackAbsPos.X) / trackAbsSize.X, 0, 1)
        local value = math.floor(minVal + (maxVal - minVal) * rel + 0.5)
        local snappedRel = (value - minVal) / math.max(maxVal - minVal, 1)

        fill.Size = UDim2.new(snappedRel, 0, 1, 0)
        knob.Position = UDim2.new(snappedRel, -7, 0.5, -7)
        ValueLabel.Text = tostring(value)
        K.SetSetting(settingPath, value)

        if type(callback) == "function" then
            pcall(callback, value)
        end
    end

    -- Drag по knob
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            activeSliderDragging = true
            UpdateSliderFromInput(input)
        end
    end)

    -- Click по track
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            activeSliderDragging = true
            UpdateSliderFromInput(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateSliderFromInput(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if dragging then
                dragging = false
                activeSliderDragging = false
            end
        end
    end)

    return SliderFrame
end

-- Dropdown (для TracerOrigin)
local function AddDropdown(tabObj, langKey, settingPath, options, callback)
    tabObj.NextOrder = tabObj.NextOrder + 1
    local currentValue = K.GetSetting(settingPath) or options[1]

    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Name = "Dropdown_" .. settingPath
    DropdownFrame.Parent = tabObj.Page
    DropdownFrame.LayoutOrder = tabObj.NextOrder
    DropdownFrame.Size = UDim2.new(1, 0, 0, 36)
    DropdownFrame.BackgroundColor3 = Theme.Element
    DropdownFrame.BackgroundTransparency = 0.2
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.ZIndex = 13

    local FrameCorner = Instance.new("UICorner")
    FrameCorner.CornerRadius = UDim.new(0, 6)
    FrameCorner.Parent = DropdownFrame

    local Label = Instance.new("TextLabel")
    Label.Name = "Title"
    Label.Parent = DropdownFrame
    Label.Size = UDim2.new(1, -140, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 14
    Label.TextScaled = false
    Label.TextColor3 = Theme.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 14

    BindTranslation(Label, langKey)

    local Button = Instance.new("TextButton")
    Button.Name = "SelectBtn"
    Button.Parent = DropdownFrame
    Button.Size = UDim2.new(0, 120, 0, 24)
    Button.Position = UDim2.new(1, -132, 0.5, -12)
    Button.BackgroundColor3 = Theme.Accent
    Button.BackgroundTransparency = 0.2
    Button.BorderSizePixel = 0
    Button.Text = currentValue
    Button.TextColor3 = Theme.Text
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 12
    Button.ZIndex = 14
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 4)

    local isOpen = false
    local OptionsFrame = nil

    local function CloseDropdown()
        if OptionsFrame then
            OptionsFrame:Destroy()
            OptionsFrame = nil
        end
        isOpen = false
    end

    Button.MouseButton1Click:Connect(function()
        if isOpen then
            CloseDropdown()
            return
        end
        isOpen = true

        OptionsFrame = Instance.new("Frame")
        OptionsFrame.Name = "Options"
        OptionsFrame.Parent = DropdownFrame
        OptionsFrame.Size = UDim2.new(0, 120, 0, #options * 26)
        OptionsFrame.Position = UDim2.new(1, -132, 1, 4)
        OptionsFrame.BackgroundColor3 = Theme.Content
        OptionsFrame.BackgroundTransparency = 0.1
        OptionsFrame.BorderSizePixel = 0
        OptionsFrame.ZIndex = 20
        OptionsFrame.ClipsDescendants = true
        Instance.new("UICorner", OptionsFrame).CornerRadius = UDim.new(0, 4)

        local OptLayout = Instance.new("UIListLayout")
        OptLayout.Parent = OptionsFrame
        OptLayout.SortOrder = Enum.SortOrder.LayoutOrder

        for i, opt in ipairs(options) do
            local OptBtn = Instance.new("TextButton")
            OptBtn.Size = UDim2.new(1, 0, 0, 24)
            OptBtn.BackgroundTransparency = 1
            OptBtn.Text = opt
            OptBtn.TextColor3 = Theme.Text
            OptBtn.Font = Enum.Font.Gotham
            OptBtn.TextSize = 12
            OptBtn.TextXAlignment = Enum.TextXAlignment.Center
            OptBtn.ZIndex = 21
            OptBtn.LayoutOrder = i

            OptBtn.MouseButton1Click:Connect(function()
                currentValue = opt
                Button.Text = opt
                K.SetSetting(settingPath, opt)
                if type(callback) == "function" then pcall(callback, opt) end
                CloseDropdown()
            end)

            OptBtn.MouseEnter:Connect(function()
                OptBtn.BackgroundTransparency = 0.7
                OptBtn.BackgroundColor3 = Theme.Accent
            end)
            OptBtn.MouseLeave:Connect(function()
                OptBtn.BackgroundTransparency = 1
            end)

            OptBtn.Parent = OptionsFrame
        end
    end)

    -- Close on outside click
    UserInputService.InputBegan:Connect(function(input)
        if isOpen and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = input.Position
            local absPos = OptionsFrame.AbsolutePosition
            local absSize = OptionsFrame.AbsoluteSize
            if mousePos.X < absPos.X or mousePos.X > absPos.X + absSize.X or
               mousePos.Y < absPos.Y or mousePos.Y > absPos.Y + absSize.Y then
                CloseDropdown()
            end
        end
    end)

    return DropdownFrame
end

-- 5. Создание вкладок и наполнение
local ActiveGame = DetectGame()

local CombatTab  = CreateTab("Tab_Combat", 1)
local VisualsTab = CreateTab("Tab_Visuals", 2)
local UtilityTab = CreateTab("Tab_Utility", 3)
local MiscTab    = CreateTab("Tab_Misc", 4)
local ConsoleTab = CreateTab("Tab_Console", 5)

-- === ВКЛАДКА 1: БОЙ (COMBAT & CS:GO) ===
AddSection(CombatTab, "Sec_Aimbot")
if K.GetSetting("Combat.Aimbot") ~= nil then AddToggle(CombatTab, "Aimbot", "Combat.Aimbot") end
if K.GetSetting("Combat.SilentAim") ~= nil then AddToggle(CombatTab, "SilentAim", "Combat.SilentAim") end
if K.GetSetting("Combat.ShowFOV") ~= nil then AddToggle(CombatTab, "ShowFOV", "Combat.ShowFOV") end
if K.GetSetting("Combat.FOV") ~= nil then AddSlider(CombatTab, "FOV", "Combat.FOV", 20, 500) end
if K.GetSetting("Combat.Smoothness") ~= nil then AddSlider(CombatTab, "Smoothness", "Combat.Smoothness", 1, 30) end
if K.GetSetting("Combat.WallCheck") ~= nil then AddToggle(CombatTab, "WallCheck", "Combat.WallCheck") end
if K.GetSetting("Combat.TeamCheck") ~= nil then AddToggle(CombatTab, "TeamCheck", "Combat.TeamCheck") end

if ActiveGame == "CSGO" or ActiveGame == "All" then
    AddSection(CombatTab, "Sec_CSGO")
    if K.GetSetting("Combat.Triggerbot") ~= nil then AddToggle(CombatTab, "Triggerbot", "Combat.Triggerbot") end
    if K.GetSetting("Combat.TriggerDelay") ~= nil then AddSlider(CombatTab, "TriggerDelay", "Combat.TriggerDelay", 0, 500) end
    if K.GetSetting("Combat.RCS") ~= nil then AddToggle(CombatTab, "RCS", "Combat.RCS") end
    if K.GetSetting("Combat.RCSStrength") ~= nil then AddSlider(CombatTab, "RCSStrength", "Combat.RCSStrength", 0, 100) end
    if K.GetSetting("Combat.AutoBuy") ~= nil then AddToggle(CombatTab, "AutoBuy", "Combat.AutoBuy") end
end

-- === ВКЛАДКА 2: ВИЗУАЛЫ (VISUALS & ESP) ===
AddSection(VisualsTab, "Sec_ESP")
if K.GetSetting("Visuals.Enabled") ~= nil then AddToggle(VisualsTab, "ESPEnabled", "Visuals.Enabled") end
if K.GetSetting("Visuals.BoxESP") ~= nil then AddToggle(VisualsTab, "BoxESP", "Visuals.BoxESP") end
if K.GetSetting("Visuals.NameESP") ~= nil then AddToggle(VisualsTab, "NameESP", "Visuals.NameESP") end
if K.GetSetting("Visuals.HealthESP") ~= nil then AddToggle(VisualsTab, "HealthESP", "Visuals.HealthESP") end
if K.GetSetting("Visuals.Tracers") ~= nil then AddToggle(VisualsTab, "Tracers", "Visuals.Tracers") end
if K.GetSetting("Visuals.TracerOrigin") ~= nil then
    AddDropdown(VisualsTab, "TracerOrigin", "Visuals.TracerOrigin", {"Screen Bottom", "Crosshair", "Screen Center"}, nil)
end
if K.GetSetting("Visuals.Snaplines") ~= nil then AddToggle(VisualsTab, "Snaplines", "Visuals.Snaplines") end
if K.GetSetting("Visuals.Chams") ~= nil then AddToggle(VisualsTab, "Chams", "Visuals.Chams") end
if K.GetSetting("Visuals.Radar") ~= nil then AddToggle(VisualsTab, "Radar", "Visuals.Radar") end
if K.GetSetting("Visuals.ChestESP") ~= nil then AddToggle(VisualsTab, "ChestESP", "Visuals.ChestESP") end
if K.GetSetting("Visuals.MaxDistance") ~= nil then AddSlider(VisualsTab, "MaxDistance", "Visuals.MaxDistance", 100, 5000) end

-- === ВКЛАДКА 3: УТИЛИТЫ ===
if ActiveGame == "ValiantDistrict" or ActiveGame == "All" then
    AddSection(UtilityTab, "Sec_Valiant")
    if K.GetSetting("Utility.AutoRepair") ~= nil then AddToggle(UtilityTab, "AutoRepair", "Utility.AutoRepair") end
    if K.GetSetting("Utility.AutoSkillCheck") ~= nil then AddToggle(UtilityTab, "AutoSkillCheck", "Utility.AutoSkillCheck") end
    if K.GetSetting("Visuals.KillerESP") ~= nil then AddToggle(UtilityTab, "KillerESP", "Visuals.KillerESP") end
    if K.GetSetting("Visuals.GeneratorESP") ~= nil then AddToggle(UtilityTab, "GeneratorESP", "Visuals.GeneratorESP") end
end

if ActiveGame == "FUST" or ActiveGame == "All" then
    AddSection(UtilityTab, "Sec_FUST")
    if K.GetSetting("Utility.AutoFarm") ~= nil then AddToggle(UtilityTab, "AutoFarm", "Utility.AutoFarm") end
    if K.GetSetting("Utility.AutoSwing") ~= nil then AddToggle(UtilityTab, "AutoSwing", "Utility.AutoSwing") end
    if K.GetSetting("Utility.AutoCollect") ~= nil then AddToggle(UtilityTab, "AutoCollect", "Utility.AutoCollect") end
    if K.GetSetting("Utility.ChestESP") ~= nil then AddToggle(UtilityTab, "ChestESP", "Utility.ChestESP") end
    if K.GetSetting("Misc.Speed") ~= nil then AddToggle(UtilityTab, "Speed", "Misc.Speed") end
end

if ActiveGame == "CSGO" or ActiveGame == "All" then
    AddSection(UtilityTab, "Sec_CSGO")
    if K.GetSetting("Utility.AutoBuy") ~= nil then AddToggle(UtilityTab, "AutoBuy", "Utility.AutoBuy") end
    if K.GetSetting("Visuals.BombTimer") ~= nil then AddToggle(UtilityTab, "BombTimer", "Visuals.BombTimer") end
    if K.GetSetting("Visuals.AntiFlash") ~= nil then AddToggle(UtilityTab, "AntiFlash", "Visuals.AntiFlash") end
end

-- === ВКЛАДКА 4: РАЗНОЕ (MISC) ===
AddSection(MiscTab, "Sec_Movement")
if K.GetSetting("Misc.Fly") ~= nil then AddToggle(MiscTab, "Fly", "Misc.Fly") end
if K.GetSetting("Misc.FlySpeed") ~= nil then AddSlider(MiscTab, "FlySpeed", "Misc.FlySpeed", 10, 300) end
if K.GetSetting("Misc.Noclip") ~= nil then AddToggle(MiscTab, "Noclip", "Misc.Noclip") end
if K.GetSetting("Misc.InfJump") ~= nil then AddToggle(MiscTab, "InfJump", "Misc.InfJump") end
if K.GetSetting("Misc.Speed") ~= nil then AddToggle(MiscTab, "Speed", "Misc.Speed") end
if K.GetSetting("Misc.WalkSpeed") ~= nil then AddSlider(MiscTab, "WalkSpeed", "Misc.WalkSpeed", 16, 250) end
if K.GetSetting("Misc.JumpPower") ~= nil then AddSlider(MiscTab, "JumpPower", "Misc.JumpPower", 50, 300) end
if K.GetSetting("Misc.BunnyHop") ~= nil then AddToggle(MiscTab, "BunnyHop", "Misc.BunnyHop") end

AddSection(MiscTab, "Sec_World")
if K.GetSetting("Misc.Fullbright") ~= nil then AddToggle(MiscTab, "Fullbright", "Misc.Fullbright") end

-- === ВКЛАДКА 5: КОНСОЛЬ (DEBUGGER) ===
AddSection(ConsoleTab, "ConsoleTitle")

local ConsoleContainer = Instance.new("Frame")
ConsoleContainer.Name = "ConsoleContainer"
ConsoleContainer.Parent = ConsoleTab.Page
ConsoleContainer.Size = UDim2.new(1, 0, 1, -40)
ConsoleContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
ConsoleContainer.BackgroundTransparency = 0.1
ConsoleContainer.BorderSizePixel = 0
ConsoleContainer.ZIndex = 13
Instance.new("UICorner", ConsoleContainer).CornerRadius = UDim.new(0, 6)

local ConsoleLayout = Instance.new("UIListLayout")
ConsoleLayout.Parent = ConsoleContainer
ConsoleLayout.SortOrder = Enum.SortOrder.LayoutOrder
ConsoleLayout.Padding = UDim.new(0, 4)

local ConsolePadding = Instance.new("UIPadding")
ConsolePadding.Parent = ConsoleContainer
ConsolePadding.PaddingTop = UDim.new(0, 8)
ConsolePadding.PaddingLeft = UDim.new(0, 8)
ConsolePadding.PaddingRight = UDim.new(0, 8)
ConsolePadding.PaddingBottom = UDim.new(0, 8)

local function RefreshConsole()
    for _, child in ipairs(ConsoleContainer:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    local modules = K.LoadedModules or {}
    local hasErrors = false

    for moduleName, moduleData in pairs(modules) do
        local entryFrame = Instance.new("Frame")
        entryFrame.Size = UDim2.new(1, 0, 0, moduleData.error and 48 or 24)
        entryFrame.BackgroundTransparency = 1
        entryFrame.LayoutOrder = #ConsoleContainer:GetChildren()
        entryFrame.ZIndex = 14
        entryFrame.Parent = ConsoleContainer

        local StatusLabel = Instance.new("TextLabel")
        StatusLabel.Size = UDim2.new(1, 0, 0, 20)
        StatusLabel.Position = UDim2.new(0, 0, 0, 0)
        StatusLabel.BackgroundTransparency = 1
        StatusLabel.Font = Enum.Font.GothamBold
        StatusLabel.TextSize = 13
        StatusLabel.TextColor3 = moduleData.status == "OK" and Theme.Green or Theme.Danger
        StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
        StatusLabel.ZIndex = 15
        StatusLabel.Text = string.format("[%s] %s: %s",
            moduleData.status == "OK" and "✓" or "✗",
            moduleName,
            moduleData.status == "OK" and Tr("ModuleStatus_OK") or Tr("ModuleStatus_FAIL")
        )
        StatusLabel.Parent = entryFrame

        if moduleData.error then
            hasErrors = true
            local ErrorLabel = Instance.new("TextLabel")
            ErrorLabel.Size = UDim2.new(1, -8, 0, 24)
            ErrorLabel.Position = UDim2.new(0, 8, 0, 20)
            ErrorLabel.BackgroundTransparency = 1
            ErrorLabel.Font = Enum.Font.Gotham
            ErrorLabel.TextSize = 11
            ErrorLabel.TextColor3 = Theme.Danger
            ErrorLabel.TextWrapped = true
            ErrorLabel.TextXAlignment = Enum.TextXAlignment.Left
            ErrorLabel.ZIndex = 15
            ErrorLabel.Text = tostring(moduleData.error)
            ErrorLabel.Parent = entryFrame
        end
    end

    if not hasErrors then
        local NoErrorsLabel = Instance.new("TextLabel")
        NoErrorsLabel.Size = UDim2.new(1, 0, 0, 30)
        NoErrorsLabel.BackgroundTransparency = 1
        NoErrorsLabel.Font = Enum.Font.Gotham
        NoErrorsLabel.TextSize = 13
        NoErrorsLabel.TextColor3 = Theme.SubText
        NoErrorsLabel.Text = Tr("NoErrors")
        NoErrorsLabel.ZIndex = 14
        NoErrorsLabel.Parent = ConsoleContainer
    end
end

local ClearBtn = Instance.new("TextButton")
ClearBtn.Size = UDim2.new(1, 0, 0, 30)
ClearBtn.BackgroundColor3 = Theme.Danger
ClearBtn.BackgroundTransparency = 0.2
ClearBtn.BorderSizePixel = 0
ClearBtn.Text = Tr("ClearConsole")
ClearBtn.TextColor3 = Theme.Text
ClearBtn.Font = Enum.Font.GothamBold
ClearBtn.TextSize = 12
ClearBtn.ZIndex = 13
Instance.new("UICorner", ClearBtn).CornerRadius = UDim.new(0, 6)
ClearBtn.Parent = ConsoleTab.Page

ClearBtn.MouseButton1Click:Connect(function()
    K.LoadedModules = {}
    RefreshConsole()
end)

task.spawn(function()
    while task.wait(1) do
        if ConsoleTab.Page.Visible then
            RefreshConsole()
        end
    end
end)

-- Логика кнопок
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

LangButton.MouseButton1Click:Connect(function()
    local langs = {"RU", "EN", "JA"}
    local currentIdx = 1
    for i, l in ipairs(langs) do if l == K.Lang then currentIdx = i end end
    K.Lang = langs[(currentIdx % #langs) + 1]
    LangButton.Text = K.Lang
    for _, updateFn in ipairs(TranslatableElements) do
        pcall(updateFn)
    end
    RefreshConsole()
end)

-- Открытие/скрытие меню по F4
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F4 then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- Mouse fix: когда меню открыто - курсор свободен
RunService.RenderStepped:Connect(function()
    if ScreenGui.Enabled then
        if UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default then
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end
        if not UserInputService.MouseIconEnabled then
            UserInputService.MouseIconEnabled = true
        end
    end
end)

K.UI = {
    ScreenGui = ScreenGui,
    Main = Main,
    AddSection = AddSection,
    AddToggle = AddToggle,
    AddSlider = AddSlider,
    AddDropdown = AddDropdown,
    RefreshConsole = RefreshConsole,
    ConsoleTab = ConsoleTab,
}

return K.UI