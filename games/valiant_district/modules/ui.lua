-- =====================================================================
-- KIRO UI | Unified Menu (Beautiful Edition)
-- =====================================================================
local K = shared.KIRO
if not K then return end

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local Theme = K.Theme or {
    BG = Color3.fromRGB(10,10,16),
    Glass = Color3.fromRGB(20,20,30),
    GlassLight = Color3.fromRGB(30,30,42),
    Accent = Color3.fromRGB(90,150,255),
    Accent2 = Color3.fromRGB(170,90,240),
    Text = Color3.fromRGB(240,240,250),
    TextDim = Color3.fromRGB(130,135,155),
    Red = Color3.fromRGB(255,90,110),
    Green = Color3.fromRGB(80,220,140),
}
local Font_Main = (K.Fonts and K.Fonts.Main) or Enum.Font.GothamMedium
local Font_Bold = (K.Fonts and K.Fonts.Bold) or Enum.Font.GothamBold
local Font_Black = (K.Fonts and K.Fonts.Black) or Enum.Font.GothamBlack

-- parent gui
local parentGui = gethui and gethui() or game:GetService("CoreGui")
for _, v in pairs(parentGui:GetChildren()) do
    if v.Name == "KiroUnifiedUI" then v:Destroy() end
end

local gui = Instance.new("ScreenGui")
gui.Name = "KiroUnifiedUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.DisplayOrder = 99999
gui.Parent = parentGui
K.ScreenGui = gui

-- уведомления
local NotifyContainer = Instance.new("Frame", gui)
NotifyContainer.Size = UDim2.new(0, 320, 1, -80)
NotifyContainer.Position = UDim2.new(1, -330, 0, 50)
NotifyContainer.BackgroundTransparency = 1
NotifyContainer.ZIndex = 1000
local NL = Instance.new("UIListLayout", NotifyContainer)
NL.VerticalAlignment = Enum.VerticalAlignment.Top
NL.HorizontalAlignment = Enum.HorizontalAlignment.Right
NL.Padding = UDim.new(0, 8)

K.Notify = function(title, text, isErr)
    local n = Instance.new("Frame", NotifyContainer)
    n.Size = UDim2.new(1, 0, 0, 56)
    n.BackgroundColor3 = Theme.Glass
    n.BackgroundTransparency = 0.05
    n.BorderSizePixel = 0
    n.ZIndex = 1001
    n.ClipsDescendants = true
    Instance.new("UICorner", n).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", n)
    stroke.Color = isErr and Theme.Red or Theme.Accent
    stroke.Thickness = 1
    stroke.Transparency = 0.4
    local acc = Instance.new("Frame", n)
    acc.Size = UDim2.new(0, 3, 0.6, 0)
    acc.Position = UDim2.new(0, 8, 0.2, 0)
    acc.BackgroundColor3 = isErr and Theme.Red or Theme.Accent
    acc.BorderSizePixel = 0
    acc.ZIndex = 1002
    Instance.new("UICorner", acc).CornerRadius = UDim.new(1, 0)
    local t1 = Instance.new("TextLabel", n)
    t1.Size = UDim2.new(1, -24, 0, 18)
    t1.Position = UDim2.new(0, 16, 0, 7)
    t1.BackgroundTransparency = 1
    t1.Text = title
    t1.TextColor3 = isErr and Theme.Red or Theme.Accent
    t1.Font = Font_Bold
    t1.TextSize = 12
    t1.TextXAlignment = Enum.TextXAlignment.Left
    t1.ZIndex = 1002
    local t2 = Instance.new("TextLabel", n)
    t2.Size = UDim2.new(1, -24, 0, 26)
    t2.Position = UDim2.new(0, 16, 0, 25)
    t2.BackgroundTransparency = 1
    t2.Text = text
    t2.TextColor3 = Theme.Text
    t2.Font = Font_Main
    t2.TextSize = 11
    t2.TextWrapped = true
    t2.TextXAlignment = Enum.TextXAlignment.Left
    t2.ZIndex = 1002
    n.Position = UDim2.new(1, 0, 0, 0)
    TweenService:Create(n, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    task.delay(3.5, function()
        if n and n.Parent then
            TweenService:Create(n, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
            for _, c in ipairs(n:GetDescendants()) do
                if c:IsA("TextLabel") then TweenService:Create(c, TweenInfo.new(0.25), {TextTransparency = 1}):Play() end
            end
            task.wait(0.3)
            if n and n.Parent then n:Destroy() end
        end
    end)
end

-- главное окно
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 480, 0, 560)
main.Position = UDim2.new(0.5, -240, 0.5, -280)
main.BackgroundColor3 = Theme.BG
main.BorderSizePixel = 0
main.Active = true
main.ClipsDescendants = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

local mainGrad = Instance.new("UIGradient", main)
mainGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 14, 22)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(6, 6, 12))
}
mainGrad.Rotation = 135

local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = Theme.Accent
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.5

-- заголовок
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 44)
header.BackgroundColor3 = Theme.Glass
header.BackgroundTransparency = 0.2
header.BorderSizePixel = 0
header.Parent = main
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)

local titleLbl = Instance.new("TextLabel", header)
titleLbl.Size = UDim2.new(1, -60, 0, 44)
titleLbl.Position = UDim2.new(0, 16, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "KiroHack"
local gameLbl = Instance.new("TextLabel", header)
gameLbl.Size = UDim2.new(1, -60, 0, 14)
gameLbl.Position = UDim2.new(0, 16, 0, 26)
gameLbl.BackgroundTransparency = 1
gameLbl.Text = "Игра: " .. tostring(K.GameId or "Unknown")
gameLbl.TextColor3 = Theme.TextDim
gameLbl.Font = Font_Main
gameLbl.TextSize = 10
gameLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.TextColor3 = Theme.Accent
titleLbl.Font = Font_Black
titleLbl.TextSize = 17
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.Parent = header

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -36, 0, 7)
closeBtn.BackgroundColor3 = Theme.GlassLight
closeBtn.Text = "×"
closeBtn.TextColor3 = Theme.Red
closeBtn.Font = Font_Bold
closeBtn.TextSize = 18
closeBtn.BorderSizePixel = 0
closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function() gui.Enabled = false end)

-- drag
do
    local dragging, startPos, startInput
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; startPos = main.Position; startInput = input.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startInput
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- вкладки
local tabsBar = Instance.new("Frame")
tabsBar.Size = UDim2.new(1, -20, 0, 34)
tabsBar.Position = UDim2.new(0, 10, 0, 50)
tabsBar.BackgroundTransparency = 1
tabsBar.Parent = main
local tabLayout = Instance.new("UIListLayout", tabsBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 4)

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -20, 1, -96)
content.Position = UDim2.new(0, 10, 0, 90)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 4
content.ScrollBarImageColor3 = Theme.Accent
content.ScrollBarImageTransparency = 0.3
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.Parent = main

local pages, buttons = {}, {}
local function makeTab(name, key, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 0, 1, 0)
    btn.AutomaticSize = Enum.AutomaticSize.X
    btn.BackgroundColor3 = Theme.Glass
    btn.Text = (icon or "") .. " " .. name
    btn.Font = Font_Bold
    btn.TextSize = 11
    btn.TextColor3 = Theme.Text
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = tabsBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local pad = Instance.new("UIPadding", btn)
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)

    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 0, 0)
    page.AutomaticSize = Enum.AutomaticSize.Y
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = content
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    pages[key] = page
    buttons[key] = btn
    btn.MouseButton1Click:Connect(function()
        for k, p in pairs(pages) do p.Visible = (k == key) end
        for k, b in pairs(buttons) do
            if k == key then
                TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Accent, TextColor3 = Color3.fromRGB(20,20,20)}):Play()
            else
                TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Glass, TextColor3 = Theme.Text}):Play()
            end
        end
    end)
    return page
end

-- хелперы виджетов
local function addToggle(parent, text, path)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 32)
    btn.BackgroundColor3 = Theme.Glass
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.Text
    lbl.Font = Font_Main
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local indicator = Instance.new("Frame", btn)
    indicator.Size = UDim2.new(0, 36, 0, 18)
    indicator.Position = UDim2.new(1, -46, 0.5, -9)
    indicator.BackgroundColor3 = K.GetSetting(path) and Theme.Accent or Theme.GlassLight
    indicator.BorderSizePixel = 0
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", indicator)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = K.GetSetting(path) and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local function refresh()
        local state = K.GetSetting(path)
        TweenService:Create(indicator, TweenInfo.new(0.15), {BackgroundColor3 = state and Theme.Accent or Theme.GlassLight}):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
        lbl.TextColor3 = state and Theme.Text or Theme.TextDim
    end

    btn.MouseButton1Click:Connect(function()
        local state = not K.GetSetting(path)
        K.SetSetting(path, state)
        refresh()
    end)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.GlassLight}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Glass}):Play()
    end)

    return btn
end

local function addSlider(parent, text, min, max, path)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -4, 0, 46)
    frame.BackgroundColor3 = Theme.Glass
    frame.BorderSizePixel = 0
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, -16, 0, 18)
    lbl.Position = UDim2.new(0, 12, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. ": " .. tostring(K.GetSetting(path))
    lbl.TextColor3 = Theme.Text
    lbl.Font = Font_Main
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local track = Instance.new("Frame", frame)
    track.Size = UDim2.new(1, -24, 0, 6)
    track.Position = UDim2.new(0, 12, 0, 30)
    track.BackgroundColor3 = Theme.GlassLight
    track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new((K.GetSetting(path) - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local fillGrad = Instance.new("UIGradient", fill)
    fillGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Theme.Accent), ColorSequenceKeypoint.new(1, Theme.Accent2)}

    local dragging = false
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local v = min + (max - min) * rel
            v = math.floor(v * 100) / 100
            K.SetSetting(path, v)
            lbl.Text = text .. ": " .. tostring(v)
            fill.Size = UDim2.new(rel, 0, 1, 0)
        end
    end)

    return frame
end

local function addSection(parent, text)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = "  " .. text
    lbl.TextColor3 = Theme.Accent
    lbl.Font = Font_Bold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return lbl
end

-- ============ ВКЛАДКИ ============
local pVisual = makeTab("Визуал", "visual", "👁")
local pCombat = makeTab("Бой", "combat", "🎯")
local pMisc   = makeTab("Миск", "misc", "⚙")
local pExtra = nil
local hasExtra = K.GetSetting("Skins") or K.GetSetting("ThirdPerson") or K.GetSetting("Teleport")
if hasExtra then
    local tabName = "Доп"
    if K.GetSetting("Skins") then tabName = "CS" end
    if K.GetSetting("Teleport") then tabName = "ТП" end
    pExtra = makeTab(tabName, "extra", "✨")
end

-- Визуал
addSection(pVisual, "ESP")
addToggle(pVisual, "Включить ESP", "ESP.Enabled")
addToggle(pVisual, "Боксы", "ESP.Box")
addToggle(pVisual, "Ники", "ESP.Name")
addToggle(pVisual, "Здоровье", "ESP.Health")
addToggle(pVisual, "Дистанция", "ESP.Distance")
addToggle(pVisual, "TeamCheck", "ESP.TeamCheck")
if K.GetSetting("ESP.MaxDist") then
    addSlider(pVisual, "Макс. дистанция", 100, 5000, "ESP.MaxDist")
end

-- Бой
addSection(pCombat, "Aimbot")
addToggle(pCombat, "Включить Aimbot", "Aimbot.Enabled")
addToggle(pCombat, "FOV круг", "Aimbot.DrawFOV")
addToggle(pCombat, "Wall Check", "Aimbot.VisibleOnly")
addToggle(pCombat, "TeamCheck", "Aimbot.TeamCheck")
if K.GetSetting("Aimbot.FOV") then
    addSlider(pCombat, "FOV", 30, 500, "Aimbot.FOV")
end
if K.GetSetting("Aimbot.Smoothness") then
    addSlider(pCombat, "Плавность", 0.05, 1, "Aimbot.Smoothness")
end
addSection(pCombat, "Combat")
addToggle(pCombat, "Triggerbot", "Combat.TriggerBot")
if K.GetSetting("Combat.TriggerDelay") then
    addSlider(pCombat, "Trigger Delay", 0, 0.5, "Combat.TriggerDelay")
end

-- Миск
addSection(pMisc, "Движение")
addToggle(pMisc, "Bunnyhop", "Misc.Bunnyhop")
addToggle(pMisc, "Speed", "Misc.Speed")
addToggle(pMisc, "Fly", "Misc.Fly")
addToggle(pMisc, "Noclip", "Misc.Noclip")
addToggle(pMisc, "Infinite Jump", "Misc.InfiniteJump")
addSection(pMisc, "Визуал")
addToggle(pMisc, "Fullbright", "Misc.Fullbright")
addToggle(pMisc, "No-Flash", "Misc.NoFlash")
addSection(pMisc, "Защита")
addToggle(pMisc, "Anti-AFK", "Security.AntiAFK")

-- Доп (CS:GO / Valiant специфика)
if K.GetSetting("Skins") then
    if pExtra then addSection(pExtra, "Skins") end
    if pExtra then addToggle(pExtra, "Skin Changer", "Skins.Enabled") end
end
if K.GetSetting("ThirdPerson") then
    if pExtra then addSection(pExtra, "Third Person") end
    if pExtra then addToggle(pExtra, "Third Person", "ThirdPerson.Enabled") end
    if pExtra then addToggle(pExtra, "Char Preview", "ThirdPerson.Preview") end
end
if K.GetSetting("Teleport") then
    if pExtra then addSection(pExtra, "Teleport") end
    if pExtra then addToggle(pExtra, "Teleport to player (T)", "Teleport.Enabled") end
end

-- активируем первую вкладку
if #buttons > 0 then
    local firstKey = next(pages)
    pages[firstKey].Visible = true
    local firstBtn = buttons[firstKey]
    firstBtn.BackgroundColor3 = Theme.Accent
    firstBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
end

-- горячая клавиша F4
UIS.InputBegan:Connect(function(input, gp)
    if input.KeyCode == Enum.KeyCode.F4 then
        gui.Enabled = not gui.Enabled
        if gui.Enabled then
            UIS.MouseBehavior = Enum.MouseBehavior.Default
            UIS.MouseIconEnabled = true
        end
    end
end)

-- фикс мыши
RunService.RenderStepped:Connect(function()
    if gui.Enabled then
        if UIS.MouseBehavior ~= Enum.MouseBehavior.Default then UIS.MouseBehavior = Enum.MouseBehavior.Default end
        if not UIS.MouseIconEnabled then UIS.MouseIconEnabled = true end
    end
end)

K.Loading = false
task.delay(0.5, function()
    K.Notify("KIRO", "Загружено! F4 — меню", false)
end)
print("[KIRO UI] Меню загружено (Unified).")
