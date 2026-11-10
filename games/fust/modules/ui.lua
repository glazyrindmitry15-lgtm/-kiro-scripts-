-- ui.lua | Kiro Scripts UI Library (Fixed TopBar & F4)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local K = shared.KIRO or getgenv().K or _G.K
if not K then return end

K.Settings = K.Settings or {}
K.Lang = K.Lang or "RU"
K.GameId = K.GameId or "fust"
K.LoadedModules = K.LoadedModules or {}
K.Notifications = K.Notifications or {}

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

function K.Notify(title, text, ntype)
    local id = tick()
    K.Notifications[id] = { title = title, text = text, type = ntype or "info", time = tick() }
    print(string.format("[KIRO %s] %s: %s", ntype and ntype:upper() or "INFO", title, text))
    task.delay(3, function() K.Notifications[id] = nil end)
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
    TextDim    = Color3.fromRGB(130, 135, 155),
    Danger     = Color3.fromRGB(235, 75, 95),
    Green      = Color3.fromRGB(80, 220, 140),
    Border     = Color3.fromRGB(60, 60, 85),
    OverlayDark = Color3.fromRGB(0, 0, 0),
    NotifyBG   = Color3.fromRGB(20, 22, 30),
    NotifyOK   = Color3.fromRGB(80, 220, 140),
    NotifyWarn = Color3.fromRGB(255, 200, 80),
    NotifyErr  = Color3.fromRGB(235, 75, 95),
}

local Translations = {
    RU = {
        Tab_Combat = "Бой", Tab_Visuals = "Визуалы", Tab_Utility = "Утилиты", Tab_Misc = "Разное", Tab_Console = "Консоль", Tab_Settings = "Настройки", Tab_Keybinds = "Бинды",
        Sec_Aimbot = "АИМБОТ", Sec_ESP = "ESP И ПОДСВЕТКА", Sec_FUST = "FUST", Sec_Movement = "ПЕРЕДВИЖЕНИЕ", Sec_World = "МИР", Sec_Config = "Конфиг", Sec_UI = "Интерфейс", Sec_Info = "Инфо", Sec_Keybinds = "КЛАВИШИ", Sec_Skins = "СКИНЫ",
        Aimbot = "Включить Аимбот", SilentAim = "Сайлент Аим", ShowFOV = "Показать FOV", FOV = "Радиус FOV", Smoothness = "Плавность",
        WallCheck = "Проверка стен", TeamCheck = "Проверка команды",
        ESPEnabled = "ESP", BoxESP = "Боксы", NameESP = "Имена", HealthESP = "Здоровье",
        Tracers = "Трейсеры", TracerOrigin = "Начало трейсера", Snaplines = "Снаплайны", Chams = "Чамсы",
        ChestESP = "ESP Сундуки", LootESP = "ESP лута", BuildingESP = "ESP Шкафов (TC)", SkeletonESP = "Скелет ESP", NoGrass = "Убрать траву", MaxDistance = "Макс. дистанция", Radar = "Радар",
        AutoFarm = "Авто-фарм", AutoSwing = "Авто-удар", AutoCollect = "Авто-сбор", Speed = "Спидхак",
        Fly = "Полёт", FlySpeed = "Скорость полёта", Noclip = "Ноклип", InfJump = "Инф. прыжок",
        WalkSpeed = "Скорость ходьбы", JumpPower = "Сила прыжка", BunnyHop = "Баннихоп", Fullbright = "Фулбрайт", Zoom = "Зум (Z)",
        Hitmarker = "Хитмаркер",
        SaveConfig = "Сохранить конфиг", LoadConfig = "Загрузить конфиг", ResetConfig = "Сбросить настройки",
        AccentColor = "Цвет акцента", UITransparency = "Прозрачность UI", UIScale = "Масштаб UI",
        SearchPlaceholder = "Поиск...", FPS = "FPS", Ping = "Пинг",
        ModuleStatus_OK = "Загружен", ModuleStatus_FAIL = "Ошибка", ConsoleTitle = "Консоль", ClearConsole = "Очистить", NoErrors = "Ошибок нет",
        BindMenu = "Меню", BindAimbot = "Аимбот", BindESP = "ESP", BindZoom = "Зум",
        WeaponSkin = "Скин оружия",
    }
}
local function Tr(key) return (Translations[K.Lang] or Translations.RU)[key] or key end

local GuiParent = gethui and gethui() or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local OldGui = GuiParent:FindFirstChild("KiroScriptsUI")
if OldGui then OldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KiroScriptsUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = GuiParent

local overlay = Instance.new("Frame")
overlay.Size = UDim2.new(1,0,1,0)
overlay.BackgroundColor3 = Theme.OverlayDark
overlay.BackgroundTransparency = 0.5
overlay.BorderSizePixel = 0
overlay.ZIndex = 1
overlay.Parent = ScreenGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 640, 0, 460)
Main.Position = UDim2.new(0.5, -320, 0.5, -230)
Main.BackgroundColor3 = Theme.Background
Main.BackgroundTransparency = 0.05
Main.BorderSizePixel = 0
Main.ZIndex = 10
Main.ClipsDescendants = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.Accent
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.3
MainStroke.Parent = Main

-- ИСПРАВЛЕНО: TopBar и все элементы выровнены вручную
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 48)
TopBar.BackgroundColor3 = Theme.Sidebar
TopBar.BackgroundTransparency = 0.15
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 50
TopBar.Parent = Main
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

local Logo = Instance.new("Frame")
Logo.Size = UDim2.new(0, 30, 0, 30)
Logo.Position = UDim2.new(0, 12, 0.5, -15)
Logo.BackgroundColor3 = Theme.Accent
Logo.BorderSizePixel = 0
Logo.ZIndex = 51
Logo.Parent = TopBar
Instance.new("UICorner", Logo).CornerRadius = UDim.new(0, 6)
local LogoK = Instance.new("TextLabel", Logo)
LogoK.Size = UDim2.new(1,0,1,0)
LogoK.BackgroundTransparency = 1
LogoK.Text = "K"
LogoK.TextColor3 = Color3.new(1,1,1)
LogoK.Font = Enum.Font.GothamBold
LogoK.TextSize = 18
LogoK.ZIndex = 52

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 160, 0, 20)
Title.Position = UDim2.new(0, 50, 0.5, -15)
Title.BackgroundTransparency = 1
Title.Text = "KIRO SCRIPTS"
Title.TextColor3 = Theme.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 51
Title.Parent = TopBar

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(0, 160, 0, 14)
Subtitle.Position = UDim2.new(0, 50, 0.5, 5)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "v1.2.0  •  [F4]"
Subtitle.TextColor3 = Theme.TextDim
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 10
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.ZIndex = 51
Subtitle.Parent = TopBar

local RightControls = Instance.new("Frame")
RightControls.Size = UDim2.new(0, 220, 1, 0)
RightControls.Position = UDim2.new(1, -230, 0, 0)
RightControls.BackgroundTransparency = 1
RightControls.ZIndex = 51
RightControls.Parent = TopBar

local RightLayout = Instance.new("UIListLayout")
RightLayout.FillDirection = Enum.FillDirection.Horizontal
RightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
RightLayout.VerticalAlignment = Enum.VerticalAlignment.Center
RightLayout.Padding = UDim.new(0, 10)
RightLayout.Parent = RightControls

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(0, 140, 0, 24)
SearchBox.BackgroundColor3 = Theme.Element
SearchBox.BackgroundTransparency = 0.2
SearchBox.BorderSizePixel = 0
SearchBox.PlaceholderText = Tr("SearchPlaceholder")
SearchBox.TextColor3 = Theme.Text
SearchBox.PlaceholderColor3 = Theme.TextDim
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 11
SearchBox.ZIndex = 51
SearchBox.Parent = RightControls
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 6)

local LangButton = Instance.new("TextButton")
LangButton.Size = UDim2.new(0, 40, 0, 24)
LangButton.BackgroundColor3 = Theme.Element
LangButton.BorderSizePixel = 0
LangButton.Text = K.Lang
LangButton.TextColor3 = Theme.Text
LangButton.Font = Enum.Font.GothamBold
LangButton.TextSize = 11
LangButton.ZIndex = 52
LangButton.Parent = RightControls
Instance.new("UICorner", LangButton).CornerRadius = UDim.new(0, 6)

-- ИСПРАВЛЕНО: Кнопка закрытия ровно в углу
local CloseContainer = Instance.new("Frame")
CloseContainer.Size = UDim2.new(0, 32, 0, 32)
CloseContainer.Position = UDim2.new(1, -44, 0.5, -16)
CloseContainer.BackgroundTransparency = 1
CloseContainer.ZIndex = 100
CloseContainer.Parent = TopBar

local CloseLine1 = Instance.new("Frame")
CloseLine1.Size = UDim2.new(1, 0, 0, 2)
CloseLine1.Position = UDim2.new(0, 0, 0.5, -1)
CloseLine1.BackgroundColor3 = Theme.TextDim
CloseLine1.BorderSizePixel = 0
CloseLine1.Rotation = 45
CloseLine1.ZIndex = 101
CloseLine1.Parent = CloseContainer

local CloseLine2 = Instance.new("Frame")
CloseLine2.Size = UDim2.new(1, 0, 0, 2)
CloseLine2.Position = UDim2.new(0, 0, 0.5, -1)
CloseLine2.BackgroundColor3 = Theme.TextDim
CloseLine2.BorderSizePixel = 0
CloseLine2.Rotation = -45
CloseLine2.ZIndex = 101
CloseLine2.Parent = CloseContainer

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 150, 1, -54)
Sidebar.Position = UDim2.new(0, 6, 0, 50)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BackgroundTransparency = 0.15
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 11
Sidebar.Parent = Main
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)
Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 6)
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 8)

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -166, 1, -54)
ContentContainer.Position = UDim2.new(0, 162, 0, 50)
ContentContainer.BackgroundColor3 = Theme.Content
ContentContainer.BackgroundTransparency = 0.15
ContentContainer.BorderSizePixel = 0
ContentContainer.ZIndex = 11
ContentContainer.Parent = Main
Instance.new("UICorner", ContentContainer).CornerRadius = UDim.new(0, 8)

local Tabs = {}
local function CreateTab(key, order)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 34)
    Btn.BackgroundColor3 = Theme.Element
    Btn.BorderSizePixel = 0
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 13
    Btn.Text = Tr(key)
    Btn.ZIndex = 12
    Btn.LayoutOrder = order
    Btn.Parent = Sidebar
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 4
    Page.ScrollBarImageColor3 = Theme.Accent
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.Visible = false
    Page.ZIndex = 12
    Page.Parent = ContentContainer
    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)
    Instance.new("UIPadding", Page).PaddingTop = UDim.new(0, 8)

    local tabObj = { Button = Btn, Page = Page, NextOrder = 0 }
    Btn.MouseButton1Click:Connect(function()
        for _, t in ipairs(Tabs) do t.Page.Visible = (t == tabObj); TweenService:Create(t.Button, TweenInfo.new(0.15), {BackgroundColor3 = (t == tabObj) and Theme.Accent or Theme.Element}):Play() end
    end)
    table.insert(Tabs, tabObj)
    if #Tabs == 1 then Btn.MouseButton1Click() end
    return tabObj
end

local function AddSection(tab, key)
    tab.NextOrder += 1
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, 0, 0, 20)
    Lbl.BackgroundTransparency = 1
    Lbl.LayoutOrder = tab.NextOrder
    Lbl.Font = Enum.Font.GothamBold
    Lbl.TextSize = 12
    Lbl.TextColor3 = Theme.Accent
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Text = Tr(key)
    Lbl.ZIndex = 13
    Lbl.Parent = tab.Page
end

local function AddToggle(tab, key, path)
    tab.NextOrder += 1
    local state = K.GetSetting(path) == true
    local Frame = Instance.new("TextButton")
    Frame.Size = UDim2.new(1, 0, 0, 34)
    Frame.BackgroundColor3 = Theme.Element
    Frame.BorderSizePixel = 0
    Frame.Text = ""
    Frame.AutoButtonColor = false
    Frame.ZIndex = 13
    Frame.LayoutOrder = tab.NextOrder
    Frame.Parent = tab.Page
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Lbl = Instance.new("TextLabel", Frame)
    Lbl.Size = UDim2.new(1, -65, 1, 0)
    Lbl.Position = UDim2.new(0, 12, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Font = Enum.Font.GothamSemibold
    Lbl.TextSize = 13
    Lbl.Text = Tr(key)
    Lbl.TextColor3 = Theme.Text
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.ZIndex = 14

    local SwBg = Instance.new("Frame", Frame)
    SwBg.Size = UDim2.new(0, 40, 0, 20)
    SwBg.Position = UDim2.new(1, -52, 0.5, -10)
    SwBg.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(55, 55, 75)
    SwBg.BorderSizePixel = 0
    SwBg.ZIndex = 14
    Instance.new("UICorner", SwBg).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame", SwBg)
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    Knob.BackgroundColor3 = Theme.Text
    Knob.BorderSizePixel = 0
    Knob.ZIndex = 15
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    Frame.MouseButton1Click:Connect(function()
        state = not state
        K.SetSetting(path, state)
        TweenService:Create(SwBg, TweenInfo.new(0.15), { BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(55, 55, 75) }):Play()
        TweenService:Create(Knob, TweenInfo.new(0.15), { Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8) }):Play()
    end)
end

local CombatTab  = CreateTab("Tab_Combat", 1)
local VisualsTab = CreateTab("Tab_Visuals", 2)
local UtilityTab = CreateTab("Tab_Utility", 3)
local MiscTab    = CreateTab("Tab_Misc", 4)

local isFust = (K.GameId == "fust")
local isCS = (K.GameId == "cs_go")

AddSection(CombatTab, "Sec_Aimbot")
AddToggle(CombatTab, "Aimbot", "Combat.Aimbot")
AddToggle(CombatTab, "ShowFOV", "Combat.ShowFOV")
AddToggle(CombatTab, "TeamCheck", "Combat.TeamCheck")

AddSection(VisualsTab, "Sec_ESP")
AddToggle(VisualsTab, "ESPEnabled", "Visuals.Enabled")
AddToggle(VisualsTab, "BoxESP", "Visuals.BoxESP")
AddToggle(VisualsTab, "NameESP", "Visuals.NameESP")
AddToggle(VisualsTab, "Tracers", "Visuals.Tracers")

-- ИСПРАВЛЕНО: Функции FUST строго внутри проверки
if isFust then
    AddToggle(VisualsTab, "LootESP", "Visuals.LootESP")
    AddToggle(VisualsTab, "BuildingESP", "Visuals.BuildingESP")
    AddToggle(VisualsTab, "NoGrass", "Visuals.NoGrass")
end

if isCS then
    AddSection(CombatTab, "Sec_CSGO")
    AddToggle(CombatTab, "Triggerbot", "Combat.Triggerbot")
    AddToggle(CombatTab, "RCS", "Combat.RCS")
end

-- ИСПРАВЛЕНО: Закрытие меню и работа мыши
CloseContainer.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
    UserInputService.MouseIconEnabled = false
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.F4 then
        ScreenGui.Enabled = not ScreenGui.Enabled
        if ScreenGui.Enabled then
            UserInputService.MouseIconEnabled = true
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if ScreenGui.Enabled then
        if not UserInputService.MouseIconEnabled then UserInputService.MouseIconEnabled = true end
        if UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default then UserInputService.MouseBehavior = Enum.MouseBehavior.Default end
    end
end)

print("[KIRO UI] Loaded (Fixed & Straightened).")
return K.UI