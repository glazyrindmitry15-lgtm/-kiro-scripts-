-- debugger.lua | Kiro Scripts System Debugger
local Players = game:GetService("Players")
local ScriptContext = game:GetService("ScriptContext")
local RunService = game:GetService("RunService")

local env = (getgenv and getgenv()) or _G or shared
local K = env.K or _G.K or shared.K or {}
env.K = K
_G.K = K

K.LoadedModules = K.LoadedModules or {}
K.ErrorLog = K.ErrorLog or {}

-- Функция логирования ошибки модуля
function K.LogError(moduleName, errorMessage, stackTrace)
    K.ErrorLog[moduleName] = {
        message = tostring(errorMessage),
        stack = tostring(stackTrace or "No stack trace"),
        time = os.date("%H:%M:%S"),
        tick = tick()
    }
    K.LoadedModules[moduleName] = {
        status = "FAILED",
        error = tostring(errorMessage),
        loadTime = tick()
    }
    warn(string.format("[KIRO DEBUGGER] Module '%s' crashed: %s", moduleName, errorMessage))
end

-- Функция отметки успешной загрузки
function K.LogSuccess(moduleName)
    K.LoadedModules[moduleName] = {
        status = "OK",
        loadTime = tick()
    }
    K.ErrorLog[moduleName] = nil
end

-- Перехват ошибок ScriptContext (краши скриптов)
ScriptContext.Error:Connect(function(message, stackTrace, scriptInstance)
    local moduleName = "Unknown"
    if scriptInstance then
        -- Пытаемся определить имя модуля из пути скрипта
        local fullName = scriptInstance:GetFullName()
        moduleName = fullName:match("modules%.([^%.]+)") or fullName:match("%.([^%.]+)$") or fullName
    end

    -- Логируем в общий лог
    table.insert(K.ErrorLog, {
        module = moduleName,
        message = tostring(message),
        stack = tostring(stackTrace),
        time = os.date("%H:%M:%S"),
        tick = tick()
    })

    -- Обновляем статус модуля
    K.LoadedModules[moduleName] = {
        status = "FAILED",
        error = tostring(message),
        stack = tostring(stackTrace),
        loadTime = tick()
    }

    warn(string.format("[KIRO DEBUGGER] Runtime error in '%s': %s", moduleName, message))
end)

-- Функция безопасной загрузки модуля с отловом ошибок
function K.SafeLoadModule(moduleName, loadFunction)
    local success, result = pcall(loadFunction)
    if success then
        K.LogSuccess(moduleName)
        return true, result
    else
        K.LogError(moduleName, result, debug.traceback())
        return false, result
    end
end

-- Очистка консоли
function K.ClearConsole()
    K.ErrorLog = {}
    K.LoadedModules = {}
end

-- Экспорт для UI
K.Debugger = {
    LogError = K.LogError,
    LogSuccess = K.LogSuccess,
    SafeLoadModule = K.SafeLoadModule,
    ClearConsole = K.ClearConsole,
    GetModules = function() return K.LoadedModules end,
    GetErrors = function() return K.ErrorLog end,
}

print("[KIRO DEBUGGER] System debugger loaded.")
return K