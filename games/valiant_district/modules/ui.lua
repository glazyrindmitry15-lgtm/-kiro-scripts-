-- ui.lua | Kiro Scripts UI Library (Valiant District)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local env = (getgenv and getgenv()) or _G or shared
local K = env.K or _G.K or shared.K or {}
env.K = K
_G.K = K

K.Settings = K.Settings or {}
K.Lang = K.Lang or "RU"
K.GameId = K.GameId or "valiant_district"
K.LoadedModules = K.LoadedModules or {}

if type(K.GetSetting) ~= "function" then
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
end

if type(K.SetSetting) ~= "function" then
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
        Tab_Combat = "Бой", Tab_Visuals = "Визуалы", Tab_Utility = "Утилиты", Tab_Misc = "Разное", Tab_Console = "Консоль",
        Sec_Aimbot = "АИМБОТ", Sec_Valiant = "VALIANT", Sec_ESP = "ESP", Sec_Movement = "ПЕРЕДВИЖЕНИЕ", Sec_World = "МИР",
        Aimbot = "Включить Аимбот", SilentAim = "Сайлент Аим", ShowFOV = "Показать FOV", FOV = "Радиус FOV", Smoothness = "Плавность",
        WallCheck = "Проверка стен", TeamCheck = "Проверка команды",
        AutoRepair = "Авто-починка", AutoSkillCheck = "Авто скилл-чек",
        KillerESP = "ESP Маньяка", GeneratorESP = "ESP Генераторов",
        ESPEnabled = "Включить ESP", BoxESP = "Боксы", NameESP = "Имена", HealthESP = "Здоровье",
        Tracers = "Трейсеры", TracerOrigin = "Начало трейсера", Snaplines = "Снаплайны", Chams = "Чамсы",
        MaxDistance = "Макс. дистанция", Radar = "Радар",
        Fly = "Полёт", FlySpeed = "Скорость полёта", Noclip = "Ноклип", InfJump = "Инф. прыжок",
        WalkSpeed = "Скорость ходьбы", JumpPower = "Сила прыжка", BunnyHop = "Баннихоп", Fullbright = "Фулбрайт",
        ModuleStatus_OK = "Загружен", ModuleStatus_FAIL = "Ошибка", ConsoleTitle = "Консоль", ClearConsole = "Очистить", NoErrors = "Ошибок нет",
    },
    EN = {
        Tab_Combat = "Combat", Tab_Visuals = "Visuals", Tab_Utility = "Utility", Tab_Misc = "Misc", Tab_Console = "Console",
        Sec_Aimbot = "AIMBOT", Sec_Valiant = "VALIANT", Sec_ESP = "ESP", Sec_Movement = "Movement", Sec_World = "World",
        Aimbot = "Enable Aimbot", SilentAim = "Silent Aim", ShowFOV = "Show FOV", FOV = "FOV Radius", Smoothness = "Smoothness",
        WallCheck = "Wall Check", TeamCheck = "Team Check",
        AutoRepair = "Auto Repair", AutoSkillCheck = "Auto Skill Check",
        KillerESP = "Killer ESP", GeneratorESP = "Generator ESP",
        ESPEnabled = "Enable ESP", BoxESP = "Box ESP", NameESP = "Name ESP", HealthESP = "Health Bar",
        Tracers = "Tracers", TracerOrigin = "Tracer Origin", Snaplines = "Snaplines", Chams = "Chams",
        MaxDistance = "Max Distance", Radar = "Radar",
        Fly = "Fly", FlySpeed = "Fly Speed", Noclip = "Noclip", InfJump = "Inf Jump",
        WalkSpeed = "Walk Speed", JumpPower = "Jump Power", BunnyHop = "Bunny Hop", Fullbright = "Fullbright",
        ModuleStatus_OK = "Loaded", ModuleStatus_FAIL = "Failed", ConsoleTitle = "Console", ClearConsole = "Clear", NoErrors = "No errors",
    },
    JA = {
        Tab_Combat = "戦闘", Tab_Visuals = "ビジュアル", Tab_Utility = "ユーティリティ", Tab_Misc = "その他", Tab_Console = "コンソール",
        Sec_Aimbot = "エイムボット", Sec_Valiant = "VALIANT", Sec_ESP = "ESP", Sec_Movement = "移動", Sec_World = "ワールド",
        Aimbot = "エイムボット有効", SilentAim = "サイレントエイム", ShowFOV = "FOV表示", FOV = "FOV半径", Smoothness = "滑らかさ",
        WallCheck = "壁チェック", TeamCheck = "チームチェック",
        AutoRepair = "自動修理", AutoSkillCheck = "自動スキルチェック",
        KillerESP = "キラーESP", GeneratorESP = "発電機ESP",
        ESPEnabled = "ESP有効", BoxESP = "ボックス", NameESP = "名前", HealthESP = "ヘルスバー",
        Tracers = "トレーサー", TracerOrigin = "始点", Snaplines = "スナップライン", Chams = "チャムス",
        MaxDistance = "最大距離", Radar = "レーダー",
        Fly = "フライ", FlySpeed = "フライ速度", Noclip = "ノックリップ", InfJump = "無限ジャンプ",
        WalkSpeed = "歩行速度", JumpPower = "ジャンプ力", BunnyHop = "バニーホップ", Fullbright = "フルブライト",
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

local overlay = Instance.new("Frame")
overlay.Size = UDim2.new(1,0,1,0)
overlay.BackgroundColor3 = Theme.OverlayDark
overlay.BackgroundTransparency = 0.5
overlay.BorderSizePixel = 0
overlay.ZIndex = 1
overlay.Parent = ScreenGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 620, 0, 440)
Main.Position = UDim2.new(0.5, -310, 0.5, -220)
Main.BackgroundColor3 = Theme.Background
Main.BackgroundTransparency = 0.05
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
bg.ImageTransparency = 0.25
bg.ZIndex = 1
bg.Parent = Main

local bgOverlay = Instance.new("Frame")
bgOverlay.Size = UDim2.new(1,0,1,0)
bgOverlay.BackgroundColor3 = Theme.OverlayDark
bgOverlay.BackgroundTransparency = 0.4
bgOverlay.BorderSizePixel = 0
bgOverlay.ZIndex = 2
bgOverlay.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.Accent
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.3
MainStroke.Parent = Main

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1,0,0,48)
TopBar.BackgroundColor3 = Theme.Sidebar
TopBar.BackgroundTransparency = 0.2
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
    Btn.MouseButton1Click:Connect(function() SelectTab(tab) end)
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
    end
    Frame.MouseButton1Click:Connect(function() Update(not state) end)
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

    local Track = Instance.new("Frame")
    Track.Name = "Track"
    Track.Size = UDim2.new(1,-24,0,8)
    Track.Position = UDim2.new(0,12,0,32)
    Track.BackgroundColor3 = Color3.fromRGB(20,20,30)
    Track.BorderSizePixel = 0
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

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0,14,0,14)
    Knob.Position = UDim2.new(alpha,-7,0.5,-7)
    Knob.BackgroundColor3 = Theme.Text
    Knob.BorderSizePixel = 0
    Knob.ZIndex = 16
    Knob.Parent = Track
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1,0)

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
    return Frame
end

local function AddDropdown(tab, key, path, options)
    tab.NextOrder += 1
    local current = K.GetSetting(path) or options[1]
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

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0,120,0,24)
    Btn.Position = UDim2.new(1,-132,0.5,-12)
    Btn.BackgroundColor3 = Theme.Accent
    Btn.BackgroundTransparency = 0.2
    Btn.BorderSizePixel = 0
    Btn.Text = current
    Btn.TextColor3 = Theme.Text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 12
    Btn.ZIndex = 14
    Btn.Parent = Frame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,4)

    local open = false
    local OptFrame = nil
    local function Close()
        if OptFrame then OptFrame:Destroy() OptFrame=nil end
        open = false
    end
    Btn.MouseButton1Click:Connect(function()
        if open then Close() return end
        open = true
        OptFrame = Instance.new("Frame")
        OptFrame.Size = UDim2.new(0,120,0,#options*26)
        OptFrame.Position = UDim2.new(1,-132,1,4)
        OptFrame.BackgroundColor3 = Theme.Content
        OptFrame.BackgroundTransparency = 0.1
        OptFrame.BorderSizePixel = 0
        OptFrame.ZIndex = 20
        OptFrame.ClipsDescendants = true
        OptFrame.Parent = Frame
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
            Ob.MouseButton1Click:Connect(function()
                current = opt
                Btn.Text = opt
                K.SetSetting(path, opt)
                Close()
            end)
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
    return Frame
end

-- ============ TABS FOR VALIANT DISTRICT ============
local CombatTab  = CreateTab("Tab_Combat", 1)
local VisualsTab = CreateTab("Tab_Visuals", 2)
local UtilityTab = CreateTab("Tab_Utility", 3)
local MiscTab    = CreateTab("Tab_Misc", 4)
local ConsoleTab = CreateTab("Tab_Console", 5)

-- Combat (Aimbot only)
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

-- Utility (Valiant specific)
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
ClearBtn.MouseButton1Click:Connect(function() K.LoadedModules={} RefreshConsole() end)
task.spawn(function() while task.wait(1) do if ConsoleTab.Page.Visible then RefreshConsole() end end end)

LangButton.MouseButton1Click:Connect(function()
    local langs = {"RU","EN","JA"}
    local idx = 1
    for i,l in ipairs(langs) do if l==K.Lang then idx=i end end
    K.Lang = langs[(idx%#langs)+1]
    LangButton.Text = K.Lang
    for _,fn in ipairs(TranslatableElements) do pcall(fn) end
    RefreshConsole()
end)

CloseButton.MouseButton1Click:Connect(function() ScreenGui.Enabled=false end)
UserInputService.InputBegan:Connect(function(input,gp) if not gp and input.KeyCode==Enum.KeyCode.F4 then ScreenGui.Enabled=not ScreenGui.Enabled end end)
RunService.RenderStepped:Connect(function()
    if ScreenGui.Enabled then
        if UserInputService.MouseBehavior~=Enum.MouseBehavior.Default then UserInputService.MouseBehavior=Enum.MouseBehavior.Default end
        if not UserInputService.MouseIconEnabled then UserInputService.MouseIconEnabled=true end
    end
end)

K.UI = {ScreenGui=ScreenGui, Main=Main, AddSection=AddSection, AddToggle=AddToggle, AddSlider=AddSlider, AddDropdown=AddDropdown, RefreshConsole=RefreshConsole}
return K.UI