-- =====================================================================
-- CONFIG SYSTEM | Save/Load Settings
-- =====================================================================
local K = shared.KIRO
if not K then return end
if not K.GetSetting then K.GetSetting = function(path) return nil end end
if not K.SetSetting then K.SetSetting = function(path, v) end end
if not K.Notify then K.Notify = function(title, text, ntype) end end

local HttpService = game:GetService("HttpService")

local CONFIG_FILE = "kiro_config_" .. (K.GameId or "default") .. ".json"

function K.SaveConfig()
    local ok, err = pcall(function()
        local data = HttpService:JSONEncode(K.Settings)
        writefile(CONFIG_FILE, data)
    end)
    if ok then
        if K.Notify then K.Notify("Config", "Saved to " .. CONFIG_FILE, "success") end
    else
        if K.Notify then K.Notify("Config", "Save failed: " .. tostring(err), "error") end
    end
    return ok
end

function K.LoadConfig()
    local ok, err = pcall(function()
        if isfile and isfile(CONFIG_FILE) then
            local data = readfile(CONFIG_FILE)
            local decoded = HttpService:JSONDecode(data)
            if decoded then
                -- merge decoded into K.Settings
                for k, v in pairs(decoded) do
                    if type(v) == "table" and type(K.Settings[k]) == "table" then
                        for k2, v2 in pairs(v) do
                            K.Settings[k][k2] = v2
                        end
                    else
                        K.Settings[k] = v
                    end
                end
            end
        end
    end)
    if ok then
        if K.Notify then K.Notify("Config", "Loaded from " .. CONFIG_FILE, "success") end
    else
        if K.Notify then K.Notify("Config", "Load failed: " .. tostring(err), "error") end
    end
    return ok
end

-- Auto-load on start
task.spawn(function()
    task.wait(1)
    K.LoadConfig()
end)

print("[KIRO CONFIG] Config system loaded.")
