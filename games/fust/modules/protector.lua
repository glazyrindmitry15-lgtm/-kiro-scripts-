-- =====================================================================
-- KIRO HACK | MOONSEC-STYLE RUNTIME PROTECTOR (VM LAYER)
-- Внимание: этот код предназначен для защиты памяти от дампа.
-- =====================================================================
local K = shared.KIRO
if not K then return end

-- =====================================================================
-- СЛОЙ 1: БАЗОВЫЙ ШИФР (Base64 + XOR)
-- =====================================================================
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local function enc(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

local function dec(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

local function xor(str, key)
    local res = ""
    for i = 1, #str do
        res = res .. string.char(bit32.bxor(string.byte(str, i), string.byte(key, (i - 1) % #key + 1)))
    end
    return res
end

-- =====================================================================
-- СЛОЙ 2: АНТИ-ДАМП И АНТИ-ДЕБАГ (Скрываем следы)
-- =====================================================================
local oldInfo = debug.info
debug.info = function(...)
    local args = {...}
    -- Если античит пытается прочитать нашу функцию, мы подсовываем ему фейк
    if typeof(args[1]) == "function" then
        local env = getfenv(args[1])
        if env and env.KIRO_PROTECTED then
            return "C", "C", 1, 1 -- Притворяемся нативной C-функцией
        end
    end
    return oldInfo(...)
end

-- Защита от string.dump (если античит попытается выгрузить байткод)
local oldDump = string.dump
string.dump = function(func, strip)
    if getfenv(func) and getfenv(func).KIRO_PROTECTED then
        return "\27LuaS" -- Возвращаем мусор, который сломает парсер античита
    end
    return oldDump(func, strip)
end

-- =====================================================================
-- СЛОЙ 3: ВИРТУАЛЬНАЯ МАШИНА (VM) ДЛЯ ЗАПУСКА
-- =====================================================================
-- Эта функция принимает зашифрованный код, расшифровывает его
-- и запускает в изолированной среде.
function K.ExecuteProtected(encrypted_code, secret_key)
    -- 1. Расшифровываем Base64 обратно в байты
    local b64_decoded = dec(encrypted_code)
    
    -- 2. Расшифровываем XOR
    local raw_code = xor(b64_decoded, secret_key)
    
    -- 3. Создаем изолированную среду (Sandbox)
    local sandbox = setmetatable({}, {__index = getgenv()})
    sandbox.KIRO_PROTECTED = true
    sandbox.script = script
    sandbox.shared = shared
    
    -- 4. Компилируем и запускаем
    local func, err = loadstring(raw_code)
    if not func then
        warn("[KIRO PROTECTOR] Ошибка декомпиляции: " .. tostring(err))
        return
    end
    
    setfenv(func, sandbox)
    local success, runErr = pcall(func)
    if not success then
        warn("[KIRO PROTECTOR] Ошибка выполнения: " .. tostring(runErr))
    end
end

-- =====================================================================
-- СЛОЙ 4: ГЕНЕРАТОР ШИФРОВ (Только для разработчика)
-- =====================================================================
-- Этот блок выполняется только если ты захочешь зашифровать новый скрипт.
-- В боевом режиме он не используется.
function K.EncryptCode(plain_code, key)
    local xored = xor(plain_code, key)
    local encoded = enc(xored)
    return encoded
end

-- =====================================================================
-- СЛОЙ 5: АНТИ-ХУК (Защита от перехвата)
-- =====================================================================
local oldHook
if hookfunction then
    oldHook = hookfunction
    hookfunction = function(original, replacement)
        if typeof(original) == "function" and getfenv(original).KIRO_PROTECTED then
            -- Если кто-то пытается захукать наш протектор, мы игнорируем это
            return original
        end
        return oldHook(original, replacement)
    end
end

print("[KIRO PROTECTOR] Защита уровня Moonsec активирована.")
