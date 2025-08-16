```lua
--[[
    UltimateUI - The Ultimate Roblox Interface Suite

    Description:
    UltimateUI is a premium Roblox UI library merging the best from Atonium, Luna, Starlight, and WindUI. It features fluid animations, mobile optimization, advanced elements, and stunning visuals with gradients, shadows, and blur effects.

    Credits:
    - Atonium UI: Private contributors
    - Luna Interface Suite (Nebula Softworks): Hunter, JustHey, Throit, Wally, Sirius
    - Starlight Interface Suite (Nebula Softworks): Hunter, JustHey, Pookie Pepelss, Inori
    - WindUI: .ftgs#0
]]

local UltimateUI = {
    Version = "2.0.0",
    Folder = "UltimateUI",
    Flags = {},
    Connections = {},
    Objects = {},
    ThemeObjects = {},
    CurrentTheme = "Dark",
    Language = "en",
    WindowKeybind = Enum.KeyCode.Insert,
    WindowVisible = true,
    Dragging = false,
    DragStart = nil,
    StartPos = nil,
    SliderDrag = false,
    IsMobile = false,
    TouchSupport = false,
    ConfigEnabled = true,
    AutoSave = true,
    ScreenGui = nil,
    MainFrame = nil,
    MobileButton = nil,
    CurrentWindow = nil,
    Elements = {},
}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Mobile Detection
UltimateUI.IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
UltimateUI.TouchSupport = UserInputService.TouchEnabled

-- Themes
UltimateUI.Themes = {
    Dark = {
        Background = Color3.fromRGB(19, 20, 24),
        Secondary = Color3.fromRGB(27, 28, 33),
        Tertiary = Color3.fromRGB(22, 23, 27),
        Accent = Color3.fromRGB(66, 89, 182),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 180),
        TextDimmed = Color3.fromRGB(140, 140, 140),
        Border = Color3.fromRGB(40, 41, 46),
        Success = Color3.fromRGB(67, 160, 71),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(244, 67, 54),
        Glow = "rbxassetid://17290798394",
        Shadow = "rbxassetid://6014261993",
    },
    Light = {
        Background = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(245, 245, 245),
        Tertiary = Color3.fromRGB(238, 238, 238),
        Accent = Color3.fromRGB(33, 150, 243),
        Text = Color3.fromRGB(33, 33, 33),
        TextSecondary = Color3.fromRGB(117, 117, 117),
        TextDimmed = Color3.fromRGB(158, 158, 158),
        Border = Color3.fromRGB(224, 224, 224),
        Success = Color3.fromRGB(76, 175, 80),
        Warning = Color3.fromRGB(255, 152, 0),
        Error = Color3.fromRGB(244, 67, 54),
        Glow = "rbxassetid://17290798394",
        Shadow = "rbxassetid://6014261993",
    }
}

-- Icons
UltimateUI.Icons = {
    home = "rbxassetid://10723434711",
    settings = "rbxassetid://10734950309",
    user = "rbxassetid://10734949856",
    star = "rbxassetid://10734896301",
    heart = "rbxassetid://10723424505",
    check = "rbxassetid://10734884548",
    x = "rbxassetid://10734884975",
    plus = "rbxassetid://10734896629",
    minus = "rbxassetid://10734896382",
    arrow_up = "rbxassetid://10709790948",
    arrow_down = "rbxassetid://10709791437",
    arrow_left = "rbxassetid://10709792216",
    arrow_right = "rbxassetid://10709791992",
    info = "rbxassetid://10734898355",
    warning = "rbxassetid://10734950598",
    error = "rbxassetid://10734899175",
    success = "rbxassetid://10734896487",
    mobile = "rbxassetid://17183279677",
}

-- Utility Functions
local function SafeCallback(callback, ...)
    if not callback then return end
    local success, err = pcall(callback, ...)
    if not success then
        warn("[UltimateUI Error] " .. tostring(err))
    end
end

local function CreateTween(object, tweenInfo, properties, callback)
    local tween = TweenService:Create(object, tweenInfo, properties)
    if callback then
        tween.Completed:Connect(callback)
    end
    tween:Play()
    return tween
end

local function GetTextSize(text, textSize, font, frameSize)
    return TextService:GetTextSize(text, textSize, font, frameSize)
end

-- Theme Functions
function UltimateUI:GetThemeColor(colorName)
    return self.Themes[self.CurrentTheme][colorName] or self.Themes.Dark[colorName]
end

function UltimateUI:AddThemeObject(object, properties)
    self.ThemeObjects[object] = properties
    self:UpdateTheme(object)
end

function UltimateUI:UpdateTheme(specificObject)
    local function applyTheme(obj, props)
        for property, colorName in pairs(props) do
            if typeof(colorName) == "string" then
                local color = self:GetThemeColor(colorName)
                if color then
                    obj[property] = color
                end
            end
        end
    end
    
    if specificObject then
        local props = self.ThemeObjects[specificObject]
        if props then
            applyTheme(specificObject, props)
        end
    else
        for obj, props in pairs(self.ThemeObjects) do
            if obj and obj.Parent then
                applyTheme(obj, props)
            end
        end
    end
end

function UltimateUI:SetTheme(themeName)
    if self.Themes[themeName] then
        self.CurrentTheme = themeName
        self:UpdateTheme()
        self:SaveConfig()
    end
end

function UltimateUI:AddConnection(connection)
    table.insert(self.Connections, connection)
end

function UltimateUI:Disconnect()
    for _, connection in pairs(self.Connections) do
        if connection then
            connection:Disconnect()
        end
    end
    self.Connections = {}
end

function UltimateUI:SaveConfig()
    if not self.ConfigEnabled then return end
    
    local config = {
        Theme = self.CurrentTheme,
        Flags = self.Flags,
        WindowVisible = self.WindowVisible,
    }
    
    local success, result = pcall(function()
        local encoded = HttpService:JSONEncode(config)
        if writefile and makefolder then
            if not isfolder(self.Folder) then
                makefolder(self.Folder)
            end
            writefile(self.Folder .. "/config.json", encoded)
        end
    end)
    
    if not success then
        warn("[UltimateUI] Failed to save config: " .. tostring(result))
    end
end

function UltimateUI:LoadConfig()
    if not self.ConfigEnabled then return end
    
    local success, result = pcall(function()
        if readfile and isfile and isfile(self.Folder .. "/config.json") then
            local data = readfile(self.Folder .. "/config.json")
            local config = HttpService:JSONDecode(data)
            
            self.CurrentTheme = config.Theme or self.CurrentTheme
            self.Flags = config.Flags or {}
            self.WindowVisible = config.WindowVisible ~= false
            
            return true
        end
    end)
    
    if not success then
        warn("[UltimateUI] Failed to load config: " .. tostring(result))
    end
end

function UltimateUI:Notify(options)
    options = options or {}
    local title = options.Title or "Notification"
    local content = options.Content or ""
    local duration = options.Duration or 5
    local icon = options.Icon or "info"
    local type = options.Type or "info"
    
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "UltimateUI_Notification"
    notificationGui.ResetOnSpawn = false
    notificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    notificationGui.Parent = CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 80)
    frame.Position = UDim2.new(1, -370, 0, 20)
    frame.BackgroundColor3 = self:GetThemeColor("Secondary")
    frame.BorderSizePixel = 0
    frame.Parent = notificationGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    local iconFrame = Instance.new("ImageLabel")
    iconFrame.Size = UDim2.new(0, 24, 0, 24)
    iconFrame.Position = UDim2.new(0, 15, 0, 15)
    iconFrame.BackgroundTransparency = 1
    iconFrame.Image = self.Icons[icon] or self.Icons.info
    iconFrame.ImageColor3 = self:GetThemeColor("Accent")
    iconFrame.Parent = frame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -55, 0, 20)
    titleLabel.Position = UDim2.new(0, 50, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = self:GetThemeColor("Text")
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.Gotham
    titleLabel.Parent = frame
    
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Size = UDim2.new(1, -55, 0, 40)
    contentLabel.Position = UDim2.new(0, 50, 0, 30)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content
    contentLabel.TextColor3 = self:GetThemeColor("TextSecondary")
    contentLabel.TextSize = 12
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextWrapped = true
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.Parent = frame
    
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(1, 0, 0, 2)
    progressBar.Position = UDim2.new(0, 0, 1, -2)
    progressBar.BackgroundColor3 = self:GetThemeColor("Accent")
    progressBar.BorderSizePixel = 0
    progressBar.Parent = frame
    
    self:AddThemeObject(frame, {BackgroundColor3 = "Secondary"})
    self:AddThemeObject(iconFrame, {ImageColor3 = "Accent"})
    self:AddThemeObject(titleLabel, {TextColor3 = "Text"})
    self:AddThemeObject(contentLabel, {TextColor3 = "TextSecondary"})
    self:AddThemeObject(progressBar, {BackgroundColor3 = "Accent"})
    
    CreateTween(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -370, 0, 20)
    })
    
    CreateTween(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 0, 2)
    })
    
    task.spawn(function()
        task.wait(duration)
        CreateTween(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 0, 0, 20)
        })
        task.wait(0.3)
        notificationGui:Destroy()
    end)
    
    return notificationGui
end

function UltimateUI:CreateWindow(options)
    options = options or {}
    local title = options.Title or "UltimateUI"
    local size = options.Size or (self.IsMobile and UDim2.new(0, 400, 0, 300) or UDim2.new(0, 600, 0, 400))
    local keySystem = options.KeySystem or {Enabled = false}
    
    self:CreateFolder()
    self:LoadConfig()
    
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "UltimateUI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = CoreGui
    
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Size = size
    self.MainFrame.Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
    self.MainFrame.BackgroundColor3 = self:GetThemeColor("Background")
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Visible = self.WindowVisible
    self.MainFrame.Parent = self.ScreenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = self.MainFrame
    
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = self:GetThemeColor("Secondary")
    titleBar.BorderSizePixel = 0
    titleBar.Parent = self.MainFrame
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -100, 1, 0)
    titleText.Position = UDim2.new(0, 15, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = title
    titleText.TextColor3 = self:GetThemeColor("Text")
    titleText.TextSize = 16
    titleText.Font = Enum.Font.GothamBold
    titleText.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -30, 0, 5)
    closeBtn.BackgroundColor3 = self:GetThemeColor("Error")
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    
    self:AddThemeObject(self.MainFrame, {BackgroundColor3 = "Background"})
    self:AddThemeObject(titleBar, {BackgroundColor3 = "Secondary"})
    self:AddThemeObject(titleText, {TextColor3 = "Text"})
    self:AddThemeObject(closeBtn, {BackgroundColor3 = "Error"})
    
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        self.MainFrame.Visible = false
        self.WindowVisible = false
    end)
    
    self:AddConnection(UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == self.WindowKeybind then
            self.WindowVisible = not self.WindowVisible
            self.MainFrame.Visible = self.WindowVisible
        end
    end))
    
    if self.IsMobile then
        self.MobileButton = Instance.new("TextButton")
        self.MobileButton.Size = UDim2.new(0, 60, 0, 60)
        self.MobileButton.Position = UDim2.new(1, -80, 1, -80)
        self.MobileButton.BackgroundColor3 = self:GetThemeColor("Accent")
        self.MobileButton.BorderSizePixel = 0
        self.MobileButton.Text = "UI"
        self.MobileButton.TextColor3 = Color3.new(1, 1, 1)
        self.MobileButton.TextSize = 18
        self.MobileButton.Font = Enum.Font.GothamBold
        self.MobileButton.Parent = self.ScreenGui
        
        local mobileCorner = Instance.new("UICorner")
        mobileCorner.CornerRadius = UDim.new(0, 30)
        mobileCorner.Parent = self.MobileButton
        
        self:AddThemeObject(self.MobileButton, {BackgroundColor3 = "Accent"})
        
        self.MobileButton.MouseButton1Click:Connect(function()
            self.WindowVisible = not self.WindowVisible
            self.MainFrame.Visible = self.WindowVisible
        end)
    end
    
    local window = {
        GUI = self.ScreenGui,
        MainFrame = self.MainFrame,
        Tabs = {},
        CurrentTab = nil,
    }
    
    function window:CreateTab(options)
        options = options or {}
        local name = options.Name or "Tab"
        local icon = options.Icon or "home"
        local layoutOrder = options.LayoutOrder or #self.Tabs + 1
        
        local tabContainer = Instance.new("Frame")
        tabContainer.Size = UDim2.new(1, 0, 0, 40)
        tabContainer.BackgroundTransparency = 1
        tabContainer.Parent = self.MainFrame
        
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(0, 100, 1, 0)
        tabButton.Position = UDim2.new(0, layoutOrder * 105 - 105, 0, 0)
        tabButton.BackgroundColor3 = self:GetThemeColor("Secondary")
        tabButton.BorderSizePixel = 0
        tabButton.Text = ""
        tabButton.Parent = tabContainer
        
        local tabIcon = Instance.new("ImageLabel")
        tabIcon.Size = UDim2.new(0, 20, 0, 20)
        tabIcon.Position = UDim2.new(0, 10, 0.5, -10)
        tabIcon.BackgroundTransparency = 1
        tabIcon.Image = self.Icons[icon] or self.Icons.home
        tabIcon.ImageColor3 = self:GetThemeColor("Text")
        tabIcon.Parent = tabButton
        
        local tabText = Instance.new("TextLabel")
        tabText.Size = UDim2.new(1, -30, 1, 0)
        tabText.Position = UDim2.new(0, 35, 0, 0)
        tabText.BackgroundTransparency = 1
        tabText.Text = name
        tabText.TextColor3 = self:GetThemeColor("Text")
        tabText.TextSize = 14
        tabText.Font = Enum.Font.Gotham
        tabText.Parent = tabButton
        
        local tabContent = Instance.new("Frame")
        tabContent.Size = UDim2.new(1, 0, 1, -40)
        tabContent.Position = UDim2.new(0, 0, 0, 40)
        tabContent.BackgroundColor3 = self:GetThemeColor("Background")
        tabContent.BorderSizePixel = 0
        tabContent.Visible = #self.Tabs == 0
        tabContent.Parent = self.MainFrame
        
        self:AddThemeObject(tabButton, {BackgroundColor3 = "Secondary"})
        self:AddThemeObject(tabIcon, {ImageColor3 = "Text"})
        self:AddThemeObject(tabText, {TextColor3 = "Text"})
        self:AddThemeObject(tabContent, {BackgroundColor3 = "Background"})
        
        local tab = {
            Name = name,
            Button = tabButton,
            Content = tabContent,
            Elements = {},
        }
        
        tabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(self.Tabs) do
                t.Content.Visible = false
            end
            tabContent.Visible = true
            self.CurrentTab = name
        end)
        
        table.insert(self.Tabs, tab)
        return tab
    end
    
    function window:CreateToggle(options)
        options = options or {}
        local toggleName = options.Name or "Toggle"
        local flag = options.Flag or toggleName:lower():gsub("%s+", "_")
        local defaultValue = options.Default or false
        local callback = options.Callback
        
        self.Flags[flag] = self.Flags[flag] or defaultValue
        
        local tab = self.CurrentTab and next(self.Tabs, function(t) return t.Name == self.CurrentTab end) or self.Tabs[1]
        if not tab then return end
        
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(1, -20, 0, 40)
        toggleFrame.Position = UDim2.new(0, 10, 0, #tab.Elements * 50)
        toggleFrame.BackgroundColor3 = self:GetThemeColor("Secondary")
        toggleFrame.BorderSizePixel = 0
        toggleFrame.Parent = tab.Content
        
        local toggleButton = Instance.new("TextButton")
        toggleButton.Size = UDim2.new(1, 0, 1, 0)
        toggleButton.BackgroundTransparency = 1
        toggleButton.Text = ""
        toggleButton.Parent = toggleFrame
        
        local toggleText = Instance.new("TextLabel")
        toggleText.Size = UDim2.new(1, -60, 1, 0)
        toggleText.Position = UDim2.new(0, 10, 0, 0)
        toggleText.BackgroundTransparency = 1
        toggleText.Text = toggleName
        toggleText.TextColor3 = self:GetThemeColor("Text")
        toggleText.TextSize = 14
        toggleText.Font = Enum.Font.Gotham
        toggleText.Parent = toggleFrame
        
        local switch = Instance.new("Frame")
        switch.Size = UDim2.new(0, 40, 0, 20)
        switch.Position = UDim2.new(1, -50, 0.5, -10)
        switch.BackgroundColor3 = self.Flags[flag] and self:GetThemeColor("Accent") or self:GetThemeColor("Border")
        switch.BorderSizePixel = 0
        switch.Parent = toggleFrame
        
        local switchCircle = Instance.new("Frame")
        switchCircle.Size = UDim2.new(0, 16, 0, 16)
        switchCircle.Position = UDim2.new(0, self.Flags[flag] and 22 or 2, 0.5, -8)
        switchCircle.BackgroundColor3 = Color3.new(1, 1, 1)
        switchCircle.BorderSizePixel = 0
        switchCircle.Parent = switch
        
        self:AddThemeObject(toggleFrame, {BackgroundColor3 = "Secondary"})
        self:AddThemeObject(toggleText, {TextColor3 = "Text"})
        self:AddThemeObject(switch, {BackgroundColor3 = self.Flags[flag] and "Accent" or "Border"})
        
        local function updateToggle(value)
            self.Flags[flag] = value
            switch.BackgroundColor3 = value and self:GetThemeColor("Accent") or self:GetThemeColor("Border")
            switchCircle.Position = UDim2.new(0, value and 22 or 2, 0.5, -8)
            if self.AutoSave then
                self:SaveConfig()
            end
            SafeCallback(callback, value)
        end
        
        updateToggle(self.Flags[flag])
        
        toggleButton.MouseButton1Click:Connect(function()
            updateToggle(not self.Flags[flag])
        end)
        
        local toggle = {Frame = toggleFrame, Set = updateToggle, Get = function() return self.Flags[flag] end}
        table.insert(tab.Elements, toggle)
        return toggle
    end
    
    return window
end

-- Initialize and return
UltimateUI:LoadConfig()
return UltimateUI
```
