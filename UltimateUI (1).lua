--[[
    Ultimate UI Library - Enhanced Version
    Built from the best patterns in Atonium, Luna, Starlight, and WindUI
    
    Credits to Original Libraries and Contributors:
    
    Atonium UI: Private library contributors
    Luna Interface Suite by Nebula Softworks: Hunter, JustHey, Throit, Wally, Sirius
    Starlight Interface Suite by Nebula Softworks: Hunter, JustHey, Pookie Pepelss, Inori
    WindUI: .ftgs#0 (Discord)
]]

local UltimateUI = {
    Version = "2.0.0",
    Folder = "UltimateUI",
    Flags = {},
    Connections = {},
    Objects = {},
    ThemeObjects = {},
    
    -- Core settings
    CurrentTheme = "Dark",
    Language = "en",
    WindowKeybind = Enum.KeyCode.Insert,
    
    -- State management
    WindowVisible = true,
    Dragging = false,
    DragStart = nil,
    StartPos = nil,
    SliderDrag = false,
    
    -- Mobile detection and optimization
    IsMobile = false,
    TouchSupport = false,
    
    -- Configuration
    ConfigEnabled = true,
    AutoSave = true,
    
    -- UI References
    ScreenGui = nil,
    MainFrame = nil,
    MobileButton = nil,
    CurrentWindow = nil,
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

-- Enhanced mobile detection
UltimateUI.IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
UltimateUI.TouchSupport = UserInputService.TouchEnabled

-- Enhanced Themes (Based on source libraries)
UltimateUI.Themes = {
    Dark = {
        Background = Color3.fromRGB(19, 20, 24),
        Secondary = Color3.fromRGB(27, 28, 33),
        Tertiary = Color3.fromRGB(22, 23, 27),
        Accent = Color3.fromRGB(66, 89, 182),
        AccentGradient = ColorSequence.new{
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(66, 89, 182)), 
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(37, 57, 137))
        },
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
        AccentGradient = ColorSequence.new{
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(33, 150, 243)), 
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(21, 101, 192))
        },
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

-- Enhanced Icons
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
    
    local success, error = pcall(callback, ...)
    if not success then
        warn("[UltimateUI Error] " .. tostring(error))
    end
    return success
end

local function CreateTween(object, tweenInfo, properties, callback)
    local tween = TweenService:Create(object, tweenInfo, properties)
    if callback then
        tween.Completed:Connect(callback)
    end
    tween:Play()
    return tween
end

-- Core Functions
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
    
    return false
end

-- Notification System
function UltimateUI:Notify(options)
    options = options or {}
    local title = options.Title or "Notification"
    local content = options.Content or ""
    local duration = options.Duration or 5
    local icon = options.Icon or "info"
    
    -- Create notification GUI
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "UltimateUI_Notification"
    notificationGui.ResetOnSpawn = false
    notificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    notificationGui.Parent = CoreGui
    
    -- Main frame
    local frame = Instance.new("Frame")
    frame.Name = "NotificationFrame"
    frame.Size = UDim2.new(0, 350, 0, 80)
    frame.Position = UDim2.new(1, 20, 0, 20)
    frame.BackgroundColor3 = self:GetThemeColor("Secondary")
    frame.BorderSizePixel = 0
    frame.Parent = notificationGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    -- Shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundTransparency = 1
    shadow.Image = self:GetThemeColor("Shadow")
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(99, 99, 99, 99)
    shadow.ZIndex = -1
    shadow.Parent = frame
    
    -- Icon
    local iconFrame = Instance.new("ImageLabel")
    iconFrame.Name = "Icon"
    iconFrame.Size = UDim2.new(0, 24, 0, 24)
    iconFrame.Position = UDim2.new(0, 15, 0, 15)
    iconFrame.BackgroundTransparency = 1
    iconFrame.Image = self.Icons[icon] or self.Icons.info
    iconFrame.ImageColor3 = self:GetThemeColor("Accent")
    iconFrame.Parent = frame
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -55, 0, 20)
    titleLabel.Position = UDim2.new(0, 50, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = self:GetThemeColor("Text")
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = frame
    
    -- Content
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Name = "Content"
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
    
    -- Progress bar
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Size = UDim2.new(1, 0, 0, 3)
    progressBar.Position = UDim2.new(0, 0, 1, -3)
    progressBar.BackgroundColor3 = self:GetThemeColor("Accent")
    progressBar.BorderSizePixel = 0
    progressBar.Parent = frame
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 1)
    progressCorner.Parent = progressBar
    
    -- Animate in
    CreateTween(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -370, 0, 20)
    })
    
    -- Progress animation
    CreateTween(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 0, 3)
    })
    
    -- Auto-dismiss
    task.spawn(function()
        task.wait(duration)
        
        CreateTween(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 20, 0, 20)
        })
        
        task.wait(0.3)
        notificationGui:Destroy()
    end)
    
    -- Click to dismiss
    local clickDetector = Instance.new("TextButton")
    clickDetector.Size = UDim2.new(1, 0, 1, 0)
    clickDetector.BackgroundTransparency = 1
    clickDetector.Text = ""
    clickDetector.Parent = frame
    
    self:AddConnection(clickDetector.MouseButton1Click:Connect(function()
        CreateTween(frame, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 20, 0, 20)
        })
        
        task.wait(0.2)
        notificationGui:Destroy()
    end))
    
    return notificationGui
end

-- Enhanced Window Creation with Mobile Support
function UltimateUI:CreateWindow(options)
    options = options or {}
    local title = options.Title or "UltimateUI"
    local size = options.Size or (self.IsMobile and UDim2.new(0, 400, 0, 500) or UDim2.new(0, 600, 0, 400))
    
    -- Load saved configuration
    self:LoadConfig()
    
    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UltimateUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = CoreGui
    
    self.ScreenGui = screenGui
    
    -- Main Window Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = size
    mainFrame.Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
    mainFrame.BackgroundColor3 = self:GetThemeColor("Background")
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = self.WindowVisible
    mainFrame.Parent = screenGui
    
    self.MainFrame = mainFrame
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame
    
    -- Shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = self:GetThemeColor("Shadow")
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(99, 99, 99, 99)
    shadow.ZIndex = -1
    shadow.Parent = mainFrame
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = self:GetThemeColor("Secondary")
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    
    local titleFix = Instance.new("Frame")
    titleFix.Size = UDim2.new(1, 0, 0, 20)
    titleFix.Position = UDim2.new(0, 0, 1, -20)
    titleFix.BackgroundColor3 = self:GetThemeColor("Secondary")
    titleFix.BorderSizePixel = 0
    titleFix.Parent = titleBar
    
    -- Title Text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.Size = UDim2.new(1, -100, 1, 0)
    titleText.Position = UDim2.new(0, 15, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = title
    titleText.TextColor3 = self:GetThemeColor("Text")
    titleText.TextSize = 16
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Font = Enum.Font.GothamBold
    titleText.Parent = titleBar
    
    -- Control Buttons
    local controlFrame = Instance.new("Frame")
    controlFrame.Name = "Controls"
    controlFrame.Size = UDim2.new(0, 80, 1, 0)
    controlFrame.Position = UDim2.new(1, -80, 0, 0)
    controlFrame.BackgroundTransparency = 1
    controlFrame.Parent = titleBar
    
    local controlLayout = Instance.new("UIListLayout")
    controlLayout.FillDirection = Enum.FillDirection.Horizontal
    controlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    controlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    controlLayout.Padding = UDim.new(0, 5)
    controlLayout.Parent = controlFrame
    
    -- Minimize Button
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeBtn"
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.BackgroundColor3 = self:GetThemeColor("Background")
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = self:GetThemeColor("Text")
    minimizeBtn.TextSize = 16
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = controlFrame
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 6)
    minimizeCorner.Parent = minimizeBtn
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.BackgroundColor3 = self:GetThemeColor("Error")
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = controlFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn
    
    -- Tab Container
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(0, 150, 1, -40)
    tabContainer.Position = UDim2.new(0, 0, 0, 40)
    tabContainer.BackgroundColor3 = self:GetThemeColor("Secondary")
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = mainFrame
    
    local tabList = Instance.new("ScrollingFrame")
    tabList.Name = "TabList"
    tabList.Size = UDim2.new(1, 0, 1, -10)
    tabList.Position = UDim2.new(0, 0, 0, 10)
    tabList.BackgroundTransparency = 1
    tabList.BorderSizePixel = 0
    tabList.ScrollBarThickness = 4
    tabList.ScrollBarImageColor3 = self:GetThemeColor("Accent")
    tabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabList.Parent = tabContainer
    
    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabListLayout.Padding = UDim.new(0, 5)
    tabListLayout.Parent = tabList
    
    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingLeft = UDim.new(0, 10)
    tabPadding.PaddingRight = UDim.new(0, 10)
    tabPadding.PaddingTop = UDim.new(0, 5)
    tabPadding.Parent = tabList
    
    -- Content Container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -150, 1, -40)
    contentContainer.Position = UDim2.new(0, 150, 0, 40)
    contentContainer.BackgroundColor3 = self:GetThemeColor("Background")
    contentContainer.BorderSizePixel = 0
    contentContainer.Parent = mainFrame
    
    -- Add theme objects
    self:AddThemeObject(mainFrame, {BackgroundColor3 = "Background"})
    self:AddThemeObject(titleBar, {BackgroundColor3 = "Secondary"})
    self:AddThemeObject(titleFix, {BackgroundColor3 = "Secondary"})
    self:AddThemeObject(titleText, {TextColor3 = "Text"})
    self:AddThemeObject(minimizeBtn, {BackgroundColor3 = "Background", TextColor3 = "Text"})
    self:AddThemeObject(closeBtn, {BackgroundColor3 = "Error"})
    self:AddThemeObject(tabContainer, {BackgroundColor3 = "Secondary"})
    self:AddThemeObject(tabList, {ScrollBarImageColor3 = "Accent"})
    self:AddThemeObject(contentContainer, {BackgroundColor3 = "Background"})
    
    -- Enhanced Mobile Toggle Button with proper functionality
    local mobileToggle = nil
    if self.IsMobile or self.TouchSupport then
        mobileToggle = Instance.new("TextButton")
        mobileToggle.Name = "MobileToggle"
        mobileToggle.Size = UDim2.new(0, 60, 0, 60)
        mobileToggle.Position = UDim2.new(1, -80, 1, -80)
        mobileToggle.BackgroundColor3 = self:GetThemeColor("Accent")
        mobileToggle.BorderSizePixel = 0
        mobileToggle.Text = "UI"
        mobileToggle.TextColor3 = Color3.new(1, 1, 1)
        mobileToggle.TextSize = 18
        mobileToggle.Font = Enum.Font.GothamBold
        mobileToggle.ZIndex = 100
        mobileToggle.Parent = screenGui
        
        local mobileCorner = Instance.new("UICorner")
        mobileCorner.CornerRadius = UDim.new(0, 30)
        mobileCorner.Parent = mobileToggle
        
        -- Add mobile button glow
        local mobileGlow = Instance.new("ImageLabel")
        mobileGlow.Name = "Glow"
        mobileGlow.Size = UDim2.new(0, 80, 0, 80)
        mobileGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
        mobileGlow.AnchorPoint = Vector2.new(0.5, 0.5)
        mobileGlow.BackgroundTransparency = 1
        mobileGlow.Image = self:GetThemeColor("Glow")
        mobileGlow.ImageColor3 = self:GetThemeColor("Accent")
        mobileGlow.ImageTransparency = 0.5
        mobileGlow.ZIndex = -1
        mobileGlow.Parent = mobileToggle
        
        self.MobileButton = mobileToggle
        
        -- Enhanced mobile button functionality
        local function toggleWindow()
            self.WindowVisible = not self.WindowVisible
            mainFrame.Visible = self.WindowVisible
            
            -- Update button appearance
            CreateTween(mobileToggle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = self.WindowVisible and self:GetThemeColor("Accent") or self:GetThemeColor("TextSecondary")
            })
            
            CreateTween(mobileGlow, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                ImageTransparency = self.WindowVisible and 0.5 or 0.8
            })
            
            -- Save state
            self:SaveConfig()
            
            -- Show feedback
            self:Notify({
                Title = "UI " .. (self.WindowVisible and "Shown" or "Hidden"),
                Content = "Interface has been " .. (self.WindowVisible and "opened" or "closed"),
                Duration = 2,
                Icon = self.WindowVisible and "check" or "x"
            })
        end
        
        -- Add click handlers for mobile button
        self:AddConnection(mobileToggle.MouseButton1Click:Connect(toggleWindow))
        
        -- Enhanced touch support
        if self.TouchSupport then
            self:AddConnection(mobileToggle.TouchTap:Connect(toggleWindow))
        end
        
        -- Mobile button hover effects
        self:AddConnection(mobileToggle.MouseEnter:Connect(function()
            CreateTween(mobileToggle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, 65, 0, 65)
            })
            CreateTween(mobileGlow, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                ImageTransparency = 0.3
            })
        end))
        
        self:AddConnection(mobileToggle.MouseLeave:Connect(function()
            CreateTween(mobileToggle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, 60, 0, 60)
            })
            CreateTween(mobileGlow, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                ImageTransparency = self.WindowVisible and 0.5 or 0.8
            })
        end))
        
        self:AddThemeObject(mobileToggle, {BackgroundColor3 = "Accent"})
        self:AddThemeObject(mobileGlow, {ImageColor3 = "Accent"})
    end
    
    -- Enhanced Dragging System (Based on WindUI and Atonium patterns)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    local function updateDrag(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        CreateTween(mainFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
            Position = newPos
        })
    end
    
    self:AddConnection(titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           (self.TouchSupport and input.UserInputType == Enum.UserInputType.Touch) then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end))
    
    self:AddConnection(titleBar.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
           (self.TouchSupport and input.UserInputType == Enum.UserInputType.Touch)) then
            updateDrag(input)
        end
    end))
    
    -- Window Control Functions
    self:AddConnection(minimizeBtn.MouseButton1Click:Connect(function()
        self.WindowVisible = false
        mainFrame.Visible = false
        self:SaveConfig()
        
        self:Notify({
            Title = "Window Minimized",
            Content = "Use the keybind or mobile button to restore",
            Duration = 3,
            Icon = "minus"
        })
    end))
    
    self:AddConnection(closeBtn.MouseButton1Click:Connect(function()
        self:Disconnect()
        screenGui:Destroy()
        
        -- Also destroy mobile button if it exists
        if mobileToggle then
            mobileToggle:Destroy()
        end
    end))
    
    -- Keybind handler
    self:AddConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == self.WindowKeybind then
            self.WindowVisible = not self.WindowVisible
            mainFrame.Visible = self.WindowVisible
            self:SaveConfig()
        end
    end))
    
    -- Window Object
    local Window = {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        TabContainer = tabContainer,
        TabList = tabList,
        TabListLayout = tabListLayout,
        ContentContainer = contentContainer,
        MobileToggle = mobileToggle,
        Tabs = {},
        CurrentTab = nil,
    }
    
    self.CurrentWindow = Window
    
    -- Tab Creation Method with Enhanced Mobile Support
    function Window:CreateTab(options)
        options = options or {}
        local name = options.Name or "Tab"
        local icon = options.Icon or "settings"
        local layoutOrder = options.LayoutOrder or (#self.Tabs + 1)
        
        -- Tab Button
        local tabButton = Instance.new("TextButton")
        tabButton.Name = "Tab_" .. name
        tabButton.Size = UDim2.new(1, 0, 0, UltimateUI.IsMobile and 50 or 40)
        tabButton.BackgroundColor3 = UltimateUI:GetThemeColor("Background")
        tabButton.BorderSizePixel = 0
        tabButton.Text = ""
        tabButton.LayoutOrder = layoutOrder
        tabButton.Parent = self.TabList
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 8)
        tabCorner.Parent = tabButton
        
        -- Tab Icon
        local tabIcon = Instance.new("ImageLabel")
        tabIcon.Name = "Icon"
        tabIcon.Size = UDim2.new(0, 20, 0, 20)
        tabIcon.Position = UDim2.new(0, 15, 0.5, 0)
        tabIcon.AnchorPoint = Vector2.new(0, 0.5)
        tabIcon.BackgroundTransparency = 1
        tabIcon.Image = UltimateUI.Icons[icon] or UltimateUI.Icons.settings
        tabIcon.ImageColor3 = UltimateUI:GetThemeColor("TextSecondary")
        tabIcon.Parent = tabButton
        
        -- Tab Text
        local tabText = Instance.new("TextLabel")
        tabText.Name = "Text"
        tabText.Size = UDim2.new(1, -50, 1, 0)
        tabText.Position = UDim2.new(0, 45, 0, 0)
        tabText.BackgroundTransparency = 1
        tabText.Text = name
        tabText.TextColor3 = UltimateUI:GetThemeColor("TextSecondary")
        tabText.TextSize = UltimateUI.IsMobile and 16 or 14
        tabText.TextXAlignment = Enum.TextXAlignment.Left
        tabText.Font = Enum.Font.GothamSemibold
        tabText.Parent = tabButton
        
        -- Tab Content Frame
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = "Content_" .. name
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.Position = UDim2.new(0, 0, 0, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 6
        tabContent.ScrollBarImageColor3 = UltimateUI:GetThemeColor("Accent")
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.Visible = false
        tabContent.Parent = self.ContentContainer
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 8)
        contentLayout.Parent = tabContent
        
        local contentPadding = Instance.new("UIPadding")
        contentPadding.PaddingLeft = UDim.new(0, 20)
        contentPadding.PaddingRight = UDim.new(0, 20)
        contentPadding.PaddingTop = UDim.new(0, 20)
        contentPadding.PaddingBottom = UDim.new(0, 20)
        contentPadding.Parent = tabContent
        
        -- Auto-resize canvas
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 40)
        end)
        
        -- Theme objects
        UltimateUI:AddThemeObject(tabButton, {BackgroundColor3 = "Background"})
        UltimateUI:AddThemeObject(tabIcon, {ImageColor3 = "TextSecondary"})
        UltimateUI:AddThemeObject(tabText, {TextColor3 = "TextSecondary"})
        UltimateUI:AddThemeObject(tabContent, {ScrollBarImageColor3 = "Accent"})
        
        -- Tab Object
        local Tab = {
            Button = tabButton,
            Icon = tabIcon,
            Text = tabText,
            Content = tabContent,
            Layout = contentLayout,
            Name = name,
            Active = false,
            Elements = {},
        }
        
        -- Tab activation methods
        function Tab:Activate()
            -- Deactivate other tabs
            for _, otherTab in pairs(Window.Tabs) do
                if otherTab.Active then
                    otherTab:Deactivate()
                end
            end
            
            self.Active = true
            Window.CurrentTab = self
            
            -- Update appearance with smooth animations
            CreateTween(self.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = UltimateUI:GetThemeColor("Accent")
            })
            CreateTween(self.Icon, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                ImageColor3 = Color3.new(1, 1, 1)
            })
            CreateTween(self.Text, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                TextColor3 = Color3.new(1, 1, 1)
            })
            
            self.Content.Visible = true
        end
        
        function Tab:Deactivate()
            self.Active = false
            
            -- Update appearance
            CreateTween(self.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = UltimateUI:GetThemeColor("Background")
            })
            CreateTween(self.Icon, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                ImageColor3 = UltimateUI:GetThemeColor("TextSecondary")
            })
            CreateTween(self.Text, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                TextColor3 = UltimateUI:GetThemeColor("TextSecondary")
            })
            
            self.Content.Visible = false
        end
        
        -- Enhanced Click/Touch handlers
        local function activateTab()
            Tab:Activate()
        end
        
        UltimateUI:AddConnection(tabButton.MouseButton1Click:Connect(activateTab))
        
        -- Enhanced touch support for mobile
        if UltimateUI.TouchSupport then
            UltimateUI:AddConnection(tabButton.TouchTap:Connect(activateTab))
        end
        
        -- Enhanced hover effects
        UltimateUI:AddConnection(tabButton.MouseEnter:Connect(function()
            if not Tab.Active then
                CreateTween(tabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                    BackgroundColor3 = UltimateUI:GetThemeColor("Tertiary")
                })
            end
        end))
        
        UltimateUI:AddConnection(tabButton.MouseLeave:Connect(function()
            if not Tab.Active then
                CreateTween(tabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                    BackgroundColor3 = UltimateUI:GetThemeColor("Background")
                })
            end
        end))
        
        -- Add to tabs list
        table.insert(self.Tabs, Tab)
        
        -- If this is the first tab, activate it
        if #self.Tabs == 1 then
            Tab:Activate()
        end
        
        return Tab
    end
    
    return Window
end

-- Component Creation Methods with Enhanced Mobile Support
function Tab:CreateSection(options)
    options = options or {}
    local name = options.Name or "Section"
    
    local section = Instance.new("TextLabel")
    section.Name = "Section_" .. name
    section.Size = UDim2.new(1, 0, 0, 30)
    section.BackgroundTransparency = 1
    section.Text = name
    section.TextColor3 = UltimateUI:GetThemeColor("Text")
    section.TextSize = 16
    section.TextXAlignment = Enum.TextXAlignment.Left
    section.Font = Enum.Font.GothamBold
    section.LayoutOrder = #self.Elements + 1
    section.Parent = self.Content
    
    UltimateUI:AddThemeObject(section, {TextColor3 = "Text"})
    
    table.insert(self.Elements, section)
    return section
end

function Tab:CreateToggle(options)
    options = options or {}
    local name = options.Name or "Toggle"
    local flag = options.Flag or name:lower():gsub(" ", "_")
    local default = options.Default or false
    local callback = options.Callback or function() end
    local mobileOptimized = options.MobileOptimized or false
    
    -- Initialize flag
    if UltimateUI.Flags[flag] == nil then
        UltimateUI.Flags[flag] = default
    end
    
    -- Main toggle frame (Enhanced from Atonium patterns)
    local toggleFrame = Instance.new("TextButton")
    toggleFrame.Name = "Toggle_" .. name
    toggleFrame.Size = UDim2.new(1, 0, 0, mobileOptimized and 50 or 42)
    toggleFrame.BackgroundColor3 = UltimateUI:GetThemeColor("Secondary")
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Text = ""
    toggleFrame.LayoutOrder = #self.Elements + 1
    toggleFrame.Parent = self.Content
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12)
    toggleCorner.Parent = toggleFrame
    
    -- Toggle text
    local toggleText = Instance.new("TextLabel")
    toggleText.Name = "Text"
    toggleText.Size = UDim2.new(1, -60, 1, 0)
    toggleText.Position = UDim2.new(0, 15, 0, 0)
    toggleText.BackgroundTransparency = 1
    toggleText.Text = name
    toggleText.TextColor3 = UltimateUI:GetThemeColor("Text")
    toggleText.TextSize = mobileOptimized and 16 or 14
    toggleText.TextXAlignment = Enum.TextXAlignment.Left
    toggleText.Font = Enum.Font.GothamSemibold
    toggleText.Parent = toggleFrame
    
    -- Checkbox container
    local checkbox = Instance.new("Frame")
    checkbox.Name = "Checkbox"
    checkbox.Size = UDim2.new(0, mobileOptimized and 24 or 20, 0, mobileOptimized and 24 or 20)
    checkbox.Position = UDim2.new(1, mobileOptimized and -35 or -30, 0.5, 0)
    checkbox.AnchorPoint = Vector2.new(0, 0.5)
    checkbox.BackgroundColor3 = UltimateUI:GetThemeColor("Tertiary")
    checkbox.BorderSizePixel = 0
    checkbox.Parent = toggleFrame
    
    local checkboxCorner = Instance.new("UICorner")
    checkboxCorner.CornerRadius = UDim.new(0, 6)
    checkboxCorner.Parent = checkbox
    
    -- Checkbox fill (for active state)
    local checkboxFill = Instance.new("Frame")
    checkboxFill.Name = "Fill"
    checkboxFill.Size = UDim2.new(1, 0, 1, 0)
    checkboxFill.BackgroundTransparency = 1
    checkboxFill.BorderSizePixel = 0
    checkboxFill.Parent = checkbox
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 6)
    fillCorner.Parent = checkboxFill
    
    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = UltimateUI:GetThemeColor("AccentGradient")
    fillGradient.Rotation = 20
    fillGradient.Parent = checkboxFill
    
    -- Checkbox glow
    local checkboxGlow = Instance.new("ImageLabel")
    checkboxGlow.Name = "Glow"
    checkboxGlow.Size = UDim2.new(0, (mobileOptimized and 24 or 20) + 10, 0, (mobileOptimized and 24 or 20) + 10)
    checkboxGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    checkboxGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    checkboxGlow.BackgroundTransparency = 1
    checkboxGlow.Image = UltimateUI:GetThemeColor("Glow")
    checkboxGlow.ImageColor3 = UltimateUI:GetThemeColor("Accent")
    checkboxGlow.ImageTransparency = 1
    checkboxGlow.ZIndex = -1
    checkboxGlow.Parent = checkbox
    
    -- Theme objects
    UltimateUI:AddThemeObject(toggleFrame, {BackgroundColor3 = "Secondary"})
    UltimateUI:AddThemeObject(toggleText, {TextColor3 = "Text"})
    UltimateUI:AddThemeObject(checkbox, {BackgroundColor3 = "Tertiary"})
    UltimateUI:AddThemeObject(checkboxGlow, {ImageColor3 = "Accent"})
    
    -- Toggle object with enhanced methods
    local Toggle = {
        Frame = toggleFrame,
        Checkbox = checkbox,
        Fill = checkboxFill,
        Glow = checkboxGlow,
        Flag = flag,
        Callback = callback,
        State = UltimateUI.Flags[flag]
    }
    
    function Toggle:Set(value, silent)
        self.State = value
        UltimateUI.Flags[self.Flag] = value
        
        if value then
            self:Enable()
        else
            self:Disable()
        end
        
        if not silent then
            SafeCallback(self.Callback, value)
        end
        
        UltimateUI:SaveConfig()
    end
    
    function Toggle:Enable()
        CreateTween(self.Fill, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 0
        })
        
        CreateTween(self.Glow, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            ImageTransparency = 0.7
        })
    end
    
    function Toggle:Disable()
        CreateTween(self.Fill, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 1
        })
        
        CreateTween(self.Glow, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            ImageTransparency = 1
        })
    end
    
    -- Enhanced Click handler
    local function toggleState()
        Toggle:Set(not Toggle.State)
    end
    
    UltimateUI:AddConnection(toggleFrame.MouseButton1Click:Connect(toggleState))
    
    -- Enhanced touch support for mobile
    if UltimateUI.TouchSupport and mobileOptimized then
        UltimateUI:AddConnection(toggleFrame.TouchTap:Connect(toggleState))
    end
    
    -- Enhanced hover effects
    UltimateUI:AddConnection(toggleFrame.MouseEnter:Connect(function()
        CreateTween(toggleFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = UltimateUI:GetThemeColor("Tertiary")
        })
    end))
    
    UltimateUI:AddConnection(toggleFrame.MouseLeave:Connect(function()
        CreateTween(toggleFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = UltimateUI:GetThemeColor("Secondary")
        })
    end))
    
    -- Set initial state
    Toggle:Set(Toggle.State, true)
    
    table.insert(self.Elements, Toggle)
    return Toggle
end

function Tab:CreateButton(options)
    options = options or {}
    local name = options.Name or "Button"
    local description = options.Description
    local callback = options.Callback or function() end
    
    -- Button frame
    local buttonFrame = Instance.new("TextButton")
    buttonFrame.Name = "Button_" .. name
    buttonFrame.Size = UDim2.new(1, 0, 0, description and 60 or 42)
    buttonFrame.BackgroundColor3 = UltimateUI:GetThemeColor("Secondary")
    buttonFrame.BorderSizePixel = 0
    buttonFrame.Text = ""
    buttonFrame.LayoutOrder = #self.Elements + 1
    buttonFrame.Parent = self.Content
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 12)
    buttonCorner.Parent = buttonFrame
    
    -- Button content frame
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -30, 1, 0)
    contentFrame.Position = UDim2.new(0, 15, 0, 0)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = buttonFrame
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.FillDirection = Enum.FillDirection.Vertical
    contentLayout.VerticalAlignment = description and Enum.VerticalAlignment.Center or Enum.VerticalAlignment.Center
    contentLayout.Parent = contentFrame
    
    -- Button title
    local buttonTitle = Instance.new("TextLabel")
    buttonTitle.Name = "Title"
    buttonTitle.Size = UDim2.new(1, 0, 0, 20)
    buttonTitle.BackgroundTransparency = 1
    buttonTitle.Text = name
    buttonTitle.TextColor3 = UltimateUI:GetThemeColor("Text")
    buttonTitle.TextSize = 14
    buttonTitle.TextXAlignment = Enum.TextXAlignment.Left
    buttonTitle.Font = Enum.Font.GothamSemibold
    buttonTitle.Parent = contentFrame
    
    -- Button description (if provided)
    local buttonDesc = nil
    if description then
        buttonDesc = Instance.new("TextLabel")
        buttonDesc.Name = "Description"
        buttonDesc.Size = UDim2.new(1, 0, 0, 16)
        buttonDesc.BackgroundTransparency = 1
        buttonDesc.Text = description
        buttonDesc.TextColor3 = UltimateUI:GetThemeColor("TextSecondary")
        buttonDesc.TextSize = 12
        buttonDesc.TextXAlignment = Enum.TextXAlignment.Left
        buttonDesc.Font = Enum.Font.Gotham
        buttonDesc.Parent = contentFrame
    end
    
    -- Button arrow indicator
    local arrow = Instance.new("ImageLabel")
    arrow.Name = "Arrow"
    arrow.Size = UDim2.new(0, 16, 0, 16)
    arrow.Position = UDim2.new(1, -25, 0.5, 0)
    arrow.AnchorPoint = Vector2.new(0, 0.5)
    arrow.BackgroundTransparency = 1
    arrow.Image = UltimateUI.Icons.arrow_right
    arrow.ImageColor3 = UltimateUI:GetThemeColor("TextSecondary")
    arrow.Parent = buttonFrame
    
    -- Theme objects
    UltimateUI:AddThemeObject(buttonFrame, {BackgroundColor3 = "Secondary"})
    UltimateUI:AddThemeObject(buttonTitle, {TextColor3 = "Text"})
    if buttonDesc then
        UltimateUI:AddThemeObject(buttonDesc, {TextColor3 = "TextSecondary"})
    end
    UltimateUI:AddThemeObject(arrow, {ImageColor3 = "TextSecondary"})
    
    -- Button object
    local Button = {
        Frame = buttonFrame,
        Title = buttonTitle,
        Description = buttonDesc,
        Arrow = arrow,
        Callback = callback
    }
    
    -- Enhanced Click handler with animation
    local function handleClick()
        -- Click animation
        CreateTween(buttonFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
            Size = UDim2.new(1, -4, 0, (description and 60 or 42) - 2)
        })
        
        CreateTween(arrow, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
            Position = UDim2.new(1, -20, 0.5, 0)
        })
        
        task.wait(0.1)
        
        CreateTween(buttonFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
            Size = UDim2.new(1, 0, 0, description and 60 or 42)
        })
        
        CreateTween(arrow, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
            Position = UDim2.new(1, -25, 0.5, 0)
        })
        
        SafeCallback(callback)
    end
    
    UltimateUI:AddConnection(buttonFrame.MouseButton1Click:Connect(handleClick))
    
    -- Enhanced touch support
    if UltimateUI.TouchSupport then
        UltimateUI:AddConnection(buttonFrame.TouchTap:Connect(function()
            SafeCallback(callback)
        end))
    end
    
    -- Enhanced hover effects
    UltimateUI:AddConnection(buttonFrame.MouseEnter:Connect(function()
        CreateTween(buttonFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = UltimateUI:GetThemeColor("Tertiary")
        })
        
        CreateTween(arrow, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            ImageColor3 = UltimateUI:GetThemeColor("Accent")
        })
    end))
    
    UltimateUI:AddConnection(buttonFrame.MouseLeave:Connect(function()
        CreateTween(buttonFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = UltimateUI:GetThemeColor("Secondary")
        })
        
        CreateTween(arrow, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            ImageColor3 = UltimateUI:GetThemeColor("TextSecondary")
        })
    end))
    
    table.insert(self.Elements, Button)
    return Button
end

function Tab:CreateSlider(options)
    options = options or {}
    local name = options.Name or "Slider"
    local flag = options.Flag or name:lower():gsub(" ", "_")
    local range = options.Range or {0, 100}
    local increment = options.Increment or 1
    local default = options.Default or range[1]
    local suffix = options.Suffix or ""
    local callback = options.Callback or function() end
    
    -- Initialize flag
    if UltimateUI.Flags[flag] == nil then
        UltimateUI.Flags[flag] = default
    end
    
    -- Slider frame (Enhanced from Atonium patterns)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = "Slider_" .. name
    sliderFrame.Size = UDim2.new(1, 0, 0, 65)
    sliderFrame.BackgroundColor3 = UltimateUI:GetThemeColor("Secondary")
    sliderFrame.BorderSizePixel = 0
    sliderFrame.LayoutOrder = #self.Elements + 1
    sliderFrame.Parent = self.Content
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 12)
    sliderCorner.Parent = sliderFrame
    
    -- Slider title and value
    local titleFrame = Instance.new("Frame")
    titleFrame.Size = UDim2.new(1, -30, 0, 25)
    titleFrame.Position = UDim2.new(0, 15, 0, 10)
    titleFrame.BackgroundTransparency = 1
    titleFrame.Parent = sliderFrame
    
    local sliderTitle = Instance.new("TextLabel")
    sliderTitle.Name = "Title"
    sliderTitle.Size = UDim2.new(1, -60, 1, 0)
    sliderTitle.Position = UDim2.new(0, 0, 0, 0)
    sliderTitle.BackgroundTransparency = 1
    sliderTitle.Text = name
    sliderTitle.TextColor3 = UltimateUI:GetThemeColor("Text")
    sliderTitle.TextSize = 14
    sliderTitle.TextXAlignment = Enum.TextXAlignment.Left
    sliderTitle.Font = Enum.Font.GothamSemibold
    sliderTitle.Parent = titleFrame
    
    local sliderValue = Instance.new("TextLabel")
    sliderValue.Name = "Value"
    sliderValue.Size = UDim2.new(0, 60, 1, 0)
    sliderValue.Position = UDim2.new(1, -60, 0, 0)
    sliderValue.BackgroundTransparency = 1
    sliderValue.Text = tostring(UltimateUI.Flags[flag]) .. suffix
    sliderValue.TextColor3 = UltimateUI:GetThemeColor("Accent")
    sliderValue.TextSize = 14
    sliderValue.TextXAlignment = Enum.TextXAlignment.Right
    sliderValue.Font = Enum.Font.GothamBold
    sliderValue.Parent = titleFrame
    
    -- Slider track
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Name = "Track"
    sliderTrack.Size = UDim2.new(1, -30, 0, 8)
    sliderTrack.Position = UDim2.new(0, 15, 0, 45)
    sliderTrack.BackgroundColor3 = UltimateUI:GetThemeColor("Tertiary")
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = sliderFrame
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 4)
    trackCorner.Parent = sliderTrack
    
    -- Slider fill
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    sliderFill.Size = UDim2.new(0, 0, 1, 0)
    sliderFill.BackgroundTransparency = 0
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderTrack
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = sliderFill
    
    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = UltimateUI:GetThemeColor("AccentGradient")
    fillGradient.Rotation = 90
    fillGradient.Parent = sliderFill
    
    -- Theme objects
    UltimateUI:AddThemeObject(sliderFrame, {BackgroundColor3 = "Secondary"})
    UltimateUI:AddThemeObject(sliderTitle, {TextColor3 = "Text"})
    UltimateUI:AddThemeObject(sliderValue, {TextColor3 = "Accent"})
    UltimateUI:AddThemeObject(sliderTrack, {BackgroundColor3 = "Tertiary"})
    
    -- Slider object
    local Slider = {
        Frame = sliderFrame,
        Track = sliderTrack,
        Fill = sliderFill,
        Value = sliderValue,
        Flag = flag,
        Callback = callback,
        Range = range,
        Increment = increment,
        Suffix = suffix,
        CurrentValue = UltimateUI.Flags[flag]
    }
    
    function Slider:UpdateVisual(value)
        local percentage = (value - self.Range[1]) / (self.Range[2] - self.Range[1])
        percentage = math.clamp(percentage, 0, 1)
        
        CreateTween(self.Fill, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Size = UDim2.new(percentage, 0, 1, 0)
        })
        
        self.Value.Text = tostring(value) .. self.Suffix
    end
    
    function Slider:Set(value, silent)
        value = math.clamp(value, self.Range[1], self.Range[2])
        value = math.floor(value / self.Increment + 0.5) * self.Increment
        
        self.CurrentValue = value
        UltimateUI.Flags[self.Flag] = value
        
        self:UpdateVisual(value)
        
        if not silent then
            SafeCallback(self.Callback, value)
        end
        
        UltimateUI:SaveConfig()
    end
    
    function Slider:UpdateFromMouse()
        local percentage = math.clamp((Mouse.X - self.Track.AbsolutePosition.X) / self.Track.AbsoluteSize.X, 0, 1)
        local value = self.Range[1] + (self.Range[2] - self.Range[1]) * percentage
        self:Set(value)
    end
    
    -- Enhanced mouse/touch interaction
    local dragging = false
    
    UltimateUI:AddConnection(sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           (UltimateUI.TouchSupport and input.UserInputType == Enum.UserInputType.Touch) then
            dragging = true
            Slider:UpdateFromMouse()
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end))
    
    UltimateUI:AddConnection(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
           (UltimateUI.TouchSupport and input.UserInputType == Enum.UserInputType.Touch)) then
            Slider:UpdateFromMouse()
        end
    end))
    
    -- Set initial value
    Slider:Set(Slider.CurrentValue, true)
    
    table.insert(self.Elements, Slider)
    return Slider
end

function Tab:CreateDropdown(options)
    options = options or {}
    local name = options.Name or "Dropdown"
    local flag = options.Flag or name:lower():gsub(" ", "_")
    local items = options.Items or {}
    local default = options.Default or (options.MultiSelect and {} or items[1])
    local multiSelect = options.MultiSelect or false
    local callback = options.Callback or function() end
    
    -- Initialize flag
    if UltimateUI.Flags[flag] == nil then
        UltimateUI.Flags[flag] = default
    end
    
    -- Dropdown frame
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = "Dropdown_" .. name
    dropdownFrame.Size = UDim2.new(1, 0, 0, 42)
    dropdownFrame.BackgroundTransparency = 1
    dropdownFrame.LayoutOrder = #self.Elements + 1
    dropdownFrame.Parent = self.Content
    
    -- Main dropdown button
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Name = "Button"
    dropdownButton.Size = UDim2.new(1, 0, 0, 42)
    dropdownButton.BackgroundColor3 = UltimateUI:GetThemeColor("Secondary")
    dropdownButton.BorderSizePixel = 0
    dropdownButton.Text = ""
    dropdownButton.Parent = dropdownFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 12)
    buttonCorner.Parent = dropdownButton
    
    -- Dropdown text
    local dropdownText = Instance.new("TextLabel")
    dropdownText.Name = "Text"
    dropdownText.Size = UDim2.new(1, -60, 1, 0)
    dropdownText.Position = UDim2.new(0, 15, 0, 0)
    dropdownText.BackgroundTransparency = 1
    dropdownText.Text = name
    dropdownText.TextColor3 = UltimateUI:GetThemeColor("Text")
    dropdownText.TextSize = 14
    dropdownText.TextXAlignment = Enum.TextXAlignment.Left
    dropdownText.Font = Enum.Font.GothamSemibold
    dropdownText.Parent = dropdownButton
    
    -- Selected value display
    local selectedValue = Instance.new("TextLabel")
    selectedValue.Name = "SelectedValue"
    selectedValue.Size = UDim2.new(0, 100, 1, 0)
    selectedValue.Position = UDim2.new(1, -130, 0, 0)
    selectedValue.BackgroundTransparency = 1
    selectedValue.Text = multiSelect and "None" or (UltimateUI.Flags[flag] or "None")
    selectedValue.TextColor3 = UltimateUI:GetThemeColor("TextSecondary")
    selectedValue.TextSize = 12
    selectedValue.TextXAlignment = Enum.TextXAlignment.Right
    selectedValue.Font = Enum.Font.Gotham
    selectedValue.Parent = dropdownButton
    
    -- Dropdown arrow
    local dropdownArrow = Instance.new("ImageLabel")
    dropdownArrow.Name = "Arrow"
    dropdownArrow.Size = UDim2.new(0, 16, 0, 16)
    dropdownArrow.Position = UDim2.new(1, -25, 0.5, 0)
    dropdownArrow.AnchorPoint = Vector2.new(0, 0.5)
    dropdownArrow.BackgroundTransparency = 1
    dropdownArrow.Image = UltimateUI.Icons.arrow_down
    dropdownArrow.ImageColor3 = UltimateUI:GetThemeColor("TextSecondary")
    dropdownArrow.Parent = dropdownButton
    
    -- Dropdown list (initially hidden)
    local dropdownList = Instance.new("Frame")
    dropdownList.Name = "List"
    dropdownList.Size = UDim2.new(1, 0, 0, math.min(#items * (UltimateUI.IsMobile and 40 or 30), 200))
    dropdownList.Position = UDim2.new(0, 0, 0, 50)
    dropdownList.BackgroundColor3 = UltimateUI:GetThemeColor("Background")
    dropdownList.BorderSizePixel = 0
    dropdownList.Visible = false
    dropdownList.ZIndex = 10
    dropdownList.Parent = dropdownFrame
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 12)
    listCorner.Parent = dropdownList
    
    local listStroke = Instance.new("UIStroke")
    listStroke.Color = UltimateUI:GetThemeColor("Border")
    listStroke.Thickness = 1
    listStroke.Parent = dropdownList
    
    -- Scrolling frame for items
    local itemScroll = Instance.new("ScrollingFrame")
    itemScroll.Size = UDim2.new(1, -10, 1, -10)
    itemScroll.Position = UDim2.new(0, 5, 0, 5)
    itemScroll.BackgroundTransparency = 1
    itemScroll.BorderSizePixel = 0
    itemScroll.ScrollBarThickness = 4
    itemScroll.ScrollBarImageColor3 = UltimateUI:GetThemeColor("Accent")
    itemScroll.CanvasSize = UDim2.new(0, 0, 0, #items * (UltimateUI.IsMobile and 40 or 30))
    itemScroll.Parent = dropdownList
    
    local itemLayout = Instance.new("UIListLayout")
    itemLayout.SortOrder = Enum.SortOrder.LayoutOrder
    itemLayout.Parent = itemScroll
    
    -- Theme objects
    UltimateUI:AddThemeObject(dropdownButton, {BackgroundColor3 = "Secondary"})
    UltimateUI:AddThemeObject(dropdownText, {TextColor3 = "Text"})
    UltimateUI:AddThemeObject(selectedValue, {TextColor3 = "TextSecondary"})
    UltimateUI:AddThemeObject(dropdownArrow, {ImageColor3 = "TextSecondary"})
    UltimateUI:AddThemeObject(dropdownList, {BackgroundColor3 = "Background"})
    UltimateUI:AddThemeObject(listStroke, {Color = "Border"})
    UltimateUI:AddThemeObject(itemScroll, {ScrollBarImageColor3 = "Accent"})
    
    -- Dropdown object
    local Dropdown = {
        Frame = dropdownFrame,
        Button = dropdownButton,
        List = dropdownList,
        SelectedValue = selectedValue,
        Arrow = dropdownArrow,
        Flag = flag,
        Callback = callback,
        Items = items,
        MultiSelect = multiSelect,
        CurrentValue = UltimateUI.Flags[flag],
        IsOpen = false
    }
    
    function Dropdown:UpdateDisplay()
        if self.MultiSelect then
            local count = #self.CurrentValue
            if count == 0 then
                self.SelectedValue.Text = "None"
            elseif count == 1 then
                self.SelectedValue.Text = self.CurrentValue[1]
            else
                self.SelectedValue.Text = count .. " selected"
            end
        else
            self.SelectedValue.Text = self.CurrentValue or "None"
        end
    end
    
    function Dropdown:Set(value, silent)
        if self.MultiSelect then
            self.CurrentValue = value or {}
        else
            self.CurrentValue = value
        end
        
        UltimateUI.Flags[self.Flag] = self.CurrentValue
        self:UpdateDisplay()
        
        if not silent then
            SafeCallback(self.Callback, self.CurrentValue)
        end
        
        UltimateUI:SaveConfig()
    end
    
    function Dropdown:Toggle()
        self.IsOpen = not self.IsOpen
        self.List.Visible = self.IsOpen
        
        -- Animate arrow
        CreateTween(self.Arrow, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Rotation = self.IsOpen and 180 or 0
        })
        
        -- Update frame size
        local newSize = self.IsOpen and 
            UDim2.new(1, 0, 0, 42 + math.min(#self.Items * (UltimateUI.IsMobile and 40 or 30), 200) + 10) or 
            UDim2.new(1, 0, 0, 42)
        
        CreateTween(self.Frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Size = newSize
        })
    end
    
    -- Create dropdown items
    for i, item in ipairs(items) do
        local itemButton = Instance.new("TextButton")
        itemButton.Name = "Item_" .. i
        itemButton.Size = UDim2.new(1, 0, 0, UltimateUI.IsMobile and 40 or 30)
        itemButton.BackgroundColor3 = UltimateUI:GetThemeColor("Secondary")
        itemButton.BorderSizePixel = 0
        itemButton.Text = item
        itemButton.TextColor3 = UltimateUI:GetThemeColor("Text")
        itemButton.TextSize = 12
        itemButton.Font = Enum.Font.Gotham
        itemButton.LayoutOrder = i
        itemButton.Parent = itemScroll
        
        local itemCorner = Instance.new("UICorner")
        itemCorner.CornerRadius = UDim.new(0, 8)
        itemCorner.Parent = itemButton
        
        -- Selection indicator for multi-select
        if multiSelect then
            local indicator = Instance.new("Frame")
            indicator.Name = "Indicator"
            indicator.Size = UDim2.new(0, 3, 1, -6)
            indicator.Position = UDim2.new(0, 3, 0, 3)
            indicator.BackgroundColor3 = UltimateUI:GetThemeColor("Accent")
            indicator.BorderSizePixel = 0
            indicator.Visible = false
            indicator.Parent = itemButton
            
            local indicatorCorner = Instance.new("UICorner")
            indicatorCorner.CornerRadius = UDim.new(0, 2)
            indicatorCorner.Parent = indicator
            
            UltimateUI:AddThemeObject(indicator, {BackgroundColor3 = "Accent"})
        end
        
        -- Theme objects
        UltimateUI:AddThemeObject(itemButton, {BackgroundColor3 = "Secondary", TextColor3 = "Text"})
        
        -- Item click handler
        UltimateUI:AddConnection(itemButton.MouseButton1Click:Connect(function()
            if multiSelect then
                local currentSelection = Dropdown.CurrentValue or {}
                local index = table.find(currentSelection, item)
                
                if index then
                    table.remove(currentSelection, index)
                    if itemButton:FindFirstChild("Indicator") then
                        itemButton.Indicator.Visible = false
                    end
                else
                    table.insert(currentSelection, item)
                    if itemButton:FindFirstChild("Indicator") then
                        itemButton.Indicator.Visible = true
                    end
                end
                
                Dropdown:Set(currentSelection)
            else
                Dropdown:Set(item)
                Dropdown:Toggle() -- Close after selection for single-select
            end
        end))
        
        -- Hover effects
        UltimateUI:AddConnection(itemButton.MouseEnter:Connect(function()
            CreateTween(itemButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = UltimateUI:GetThemeColor("Tertiary")
            })
        end))
        
        UltimateUI:AddConnection(itemButton.MouseLeave:Connect(function()
            CreateTween(itemButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = UltimateUI:GetThemeColor("Secondary")
            })
        end))
    end
    
    -- Main button click handler
    UltimateUI:AddConnection(dropdownButton.MouseButton1Click:Connect(function()
        Dropdown:Toggle()
    end))
    
    -- Enhanced touch support
    if UltimateUI.TouchSupport then
        UltimateUI:AddConnection(dropdownButton.TouchTap:Connect(function()
            Dropdown:Toggle()
        end))
    end
    
    -- Hover effects for main button
    UltimateUI:AddConnection(dropdownButton.MouseEnter:Connect(function()
        CreateTween(dropdownButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = UltimateUI:GetThemeColor("Tertiary")
        })
    end))
    
    UltimateUI:AddConnection(dropdownButton.MouseLeave:Connect(function()
        CreateTween(dropdownButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = UltimateUI:GetThemeColor("Secondary")
        })
    end))
    
    -- Set initial state
    Dropdown:Set(Dropdown.CurrentValue, true)
    
    table.insert(self.Elements, Dropdown)
    return Dropdown
end

-- Return the UltimateUI library
return UltimateUI