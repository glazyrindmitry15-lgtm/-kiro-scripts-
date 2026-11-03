-- =====================================================================
-- KIRO UI | Full Featured (Anime BG + Working Sliders)
-- =====================================================================
local K = shared.KIRO
if not K then return end

if not K.GameId then K.GameId = "unknown" end
if not K.GetSetting then K.GetSetting = function(path) return nil end end
if not K.SetSetting then K.SetSetting = function(path, v) end end
if not K.Notify then K.Notify = function(title, text, ntype) end end
if not K.Version then K.Version = "1.2.0" end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

local Theme = K.Theme or {
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
    Orange = Color3.fromRGB(255, 165, 0),
}
local FontMain = (K.Fonts and K.Fonts.Main) or Enum.Font.GothamMedium
local FontBold = (K.Fonts and K.Fonts.Bold) or Enum.Font.GothamBold
local FontBlack = (K.Fonts and K.Fonts.Black) or Enum.Font.GothamBlack

local function gs(path)
    local v = K.GetSetting(path)
    if v == nil then return false end
    return v
end

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

-- ============ ANIME BACKGROUND ============
local bg = Instance.new("ImageLabel", ScreenGui)
bg.Size = UDim2.new(1, 0, 1, 0)
bg.Position = UDim2.new(0, 0, 0, 0)
bg.BackgroundTransparency = 1
bg.Image = "rbxassetid://135051563569214"
bg.ScaleType = Enum.ScaleType.Crop
bg.ZIndex = 1

-- darken overlay
local overlay = Instance.new("Frame", ScreenGui)
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 0.4
overlay.BorderSizePixel = 0
overlay.ZIndex = 2

-- ============ MAIN WINDOW ============
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 600, 0, 420)
Main.Position = UDim2.new(0.5, -300, 0.5, -210)
Main.BackgroundColor3 = Theme.BG
Main.BackgroundTransparency = 0.15
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Visible = false
Main.Active = true
Main.ZIndex = 10
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

-- ============ STATUS BAR ============
local statusBar = Instance.new("Frame", Main)
statusBar.Size = UDim2.new(1, 0, 0, 24)
statusBar.Position = UDim2.new(0, 0, 0, 0)
statusBar.BackgroundColor3 = Theme.Component or Color3.fromRGB(28, 34, 48)
statusBar.BorderSizePixel = 0
statusBar.ZIndex = 11

local statusTitle = Instance.new("TextLabel", statusBar)
statusTitle.Size = UDim2.new(0, 120, 1, 0)
statusTitle.Position = UDim2.new(0, 8, 0, 0)
statusTitle.BackgroundTransparency = 1
statusTitle.Text = "KiroHack v" .. (K.Version or "1.2.0")
statusTitle.TextColor3 = Theme.Accent
statusTitle.Font = FontBlack
statusTitle.TextSize = 11
statusTitle.TextXAlignment = Enum.TextXAlignment.Left
statusTitle.ZIndex = 12

local statusTime = Instance.new("TextLabel", statusBar)
statusTime.Size = UDim2.new(0, 70, 1, 0)
statusTime.Position = UDim2.new(0, 130, 0, 0)
statusTime.BackgroundTransparency = 1
statusTime.Text = "00:00:00"
statusTime.TextColor3 = Theme.TextDim
statusTime.Font = Enum.Font.Code
statusTime.TextSize = 10
statusTime.TextXAlignment = Enum.TextXAlignment.Left
statusTime.ZIndex = 12

local statusNick = Instance.new("TextLabel", statusBar)
statusNick.Size = UDim2.new(0, 120, 1, 0)
statusNick.Position = UDim2.new(0, 205, 0, 0)
statusNick.BackgroundTransparency = 1
statusNick.Text = LP.Name
statusNick.TextColor3 = Theme.Text
statusNick.Font = FontBold
statusNick.TextSize = 10
statusNick.TextXAlignment = Enum.TextXAlignment.Left
statusNick.ZIndex = 12

local statusGame = Instance.new("TextLabel", statusBar)
statusGame.Size = UDim2.new(1, -330, 1, 0)
statusGame.Position = UDim2.new(0, 330, 0, 0)
statusGame.BackgroundTransparency = 1
statusGame.Text = tostring(K.GameId or "Unknown")
statusGame.TextColor3 = Theme.Accent
statusGame.Font = FontBold
statusGame.TextSize = 10
statusGame.TextXAlignment = Enum.TextXAlignment.Left
statusGame.ZIndex = 12

task.spawn(function()
    while ScreenGui and ScreenGui.Parent do
        statusTime.Text = os.date("%H:%M:%S")
        task.wait(1)
    end
end)

-- ============ SIDEBAR ============
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 150, 1, -24)
Sidebar.Position = UDim2.new(0, 0, 0, 24)
Sidebar.BackgroundColor3 = Theme.Sidebar or Color3.fromRGB(18, 22, 33)
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 10
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

local SidebarFix = Instance.new("Frame", Sidebar)
SidebarFix.Size = UDim2.new(0, 12, 1, 0)
SidebarFix.Position = UDim2.new(1, -12, 0, 0)
SidebarFix.BackgroundColor3 = Theme.Sidebar or Color3.fromRGB(18, 22, 33)
SidebarFix.BorderSizePixel = 0
SidebarFix.ZIndex = 10

local Logo = Instance.new("TextLabel", Sidebar)
Logo.Size = UDim2.new(1, 0, 0, 36)
Logo.BackgroundTransparency = 1
Logo.Text = "KiroHack"
Logo.TextColor3 = Theme.Accent
Logo.Font = FontBlack
Logo.TextSize = 18
Logo.Position = UDim2.new(0, 0, 0, 6)
Logo.ZIndex = 11

local GameLbl = Instance.new("TextLabel", Sidebar)
GameLbl.Size = UDim2.new(1, -10, 0, 14)
GameLbl.Position = UDim2.new(0, 5, 0, 40)
GameLbl.BackgroundTransparency = 1
GameLbl.Text = tostring(K.GameId or "Unknown")
GameLbl.TextColor3 = Theme.TextDim
GameLbl.Font = Enum.Font.Gotham
GameLbl.TextSize = 10
GameLbl.TextXAlignment = Enum.TextXAlignment.Center
GameLbl.ZIndex = 11

local VersionLbl = Instance.new("TextLabel", Sidebar)
VersionLbl.Size = UDim2.new(1, -10, 0, 12)
VersionLbl.Position = UDim2.new(0, 5, 0, 54)
VersionLbl.BackgroundTransparency = 1
VersionLbl.Text = "v" .. (K.Version or "1.2.0")
VersionLbl.TextColor3 = Theme.TextDim
VersionLbl.Font = Enum.Font.Gotham
VersionLbl.TextSize = 9
VersionLbl.TextXAlignment = Enum.TextXAlignment.Center
VersionLbl.ZIndex = 11

local TabContainer = Instance.new("Frame", Sidebar)
TabContainer.Size = UDim2.new(1, -16, 1, -80)
TabContainer.Position = UDim2.new(0, 8, 0, 70)
TabContainer.BackgroundTransparency = 1
TabContainer.ZIndex = 10
local tabList = Instance.new("UIListLayout", TabContainer)
tabList.Padding = UDim.new(0, 4)
tabList.SortOrder = Enum.SortOrder.LayoutOrder

-- player profile
local profileFrame = Instance.new("Frame", Sidebar)
profileFrame.Size = UDim2.new(1, -16, 0, 44)
profileFrame.Position = UDim2.new(0, 8, 1, -52)
profileFrame.BackgroundColor3 = Theme.Component or Color3.fromRGB(28, 34, 48)
profileFrame.BorderSizePixel = 0
profileFrame.ZIndex = 10
Instance.new("UICorner", profileFrame).CornerRadius = UDim.new(0, 6)

local avatar = Instance.new("ImageLabel", profileFrame)
avatar.Size = UDim2.new(0, 32, 0, 32)
avatar.Position = UDim2.new(0, 6, 0.5, -16)
avatar.BackgroundColor3 = Theme.Glass or Color3.fromRGB(20, 20, 30)
avatar.BorderSizePixel = 0
avatar.ZIndex = 11
Instance.new("UICorner", avatar).CornerRadius = UDim.new(0, 6)
task.spawn(function()
    local ok, img = pcall(function()
        return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    end)
    if ok and img then avatar.Image = img end
end)

local nameLabel = Instance.new("TextLabel", profileFrame)
nameLabel.Size = UDim2.new(1, -44, 0, 14)
nameLabel.Position = UDim2.new(0, 42, 0, 6)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = LP.Name
nameLabel.TextColor3 = Theme.Text
nameLabel.Font = FontBold
nameLabel.TextSize = 10
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
nameLabel.ZIndex = 11

local idLabel = Instance.new("TextLabel", profileFrame)
idLabel.Size = UDim2.new(1, -44, 0, 12)
idLabel.Position = UDim2.new(0, 42, 0, 22)
idLabel.BackgroundTransparency = 1
idLabel.Text = "ID: " .. LP.UserId
idLabel.TextColor3 = Theme.TextDim
idLabel.Font = Enum.Font.Gotham
idLabel.TextSize = 9
idLabel.TextXAlignment = Enum.TextXAlignment.Left
idLabel.ZIndex = 11

-- ============ CLOSE BUTTON ============
local closeBtn = Instance.new("TextButton", Main)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -36, 0, 28)
closeBtn.BackgroundColor3 = Theme.GlassLight or Color3.fromRGB(30, 30, 42)
closeBtn.Text = "X"
closeBtn.TextColor3 = Theme.Red
closeBtn.Font = FontBold
closeBtn.TextSize = 18
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 12
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

-- ============ LANGUAGE BUTTON ============
local langBtn = Instance.new("TextButton", Main)
langBtn.Size = UDim2.new(0, 30, 0, 30)
langBtn.Position = UDim2.new(1, -70, 0, 28)
langBtn.BackgroundColor3 = Theme.GlassLight or Color3.fromRGB(30, 30, 42)
langBtn.Text = "RU"
langBtn.TextColor3 = Theme.Text
langBtn.Font = FontBold
langBtn.TextSize = 11
langBtn.BorderSizePixel = 0
langBtn.ZIndex = 12
Instance.new("UICorner", langBtn).CornerRadius = UDim.new(0, 6)

local langs = {"ru", "en", "ar"}
local langIdx = 1
langBtn.MouseButton1Click:Connect(function()
    langIdx = langIdx % #langs + 1
    local newLang = langs[langIdx]
    if K.Settings then K.Settings.Language = newLang end
    langBtn.Text = newLang:upper()
    if K.Notify then K.Notify("Language", "Changed to " .. newLang:upper(), "success") end
end)

-- ============ CONTENT ============
local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, -170, 1, -58)
Content.Position = UDim2.new(0, 150, 0, 30)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = Theme.Accent
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.ZIndex = 10
local contentList = Instance.new("UIListLayout", Content)
contentList.Padding = UDim.new(0, 6)
contentList.SortOrder = Enum.SortOrder.LayoutOrder

-- ============ HELPERS ============
local pages = {}
local tabButtons = {}
local tabOrder = 0

local function gs(path)
    local v = K.GetSetting(path)
    if v == nil then return false end
    return v
end

local function makeTab(name, key)
    tabOrder = tabOrder + 1
    local btn = Instance.new("TextButton", TabContainer)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Theme.Component or Color3.fromRGB(28, 34, 48)
    btn.Text = name
    btn.TextColor3 = Theme.TextDim
    btn.Font = FontBold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.LayoutOrder = tabOrder
    btn.ZIndex = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local pad = Instance.new("UIPadding", btn)
    pad.PaddingLeft = UDim.new(0, 10)

    local page = Instance.new("Frame", Content)
    page.Size = UDim2.new(1, -10, 0, 0)
    page.AutomaticSize = Enum.AutomaticSize.Y
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ZIndex = 10
    local pl = Instance.new("UIListLayout", page)
    pl.Padding = UDim.new(0, 4)
    pl.SortOrder = Enum.SortOrder.LayoutOrder

    pages[key] = page
    tabButtons[key] = btn

    btn.MouseButton1Click:Connect(function()
        for k, p in pairs(pages) do p.Visible = (k == key) end
        for k, b in pairs(tabButtons) do
            if k == key then
                b.BackgroundColor3 = Theme.Accent
                b.TextColor3 = Color3.fromRGB(20, 20, 25)
            else
                b.BackgroundColor3 = Theme.Component or Color3.fromRGB(28, 34, 48)
                b.TextColor3 = Theme.TextDim
            end
        end
    end)
    btn.MouseEnter:Connect(function()
        if not pages[key].Visible then
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.ComponentHover or Color3.fromRGB(38, 45, 62)}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if not pages[key].Visible then
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Component or Color3.fromRGB(28, 34, 48)}):Play()
        end
    end)
    return page
end

local function addToggle(parent, text, path)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Theme.Component or Color3.fromRGB(28, 34, 48)
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ZIndex = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, -42, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.Text
    lbl.Font = FontMain
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 12

    local sw = Instance.new("Frame", btn)
    sw.Size = UDim2.new(0, 28, 0, 12)
    sw.Position = UDim2.new(1, -34, 0.5, -6)
    sw.BackgroundColor3 = gs(path) and Theme.Accent or Color3.fromRGB(50, 55, 70)
    sw.BorderSizePixel = 0
    sw.ZIndex = 12
    Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", sw)
    knob.Size = UDim2.new(0, 8, 0, 8)
    knob.Position = gs(path) and UDim2.new(1, -10, 0.5, -4) or UDim2.new(0, 2, 0.5, -4)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 13
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local function refresh()
        local st = gs(path)
        TweenService:Create(sw, TweenInfo.new(0.15), {BackgroundColor3 = st and Theme.Accent or Color3.fromRGB(50, 55, 70)}):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {Position = st and UDim2.new(1, -10, 0.5, -4) or UDim2.new(0, 2, 0.5, -4)}):Play()
        lbl.TextColor3 = st and Theme.Text or Theme.TextDim
    end

    btn.MouseButton1Click:Connect(function()
        K.SetSetting(path, not gs(path))
        refresh()
    end)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.ComponentHover or Color3.fromRGB(38, 45, 62)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Component or Color3.fromRGB(28, 34, 48)}):Play()
    end)
end

local function addSlider(parent, text, min, max, path)
    local cur = K.GetSetting(path)
    if cur == nil then return end
    cur = tonumber(cur) or min

    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, 0, 0, 36)
    frame.BackgroundColor3 = Theme.Component or Color3.fromRGB(28, 34, 48)
    frame.BorderSizePixel = 0
    frame.ZIndex = 11
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, -16, 0, 14)
    lbl.Position = UDim2.new(0, 8, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.Text
    lbl.Font = FontMain
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 12

    local val = Instance.new("TextLabel", frame)
    val.Size = UDim2.new(0, 40, 0, 14)
    val.Position = UDim2.new(1, -48, 0, 4)
    val.BackgroundTransparency = 1
    val.Text = tostring(cur)
    val.TextColor3 = Theme.Accent
    val.Font = FontBold
    val.TextSize = 10
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.ZIndex = 12

    local track = Instance.new("Frame", frame)
    track.Size = UDim2.new(1, -16, 0, 4)
    track.Position = UDim2.new(0, 8, 0, 24)
    track.BackgroundColor3 = Color3.fromRGB(50, 55, 70)
    track.BorderSizePixel = 0
    track.ZIndex = 12
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", track)
    local rel = math.clamp((cur - min) / (max - min), 0, 1)
    fill.Size = UDim2.new(rel, 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    fill.ZIndex = 13
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local dragging = false
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            -- immediate update on click
            local r = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local v = math.floor((min + (max - min) * r) * 100) / 100
            K.SetSetting(path, v)
            val.Text = tostring(v)
            fill.Size = UDim2.new(r, 0, 1, 0)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local r = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local v = math.floor((min + (max - min) * r) * 100) / 100
            K.SetSetting(path, v)
            val.Text = tostring(v)
            fill.Size = UDim2.new(r, 0, 1, 0)
        end
    end)
end

local function addSection(parent, text)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.Accent
    lbl.Font = FontBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 11
end

-- ============ TABS ============
local hasExtra = K.GetSetting("Skins") or K.GetSetting("ThirdPerson") or K.GetSetting("Teleport")
local pVisual = makeTab("Visual", "visual")
local pCombat = makeTab("Combat", "combat")
local pMisc = makeTab("Misc", "misc")

local pExtra = nil
if hasExtra then
    local tabName = "Extra"
    if K.GetSetting("Skins") then tabName = "Skins" end
    if K.GetSetting("Teleport") then tabName = "TP" end
    pExtra = makeTab(tabName, "extra")
end

-- Settings tab
local pSettings = makeTab("Settings", "settings")

-- Visual
addSection(pVisual, "ESP")
addToggle(pVisual, "ESP Enabled", "ESP.Enabled")
if K.GetSetting("ESP.Box") ~= nil then addToggle(pVisual, "Boxes", "ESP.Box") end
if K.GetSetting("ESP.Name") ~= nil then addToggle(pVisual, "Names", "ESP.Name") end
if K.GetSetting("ESP.Health") ~= nil then addToggle(pVisual, "Health", "ESP.Health") end
if K.GetSetting("ESP.Distance") ~= nil then addToggle(pVisual, "Distance", "ESP.Distance") end
if K.GetSetting("ESP.Weapon") ~= nil then addToggle(pVisual, "Weapon", "ESP.Weapon") end
if K.GetSetting("ESP.Skeleton") ~= nil then addToggle(pVisual, "Skeleton", "ESP.Skeleton") end
if K.GetSetting("ESP.TeamCheck") ~= nil then addToggle(pVisual, "TeamCheck", "ESP.TeamCheck") end
addSlider(pVisual, "Max Distance", 100, 5000, "ESP.MaxDist")

-- Combat
addSection(pCombat, "Aimbot")
addToggle(pCombat, "Aimbot", "Aimbot.Enabled")
if K.GetSetting("Aimbot.DrawFOV") ~= nil then addToggle(pCombat, "Draw FOV", "Aimbot.DrawFOV") end
if K.GetSetting("Aimbot.VisibleOnly") ~= nil then addToggle(pCombat, "Wall Check", "Aimbot.VisibleOnly") end
if K.GetSetting("Aimbot.TeamCheck") ~= nil then addToggle(pCombat, "TeamCheck", "Aimbot.TeamCheck") end
if K.GetSetting("Aimbot.SilentAim") ~= nil then addToggle(pCombat, "Silent Aim", "Aimbot.SilentAim") end
addSlider(pCombat, "FOV", 30, 500, "Aimbot.FOV")
addSlider(pCombat, "Smoothness", 0.05, 1, "Aimbot.Smoothness")

if K.GetSetting("Combat") then
    addSection(pCombat, "Combat")
    if K.GetSetting("Combat.TriggerBot") ~= nil then addToggle(pCombat, "Triggerbot", "Combat.TriggerBot") end
    if K.GetSetting("Combat.NoRecoil") ~= nil then addToggle(pCombat, "No Recoil", "Combat.NoRecoil") end
    if K.GetSetting("Combat.NoSpread") ~= nil then addToggle(pCombat, "No Spread", "Combat.NoSpread") end
    addSlider(pCombat, "Trigger Delay", 0, 0.5, "Combat.TriggerDelay")
end

-- Misc
addSection(pMisc, "Movement")
if K.GetSetting("Misc.Bunnyhop") ~= nil then addToggle(pMisc, "Bunnyhop", "Misc.Bunnyhop") end
if K.GetSetting("Misc.Speed") ~= nil then addToggle(pMisc, "Speed", "Misc.Speed") end
if K.GetSetting("Misc.Fly") ~= nil then addToggle(pMisc, "Fly", "Misc.Fly") end
if K.GetSetting("Misc.Noclip") ~= nil then addToggle(pMisc, "Noclip", "Misc.Noclip") end
if K.GetSetting("Misc.InfiniteJump") ~= nil then addToggle(pMisc, "Inf Jump", "Misc.InfiniteJump") end
addSection(pMisc, "Visual")
if K.GetSetting("Misc.Fullbright") ~= nil then addToggle(pMisc, "Fullbright", "Misc.Fullbright") end
if K.GetSetting("Misc.NoFlash") ~= nil then addToggle(pMisc, "No-Flash", "Misc.NoFlash") end
addSection(pMisc, "Security")
if K.GetSetting("Security.AntiAFK") ~= nil then addToggle(pMisc, "Anti-AFK", "Security.AntiAFK") end
if K.GetSetting("Security.StaffDetect") ~= nil then addToggle(pMisc, "Staff Detect", "Security.StaffDetect") end
if K.GetSetting("Utils.AutoCollect") ~= nil then addToggle(pMisc, "Auto Collect", "Utils.AutoCollect") end
if K.GetSetting("Utils.AutoBuy") ~= nil then addToggle(pMisc, "Auto Buy", "Utils.AutoBuy") end
if K.GetSetting("Utils.AutoRepair") ~= nil then addToggle(pMisc, "Auto Repair", "Utils.AutoRepair") end
if K.GetSetting("Utils.AutoSkillCheck") ~= nil then addToggle(pMisc, "Auto Skill Check", "Utils.AutoSkillCheck") end

-- Extra
if pExtra then
    if K.GetSetting("Skins") then
        addSection(pExtra, "Skins")
        if K.GetSetting("Skins.Enabled") ~= nil then addToggle(pExtra, "Skin Changer", "Skins.Enabled") end
    end
    if K.GetSetting("ThirdPerson") then
        addSection(pExtra, "Third Person")
        if K.GetSetting("ThirdPerson.Enabled") ~= nil then addToggle(pExtra, "Third Person", "ThirdPerson.Enabled") end
        if K.GetSetting("ThirdPerson.Preview") ~= nil then addToggle(pExtra, "Char Preview", "ThirdPerson.Preview") end
    end
    if K.GetSetting("Teleport") then
        addSection(pExtra, "Teleport")
        if K.GetSetting("Teleport.Enabled") ~= nil then addToggle(pExtra, "Teleport (T)", "Teleport.Enabled") end
    end
end

-- Settings tab
addSection(pSettings, "Profile")
local infoLbl = Instance.new("TextLabel", pSettings)
infoLbl.Size = UDim2.new(1, 0, 0, 28)
infoLbl.BackgroundTransparency = 1
infoLbl.Text = "User: " .. LP.Name .. "\nID: " .. LP.UserId
infoLbl.TextColor3 = Theme.Text
infoLbl.Font = FontMain
infoLbl.TextSize = 11
infoLbl.TextXAlignment = Enum.TextXAlignment.Left
infoLbl.ZIndex = 11

addSection(pSettings, "Language")
local langBtns = Instance.new("Frame", pSettings)
langBtns.Size = UDim2.new(1, 0, 0, 24)
langBtns.BackgroundTransparency = 1
local lbl2 = Instance.new("UIListLayout", langBtns)
lbl2.FillDirection = Enum.FillDirection.Horizontal
lbl2.Padding = UDim.new(0, 6)

local langs = {"ru", "en", "ar"}
for _, l in ipairs(langs) do
    local b = Instance.new("TextButton", langBtns)
    b.Size = UDim2.new(0, 40, 0, 22)
    b.BackgroundColor3 = Theme.Component or Color3.fromRGB(28, 34, 48)
    b.Text = l:upper()
    b.TextColor3 = Theme.Text
    b.Font = FontBold
    b.TextSize = 10
    b.BorderSizePixel = 0
    b.ZIndex = 11
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    b.MouseButton1Click:Connect(function()
        if K.Settings then K.Settings.Language = l end
        if K.Notify then K.Notify("Language", "Changed to " .. l:upper(), "success") end
    end)
end

addSection(pSettings, "Config")
local saveBtn = Instance.new("TextButton", pSettings)
saveBtn.Size = UDim2.new(1, 0, 0, 26)
saveBtn.BackgroundColor3 = Theme.Component or Color3.fromRGB(28, 34, 48)
saveBtn.Text = "Save Config"
saveBtn.TextColor3 = Theme.Text
saveBtn.Font = FontBold
saveBtn.TextSize = 11
saveBtn.BorderSizePixel = 0
saveBtn.ZIndex = 11
Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 6)
saveBtn.MouseButton1Click:Connect(function()
    if K.SaveConfig then K.SaveConfig() end
end)

local loadBtn = Instance.new("TextButton", pSettings)
loadBtn.Size = UDim2.new(1, 0, 0, 26)
loadBtn.BackgroundColor3 = Theme.Component or Color3.fromRGB(28, 34, 48)
loadBtn.Text = "Load Config"
loadBtn.TextColor3 = Theme.Text
loadBtn.Font = FontBold
loadBtn.TextSize = 11
loadBtn.BorderSizePixel = 0
loadBtn.ZIndex = 11
Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0, 6)
loadBtn.MouseButton1Click:Connect(function()
    if K.LoadConfig then K.LoadConfig() end
end)

-- activate first tab
local firstKey = next(pages)
if firstKey then
    pages[firstKey].Visible = true
    if tabButtons[firstKey] then
        tabButtons[firstKey].BackgroundColor3 = Theme.Accent
        tabButtons[firstKey].TextColor3 = Color3.fromRGB(20, 20, 25)
    end
end

-- ============ DRAG ============
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

-- ============ HOTKEY F4 ============
UIS.InputBegan:Connect(function(input, gp)
    if input.KeyCode == Enum.KeyCode.F4 then
        print("[KIRO UI] F4 pressed! Toggling menu.")
        Main.Visible = not Main.Visible
        if Main.Visible then
            UIS.MouseBehavior = Enum.MouseBehavior.Default
            UIS.MouseIconEnabled = true
        end
    end
end)

-- ============ MOUSE FIX ============
RunService.RenderStepped:Connect(function()
    if Main.Visible then
        if UIS.MouseBehavior ~= Enum.MouseBehavior.Default then UIS.MouseBehavior = Enum.MouseBehavior.Default end
        if not UIS.MouseIconEnabled then UIS.MouseIconEnabled = true end
    end
end)

K.Loading = false
task.delay(0.5, function()
    if K.Notify then K.Notify("KiroHack", "Loaded! F4 - menu", "success") end
end)
print("[KIRO UI] Меню УСПЕШНО создано! Нажмите F4 для открытия.")
