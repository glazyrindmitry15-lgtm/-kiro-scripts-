-- =====================================================================
-- KIRO HACK | UNIVERSAL LAUNCHER (multi-game)
-- =====================================================================
print("[KIRO] Инициализация лаунчера...")

local BASE = "https://raw.githubusercontent.com/glazyrindmitry15-lgtm/kiro-scripts/main/"
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
K.Runtime     = true
K.Modules     = {}
shared.KIRO   = K

-- ============ SECURE LOAD ============
function K.SecureLoad(url)
    local ok, code = pcall(game.HttpGet, game, url)
    if not ok or not code or code == "" then
        warn("[KIRO] Не удалось скачать: "..url)
        return
    end

    if code:sub(1,4) == "ENC:" then
        code = xor(dec(code:sub(5)), KEY)
    end

    local wrapped = "ENC:" .. enc(xor(code, KEY))
    code = nil

    local raw = xor(dec(wrapped:sub(5)), KEY)
    local fn, err = loadstring(raw)
    if not fn then
        warn("[KIRO] Ошибка компиляции: "..url.."\n"..tostring(err))
        return
    end

    local env = setmetatable({}, { __index = getgenv() })
    env.KIRO_PROTECTED = true
    env.shared = shared
    setfenv(fn, env)

    local okRun, errRun = pcall(fn)
    if not okRun then
        warn("[KIRO] Ошибка выполнения: "..url.."\n"..tostring(errRun))
    end
    raw, wrapped = nil, nil
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

local oldDump = string.dump
string.dump = function(f, s)
    if getfenv(f) and getfenv(f).KIRO_PROTECTED then
        return "\27LuaS"
    end
    return oldDump(f, s)
end

-- ============ ЗАГРУЗКА КОНФИГА ============
local cfgOk, cfgRaw = pcall(game.HttpGet, game, BASE.."config.lua")
if not cfgOk or not cfgRaw or cfgRaw == "" then
    warn("[KIRO] Не удалось загрузить config.lua")
    return
end

local cfgFn = loadstring(cfgRaw)
local cfg = cfgFn and cfgFn() or nil
if not cfg then
    warn("[KIRO] config.lua повреждён или пустой")
    return
end

-- ============ МЕНЮ ВЫБОРА ИГРЫ ============
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "KiroLauncher"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LP:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 380, 0, 60 + #cfg.games * 70 + 20)
main.Position = UDim2.new(0.5, -190, 0.5, -main.Size.Y.Offset/2)
main.BackgroundColor3 = Color3.fromRGB(18,18,22)
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0,8)
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(255,140,0)
stroke.Thickness = 1.5

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,50)
title.BackgroundTransparency = 1
title.Text = "KIRO HACK • Выбор игры"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(255,140,0)
title.Parent = main

for i, g in ipairs(cfg.games) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-20,0,60)
    btn.Position = UDim2.new(0,10,0,50+(i-1)*70)
    btn.BackgroundColor3 = Color3.fromRGB(28,28,34)
    btn.BorderSizePixel = 0
    btn.Text = "  "..g.name.."\n  "..g.desc
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(230,230,230)
    btn.Parent = main
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(40,40,48) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(28,28,34) end)

    btn.MouseButton1Click:Connect(function()
        gui:Destroy()
        K.GAME_BASE = BASE.."games/"..g.id.."/"
        K.GameId    = g.id
        print("[KIRO] Запуск: "..g.name)
        K.SecureLoad(K.GAME_BASE.."entry.lua")
    end)
end
