-- =====================================================================
-- KIRO LOADER | Multi-Game Menu (FIXED)
-- =====================================================================
print("[KIRO LOADER] Инициализация...")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LP = Players.LocalPlayer

-- ССЫЛКА НА ТВОЙ НОВЫЙ РЕПОЗИТОРИЙ (с дефисами)
local GITHUB_BASE = "https://raw.githubusercontent.com/glazyrindmitry15-lgtm/-kiro-scripts-/main/"

local SUPPORTED_GAMES = {
    {
        name = "FUST",
        file = "games/fust/entry.lua", 
        desc = "Aimbot • ESP • Visuals",
        placeIds = {}
    },
    {
        name = "CS:GO Roblox",
        file = "games/cs_go/entry.lua",
        desc = "ESP • Trigger • RCS • BHop",
        placeIds = {}
    }
}

local Theme = {
    BG=Color3.fromRGB(8,8,12), Glass=Color3.fromRGB(18,18,24), GlassLight=Color3.fromRGB(26,26,36),
    Accent=Color3.fromRGB(100,160,240), Accent2=Color3.fromRGB(160,90,230),
    Text=Color3.fromRGB(245,245,250), TextDim=Color3.fromRGB(120,125,140),
    Red=Color3.fromRGB(255,90,110), Green=Color3.fromRGB(80,230,150),
}
local Font_Main = Enum.Font.GothamMedium
local Font_Bold = Enum.Font.GothamBold
local Font_Black = Enum.Font.GothamBlack

local function FindGameByPlaceId(pid)
    for _, g in ipairs(SUPPORTED_GAMES) do
        if #g.placeIds == 0 then return g end
        for _, id in ipairs(g.placeIds) do
            if id == pid then return g end
        end
    end
    return nil
end

local function LoadScript(file)
    local url = GITHUB_BASE .. file
    print("[KIRO LOADER] Скачивание:", url)
    local ok, code = pcall(game.HttpGet, game, url)
    if not ok or not code or code == "" then return false, "Не удалось скачать скрипт" end
    
    if string.sub(code, 1, 9) == "<!DOCTYPE" then 
        return false, "Ошибка 404: Файл не найден на GitHub!" 
    end
    
    local fn, err = loadstring(code)
    if not fn then return false, "Ошибка компиляции: " .. tostring(err) end
    local ok2, err2 = pcall(fn)
    if not ok2 then return false, "Ошибка выполнения: " .. tostring(err2) end
    return true
end

local parentGui = gethui and gethui() or game:GetService("CoreGui")
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

local Overlay = Instance.new("Frame", ScreenGui)
Overlay.Size = UDim2.new(1,0,1,0)
Overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
Overlay.BackgroundTransparency = 0.35
Overlay.BorderSizePixel = 0
Overlay.Active = true
Overlay.ZIndex = 1

local Glow = Instance.new("Frame", ScreenGui)
Glow.Size = UDim2.new(0,644,0,484)
Glow.Position = UDim2.new(0.5,-322,0.5,-242)
Glow.BackgroundColor3 = Theme.Accent
Glow.BackgroundTransparency = 0.85
Glow.BorderSizePixel = 0
Glow.ZIndex = 2
Instance.new("UICorner", Glow).CornerRadius = UDim.new(0, 24)

local Card = Instance.new("Frame", ScreenGui)
Card.Size = UDim2.new(0,640,0,480)
Card.Position = UDim2.new(0.5,-320,0.5,-240)
Card.BackgroundColor3 = Theme.BG
Card.BackgroundTransparency = 0.02
Card.BorderSizePixel = 0
Card.ClipsDescendants = true
Card.Active = true
Card.ZIndex = 3
Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 20)

local CardGrad = Instance.new("UIGradient", Card)
CardGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(12,12,18)), ColorSequenceKeypoint.new(1, Color3.fromRGB(4,4,8))}
CardGrad.Rotation = 135

local CardStroke = Instance.new("UIStroke", Card)
CardStroke.Color = Theme.Accent
CardStroke.Thickness = 1
CardStroke.Transparency = 0.5

local Header = Instance.new("Frame", Card)
Header.Size = UDim2.new(1,0,0,80)
Header.BackgroundTransparency = 1
Header.ZIndex = 4

local Logo = Instance.new("Frame", Header)
Logo.Size = UDim2.new(0,56,0,56)
Logo.Position = UDim2.new(0,20,0.5,-28)
Logo.BackgroundColor3 = Theme.Accent
Logo.BorderSizePixel = 0
Logo.ZIndex = 5
Instance.new("UICorner", Logo).CornerRadius = UDim.new(1,0)
local logoGrad = Instance.new("UIGradient", Logo)
logoGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Theme.Accent), ColorSequenceKeypoint.new(0.5, Theme.Accent2), ColorSequenceKeypoint.new(1, Theme.Accent)}
local LogoK = Instance.new("TextLabel", Logo)
LogoK.Size = UDim2.new(1,0,1,0)
LogoK.BackgroundTransparency = 1
LogoK.Text = "K"
LogoK.TextColor3 = Color3.fromRGB(255,255,255)
LogoK.Font = Font_Black
LogoK.TextSize = 30
LogoK.ZIndex = 6
task.spawn(function() while Logo and Logo.Parent do logoGrad.Rotation = (logoGrad.Rotation + 2) % 360; task.wait(0.03) end end)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1,-120,0,26)
Title.Position = UDim2.new(0,88,0,18)
Title.BackgroundTransparency = 1
Title.Text = "KIRO LOADER"
Title.TextColor3 = Theme.Text
Title.Font = Font_Black
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 5

local Subtitle = Instance.new("TextLabel", Header)
Subtitle.Size = UDim2.new(1,-120,0,16)
Subtitle.Position = UDim2.new(0,88,0,46)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Мульти-игровая загрузка"
Subtitle.TextColor3 = Theme.TextDim
Subtitle.Font = Font_Main
Subtitle.TextSize = 11
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.ZIndex = 5

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0,32,0,32)
CloseBtn.Position = UDim2.new(1,-44,0.5,-16)
CloseBtn.BackgroundColor3 = Theme.GlassLight
CloseBtn.BackgroundTransparency = 0.3
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Theme.Red
CloseBtn.Font = Font_Bold
CloseBtn.TextSize = 14
CloseBtn.BorderSizePixel = 0
CloseBtn.AutoButtonColor = false
CloseBtn.ZIndex = 5
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local Divider = Instance.new("Frame", Card)
Divider.Size = UDim2.new(1,-40,0,1)
Divider.Position = UDim2.new(0,20,0,80)
Divider.BackgroundColor3 = Theme.GlassLight
Divider.BorderSizePixel = 0
Divider.ZIndex = 4

local CurrentBox = Instance.new("Frame", Card)
CurrentBox.Size = UDim2.new(1,-40,0,72)
CurrentBox.Position = UDim2.new(0,20,0,96)
CurrentBox.BackgroundColor3 = Theme.Glass
CurrentBox.BackgroundTransparency = 0.1
CurrentBox.BorderSizePixel = 0
CurrentBox.ZIndex = 4
Instance.new("UICorner", CurrentBox).CornerRadius = UDim.new(0,12)

local CurAccent = Instance.new("Frame", CurrentBox)
CurAccent.Size = UDim2.new(0,3,0.6,0)
CurAccent.Position = UDim2.new(0,10,0.2,0)
CurAccent.BackgroundColor3 = Theme.Accent
CurAccent.BorderSizePixel = 0
CurAccent.ZIndex = 5
Instance.new("UICorner", CurAccent).CornerRadius = UDim.new(1,0)

local CurLabel = Instance.new("TextLabel", CurrentBox)
CurLabel.Size = UDim2.new(1,-140,0,16)
CurLabel.Position = UDim2.new(0,24,0,10)
CurLabel.BackgroundTransparency = 1
CurLabel.Text = "ТЕКУЩАЯ ИГРА"
CurLabel.TextColor3 = Theme.Accent
CurLabel.Font = Font_Bold
CurLabel.TextSize = 10
CurLabel.TextXAlignment = Enum.TextXAlignment.Left
CurLabel.ZIndex = 5

local CurGameName = Instance.new("TextLabel", CurrentBox)
CurGameName.Size = UDim2.new(1,-140,0,22)
CurGameName.Position = UDim2.new(0,24,0,28)
CurGameName.BackgroundTransparency = 1
CurGameName.Text = "..."
CurGameName.TextColor3 = Theme.Text
CurGameName.Font = Font_Bold
CurGameName.TextSize = 15
CurGameName.TextXAlignment = Enum.TextXAlignment.Left
CurGameName.ZIndex = 5

local CurPlace = Instance.new("TextLabel", CurrentBox)
CurPlace.Size = UDim2.new(1,-140,0,14)
CurPlace.Position = UDim2.new(0,24,0,50)
CurPlace.BackgroundTransparency = 1
CurPlace.Text = "PlaceId: ..."
CurPlace.TextColor3 = Theme.TextDim
CurPlace.Font = Font_Main
CurPlace.TextSize = 10
CurPlace.TextXAlignment = Enum.TextXAlignment.Left
CurPlace.ZIndex = 5

local LaunchBtn = Instance.new("TextButton", CurrentBox)
LaunchBtn.Size = UDim2.new(0,110,0,44)
LaunchBtn.Position = UDim2.new(1,-122,0.5,-22)
LaunchBtn.BackgroundColor3 = Theme.Green
LaunchBtn.BorderSizePixel = 0
LaunchBtn.Text = "ЗАПУСТИТЬ"
LaunchBtn.TextColor3 = Color3.fromRGB(255,255,255)
LaunchBtn.Font = Font_Bold
LaunchBtn.TextSize = 11
LaunchBtn.AutoButtonColor = false
LaunchBtn.ZIndex = 5
Instance.new("UICorner", LaunchBtn).CornerRadius = UDim.new(0, 10)

local ListLabel = Instance.new("TextLabel", Card)
ListLabel.Size = UDim2.new(1,-40,0,16)
ListLabel.Position = UDim2.new(0,20,0,180)
ListLabel.BackgroundTransparency = 1
ListLabel.Text = "ДОСТУПНЫЕ СКРИПТЫ"
ListLabel.TextColor3 = Theme.Accent
ListLabel.Font = Font_Bold
ListLabel.TextSize = 10
ListLabel.TextXAlignment = Enum.TextXAlignment.Left
ListLabel.ZIndex = 4

local Scroll = Instance.new("ScrollingFrame", Card)
Scroll.Size = UDim2.new(1,-40,0,210)
Scroll.Position = UDim2.new(0,20,0,200)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = Theme.Accent
Scroll.ScrollBarImageTransparency = 0.4
Scroll.CanvasSize = UDim2.new(0,0,0,0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.ZIndex = 4

local ListLayout = Instance.new("UIListLayout", Scroll)
ListLayout.Padding = UDim.new(0,8)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local Status = Instance.new("TextLabel", Card)
Status.Size = UDim2.new(1,-40,0,16)
Status.Position = UDim2.new(0,20,1,-36)
Status.BackgroundTransparency = 1
Status.Text = "Готово к запуску"
Status.TextColor3 = Theme.TextDim
Status.Font = Font_Main
Status.TextSize = 11
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.ZIndex = 4

local ProgressBg = Instance.new("Frame", Card)
ProgressBg.Size = UDim2.new(1,-40,0,3)
ProgressBg.Position = UDim2.new(0,20,1,-14)
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

local LoadFromUI
LoadFromUI = function(game)
    Status.Text = "Загрузка: " .. game.name .. "..."
    Status.TextColor3 = Theme.Accent
    ProgressFill.BackgroundColor3 = Theme.Accent
    ProgressFill.Size = UDim2.new(0.2, 0, 1, 0)
    task.spawn(function()
        task.wait(0.1)
        ProgressFill.Size = UDim2.new(0.5, 0, 1, 0)
        local ok, err = LoadScript(game.file)
        ProgressFill.Size = UDim2.new(1, 0, 1, 0)
        if ok then
            Status.Text = "✓ " .. game.name .. " загружен"
            Status.TextColor3 = Theme.Green
            task.wait(0.4)
            TweenService:Create(Card, TweenInfo.new(0.3), {BackgroundTransparency=1}):Play()
            TweenService:Create(Glow, TweenInfo.new(0.3), {BackgroundTransparency=1}):Play()
            TweenService:Create(Overlay, TweenInfo.new(0.3), {BackgroundTransparency=1}):Play()
            for _, v in ipairs(Card:GetDescendants()) do
                if v:IsA("TextLabel") or v:IsA("TextButton") then
                    TweenService:Create(v, TweenInfo.new(0.3), {TextTransparency=1}):Play()
                elseif v:IsA("Frame") and v.BackgroundTransparency < 1 then
                    TweenService:Create(v, TweenInfo.new(0.3), {BackgroundTransparency=1}):Play()
                elseif v:IsA("UIStroke") then
                    TweenService:Create(v, TweenInfo.new(0.3), {Transparency=1}):Play()
                end
            end
            task.delay(0.4, function() ScreenGui:Destroy() end)
        else
            Status.Text = "✕ " .. (err or "неизвестно")
            Status.TextColor3 = Theme.Red
            ProgressFill.BackgroundColor3 = Theme.Red
        end
    end)
end

local function MakeGameCard(game, isCurrent, layoutOrder)
    local card = Instance.new("TextButton", Scroll)
    card.Size = UDim2.new(1,-8,0,58)
    card.BackgroundColor3 = isCurrent and Theme.GlassLight or Theme.Glass
    card.BackgroundTransparency = isCurrent and 0 or 0.15
    card.Text = ""
    card.BorderSizePixel = 0
    card.AutoButtonColor = false
    card.ZIndex = 5
    card.LayoutOrder = layoutOrder
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke", card)
    stroke.Color = isCurrent and Theme.Green or Theme.TextDim
    stroke.Thickness = 1
    stroke.Transparency = isCurrent and 0.3 or 0.8

    local accent = Instance.new("Frame", card)
    accent.Size = UDim2.new(0,3,0.6,0)
    accent.Position = UDim2.new(0,8,0.2,0)
    accent.BackgroundColor3 = isCurrent and Theme.Green or Theme.Accent
    accent.BorderSizePixel = 0
    accent.ZIndex = 6
    Instance.new("UICorner", accent).CornerRadius = UDim.new(1,0)

    local nameLbl = Instance.new("TextLabel", card)
    nameLbl.Size = UDim2.new(1,-180,0,18)
    nameLbl.Position = UDim2.new(0,20,0,10)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = game.name
    nameLbl.TextColor3 = Theme.Text
    nameLbl.Font = Font_Bold
    nameLbl.TextSize = 13
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.ZIndex = 6

    local descLbl = Instance.new("TextLabel", card)
    descLbl.Size = UDim2.new(1,-180,0,14)
    descLbl.Position = UDim2.new(0,20,0,32)
    descLbl.BackgroundTransparency = 1
    descLbl.Text = game.desc or ""
    descLbl.TextColor3 = Theme.TextDim
    descLbl.Font = Font_Main
    descLbl.TextSize = 10
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.ZIndex = 6

    if isCurrent then
        local badge = Instance.new("TextLabel", card)
        badge.Size = UDim2.new(0,72,0,20)
        badge.Position = UDim2.new(1,-84,0.5,-10)
        badge.BackgroundColor3 = Theme.Green
        badge.BackgroundTransparency = 0.2
        badge.Text = "ТЕКУЩАЯ"
        badge.TextColor3 = Theme.Green
        badge.Font = Font_Bold
        badge.TextSize = 9
        badge.BorderSizePixel = 0
        badge.ZIndex = 6
        Instance.new("UICorner", badge).CornerRadius = UDim.new(1,0)
    else
        local loadBtn = Instance.new("TextButton", card)
        loadBtn.Size = UDim2.new(0,72,0,26)
        loadBtn.Position = UDim2.new(1,-84,0.5,-13)
        loadBtn.BackgroundColor3 = Theme.Accent
        loadBtn.BackgroundTransparency = 0.3
        loadBtn.Text = "ЗАГРУЗИТЬ"
        loadBtn.TextColor3 = Theme.Accent
        loadBtn.Font = Font_Bold
        loadBtn.TextSize = 9
        loadBtn.BorderSizePixel = 0
        loadBtn.AutoButtonColor = false
        loadBtn.ZIndex = 6
        Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0, 6)

        loadBtn.MouseEnter:Connect(function() TweenService:Create(loadBtn, TweenInfo.new(0.15), {BackgroundTransparency=0, TextColor3=Color3.new(1,1,1)}):Play() end)
        loadBtn.MouseLeave:Connect(function() TweenService:Create(loadBtn, TweenInfo.new(0.15), {BackgroundTransparency=0.3, TextColor3=Theme.Accent}):Play() end)
        loadBtn.MouseButton1Click:Connect(function() LoadFromUI(game) end)
    end

    card.MouseEnter:Connect(function()
        if not isCurrent then TweenService:Create(card, TweenInfo.new(0.15), {BackgroundTransparency=0}):Play(); TweenService:Create(stroke, TweenInfo.new(0.15), {Transparency=0.4}):Play() end
    end)
    card.MouseLeave:Connect(function()
        if not isCurrent then TweenService:Create(card, TweenInfo.new(0.15), {BackgroundTransparency=0.15}):Play(); TweenService:Create(stroke, TweenInfo.new(0.15), {Transparency=0.8}):Play() end
    end)

    return card
end

task.spawn(function()
    task.wait(0.3)
    local placeId = game.PlaceId
    local gameName = "Unknown"
    local ok, info = pcall(function() return MarketplaceService:GetProductInfo(placeId) end)
    if ok and info and info.Name then gameName = info.Name end
    
    local currentGame = FindGameByPlaceId(placeId)

    CurGameName.Text = gameName
    CurPlace.Text = "PlaceId: " .. tostring(placeId)

    if currentGame then
        LaunchBtn.Text = "ЗАПУСТИТЬ"
        LaunchBtn.BackgroundColor3 = Theme.Green
        LaunchBtn.MouseButton1Click:Connect(function() LoadFromUI(currentGame) end)
        Status.Text = "Игра поддерживается — жми Запустить"
        Status.TextColor3 = Theme.Green
    else
        LaunchBtn.Text = "ВРУЧНУЮ"
        LaunchBtn.BackgroundColor3 = Theme.GlassLight
        LaunchBtn.TextColor3 = Theme.TextDim
        Status.Text = "Игра не в списке — выбери вручную снизу"
        Status.TextColor3 = Theme.Red
    end

    for i, g in ipairs(SUPPORTED_GAMES) do
        MakeGameCard(g, g == currentGame, i)
    end
end)

Overlay.BackgroundTransparency = 1
Card.BackgroundTransparency = 1
CardStroke.Transparency = 1
Glow.BackgroundTransparency = 1
task.spawn(function()
    task.wait(0.05)
    TweenService:Create(Overlay, TweenInfo.new(0.3), {BackgroundTransparency=0.35}):Play()
    TweenService:Create(Card, TweenInfo.new(0.3), {BackgroundTransparency=0.02}):Play()
    TweenService:Create(CardStroke, TweenInfo.new(0.3), {Transparency=0.5}):Play()
    TweenService:Create(Glow, TweenInfo.new(0.3), {BackgroundTransparency=0.85}):Play()
end)

RunService.RenderStepped:Connect(function()
    if ScreenGui and ScreenGui.Parent then
        if UIS.MouseBehavior ~= Enum.MouseBehavior.Default then UIS.MouseBehavior = Enum.MouseBehavior.Default end
        if not UIS.MouseIconEnabled then UIS.MouseIconEnabled = true end
    end
end)
