-- rpc.lua | Kiro Scripts - Discord Rich Presence (BloxstrapRPC)
local env = (getgenv and getgenv()) or _G or shared
local K = env.K or _G.K or shared.K or {}
env.K = K
_G.K = K

K.Settings = K.Settings or {}
K.Settings.Misc = K.Settings.Misc or {}
if K.Settings.Misc.RPC == nil then K.Settings.Misc.RPC = true end

if type(K.GetSetting) ~= "function" then
    function K.GetSetting(path)
        if type(path) ~= "string" then return nil end
        if K.Settings[path] ~= nil then return K.Settings[path] end
        local current = K.Settings
        for part in string.gmatch(path, "[^%.]+") do
            if type(current) == "table" and current[part] ~= nil then
                current = current[part]
            else return nil end
        end
        return current
    end
end

if type(K.SetSetting) ~= "function" then
    function K.SetSetting(path, value)
        if type(path) ~= "string" then return end
        K.Settings[path] = value
        local parts = {}
        for part in string.gmatch(path, "[^%.]+") do table.insert(parts, part) end
        local current = K.Settings
        for i = 1, #parts - 1 do
            local key = parts[i]
            if type(current[key]) ~= "table" then current[key] = {} end
            current = current[key]
        end
        current[parts[#parts]] = value
    end
end

local function G(path, default)
    local v = K.GetSetting(path)
    if v == nil then return default end
    return v
end

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local lastRPCUpdate = 0
local RPC_INTERVAL = 15 -- 15 seconds rate limit

local function getGameName()
    local id = K.GameId or "unknown"
    if id == "fust" then return "FUST" end
    if id == "cs_go" then return "CS:GO" end
    if id == "valiant_district" then return "Valiant District" end
    return "Unknown"
end

local function sendRPC()
    if not G("Misc.RPC", true) then return end
    
    local now = tick()
    if now - lastRPCUpdate < RPC_INTERVAL then return end
    lastRPCUpdate = now

    local gameName = getGameName()
    local payload = {
        details = "Играет с KIRO HACK v1.2.0",
        state = "[" .. gameName .. "]",
        largeImage = "https://raw.githubusercontent.com/glazyrindmitry15-lgtm/-kiro-scripts-/main/chatmost_ru_1793693416810.png",
        largeText = "KIRO HACK",
        smallImage = "",
        smallText = "",
        buttons = {}
    }

    local json = HttpService:JSONEncode(payload)
    local rpcString = "[BloxstrapRPC] " .. json
    
    print(rpcString)
end

task.spawn(function()
    while task.wait(RPC_INTERVAL) do
        pcall(sendRPC)
    end
end)

print("[KIRO RPC] BloxstrapRPC module loaded. Game: " .. (K.GameId or "unknown"))
return K