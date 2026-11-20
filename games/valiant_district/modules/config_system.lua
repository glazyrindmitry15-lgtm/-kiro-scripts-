-- =====================================================================
-- CONFIG SYSTEM | Save/Load Settings
-- =====================================================================
local K = shared.KIRO
if not K then return end
if not K.Notify then K.Notify = function(title, text, ntype) end end

local HttpService = game:GetService("HttpService")

local CONFIG_FILE = "kiro_config_" .. (K.GameId or "default") .. ".json"

-- Paths that store Enum.KeyCode values
local enumPaths = {
    ["Camera.ZoomKey"] = true,
    ["Camera.CustomFOV"] = false,
    ["Keybinds.Menu"] = true,
    ["Keybinds.ESP"] = true,
    ["Keybinds.Aimbot"] = true,
    ["Keybinds.Fly"] = true,
    ["Keybinds.Speed"] = true,
    ["Keybinds.Noclip"] = true,
    ["Keybinds.AutoRepair"] = true,
    ["Keybinds.Zoom"] = true,
}

local function convToSave(t)
    local out = {}
    for k, v in pairs(t) do
        if typeof(v) == "EnumItem" then
            out[k] = v.Name
        elseif type(v) == "table" then
            out[k] = convToSave(v)
        else
            out[k] = v
        end
    end
    return out
end

local function convToLoad(t, pathPrefix)
    pathPrefix = pathPrefix or ""
    local out = {}
    for k, v in pairs(t) do
        local fullPath = pathPrefix .. (pathPrefix ~= "" and "." or "") .. k
        if type(v) == "table" then
            out[k] = convToLoad(v, fullPath)
        elseif type(v) == "string" and enumPaths[fullPath] then
            out[k] = Enum.KeyCode[v]
        else
            out[k] = v
        end
    end
    return out
end

function K.SaveConfig()
    local ok, err = pcall(function()
        local data = HttpService:JSONEncode(convToSave(K.Settings))
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
                decoded = convToLoad(decoded)
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