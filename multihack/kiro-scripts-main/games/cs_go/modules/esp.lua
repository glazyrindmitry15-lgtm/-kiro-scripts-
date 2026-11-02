local K = shared.KIRO
if not K or not Drawing then return end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer
local objs = {}

RunService.RenderStepped:Connect(function()
    if not K.GetSetting("ESP.Enabled") then
        for _, o in pairs(objs) do o.Visible = false end
        return
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
            if K.GetSetting("ESP.TeamCheck") and p.Team == LP.Team then continue end
            local head = p.Character.Head
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                if not objs[p] then
                    objs[p] = Drawing.new("Text")
                    objs[p].Size = 14; objs[p].Center = true; objs[p].Outline = true
                end
                objs[p].Visible = K.GetSetting("ESP.Name")
                objs[p].Text = p.Name
                objs[p].Position = Vector2.new(pos.X, pos.Y - 20)
                objs[p].Color = K.GetSetting("ESP.Color")
            elseif objs[p] then objs[p].Visible = false end
        end
    end
end)
print("[KIRO ESP] Загружено.")
