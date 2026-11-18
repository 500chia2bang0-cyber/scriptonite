--[[
    CART3R.JAILBREAK | MOBILE COMMAND UI
    Version: 1.0.0
    Target: Roblox Studio experience you own or are authorized to test.

    Install as a LocalScript in StarterPlayer > StarterPlayerScripts.
    This is a legitimate Studio UI/controller scaffold, not an executor script.

    Server-authoritative features:
      * Collection must be implemented by your game's server.
      * NPC test damage must be validated and rate-limited by your game's server.
      * No cooldown bypass, prompt-hold bypass, teleport farming, or anti-ban.

    Optional CollectionService tags for ESP:
      "ESP_NPC", "ESP_Boss", "ESP_Chest", "ESP_Item", "ESP_Drop"
    Optional leaderstats value:
      player.leaderstats.Money
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local CONFIG = {
    FlySpeed = 55,
    WalkSpeed = 24,
    JumpPower = 65,
    ESPMaxDistance = 1500,
    ESPRefreshRate = 0.35,
    NPCTestRange = 20,
    NPCTestRate = 1.0,
}

local COLORS = {
    Background = Color3.fromRGB(10, 10, 14),
    Panel = Color3.fromRGB(20, 18, 25),
    Panel2 = Color3.fromRGB(29, 23, 32),
    Red = Color3.fromRGB(235, 48, 65),
    RedDark = Color3.fromRGB(115, 25, 38),
    Text = Color3.fromRGB(245, 240, 243),
    Muted = Color3.fromRGB(160, 148, 158),
    Green = Color3.fromRGB(65, 210, 135),
}

local function make(className, properties, parent)
    local object = Instance.new(className)
    for key, value in pairs(properties or {}) do
        object[key] = value
    end
    object.Parent = parent
    return object
end

local function corner(parent, radius)
    make("UICorner", {CornerRadius = UDim.new(0, radius or 10)}, parent)
end

local function stroke(parent, color, thickness, transparency)
    make("UIStroke", {
        Color = color or COLORS.Red,
        Thickness = thickness or 1,
        Transparency = transparency or 0.15,
    }, parent)
end

local function addPadding(parent, amount)
    make("UIPadding", {
        PaddingTop = UDim.new(0, amount),
        PaddingBottom = UDim.new(0, amount),
        PaddingLeft = UDim.new(0, amount),
        PaddingRight = UDim.new(0, amount),
    }, parent)
end

local screen = make("ScreenGui", {
    Name = "CART3R_MobileCommandCenter",
    ResetOnSpawn = false,
    IgnoreGuiInset = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PlayerGui)

local main = make("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(0.88, 0, 0.72, 0),
    BackgroundColor3 = COLORS.Background,
    BorderSizePixel = 0,
}, screen)
main.Size = UDim2.new(0, 370, 0, 440)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.ClipsDescendants = true
corner(main, 14)
stroke(main, COLORS.Red, 1.5, 0.05)

local sizeConstraint = make("UISizeConstraint", {
    MinSize = Vector2.new(285, 340),
    MaxSize = Vector2.new(440, 620),
}, main)

local header = make("Frame", {
    Name = "Header",
    Size = UDim2.new(1, 0, 0, 48),
    BackgroundColor3 = COLORS.Panel,
    BorderSizePixel = 0,
}, main)

local title = make("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 13, 0, 0),
    Size = UDim2.new(1, -100, 1, 0),
    Font = Enum.Font.GothamBold,
    Text = "CART3R  /  MOBILE",
    TextColor3 = COLORS.Text,
    TextSize = 15,
    TextXAlignment = Enum.TextXAlignment.Left,
}, header)

local minimize = make("TextButton", {
    Name = "Minimize",
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -10, 0.5, 0),
    Size = UDim2.fromOffset(34, 30),
    BackgroundColor3 = COLORS.RedDark,
    Text = "−",
    TextColor3 = COLORS.Text,
    TextSize = 22,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = true,
}, header)
corner(minimize, 8)

local nav = make("Frame", {
    Name = "Navigation",
    Position = UDim2.new(0, 8, 0, 56),
    Size = UDim2.new(1, -16, 0, 38),
    BackgroundTransparency = 1,
}, main)

local navLayout = make("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0, 5),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, nav)

local content = make("ScrollingFrame", {
    Name = "Content",
    Position = UDim2.new(0, 8, 0, 101),
    Size = UDim2.new(1, -16, 1, -128),
    BackgroundColor3 = COLORS.Panel,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = COLORS.Red,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, main)
corner(content, 10)
addPadding(content, 10)

local contentLayout = make("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, content)

local footer = make("TextLabel", {
    Name = "Watermark",
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0.5, 0, 1, -3),
    Size = UDim2.new(1, -16, 0, 18),
    Font = Enum.Font.Gotham,
    Text = "CART3R.JAILBREAK  •  STUDIO EDITION",
    TextColor3 = COLORS.Muted,
    TextSize = 9,
}, main)

local bubble = make("TextButton", {
    Name = "FloatingBubble",
    Visible = false,
    AnchorPoint = Vector2.new(0, 0),
    Position = UDim2.new(0, 18, 0.55, 0),
    Size = UDim2.fromOffset(54, 54),
    BackgroundColor3 = COLORS.Background,
    Text = "C",
    TextColor3 = COLORS.Red,
    TextSize = 22,
    Font = Enum.Font.GothamBlack,
    ZIndex = 20,
}, screen)
corner(bubble, 27)
stroke(bubble, COLORS.Red, 2, 0)

local function clearContent()
    for _, child in ipairs(content:GetChildren()) do
        if child ~= contentLayout and child:IsA("GuiObject") then
            child:Destroy()
        end
    end
end

local function sectionLabel(text)
    return make("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 23),
        Font = Enum.Font.GothamBold,
        Text = string.upper(text),
        TextColor3 = COLORS.Red,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, content)
end

local function infoLabel(text, height)
    return make("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, height or 36),
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = COLORS.Muted,
        TextSize = 11,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, content)
end

local function actionButton(text, callback)
    local button = make("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = COLORS.Panel2,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamSemibold,
        Text = text,
        TextColor3 = COLORS.Text,
        TextSize = 12,
        AutoButtonColor = true,
    }, content)
    corner(button, 8)
    stroke(button, COLORS.RedDark, 1, 0.25)
    button.Activated:Connect(callback)
    return button
end

local function sliderRow(labelText, minValue, maxValue, initial, callback)
    local holder = make("Frame", {
        Size = UDim2.new(1, 0, 0, 58),
        BackgroundTransparency = 1,
    }, content)

    local label = make("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 22),
        Font = Enum.Font.Gotham,
        Text = labelText .. ": " .. tostring(initial),
        TextColor3 = COLORS.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, holder)

    local bar = make("Frame", {
        Position = UDim2.new(0, 0, 0, 31),
        Size = UDim2.new(1, 0, 0, 8),
        BackgroundColor3 = COLORS.Panel2,
        BorderSizePixel = 0,
    }, holder)
    corner(bar, 5)

    local fill = make("Frame", {
        Size = UDim2.new((initial - minValue) / (maxValue - minValue), 0, 1, 0),
        BackgroundColor3 = COLORS.Red,
        BorderSizePixel = 0,
    }, bar)
    corner(fill, 5)

    local knob = make("TextButton", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new((initial - minValue) / (maxValue - minValue), 0, 0.5, 0),
        Size = UDim2.fromOffset(18, 18),
        BackgroundColor3 = COLORS.Text,
        Text = "",
        AutoButtonColor = false,
    }, bar)
    corner(knob, 9)

    local dragging = false
    local function update(inputX)
        local width = math.max(bar.AbsoluteSize.X, 1)
        local alpha = math.clamp((inputX - bar.AbsolutePosition.X) / width, 0, 1)
        local value = math.floor(minValue + (maxValue - minValue) * alpha + 0.5)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, 0, 0.5, 0)
        label.Text = labelText .. ": " .. tostring(value)
        callback(value)
    end

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            update(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function getCharacterParts()
    local character = LocalPlayer.Character
    if not character then return nil end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return nil end
    return character, humanoid, root
end

-- Flight uses Roblox's normal mobile movement input and camera orientation.
local flying = false
local flyConnection
local flyAttachment
local flyVelocity
local flyOrientation

local function stopFly()
    flying = false
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    if flyVelocity then flyVelocity:Destroy(); flyVelocity = nil end
    if flyOrientation then flyOrientation:Destroy(); flyOrientation = nil end
    if flyAttachment then flyAttachment:Destroy(); flyAttachment = nil end
end

local function startFly()
    local _, humanoid, root = getCharacterParts()
    if not humanoid or not root then return end
    stopFly()
    flying = true
    humanoid:ChangeState(Enum.HumanoidStateType.Freefall)

    flyAttachment = Instance.new("Attachment")
    flyAttachment.Name = "CART3R_FlyAttachment"
    flyAttachment.Parent = root

    flyVelocity = Instance.new("LinearVelocity")
    flyVelocity.Name = "CART3R_FlyVelocity"
    flyVelocity.Attachment0 = flyAttachment
    flyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    flyVelocity.MaxForce = math.huge
    flyVelocity.VectorVelocity = Vector3.zero
    flyVelocity.Parent = root

    flyOrientation = Instance.new("AlignOrientation")
    flyOrientation.Name = "CART3R_FlyOrientation"
    flyOrientation.Attachment0 = flyAttachment
    flyOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
    flyOrientation.MaxTorque = math.huge
    flyOrientation.Responsiveness = 18
    flyOrientation.Parent = root

    flyConnection = RunService.RenderStepped:Connect(function()
        local _, currentHumanoid, currentRoot = getCharacterParts()
        local camera = workspace.CurrentCamera
        if not currentHumanoid or not currentRoot or not camera then
            stopFly()
            return
        end

        local move = currentHumanoid.MoveDirection
        local look = camera.CFrame.LookVector
        local flatLook = Vector3.new(look.X, 0, look.Z)
        if flatLook.Magnitude > 0.01 then
            flyOrientation.CFrame = CFrame.lookAt(Vector3.zero, flatLook.Unit)
        end

        local vertical = 0
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            vertical = 1
        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            vertical = -1
        end

        -- Mobile joystick supplies MoveDirection; camera pitch controls ascent/descent.
        local cameraVertical = math.clamp(look.Y, -0.85, 0.85)
        local direction = Vector3.new(move.X, cameraVertical + vertical, move.Z)
        if direction.Magnitude > 1 then direction = direction.Unit end
        flyVelocity.VectorVelocity = direction * CONFIG.FlySpeed
    end)
end

local function setFly(enabled)
    if enabled then startFly() else stopFly() end
end

local function applyMovement()
    local _, humanoid = getCharacterParts()
    if not humanoid then return end
    humanoid.WalkSpeed = CONFIG.WalkSpeed
    humanoid.UseJumpPower = true
    humanoid.JumpPower = CONFIG.JumpPower
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if flying then startFly() end
    applyMovement()
end)

-- ESP uses CollectionService tags in your own experience.
local espEnabled = {
    NPC = false,
    Boss = false,
    Chest = false,
    Item = false,
    Drop = false,
    Player = false,
}
local espObjects = {}

local ESP_TAGS = {
    NPC = "ESP_NPC",
    Boss = "ESP_Boss",
    Chest = "ESP_Chest",
    Item = "ESP_Item",
    Drop = "ESP_Drop",
}

local function removeEsp(instance)
    local record = espObjects[instance]
    if record then
        if record.Highlight then record.Highlight:Destroy() end
        if record.Billboard then record.Billboard:Destroy() end
        espObjects[instance] = nil
    end
end

local function addEsp(instance, category)
    if espObjects[instance] or not instance:IsA("Model") and not instance:IsA("BasePart") then
        return
    end
    local adornee = instance:IsA("Model") and (instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart")) or instance
    if not adornee then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "CART3R_ESP"
    highlight.Adornee = instance
    highlight.FillColor = COLORS.Red
    highlight.OutlineColor = COLORS.Text
    highlight.FillTransparency = 0.78
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = screen

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "CART3R_ESP_Label"
    billboard.Adornee = adornee
    billboard.Size = UDim2.fromOffset(160, 34)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = screen

    local label = Instance.new("TextLabel")
    label.BackgroundColor3 = COLORS.Background
    label.BackgroundTransparency = 0.15
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextColor3 = COLORS.Text
    label.TextSize = 11
    label.Text = category
    label.Parent = billboard
    corner(label, 6)

    espObjects[instance] = {Highlight = highlight, Billboard = billboard, Label = label}
end

local function refreshEsp()
    local _, _, root = getCharacterParts()
    if not root then return end

    for instance, record in pairs(espObjects) do
        if not instance.Parent then
            removeEsp(instance)
        else
            local part = instance:IsA("Model") and (instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart")) or instance
            if part then
                local distance = (part.Position - root.Position).Magnitude
                record.Label.Text = string.format("%s  •  %dm", instance.Name, math.floor(distance))
                record.Highlight.Enabled = distance <= CONFIG.ESPMaxDistance
                record.Billboard.Enabled = distance <= CONFIG.ESPMaxDistance
            end
        end
    end

    for category, tag in pairs(ESP_TAGS) do
        if espEnabled[category] then
            for _, instance in ipairs(CollectionService:GetTagged(tag)) do
                addEsp(instance, category)
            end
        end
    end

    if espEnabled.Player then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                addEsp(player.Character, "PLAYER")
            end
        end
    end
end

task.spawn(function()
    while screen.Parent do
        refreshEsp()
        task.wait(CONFIG.ESPRefreshRate)
    end
end)

local function toggleEsp(category, enabled)
    espEnabled[category] = enabled
    if not enabled then
        for instance in pairs(espObjects) do
            local shouldRemove = false
            if category == "Player" then
                shouldRemove = Players:GetPlayerFromCharacter(instance) ~= nil
            else
                local tag = ESP_TAGS[category]
                shouldRemove = tag and CollectionService:HasTag(instance, tag) or false
            end
            if shouldRemove then removeEsp(instance) end
        end
    end
end

-- UI tabs
local tabs = {"PLAYER", "FARM", "KILL AURA", "ESP"}
local tabButtons = {}

local function renderPlayer()
    sectionLabel("PLAYER CONTROL")
    infoLabel("Fly follows the mobile joystick and camera. On touch devices, tilt the camera up/down to change altitude.")
    local flyButton
    flyButton = actionButton("FLY: OFF  •  TAP TO ENABLE", function()
        setFly(not flying)
        flyButton.Text = flying and "FLY: ON  •  TAP TO DISABLE" or "FLY: OFF  •  TAP TO ENABLE"
    end)

    sliderRow("Fly speed", 10, 150, CONFIG.FlySpeed, function(value)
        CONFIG.FlySpeed = value
    end)
    sliderRow("Walk speed", 8, 60, CONFIG.WalkSpeed, function(value)
        CONFIG.WalkSpeed = value
        applyMovement()
    end)
    sliderRow("Jump power", 20, 120, CONFIG.JumpPower, function(value)
        CONFIG.JumpPower = value
        applyMovement()
    end)
    actionButton("APPLY MOVEMENT SETTINGS", applyMovement)
    infoLabel("These movement values are client-side controls for Studio testing. Your game server should enforce its own movement rules.")
end

local function renderFarm()
    sectionLabel("FARM / COLLECTION")
    infoLabel("Collection is intentionally server-authorized. Add your own server-side checks and collection rules; this panel does not teleport or bypass ProximityPrompt holds.")
    local keyword = make("TextBox", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = COLORS.Panel2,
        TextColor3 = COLORS.Text,
        PlaceholderColor3 = COLORS.Muted,
        PlaceholderText = "Chest / item name or keyword...",
        Text = "",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        ClearTextOnFocus = false,
    }, content)
    corner(keyword, 8)
    addPadding(keyword, 8)

    local priority = make("TextBox", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = COLORS.Panel2,
        TextColor3 = COLORS.Text,
        PlaceholderColor3 = COLORS.Muted,
        PlaceholderText = "Collection priority (e.g. Hyper, Rare)...",
        Text = "",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        ClearTextOnFocus = false,
    }, content)
    corner(priority, 8)
    addPadding(priority, 8)

    actionButton("SEARCH TAGGED COLLECTION TARGETS", function()
        local query = string.lower(keyword.Text)
        local matches = {}
        for _, tag in ipairs({"ESP_Chest", "ESP_Item", "ESP_Drop"}) do
            for _, object in ipairs(CollectionService:GetTagged(tag)) do
                if query == "" or string.find(string.lower(object.Name), query, 1, true) then
                    table.insert(matches, object.Name)
                end
            end
        end
        infoLabel("Found " .. #matches .. " matching tagged target(s): " .. table.concat(matches, ", "), 48)
    end)
    actionButton("COLLECTION INTEGRATION STATUS", function()
        infoLabel("Connect this UI to a RemoteEvent that validates distance, ownership, item state, and rate limits on the server.", 48)
    end)
    infoLabel("Priority text: " .. (priority.Text ~= "" and priority.Text or "(not set)"), 24)
end

local function renderKillAura()
    sectionLabel("NPC COMBAT TEST")
    infoLabel("Safe test panel only. It does not generate damage or attack NPCs by itself. Add a server-authorized test RemoteEvent in your own game.")
    sliderRow("Test range", 5, 60, CONFIG.NPCTestRange, function(value)
        CONFIG.NPCTestRange = value
    end)
    sliderRow("Request interval (seconds)", 1, 5, CONFIG.NPCTestRate, function(value)
        CONFIG.NPCTestRate = value
    end)
    local status = infoLabel("Status: server integration required.", 35)
    actionButton("CHECK NPC TEST INTEGRATION", function()
        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("AuthorizedNPCTest")
        if remote and remote:IsA("RemoteEvent") then
            status.Text = "Remote found. Ensure the server independently validates tester permissions, NPC-only targets, range, and request rate."
        else
            status.Text = "No AuthorizedNPCTest RemoteEvent found. No combat request was sent."
        end
    end)
end

local function renderEsp()
    sectionLabel("ESP / WORLD OVERLAY")
    infoLabel("Uses CollectionService tags configured in your own Roblox Studio experience.")
    local categories = {
        {"Player", "PLAYER"},
        {"NPC", "NPC / MOB"},
        {"Boss", "BOSS"},
        {"Chest", "CHEST"},
        {"Item", "ITEM"},
        {"Drop", "BOSS DROPS"},
    }
    for _, entry in ipairs(categories) do
        local key, label = entry[1], entry[2]
        local button
        button = actionButton(label .. ": OFF", function()
            local enabled = not espEnabled[key]
            toggleEsp(key, enabled)
            button.Text = label .. (enabled and ": ON" or ": OFF")
        end)
    end
    sliderRow("ESP maximum distance", 100, 3000, CONFIG.ESPMaxDistance, function(value)
        CONFIG.ESPMaxDistance = value
    end)

    local custom = make("TextBox", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = COLORS.Panel2,
        TextColor3 = COLORS.Text,
        PlaceholderColor3 = COLORS.Muted,
        PlaceholderText = "Custom tagged object name...",
        Text = "",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        ClearTextOnFocus = false,
    }, content)
    corner(custom, 8)
    addPadding(custom, 8)
    actionButton("HIGHLIGHT CUSTOM NAME MATCHES", function()
        local query = string.lower(custom.Text)
        if query == "" then return end
        for _, object in ipairs(workspace:GetDescendants()) do
            if (object:IsA("Model") or object:IsA("BasePart"))
                and string.find(string.lower(object.Name), query, 1, true) then
                addEsp(object, "CUSTOM")
            end
        end
    end)
    infoLabel("Money: " .. (function()
        local stats = LocalPlayer:FindFirstChild("leaderstats")
        local money = stats and (stats:FindFirstChild("Money") or stats:FindFirstChild("Cash"))
        return money and tostring(money.Value) or "leaderstats value not found"
    end)(), 24)
end

local renderers = {
    PLAYER = renderPlayer,
    FARM = renderFarm,
    ["KILL AURA"] = renderKillAura,
    ESP = renderEsp,
}

local function selectTab(tabName)
    clearContent()
    for name, button in pairs(tabButtons) do
        button.BackgroundColor3 = name == tabName and COLORS.RedDark or COLORS.Panel2
        button.TextColor3 = COLORS.Text
    end
    renderers[tabName]()
    content.CanvasPosition = Vector2.zero
end

for index, tabName in ipairs(tabs) do
    local button = make("TextButton", {
        Name = tabName,
        Size = UDim2.new(0.25, -5, 1, 0),
        BackgroundColor3 = index == 1 and COLORS.RedDark or COLORS.Panel2,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        Text = tabName,
        TextColor3 = COLORS.Text,
        TextSize = 9,
        LayoutOrder = index,
    }, nav)
    corner(button, 7)
    tabButtons[tabName] = button
    button.Activated:Connect(function()
        selectTab(tabName)
    end)
end

local function setMinimized(minimized)
    main.Visible = not minimized
    bubble.Visible = minimized
end

minimize.Activated:Connect(function()
    setMinimized(true)
end)

bubble.Activated:Connect(function()
    setMinimized(false)
end)

-- Make the floating bubble draggable on touch and mouse.
do
    local dragging = false
    local dragStart
    local startPosition

    bubble.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPosition = bubble.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            bubble.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

selectTab("PLAYER")

screen.Destroying:Connect(function()
    stopFly()
    for instance in pairs(espObjects) do
        removeEsp(instance)
    end
end)
