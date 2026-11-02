-- =====================================================================
-- KIRO LOADER | Multi-Game Menu
-- =====================================================================
print("[KIRO LOADER] Инициализация...")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LP = Players.LocalPlayer

local BASE = "https://raw.githubusercontent.com/glazyrindmitry15-lgtm/-kiro-scripts-/main/multihack/kiro-scripts-main/"
local KEY  = "KiroSuperSecretKey2026"

-- ============ ШИФРОВАНИЕ (XOR + Base64) ============
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

-- ============ ГЛОБАЛЬНОЕ ПРОСТРАНСТВО ============
local K = {}
K.Base        = BASE
K.Key         = KEY
K.enc         = enc
K.dec         = dec
K.xor         = xor
K.GAME_BASE   = ""
K.Modules     = {}
shared.KIRO   = K

-- ============ SECURE LOAD ============
function K.SecureLoad(url)
    local ok, code = pcall(game.HttpGet, game, url)
    if not ok or not code or code == "" then
        warn("[KIRO] Не удалось скачать: "..url)
        return false
    end
    if code:sub(1,9) == "<!DOCTYPE" then
        warn("[KIRO] 404: "..url)
        return false
    end

    -- если зашифровано (ENC:) — расшифровать
    if code:sub(1,4) == "ENC:" then
        code = xor(dec(code:sub(5)), KEY)
    end

    local fn, err = loadstring(code)
    if not fn then
        warn("[KIRO] Ошибка компиляции: "..url.."\n"..tostring(err))
        return false
    end

    local env = setmetatable({}, { __index = getgenv() })
    env.KIRO_PROTECTED = true
    env.shared = shared
    setfenv(fn, env)

    local okRun, errRun = pcall(fn)
    if not okRun then
        warn("[KIRO] Ошибка выполнения: "..url.."\n"..tostring(errRun))
        return false
    end
    return true
end

-- ============ АНТИ-ДАМП ============
local oldInfo = debug.info
debug.info = function(...)
    local a = {...}
    if typeof(a[1]) == "function" and getfenv(a[1]).KIRO_PROTECTED then
        return "C","C",1,1
    end
    return oldInfo(...)
end

-- ============ МЕНЮ ============
local GAMES = {
    { id = "fust",  name = "FUST",          desc = "Aimbot • ESP • Visuals" },
    { id = "cs_go", name = "CS:GO Roblox",  desc = "ESP • Trigger • RCS • BHop" },
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

local Card = Instance.new("Frame", ScreenGui)
Card.Size = UDim2.new(0, 420, 0, 60 + #GAMES*70 + 30)
Card.Position = UDim2.new(0.5, -210, 0.5, -(60 + #GAMES*70 + 30)/2)
Card.BackgroundColor3 = Theme.BG
Card.BackgroundTransparency = 0.02
Card.BorderSizePixel = 0
Card.Active = true
Card.ZIndex = 3
Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 16)

local Title = Instance.new("TextLabel", Card)
Title.Size = UDim2.new(1,0,0,44)
Title.Position = UDim2.new(0,0,0,8)
Title.BackgroundTransparency = 1
Title.Text = "KIRO • Выбор игры"
Title.TextColor3 = Theme.Accent
Title.Font = Font_Black
Title.TextSize = 18
Title.ZIndex = 4

local Status = Instance.new("TextLabel", Card)
Status.Size = UDim2.new(1,-20,0,16)
Status.Position = UDim2.new(0,10,1,-22)
Status.BackgroundTransparency = 1
Status.Text = "Готово"
Status.TextColor3 = Theme.TextDim
Status.Font = Font_Main
Status.TextSize = 11
Status.ZIndex = 4

for i, g in ipairs(GAMES) do
    local btn = Instance.new("TextButton", Card)
    btn.Size = UDim2.new(1,-24,0,60)
    btn.Position = UDim2.new(0,12,0,52+(i-1)*68)
    btn.BackgroundColor3 = Theme.Glass
    btn.BackgroundTransparency = 0.1
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ZIndex = 4
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    local nameLbl = Instance.new("TextLabel", btn)
    nameLbl.Size = UDim2.new(1,-20,0,22)
    nameLbl.Position = UDim2.new(0,12,0,8)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = g.name
    nameLbl.TextColor3 = Theme.Text
    nameLbl.Font = Font_Bold
    nameLbl.TextSize = 14
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.ZIndex = 5

    local descLbl = Instance.new("TextLabel", btn)
    descLbl.Size = UDim2.new(1,-20,0,16)
    descLbl.Position = UDim2.new(0,12,0,32)
    descLbl.BackgroundTransparency = 1
    descLbl.Text = g.desc
    descLbl.TextColor3 = Theme.TextDim
    descLbl.Font = Font_Main
    descLbl.TextSize = 11
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.ZIndex = 5

    btn.MouseEnter:Connect(function() btn.BackgroundTransparency = 0 end)
    btn.MouseLeave:Connect(function() btn.BackgroundTransparency = 0.1 end)
    btn.MouseButton1Click:Connect(function()
        Status.Text = "Загрузка: "..g.name.."..."
        Status.TextColor3 = Theme.Accent
        K.GAME_BASE = BASE.."games/"..g.id.."/"
        local ok = K.SecureLoad(K.GAME_BASE.."entry.lua")
        if ok then
            Status.Text = "✓ "..g.name.." загружен"
            Status.TextColor3 = Theme.Green
            task.wait(0.4)
            ScreenGui:Destroy()
        else
            Status.Text = "✕ Ошибка загрузки"
            Status.TextColor3 = Theme.Red
        end
    end)
end

-- mouse fix
RunService.RenderStepped:Connect(function()
    if ScreenGui and ScreenGui.Parent then
        if UIS.MouseBehavior ~= Enum.MouseBehavior.Default then UIS.MouseBehavior = Enum.MouseBehavior.Default end
        if not UIS.MouseIconEnabled then UIS.MouseIconEnabled = true end
    end
end)

print("[KIRO LOADER] Меню создано.")
