-- =====================================================================
-- KIRO LOADER | Multi-Game Menu (v2 - Visual)
-- =====================================================================
print("[KIRO LOADER] Инициализация...")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer

local BASE = "https://raw.githubusercontent.com/glazyrindmitry15-lgtm/-kiro-scripts-/main/multihack/kiro-scripts-main/"
local KEY  = "KiroSuperSecretKey2026"

-- ============ ШИФРОВАНИЕ ============
local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local function enc(data)
    return ((data:gsub('.', function(x)
        local r,bb = '', x:byte()
        for i=8,1,-1 do r=r..(bb%2^i-bb%2^(i-1)>0 and '1' or '0') end
        return r
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if #x < 6 then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end
local function dec(data)
    data = data:gsub('[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if x == '=' then return '' end
        local r,f = '', b:find(x)-1
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if #x ~= 8 then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end
local function xor(str, key)
    local r = ""
    for i=1,#str do
        r = r .. string.char(bit32.bxor(str:byte(i), key:byte((i-1)%#key+1)))
    end
    return r
end

local K = {}
K.Base = BASE; K.Key = KEY; K.enc = enc; K.dec = dec; K.xor = xor
K.GAME_BASE = ""; K.Modules = {}
shared.KIRO = K

function K.SecureLoad(url)
    local ok, code = pcall(game.HttpGet, game, url)
    if not ok or not code or code == "" then warn("[KIRO] Не удалось скачать: "..url); return false end
    if code:sub(1,9) == "<!DOCTYPE" then warn("[KIRO] 404: "..url); return false end
    if code:sub(1,4) == "ENC:" then code = xor(dec(code:sub(5)), KEY) end
    local fn, err = loadstring(code)
    if not fn then warn("[KIRO] Ошибка компиляции: "..url.."\n"..tostring(err)); return false end
    local env = setmetatable({}, { __index = getgenv() })
    env.KIRO_PROTECTED = true; env.shared = shared
    setfenv(fn, env)
    local okRun, errRun = pcall(fn)
    if not okRun then warn("[KIRO] Ошибка выполнения: "..url.."\n"..tostring(errRun)); return false end
    return true
end

-- анти-дамп
local oldInfo = debug.info
debug.info = function(...)
    local a = {...}
    if typeof(a[1]) == "function" and getfenv(a[1]).KIRO_PROTECTED then return "C","C",1,1 end
    return oldInfo(...)
end

-- ============ ЗАГРУЗКА КОНФИГА ============
local cfgOk, cfgRaw = pcall(game.HttpGet, game, BASE.."config.lua")
if not cfgOk or not cfgRaw or cfgRaw == "" then warn("[KIRO] Нет config.lua"); return end
local cfg = loadstring(cfgRaw)()
if not cfg then warn("[KIRO] config.lua повреждён"); return end

-- ============ ТЕМА ============
local Theme = {
    BG = Color3.fromRGB(10,10,16),
    Glass = Color3.fromRGB(20,20,30),
    GlassLight = Color3.fromRGB(30,30,42),
    Accent = Color3.fromRGB(90,150,255),
    Accent2 = Color3.fromRGB(170,90,240),
    Text = Color3.fromRGB(240,240,250),
    TextDim = Color3.fromRGB(130,135,155),
    Green = Color3.fromRGB(80,220,140),
    Red = Color3.fromRGB(255,90,110),
    Gold = Color3.fromRGB(255,200,80),
}
local Font_Main = Enum.Font.GothamMedium
local Font_Bold = Enum.Font.GothamBold
local Font_Black = Enum.Font.GothamBlack

local parentGui = gethui and gethui() or game:GetService("CoreGui")

-- ============ KEY CHECK (�������� � �����) ============
local KEYS_URL = BASE.."keys.txt"
local keyVerified = false

local function verifyKey(key)
    if not key or key == "" then return false end
    local ok, data = pcall(game.HttpGet, game, KEYS_URL)
    if not ok or not data or data == "" then
        -- fallback: ���� ����� ���, ���������� ��������
        return true
    end
    for line in data:gmatch("[^\r\n]+") do
        if line:match("^%s*(.-)%s*$") == key then
            return true
        end
    end
    return false
end

-- ���������� ���� ����� �����
local function showKeyPrompt()
    local kg = Instance.new("ScreenGui")
    kg.Name = "KiroKeyPrompt"
    kg.ResetOnSpawn = false
    kg.IgnoreGuiInset = true
    kg.ZIndexBehavior = Enum.ZIndexBehavior.Global
    kg.DisplayOrder = 2147483647
    kg.Parent = parentGui

    local frame = Instance.new("Frame", kg)
    frame.Size = UDim2.new(0, 360, 0, 180)
    frame.Position = UDim2.new(0.5, -180, 0.5, -90)
    frame.BackgroundColor3 = Theme.BG
    frame.BorderSizePixel = 0
    frame.Active = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

    local t = Instance.new("TextLabel", frame)
    t.Size = UDim2.new(1, 0, 0, 40)
    t.Position = UDim2.new(0, 0, 0, 10)
    t.BackgroundTransparency = 1
    t.Text = "������� ���� �������"
    t.TextColor3 = Theme.Accent
    t.Font = Font_Black
    t.TextSize = 18

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(1, -40, 0, 36)
    box.Position = UDim2.new(0, 20, 0, 60)
    box.BackgroundColor3 = Theme.Glass
    box.TextColor3 = Theme.Text
    box.PlaceholderText = "XXXX-XXXX-XXXX-XXXX"
    box.Font = Font_Main
    box.TextSize = 14
    box.BorderSizePixel = 0
    box.ClearTextOnFocus = false
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, -40, 0, 36)
    btn.Position = UDim2.new(0, 20, 0, 110)
    btn.BackgroundColor3 = Theme.Accent
    btn.Text = "������������"
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Font_Bold
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local status = Instance.new("TextLabel", frame)
    status.Size = UDim2.new(1, 0, 0, 20)
    status.Position = UDim2.new(0, 0, 0, 150)
    status.BackgroundTransparency = 1
    status.Text = ""
    status.TextColor3 = Theme.Red
    status.Font = Font_Main
    status.TextSize = 11

    local done = false
    btn.MouseButton1Click:Connect(function()
        local key = box.Text
        if verifyKey(key) then
            status.Text = "? ���� ������"
            status.TextColor3 = Theme.Green
            task.wait(0.5)
            kg:Destroy()
            keyVerified = true
            done = true
        else
            status.Text = "? �������� ����"
            status.TextColor3 = Theme.Red
        end
    end)

    -- ��� �����������
    while not done do
        if UIS.MouseBehavior ~= Enum.MouseBehavior.Default then UIS.MouseBehavior = Enum.MouseBehavior.Default end
        if not UIS.MouseIconEnabled then UIS.MouseIconEnabled = true end
        task.wait(0.1)
    end
end

showKeyPrompt()
-- ============ GUI ============
for _, v in pairs(parentGui:GetChildren()) do
    if v.Name == "KiroLoaderMenu" then v:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KiroLoaderMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.DisplayOrder = 2147483647
ScreenGui.Parent = parentGui

-- фон с блюром
local Overlay = Instance.new("Frame", ScreenGui)
Overlay.Size = UDim2.new(1,0,1,0)
Overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
Overlay.BackgroundTransparency = 1
Overlay.BorderSizePixel = 0
Overlay.Active = true
Overlay.ZIndex = 1

-- карточка
local cardW, cardH = 520, 80 + #cfg.games * 90
local Card = Instance.new("Frame", ScreenGui)
Card.Size = UDim2.new(0, cardW, 0, cardH)
Card.Position = UDim2.new(0.5, -cardW/2, 0.5, -cardH/2)
Card.BackgroundColor3 = Theme.BG
Card.BackgroundTransparency = 1
Card.BorderSizePixel = 0
Card.Active = true
Card.ClipsDescendants = true
Card.ZIndex = 3
Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 20)

-- градиент фона карточки
local cardGrad = Instance.new("UIGradient", Card)
cardGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(16,16,24)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(6,6,12))
}
cardGrad.Rotation = 135

local CardStroke = Instance.new("UIStroke", Card)
CardStroke.Color = Theme.Accent
CardStroke.Thickness = 1.5
CardStroke.Transparency = 1

-- свечение
local Glow = Instance.new("Frame", ScreenGui)
Glow.Size = UDim2.new(0, cardW+40, 0, cardH+40)
Glow.Position = UDim2.new(0.5, -(cardW+40)/2, 0.5, -(cardH+40)/2)
Glow.BackgroundColor3 = Theme.Accent
Glow.BackgroundTransparency = 1
Glow.BorderSizePixel = 0
Glow.ZIndex = 2
Instance.new("UICorner", Glow).CornerRadius = UDim.new(0, 28)

-- заголовок
local Header = Instance.new("Frame", Card)
Header.Size = UDim2.new(1,0,0,64)
Header.BackgroundTransparency = 1
Header.ZIndex = 4

-- логотип (анимированный градиент)
local Logo = Instance.new("Frame", Header)
Logo.Size = UDim2.new(0,48,0,48)
Logo.Position = UDim2.new(0,16,0.5,-24)
Logo.BackgroundColor3 = Theme.Accent
Logo.BorderSizePixel = 0
Logo.ZIndex = 5
Instance.new("UICorner", Logo).CornerRadius = UDim.new(1,0)
local logoGrad = Instance.new("UIGradient", Logo)
logoGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Theme.Accent),
    ColorSequenceKeypoint.new(0.5, Theme.Accent2),
    ColorSequenceKeypoint.new(1, Theme.Accent)
}
local LogoK = Instance.new("TextLabel", Logo)
LogoK.Size = UDim2.new(1,0,1,0)
LogoK.BackgroundTransparency = 1
LogoK.Text = "K"
LogoK.TextColor3 = Color3.fromRGB(255,255,255)
LogoK.Font = Font_Black
LogoK.TextSize = 26
LogoK.ZIndex = 6
task.spawn(function()
    while Logo and Logo.Parent do
        logoGrad.Rotation = (logoGrad.Rotation + 1.5) % 360
        task.wait(0.03)
    end
end)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1,-120,0,22)
Title.Position = UDim2.new(0,72,0,14)
Title.BackgroundTransparency = 1
Title.Text = "KIRO LOADER"
Title.TextColor3 = Theme.Text
Title.Font = Font_Black
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 5

local Subtitle = Instance.new("TextLabel", Header)
Subtitle.Size = UDim2.new(1,-120,0,16)
Subtitle.Position = UDim2.new(0,72,0,38)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Мульти-игровая загрузка • v2"
Subtitle.TextColor3 = Theme.TextDim
Subtitle.Font = Font_Main
Subtitle.TextSize = 11
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.ZIndex = 5

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0,32,0,32)
CloseBtn.Position = UDim2.new(1,-44,0.5,-16)
CloseBtn.BackgroundColor3 = Theme.GlassLight
CloseBtn.BackgroundTransparency = 0.4
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Theme.Red
CloseBtn.Font = Font_Bold
CloseBtn.TextSize = 14
CloseBtn.BorderSizePixel = 0
CloseBtn.AutoButtonColor = false
CloseBtn.ZIndex = 5
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- разделитель
local Divider = Instance.new("Frame", Card)
Divider.Size = UDim2.new(1,-32,0,1)
Divider.Position = UDim2.new(0,16,0,64)
Divider.BackgroundColor3 = Theme.GlassLight
Divider.BorderSizePixel = 0
Divider.ZIndex = 4

-- статус
local Status = Instance.new("TextLabel", Card)
Status.Size = UDim2.new(1,-32,0,16)
Status.Position = UDim2.new(0,16,1,-20)
Status.BackgroundTransparency = 1
Status.Text = "Готово к запуску"
Status.TextColor3 = Theme.TextDim
Status.Font = Font_Main
Status.TextSize = 11
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.ZIndex = 4

-- прогресс-бар
local ProgressBg = Instance.new("Frame", Card)
ProgressBg.Size = UDim2.new(1,-32,0,3)
ProgressBg.Position = UDim2.new(0,16,1,-6)
ProgressBg.BackgroundColor3 = Theme.GlassLight
ProgressBg.BorderSizePixel = 0
ProgressBg.ZIndex = 4
Instance.new("UICorner", ProgressBg).CornerRadius = UDim.new(1,0)
local ProgressFill = Instance.new("Frame", ProgressBg)
ProgressFill.Size = UDim2.new(0,0,1,0)
ProgressFill.BackgroundColor3 = Theme.Accent
ProgressFill.BorderSizePixel = 0
ProgressFill.ZIndex = 5
Instance.new("UICorner", ProgressFill).CornerRadius = UDim.new(1,0)
local ProgressGrad = Instance.new("UIGradient", ProgressFill)
ProgressGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Theme.Accent), ColorSequenceKeypoint.new(1, Theme.Accent2)}

-- список игр
local Scroll = Instance.new("ScrollingFrame", Card)
Scroll.Size = UDim2.new(1,-24,0, cardH - 90)
Scroll.Position = UDim2.new(0,12,0,70)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Theme.Accent
Scroll.ScrollBarImageTransparency = 0.3
Scroll.CanvasSize = UDim2.new(0,0,0,0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.ZIndex = 4

local ListLayout = Instance.new("UIListLayout", Scroll)
ListLayout.Padding = UDim.new(0,10)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- функция загрузки
local function LoadScript(gameInfo)
    Status.Text = "Загрузка: " .. gameInfo.name .. "..."
    Status.TextColor3 = Theme.Accent
    ProgressFill.Size = UDim2.new(0.15,0,1,0)
    task.spawn(function()
        task.wait(0.05)
        ProgressFill.Size = UDim2.new(0.4,0,1,0)
        K.GAME_BASE = BASE.."games/"..gameInfo.id.."/"\n        K.GameId = gameInfo.id
        local ok = K.SecureLoad(K.GAME_BASE.."entry.lua")
        ProgressFill.Size = UDim2.new(1,0,1,0)
        if ok then
            Status.Text = "✓ " .. gameInfo.name .. " загружен"
            Status.TextColor3 = Theme.Green
            task.wait(0.5)
            ScreenGui:Destroy()
        else
            Status.Text = "✕ Ошибка загрузки " .. gameInfo.name
            Status.TextColor3 = Theme.Red
            ProgressFill.BackgroundColor3 = Theme.Red
        end
    end)
end

-- создание карточки игры
local function MakeGameCard(gameInfo, layoutOrder)
    local card = Instance.new("TextButton", Scroll)
    card.Size = UDim2.new(1,-8,0,78)
    card.BackgroundColor3 = Theme.Glass
    card.BackgroundTransparency = 0.05
    card.Text = ""
    card.BorderSizePixel = 0
    card.AutoButtonColor = false
    card.ZIndex = 5
    card.LayoutOrder = layoutOrder
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", card)
    stroke.Color = Theme.GlassLight
    stroke.Thickness = 1
    stroke.Transparency = 0.5

    -- иконка игры
    local iconFrame = Instance.new("Frame", card)
    iconFrame.Size = UDim2.new(0,62,0,62)
    iconFrame.Position = UDim2.new(0,8,0.5,-31)
    iconFrame.BackgroundColor3 = Theme.GlassLight
    iconFrame.BorderSizePixel = 0
    iconFrame.ZIndex = 6
    Instance.new("UICorner", iconFrame).CornerRadius = UDim.new(0, 10)

    -- rbxthumb иконка
    local iconImg = Instance.new("ImageLabel", iconFrame)
    iconImg.Size = UDim2.new(1,-4,1,-4)
    iconImg.Position = UDim2.new(0,2,0,2)
    iconImg.BackgroundTransparency = 1
    iconImg.ScaleType = Enum.ScaleType.Fit
    iconImg.ZIndex = 7
    Instance.new("UICorner", iconImg).CornerRadius = UDim.new(0, 8)

    -- попытка загрузить иконку
    task.spawn(function()
        -- сначала пробуем rbxthumb по placeId
        if gameInfo.placeId and gameInfo.placeId > 0 then
            iconImg.Image = "rbxthumb://type=GameIcon&id="..gameInfo.placeId.."&w=150&h=150"
        elseif gameInfo.icon and gameInfo.icon ~= "" then
            iconImg.Image = gameInfo.icon
        end
        -- fallback: если не загрузилось, показываем первую букву
        task.wait(0.5)
        if iconImg.Image == "" or iconImg.Image == nil then
            iconImg.Visible = false
            local letter = Instance.new("TextLabel", iconFrame)
            letter.Size = UDim2.new(1,0,1,0)
            letter.BackgroundTransparency = 1
            letter.Text = string.sub(gameInfo.name,1,1)
            letter.TextColor3 = Theme.Accent
            letter.Font = Font_Black
            letter.TextSize = 28
            letter.ZIndex = 7
        end
    end)

    -- акцент-полоска слева
    local accent = Instance.new("Frame", card)
    accent.Size = UDim2.new(0,3,0.6,0)
    accent.Position = UDim2.new(0,74,0.2,0)
    accent.BackgroundColor3 = Theme.Accent
    accent.BorderSizePixel = 0
    accent.ZIndex = 6
    Instance.new("UICorner", accent).CornerRadius = UDim.new(1,0)

    local nameLbl = Instance.new("TextLabel", card)
    nameLbl.Size = UDim2.new(1,-170,0,22)
    nameLbl.Position = UDim2.new(0,84,0,12)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = gameInfo.name
    nameLbl.TextColor3 = Theme.Text
    nameLbl.Font = Font_Bold
    nameLbl.TextSize = 15
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.ZIndex = 6

    local descLbl = Instance.new("TextLabel", card)
    descLbl.Size = UDim2.new(1,-170,0,16)
    descLbl.Position = UDim2.new(0,84,0,36)
    descLbl.BackgroundTransparency = 1
    descLbl.Text = gameInfo.desc or ""
    descLbl.TextColor3 = Theme.TextDim
    descLbl.Font = Font_Main
    descLbl.TextSize = 11
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.ZIndex = 6

    -- статус (поддерживается ли)
    local statusLbl = Instance.new("TextLabel", card)
    statusLbl.Size = UDim2.new(1,-170,0,14)
    statusLbl.Position = UDim2.new(0,84,0,54)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Text = "● Готов к запуску"
    statusLbl.TextColor3 = Theme.Green
    statusLbl.Font = Font_Main
    statusLbl.TextSize = 10
    statusLbl.TextXAlignment = Enum.TextXAlignment.Left
    statusLbl.ZIndex = 6

    -- кнопка загрузки
    local loadBtn = Instance.new("TextButton", card)
    loadBtn.Size = UDim2.new(0,92,0,34)
    loadBtn.Position = UDim2.new(1,-102,0.5,-17)
    loadBtn.BackgroundColor3 = Theme.Accent
    loadBtn.BackgroundTransparency = 0.15
    loadBtn.Text = "ЗАПУСТИТЬ"
    loadBtn.TextColor3 = Color3.fromRGB(255,255,255)
    loadBtn.Font = Font_Bold
    loadBtn.TextSize = 11
    loadBtn.BorderSizePixel = 0
    loadBtn.AutoButtonColor = false
    loadBtn.ZIndex = 6
    Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0, 8)

    local loadGrad = Instance.new("UIGradient", loadBtn)
    loadGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Theme.Accent), ColorSequenceKeypoint.new(1, Theme.Accent2)}
    loadGrad.Rotation = 90

    loadBtn.MouseEnter:Connect(function()
        TweenService:Create(loadBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0, Size = UDim2.new(0,96,0,36)}):Play()
    end)
    loadBtn.MouseLeave:Connect(function()
        TweenService:Create(loadBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.15, Size = UDim2.new(0,92,0,34)}):Play()
    end)
    loadBtn.MouseButton1Click:Connect(function()
        LoadScript(gameInfo)
    end)

    card.MouseEnter:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.15), {Transparency = 0.2, Color = Theme.Accent}):Play()
    end)
    card.MouseLeave:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.15), {BackgroundTransparency = 0.05}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.15), {Transparency = 0.5, Color = Theme.GlassLight}):Play()
    end)

    return card
end

-- создание карточек
for i, g in ipairs(cfg.games) do
    MakeGameCard(g, i)
end

-- анимация появления
Overlay.BackgroundTransparency = 1
Card.BackgroundTransparency = 1
CardStroke.Transparency = 1
Glow.BackgroundTransparency = 1
task.spawn(function()
    task.wait(0.05)
    TweenService:Create(Overlay, TweenInfo.new(0.3), {BackgroundTransparency = 0.4}):Play()
    TweenService:Create(Card, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.02}):Play()
    TweenService:Create(CardStroke, TweenInfo.new(0.35), {Transparency = 0.4}):Play()
    TweenService:Create(Glow, TweenInfo.new(0.35), {BackgroundTransparency = 0.88}):Play()
end)

-- mouse fix
RunService.RenderStepped:Connect(function()
    if ScreenGui and ScreenGui.Parent then
        if UIS.MouseBehavior ~= Enum.MouseBehavior.Default then UIS.MouseBehavior = Enum.MouseBehavior.Default end
        if not UIS.MouseIconEnabled then UIS.MouseIconEnabled = true end
    end
end)

print("[KIRO LOADER] Меню создано. Игр: "..#cfg.games)
