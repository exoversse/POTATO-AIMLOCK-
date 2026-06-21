-- POTATO'S AIMLOCK + ESP WITH TEAM CHECK (ARCEUS X MOBILE/PC)
-- GUI: Drag by title. Team Check ON = only targets enemies.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- === CONFIG (GUI-modifiable) ===
local config = {
    TARGET_NAME = nil,
    SMOOTH_MODE = true,
    SMOOTH_SPEED = 0.35,
    ESP_ENABLED = true,
    WALL_CHECK = true,
    TEAM_CHECK = true,      -- <-- NEW: only target enemies
    AIMLOCK_ACTIVE = false,
}

-- === CREATE GUI ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PotatoAimlockGUI"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 320)  -- taller for new button
mainFrame.Position = UDim2.new(0, 20, 0, 100)
mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.15)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.new(0.8, 0.2, 0.2)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.new(0.2, 0.05, 0.05)
title.Text = "🥔 POTATO AIM v4.0"
title.TextColor3 = Color3.new(1, 0.8, 0.2)
title.TextScaled = true
title.Font = Enum.Font.Bold
title.Parent = mainFrame

local function makeButton(text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.new(0.2, 0.2, 0.3)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Text = text
    btn.Font = Enum.Font.SourceSansBold
    btn.TextScaled = true
    btn.Parent = mainFrame
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function makeSlider(text, yPos, minVal, maxVal, step, getter, setter)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 35)
    frame.Position = UDim2.new(0.05, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = mainFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. tostring(getter())
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.SourceSans
    label.Parent = frame

    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.45, 0, 0.5, 0)
    slider.Position = UDim2.new(0.5, 0, 0.25, 0)
    slider.BackgroundColor3 = Color3.new(0.3, 0.3, 0.4)
    slider.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((getter() - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    fill.Parent = slider

    local function updateSlider(val)
        val = math.clamp(val, minVal, maxVal)
        val = math.round(val / step) * step
        setter(val)
        label.Text = text .. ": " .. tostring(val)
        fill.Size = UDim2.new((val - minVal) / (maxVal - minVal), 0, 1, 0)
    end

    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            local conn
            conn = UserInputService.InputChanged:Connect(function(input2)
                if input2.UserInputType == Enum.UserInputType.Touch or input2.UserInputType == Enum.UserInputType.MouseMovement then
                    local pos = input2.Position
                    local relX = (pos.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X
                    updateSlider(minVal + relX * (maxVal - minVal))
                end
            end)
            local connEnd
            connEnd = UserInputService.InputEnded:Connect(function(input3)
                if input3 == input then
                    conn:Disconnect()
                    connEnd:Disconnect()
                end
            end)
        end
    end)
    return frame
end

-- === GUI BUTTONS ===
local aimBtn = makeButton("🔴 AIMLOCK: OFF", 35, function()
    config.AIMLOCK_ACTIVE = not config.AIMLOCK_ACTIVE
    aimBtn.Text = config.AIMLOCK_ACTIVE and "🟢 AIMLOCK: ON" or "🔴 AIMLOCK: OFF"
end)

local smoothBtn = makeButton("🌀 SMOOTH: ON", 70, function()
    config.SMOOTH_MODE = not config.SMOOTH_MODE
    smoothBtn.Text = config.SMOOTH_MODE and "🌀 SMOOTH: ON" or "⚡ INSTANT: ON"
end)

local espBtn = makeButton("👁️ ESP: ON", 105, function()
    config.ESP_ENABLED = not config.ESP_ENABLED
    espBtn.Text = config.ESP_ENABLED and "👁️ ESP: ON" or "🚫 ESP: OFF"
end)

local wallBtn = makeButton("🧱 WALL CHECK: ON", 140, function()
    config.WALL_CHECK = not config.WALL_CHECK
    wallBtn.Text = config.WALL_CHECK and "🧱 WALL CHECK: ON" or "🔓 WALL CHECK: OFF"
end)

-- NEW: Team check button
local teamBtn = makeButton("🤝 TEAM CHECK: ON", 175, function()
    config.TEAM_CHECK = not config.TEAM_CHECK
    teamBtn.Text = config.TEAM_CHECK and "🤝 TEAM CHECK: ON" or "⚔️ TEAM CHECK: OFF"
end)

-- Smooth speed slider (moved down)
makeSlider("SPEED", 215, 0.05, 0.9, 0.05,
    function() return config.SMOOTH_SPEED end,
    function(val) config.SMOOTH_SPEED = val end
)

-- === CORE LOGIC with TEAM CHECK ===
local espObjects = {}

local function isEnemy(player)
    if player == LocalPlayer then return false end
    if config.TARGET_NAME and player.Name ~= config.TARGET_NAME then return false end
    if not config.TEAM_CHECK then return true end
    -- Team check: compare team values (nil = neutral, treat as enemy if you have a team)
    local myTeam = LocalPlayer.Team
    local theirTeam = player.Team
    if myTeam and theirTeam then
        return myTeam ~= theirTeam
    elseif myTeam and not theirTeam then
        return true  -- you have a team, they don't -> enemy
    elseif not myTeam and theirTeam then
        return true  -- they have a team, you don't -> enemy
    else
        return true  -- both neutral -> treat as enemy (free-for-all)
    end
end

local function getClosestEnemy()
    local closest, dist = nil, math.huge
    local camPos = Camera.CFrame.Position
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if not isEnemy(plr) then continue end
        if not plr.Character or not plr.Character:FindFirstChild("Humanoid") or plr.Character.Humanoid.Health <= 0 then continue end
        local root = plr.Character:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        if config.WALL_CHECK then
            local ray = Ray.new(camPos, (root.Position - camPos).unit * 1000)
            local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
            if hit and not hit:IsDescendantOf(plr.Character) then continue end
        end
        local d = (root.Position - camPos).magnitude
        if d < dist then
            dist = d
            closest = plr
        end
    end
    return closest
end

-- ESP creation (only for enemies when TEAM_CHECK is ON)
local function createESP(plr)
    if not config.ESP_ENABLED then return end
    if not isEnemy(plr) then 
        -- Remove ESP if it exists and player is no longer enemy
        if espObjects[plr] then
            for _, obj in pairs(espObjects[plr]) do obj:Remove() end
            espObjects[plr] = nil
        end
        return 
    end
    if espObjects[plr] then return end
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Color = Color3.new(1,0,0)
    box.Filled = false
    local healthBar = Drawing.new("Line")
    healthBar.Thickness = 3
    healthBar.Color = Color3.new(0,1,0)
    local nameTag = Drawing.new("Text")
    nameTag.Size = 14
    nameTag.Color = Color3.new(1,1,1)
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.OutlineColor = Color3.new(0,0,0)
    espObjects[plr] = {box = box, healthBar = healthBar, nameTag = nameTag}
end

local function updateESP()
    for plr, objs in pairs(espObjects) do
        if not isEnemy(plr) or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character.Humanoid.Health <= 0 then
            objs.box.Visible = false
            objs.healthBar.Visible = false
            objs.nameTag.Visible = false
            continue
        end
        local root = plr.Character.HumanoidRootPart
        local pos, onScreen = Camera:WorldToScreenPoint(root.Position)
        if not onScreen then
            objs.box.Visible = false
            objs.healthBar.Visible = false
            objs.nameTag.Visible = false
            continue
        end
        local size = 4 / (pos.Z / 10)
        local x, y = pos.X, pos.Y
        objs.box.Visible = true
        objs.box.Size = Vector2.new(size * 2, size * 3)
        objs.box.Position = Vector2.new(x - size, y - size * 1.5)
        local hp = plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth
        objs.healthBar.Visible = true
        objs.healthBar.From = Vector2.new(x - size, y + size * 1.8)
        objs.healthBar.To = Vector2.new(x - size + size * 2 * hp, y + size * 1.8)
        objs.healthBar.Color = Color3.new(1 - hp, hp, 0)
        objs.nameTag.Visible = true
        objs.nameTag.Position = Vector2.new(x, y - size * 2.2)
        objs.nameTag.Text = plr.Name .. " [" .. math.floor(plr.Character.Humanoid.Health) .. "HP]"
    end
end

local function aimlock()
    if not config.AIMLOCK_ACTIVE then return end
    local plr = getClosestEnemy()
    if not plr then return end
    local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local targetPos = root.Position + Vector3.new(0, 1.5, 0)
    local camPos = Camera.CFrame.Position
    local lookVec = (targetPos - camPos).unit
    local newCF = CFrame.new(camPos, camPos + lookVec)
    if config.SMOOTH_MODE then
        Camera.CFrame = Camera.CFrame:Lerp(newCF, config.SMOOTH_SPEED)
    else
        Camera.CFrame = newCF
    end
end

RunService.RenderStepped:Connect(function()
    aimlock()
    if config.ESP_ENABLED then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                createESP(plr)
            end
        end
        updateESP()
    else
        -- Cleanup ESP if disabled
        for plr, objs in pairs(espObjects) do
            for _, obj in pairs(objs) do obj:Remove() end
            espObjects[plr] = nil
        end
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if espObjects[plr] then
        for _, obj in pairs(espObjects[plr]) do obj:Remove() end
        espObjects[plr] = nil
    end
end)

print("🥔 POTATO AIM v4.0 LOADED WITH TEAM CHECK. Drag GUI to move.")
