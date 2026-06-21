-- =============================================
--  POTATO AIM v5.0 - NEON EDITION (ARCEUS X)
--  Full GUI with ALL toggles + style overhaul
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- === CONFIG ===
local config = {
    TARGET_NAME = nil,
    SMOOTH_MODE = true,
    SMOOTH_SPEED = 0.35,
    ESP_ENABLED = true,
    WALL_CHECK = true,
    TEAM_CHECK = true,
    AIMLOCK_ACTIVE = false,
}

-- === CREATE STYLISH GUI ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PotatoAimlockGUI"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 380)
mainFrame.Position = UDim2.new(0, 20, 0, 80)
mainFrame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.1)
mainFrame.BackgroundTransparency = 0.25
mainFrame.BorderSizePixel = 3
mainFrame.BorderColor3 = Color3.new(0.8, 0.2, 0.8)  -- neon purple
mainFrame.ClipsDescendants = true
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Rounded corners via UICorner (if supported) - fallback to border
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Title bar with gradient effect
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 36)
title.BackgroundColor3 = Color3.new(0.2, 0.05, 0.2)
title.Text = "🥔 POTATO AIM v5.0"
title.TextColor3 = Color3.new(1, 0.6, 1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.BorderSizePixel = 0
title.Parent = mainFrame

-- Separator line
local line = Instance.new("Frame")
line.Size = UDim2.new(0.95, 0, 0, 2)
line.Position = UDim2.new(0.025, 0, 0, 36)
line.BackgroundColor3 = Color3.new(0.8, 0.2, 0.8)
line.Parent = mainFrame

-- === HELPER: MODERN TOGGLE BUTTON ===
local function makeToggle(text, yPos, getter, setter)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 34)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.new(0.15, 0.15, 0.25)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Text = text .. (getter() and " ✅" or " ❌")
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.BorderSizePixel = 2
    btn.BorderColor3 = getter() and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
    btn.Parent = mainFrame
    
    -- Hover effect
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.new(0.25, 0.25, 0.4)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.new(0.15, 0.15, 0.25)
    end)
    
    btn.MouseButton1Click:Connect(function()
        setter(not getter())
        btn.Text = text .. (getter() and " ✅" or " ❌")
        btn.BorderColor3 = getter() and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
    end)
    return btn
end

-- === ALL TOGGLES (EVERY SINGLE ONE) ===
local aimBtn = makeToggle("🔫 AIMLOCK", 42,
    function() return config.AIMLOCK_ACTIVE end,
    function(v) config.AIMLOCK_ACTIVE = v end
)

local smoothBtn = makeToggle("🌀 SMOOTH", 80,
    function() return config.SMOOTH_MODE end,
    function(v) config.SMOOTH_MODE = v end
)

local espBtn = makeToggle("👁️ ESP", 118,
    function() return config.ESP_ENABLED end,
    function(v) config.ESP_ENABLED = v end
)

local wallBtn = makeToggle("🧱 WALL CHECK", 156,
    function() return config.WALL_CHECK end,
    function(v) config.WALL_CHECK = v end
)

local teamBtn = makeToggle("🤝 TEAM CHECK", 194,
    function() return config.TEAM_CHECK end,
    function(v) config.TEAM_CHECK = v end
)

-- === SMOOTH SPEED SLIDER (with glow) ===
local sliderFrame = Instance.new("Frame")
sliderFrame.Size = UDim2.new(0.9, 0, 0, 40)
sliderFrame.Position = UDim2.new(0.05, 0, 0, 234)
sliderFrame.BackgroundTransparency = 1
sliderFrame.Parent = mainFrame

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.5, 0, 1, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "SPEED: " .. tostring(config.SMOOTH_SPEED)
speedLabel.TextColor3 = Color3.new(1, 0.8, 1)
speedLabel.TextScaled = true
speedLabel.Font = Enum.Font.GothamBold
speedLabel.Parent = sliderFrame

local sliderTrack = Instance.new("Frame")
sliderTrack.Size = UDim2.new(0.45, 0, 0.4, 0)
sliderTrack.Position = UDim2.new(0.5, 0, 0.3, 0)
sliderTrack.BackgroundColor3 = Color3.new(0.3, 0.3, 0.5)
sliderTrack.BorderSizePixel = 1
sliderTrack.BorderColor3 = Color3.new(0.8, 0.2, 0.8)
sliderTrack.Parent = sliderFrame

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new((config.SMOOTH_SPEED - 0.05) / 0.85, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.new(0.8, 0.2, 0.8)
sliderFill.Parent = sliderTrack

local function updateSlider(val)
    val = math.clamp(val, 0.05, 0.9)
    val = math.round(val / 0.05) * 0.05
    config.SMOOTH_SPEED = val
    speedLabel.Text = "SPEED: " .. tostring(val)
    sliderFill.Size = UDim2.new((val - 0.05) / 0.85, 0, 1, 0)
end

sliderTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        local conn, connEnd
        conn = UserInputService.InputChanged:Connect(function(input2)
            if input2.UserInputType == Enum.UserInputType.Touch or input2.UserInputType == Enum.UserInputType.MouseMovement then
                local pos = input2.Position
                local relX = (pos.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X
                updateSlider(0.05 + relX * 0.85)
            end
        end)
        connEnd = UserInputService.InputEnded:Connect(function(input3)
            if input3 == input then
                conn:Disconnect()
                connEnd:Disconnect()
            end
        end)
    end
end)

-- === CORE AIMLOCK + ESP (same logic, uses config) ===
local espObjects = {}

local function isEnemy(player)
    if player == LocalPlayer then return false end
    if config.TARGET_NAME and player.Name ~= config.TARGET_NAME then return false end
    if not config.TEAM_CHECK then return true end
    local myTeam = LocalPlayer.Team
    local theirTeam = player.Team
    if myTeam and theirTeam then return myTeam ~= theirTeam end
    return true  -- neutral or mismatch = enemy
end

local function getClosestEnemy()
    local closest, dist = nil, math.huge
    local camPos = Camera.CFrame.Position
    for _, plr in pairs(Players:GetPlayers()) do
        if not isEnemy(plr) then continue end
        local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        if plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health <= 0 then continue end
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

-- ESP drawing (only for enemies)
local function createESP(plr)
    if not config.ESP_ENABLED or not isEnemy(plr) then
        if espObjects[plr] then
            for _, obj in pairs(espObjects[plr]) do obj:Remove() end
            espObjects[plr] = nil
        end
        return
    end
    if espObjects[plr] then return end
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Color = Color3.new(1, 0.2, 0.8)
    box.Filled = false
    local healthBar = Drawing.new("Line")
    healthBar.Thickness = 4
    healthBar.Color = Color3.new(0, 1, 0)
    local nameTag = Drawing.new("Text")
    nameTag.Size = 16
    nameTag.Color = Color3.new(1, 1, 1)
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
        objs.box.Size = Vector2.new(size * 2.2, size * 3.2)
        objs.box.Position = Vector2.new(x - size * 1.1, y - size * 1.6)
        local hp = plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth
        objs.healthBar.Visible = true
        objs.healthBar.From = Vector2.new(x - size, y + size * 1.9)
        objs.healthBar.To = Vector2.new(x - size + size * 2 * hp, y + size * 1.9)
        objs.healthBar.Color = Color3.new(1 - hp, hp, 0)
        objs.nameTag.Visible = true
        objs.nameTag.Position = Vector2.new(x, y - size * 2.5)
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
            if plr ~= LocalPlayer then createESP(plr) end
        end
        updateESP()
    else
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

print("🥔 POTATO AIM v5.0 - NEON EDITION LOADED. All toggles visible & stylish.")
