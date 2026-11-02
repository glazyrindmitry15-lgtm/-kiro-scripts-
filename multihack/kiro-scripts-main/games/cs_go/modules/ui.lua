local K = shared.KIRO
if not K then return end
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Theme = K.Theme

local parentGui = gethui and gethui() or game:GetService("CoreGui")
for _, v in pairs(parentGui:GetChildren()) do
    if v.Name == "KiroCSUI" then v:Destroy() end
end

local gui = Instance.new("ScreenGui")
gui.Name = "KiroCSUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.DisplayOrder = 99999
gui.Parent = parentGui
K.ScreenGui = gui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 420, 0, 520)
main.Position = UDim2.new(0.5, -210, 0.5, -260)
main.BackgroundColor3 = Theme.BG
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Theme.Glass
header.BorderSizePixel = 0
header.Parent = main
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 0, 40)
title.Position = UDim2.new(0, 14, 0, 0)
title.BackgroundTransparency = 1
title.Text = "KIRO • CS:GO"
title.TextColor3 = Theme.Accent
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -36, 0, 5)
close.BackgroundColor3 = Theme.GlassLight
close.Text = "×"
close.TextColor3 = Theme.Red
close.Font = Enum.Font.GothamBold
close.TextSize = 18
close.BorderSizePixel = 0
close.Parent = header
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)
close.MouseButton1Click:Connect(function() gui.Enabled = false end)

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

-- tabs
local tabsBar = Instance.new("Frame")
tabsBar.Size = UDim2.new(1, -16, 0, 34)
tabsBar.Position = UDim2.new(0, 8, 0, 46)
tabsBar.BackgroundTransparency = 1
tabsBar.Parent = main
local tabLayout = Instance.new("UIListLayout", tabsBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 4)

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -16, 1, -92)
content.Position = UDim2.new(0, 8, 0, 86)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 4
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.Parent = main

local pages, buttons = {}, {}
local function makeTab(name, key)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 90, 1, 0)
    btn.BackgroundColor3 = Theme.Glass
    btn.Text = name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.TextColor3 = Theme.Text
    btn.BorderSizePixel = 0
    btn.Parent = tabsBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

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
            b.BackgroundColor3 = (k == key) and Theme.Accent or Theme.Glass
            b.TextColor3 = (k == key) and Color3.fromRGB(20, 20, 20) or Theme.Text
        end
    end)
    return page
end

local pVisual = makeTab("Визуал", "visual")
local pCombat = makeTab("Бой", "combat")
local pMisc   = makeTab("Миск", "misc")
local pCS     = makeTab("CS", "cs")
buttons.visual.BackgroundColor3 = Theme.Accent
buttons.visual.TextColor3 = Color3.fromRGB(20, 20, 20)
pages.visual.Visible = true

local function addToggle(parent, text, path)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 30)
    btn.BackgroundColor3 = Theme.Glass
    btn.BorderSizePixel = 0
    btn.Text = "  " .. text .. ": " .. (K.GetSetting(path) and "ON" or "OFF")
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.TextColor3 = K.GetSetting(path) and Theme.Accent or Theme.Text
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function()
        local state = not K.GetSetting(path)
        K.SetSetting(path, state)
        btn.Text = "  " .. text .. ": " .. (state and "ON" or "OFF")
        btn.TextColor3 = state and Theme.Accent or Theme.Text
    end)
end

-- Visual
addToggle(pVisual, "ESP", "ESP.Enabled")
addToggle(pVisual, "Боксы", "ESP.Box")
addToggle(pVisual, "Ники", "ESP.Name")
addToggle(pVisual, "Здоровье", "ESP.Health")
addToggle(pVisual, "Дистанция", "ESP.Distance")
addToggle(pVisual, "TeamCheck", "ESP.TeamCheck")

-- Combat
addToggle(pCombat, "Aimbot", "Aimbot.Enabled")
addToggle(pCombat, "FOV круг", "Aimbot.DrawFOV")
addToggle(pCombat, "Wall Check", "Aimbot.VisibleOnly")
addToggle(pCombat, "TeamCheck", "Aimbot.TeamCheck")
addToggle(pCombat, "Triggerbot", "Combat.TriggerBot")

-- Misc
addToggle(pMisc, "Bunnyhop", "Misc.Bunnyhop")
addToggle(pMisc, "Fullbright", "Misc.Fullbright")
addToggle(pMisc, "No-Flash", "Misc.NoFlash")
addToggle(pMisc, "Anti-AFK", "Security.AntiAFK")

-- CS
addToggle(pCS, "Skin Changer", "Skins.Enabled")
addToggle(pCS, "Third Person", "ThirdPerson.Enabled")
addToggle(pCS, "Char Preview", "ThirdPerson.Preview")

-- hotkey
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == (K.GetSetting("Keybinds.Menu") or Enum.KeyCode.RightShift) then
        gui.Enabled = not gui.Enabled
        -- show cursor
        if gui.Enabled then
            UIS.MouseBehavior = Enum.MouseBehavior.Default
            UIS.MouseIconEnabled = true
        end
    end
end)

-- mouse fix loop
RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function()
    if gui.Enabled then
        if UIS.MouseBehavior ~= Enum.MouseBehavior.Default then UIS.MouseBehavior = Enum.MouseBehavior.Default end
        if not UIS.MouseIconEnabled then UIS.MouseIconEnabled = true end
    end
end)

K.Loading = false
print("[KIRO UI] Меню загружено. Клавиша: RightShift")
