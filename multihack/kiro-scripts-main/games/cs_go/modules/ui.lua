local K = shared.KIRO
if not K then return end
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "KIRO_CS_UI"; gui.ResetOnSpawn = false; gui.Parent = LP:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 460, 0, 340); main.Position = UDim2.new(0.5, -230, 0.5, -170)
main.BackgroundColor3 = K.Theme.BG; main.Active = true; main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0,8)

local header = Instance.new("Frame")
header.Size = UDim2.new(1,0,0,36); header.BackgroundColor3 = K.Theme.Glass; header.BorderSizePixel = 0; header.Parent = main
Instance.new("UICorner", header).CornerRadius = UDim.new(0,8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-40,0,36); title.Position = UDim2.new(0,12,0,0); title.BackgroundTransparency = 1
title.Text = "KIRO • CS:GO"; title.Font = Enum.Font.GothamBold; title.TextSize = 15
title.TextColor3 = K.Theme.Accent; title.TextXAlignment = Enum.TextXAlignment.Left; title.Parent = header

local close = Instance.new("TextButton")
close.Size = UDim2.new(0,28,0,28); close.Position = UDim2.new(1,-34,0,4)
close.BackgroundColor3 = K.Theme.GlassLight; close.Text = "×"; close.Font = Enum.Font.GothamBold
close.TextSize = 18; close.TextColor3 = Color3.fromRGB(255,255,255); close.BorderSizePixel = 0; close.Parent = header
Instance.new("UICorner", close).CornerRadius = UDim.new(0,4)
close.MouseButton1Click:Connect(function() gui.Enabled = false end)

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

local tabsBar = Instance.new("Frame")
tabsBar.Size = UDim2.new(1,-16,0,32); tabsBar.Position = UDim2.new(0,8,0,44)
tabsBar.BackgroundTransparency = 1; tabsBar.Parent = main
local tabLayout = Instance.new("UIListLayout", tabsBar); tabLayout.FillDirection = Enum.FillDirection.Horizontal; tabLayout.Padding = UDim.new(0,4)

local content = Instance.new("Frame")
content.Size = UDim2.new(1,-16,1,-86); content.Position = UDim2.new(0,8,0,80)
content.BackgroundTransparency = 1; content.Parent = main

local pages, buttons = {}, {}
local function makeTab(name, key)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,100,1,0); btn.BackgroundColor3 = K.Theme.Glass; btn.Text = name
    btn.Font = Enum.Font.Gotham; btn.TextSize = 13; btn.TextColor3 = K.Theme.TextColor; btn.BorderSizePixel = 0; btn.Parent = tabsBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,4)

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1,0,1,0); page.BackgroundTransparency = 1; page.BorderSizePixel = 0
    page.ScrollBarThickness = 3; page.CanvasSize = UDim2.new(0,0,0,0); page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false; page.Parent = content
    local layout = Instance.new("UIListLayout", page); layout.Padding = UDim.new(0,4); layout.SortOrder = Enum.SortOrder.LayoutOrder

    pages[key] = page; buttons[key] = btn
    btn.MouseButton1Click:Connect(function()
        for k, p in pairs(pages) do p.Visible = (k == key) end
        for k, b in pairs(buttons) do
            b.BackgroundColor3 = (k == key) and K.Theme.Accent or K.Theme.Glass
            b.TextColor3 = (k == key) and Color3.fromRGB(20,20,20) or K.Theme.TextColor
        end
    end)
    return page
end

local visualsPage = makeTab("Visuals", "visuals")
local aimbotPage  = makeTab("Aimbot",  "aimbot")
local miscPage    = makeTab("Misc",    "misc")
buttons.visuals.BackgroundColor3 = K.Theme.Accent; buttons.visuals.TextColor3 = Color3.fromRGB(20,20,20)
pages.visuals.Visible = true

local function addToggle(parent, text, path)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-4,0,32); btn.BackgroundColor3 = K.Theme.Glass; btn.BorderSizePixel = 0
    btn.Text = "  "..text..": "..(K.GetSetting(path) and "ON" or "OFF")
    btn.TextXAlignment = Enum.TextXAlignment.Left; btn.Font = Enum.Font.Gotham; btn.TextSize = 13
    btn.TextColor3 = K.GetSetting(path) and K.Theme.Accent or K.Theme.TextColor; btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,4)
    btn.MouseButton1Click:Connect(function()
        local state = not K.GetSetting(path)
        K.SetSetting(path, state)
        btn.Text = "  "..text..": "..(state and "ON" or "OFF")
        btn.TextColor3 = state and K.Theme.Accent or K.Theme.TextColor
    end)
end

addToggle(visualsPage, "ESP",       "ESP.Enabled")
addToggle(visualsPage, "Боксы",     "ESP.Box")
addToggle(visualsPage, "Ники",      "ESP.Name")
addToggle(visualsPage, "Здоровье",  "ESP.Health")
addToggle(visualsPage, "Дистанция", "ESP.Distance")
addToggle(visualsPage, "TeamCheck", "ESP.TeamCheck")

addToggle(aimbotPage, "Aimbot",     "Aimbot.Enabled")
addToggle(aimbotPage, "FOV круг",   "Aimbot.DrawFOV")
addToggle(aimbotPage, "Стены",      "Aimbot.VisibleOnly")
addToggle(aimbotPage, "TeamCheck",  "Aimbot.TeamCheck")
addToggle(aimbotPage, "Triggerbot", "Combat.TriggerBot")

addToggle(miscPage, "Bunnyhop",   "Misc.Bunnyhop")
addToggle(miscPage, "Fullbright", "Misc.Fullbright")

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == K.GetSetting("Keybinds.Menu") then gui.Enabled = not gui.Enabled end
end)

print("[KIRO UI] Меню создано.")
