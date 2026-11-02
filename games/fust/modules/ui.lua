-- =====================================================================
-- KIRO UI | Frozen Style (Optimized)
-- =====================================================================
local K = shared.KIRO
if not K then return end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer

local Theme = {
    BG = Color3.fromRGB(12, 15, 22),
    Sidebar = Color3.fromRGB(18, 22, 33),
    Component = Color3.fromRGB(28, 34, 48),
    ComponentHover = Color3.fromRGB(38, 45, 62),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(150, 160, 180),
    Accent = Color3.fromRGB(99, 102, 241),
    Accent2 = Color3.fromRGB(139, 92, 246),
    Red = Color3.fromRGB(239, 68, 68),
    Green = Color3.fromRGB(34, 197, 94),
    Border = Color3.fromRGB(40, 46, 62)
}

local FontMain = Enum.Font.GothamMedium
local FontBold = Enum.Font.GothamBold
local FontBlack = Enum.Font.GothamBlack

local function gs(path)
    local v = K.GetSetting(path)
    if v == nil then return false end
    return v
end

-- blur
local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting

-- parent gui
local parentGui = gethui and gethui() or game:GetService("CoreGui")
for _, v in pairs(parentGui:GetChildren()) do
    if v.Name == "KiroCheatUI" then v:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KiroCheatUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.DisplayOrder = 99999
ScreenGui.Parent = parentGui
K.ScreenGui = ScreenGui

-- main window
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 580, 0, 380)
Main.Position = UDim2.new(0.5, -290, 0.5, -190)
Main.BackgroundColor3 = Theme.BG
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Visible = false
Main.Active = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Theme.Accent
MainStroke.Thickness = 1
MainStroke.Transparency = 0.5

local MainGrad = Instance.new("UIGradient", Main)
MainGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 20, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 10, 15))
}
MainGrad.Rotation = 135

-- sidebar
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 140, 1, 0)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

local SidebarFix = Instance.new("Frame", Sidebar)
SidebarFix.Size = UDim2.new(0, 12, 1, 0)
SidebarFix.Position = UDim2.new(1, -12, 0, 0)
SidebarFix.BackgroundColor3 = Theme.Sidebar
SidebarFix.BorderSizePixel = 0

local Logo = Instance.new("TextLabel", Sidebar)
Logo.Size = UDim2.new(1, 0, 0, 40)
Logo.BackgroundTransparency = 1
Logo.Text = "KiroHack"
Logo.TextColor3 = Theme.Accent
Logo.Font = FontBlack
Logo.TextSize = 20
Logo.Position = UDim2.new(0, 0, 0, 8)

local GameLbl = Instance.new("TextLabel", Sidebar)
GameLbl.Size = UDim2.new(1, -10, 0, 14)
GameLbl.Position = UDim2.new(0, 5, 0, 44)
GameLbl.BackgroundTransparency = 1
GameLbl.Text = tostring(K.GameId or "Unknown")
GameLbl.TextColor3 = Theme.TextDim
GameLbl.Font = Enum.Font.Gotham
GameLbl.TextSize = 10
GameLbl.TextXAlignment = Enum.TextXAlignment.Center

local TabContainer = Instance.new("Frame", Sidebar)
TabContainer.Size = UDim2.new(1, -16, 1, -70)
TabContainer.Position = UDim2.new(0, 8, 0, 62)
TabContainer.BackgroundTransparency = 1
local tabList = Instance.new("UIListLayout", TabContainer)
tabList.Padding = UDim.new(0, 4)
tabList.SortOrder = Enum.SortOrder.LayoutOrder

-- content area
local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, -160, 1, -30)
Content.Position = UDim2.new(0, 150, 0, 15)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = Theme.Accent
Content.ScrollBarImageTransparency = 0.4
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
local contentList = Instance.new("UIListLayout", Content)
contentList.Padding = UDim.new(0, 6)
contentList.SortOrder = Enum.SortOrder.LayoutOrder

-- helpers
local pages = {}
local tabButtons = {}
local tabOrder = 0

local function CreateTab(name, key)
    tabOrder = tabOrder + 1
    local btn = Instance.new("TextButton", TabContainer)
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Theme.Component
    btn.Text = name
    btn.TextColor3 = Theme.TextDim
    btn.Font = FontBold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.LayoutOrder = tabOrder
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local pad = Instance.new("UIPadding", btn)
    pad.PaddingLeft = UDim.new(0, 12)

    local page = Instance.new("Frame", Content)
    page.Size = UDim2.new(1, -10, 0, 0)
    page.AutomaticSize = Enum.AutomaticSize.Y
    page.BackgroundTransparency = 1
    page.Visible = false
    local pl = Instance.new("UIListLayout", page)
    pl.Padding = UDim.new(0, 5)
    pl.SortOrder = Enum.SortOrder.LayoutOrder

    pages[key] = page
    tabButtons[key] = btn

    btn.MouseButton1Click:Connect(function()
        for k, p in pairs(pages) do p.Visible = (k == key) end
        for k, b in pairs(tabButtons) do
            b.BackgroundColor3 = (k == key) and Theme.Accent or Theme.Component
            b.TextColor3 = (k == key) and Theme.Text or Theme.TextDim
        end
    end)
    btn.MouseEnter:Connect(function()
        if not pages[key].Visible then
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.ComponentHover}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if not pages[key].Visible then
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Component}):Play()
        end
    end)
    return page
end

local function AddSection(parent, text)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text = text:upper()
    lbl.TextColor3 = Theme.Accent
    lbl.Font = FontBold
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
end

local function AddToggle(parent, text, path)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Theme.Component
    btn.Text = ""
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.Text
    lbl.Font = FontMain
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local sw = Instance.new("Frame", btn)
    sw.Size = UDim2.new(0, 32, 0, 16)
    sw.Position = UDim2.new(1, -40, 0.5, -8)
    sw.BackgroundColor3 = gs(path) and Theme.Accent or Color3.fromRGB(50, 55, 70)
    sw.BorderSizePixel = 0
    Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", sw)
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = gs(path) and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local function refresh()
        local st = gs(path)
        TweenService:Create(sw, TweenInfo.new(0.15), {BackgroundColor3 = st and Theme.Accent or Color3.fromRGB(50, 55, 70)}):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {Position = st and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}):Play()
        lbl.TextColor3 = st and Theme.Text or Theme.TextDim
    end

    btn.MouseButton1Click:Connect(function()
        K.SetSetting(path, not gs(path))
        refresh()
    end)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.ComponentHover}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Component}):Play()
    end)
end

local function AddSlider(parent, text, min, max, path)
    local cur = K.GetSetting(path)
    if cur == nil then return end
    cur = tonumber(cur) or min

    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, 0, 0, 42)
    frame.BackgroundColor3 = Theme.Component
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, -16, 0, 18)
    lbl.Position = UDim2.new(0, 8, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.Text
    lbl.Font = FontMain
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local val = Instance.new("TextLabel", frame)
    val.Size = UDim2.new(0, 50, 0, 18)
    val.Position = UDim2.new(1, -58, 0, 4)
    val.BackgroundTransparency = 1
    val.Text = tostring(cur)
    val.TextColor3 = Theme.Accent
    val.Font = FontBold
    val.TextSize = 11
    val.TextXAlignment = Enum.TextXAlignment.Right

    local track = Instance.new("Frame", frame)
    track.Size = UDim2.new(1, -16, 0, 4)
    track.Position = UDim2.new(0, 8, 0, 28)
    track.BackgroundColor3 = Color3.fromRGB(50, 55, 70)
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", track)
    local rel = math.clamp((cur - min) / (max - min), 0, 1)
    fill.Size = UDim2.new(rel, 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local dragging = false
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local r = math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local v = math.floor((min + (max - min) * r) * 100) / 100
            K.SetSetting(path, v)
            val.Text = tostring(v)
            fill.Size = UDim2.new(r, 0, 1, 0)
        end
    end)
end

-- ============ TABS ============
local hasExtra = K.GetSetting("Skins") or K.GetSetting("ThirdPerson") or K.GetSetting("Teleport")
local pVisual = CreateTab("Visuals", "visual")
local pCombat = CreateTab("Combat", "combat")
local pMisc = CreateTab("Misc", "misc")
local pExtra = nil
if hasExtra then
    local tabName = "Extra"
    if K.GetSetting("Skins") then tabName = "Skins" end
    if K.GetSetting("Teleport") then tabName = "TP" end
    pExtra = CreateTab(tabName, "extra")
end

-- Visual tab
AddSection(pVisual, "ESP")
AddToggle(pVisual, "ESP Enabled", "ESP.Enabled")
AddToggle(pVisual, "Boxes", "ESP.Box")
AddToggle(pVisual, "Names", "ESP.Name")
AddToggle(pVisual, "Health", "ESP.Health")
AddToggle(pVisual, "Distance", "ESP.Distance")
AddToggle(pVisual, "Weapon", "ESP.Weapon")
AddToggle(pVisual, "Skeleton", "ESP.Skeleton")
AddToggle(pVisual, "Team Check", "ESP.TeamCheck")
AddSlider(pVisual, "Max Distance", 100, 5000, "ESP.MaxDist")

-- Combat tab
AddSection(pCombat, "Aimbot")
AddToggle(pCombat, "Aimbot", "Aimbot.Enabled")
AddToggle(pCombat, "Draw FOV", "Aimbot.DrawFOV")
AddToggle(pCombat, "Wall Check", "Aimbot.VisibleOnly")
AddToggle(pCombat, "Team Check", "Aimbot.TeamCheck")
AddToggle(pCombat, "Silent Aim", "Aimbot.SilentAim")
AddSlider(pCombat, "FOV", 30, 500, "Aimbot.FOV")
AddSlider(pCombat, "Smoothness", 0.05, 1, "Aimbot.Smoothness")
AddSection(pCombat, "Combat")
AddToggle(pCombat, "Triggerbot", "Combat.TriggerBot")
AddToggle(pCombat, "No Recoil", "Combat.NoRecoil")
AddToggle(pCombat, "No Spread", "Combat.NoSpread")
AddSlider(pCombat, "Trigger Delay", 0, 0.5, "Combat.TriggerDelay")

-- Misc tab
AddSection(pMisc, "Movement")
AddToggle(pMisc, "Bunnyhop", "Misc.Bunnyhop")
AddToggle(pMisc, "Speed", "Misc.Speed")
AddToggle(pMisc, "Fly", "Misc.Fly")
AddToggle(pMisc, "Noclip", "Misc.Noclip")
AddToggle(pMisc, "Inf Jump", "Misc.InfiniteJump")
AddSection(pMisc, "Visual")
AddToggle(pMisc, "Fullbright", "Misc.Fullbright")
AddToggle(pMisc, "No-Flash", "Misc.NoFlash")
AddSection(pMisc, "Security")
AddToggle(pMisc, "Anti-AFK", "Security.AntiAFK")
AddToggle(pMisc, "Staff Detect", "Security.StaffDetect")

-- Extra tab
if pExtra then
    if K.GetSetting("Skins") then
        AddSection(pExtra, "Skins")
        AddToggle(pExtra, "Skin Changer", "Skins.Enabled")
    end
    if K.GetSetting("ThirdPerson") then
        AddSection(pExtra, "Third Person")
        AddToggle(pExtra, "Third Person", "ThirdPerson.Enabled")
        AddToggle(pExtra, "Char Preview", "ThirdPerson.Preview")
    end
    if K.GetSetting("Teleport") then
        AddSection(pExtra, "Teleport")
        AddToggle(pExtra, "Teleport (T)", "Teleport.Enabled")
    end
end

-- activate first tab
local firstKey = nil
for k, _ in pairs(pages) do firstKey = k break end
if firstKey then
    pages[firstKey].Visible = true
    tabButtons[firstKey].BackgroundColor3 = Theme.Accent
    tabButtons[firstKey].TextColor3 = Theme.Text
end

-- drag
local dragging, dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- hotkey
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F4 then
        Main.Visible = not Main.Visible
        if Main.Visible then
            UIS.MouseBehavior = Enum.MouseBehavior.Default
            UIS.MouseIconEnabled = true
        end
    end
end)

-- mouse fix
RunService.RenderStepped:Connect(function()
    if Main.Visible then
        if UIS.MouseBehavior ~= Enum.MouseBehavior.Default then UIS.MouseBehavior = Enum.MouseBehavior.Default end
        if not UIS.MouseIconEnabled then UIS.MouseIconEnabled = true end
    end
end)

-- blur (light)
task.spawn(function()
    while Main and Main.Parent do
        if Main.Visible then
            if blur.Size < 6 then blur.Size = blur.Size + 2 end
        else
            if blur.Size > 0 then blur.Size = blur.Size - 2 end
        end
        task.wait(0.05)
    end
end)

-- optimized snow (lightweight, few particles)
local snowContainer = Instance.new("Frame", ScreenGui)
snowContainer.Size = UDim2.new(1, 0, 1, 0)
snowContainer.BackgroundTransparency = 1
snowContainer.ClipsDescendants = true
snowContainer.ZIndex = 0

local snowflakes = {}
local maxFlakes = 25

task.spawn(function()
    while ScreenGui and ScreenGui.Parent do
        if Main.Visible and #snowflakes < maxFlakes then
            local flake = Instance.new("Frame", snowContainer)
            flake.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
            flake.Position = UDim2.new(math.random() * 0.9 + 0.05, 0, -0.02, 0)
            flake.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            flake.BackgroundTransparency = 0.4
            flake.BorderSizePixel = 0
            flake.ZIndex = 0
            local c = Instance.new("UICorner", flake)
            c.CornerRadius = UDim.new(1, 0)
            table.insert(snowflakes, flake)
        end
        for i = #snowflakes, 1, -1 do
            local f = snowflakes[i]
            if f and f.Parent then
                local p = f.Position
                local ny = p.Y.Scale + 0.003
                if ny > 1.02 then
                    f.Position = UDim2.new(math.random() * 0.9 + 0.05, 0, -0.02, 0)
                else
                    f.Position = UDim2.new(p.X.Scale + (math.random(-1, 1) * 0.0005), 0, ny, 0)
                end
            else
                table.remove(snowflakes, i)
            end
        end
        task.wait(0.04)
    end
end)

K.Loading = false
if K.Notify then K.Notify("KiroHack", "Loaded! F4 - menu", false) end
print("[KIRO UI] Frozen style menu loaded.")
