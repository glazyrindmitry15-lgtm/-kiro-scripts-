-- =====================================================================
-- KIRO UI | Unified Menu (Premium Edition - 1000+ lines)
-- =====================================================================
local K = shared.KIRO
if not K then return end

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer

-- =====================================================================
-- THEME & CONFIG
-- =====================================================================
local Theme = K.Theme or {
    BG = Color3.fromRGB(8, 8, 14),
    Glass = Color3.fromRGB(18, 18, 28),
    GlassLight = Color3.fromRGB(28, 28, 40),
    Accent = Color3.fromRGB(100, 160, 255),
    Accent2 = Color3.fromRGB(180, 90, 250),
    Text = Color3.fromRGB(245, 245, 255),
    TextDim = Color3.fromRGB(130, 135, 160),
    Red = Color3.fromRGB(255, 90, 110),
    Green = Color3.fromRGB(80, 230, 150),
    Gold = Color3.fromRGB(255, 200, 80),
    Dark = Color3.fromRGB(4, 4, 10),
}
local Font_Main = (K.Fonts and K.Fonts.Main) or Enum.Font.GothamMedium
local Font_Bold = (K.Fonts and K.Fonts.Bold) or Enum.Font.GothamBold
local Font_Black = (K.Fonts and K.Fonts.Black) or Enum.Font.GothamBlack
local Font_Mono = Enum.Font.Code

-- =====================================================================
-- UTILITY FUNCTIONS
-- =====================================================================
local function gs(path)
    local v = K.GetSetting(path)
    if v == nil then return false end
    return v
end

local function ts(obj, props, time, style, dir)
    local ti = TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, ti, props)
    t:Play()
    return t
end

local function makeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function makeStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Accent
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0.5
    s.Parent = parent
    return s
end

local function makeGradient(parent, colors, rotation)
    local g = Instance.new("UIGradient")
    local keypoints = {}
    for i, c in ipairs(colors) do
        table.insert(keypoints, ColorSequenceKeypoint.new((i-1)/(#colors-1), c))
    end
    g.Color = ColorSequence.new(keypoints)
    g.Rotation = rotation or 90
    g.Parent = parent
    return g
end

local function makePadding(parent, left, right, top, bottom)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, left or 8)
    p.PaddingRight = UDim.new(0, right or 8)
    p.PaddingTop = UDim.new(0, top or 8)
    p.PaddingBottom = UDim.new(0, bottom or 8)
    p.Parent = parent
    return p
end

-- =====================================================================
-- PARENT GUI
-- =====================================================================
local parentGui = gethui and gethui() or game:GetService("CoreGui")
for _, v in pairs(parentGui:GetChildren()) do
    if v.Name == "KiroPremiumUI" then v:Destroy() end
end

-- =====================================================================
-- BLUR EFFECT
-- =====================================================================
local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting

-- =====================================================================
-- SNOW PARTICLE SYSTEM
-- =====================================================================
local snowContainer = Instance.new("Frame")
snowContainer.Size = UDim2.new(1, 0, 1, 0)
snowContainer.BackgroundTransparency = 1
snowContainer.ClipsDescendants = true
snowContainer.ZIndex = 0

local snowParticles = {}
local maxSnow = 60

local function createSnowflake()
    local flake = Instance.new("Frame")
    flake.Size = UDim2.new(0, math.random(2, 5), 0, math.random(2, 5))
    flake.Position = UDim2.new(math.random() * 0.95 + 0.025, 0, -0.05, 0)
    flake.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    flake.BackgroundTransparency = math.random(30, 70) / 100
    flake.BorderSizePixel = 0
    flake.ZIndex = 0
    makeCorner(flake, 10)
    return flake
end

-- =====================================================================
-- SCREEN GUI
-- =====================================================================
local gui = Instance.new("ScreenGui")
gui.Name = "KiroPremiumUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.DisplayOrder = 99999
gui.Parent = parentGui
K.ScreenGui = gui

snowContainer.Parent = gui

-- =====================================================================
-- NOTIFICATION SYSTEM
-- =====================================================================
local NotifyContainer = Instance.new("Frame", gui)
NotifyContainer.Size = UDim2.new(0, 340, 1, -100)
NotifyContainer.Position = UDim2.new(1, -350, 0, 60)
NotifyContainer.BackgroundTransparency = 1
NotifyContainer.ZIndex = 1000
local NL = Instance.new("UIListLayout", NotifyContainer)
NL.VerticalAlignment = Enum.VerticalAlignment.Top
NL.HorizontalAlignment = Enum.HorizontalAlignment.Right
NL.Padding = UDim.new(0, 8)

K.Notify = function(title, text, isErr, duration)
    duration = duration or 3.5
    local n = Instance.new("Frame", NotifyContainer)
    n.Size = UDim2.new(1, 0, 0, 62)
    n.BackgroundColor3 = Theme.Glass
    n.BackgroundTransparency = 0.05
    n.BorderSizePixel = 0
    n.ZIndex = 1001
    n.ClipsDescendants = true
    makeCorner(n, 12)
    local stroke = makeStroke(n, isErr and Theme.Red or Theme.Accent, 1, 0.4)

    -- accent bar
    local acc = Instance.new("Frame", n)
    acc.Size = UDim2.new(0, 4, 0.65, 0)
    acc.Position = UDim2.new(0, 10, 0.175, 0)
    acc.BackgroundColor3 = isErr and Theme.Red or Theme.Accent
    acc.BorderSizePixel = 0
    acc.ZIndex = 1002
    makeCorner(acc, 2)

    local grad = Instance.new("UIGradient", acc)
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, isErr and Theme.Red or Theme.Accent),
        ColorSequenceKeypoint.new(1, isErr and Theme.Red or Theme.Accent2)
    }
    grad.Rotation = 90

    local t1 = Instance.new("TextLabel", n)
    t1.Size = UDim2.new(1, -30, 0, 20)
    t1.Position = UDim2.new(0, 22, 0, 8)
    t1.BackgroundTransparency = 1
    t1.Text = title
    t1.TextColor3 = isErr and Theme.Red or Theme.Accent
    t1.Font = Font_Bold
    t1.TextSize = 13
    t1.TextXAlignment = Enum.TextXAlignment.Left
    t1.ZIndex = 1002

    local t2 = Instance.new("TextLabel", n)
    t2.Size = UDim2.new(1, -30, 0, 28)
    t2.Position = UDim2.new(0, 22, 0, 28)
    t2.BackgroundTransparency = 1
    t2.Text = text
    t2.TextColor3 = Theme.Text
    t2.Font = Font_Main
    t2.TextSize = 11
    t2.TextWrapped = true
    t2.TextXAlignment = Enum.TextXAlignment.Left
    t2.ZIndex = 1002

    -- progress bar
    local progBg = Instance.new("Frame", n)
    progBg.Size = UDim2.new(1, -20, 0, 2)
    progBg.Position = UDim2.new(0, 10, 1, -6)
    progBg.BackgroundColor3 = Theme.GlassLight
    progBg.BorderSizePixel = 0
    progBg.ZIndex = 1002
    makeCorner(progBg, 1)

    local progFill = Instance.new("Frame", progBg)
    progFill.Size = UDim2.new(1, 0, 1, 0)
    progFill.BackgroundColor3 = isErr and Theme.Red or Theme.Accent
    progFill.BorderSizePixel = 0
    progFill.ZIndex = 1003
    makeCorner(progFill, 1)

    n.Position = UDim2.new(1, 10, 0, 0)
    ts(n, {Position = UDim2.new(0, 0, 0, 0)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    task.delay(duration, function()
        if n and n.Parent then
            ts(n, {BackgroundTransparency = 1}, 0.25)
            for _, c in ipairs(n:GetDescendants()) do
                if c:IsA("TextLabel") then ts(c, {TextTransparency = 1}, 0.25) end
                if c:IsA("Frame") and c ~= n then ts(c, {BackgroundTransparency = 1}, 0.25) end
            end
            ts(progFill, {Size = UDim2.new(0, 0, 1, 0)}, duration, Enum.EasingStyle.Linear)
            task.wait(0.3)
            if n and n.Parent then n:Destroy() end
        end
    end)
    ts(progFill, {Size = UDim2.new(0, 0, 1, 0)}, duration, Enum.EasingStyle.Linear)
end

-- =====================================================================
-- MAIN WINDOW
-- =====================================================================
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 520, 0, 620)
main.Position = UDim2.new(0.5, -260, 0.5, -310)
main.BackgroundColor3 = Theme.BG
main.BorderSizePixel = 0
main.Active = true
main.ClipsDescendants = true
main.Parent = gui
makeCorner(main, 16)

local mainGrad = Instance.new("UIGradient", main)
mainGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 12, 20)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(8, 8, 16)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 4, 10))
}
mainGrad.Rotation = 135

local mainStroke = makeStroke(main, Theme.Accent, 1.5, 0.4)

-- shadow
local shadow = Instance.new("ImageLabel", main)
shadow.Size = UDim2.new(1, 40, 1, 40)
shadow.Position = UDim2.new(0, -20, 0, -20)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://6014261993"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.5
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(49, 49, 450, 450)
shadow.ZIndex = -1

-- =====================================================================
-- HEADER
-- =====================================================================
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 52)
header.BackgroundColor3 = Theme.Glass
header.BackgroundTransparency = 0.1
header.BorderSizePixel = 0
header.Parent = main
makeCorner(header, 16)

-- bottom corners square
local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 16)
headerFix.Position = UDim2.new(0, 0, 1, -16)
headerFix.BackgroundColor3 = Theme.Glass
headerFix.BackgroundTransparency = 0.1
headerFix.BorderSizePixel = 0
headerFix.Parent = header

local headerGrad = Instance.new("UIGradient", header)
headerGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
}
headerGrad.Rotation = 90

-- logo
local logoFrame = Instance.new("Frame", header)
logoFrame.Size = UDim2.new(0, 36, 0, 36)
logoFrame.Position = UDim2.new(0, 14, 0.5, -18)
logoFrame.BackgroundColor3 = Theme.Accent
logoFrame.BorderSizePixel = 0
makeCorner(logoFrame, 10)

local logoGrad = Instance.new("UIGradient", logoFrame)
logoGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Theme.Accent),
    ColorSequenceKeypoint.new(0.5, Theme.Accent2),
    ColorSequenceKeypoint.new(1, Theme.Accent)
}

local logoText = Instance.new("TextLabel", logoFrame)
logoText.Size = UDim2.new(1, 0, 1, 0)
logoText.BackgroundTransparency = 1
logoText.Text = "K"
logoText.TextColor3 = Color3.fromRGB(255, 255, 255)
logoText.Font = Font_Black
logoText.TextSize = 20

-- animated logo gradient
task.spawn(function()
    while logoFrame and logoFrame.Parent do
        logoGrad.Rotation = (logoGrad.Rotation + 2) % 360
        task.wait(0.03)
    end
end)

local titleLbl = Instance.new("TextLabel", header)
titleLbl.Size = UDim2.new(0, 200, 0, 26)
titleLbl.Position = UDim2.new(0, 58, 0, 6)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "KiroHack"
titleLbl.TextColor3 = Theme.Accent
titleLbl.Font = Font_Black
titleLbl.TextSize = 20
titleLbl.TextXAlignment = Enum.TextXAlignment.Left

local gameLbl = Instance.new("TextLabel", header)
gameLbl.Size = UDim2.new(0, 200, 0, 14)
gameLbl.Position = UDim2.new(0, 58, 0, 30)
gameLbl.BackgroundTransparency = 1
gameLbl.Text = "Игра: " .. tostring(K.GameId or "Unknown")
gameLbl.TextColor3 = Theme.TextDim
gameLbl.Font = Font_Main
gameLbl.TextSize = 10
gameLbl.TextXAlignment = Enum.TextXAlignment.Left

-- window controls
local controlsFrame = Instance.new("Frame", header)
controlsFrame.Size = UDim2.new(0, 70, 0, 24)
controlsFrame.Position = UDim2.new(1, -78, 0.5, -12)
controlsFrame.BackgroundTransparency = 1

local minimizeBtn = Instance.new("TextButton", controlsFrame)
minimizeBtn.Size = UDim2.new(0, 24, 0, 24)
minimizeBtn.Position = UDim2.new(0, 0, 0, 0)
minimizeBtn.BackgroundColor3 = Theme.GlassLight
minimizeBtn.Text = "─"
minimizeBtn.TextColor3 = Theme.Text
minimizeBtn.Font = Font_Bold
minimizeBtn.TextSize = 12
minimizeBtn.BorderSizePixel = 0
minimizeBtn.AutoButtonColor = false
makeCorner(minimizeBtn, 6)

local closeBtn = Instance.new("TextButton", controlsFrame)
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(0, 36, 0, 0)
closeBtn.BackgroundColor3 = Theme.GlassLight
closeBtn.Text = "✕"
closeBtn.TextColor3 = Theme.Red
closeBtn.Font = Font_Bold
closeBtn.TextSize = 12
closeBtn.BorderSizePixel = 0
closeBtn.AutoButtonColor = false
makeCorner(closeBtn, 6)

closeBtn.MouseButton1Click:Connect(function() gui.Enabled = false end)

local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        ts(main, {Size = UDim2.new(0, 520, 0, 52)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    else
        ts(main, {Size = UDim2.new(0, 520, 0, 620)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end
end)

-- drag with inertia
do
    local dragging = false
    local startPos, startInput
    local velocity = Vector2.new(0, 0)
    local lastPos = Vector2.new(0, 0)
    local lastTime = tick()

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startPos = main.Position
            startInput = input.Position
            lastPos = input.Position
            lastTime = tick()
            velocity = Vector2.new(0, 0)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local now = tick()
            local dt = now - lastTime
            if dt > 0 then
                velocity = (input.Position - lastPos) / dt
            end
            lastPos = input.Position
            lastTime = now
            local delta = input.Position - startInput
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
            dragging = false
            -- inertia
            task.spawn(function()
                local pos = main.Position
                local vel = velocity * 0.15
                for i = 1, 15 do
                    if dragging then break end
                    vel = vel * 0.85
                    pos = UDim2.new(pos.X.Scale, pos.X.Offset + vel.X, pos.Y.Scale, pos.Y.Offset + vel.Y)
                    main.Position = pos
                    task.wait(0.016)
                end
            end)
        end
    end)
end

-- =====================================================================
-- TABS
-- =====================================================================
local tabsBar = Instance.new("Frame")
tabsBar.Size = UDim2.new(1, -24, 0, 36)
tabsBar.Position = UDim2.new(0, 12, 0, 58)
tabsBar.BackgroundTransparency = 1
tabsBar.Parent = main

local tabLayout = Instance.new("UIListLayout", tabsBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 6)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -24, 1, -106)
content.Position = UDim2.new(0, 12, 0, 100)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 4
content.ScrollBarImageColor3 = Theme.Accent
content.ScrollBarImageTransparency = 0.3
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.Parent = main

local pages = {}
local buttons = {}
local tabOrder = 0

local function makeTab(name, key, icon)
    tabOrder = tabOrder + 1
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 0, 1, 0)
    btn.AutomaticSize = Enum.AutomaticSize.X
    btn.BackgroundColor3 = Theme.Glass
    btn.BackgroundTransparency = 0.3
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.LayoutOrder = tabOrder
    btn.Parent = tabsBar
    makeCorner(btn, 8)

    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = (icon or "") .. "  " .. name
    lbl.TextColor3 = Theme.TextDim
    lbl.Font = Font_Bold
    lbl.TextSize = 11
    makePadding(lbl, 12, 12, 0, 0)

    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 0, 0)
    page.AutomaticSize = Enum.AutomaticSize.Y
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = content

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    pages[key] = page
    buttons[key] = {btn = btn, lbl = lbl}

    btn.MouseButton1Click:Connect(function()
        for k, p in pairs(pages) do
            if k == key then
                p.Visible = true
                ts(p, {BackgroundTransparency = 0}, 0.15)
            else
                p.Visible = false
            end
        end
        for k, data in pairs(buttons) do
            if k == key then
                ts(data.btn, {BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0}, 0.2)
                ts(data.lbl, {TextColor3 = Color3.fromRGB(20, 20, 25)}, 0.2)
            else
                ts(data.btn, {BackgroundColor3 = Theme.Glass, BackgroundTransparency = 0.3}, 0.2)
                ts(data.lbl, {TextColor3 = Theme.TextDim}, 0.2)
            end
        end
    end)

    btn.MouseEnter:Connect(function()
        if not pages[key].Visible then
            ts(btn, {BackgroundTransparency = 0.1}, 0.15)
        end
    end)
    btn.MouseLeave:Connect(function()
        if not pages[key].Visible then
            ts(btn, {BackgroundTransparency = 0.3}, 0.15)
        end
    end)

    return page
end

-- =====================================================================
-- WIDGET HELPERS
-- =====================================================================
local function addSection(parent, text)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 24)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local line = Instance.new("Frame", frame)
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0.5, 0)
    line.BackgroundColor3 = Theme.GlassLight
    line.BorderSizePixel = 0

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0, 0, 1, 0)
    lbl.AutomaticSize = Enum.AutomaticSize.X
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundColor3 = Theme.BG
    lbl.Text = "  " .. text .. "  "
    lbl.TextColor3 = Theme.Accent
    lbl.Font = Font_Bold
    lbl.TextSize = 11
    lbl.ZIndex = 2
    makePadding(lbl, 8, 8, 0, 0)

    return frame
end

local function addToggle(parent, text, path, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 36)
    btn.BackgroundColor3 = Theme.Glass
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = parent
    makeCorner(btn, 8)

    local iconLbl = Instance.new("TextLabel", btn)
    iconLbl.Size = UDim2.new(0, 24, 1, 0)
    iconLbl.Position = UDim2.new(0, 8, 0, 0)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text = icon or "●"
    iconLbl.TextColor3 = Theme.TextDim
    iconLbl.Font = Font_Main
    iconLbl.TextSize = 14

    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, -80, 1, 0)
    lbl.Position = UDim2.new(0, 36, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.Text
    lbl.Font = Font_Main
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local sw = Instance.new("Frame", btn)
    sw.Size = UDim2.new(0, 40, 0, 20)
    sw.Position = UDim2.new(1, -48, 0.5, -10)
    sw.BackgroundColor3 = gs(path) and Theme.Accent or Theme.GlassLight
    sw.BorderSizePixel = 0
    makeCorner(sw, 10)

    local swGrad = Instance.new("UIGradient", sw)
    swGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, gs(path) and Theme.Accent or Theme.GlassLight),
        ColorSequenceKeypoint.new(1, gs(path) and Theme.Accent2 or Theme.GlassLight)
    }
    swGrad.Rotation = 90

    local knob = Instance.new("Frame", sw)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = gs(path) and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    makeCorner(knob, 8)

    local knobShadow = Instance.new("ImageLabel", knob)
    knobShadow.Size = UDim2.new(1, 8, 1, 8)
    knobShadow.Position = UDim2.new(0, -4, 0, -4)
    knobShadow.BackgroundTransparency = 1
    knobShadow.Image = "rbxassetid://6014261993"
    knobShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    knobShadow.ImageTransparency = 0.7
    knobShadow.ScaleType = Enum.ScaleType.Slice
    knobShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    knobShadow.ZIndex = -1

    local function refresh()
        local st = gs(path)
        ts(sw, {BackgroundColor3 = st and Theme.Accent or Theme.GlassLight}, 0.2)
        ts(knob, {Position = st and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.2)
        ts(lbl, {TextColor3 = st and Theme.Text or Theme.TextDim}, 0.2)
        ts(iconLbl, {TextColor3 = st and Theme.Accent or Theme.TextDim}, 0.2)
        swGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, st and Theme.Accent or Theme.GlassLight),
            ColorSequenceKeypoint.new(1, st and Theme.Accent2 or Theme.GlassLight)
        }
    end

    btn.MouseButton1Click:Connect(function()
        local st = not gs(path)
        K.SetSetting(path, st)
        refresh()
        -- pulse animation
        ts(btn, {Size = UDim2.new(1, -4, 0, 38)}, 0.08)
        task.delay(0.08, function()
            ts(btn, {Size = UDim2.new(1, -4, 0, 36)}, 0.08)
        end)
    end)

    btn.MouseEnter:Connect(function()
        ts(btn, {BackgroundTransparency = 0.05}, 0.15)
    end)
    btn.MouseLeave:Connect(function()
        ts(btn, {BackgroundTransparency = 0.2}, 0.15)
    end)

    return btn
end

local function addSlider(parent, text, min, max, path, suffix)
    suffix = suffix or ""
    local cur = K.GetSetting(path)
    if cur == nil then return end
    cur = tonumber(cur) or min

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -4, 0, 52)
    frame.BackgroundColor3 = Theme.Glass
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = parent
    makeCorner(frame, 8)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, -16, 0, 18)
    lbl.Position = UDim2.new(0, 10, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.Text
    lbl.Font = Font_Main
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local valLbl = Instance.new("TextLabel", frame)
    valLbl.Size = UDim2.new(0, 60, 0, 18)
    valLbl.Position = UDim2.new(1, -68, 0, 6)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(cur) .. suffix
    valLbl.TextColor3 = Theme.Accent
    valLbl.Font = Font_Bold
    valLbl.TextSize = 12
    valLbl.TextXAlignment = Enum.TextXAlignment.Right

    local track = Instance.new("Frame", frame)
    track.Size = UDim2.new(1, -20, 0, 6)
    track.Position = UDim2.new(0, 10, 0, 34)
    track.BackgroundColor3 = Theme.GlassLight
    track.BorderSizePixel = 0
    makeCorner(track, 3)

    local fill = Instance.new("Frame", track)
    local rel = math.clamp((cur - min) / (max - min), 0, 1)
    fill.Size = UDim2.new(rel, 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    makeCorner(fill, 3)

    local fillGrad = Instance.new("UIGradient", fill)
    fillGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(1, Theme.Accent2)
    }

    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new(rel, -6, 0.5, -6)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 2
    makeCorner(knob, 6)

    local dragging = false
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local r = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local v = min + (max - min) * r
            v = math.floor(v * 100) / 100
            K.SetSetting(path, v)
            valLbl.Text = tostring(v) .. suffix
            fill.Size = UDim2.new(r, 0, 1, 0)
            knob.Position = UDim2.new(r, -6, 0.5, -6)
        end
    end)

    frame.MouseEnter:Connect(function()
        ts(frame, {BackgroundTransparency = 0.05}, 0.15)
    end)
    frame.MouseLeave:Connect(function()
        ts(frame, {BackgroundTransparency = 0.2}, 0.15)
    end)

    return frame
end

local function addDropdown(parent, text, options, path)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -4, 0, 32)
    frame.BackgroundColor3 = Theme.Glass
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = parent
    makeCorner(frame, 8)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, -40, 0, 32)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. ": " .. tostring(K.GetSetting(path))
    lbl.TextColor3 = Theme.Text
    lbl.Font = Font_Main
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local arrow = Instance.new("TextLabel", frame)
    arrow.Size = UDim2.new(0, 24, 0, 32)
    arrow.Position = UDim2.new(1, -30, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Theme.TextDim
    arrow.Font = Font_Main
    arrow.TextSize = 10

    local expanded = false
    local optionFrames = {}

    local function collapse()
        expanded = false
        ts(frame, {Size = UDim2.new(1, -4, 0, 32)}, 0.2)
        ts(arrow, {Rotation = 0}, 0.2)
    end

    local function expand()
        expanded = true
        local h = 32 + #options * 28
        ts(frame, {Size = UDim2.new(1, -4, 0, h)}, 0.2)
        ts(arrow, {Rotation = 180}, 0.2)
    end

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 2
    btn.Parent = frame

    btn.MouseButton1Click:Connect(function()
        if expanded then collapse() else expand() end
    end)

    for i, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton", frame)
        optBtn.Size = UDim2.new(1, -8, 0, 26)
        optBtn.Position = UDim2.new(0, 4, 0, 30 + (i-1)*28)
        optBtn.BackgroundColor3 = Theme.GlassLight
        optBtn.BackgroundTransparency = 0.3
        optBtn.Text = "  " .. tostring(opt)
        optBtn.TextColor3 = Theme.Text
        optBtn.Font = Font_Main
        optBtn.TextSize = 11
        optBtn.TextXAlignment = Enum.TextXAlignment.Left
        optBtn.BorderSizePixel = 0
        optBtn.ZIndex = 3
        makeCorner(optBtn, 4)

        optBtn.MouseButton1Click:Connect(function()
            K.SetSetting(path, opt)
            lbl.Text = text .. ": " .. tostring(opt)
            collapse()
        end)
        optBtn.MouseEnter:Connect(function()
            ts(optBtn, {BackgroundTransparency = 0}, 0.1)
        end)
        optBtn.MouseLeave:Connect(function()
            ts(optBtn, {BackgroundTransparency = 0.3}, 0.1)
        end)
    end

    return frame
end

local function addKeybind(parent, text, path)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -4, 0, 32)
    frame.BackgroundColor3 = Theme.Glass
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = parent
    makeCorner(frame, 8)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, -80, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.Text
    lbl.Font = Font_Main
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local keyBtn = Instance.new("TextButton", frame)
    keyBtn.Size = UDim2.new(0, 60, 0, 22)
    keyBtn.Position = UDim2.new(1, -68, 0.5, -11)
    keyBtn.BackgroundColor3 = Theme.GlassLight
    keyBtn.Text = tostring(K.GetSetting(path))
    keyBtn.TextColor3 = Theme.Accent
    keyBtn.Font = Font_Bold
    keyBtn.TextSize = 10
    keyBtn.BorderSizePixel = 0
    makeCorner(keyBtn, 4)

    local listening = false
    keyBtn.MouseButton1Click:Connect(function()
        listening = true
        keyBtn.Text = "..."
        local conn
        conn = UIS.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                K.SetSetting(path, input.KeyCode)
                keyBtn.Text = tostring(input.KeyCode)
                listening = false
                conn:Disconnect()
            end
        end)
        task.delay(5, function()
            if listening then
                listening = false
                keyBtn.Text = tostring(K.GetSetting(path))
                conn:Disconnect()
            end
        end)
    end)

    return frame
end

local function addSection(parent, text)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 22)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local line = Instance.new("Frame", frame)
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0.5, 0)
    line.BackgroundColor3 = Theme.GlassLight
    line.BorderSizePixel = 0

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0, 0, 1, 0)
    lbl.AutomaticSize = Enum.AutomaticSize.X
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundColor3 = Theme.BG
    lbl.Text = "  " .. text .. "  "
    lbl.TextColor3 = Theme.Accent
    lbl.Font = Font_Bold
    lbl.TextSize = 11
    lbl.ZIndex = 2
    makePadding(lbl, 6, 6, 0, 0)

    return frame
end

-- =====================================================================
-- TABS
-- =====================================================================
local tabsBar = Instance.new("Frame")
tabsBar.Size = UDim2.new(1, -24, 0, 38)
tabsBar.Position = UDim2.new(0, 12, 0, 56)
tabsBar.BackgroundTransparency = 1
tabsBar.Parent = main

local tabLayout = Instance.new("UIListLayout", tabsBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 6)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -24, 1, -108)
content.Position = UDim2.new(0, 12, 0, 100)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 4
content.ScrollBarImageColor3 = Theme.Accent
content.ScrollBarImageTransparency = 0.3
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.Parent = main

local pages = {}
local buttons = {}
local tabOrder = 0

local function makeTab(name, key, icon)
    tabOrder = tabOrder + 1
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 0, 1, 0)
    btn.AutomaticSize = Enum.AutomaticSize.X
    btn.BackgroundColor3 = Theme.Glass
    btn.BackgroundTransparency = 0.3
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.LayoutOrder = tabOrder
    btn.Parent = tabsBar
    makeCorner(btn, 8)

    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = (icon or "") .. "  " .. name
    lbl.TextColor3 = Theme.TextDim
    lbl.Font = Font_Bold
    lbl.TextSize = 11
    makePadding(lbl, 12, 12, 0, 0)

    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 0, 0)
    page.AutomaticSize = Enum.AutomaticSize.Y
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = content

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    pages[key] = page
    buttons[key] = {btn = btn, lbl = lbl}

    btn.MouseButton1Click:Connect(function()
        for k, p in pairs(pages) do
            if k == key then
                p.Visible = true
            else
                p.Visible = false
            end
        end
        for k, data in pairs(buttons) do
            if k == key then
                ts(data.btn, {BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0}, 0.2)
                ts(data.lbl, {TextColor3 = Color3.fromRGB(20, 20, 25)}, 0.2)
            else
                ts(data.btn, {BackgroundColor3 = Theme.Glass, BackgroundTransparency = 0.3}, 0.2)
                ts(data.lbl, {TextColor3 = Theme.TextDim}, 0.2)
            end
        end
    end)

    btn.MouseEnter:Connect(function()
        if not pages[key].Visible then
            ts(btn, {BackgroundTransparency = 0.1}, 0.15)
        end
    end)
    btn.MouseLeave:Connect(function()
        if not pages[key].Visible then
            ts(btn, {BackgroundTransparency = 0.3}, 0.15)
        end
    end)

    return page
end

-- =====================================================================
-- PAGE CONTENT
-- =====================================================================
local pVisual = makeTab("Visual", "visual", "👁")
local pCombat = makeTab("Combat", "combat", "🎯")
local pMisc = makeTab("Misc", "misc", "⚙")
local pSecurity = makeTab("Security", "security", "🛡")

local hasExtra = K.GetSetting("Skins") or K.GetSetting("ThirdPerson") or K.GetSetting("Teleport")
local pExtra = nil
if hasExtra then
    local tabName = "Extra"
    if K.GetSetting("Skins") then tabName = "Skins" end
    if K.GetSetting("Teleport") then tabName = "TP" end
    pExtra = makeTab(tabName, "extra", "✨")
end

-- Visual tab
addSection(pVisual, "ESP")
addToggle(pVisual, "ESP Enabled", "ESP.Enabled", "👁")
addToggle(pVisual, "Boxes", "ESP.Box", "⬜")
addToggle(pVisual, "Names", "ESP.Name", "📝")
addToggle(pVisual, "Health", "ESP.Health", "❤")
addToggle(pVisual, "Distance", "ESP.Distance", "📏")
addToggle(pVisual, "Weapon", "ESP.Weapon", "🔫")
addToggle(pVisual, "Skeleton", "ESP.Skeleton", "💀")
addToggle(pVisual, "Highlight", "ESP.Highlight", "✨")
addToggle(pVisual, "TeamCheck", "ESP.TeamCheck", "👥")
addSlider(pVisual, "Max Distance", 100, 5000, "ESP.MaxDist", "m")

-- Combat tab
addSection(pCombat, "Aimbot")
addToggle(pCombat, "Aimbot Enabled", "Aimbot.Enabled", "🎯")
addToggle(pCombat, "Draw FOV", "Aimbot.DrawFOV", "⭕")
addToggle(pCombat, "Silent Aim", "Aimbot.SilentAim", "🤫")
addToggle(pCombat, "Wall Check", "Aimbot.VisibleOnly", "🧱")
addToggle(pCombat, "TeamCheck", "Aimbot.TeamCheck", "👥")
addToggle(pCombat, "Snap Aim", "Aimbot.SnapAim", "⚡")
addToggle(pCombat, "Humanize", "Aimbot.Humanize", "🤖")
addSlider(pCombat, "FOV", 30, 500, "Aimbot.FOV", "px")
addSlider(pCombat, "Smoothness", 0.05, 1, "Aimbot.Smoothness", "")
addSlider(pCombat, "Jitter", 0, 2, "Aimbot.Jitter", "°")
addSlider(pCombat, "Max Distance", 100, 2000, "Aimbot.MaxDistance", "m")
addSection(pCombat, "Combat")
addToggle(pCombat, "Triggerbot", "Combat.TriggerBot", "🔫")
addToggle(pCombat, "No Recoil", "Combat.NoRecoil", "📉")
addToggle(pCombat, "No Spread", "Combat.NoSpread", "🎯")
addToggle(pCombat, "Proj Magnet", "Combat.ProjMagnet", "🧲")
addSlider(pCombat, "Trigger Delay", 0, 0.5, "Combat.TriggerDelay", "s")
addDropdown(pCombat, "Aim Mode", {"Hold", "Toggle", "Always"}, "Aimbot.AimMode")
addDropdown(pCombat, "Smooth Curve", {"Linear", "SmoothStep", "EaseIn", "EaseOut"}, "Aimbot.SmoothCurve")
addKeybind(pCombat, "Aimbot Key", "Aimbot.Key")

-- Misc tab
addSection(pMisc, "Movement")
addToggle(pMisc, "Bunnyhop", "Misc.Bunnyhop", "🐰")
addToggle(pMisc, "Speed", "Misc.Speed", "🏃")
addToggle(pMisc, "Fly", "Misc.Fly", "✈")
addToggle(pMisc, "Noclip", "Misc.Noclip", "👻")
addToggle(pMisc, "Infinite Jump", "Misc.InfiniteJump", "⬆")
addSlider(pMisc, "Speed Value", 16, 200, "Misc.SpeedValue", "")
addSlider(pMisc, "Fly Speed", 10, 200, "Misc.FlySpeed", "")
addSection(pMisc, "Visual")
addToggle(pMisc, "Fullbright", "Misc.Fullbright", "☀")
addToggle(pMisc, "No-Flash", "Misc.NoFlash", "🚫")
addToggle(pMisc, "Custom Crosshair", "VisualExtras.CustomCrosshair", "➕")
addSection(pMisc, "Utility")
addToggle(pMisc, "Auto Equip", "Utils.AutoEquip", "🎒")
addToggle(pMisc, "Auto Collect", "Utils.AutoCollect", "📦")
addToggle(pMisc, "Head Expander", "Utils.HeadExpander", " inflated")
addSlider(pMisc, "Head Size", 1, 10, "Utils.HeadSize", "x")

-- Security tab
addSection(pSecurity, "Anti-Cheat")
addToggle(pSecurity, "Staff Detect", "Security.StaffDetect", "👮")
addToggle(pSecurity, "Observer Alert", "Security.ObserverAlert", "👁")
addToggle(pSecurity, "Anti-AFK", "Security.AntiAFK", "⏰")
addToggle(pSecurity, "Anti-Dump", "Security.AntiDump", "🔒")
addSection(pSecurity, "World")
addToggle(pSecurity, "No Fog", "World.NoFog", "🌫")
addToggle(pSecurity, "Remove Grass", "World.RemoveGrass", "🌿")
addToggle(pSecurity, "Performance Mode", "World.PerformanceMode", "⚡")
addSection(pSecurity, "Camera")
addSlider(pSecurity, "Default FOV", 50, 120, "Camera.DefaultFOV", "°")
addSlider(pSecurity, "Zoom FOV", 10, 120, "Camera.ZoomFOV", "°")
addKeybind(pSecurity, "Zoom Key", "Camera.ZoomKey")
addKeybind(pSecurity, "Panic Key", "Keybinds.Panic")

-- Extra tab
if pExtra then
    if K.GetSetting("Skins") then
        addSection(pExtra, "Skins")
        addToggle(pExtra, "Skin Changer", "Skins.Enabled", "🎨")
        addDropdown(pExtra, "Skin", {"Default", "Gold", "Neon", "Dark", "Red"}, "Skins.Skin")
    end
    if K.GetSetting("ThirdPerson") then
        addSection(pExtra, "Third Person")
        addToggle(pExtra, "Third Person", "ThirdPerson.Enabled", "📷")
        addToggle(pExtra, "Char Preview", "ThirdPerson.Preview", "🖼")
        addSlider(pExtra, "Distance", 3, 20, "ThirdPerson.Distance", "m")
    end
    if K.GetSetting("Teleport") then
        addSection(pExtra, "Teleport")
        addToggle(pExtra, "Teleport (T)", "Teleport.Enabled", "📍")
    end
    if K.GetSetting("MapHack") then
        addSection(pExtra, "MapHack")
        addToggle(pExtra, "MapHack", "MapHack.Enabled", "🗺")
        addSlider(pExtra, "Max Dist", 100, 2000, "MapHack.MaxDist", "m")
    end
    if K.GetSetting("Fun") then
        addSection(pExtra, "Fun")
        addToggle(pExtra, "Hitmarker", "Fun.Hitmarker", "💥")
        addToggle(pExtra, "Kill Messages", "Fun.KillMessages", "💬")
    end
end

-- activate first tab
local firstKey = next(pages)
if firstKey then
    pages[firstKey].Visible = true
    buttons[firstKey].btn.BackgroundColor3 = Theme.Accent
    buttons[firstKey].btn.BackgroundTransparency = 0
    buttons[firstKey].lbl.TextColor3 = Color3.fromRGB(20, 20, 25)
end

-- =====================================================================
-- STATUS BAR
-- =====================================================================
local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1, -24, 0, 24)
statusBar.Position = UDim2.new(0, 12, 1, -30)
statusBar.BackgroundColor3 = Theme.Glass
statusBar.BackgroundTransparency = 0.2
statusBar.BorderSizePixel = 0
statusBar.Parent = main
makeCorner(statusBar, 6)

local fpsLbl = Instance.new("TextLabel", statusBar)
fpsLbl.Size = UDim2.new(0, 80, 1, 0)
fpsLbl.Position = UDim2.new(0, 8, 0, 0)
fpsLbl.BackgroundTransparency = 1
fpsLbl.Text = "FPS: 0"
fpsLbl.TextColor3 = Theme.Green
fpsLbl.Font = Font_Mono
fpsLbl.TextSize = 10
fpsLbl.TextXAlignment = Enum.TextXAlignment.Left

local statusLbl = Instance.new("TextLabel", statusBar)
statusLbl.Size = UDim2.new(1, -100, 1, 0)
statusLbl.Position = UDim2.new(0, 90, 0, 0)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "KiroHack loaded. F4 - toggle menu"
statusLbl.TextColor3 = Theme.TextDim
statusLbl.Font = Font_Main
statusLbl.TextSize = 10
statusLbl.TextXAlignment = Enum.TextXAlignment.Left

-- FPS counter
local fpsCount = 0
local lastFpsUpdate = tick()
RunService.RenderStepped:Connect(function()
    fpsCount = fpsCount + 1
    if tick() - lastFpsUpdate >= 1 then
        fpsLbl.Text = "FPS: " .. fpsCount
        fpsCount = 0
        lastFpsUpdate = tick()
    end
end)

-- =====================================================================
-- HOTKEYS
-- =====================================================================
UIS.InputBegan:Connect(function(input, gp)
    if input.KeyCode == Enum.KeyCode.F4 then
        gui.Enabled = not gui.Enabled
        if gui.Enabled then
            UIS.MouseBehavior = Enum.MouseBehavior.Default
            UIS.MouseIconEnabled = true
            ts(main, {Size = UDim2.new(0, 520, 0, 620)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else
            ts(main, {Size = UDim2.new(0, 520, 0, 52)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        end
    end
    if input.KeyCode == Enum.KeyCode.Insert then
        gui.Enabled = not gui.Enabled
    end
end)

-- =====================================================================
-- MOUSE FIX
-- =====================================================================
RunService.RenderStepped:Connect(function()
    if gui.Enabled then
        if UIS.MouseBehavior ~= Enum.MouseBehavior.Default then UIS.MouseBehavior = Enum.MouseBehavior.Default end
        if not UIS.MouseIconEnabled then UIS.MouseIconEnabled = true end
    end
end)

-- =====================================================================
-- SNOW PARTICLES
-- =====================================================================
snowContainer.Parent = gui
snowContainer.ZIndex = 0

task.spawn(function()
    while gui and gui.Parent do
        if #snowParticles < maxSnow then
            local flake = createSnowflake()
            flake.Parent = snowContainer
            table.insert(snowParticles, flake)
        end
        for i = #snowParticles, 1, -1 do
            local flake = snowParticles[i]
            if flake and flake.Parent then
                local pos = flake.Position
                local newX = pos.X.Scale + (math.random(-1, 1) * 0.001)
                local newY = pos.Y.Scale + 0.002 + math.random() * 0.001
                if newY > 1.05 then
                    flake.Position = UDim2.new(math.random() * 0.95 + 0.025, 0, -0.05, 0)
                else
                    flake.Position = UDim2.new(newX, 0, newY, 0)
                end
                flake.Rotation = flake.Rotation + math.random(-2, 2)
            else
                table.remove(snowParticles, i)
            end
        end
        task.wait(0.03)
    end
end)

-- =====================================================================
-- BLUR
-- =====================================================================
task.spawn(function()
    while gui and gui.Parent do
        if gui.Enabled then
            if blur.Size < 12 then blur.Size = blur.Size + 1 end
        else
            if blur.Size > 0 then blur.Size = blur.Size - 1 end
        end
        task.wait(0.03)
    end
end)

-- =====================================================================
-- FINALIZE
-- =====================================================================
K.Loading = false
task.delay(0.6, function()
    if K.Notify then K.Notify("KiroHack", "Loaded successfully! F4 - menu, Insert - toggle", false) end
end)
print("[KIRO UI] Premium menu loaded. Lines: 1000+")
