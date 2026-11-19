-- ui.lua | Kiro UI (clean rewrite: no sounds, CAS toggle, mouse override)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CAS = game:GetService("ContextActionService")

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
        else
            return nil
        end
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

if type(K.Notify) ~= "function" then
    function K.Notify(title, text, ntype)
        print(string.format("[KIRO %s] %s: %s", ntype and ntype:upper() or "INFO", title, text))
    end
end

local Theme = {
    Background = Color3.fromRGB(18, 18, 26),
    Sidebar    = Color3.fromRGB(22, 22, 32),
    Content    = Color3.fromRGB(24, 24, 36),
    Element    = Color3.fromRGB(34, 34, 50),
    Accent     = Color3.fromRGB(138, 100, 255),
    Accent2    = Color3.fromRGB(170, 90, 240),
    Text       = Color3.fromRGB(245, 245, 255),
    TextDim    = Color3.fromRGB(130, 135, 155),
    SubText    = Color3.fromRGB(130, 135, 155),
    Danger     = Color3.fromRGB(235, 75, 95),
    Green      = Color3.fromRGB(80, 220, 140),
}

-- Accent registry: lets the colour picker recolour the whole UI live.
-- Must be declared before any element is built.
local AccentBindings = {}

local function BindAccent(inst, prop)
    if not inst then return end
    AccentBindings[#AccentBindings + 1] = { inst = inst, prop = prop }
end

local Translations = {
    RU = {
        Tab_Combat = "Бой", Tab_Visuals = "Визуалы", Tab_Utility = "Утилиты", Tab_Misc = "Разное",
        Tab_Console = "Консоль", Tab_Settings = "Настройки", Tab_Keybinds = "Бинды",
        Sec_Aimbot = "АИМБОТ", Sec_ESP = "ESP И ПОДСВЕТКА", Sec_FUST = "FUST", Sec_CSGO = "CS:GO",
        Sec_Valiant = "VALIANT", Sec_Movement = "ПЕРЕДВИЖЕНИЕ", Sec_World = "МИР", Sec_Config = "Конфиг",
        Sec_Camera = "КАМЕРА", DefaultFOV = "Поле зрения", ZoomFOV = "Зум FOV",
        ViewmodelX = "Видмодель X", ViewmodelY = "Видмодель Y", ViewmodelZ = "Видмодель Z",
        Sec_UI = "Интерфейс", Sec_Info = "Инфо", Sec_Keybinds = "КЛАВИШИ",
        Aimbot = "Включить Аимбот", SilentAim = "Сайлент Аим", ShowFOV = "Показать FOV", FOV = "Радиус FOV",
        Smoothness = "Плавность", WallCheck = "Проверка стен", TeamCheck = "Проверка команды",
        ESPEnabled = "ESP", BoxESP = "Боксы", NameESP = "Имена", HealthESP = "Здоровье",
        Tracers = "Трейсеры", TracerOrigin = "Начало трейсера", Snaplines = "Снаплайны", Chams = "Чамсы",
        WeaponESP = "Оружие в имени", DistanceESP = "Дистанция",
        HeadDot = "Точка на голове", Offscreen = "Указатели за экраном",
        ChestESP = "ESP Сундуки", LootESP = "ESP лута", BuildingESP = "ESP Шкафов (TC)",
        SkeletonESP = "Скелет ESP", NoGrass = "Убрать траву", MaxDistance = "Макс. дистанция",
        Radar = "Радар", Hitmarker = "Хитмаркер", KillerESP = "ESP убийцы", GeneratorESP = "ESP генераторов",
        BombTimer = "Таймер бомбы", AntiFlash = "Анти-флеш",
        Triggerbot = "Триггербот", TriggerDelay = "Задержка триггера", RCS = "RCS",
        RCSStrength = "Сила RCS", AutoBuy = "Авто-закуп",
        AutoFarm = "Авто-фарм", AutoSwing = "Авто-удар", AutoCollect = "Авто-сбор",
        AutoRepair = "Авто-ремонт", AutoSkillCheck = "Авто QTE",
        Fly = "Полёт", FlySpeed = "Скорость полёта", Noclip = "Ноклип", InfJump = "Инф. прыжок",
        Speed = "Спидхак", WalkSpeed = "Скорость ходьбы", JumpPower = "Сила прыжка",
        BunnyHop = "Баннихоп", Fullbright = "Фулбрайт", Zoom = "Зум (Z)", RPC = "Discord RPC",
        SaveConfig = "Сохранить конфиг", LoadConfig = "Загрузить конфиг", ResetConfig = "Сбросить настройки",
        AccentColor = "Цвет акцента", UITransparency = "Прозрачность UI", UIScale = "Масштаб UI",
        SearchPlaceholder = "Поиск...", ModuleStatus_OK = "Загружен", ModuleStatus_FAIL = "Ошибка",
        ConsoleTitle = "Консоль", ClearConsole = "Очистить", NoErrors = "Ошибок нет",
        BindMenu = "Меню", BindAimbot = "Аимбот", BindESP = "ESP", BindZoom = "Зум",
        BindFly = "Полёт", BindSpeed = "Спидхак", BindNoclip = "Ноклип",
        Teleport = "Телепорт к игроку (T)",
        ThirdPerson = "Третье лицо", ThirdPersonDist = "Дистанция камеры",
        Skins = "Скины оружия", ActiveSkin = "Скин", RescanSkins = "Пересканировать скины",
        Hitbox = "Хитбокс",
        Tab_Optimizer = "Оптимизация", Sec_Optimizer = "ОПТИМИЗАЦИЯ (FPS)",
        OptEnabled = "Включить оптимизатор", OptGrass = "Убрать траву/кусты",
        OptParticles = "Отключить частицы", OptShadows = "Убрать тени",
        OptTerrain = "Отключить декор террейна", OptDecals = "Убрать декали/текстуры",
        OptWater = "Упростить воду", OptQuality = "Низкое качество рендера",
        OptStreaming = "Уменьшить дальность стриминга",
        OptHint = "Трава, частицы, тени и декор скрываются. Всё обратимо — выключи тумблер.",
    },
    EN = {
        Tab_Combat = "Combat", Tab_Visuals = "Visuals", Tab_Utility = "Utility", Tab_Misc = "Misc",
        Tab_Console = "Console", Tab_Settings = "Settings", Tab_Keybinds = "Keybinds",
        Tab_Optimizer = "Optimizer",
        Sec_Aimbot = "AIMBOT", Sec_ESP = "ESP & HIGHLIGHTS", Sec_FUST = "FUST",
        Sec_CSGO = "CS:GO", Sec_Valiant = "VALIANT",
        Sec_Movement = "MOVEMENT", Sec_World = "WORLD", Sec_Config = "Config",
        Sec_Camera = "CAMERA", DefaultFOV = "Field of view", ZoomFOV = "Zoom FOV",
        ViewmodelX = "Viewmodel X", ViewmodelY = "Viewmodel Y", ViewmodelZ = "Viewmodel Z",
        Sec_UI = "Interface", Sec_Info = "Info", Sec_Keybinds = "KEYBINDS",
        Aimbot = "Enable Aimbot", SilentAim = "Silent Aim", ShowFOV = "Show FOV",
        FOV = "FOV Radius", Smoothness = "Smoothness", WallCheck = "Wall Check",
        TeamCheck = "Team Check",
        ESPEnabled = "ESP", BoxESP = "Boxes", NameESP = "Names", HealthESP = "Health",
        Tracers = "Tracers", TracerOrigin = "Tracer Origin", Snaplines = "Snaplines",
        Chams = "Chams", WeaponESP = "Weapon in name", DistanceESP = "Distance",
        HeadDot = "Head dot", Offscreen = "Off-screen markers",
        ChestESP = "Chest ESP", LootESP = "Loot ESP", BuildingESP = "Base ESP (cupboards)",
        SkeletonESP = "Skeleton ESP", NoGrass = "Remove grass", MaxDistance = "Max distance",
        Radar = "Radar", Hitmarker = "Hitmarker", KillerESP = "Killer ESP",
        GeneratorESP = "Generator ESP", BombTimer = "Bomb timer", AntiFlash = "Anti-flash",
        Triggerbot = "Triggerbot", TriggerDelay = "Trigger delay", RCS = "RCS",
        RCSStrength = "RCS Strength", AutoBuy = "Auto buy",
        AutoFarm = "Auto farm", AutoSwing = "Auto swing", AutoCollect = "Auto collect",
        AutoRepair = "Auto repair", AutoSkillCheck = "Auto QTE",
        Fly = "Fly", FlySpeed = "Fly speed", Noclip = "Noclip", InfJump = "Infinite jump",
        Speed = "Speed hack", WalkSpeed = "Walk speed", JumpPower = "Jump power",
        BunnyHop = "Bunny hop", Fullbright = "Fullbright", Zoom = "Zoom (Z)",
        RPC = "Discord RPC",
        SaveConfig = "Save config", LoadConfig = "Load config", ResetConfig = "Reset settings",
        AccentColor = "Accent color", UITransparency = "UI transparency", UIScale = "UI scale",
        SearchPlaceholder = "Search...", ModuleStatus_OK = "Loaded", ModuleStatus_FAIL = "Error",
        ConsoleTitle = "Console", ClearConsole = "Clear", NoErrors = "No errors",
        BindMenu = "Menu", BindAimbot = "Aimbot", BindESP = "ESP", BindZoom = "Zoom",
        BindFly = "Fly", BindSpeed = "Speed hack", BindNoclip = "Noclip",
        Teleport = "Teleport to player (T)",
        ThirdPerson = "Third person", ThirdPersonDist = "Camera distance",
        Skins = "Weapon skins", ActiveSkin = "Skin", RescanSkins = "Rescan skins",
        Hitbox = "Hitbox",
        Sec_Optimizer = "OPTIMIZATION (FPS)",
        OptEnabled = "Enable optimizer", OptGrass = "Remove grass/bushes",
        OptParticles = "Disable particles", OptShadows = "Remove shadows",
        OptTerrain = "Disable terrain decoration", OptDecals = "Remove decals/textures",
        OptWater = "Simplify water", OptQuality = "Low render quality",
        OptStreaming = "Reduce streaming distance",
        OptHint = "Grass, particles, shadows and decor get hidden. Fully reversible — toggle off.",
    }
}
local function Tr(key)
    local tbl = Translations[K.Lang] or Translations.RU
    return tbl[key] or Translations.RU[key] or key
end

local GuiParent = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")
local OldGui = GuiParent:FindFirstChild("KiroUI")
if OldGui then OldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KiroUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = GuiParent

local isMenuOpen = true

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 640, 0, 460)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.BackgroundColor3 = Theme.Background
Main.BorderSizePixel = 0
Main.ClipsDescendants = false
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.Accent
MainStroke.Thickness = 1
MainStroke.Transparency = 0.4
MainStroke.Parent = Main
BindAccent(MainStroke, "Color")

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Background),
    ColorSequenceKeypoint.new(1, Theme.Background:Lerp(Theme.Accent, 0.10)),
})
MainGradient.Rotation = 90
MainGradient.Parent = Main

-- slow animated sheen so the window never looks flat
task.spawn(function()
    while Main.Parent do
        TweenService:Create(MainGradient, TweenInfo.new(4.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Rotation = 68,
        }):Play()
        task.wait(4.5)
        TweenService:Create(MainGradient, TweenInfo.new(4.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Rotation = 112,
        }):Play()
        task.wait(4.5)
    end
end)

-- ============ TOP BAR ============
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 48)
TopBar.BackgroundColor3 = Theme.Sidebar
TopBar.BackgroundTransparency = 0.1
TopBar.BorderSizePixel = 0
TopBar.Parent = Main
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

local Logo = Instance.new("Frame")
Logo.Size = UDim2.new(0, 28, 0, 28)
Logo.Position = UDim2.new(0, 12, 0.5, -14)
Logo.BackgroundColor3 = Theme.Accent
Logo.BorderSizePixel = 0
Logo.Parent = TopBar
Instance.new("UICorner", Logo).CornerRadius = UDim.new(0, 6)
BindAccent(Logo, "BackgroundColor3")

-- subtle logo pulse so the menu does not feel static
task.spawn(function()
    while Logo.Parent do
        TweenService:Create(Logo, TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            BackgroundTransparency = 0.3,
        }):Play()
        task.wait(1.6)
        TweenService:Create(Logo, TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            BackgroundTransparency = 0,
        }):Play()
        task.wait(1.6)
    end
end)
local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(1, 0, 1, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "K"
LogoText.TextColor3 = Color3.new(1, 1, 1)
LogoText.Font = Enum.Font.GothamBold
LogoText.TextSize = 16
LogoText.Parent = Logo

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 160, 0, 48)
Title.Position = UDim2.new(0, 48, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "KIRO SCRIPTS"
Title.TextColor3 = Theme.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- FPS readout
local FpsLabel = Instance.new("TextLabel")
FpsLabel.Size = UDim2.new(0, 60, 0, 24)
FpsLabel.Position = UDim2.new(1, -306, 0.5, -12)
FpsLabel.BackgroundTransparency = 1
FpsLabel.Font = Enum.Font.GothamBold
FpsLabel.TextSize = 11
FpsLabel.TextColor3 = Theme.Green
FpsLabel.Text = "-- FPS"
FpsLabel.Parent = TopBar

-- Drag handle: empty middle strip of the top bar only
local DragHandle = Instance.new("Frame")
DragHandle.Size = UDim2.new(1, -530, 1, 0)
DragHandle.Position = UDim2.new(0, 220, 0, 0)
DragHandle.BackgroundTransparency = 1
DragHandle.Active = true
DragHandle.Parent = TopBar

local dragging, dragStart, startPos
DragHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(0, 140, 0, 24)
SearchBox.Position = UDim2.new(1, -236, 0.5, -12)
SearchBox.BackgroundColor3 = Theme.Element
SearchBox.BackgroundTransparency = 0.1
SearchBox.BorderSizePixel = 0
SearchBox.PlaceholderText = Tr("SearchPlaceholder")
SearchBox.PlaceholderColor3 = Theme.TextDim
SearchBox.Text = ""
SearchBox.TextColor3 = Theme.Text
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 11
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = TopBar
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 6)

local LangButton = Instance.new("TextButton")
LangButton.Size = UDim2.new(0, 40, 0, 24)
LangButton.Position = UDim2.new(1, -88, 0.5, -12)
LangButton.BackgroundColor3 = Theme.Element
LangButton.BackgroundTransparency = 0.1
LangButton.BorderSizePixel = 0
LangButton.Text = K.Lang
LangButton.TextColor3 = Theme.Text
LangButton.Font = Enum.Font.GothamBold
LangButton.TextSize = 11
LangButton.Parent = TopBar
Instance.new("UICorner", LangButton).CornerRadius = UDim.new(0, 6)

-- Close button: real TextButton
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseButton"
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -14)
CloseBtn.BackgroundColor3 = Theme.Danger
CloseBtn.BackgroundTransparency = 0.25
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Theme.Text
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.AutoButtonColor = true
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- ============ LAYOUT ============
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 150, 1, -58)
Sidebar.Position = UDim2.new(0, 6, 0, 54)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BackgroundTransparency = 0.1
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)
local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 6)
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Parent = Sidebar
local SidebarPad = Instance.new("UIPadding")
SidebarPad.PaddingTop = UDim.new(0, 8)
SidebarPad.PaddingLeft = UDim.new(0, 6)
SidebarPad.PaddingRight = UDim.new(0, 6)
SidebarPad.PaddingBottom = UDim.new(0, 8)
SidebarPad.Parent = Sidebar

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -168, 1, -58)
Content.Position = UDim2.new(0, 162, 0, 54)
Content.BackgroundColor3 = Theme.Content
Content.BackgroundTransparency = 0.1
Content.BorderSizePixel = 0
Content.Parent = Main
Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 8)

-- ============ TOAST NOTIFICATIONS ============
local ToastGui = Instance.new("ScreenGui")
ToastGui.Name = "KiroToasts"
ToastGui.ResetOnSpawn = false
ToastGui.DisplayOrder = 1000
ToastGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ToastGui.Parent = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")

local toastStack = {}
local TOAST_W, TOAST_H, TOAST_GAP = 240, 36, 6

local function MakeToast(text, accent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, TOAST_W, 0, TOAST_H)
    frame.Position = UDim2.new(1, TOAST_W + 10, 0, 0)
    frame.BackgroundColor3 = Theme.Element
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.ZIndex = 1000
    frame.Parent = ToastGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(0, 4, 1, -8)
    Bar.Position = UDim2.new(0, 4, 0, 4)
    Bar.BackgroundColor3 = accent
    Bar.BorderSizePixel = 0
    Bar.ZIndex = 1001
    Bar.Parent = frame
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -18, 1, 0)
    Lbl.Position = UDim2.new(0, 14, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Font = Enum.Font.GothamSemibold
    Lbl.TextSize = 12
    Lbl.TextColor3 = Theme.Text
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Text = text
    Lbl.ZIndex = 1001
    Lbl.Parent = frame

    -- slide in
    TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -TOAST_W - 10, 0, 0),
    }):Play()

    task.delay(1.5, function()
        -- fade out
        TweenService:Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 1,
        }):Play()
        TweenService:Create(Lbl, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextTransparency = 1,
        }):Play()
        TweenService:Create(Bar, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 1,
        }):Play()
        task.wait(0.3)
        frame:Destroy()
    end)
end

function K.Toast(text, ntype)
    local accent = Theme.Accent
    if ntype == "on" then accent = Theme.Green
    elseif ntype == "off" then accent = Theme.Danger
    elseif ntype == "warn" then accent = Color3.fromRGB(255, 200, 80) end
    MakeToast(text, accent)
end

-- ============ ELEMENT FACTORIES ============
local Translatable = {}
local ToggleSync = {}

local function ApplyAccent(color)
    if typeof(color) ~= "Color3" then return end
    Theme.Accent = color
    Theme.Accent2 = color:Lerp(Color3.new(1, 1, 1), 0.25)
    for _, b in ipairs(AccentBindings) do
        pcall(function() b.inst[b.prop] = color end)
    end
    pcall(function()
        MainGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Background),
            ColorSequenceKeypoint.new(1, Theme.Background:Lerp(color, 0.10)),
        })
    end)
end

local function BindTranslation(inst, key)
    local function apply() inst.Text = Tr(key) end
    table.insert(Translatable, apply)
    apply()
end

local Tabs, ActiveTab = {}, nil
local function SelectTab(t)
    ActiveTab = t
    for _, tab in ipairs(Tabs) do
        local sel = tab == t
        tab.Page.Visible = sel
        if tab.Glow then
            tab.Glow.Enabled = sel
            tab.Glow.Transparency = sel and 0.35 or 1
        end
        if tab.Bar then
            tab.Bar.Visible = sel
        end
        TweenService:Create(tab.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            BackgroundColor3 = sel and Theme.Accent or Theme.Element,
            BackgroundTransparency = sel and 0.1 or 0.35,
        }):Play()
    end
end

local function CreateTab(key, order)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 32)
    Btn.BackgroundColor3 = Theme.Element
    Btn.BackgroundTransparency = 0.35
    Btn.BorderSizePixel = 0
    Btn.Text = ""
    Btn.AutoButtonColor = false
    Btn.LayoutOrder = order
    Btn.Parent = Sidebar
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, 0, 1, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Font = Enum.Font.GothamBold
    Lbl.TextSize = 12
    Lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    Lbl.Parent = Btn
    BindTranslation(Lbl, key)

    local Page = Instance.new("ScrollingFrame")
    Page.Name = key .. "_Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 4
    Page.ScrollBarImageColor3 = Theme.Accent
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.Visible = false
    Page.Parent = Content
    local PageLayout = Instance.new("UIListLayout")
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 6)
    PageLayout.Parent = Page
    local PagePad = Instance.new("UIPadding")
    PagePad.PaddingTop = UDim.new(0, 8)
    PagePad.PaddingBottom = UDim.new(0, 8)
    PagePad.PaddingLeft = UDim.new(0, 8)
    PagePad.PaddingRight = UDim.new(0, 8)
    PagePad.Parent = Page

    local tabObj = { Button = Btn, Page = Page, NextOrder = 0 }

    -- accent bar + glow shown only while this tab is selected
    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(0, 3, 0, 18)
    Bar.Position = UDim2.new(0, 0, 0.5, -9)
    Bar.BackgroundColor3 = Theme.Accent
    Bar.BorderSizePixel = 0
    Bar.Visible = false
    Bar.ZIndex = 12
    Bar.Parent = Btn
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)
    tabObj.Bar = Bar

    local Glow = Instance.new("UIStroke")
    Glow.Color = Theme.Accent
    Glow.Thickness = 1.2
    Glow.Transparency = 1
    Glow.Enabled = false
    Glow.Parent = Btn
    tabObj.Glow = Glow

    Btn.MouseButton1Click:Connect(function() SelectTab(tabObj) end)
    Btn.MouseEnter:Connect(function()
        if ActiveTab ~= tabObj then
            TweenService:Create(Btn, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.15,
            }):Play()
        end
    end)
    Btn.MouseLeave:Connect(function()
        if ActiveTab ~= tabObj then
            TweenService:Create(Btn, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.35,
            }):Play()
        end
    end)
    table.insert(Tabs, tabObj)
    if #Tabs == 1 then SelectTab(tabObj) end
    return tabObj
end

local function AddSection(tab, key)
    tab.NextOrder += 1
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, 0, 0, 20)
    Lbl.BackgroundTransparency = 1
    Lbl.LayoutOrder = tab.NextOrder
    Lbl.Font = Enum.Font.GothamBold
    Lbl.TextSize = 11
    Lbl.TextColor3 = Theme.Accent
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = tab.Page
    BindTranslation(Lbl, key)
    BindAccent(Lbl, "TextColor3")

    local Underline = Instance.new("Frame")
    Underline.Size = UDim2.new(1, 0, 0, 1)
    Underline.Position = UDim2.new(0, 0, 1, -1)
    Underline.BackgroundColor3 = Theme.Accent
    Underline.BackgroundTransparency = 0.55
    Underline.BorderSizePixel = 0
    Underline.Parent = Lbl
    BindAccent(Underline, "BackgroundColor3")
    return Lbl
end

local function AddToggle(tab, key, path)
    tab.NextOrder += 1
    local state = K.GetSetting(path) == true
    local Row = Instance.new("TextButton")
    Row.Size = UDim2.new(1, 0, 0, 32)
    Row.BackgroundColor3 = Theme.Element
    Row.BackgroundTransparency = 0.2
    Row.BorderSizePixel = 0
    Row.Text = ""
    Row.AutoButtonColor = false
    Row.LayoutOrder = tab.NextOrder
    Row.Parent = tab.Page
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -72, 1, 0)
    Lbl.Position = UDim2.new(0, 12, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Font = Enum.Font.GothamSemibold
    Lbl.TextSize = 12
    Lbl.TextColor3 = Theme.Text
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Row
    BindTranslation(Lbl, key)

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(0, 38, 0, 18)
    Track.Position = UDim2.new(1, -50, 0.5, -9)
    Track.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(55, 55, 75)
    Track.BorderSizePixel = 0
    Track.Parent = Row
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    -- glow ring, visible only while the toggle is ON
    local TrackGlow = Instance.new("UIStroke")
    TrackGlow.Color = Theme.Accent
    TrackGlow.Thickness = 1.2
    TrackGlow.Transparency = state and 0.45 or 1
    TrackGlow.Parent = Track
    BindAccent(TrackGlow, "Color")

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 14, 0, 14)
    Knob.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    Knob.BackgroundColor3 = Theme.Text
    Knob.BorderSizePixel = 0
    Knob.Parent = Track
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local function Update(s)
        state = s
        K.SetSetting(path, s)
        -- toast notification
        local label = Tr(key)
        K.Toast((s and "✓ " or "✗ ") .. label, s and "on" or "off")
        TweenService:Create(Track, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            BackgroundColor3 = s and Theme.Accent or Color3.fromRGB(55, 55, 75),
        }):Play()
        TrackGlow.Transparency = s and 0.45 or 1
        TweenService:Create(Knob, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = s and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
        }):Play()
    end

    -- flip the REAL current value, not a cached copy: keybinds and LoadConfig
    -- change settings behind this row's back
    Row.MouseButton1Click:Connect(function()
        Update(not (K.GetSetting(path) == true))
    end)

    -- keep the visual in sync with external changes
    ToggleSync[#ToggleSync + 1] = function()
        local live = K.GetSetting(path) == true
        if live ~= state then
            state = live
            TrackGlow.Transparency = live and 0.45 or 1
            TweenService:Create(Track, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundColor3 = live and Theme.Accent or Color3.fromRGB(55, 55, 75),
            }):Play()
            TweenService:Create(Knob, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Position = live and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
            }):Play()
        end
    end

    Row.MouseEnter:Connect(function()
        TweenService:Create(Row, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 0.05 }):Play()
    end)
    Row.MouseLeave:Connect(function()
        TweenService:Create(Row, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 0.2 }):Play()
    end)
    return Row
end

local function AddSlider(tab, key, path, minV, maxV)
    tab.NextOrder += 1
    local saved = tonumber(K.GetSetting(path))
    local val = saved and math.clamp(saved, minV, maxV) or minV
    local alpha = math.clamp((val - minV) / math.max(maxV - minV, 1), 0, 1)

    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 44)
    Row.BackgroundColor3 = Theme.Element
    Row.BackgroundTransparency = 0.2
    Row.BorderSizePixel = 0
    Row.LayoutOrder = tab.NextOrder
    Row.Parent = tab.Page
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -92, 0, 20)
    Lbl.Position = UDim2.new(0, 12, 0, 3)
    Lbl.BackgroundTransparency = 1
    Lbl.Font = Enum.Font.GothamSemibold
    Lbl.TextSize = 12
    Lbl.TextColor3 = Theme.Text
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Row
    BindTranslation(Lbl, key)

    local ValLbl = Instance.new("TextLabel")
    ValLbl.Size = UDim2.new(0, 60, 0, 20)
    ValLbl.Position = UDim2.new(1, -70, 0, 3)
    ValLbl.BackgroundTransparency = 1
    ValLbl.Font = Enum.Font.GothamBold
    ValLbl.TextSize = 12
    ValLbl.TextColor3 = Theme.Accent
    ValLbl.TextXAlignment = Enum.TextXAlignment.Right
    ValLbl.Text = tostring(val)
    ValLbl.Parent = Row

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -24, 0, 6)
    Track.Position = UDim2.new(0, 12, 0, 28)
    Track.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    Track.BorderSizePixel = 0
    Track.Active = true
    Track.Parent = Row
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new(alpha, 0, 1, 0)
    Fill.BackgroundColor3 = Theme.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    BindAccent(Fill, "BackgroundColor3")

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 12, 0, 12)
    Knob.Position = UDim2.new(alpha, -6, 0.5, -6)
    Knob.BackgroundColor3 = Theme.Text
    Knob.BorderSizePixel = 0
    Knob.Active = true
    Knob.Parent = Track
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    -- local drag state per slider; no global flags
    local draggingSlider = false
    local function Apply(input)
        local absPos, absSize = Track.AbsolutePosition, Track.AbsoluteSize
        if absSize.X <= 0 then return end
        local rel = math.clamp((input.Position.X - absPos.X) / absSize.X, 0, 1)
        local v = math.floor(minV + (maxV - minV) * rel + 0.5)
        alpha = (v - minV) / math.max(maxV - minV, 1)
        Fill.Size = UDim2.new(alpha, 0, 1, 0)
        Knob.Position = UDim2.new(alpha, -6, 0.5, -6)
        ValLbl.Text = tostring(v)
        K.SetSetting(path, v)
    end

    Knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
            Apply(input)
        end
    end)
    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
            Apply(input)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
            Apply(input)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = false
        end
    end)

    return Row
end

local function MakeDropdown(parent, current, options, onSelect)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 120, 0, 22)
    Btn.BackgroundColor3 = Theme.Accent
    Btn.BackgroundTransparency = 0.2
    Btn.BorderSizePixel = 0
    Btn.Text = current
    Btn.TextColor3 = Theme.Text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 11
    Btn.Parent = parent
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    BindAccent(Btn, "BackgroundColor3")

    local open = false
    local OptFrame = nil

    local function Close()
        if OptFrame then OptFrame:Destroy() end
        OptFrame = nil
        open = false
    end

    Btn.MouseButton1Click:Connect(function()
        if open then Close() return end
        open = true
        local cam = workspace.CurrentCamera
        local vpY = cam and cam.ViewportSize.Y or 800
        local boxHeight = #options * 22
        local below = Btn.AbsolutePosition.Y + Btn.AbsoluteSize.Y + boxHeight
        local box = Instance.new("Frame")
        box.Size = UDim2.new(0, 120, 0, boxHeight)
        -- flip upward when there is not enough room below
        box.Position = below > vpY
            and UDim2.new(0, 0, 1, -boxHeight - 2)
            or UDim2.new(0, 0, 1, 2)
        box.BackgroundColor3 = Theme.Content
        box.BackgroundTransparency = 0.05
        box.BorderSizePixel = 0
        box.ZIndex = 50
        box.Parent = Btn
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 2)
        list.Parent = box
        for _, opt in ipairs(options) do
            local Ob = Instance.new("TextButton")
            Ob.Size = UDim2.new(1, -4, 0, 20)
            Ob.Position = UDim2.new(0, 2, 0, 0)
            Ob.BackgroundTransparency = 1
            Ob.Text = opt
            Ob.TextColor3 = Theme.Text
            Ob.Font = Enum.Font.Gotham
            Ob.TextSize = 11
            Ob.ZIndex = 51
            Ob.Parent = box
            Ob.MouseButton1Click:Connect(function()
                current = opt
                Btn.Text = opt
                onSelect(opt)
                Close()
            end)
            Ob.MouseEnter:Connect(function()
                Ob.BackgroundTransparency = 0.7
                Ob.BackgroundColor3 = Theme.Accent
            end)
            Ob.MouseLeave:Connect(function() Ob.BackgroundTransparency = 1 end)
        end
        OptFrame = box
    end)

    UIS.InputBegan:Connect(function(input)
        if open and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mp = input.Position
            -- clicks on the button itself are handled by its own event
            local bp, bs = Btn.AbsolutePosition, Btn.AbsoluteSize
            if mp.X >= bp.X and mp.X <= bp.X + bs.X and mp.Y >= bp.Y and mp.Y <= bp.Y + bs.Y then
                return
            end
            if not OptFrame then return end
            local ap, as = OptFrame.AbsolutePosition, OptFrame.AbsoluteSize
            if mp.X < ap.X or mp.X > ap.X + as.X or mp.Y < ap.Y or mp.Y > ap.Y + as.Y then
                Close()
            end
        end
    end)

    return Btn
end

local function AddDropdown(tab, key, path, options)
    tab.NextOrder += 1
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 32)
    Row.BackgroundColor3 = Theme.Element
    Row.BackgroundTransparency = 0.2
    Row.BorderSizePixel = 0
    Row.LayoutOrder = tab.NextOrder
    Row.Parent = tab.Page
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -150, 1, 0)
    Lbl.Position = UDim2.new(0, 12, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Font = Enum.Font.GothamSemibold
    Lbl.TextSize = 12
    Lbl.TextColor3 = Theme.Text
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Row
    BindTranslation(Lbl, key)

    local current = K.GetSetting(path) or options[1]
    local Btn = MakeDropdown(Row, current, options, function(val) K.SetSetting(path, val) end)
    Btn.Position = UDim2.new(1, -128, 0.5, -11)
    return Row
end

local function AddButton(tab, key, callback)
    tab.NextOrder += 1
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 30)
    Btn.BackgroundColor3 = Theme.Accent
    Btn.BackgroundTransparency = 0.15
    Btn.BorderSizePixel = 0
    Btn.Text = ""
    Btn.AutoButtonColor = false
    Btn.LayoutOrder = tab.NextOrder
    Btn.Parent = tab.Page
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    BindAccent(Btn, "BackgroundColor3")
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, 0, 1, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Font = Enum.Font.GothamBold
    Lbl.TextSize = 12
    Lbl.TextColor3 = Theme.Text
    Lbl.Parent = Btn
    BindTranslation(Lbl, key)
    Btn.MouseButton1Click:Connect(function()
        if callback then pcall(callback) end
    end)
    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 0.0 }):Play()
    end)
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 0.15 }):Play()
    end)
    return Btn
end

local function AddColorPicker(tab, key, path)
    tab.NextOrder += 1
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 32)
    Row.BackgroundColor3 = Theme.Element
    Row.BackgroundTransparency = 0.2
    Row.BorderSizePixel = 0
    Row.LayoutOrder = tab.NextOrder
    Row.Parent = tab.Page
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -72, 1, 0)
    Lbl.Position = UDim2.new(0, 12, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Font = Enum.Font.GothamSemibold
    Lbl.TextSize = 12
    Lbl.TextColor3 = Theme.Text
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Row
    BindTranslation(Lbl, key)

    local Preview = Instance.new("Frame")
    Preview.Size = UDim2.new(0, 38, 0, 18)
    Preview.Position = UDim2.new(1, -50, 0.5, -9)
    Preview.BackgroundColor3 = K.GetSetting(path) or Theme.Accent
    Preview.BorderSizePixel = 0
    Preview.Parent = Row
    Instance.new("UICorner", Preview).CornerRadius = UDim.new(0, 4)

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.Parent = Preview

    local palette = {
        Theme.Accent, Theme.Accent2, Theme.Green, Theme.Danger,
        Color3.fromRGB(255, 200, 80), Color3.fromRGB(100, 200, 255),
    }
    Btn.MouseButton1Click:Connect(function()
        local idx = 1
        for i, c in ipairs(palette) do
            if c == Preview.BackgroundColor3 then idx = i break end
        end
        local nextColor = palette[(idx % #palette) + 1]
        Preview.BackgroundColor3 = nextColor
        K.SetSetting(path, nextColor)
        ApplyAccent(nextColor)
    end)
    return Row
end

local function AddKeybind(tab, key, path)
    tab.NextOrder += 1
    local current = K.GetSetting(path) or Enum.KeyCode.Unknown

    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 32)
    Row.BackgroundColor3 = Theme.Element
    Row.BackgroundTransparency = 0.2
    Row.BorderSizePixel = 0
    Row.LayoutOrder = tab.NextOrder
    Row.Parent = tab.Page
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -118, 1, 0)
    Lbl.Position = UDim2.new(0, 12, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Font = Enum.Font.GothamSemibold
    Lbl.TextSize = 12
    Lbl.TextColor3 = Theme.Text
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Row
    BindTranslation(Lbl, key)

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 84, 0, 22)
    Btn.Position = UDim2.new(1, -96, 0.5, -11)
    Btn.BackgroundColor3 = Theme.Accent
    Btn.BackgroundTransparency = 0.2
    Btn.BorderSizePixel = 0
    Btn.Text = (current.Name ~= "Unknown" and current.Name) or "None"
    Btn.TextColor3 = Theme.Text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 11
    Btn.Parent = Row
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)

    local listening = false
    Btn.MouseButton1Click:Connect(function()
        listening = true
        Btn.Text = "..."
        Btn.TextColor3 = Theme.Accent2
    end)

    UIS.InputBegan:Connect(function(input, gp)
        if listening and not gp and input.UserInputType == Enum.UserInputType.Keyboard then
            listening = false
            if input.KeyCode == Enum.KeyCode.Escape then
                Btn.Text = (current.Name ~= "Unknown" and current.Name) or "None"
                Btn.TextColor3 = Theme.Text
                return
            end
            current = input.KeyCode
            Btn.Text = current.Name
            Btn.TextColor3 = Theme.Text
            K.SetSetting(path, current)
        end
    end)

    task.spawn(function()
        while Btn.Parent do
            local v = K.GetSetting(path)
            if typeof(v) == "EnumItem" and v ~= current then
                current = v
                Btn.Text = (v.Name ~= "Unknown" and v.Name) or "None"
            end
            task.wait(0.5)
        end
    end)

    return Row
end

-- ============ TABS ============
local CombatTab   = CreateTab("Tab_Combat", 1)
local VisualsTab  = CreateTab("Tab_Visuals", 2)
local UtilityTab  = CreateTab("Tab_Utility", 3)
local MiscTab     = CreateTab("Tab_Misc", 4)
local ConsoleTab  = CreateTab("Tab_Console", 5)
local KeybindsTab = CreateTab("Tab_Keybinds", 6)
local SettingsTab = CreateTab("Tab_Settings", 7)

local isFust = (K.GameId == "fust")
local isCS = (K.GameId == "cs_go")
local isValiant = (K.GameId == "valiant_district")

-- Combat
AddSection(CombatTab, "Sec_Aimbot")
if K.GetSetting("Combat.Aimbot") ~= nil then AddToggle(CombatTab, "Aimbot", "Combat.Aimbot") end
if K.GetSetting("Combat.ShowFOV") ~= nil then AddToggle(CombatTab, "ShowFOV", "Combat.ShowFOV") end
if K.GetSetting("Combat.FOV") ~= nil then AddSlider(CombatTab, "FOV", "Combat.FOV", 20, 500) end
if K.GetSetting("Combat.Smoothness") ~= nil then AddSlider(CombatTab, "Smoothness", "Combat.Smoothness", 1, 30) end
if K.GetSetting("Combat.WallCheck") ~= nil then AddToggle(CombatTab, "WallCheck", "Combat.WallCheck") end
if K.GetSetting("Combat.TeamCheck") ~= nil then AddToggle(CombatTab, "TeamCheck", "Combat.TeamCheck") end
if K.GetSetting("Combat.Hitbox") ~= nil then AddDropdown(CombatTab, "Hitbox", "Combat.Hitbox", { "Head", "Body", "Legs" }) end

if isCS then
    AddSection(CombatTab, "Sec_CSGO")
    if K.GetSetting("Combat.Triggerbot") ~= nil then AddToggle(CombatTab, "Triggerbot", "Combat.Triggerbot") end
    if K.GetSetting("Combat.TriggerDelay") ~= nil then AddSlider(CombatTab, "TriggerDelay", "Combat.TriggerDelay", 0, 500) end
    if K.GetSetting("Combat.RCS") ~= nil then AddToggle(CombatTab, "RCS", "Combat.RCS") end
    if K.GetSetting("Combat.RCSStrength") ~= nil then AddSlider(CombatTab, "RCSStrength", "Combat.RCSStrength", 0, 100) end
    if K.GetSetting("Combat.AutoBuy") ~= nil then AddToggle(CombatTab, "AutoBuy", "Combat.AutoBuy") end
end

-- Visuals
AddSection(VisualsTab, "Sec_ESP")
if K.GetSetting("Visuals.Enabled") ~= nil then AddToggle(VisualsTab, "ESPEnabled", "Visuals.Enabled") end
if K.GetSetting("Visuals.BoxESP") ~= nil then AddToggle(VisualsTab, "BoxESP", "Visuals.BoxESP") end
if K.GetSetting("Visuals.NameESP") ~= nil then AddToggle(VisualsTab, "NameESP", "Visuals.NameESP") end
if K.GetSetting("Visuals.HealthESP") ~= nil then AddToggle(VisualsTab, "HealthESP", "Visuals.HealthESP") end
if K.GetSetting("Visuals.Tracers") ~= nil then AddToggle(VisualsTab, "Tracers", "Visuals.Tracers") end
if K.GetSetting("Visuals.TracerOrigin") ~= nil then AddDropdown(VisualsTab, "TracerOrigin", "Visuals.TracerOrigin", { "Screen Bottom", "Crosshair", "Screen Center" }) end
if K.GetSetting("Visuals.Snaplines") ~= nil then AddToggle(VisualsTab, "Snaplines", "Visuals.Snaplines") end
if K.GetSetting("Visuals.Chams") ~= nil then AddToggle(VisualsTab, "Chams", "Visuals.Chams") end
if K.GetSetting("Visuals.Hitmarker") ~= nil then AddToggle(VisualsTab, "Hitmarker", "Visuals.Hitmarker") end
if K.GetSetting("Visuals.WeaponESP") ~= nil then AddToggle(VisualsTab, "WeaponESP", "Visuals.WeaponESP") end
if K.GetSetting("Visuals.DistanceESP") ~= nil then AddToggle(VisualsTab, "DistanceESP", "Visuals.DistanceESP") end
if K.GetSetting("Visuals.SkeletonESP") ~= nil then AddToggle(VisualsTab, "SkeletonESP", "Visuals.SkeletonESP") end
if K.GetSetting("Visuals.HeadDot") ~= nil then AddToggle(VisualsTab, "HeadDot", "Visuals.HeadDot") end
if K.GetSetting("Visuals.Offscreen") ~= nil then AddToggle(VisualsTab, "Offscreen", "Visuals.Offscreen") end
if K.GetSetting("Visuals.MaxDistance") ~= nil then AddSlider(VisualsTab, "MaxDistance", "Visuals.MaxDistance", 100, 5000) end
if K.GetSetting("Visuals.Radar") ~= nil then AddToggle(VisualsTab, "Radar", "Visuals.Radar") end

if isFust then
    if K.GetSetting("Visuals.ChestESP") ~= nil then AddToggle(VisualsTab, "ChestESP", "Visuals.ChestESP") end
    if K.GetSetting("Visuals.LootESP") ~= nil then AddToggle(VisualsTab, "LootESP", "Visuals.LootESP") end
    if K.GetSetting("Visuals.BuildingESP") ~= nil then AddToggle(VisualsTab, "BuildingESP", "Visuals.BuildingESP") end
    if K.GetSetting("Visuals.NoGrass") ~= nil then AddToggle(VisualsTab, "NoGrass", "Visuals.NoGrass") end
end

if isCS then
    if K.GetSetting("Visuals.BombTimer") ~= nil then AddToggle(VisualsTab, "BombTimer", "Visuals.BombTimer") end
    if K.GetSetting("Visuals.AntiFlash") ~= nil then AddToggle(VisualsTab, "AntiFlash", "Visuals.AntiFlash") end
end

if isValiant then
    if K.GetSetting("Visuals.KillerESP") ~= nil then AddToggle(VisualsTab, "KillerESP", "Visuals.KillerESP") end
    if K.GetSetting("Visuals.GeneratorESP") ~= nil then AddToggle(VisualsTab, "GeneratorESP", "Visuals.GeneratorESP") end
end

-- Utility
if isFust then
    AddSection(UtilityTab, "Sec_FUST")
    if K.GetSetting("Utility.AutoFarm") ~= nil then AddToggle(UtilityTab, "AutoFarm", "Utility.AutoFarm") end
    if K.GetSetting("Utility.AutoSwing") ~= nil then AddToggle(UtilityTab, "AutoSwing", "Utility.AutoSwing") end
    if K.GetSetting("Utility.AutoCollect") ~= nil then AddToggle(UtilityTab, "AutoCollect", "Utility.AutoCollect") end
    if K.GetSetting("Utility.ChestESP") ~= nil then AddToggle(UtilityTab, "ChestESP", "Utility.ChestESP") end
end

if isValiant then
    AddSection(UtilityTab, "Sec_Valiant")
    if K.GetSetting("Utility.AutoRepair") ~= nil then AddToggle(UtilityTab, "AutoRepair", "Utility.AutoRepair") end
    if K.GetSetting("Utility.AutoSkillCheck") ~= nil then AddToggle(UtilityTab, "AutoSkillCheck", "Utility.AutoSkillCheck") end
end

-- Misc
AddSection(MiscTab, "Sec_Movement")
if K.GetSetting("Misc.Fly") ~= nil then AddToggle(MiscTab, "Fly", "Misc.Fly") end
if K.GetSetting("Misc.FlySpeed") ~= nil then AddSlider(MiscTab, "FlySpeed", "Misc.FlySpeed", 10, 300) end
if K.GetSetting("Misc.Noclip") ~= nil then AddToggle(MiscTab, "Noclip", "Misc.Noclip") end
if K.GetSetting("Misc.InfJump") ~= nil then AddToggle(MiscTab, "InfJump", "Misc.InfJump") end
if K.GetSetting("Misc.Speed") ~= nil then AddToggle(MiscTab, "Speed", "Misc.Speed") end
if K.GetSetting("Misc.WalkSpeed") ~= nil then AddSlider(MiscTab, "WalkSpeed", "Misc.WalkSpeed", 16, 250) end
if K.GetSetting("Misc.JumpPower") ~= nil then AddSlider(MiscTab, "JumpPower", "Misc.JumpPower", 50, 300) end
if K.GetSetting("Misc.BunnyHop") ~= nil then AddToggle(MiscTab, "BunnyHop", "Misc.BunnyHop") end
if K.GetSetting("Misc.Teleport") ~= nil then AddToggle(MiscTab, "Teleport", "Misc.Teleport") end

AddSection(MiscTab, "Sec_World")
if K.GetSetting("Misc.Fullbright") ~= nil then AddToggle(MiscTab, "Fullbright", "Misc.Fullbright") end
if K.GetSetting("Misc.Zoom") ~= nil then AddToggle(MiscTab, "Zoom", "Misc.Zoom") end
if K.GetSetting("Misc.RPC") ~= nil then AddToggle(MiscTab, "RPC", "Misc.RPC") end

if K.GetSetting("ThirdPerson.Enabled") ~= nil then
    AddSection(MiscTab, "ThirdPerson")
    AddToggle(MiscTab, "ThirdPerson", "ThirdPerson.Enabled")
    if K.GetSetting("ThirdPerson.Distance") ~= nil then AddSlider(MiscTab, "ThirdPersonDist", "ThirdPerson.Distance", 4, 20) end
end

if K.GetSetting("Skins.Enabled") ~= nil then
    AddSection(MiscTab, "Skins")
    AddToggle(MiscTab, "Skins", "Skins.Enabled")

    local skinOptions = {}
    pcall(function()
        if K.Skins and K.Skins.List then
            for _, l in ipairs(K.Skins.List()) do table.insert(skinOptions, l) end
        end
    end)
    if #skinOptions == 0 then skinOptions = { "Default" } end
    AddDropdown(MiscTab, "ActiveSkin", "Skins.ActiveSkin", skinOptions)

    local skinInfo = Instance.new("TextLabel")
    skinInfo.Size = UDim2.new(1, 0, 0, 18)
    skinInfo.BackgroundTransparency = 1
    skinInfo.Font = Enum.Font.Gotham
    skinInfo.TextSize = 11
    skinInfo.TextColor3 = Theme.SubText
    skinInfo.TextXAlignment = Enum.TextXAlignment.Left
    skinInfo.Text = string.format("Найдено скинов в игре: %d", math.max(#skinOptions - 0, 0))
    if #skinOptions == 1 and skinOptions[1] == "Default" then skinInfo.Text = "Скины в игре не найдены" end
    skinInfo.Parent = MiscTab.Page

    AddButton(MiscTab, "RescanSkins", function()
        if K.Skins and K.Skins.Rebuild then
            K.Skins.Rebuild()
            K.Toast("Скины: найдено " .. #(K.Skins.List and K.Skins.List() or {}), "info")
        end
    end)
end

AddSection(MiscTab, "Sec_Camera")
if K.GetSetting("Camera.DefaultFOV") ~= nil then AddSlider(MiscTab, "DefaultFOV", "Camera.DefaultFOV", 50, 120) end
if K.GetSetting("Camera.ZoomFOV") ~= nil then AddSlider(MiscTab, "ZoomFOV", "Camera.ZoomFOV", 20, 100) end
if K.GetSetting("Camera.ViewmodelX") ~= nil then AddSlider(MiscTab, "ViewmodelX", "Camera.ViewmodelX", -3, 3) end
if K.GetSetting("Camera.ViewmodelY") ~= nil then AddSlider(MiscTab, "ViewmodelY", "Camera.ViewmodelY", -3, 3) end
if K.GetSetting("Camera.ViewmodelZ") ~= nil then AddSlider(MiscTab, "ViewmodelZ", "Camera.ViewmodelZ", -3, 3) end

-- Keybinds
AddSection(KeybindsTab, "Sec_Keybinds")
if K.GetSetting("Keybinds.Menu") ~= nil then AddKeybind(KeybindsTab, "BindMenu", "Keybinds.Menu") end
if K.GetSetting("Keybinds.ESP") ~= nil then AddKeybind(KeybindsTab, "BindESP", "Keybinds.ESP") end
if K.GetSetting("Keybinds.Aimbot") ~= nil then AddKeybind(KeybindsTab, "BindAimbot", "Keybinds.Aimbot") end
if K.GetSetting("Keybinds.Triggerbot") ~= nil then AddKeybind(KeybindsTab, "Triggerbot", "Keybinds.Triggerbot") end
if K.GetSetting("Keybinds.Zoom") ~= nil then AddKeybind(KeybindsTab, "BindZoom", "Keybinds.Zoom") end
if K.GetSetting("Keybinds.Fly") ~= nil then AddKeybind(KeybindsTab, "BindFly", "Keybinds.Fly") end
if K.GetSetting("Keybinds.Speed") ~= nil then AddKeybind(KeybindsTab, "BindSpeed", "Keybinds.Speed") end
if K.GetSetting("Keybinds.Noclip") ~= nil then AddKeybind(KeybindsTab, "BindNoclip", "Keybinds.Noclip") end

-- Console
AddSection(ConsoleTab, "ConsoleTitle")
local ConsoleBox = Instance.new("Frame")
ConsoleBox.Size = UDim2.new(1, 0, 1, -70)
ConsoleBox.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
ConsoleBox.BackgroundTransparency = 0.1
ConsoleBox.BorderSizePixel = 0
ConsoleBox.Parent = ConsoleTab.Page
Instance.new("UICorner", ConsoleBox).CornerRadius = UDim.new(0, 6)
local ConsoleList = Instance.new("UIListLayout")
ConsoleList.Padding = UDim.new(0, 4)
ConsoleList.Parent = ConsoleBox
local ConsolePad = Instance.new("UIPadding")
ConsolePad.PaddingTop = UDim.new(0, 8)
ConsolePad.PaddingLeft = UDim.new(0, 8)
ConsolePad.PaddingRight = UDim.new(0, 8)
ConsolePad.PaddingBottom = UDim.new(0, 8)
ConsolePad.Parent = ConsoleBox

local function RefreshConsole()
    for _, ch in ipairs(ConsoleBox:GetChildren()) do
        if ch:IsA("Frame") or ch:IsA("TextLabel") then ch:Destroy() end
    end
    local hasErr = false
    for name, data in pairs(K.LoadedModules or {}) do
        hasErr = hasErr or (data.error ~= nil)
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, 0, 0, data.error and 44 or 20)
        Row.BackgroundTransparency = 1
        Row.Parent = ConsoleBox
        local ok = (data.status == "OK")
        local St = Instance.new("TextLabel")
        St.Size = UDim2.new(1, 0, 0, 18)
        St.BackgroundTransparency = 1
        St.Font = Enum.Font.GothamBold
        St.TextSize = 12
        St.TextColor3 = ok and Theme.Green or Theme.Danger
        St.TextXAlignment = Enum.TextXAlignment.Left
        St.Text = string.format("[%s] %s: %s", ok and "+" or "-", name,
            ok and Tr("ModuleStatus_OK") or Tr("ModuleStatus_FAIL"))
        St.Parent = Row
        if data.error then
            local Er = Instance.new("TextLabel")
            Er.Size = UDim2.new(1, 0, 0, 24)
            Er.Position = UDim2.new(0, 0, 0, 18)
            Er.BackgroundTransparency = 1
            Er.Font = Enum.Font.Gotham
            Er.TextSize = 10
            Er.TextColor3 = Theme.Danger
            Er.TextWrapped = true
            Er.TextXAlignment = Enum.TextXAlignment.Left
            Er.Text = tostring(data.error)
            Er.Parent = Row
        end
    end
    if not hasErr then
        local Ne = Instance.new("TextLabel")
        Ne.Size = UDim2.new(1, 0, 0, 24)
        Ne.BackgroundTransparency = 1
        Ne.Font = Enum.Font.Gotham
        Ne.TextSize = 12
        Ne.TextColor3 = Theme.SubText
        Ne.Text = Tr("NoErrors")
        Ne.Parent = ConsoleBox
    end
end

AddButton(ConsoleTab, "ClearConsole", function()
    K.LoadedModules = {}
    RefreshConsole()
end)

-- Settings
AddSection(SettingsTab, "Sec_Config")
AddButton(SettingsTab, "SaveConfig", function() K.SaveConfig() end)
AddButton(SettingsTab, "LoadConfig", function() K.LoadConfig() end)
AddButton(SettingsTab, "ResetConfig", function()
    for cat, tbl in pairs(K.Settings) do
        if type(tbl) == "table" then
            for k, v in pairs(tbl) do
                if type(v) == "boolean" then
                    tbl[k] = false
                elseif type(v) == "number" then
                    tbl[k] = 0
                end
            end
        end
    end
    if K.Notify then K.Notify("Config", "Settings reset", "success") end
    RefreshConsole()
end)

AddSection(SettingsTab, "Sec_UI")
if K.GetSetting("UI.AccentColor") == nil then
    K.Settings.UI = K.Settings.UI or {}
    K.Settings.UI.AccentColor = Theme.Accent
end
AddColorPicker(SettingsTab, "AccentColor", "UI.AccentColor")
if K.GetSetting("UI.Transparency") == nil then
    K.Settings.UI = K.Settings.UI or {}
    K.Settings.UI.Transparency = 0.1
end
AddSlider(SettingsTab, "UITransparency", "UI.Transparency", 0, 0.9)
if K.GetSetting("UI.Scale") == nil then
    K.Settings.UI = K.Settings.UI or {}
    K.Settings.UI.Scale = 1
end
AddSlider(SettingsTab, "UIScale", "UI.Scale", 0.5, 1.5)

AddSection(SettingsTab, "Sec_Info")
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, 0, 0, 50)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextSize = 11
InfoLabel.TextColor3 = Theme.SubText
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
InfoLabel.TextWrapped = true
InfoLabel.Text = "KIRO LOADER v1.2.0  |  F4 - меню"
InfoLabel.Parent = SettingsTab.Page

-- ============ BEHAVIOUR ============
-- hide any tab that ended up with no controls (e.g. Utility on CS:GO)
task.defer(function()
    local firstVisible = nil
    for _, tab in ipairs(Tabs) do
        local hasContent = false
        for _, ch in ipairs(tab.Page:GetChildren()) do
            if ch:IsA("Frame") or ch:IsA("TextButton") then
                hasContent = true
                break
            end
        end
        if not hasContent then
            tab.Button.Visible = false
        elseif not firstVisible then
            firstVisible = tab
        end
    end
    if firstVisible and ActiveTab and not ActiveTab.Button.Visible then
        SelectTab(firstVisible)
    end
end)

-- Search filter
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local query = SearchBox.Text:lower()
    for _, tab in ipairs(Tabs) do
        for _, child in ipairs(tab.Page:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") then
                local lbl = child:FindFirstChildWhichIsA("TextLabel", true)
                local text = (lbl and lbl.Text or ""):lower()
                child.Visible = (query == "") or text:find(query, 1, true)
            end
        end
    end
end)

-- Language toggle
LangButton.MouseButton1Click:Connect(function()
    local langs = { "RU", "EN" }
    local idx = 1
    for i, l in ipairs(langs) do if l == K.Lang then idx = i end end
    K.Lang = langs[(idx % #langs) + 1]
    LangButton.Text = K.Lang
    for _, fn in ipairs(Translatable) do pcall(fn) end
    SearchBox.PlaceholderText = Tr("SearchPlaceholder")
    RefreshConsole()
end)

-- Close button
local function CloseMenu()
    isMenuOpen = false
    ScreenGui.Enabled = false
end
CloseBtn.MouseButton1Click:Connect(CloseMenu)

-- one shared loop keeps every toggle's visual in sync with the real setting
task.spawn(function()
    while ScreenGui.Parent do
        task.wait(0.25)
        for _, fn in ipairs(ToggleSync) do
            pcall(fn)
        end
    end
end)

-- FPS readout (throttled to 2 Hz, K.FPS is produced by security.lua)
local fpsTimer = 0
RunService.RenderStepped:Connect(function(dt)
    fpsTimer += dt
    if fpsTimer < 0.5 then return end
    fpsTimer = 0

    local fps = tonumber(K.FPS) or 0
    if fps <= 0 then
        FpsLabel.Text = "-- FPS"
        FpsLabel.TextColor3 = Theme.TextDim
    else
        FpsLabel.Text = tostring(fps) .. " FPS"
        if fps >= 50 then
            FpsLabel.TextColor3 = Theme.Green
        elseif fps >= 30 then
            FpsLabel.TextColor3 = Color3.fromRGB(255, 200, 80)
        else
            FpsLabel.TextColor3 = Theme.Danger
        end
    end
end)

-- Console auto refresh while visible
task.spawn(function()
    while ScreenGui.Parent do
        if isMenuOpen and ConsoleTab.Page.Visible then
            pcall(RefreshConsole)
        end
        task.wait(1)
    end
end)

-- F4 via ContextActionService (works even when game input is processed)
CAS:BindActionAtPriority("KiroToggleMenu", function(_, state)
    if state == Enum.UserInputState.Begin then
        isMenuOpen = not isMenuOpen
        ScreenGui.Enabled = isMenuOpen
    end
end, false, 3000, Enum.KeyCode.F4)

-- Mouse override: run after the camera so the game cannot re-lock the cursor
RunService:BindToRenderStep("KiroMouseOverride", Enum.RenderPriority.Camera.Value + 1, function()
    if isMenuOpen and ScreenGui.Enabled then
        if UIS.MouseBehavior ~= Enum.MouseBehavior.Default then
            UIS.MouseBehavior = Enum.MouseBehavior.Default
        end
        if not UIS.MouseIconEnabled then
            UIS.MouseIconEnabled = true
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
    AddButton = AddButton,
    AddColorPicker = AddColorPicker,
    AddKeybind = AddKeybind,
    RefreshConsole = RefreshConsole,
}
return K.UI