local K = shared.KIRO
if not K then return end
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- Speed (BodyVelocity to avoid rubber-banding)
local speedBV = nil
RunService.Heartbeat:Connect(function()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    if K.GetSetting("Misc.Speed") then
        -- используем BodyVelocity для плавного ускорения без отката
        if not speedBV or not speedBV.Parent then
            speedBV = Instance.new("BodyVelocity")
            speedBV.MaxForce = Vector3.new(1e5, 0, 1e5)
            speedBV.Velocity = Vector3.new(0, 0, 0)
            speedBV.Parent = hrp
        end
        local cam = workspace.CurrentCamera
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            local speed = K.GetSetting("Misc.SpeedValue") or 32
            speedBV.Velocity = moveDir * speed
        else
            speedBV.Velocity = Vector3.new(0, 0, 0)
        end
        hum.WalkSpeed = 16 -- держим стандартную, чтобы сервер не откатывал
    else
        if speedBV then speedBV:Destroy(); speedBV = nil end
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed ~= 16 then hum.WalkSpeed = 16 end
    end
    if K.GetSetting("Misc.Noclip") then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

-- Fly
local flying = false
local flyBV, flyBG
RunService.RenderStepped:Connect(function()
    if K.GetSetting("Misc.Fly") then
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if not flying then
            flying = true
            flyBV = Instance.new("BodyVelocity")
            flyBV.Velocity = Vector3.new(0,0,0)
            flyBV.MaxForce = Vector3.new(1e9,1e9,1e9)
            flyBV.Parent = hrp
            flyBG = Instance.new("BodyGyro")
            flyBG.MaxTorque = Vector3.new(1e9,1e9,1e9)
            flyBG.CFrame = hrp.CFrame
            flyBG.Parent = hrp
        end
        local cam = workspace.CurrentCamera
        local move = Vector3.new()
        if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0,1,0) end
        flyBV.Velocity = move * (K.GetSetting("Misc.FlySpeed") or 50)
        flyBG.CFrame = cam.CFrame
    else
        if flying then
            flying = false
            if flyBV then flyBV:Destroy(); flyBV = nil end
            if flyBG then flyBG:Destroy(); flyBG = nil end
        end
    end
end)

-- Infinite Jump
UIS.JumpRequest:Connect(function()
    if K.GetSetting("Misc.InfiniteJump") then
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Anti-AFK
task.spawn(function()
    local vu = game:GetService("VirtualUser")
    LP.Idled:Connect(function()
        if K.GetSetting("Misc.AntiAFK") then
            pcall(function() vu:CaptureController(); vu:ClickButton2(Vector2.new()) end)
        end
    end)
end)

print("[KIRO MISC] Модуль загружен.")
