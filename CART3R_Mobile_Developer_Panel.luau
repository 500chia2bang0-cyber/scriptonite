--[[
    CART3R.JAILBREAK - MOBILE DEVELOPER PANEL
    Version: 1.0.0
    Platform: Roblox Studio / Luau
    Purpose: Safe UI framework for an experience you own or are authorized to develop.

    IMPORTANT:
    - This is a LocalScript UI framework, not an executor script.
    - It does not bypass cooldowns, teleport/collect objects in other games,
      damage NPCs, reveal hidden entities, evade moderation, or provide anti-ban.
    - Connect the buttons to your own game's server-validated systems.
    - Never trust client requests for rewards, damage, movement, or permissions.

    Install:
    1. In Roblox Studio, create a LocalScript under StarterPlayer > StarterPlayerScripts.
    2. Paste this entire file into the LocalScript.
    3. Press Play. The panel is designed for touch and mouse input.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("CarterMobilePanel")
if oldGui then
    oldGui:Destroy()
end

local COLORS = {
    Background = Color3.fromRGB(8, 8, 10),
    Panel = Color3.fromRGB(17, 14, 16),
    Panel2 = Color3.fromRGB(27, 18, 21),
    Red = Color3.fromRGB(235, 42, 55),
    RedDark = Color3.fromRGB(105, 20, 30),
    Text = Color3.fromRGB(245, 240, 241),
    Muted = Color3.fromRGB(165, 150, 154),
    Green = Color3.fromRGB(65, 190, 120),
}

local gui = Instance.new("ScreenGui")
gui.Name = "CarterMobilePanel"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or COLORS.RedDark
    s.Thickness = thickness or 1
    s.Transparency = 0.15
    s.Parent = parent
    return s
end

local function makeLabel(parent, text, size, color, font)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or COLORS.Text
    label.TextSize = size or 14
    label.Font = font or Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.Size = UDim2.new(1, 0, 0, 0)
    label.Parent = parent
    return label
end

local function makeButton(parent, text, height)
    local button = Instance.new("TextButton")
    button.AutoButtonColor = true
    button.BackgroundColor3 = COLORS.Panel2
    button.Text = text
    button.TextColor3 = COLORS.Text
    button.TextSize = 13
    button.Font = Enum.Font.GothamSemibold
    button.Size = UDim2.new(1, 0, 0, height or 38)
    button.Parent = parent
    corner(button, 9)
    stroke(button, COLORS.RedDark, 1)
    return button
end

local function makeCard(parent, title, description)
    local card = Instance.new("Frame")
    card.BackgroundColor3 = COLORS.Panel
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.Parent = parent
    corner(card, 10)
    stroke(card, COLORS.RedDark, 1)

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 11)
    padding.PaddingRight = UDim.new(0, 11)
    padding.Parent = card

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 7)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = card

    makeLabel(card, title, 14, COLORS.Text, Enum.Font.GothamBold)
    if description then
        makeLabel(card, description, 11, COLORS.Muted)
    end
    return card
end

local function makeToggle(parent, title, description, onChanged)
    local card = makeCard(parent, title, description)
    local state = false
    local button = makeButton(card, "OFF", 34)
    button.BackgroundColor3 = COLORS.Panel2

    button.Activated:Connect(function()
        state = not state
        button.Text = state and "ON" or "OFF"
        button.BackgroundColor3 = state and Color3.fromRGB(24, 65, 44) or COLORS.Panel2
        if onChanged then
            onChanged(state)
        end
    end)

    return card
end

local function makeTextInput(parent, title, placeholder)
    local card = makeCard(parent, title)
    local input = Instance.new("TextBox")
    input.ClearTextOnFocus = false
    input.PlaceholderText = placeholder or "Enter text..."
    input.Text = ""
    input.TextColor3 = COLORS.Text
    input.PlaceholderColor3 = COLORS.Muted
    input.TextSize = 13
    input.Font = Enum.Font.Gotham
    input.BackgroundColor3 = COLORS.Background
    input.Size = UDim2.new(1, 0, 0, 38)
    input.Parent = card
    corner(input, 8)
    stroke(input, COLORS.RedDark, 1)
    return input
end

local function makeSlider(parent, title, minValue, maxValue, initialValue, callback)
    local card = makeCard(parent, title)
    local valueLabel = makeLabel(card, tostring(initialValue), 12, COLORS.Red)
    local slider = Instance.new("Frame")
    slider.BackgroundColor3 = COLORS.Background
    slider.Size = UDim2.new(1, 0, 0, 10)
    slider.Parent = card
    corner(slider, 6)

    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = COLORS.Red
    fill.Size = UDim2.new((initialValue - minValue) / (maxValue - minValue), 0, 1, 0)
    fill.Parent = slider
    corner(fill, 6)

    local knob = Instance.new("TextButton")
    knob.Text = ""
    knob.AutoButtonColor = false
    knob.BackgroundColor3 = COLORS.Text
    knob.Size = UDim2.fromOffset(18, 18)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, 0)
    knob.Parent = slider
    corner(knob, 20)

    local dragging = false
    local currentValue = initialValue

    local function update(inputX)
        local width = math.max(slider.AbsoluteSize.X, 1)
        local alpha = math.clamp((inputX - slider.AbsolutePosition.X) / width, 0, 1)
        currentValue = math.floor(minValue + (maxValue - minValue) * alpha + 0.5)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, 0, 0.5, 0)
        valueLabel.Text = tostring(currentValue)
        if callback then callback(currentValue) end
    end

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)

    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            update(input.Position.X)
            dragging = true
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

    return card
end

-- Main window
local main = Instance.new("Frame")
main.Name = "Main"
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.fromScale(0.5, 0.5)
main.Size = UDim2.new(0.88, 0, 0.72, 0)
main.BackgroundColor3 = COLORS.Background
main.Parent = gui
corner(main, 14)
stroke(main, COLORS.Red, 1.5)

local sizeLimit = Instance.new("UISizeConstraint")
sizeLimit.MinSize = Vector2.new(280, 320)
sizeLimit.MaxSize = Vector2.new(520, 620)
sizeLimit.Parent = main

local mainPadding = Instance.new("UIPadding")
mainPadding.PaddingTop = UDim.new(0, 10)
mainPadding.PaddingBottom = UDim.new(0, 10)
mainPadding.PaddingLeft = UDim.new(0, 10)
mainPadding.PaddingRight = UDim.new(0, 10)
mainPadding.Parent = main

local rootLayout = Instance.new("UIListLayout")
rootLayout.Padding = UDim.new(0, 9)
rootLayout.SortOrder = Enum.SortOrder.LayoutOrder
rootLayout.Parent = main

-- Header
local header = Instance.new("Frame")
header.BackgroundColor3 = COLORS.Panel
header.Size = UDim2.new(1, 0, 0, 42)
header.LayoutOrder = 1
header.Parent = main
corner(header, 9)

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(10, 0)
title.Size = UDim2.new(1, -92, 1, 0)
title.Font = Enum.Font.GothamBold
title.Text = "CART3R  /  MOBILE"
title.TextColor3 = COLORS.Red
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(34, 30)
minimize.Position = UDim2.new(1, -42, 0.5, -15)
minimize.Text = "−"
minimize.TextSize = 24
minimize.Font = Enum.Font.GothamBold
minimize.TextColor3 = COLORS.Text
minimize.BackgroundColor3 = COLORS.Panel2
minimize.Parent = header
corner(minimize, 8)

-- Tab navigation
local tabBar = Instance.new("Frame")
tabBar.BackgroundTransparency = 1
tabBar.Size = UDim2.new(1, 0, 0, 38)
tabBar.LayoutOrder = 2
tabBar.Parent = main

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 5)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabBar

local pagesHolder = Instance.new("Frame")
pagesHolder.BackgroundTransparency = 1
pagesHolder.Size = UDim2.new(1, 0, 1, -100)
pagesHolder.LayoutOrder = 3
pagesHolder.Parent = main

local pages = {}
local tabButtons = {}
local tabNames = {"PLAYER", "FARM", "KILL AURA", "ESP"}

for _, tabName in ipairs(tabNames) do
    local tabButton = Instance.new("TextButton")
    tabButton.Name = tabName
    tabButton.Size = UDim2.new(0.25, -4, 1, 0)
    tabButton.BackgroundColor3 = COLORS.Panel2
    tabButton.Text = tabName
    tabButton.TextColor3 = COLORS.Muted
    tabButton.TextSize = 10
    tabButton.Font = Enum.Font.GothamBold
    tabButton.Parent = tabBar
    corner(tabButton, 8)
    tabButtons[tabName] = tabButton

    local page = Instance.new("ScrollingFrame")
    page.Name = tabName .. "Page"
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundColor3 = COLORS.Panel
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = COLORS.Red
    page.CanvasSize = UDim2.new()
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = pagesHolder
    corner(page, 10)

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 9)
    padding.PaddingBottom = UDim.new(0, 9)
    padding.PaddingLeft = UDim.new(0, 9)
    padding.PaddingRight = UDim.new(0, 9)
    padding.Parent = page

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 8)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = page

    pages[tabName] = page
end

local function showTab(name)
    for tabName, page in pairs(pages) do
        local active = tabName == name
        page.Visible = active
        tabButtons[tabName].BackgroundColor3 = active and COLORS.RedDark or COLORS.Panel2
        tabButtons[tabName].TextColor3 = active and COLORS.Text or COLORS.Muted
    end
end

for tabName, button in pairs(tabButtons) do
    button.Activated:Connect(function()
        showTab(tabName)
    end)
end

-- PLAYER page: safe UI controls only; wire these to your own server-authorized game systems.
local playerPage = pages["PLAYER"]
makeLabel(playerPage, "PLAYER TOOLS", 14, COLORS.Red, Enum.Font.GothamBold)
makeToggle(playerPage, "Flight mode", "UI toggle only. Connect to a movement system in your own experience.")
makeSlider(playerPage, "Flight speed setting", 1, 100, 25)
makeToggle(playerPage, "Speed boost", "Requires server-side permission and validation in your own game.")
makeSlider(playerPage, "Walk speed setting", 8, 32, 16)
makeToggle(playerPage, "Jump boost", "Requires server-side permission and validation in your own game.")
makeSlider(playerPage, "Jump power setting", 25, 100, 50)
makeLabel(playerPage, "Cooldowns and item-use rules must be enforced by the server; this panel does not bypass them.", 11, COLORS.Muted)

-- FARM page: search/configuration UI, not an automated collector or teleport exploit.
local farmPage = pages["FARM"]
makeLabel(farmPage, "FARM CONFIGURATION", 14, COLORS.Red, Enum.Font.GothamBold)
local priorityInput = makeTextInput(farmPage, "Collect Priority", "Example: Hyper Chest, Rare Chest")
local filterInput = makeTextInput(farmPage, "Item / object keyword", "Enter an object name or keyword")
makeToggle(farmPage, "Enable collection helper", "Configuration toggle only. Implement collection through your own game's server logic.")
makeToggle(farmPage, "Show dropped-item markers", "Display markers for objects your own game exposes to this client.")
makeLabel(farmPage, "Priority text: the first keyword can be treated as the highest priority by your own collection system.", 11, COLORS.Muted)

-- KILL AURA page: non-combat testing controls only; no damage automation.
local combatPage = pages["KILL AURA"]
makeLabel(combatPage, "NPC TESTING", 14, COLORS.Red, Enum.Font.GothamBold)
makeLabel(combatPage, "Automated damage and instant-kill features are intentionally not included. Use Roblox Studio test tools and server-authorized combat logic for your own NPCs.", 12, COLORS.Muted)
makeToggle(combatPage, "NPC debug overlay", "Placeholder toggle for a debug overlay in your own experience.")
makeSlider(combatPage, "Debug display radius", 10, 250, 60)

-- ESP page: safe debug visualization settings for objects explicitly exposed by your own game.
local espPage = pages["ESP"]
makeLabel(espPage, "DEBUG VISUALIZATION", 14, COLORS.Red, Enum.Font.GothamBold)
makeToggle(espPage, "Player markers", "For your own game's permitted player-debug view.")
makeToggle(espPage, "NPC / boss markers", "For NPCs your own game exposes to the client.")
makeToggle(espPage, "Chest markers", "For test objects in your own experience.")
makeToggle(espPage, "Dropped item markers", "For item drops your own game exposes to the client.")
local customEspInput = makeTextInput(espPage, "Custom marker keyword", "Enter an allowed object name")
makeToggle(espPage, "Custom marker filter", "Configuration toggle only; connect to your own debug tagging system.")
makeLabel(espPage, "A debug overlay should only show information the game intentionally replicates to the client.", 11, COLORS.Muted)

-- Minimize to a floating bubble; tap the bubble to restore.
local bubble = Instance.new("TextButton")
bubble.Name = "RestoreBubble"
bubble.Size = UDim2.fromOffset(54, 54)
bubble.Position = UDim2.new(0, 18, 0.55, 0)
bubble.BackgroundColor3 = COLORS.RedDark
bubble.Text = "C"
bubble.TextColor3 = COLORS.Text
bubble.TextSize = 22
bubble.Font = Enum.Font.GothamBlack
bubble.Visible = false
bubble.Parent = gui
corner(bubble, 28)
stroke(bubble, COLORS.Red, 2)

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

-- Drag the floating bubble on touch or mouse.
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

showTab("PLAYER")
print("[CART3R.JAILBREAK] Mobile developer panel loaded.")
