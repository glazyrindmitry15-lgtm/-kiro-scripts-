-- KIRO HACK | ESP CORE (FULL)
local K = shared.KIRO
if not K then return end
if not K.GetSetting then K.GetSetting = function(path) return nil end end
if not K.SetSetting then K.SetSetting = function(path, v) end end
if not K.Notify then K.Notify = function(title, text, ntype) end end
local RunService = game:GetService("RunService")
local Camera, Settings = K.Camera, K.Settings

local function DrawESP()
    if not Settings.ESP.Enabled or K.MenuOpen or K.Loading then
        for _, d in pairs(K.ESPObjects) do for _, v in pairs(d) do pcall(function() v.Visible = false end) end end
        for _, h in pairs(K.Highlights) do pcall(function() h.Enabled = false end) end
        if K.MenuOpen or K.Loading then return end
        for _, h in pairs(K.Highlights) do if h and h.Parent then h:Destroy() end end
        K.Highlights = {}; return
    end
    
    local active = {}
    for _, t in ipairs(K.CachedTargets) do
        if t.obj and t.obj.Parent and t.hrp and t.hrp.Parent and t.head and t.head.Parent and t.hum and t.hum.Health > 0 then
            active[t.obj] = true
            if not K.ESPObjects[t.obj] then
                K.ESPObjects[t.obj] = {
                    Box=Drawing.new("Square"), Name=Drawing.new("Text"), Dist=Drawing.new("Text"), Weapon=Drawing.new("Text"),
                    HShadow=Drawing.new("Square"), HBg=Drawing.new("Square"), HBar=Drawing.new("Square"), HText=Drawing.new("Text"),
                    Tracer=Drawing.new("Line"),
                    SkelHead=Drawing.new("Line"), SkelLArm=Drawing.new("Line"), SkelRArm=Drawing.new("Line"),
                    SkelLLeg=Drawing.new("Line"), SkelRLeg=Drawing.new("Line")
                }
                local d = K.ESPObjects[t.obj]
                d.Box.Filled = false; d.Box.Thickness = 1
                d.Name.Center = true; d.Name.Outline = true; d.Name.Size = 20; d.Name.Font = Drawing.Fonts.SystemBold; d.Name.OutlineColor = Color3.new(0,0,0)
                d.Dist.Center = true; d.Dist.Outline = true; d.Dist.Size = 16; d.Dist.Font = Drawing.Fonts.SystemBold; d.Dist.OutlineColor = Color3.new(0,0,0)
                d.Weapon.Center = true; d.Weapon.Outline = true; d.Weapon.Size = 16; d.Weapon.Font = Drawing.Fonts.SystemBold; d.Weapon.OutlineColor = Color3.new(0,0,0)
                d.HShadow.Filled = true; d.HBg.Filled = true; d.HBar.Filled = true
                d.HText.Center = true; d.HText.Font = Drawing.Fonts.SystemBold; d.HText.Size = 12; d.HText.Outline = true; d.HText.OutlineColor = Color3.new(0,0,0)
                for _, n in ipairs({"SkelHead","SkelLArm","SkelRArm","SkelLLeg","SkelRLeg"}) do d[n].Thickness = 1.5; d[n].Visible = false end
            end
            
            local d = K.ESPObjects[t.obj]
            local sp, on = Camera:WorldToViewportPoint(t.hrp.Position)
            local sh, hv = Camera:WorldToViewportPoint(t.hrp.Position + Vector3.new(0,3,0))
            local dist = math.floor((Camera.CFrame.Position - t.hrp.Position).Magnitude)
            local valid = on and hv and sp.Z > 0 and dist > 2 and dist <= Settings.ESP.MaxDist
            local col = Color3.fromRGB(table.unpack(Settings.ESP.Color))
            
            -- Подсветка (Chams)
            if Settings.ESP.Highlight then
                if not K.Highlights[t.obj] then
                    local h = Instance.new("Highlight"); h.OutlineColor = Color3.fromRGB(255,255,255); h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; h.Parent = t.obj; K.Highlights[t.obj] = h
                end
                K.Highlights[t.obj].Enabled = true; K.Highlights[t.obj].FillColor = col; K.Highlights[t.obj].FillTransparency = Settings.ESP.ChamsTransparency
            elseif K.Highlights[t.obj] then K.Highlights[t.obj]:Destroy(); K.Highlights[t.obj] = nil end
            
            if valid then
                local hh = math.clamp(4000/dist, 40, 200); local ww = hh * 0.55
                
                d.Box.Color = col; d.Box.Position = Vector2.new(sp.X-ww/2, sp.Y-hh/2); d.Box.Size = Vector2.new(ww, hh); d.Box.Visible = Settings.ESP.Box
                d.Name.Color = col; d.Name.Text = t.name; d.Name.Position = Vector2.new(sh.X, sh.Y-22); d.Name.Visible = Settings.ESP.Name
                d.Dist.Color = Color3.fromRGB(220,220,220); d.Dist.Text = dist .. "m"; d.Dist.Position = Vector2.new(sh.X, sh.Y); d.Dist.Visible = Settings.ESP.Distance
                
                local tool = t.obj:FindFirstChildOfClass("Tool")
                d.Weapon.Color = Color3.fromRGB(255,200,0); d.Weapon.Text = tool and ("[" .. tool.Name .. "]") or ""; d.Weapon.Position = Vector2.new(sh.X, sh.Y+18)
                d.Weapon.Visible = Settings.ESP.Weapon and tool ~= nil
                
                -- Трейсеры
                if Settings.ESP.Tracer then
                    d.Tracer.Color = col; d.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y); d.Tracer.To = Vector2.new(sp.X, sp.Y); d.Tracer.Visible = true
                else d.Tracer.Visible = false end
                
                -- Здоровье
                if Settings.ESP.Health then
                    local maxHp = t.hum.MaxHealth or 100; if maxHp <= 0 then maxHp = math.max(t.hum.Health or 0, 100) end
                    local curHp = math.max(t.hum.Health or 0, 0); local hpPct = math.clamp(curHp / maxHp, 0, 1)
                    local hbW = 6; local hbG = 8; local barX = sp.X - ww/2 - hbG - hbW; local barY = sp.Y - hh/2
                    
                    d.HShadow.Size = Vector2.new(hbW+4, hh+4); d.HShadow.Position = Vector2.new(barX-2, barY-2); d.HShadow.Visible = true
                    if hpPct < 0.3 and hpPct > 0 then
                        local pulse = 0.5 + math.sin(tick()*6)*0.3
                        d.HShadow.Color = Color3.fromRGB(255,60,60); d.HShadow.Transparency = 1 - pulse
                    else d.HShadow.Color = Color3.fromRGB(0,0,0); d.HShadow.Transparency = 0.5 end
                    
                    d.HBg.Size = Vector2.new(hbW, hh); d.HBg.Position = Vector2.new(barX, barY); d.HBg.Color = Color3.fromRGB(20,20,25); d.HBg.Visible = true
                    if hpPct > 0 then
                        local fillH = hpPct * (hh - 2)
                        local fillCol = hpPct > 0.6 and Color3.fromRGB(80,230,120) or (hpPct > 0.3 and Color3.fromRGB(255,210,80) or Color3.fromRGB(255,70,70))
                        d.HBar.Size = Vector2.new(hbW-2, fillH); d.HBar.Position = Vector2.new(barX+1, barY+1+(hh-2-fillH)); d.HBar.Color = fillCol; d.HBar.Visible = true
                    else d.HBar.Visible = false end
                    
                    if Settings.ESP.HealthNum then d.HText.Text = tostring(math.floor(curHp)); d.HText.Color = Color3.fromRGB(255,255,255); d.HText.Position = Vector2.new(barX+hbW/2, barY-14); d.HText.Visible = true
                    else d.HText.Visible = false end
                else d.HShadow.Visible = false; d.HBg.Visible = false; d.HBar.Visible = false; d.HText.Visible = false end
                
                -- Скелет
                if Settings.ESP.Skeleton then
                    local function gp(n)
                        local p = t.obj:FindFirstChild(n)
                        if p then local ps, os = Camera:WorldToViewportPoint(p.Position); if os then return Vector2.new(ps.X, ps.Y) end end
                        return nil
                    end
                    local hp_ = gp("Head"); local tp = gp("UpperTorso") or gp("Torso")
                    local la = gp("LeftUpperArm") or gp("LeftArm"); local ra = gp("RightUpperArm") or gp("RightArm")
                    local ll = gp("LeftUpperLeg") or gp("LeftLeg"); local rl = gp("RightUpperLeg") or gp("RightLeg")
                    if hp_ and tp then
                        d.SkelHead.From = hp_; d.SkelHead.To = tp; d.SkelHead.Color = col; d.SkelHead.Visible = true
                        if la then d.SkelLArm.From = tp; d.SkelLArm.To = la; d.SkelLArm.Color = col; d.SkelLArm.Visible = true else d.SkelLArm.Visible = false end
                        if ra then d.SkelRArm.From = tp; d.SkelRArm.To = ra; d.SkelRArm.Color = col; d.SkelRArm.Visible = true else d.SkelRArm.Visible = false end
                        if ll then d.SkelLLeg.From = tp; d.SkelLLeg.To = ll; d.SkelLLeg.Color = col; d.SkelLLeg.Visible = true else d.SkelLLeg.Visible = false end
                        if rl then d.SkelRLeg.From = tp; d.SkelRLeg.To = rl; d.SkelRLeg.Color = col; d.SkelRLeg.Visible = true else d.SkelRLeg.Visible = false end
                    else for _, n in ipairs({"SkelHead","SkelLArm","SkelRArm","SkelLLeg","SkelRLeg"}) do d[n].Visible = false end end
                else for _, n in ipairs({"SkelHead","SkelLArm","SkelRArm","SkelLLeg","SkelRLeg"}) do d[n].Visible = false end end
            else
                d.Box.Visible = false; d.Name.Visible = false; d.Dist.Visible = false; d.Weapon.Visible = false; d.Tracer.Visible = false
                d.HShadow.Visible = false; d.HBg.Visible = false; d.HBar.Visible = false; d.HText.Visible = false
                for _, n in ipairs({"SkelHead","SkelLArm","SkelRArm","SkelLLeg","SkelRLeg"}) do d[n].Visible = false end
            end
        end
    end
    for obj, d in pairs(K.ESPObjects) do
        if not active[obj] then for _, v in pairs(d) do pcall(function() v:Remove() end) end; K.ESPObjects[obj] = nil end
    end
    for obj, h in pairs(K.Highlights) do if not active[obj] then h:Destroy(); K.Highlights[obj] = nil end end
end

RunService.RenderStepped:Connect(function() pcall(DrawESP) end)
print("[KIRO ESP] Загружено (FULL).")