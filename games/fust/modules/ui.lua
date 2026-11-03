-- ui.lua | Kiro Scripts UI Library
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Получение глобальной таблицы K (совместимость с любым лоадером)
local env = (getgenv and getgenv()) or _G or shared
local K = env.K or _G.K or shared.K or {}
env.K = K
_G.K = K

K.Settings = K.Settings or {}
K.Lang = K.Lang or "RU"
K.GameId = K.GameId or "Universal"

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

-- Гарантируем наличие базовых настроек, чтобы проверка K.GetSetting(...) ~= nil не скрывала нужные функции
local DefaultSettings = {
    -- Combat / CS:GO
    ["Combat.Aimbot"] = false,
    ["Combat.SilentAim"] = false,
    ["Combat.ShowFOV"] = true,
    ["Combat.FOV"] = 120,
    ["Combat.Smoothness"] = 5,
    ["Combat.WallCheck"] = true,
    ["Combat.TeamCheck"] = true,
    ["Combat.Triggerbot"] = false,
    ["Combat.TriggerDelay"] = 50,
    ["Combat.RCS"] = false,
    ["Combat.RCSStrength"] = 80,
    ["Combat.AutoBuy"] = false,

    -- Visuals / ESP
    ["Visuals.Enabled"] = false,
    ["Visuals.BoxESP"] = false,
    ["Visuals.NameESP"] = false,
    ["Visuals.HealthESP"] = false,
    ["Visuals.Tracers"] = false,
    ["Visuals.Chams"] = false,
    ["Visuals.ChestESP"] = false,
    ["Visuals.KillerESP"] = false,
    ["Visuals.GeneratorESP"] = false,
    ["Visuals.MaxDistance"] = 1000,

    -- Utility (Valiant District / FUST / CS:GO)
    ["Utility.AutoRepair"] = false,
    ["Utility.AutoSkillCheck"] = false,
    ["Utility.AutoFarm"] = false,
    ["Utility.AutoBuy"] = false,
    ["Utility.ChestESP"] = false,

    -- Misc (Valiant District / FUST / Universal)
    ["Misc.Fly"] = false,
    ["Misc.FlySpeed"] = 50,
    ["Misc.Noclip"] = false,
    ["Misc.InfJump"] = false,
    ["Misc.Speed"] = false,
    ["Misc.WalkSpeed"] = 16,
    ["Misc.JumpPower"] = 50,
    ["Misc.Fullbright"] = false,
    ["Misc.BunnyHop"] = false
}

for path, defaultVal in pairs(DefaultSettings) do
    if K.GetSetting(path) == nil then
        K.SetSetting(path, defaultVal)
    end
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
    Text       = Color3.fromRGB(245, 245, 255),
    SubText    = Color3.fromRGB(170, 170, 195),
    Danger     = Color3.fromRGB(235, 75, 95),
    Border     = Color3.fromRGB(60, 60, 85)
}

-- Словарь локализации (RU / EN)
local Translations = {
    RU = {
        Tab_Combat = "Бой",
        Tab_Visuals = "Визуалы",
        Tab_Utility = "Утилиты",
        Tab_Misc = "Разное",

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
        Chams = "Чамсы (Подсветка моделей)",
        MaxDistance = "Макс. дистанция ESP",

        AutoRepair = "Авто-Починка (Auto Repair)",
        AutoSkillCheck = "Авто Скилл-Чек (Auto Skill Check)",
        KillerESP = "ESP на Маньяка",
        GeneratorESP = "ESP на Генераторы",

        AutoFarm = "Авто-Фарм ресурсов (Auto-Farm)",
        Speed = "Ускорение (Speed Hack)",
        ChestESP = "ESP на сундуки",

        Fly = "Полет (Fly)",
        FlySpeed = "Скорость полета",
        Noclip = "Сквозь стены (Noclip)",
        InfJump = "Бесконечный прыжок (Inf Jump)",
        WalkSpeed = "Скорость ходьбы (WalkSpeed)",
        JumpPower = "Сила прыжка (JumpPower)",
        BunnyHop = "Баннихоп (BunnyHop)",
        Fullbright = "Яркое освещение (Fullbright)"
    },
    EN = {
        Tab_Combat = "Combat",
        Tab_Visuals = "Visuals",
        Tab_Utility = "Utility",
        Tab_Misc = "Misc",

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
        Chams = "Chams Highlight",
        MaxDistance = "ESP Max Distance",

        AutoRepair = "Auto Repair",
        AutoSkillCheck = "Auto Skill Check",
        KillerESP = "Killer ESP",
        GeneratorESP = "Generator ESP",

        AutoFarm = "Auto-Farm",
        Speed = "Speed Hack",
        ChestESP = "Chest ESP",

        Fly = "Fly",
        FlySpeed = "Fly Speed",
        Noclip = "Noclip",
        InfJump = "Infinite Jump (Inf Jump)",
        WalkSpeed = "WalkSpeed",
        JumpPower = "JumpPower",
        BunnyHop = "BunnyHop",
        Fullbright = "Fullbright"
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

-- 1. Создание ScreenGui и полноэкранного аниме-фона
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

-- Аниме-фон на весь экран (ZIndex = 1)
local bg = Instance.new("ImageLabel")
bg.Name = "AnimeBackground"
bg.Parent = ScreenGui
bg.Size = UDim2.new(1, 0, 1, 0)
bg.Position = UDim2.new(0, 0, 0, 0)
bg.BackgroundTransparency = 1
bg.Image = "rbxassetid://135051563569214"
bg.ScaleType = Enum.ScaleType.Crop
bg.ImageTransparency = 0.15
bg.ZIndex = 1

-- 2. Главное окно (600x420, ZIndex = 10, BackgroundTransparency = 0.8)
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = ScreenGui
Main.Size = UDim2.new(0, 600, 0, 420)
Main.Position = UDim2.new(0.5, -300, 0.5, -210)
Main.BackgroundColor3 = Theme.Background
Main.BackgroundTransparency = 0.8
Main.BorderSizePixel = 0
Main.ZIndex = 10

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.Accent
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.3
MainStroke.Parent = Main

-- Верхняя панель (TopBar)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = Main
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.Position = UDim2.new(0, 0, 0, 0)
TopBar.BackgroundColor3 = Theme.Sidebar
TopBar.BackgroundTransparency = 0.25
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 11

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 10)
TopBarCorner.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Parent = TopBar
TitleLabel.Size = UDim2.new(0, 350, 1, 0)
TitleLabel.Position = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "KIRO SCRIPTS  |  [F4]"
TitleLabel.TextColor3 = Theme.Text
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 15
TitleLabel.TextScaled = false
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 12

-- 5. Кнопки Языка (RU/EN) и Закрытия (X)
local LangButton = Instance.new("TextButton")
LangButton.Name = "LangButton"
LangButton.Parent = TopBar
LangButton.Size = UDim2.new(0, 44, 0, 30)
LangButton.Position = UDim2.new(1, -84, 0, 6)
LangButton.BackgroundColor3 = Theme.Element
LangButton.BackgroundTransparency = 0.15
LangButton.BorderSizePixel = 0
LangButton.Text = K.Lang
LangButton.TextColor3 = Theme.Text
LangButton.Font = Enum.Font.GothamBold
LangButton.TextSize = 14
LangButton.TextScaled = false
LangButton.ZIndex = 12

local LangCorner = Instance.new("UICorner")
LangCorner.CornerRadius = UDim.new(0, 6)
LangCorner.Parent = LangButton

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = TopBar
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -36, 0, 6)
CloseButton.BackgroundColor3 = Theme.Danger
CloseButton.BackgroundTransparency = 0.15
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Theme.Text
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
CloseButton.TextScaled = false
CloseButton.ZIndex = 12

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- 3. Сайдбар слева (ширина 150 пикселей) и Контент справа
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Parent = Main
Sidebar.Size = UDim2.new(0, 150, 1, -54)
Sidebar.Position = UDim2.new(0, 6, 0, 48)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BackgroundTransparency = 0.25
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
ContentContainer.Size = UDim2.new(1, -168, 1, -54)
ContentContainer.Position = UDim2.new(0, 162, 0, 48)
ContentContainer.BackgroundColor3 = Theme.Content
ContentContainer.BackgroundTransparency = 0.25
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

-- Хранилище для динамического обновления текстов при смене языка RU/EN
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

-- Заголовки секций (TextSize = 12, цвет Theme.Accent)
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

-- Тумблеры (TextSize = 14, цвет Theme.Text)
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

-- 3. Полноценно работающий слайдер (SLIDERS MUST WORK)
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

    -- Дорожка слайдера (track)
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Parent = SliderFrame
    track.Size = UDim2.new(1, -24, 0, 8)
    track.Position = UDim2.new(0, 12, 0, 32)
    track.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    track.BorderSizePixel = 0
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
        local trackWidth = math.max(track.AbsoluteSize.X, 1)
        local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / trackWidth, 0, 1)
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

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            activeSliderDragging = true
            UpdateSliderFromInput(input)
        end
    end)

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

-- 5. Создание вкладок и наполнение динамическими функциями
local ActiveGame = DetectGame()

local CombatTab  = CreateTab("Tab_Combat", 1)
local VisualsTab = CreateTab("Tab_Visuals", 2)
local UtilityTab = CreateTab("Tab_Utility", 3)
local MiscTab    = CreateTab("Tab_Misc", 4)

-- === ВКЛАДКА 1: БОЙ (COMBAT & CS:GO) ===
AddSection(CombatTab, "Sec_Aimbot")
if K.GetSetting("Combat.Aimbot") ~= nil then
    AddToggle(CombatTab, "Aimbot", "Combat.Aimbot")
end
if K.GetSetting("Combat.SilentAim") ~= nil then
    AddToggle(CombatTab, "SilentAim", "Combat.SilentAim")
end
if K.GetSetting("Combat.ShowFOV") ~= nil then
    AddToggle(CombatTab, "ShowFOV", "Combat.ShowFOV")
end
if K.GetSetting("Combat.FOV") ~= nil then
    AddSlider(CombatTab, "FOV", "Combat.FOV", 20, 500)
end
if K.GetSetting("Combat.Smoothness") ~= nil then
    AddSlider(CombatTab, "Smoothness", "Combat.Smoothness", 1, 30)
end
if K.GetSetting("Combat.WallCheck") ~= nil then
    AddToggle(CombatTab, "WallCheck", "Combat.WallCheck")
end
if K.GetSetting("Combat.TeamCheck") ~= nil then
    AddToggle(CombatTab, "TeamCheck", "Combat.TeamCheck")
end

if ActiveGame == "CSGO" or ActiveGame == "All" then
    AddSection(CombatTab, "Sec_CSGO")
    if K.GetSetting("Combat.Triggerbot") ~= nil then
        AddToggle(CombatTab, "Triggerbot", "Combat.Triggerbot")
    end
    if K.GetSetting("Combat.TriggerDelay") ~= nil then
        AddSlider(CombatTab, "TriggerDelay", "Combat.TriggerDelay", 0, 500)
    end
    if K.GetSetting("Combat.RCS") ~= nil then
        AddToggle(CombatTab, "RCS", "Combat.RCS")
    end
    if K.GetSetting("Combat.RCSStrength") ~= nil then
        AddSlider(CombatTab, "RCSStrength", "Combat.RCSStrength", 0, 100)
    end
    if K.GetSetting("Combat.AutoBuy") ~= nil then
        AddToggle(CombatTab, "AutoBuy", "Combat.AutoBuy")
    end
end

-- === ВКЛАДКА 2: ВИЗУАЛЫ (VISUALS & ESP) ===
AddSection(VisualsTab, "Sec_ESP")
if K.GetSetting("Visuals.Enabled") ~= nil then
    AddToggle(VisualsTab, "ESPEnabled", "Visuals.Enabled")
end
if K.GetSetting("Visuals.BoxESP") ~= nil then
    AddToggle(VisualsTab, "BoxESP", "Visuals.BoxESP")
end
if K.GetSetting("Visuals.NameESP") ~= nil then
    AddToggle(VisualsTab, "NameESP", "Visuals.NameESP")
end
if K.GetSetting("Visuals.HealthESP") ~= nil then
    AddToggle(VisualsTab, "HealthESP", "Visuals.HealthESP")
end
if K.GetSetting("Visuals.Tracers") ~= nil then
    AddToggle(VisualsTab, "Tracers", "Visuals.Tracers")
end
if K.GetSetting("Visuals.Chams") ~= nil then
    AddToggle(VisualsTab, "Chams", "Visuals.Chams")
end
if K.GetSetting("Visuals.ChestESP") ~= nil then
    AddToggle(VisualsTab, "ChestESP", "Visuals.ChestESP")
end
if K.GetSetting("Visuals.MaxDistance") ~= nil then
    AddSlider(VisualsTab, "MaxDistance", "Visuals.MaxDistance", 100, 5000)
end

-- === ВКЛАДКА 3: УТИЛИТЫ (UTILITY: VALIANT DISTRICT / FUST / CS:GO) ===
if ActiveGame == "ValiantDistrict" or ActiveGame == "All" then
    AddSection(UtilityTab, "Sec_Valiant")
    if K.GetSetting("Utility.AutoRepair") ~= nil then
        AddToggle(UtilityTab, "AutoRepair", "Utility.AutoRepair")
    end
    if K.GetSetting("Utility.AutoSkillCheck") ~= nil then
        AddToggle(UtilityTab, "AutoSkillCheck", "Utility.AutoSkillCheck")
    end
    if K.GetSetting("Visuals.KillerESP") ~= nil then
        AddToggle(UtilityTab, "KillerESP", "Visuals.KillerESP")
    end
    if K.GetSetting("Visuals.GeneratorESP") ~= nil then
        AddToggle(UtilityTab, "GeneratorESP", "Visuals.GeneratorESP")
    end
end

if ActiveGame == "FUST" or ActiveGame == "All" then
    AddSection(UtilityTab, "Sec_FUST")
    if K.GetSetting("Utility.AutoFarm") ~= nil then
        AddToggle(UtilityTab, "AutoFarm", "Utility.AutoFarm")
    end
    if K.GetSetting("Misc.Speed") ~= nil then
        AddToggle(UtilityTab, "Speed", "Misc.Speed")
    end
    if K.GetSetting("Utility.ChestESP") ~= nil then
        AddToggle(UtilityTab, "ChestESP", "Utility.ChestESP")
    end
end

if ActiveGame == "CSGO" or ActiveGame == "All" then
    AddSection(UtilityTab, "Sec_CSGO")
    if K.GetSetting("Utility.AutoBuy") ~= nil then
        AddToggle(UtilityTab, "AutoBuy", "Utility.AutoBuy")
    end
end

-- === ВКЛАДКА 4: РАЗНОЕ (MISC: FLY, NOCLIP, INF JUMP, SPEED) ===
AddSection(MiscTab, "Sec_Movement")
if K.GetSetting("Misc.Fly") ~= nil then
    AddToggle(MiscTab, "Fly", "Misc.Fly")
end
if K.GetSetting("Misc.FlySpeed") ~= nil then
    AddSlider(MiscTab, "FlySpeed", "Misc.FlySpeed", 10, 300)
end
if K.GetSetting("Misc.Noclip") ~= nil then
    AddToggle(MiscTab, "Noclip", "Misc.Noclip")
end
if K.GetSetting("Misc.InfJump") ~= nil then
    AddToggle(MiscTab, "InfJump", "Misc.InfJump")
end
if K.GetSetting("Misc.Speed") ~= nil then
    AddToggle(MiscTab, "Speed", "Misc.Speed")
end
if K.GetSetting("Misc.WalkSpeed") ~= nil then
    AddSlider(MiscTab, "WalkSpeed", "Misc.WalkSpeed", 16, 250)
end
if K.GetSetting("Misc.JumpPower") ~= nil then
    AddSlider(MiscTab, "JumpPower", "Misc.JumpPower", 50, 300)
end
if K.GetSetting("Misc.BunnyHop") ~= nil then
    AddToggle(MiscTab, "BunnyHop", "Misc.BunnyHop")
end

AddSection(MiscTab, "Sec_World")
if K.GetSetting("Misc.Fullbright") ~= nil then
    AddToggle(MiscTab, "Fullbright", "Misc.Fullbright")
end

-- Логика кнопок Закрытия (X) и Переключения языка (RU/EN)
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

LangButton.MouseButton1Click:Connect(function()
    K.Lang = (K.Lang == "RU") and "EN" or "RU"
    LangButton.Text = K.Lang
    for _, updateFn in ipairs(TranslatableElements) do
        pcall(updateFn)
    end
end)

-- 6. Открытие/скрытие меню по клавише F4
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F4 then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

K.UI = {
    ScreenGui = ScreenGui,
    Main = Main,
    AddSection = AddSection,
    AddToggle = AddToggle,
    AddSlider = AddSlider
}

return K.UI