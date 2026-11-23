local verifiedLoadstring = nil

local function loadstringAlterado()
    local globalsOk, globals = pcall(getgenv)
    if not globalsOk or type(globals) ~= "table" then
        return true
    end

    local fn = rawget(globals, "loadstring") or loadstring
    if type(fn) ~= "function" then
        return true
    end

    local debugInfo = type(debug) == "table" and debug.info or nil
    if type(debugInfo) ~= "function" then
        return true
    end

    local ok, origen = pcall(debugInfo, fn, "s")
    if not ok or origen ~= "[C]" then
        return true
    end

    verifiedLoadstring = fn
    return false
end

if loadstringAlterado() then
    warn("load cancelled: loadstring has been altered or is not available.")
    return
end

if not game:IsLoaded() then game.Loaded:Wait() end
-------------------------------------------------------------------------------
local cloneref = (type(cloneref) == "function" and cloneref) or function(instance)
    return instance
end

local getService = setmetatable({}, {
    __index = function(self, serviceName)
        local service = cloneref(game:GetService(serviceName))
        rawset(self, serviceName, service)
        return service
    end
})

local RbxAnalyticsService = getService.RbxAnalyticsService
local UserInputService = getService.UserInputService
local TweenService = getService.TweenService
local HttpService = getService.HttpService
local TextService = getService.TextService
local RunService = getService.RunService
local Workspace = getService.Workspace
local Lighting = getService.Lighting
local CoreGui = getService.CoreGui
local Players = getService.Players
-------------------------------------------------------------------------------
local LocalPlayer = Players.LocalPlayer

local Colors = {
    MainBG = Color3.fromRGB(10, 11, 22),
    MainBGTop = Color3.fromRGB(18, 16, 38),
    SecondaryBG = Color3.fromRGB(17, 19, 37),
    TertiaryBG = Color3.fromRGB(22, 24, 46),
    ElevatedBG = Color3.fromRGB(31, 33, 62),
    AccentCyan = Color3.fromRGB(22, 198, 255),
    Accent = Color3.fromRGB(112, 61, 255),
    AccentSoft = Color3.fromRGB(157, 128, 255),
    AccentGlow = Color3.fromRGB(226, 27, 255),
    TextPrimary = Color3.fromRGB(246, 247, 255),
    TextSecondary = Color3.fromRGB(176, 181, 214),
    TextMuted = Color3.fromRGB(112, 117, 156),
    Stroke = Color3.fromRGB(44, 46, 80),
    StrokeBright = Color3.fromRGB(86, 75, 143),
    Success = Color3.fromRGB(45, 224, 171),
    Warn = Color3.fromRGB(255, 184, 70),
    Error = Color3.fromRGB(255, 70, 136),
    White = Color3.new(1, 1, 1),
    Black = Color3.new(0, 0, 0)
}

local Config = {
    HeaderTitle = "VANTA",
    HeaderAccent = "HUB",
    -- CHANGED: subtitle reflects cracked build
    Subtitle = "crack by c6r6",
    WebsiteLink = "https://github.com/moumou31k-cyber/cracked-scripts",
    DiscordLink = "https://discord.gg/bbgjBrtA2",
    LoaderURL = "https://flowauth.net/v1/loaders/VantaHub.lua",
    AssetFolder = "VantaAssets",
    SuccessDelay = 3,
    Layout = "auto"
}

local FallbackIcons = {
    vanta = "rbxassetid://0",
    key = "rbxassetid://96510194465420",
    ["book-lock"] = "rbxassetid://118765061220571",
    ["gamepad-2"] = "rbxassetid://92483947987410",
    ["loader-2"] = "rbxassetid://116535712789945",
    check = "rbxassetid://93898873302694",
    ["wifi-off"] = "rbxassetid://74113634330106",
    ["alert-circle"] = "rbxassetid://83898160590116",
    x = "rbxassetid://110786993356448",
    ["book-key"] = "rbxassetid://116024426170705",
    ["external-link"] = "rbxassetid://129331830773832",
    shield = "rbxassetid://110987169760162",
    user = "rbxassetid://81589895647169",
    copy = "rbxassetid://78979572434545",
    clock = "rbxassetid://121808839832144"
}

local Assets = {
    Shadow = "rbxassetid://1316045217",
    Glow = "rbxassetid://8992230677"
}

local ApplyFont
do
    local FontFamilies = {
        Display = "rbxasset://fonts/families/Montserrat.json",
        Body = "rbxasset://fonts/families/BuilderSans.json",
        Mono = "rbxasset://fonts/families/RobotoMono.json"
    }

    local function MakeFont(family, weight)
        local ok, font = pcall(function()
            return Font.new(FontFamilies[family], weight, Enum.FontStyle.Normal)
        end)
        return ok and font or nil
    end

    local Fonts = {
        Title = MakeFont("Display", Enum.FontWeight.ExtraBold),
        Heading = MakeFont("Display", Enum.FontWeight.Bold),
        Label = MakeFont("Display", Enum.FontWeight.SemiBold),
        Body = MakeFont("Body", Enum.FontWeight.Regular),
        BodyMedium = MakeFont("Body", Enum.FontWeight.Medium),
        BodyBold = MakeFont("Body", Enum.FontWeight.Bold),
        Mono = MakeFont("Mono", Enum.FontWeight.Medium),
        MonoBold = MakeFont("Mono", Enum.FontWeight.Bold)
    }

    local LegacyFonts = {
        Title = Enum.Font.GothamBlack,
        Heading = Enum.Font.GothamBold,
        Label = Enum.Font.GothamBold,
        Body = Enum.Font.Gotham,
        BodyMedium = Enum.Font.GothamMedium,
        BodyBold = Enum.Font.GothamBold,
        Mono = Enum.Font.Code,
        MonoBold = Enum.Font.Code
    }

    function ApplyFont(object, style)
        local face = Fonts[style]
        if face and pcall(function() object.FontFace = face end) then
            return
        end
        pcall(function()
            object.Font = LegacyFonts[style] or Enum.Font.GothamMedium
        end)
    end
end

local function New(className, properties)
    local object = Instance.new(className)
    local parent, typeface, noFade = nil, nil, false
    for property, value in pairs(properties or {}) do
        if property == "Parent" then
            parent = value
        elseif property == "Typeface" then
            typeface = value
        elseif property == "NoFade" then
            noFade = value
        else
            object[property] = value
        end
    end
    if typeface then ApplyFont(object, typeface) end
    if noFade then object:SetAttribute("NoFade", true) end
    if parent then object.Parent = parent end
    return object
end

local function Corner(parent, radius)
    return New("UICorner", {
        CornerRadius = radius == "full" and UDim.new(1, 0) or UDim.new(0, radius or 8),
        Parent = parent
    })
end

local function Stroke(parent, color, thickness, transparency)
    return New("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        LineJoinMode = Enum.LineJoinMode.Round,
        Color = color or Colors.Stroke,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        Parent = parent
    })
end

local function Sequence(...)
    local values = {...}
    local keypoints = {}
    for index = 1, #values, 2 do
        table.insert(keypoints, NumberSequenceKeypoint.new(values[index], values[index + 1]))
    end
    return NumberSequence.new(keypoints)
end

local function Gradient(parent, colors, rotation, transparency)
    local keypoints = {}
    for index, color in ipairs(colors) do
        keypoints[index] = ColorSequenceKeypoint.new((index - 1) / (#colors - 1), color)
    end
    return New("UIGradient", {
        Color = ColorSequence.new(keypoints),
        Rotation = rotation or 0,
        Transparency = transparency or NumberSequence.new(0),
        Parent = parent
    })
end

local function ShadowImage(properties)
    properties.BackgroundTransparency = 1
    properties.Image = Assets.Shadow
    properties.ScaleType = Enum.ScaleType.Slice
    properties.SliceCenter = Rect.new(10, 10, 118, 118)
    properties.SliceScale = properties.SliceScale or 4
    return New("ImageLabel", properties)
end

local function GlowImage(properties)
    properties.BackgroundTransparency = 1
    properties.Image = Assets.Glow
    properties.ScaleType = Enum.ScaleType.Stretch
    return New("ImageLabel", properties)
end

local function Ring(parent, size, thickness, color, transparency, zIndex)
    local frame = New("Frame", {
        Size = UDim2.fromOffset(size, size),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        ZIndex = zIndex or 1,
        Parent = parent
    })
    Corner(frame, "full")
    local stroke = Stroke(frame, color, thickness, transparency)
    return frame, stroke
end

local function Comet(stroke)
    return New("UIGradient", {
        Transparency = Sequence(0, 0, 0.35, 0, 0.7, 1, 1, 1),
        Parent = stroke
    })
end

local function ToHex(color)
    return string.format(
        "#%02X%02X%02X",
        math.floor(color.R * 255 + 0.5),
        math.floor(color.G * 255 + 0.5),
        math.floor(color.B * 255 + 0.5)
    )
end

local function PlayTween(object, duration, properties, style, direction)
    if not object or not object.Parent then return nil end
    local tween = TweenService:Create(
        object,
        TweenInfo.new(duration or 0.25, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

local function OffsetPosition(position, xOffset, yOffset)
    return UDim2.new(
        position.X.Scale, position.X.Offset + (xOffset or 0),
        position.Y.Scale, position.Y.Offset + (yOffset or 0)
    )
end

local function GetTransparencyProps(object)
    if object:GetAttribute("NoFade") then return nil end
    if object:IsA("UIStroke") then return {"Transparency"} end
    if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
        return {"BackgroundTransparency", "TextTransparency"}
    end
    if object:IsA("ImageLabel") or object:IsA("ImageButton") then
        return {"BackgroundTransparency", "ImageTransparency"}
    end
    if object:IsA("ScrollingFrame") then
        return {"BackgroundTransparency", "ScrollBarImageTransparency"}
    end
    if object:IsA("Frame") then return {"BackgroundTransparency"} end
    return nil
end

local function TreeOf(root, includeRoot)
    local list = includeRoot and {root} or {}
    for _, descendant in ipairs(root:GetDescendants()) do
        table.insert(list, descendant)
    end
    return list
end

local function CaptureVisuals(objects)
    local snapshot = {}
    for _, object in ipairs(objects) do
        local props = GetTransparencyProps(object)
        if props then
            local values = {}
            for _, prop in ipairs(props) do values[prop] = object[prop] end
            table.insert(snapshot, {Object = object, Values = values})
        end
    end
    return snapshot
end

local function HideSnapshot(snapshot)
    for _, entry in ipairs(snapshot) do
        for prop in pairs(entry.Values) do entry.Object[prop] = 1 end
    end
end

local function ShowSnapshot(snapshot, duration, style)
    for _, entry in ipairs(snapshot) do
        PlayTween(entry.Object, duration or 0.4, entry.Values, style or Enum.EasingStyle.Quint)
    end
end

local function FadeOutTree(root, duration)
    for _, object in ipairs(TreeOf(root, true)) do
        local props = GetTransparencyProps(object)
        if props then
            local goal = {}
            for _, prop in ipairs(props) do goal[prop] = 1 end
            PlayTween(object, duration, goal, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        end
    end
end

local function RevealGroup(object, snapshot, delay, offsetX, offsetY, duration)
    local resting = object.Position
    object.Position = OffsetPosition(resting, offsetX or 0, offsetY or 0)
    task.delay(delay or 0, function()
        if not object.Parent then return end
        ShowSnapshot(snapshot, duration or 0.4)
        PlayTween(object, duration or 0.45, {Position = resting}, Enum.EasingStyle.Quint)
    end)
end

local function MakeCheckBar(holder, startPoint, endPoint, color)
    local delta = endPoint - startPoint
    local bar = New("Frame", {
        Size = UDim2.fromOffset(0, 4),
        Position = UDim2.new(0.5, startPoint.X, 0.5, startPoint.Y),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Rotation = math.deg(math.atan2(delta.Y, delta.X)),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = holder.ZIndex + 1,
        Parent = holder
    })
    Corner(bar, "full")
    return {Frame = bar, Start = startPoint, Finish = endPoint, Length = delta.Magnitude}
end

local function DrawCheckBar(bar, duration)
    bar.Frame.Size = UDim2.fromOffset(0, 4)
    bar.Frame.Position = UDim2.new(0.5, bar.Start.X, 0.5, bar.Start.Y)
    bar.Frame.Visible = true
    local middle = (bar.Start + bar.Finish) / 2
    PlayTween(bar.Frame, duration, {
        Size = UDim2.fromOffset(bar.Length, 4),
        Position = UDim2.new(0.5, middle.X, 0.5, middle.Y)
    }, Enum.EasingStyle.Quad)
end

local function HasFileSystem()
    return type(isfile) == "function"
        and type(readfile) == "function"
        and type(writefile) == "function"
end

local FileSystemAvailable = HasFileSystem()
local LogoImage = nil

local function PrepareLogo()
    if not (FileSystemAvailable and type(getcustomasset) == "function"
        and type(makefolder) == "function" and type(isfolder) == "function") then
        return
    end
    pcall(function()
        local path = Config.AssetFolder .. "/vanta.png"
        if not isfolder(Config.AssetFolder) then makefolder(Config.AssetFolder) end
        if not isfile(path) then
            local inviteCode = tostring(Config.DiscordLink):match("([%w%-]+)/*$")
            local response = game:HttpGet("https://discord.com/api/v10/invites/" .. inviteCode .. "?with_counts=false&with_expiration=false")
            local data = HttpService:JSONDecode(response)
            local guild = type(data) == "table" and data.guild or nil
            if guild and guild.id and guild.icon then
                local image = game:HttpGet("https://cdn.discordapp.com/icons/" .. guild.id .. "/" .. guild.icon .. ".png?size=256")
                if type(image) == "string" and #image > 100 then
                    writefile(path, image)
                end
            end
        end
        if isfile(path) then LogoImage = getcustomasset(path) end
    end)
end

local function GetAsset(name)
    if name == "vanta" and LogoImage then return LogoImage end
    return FallbackIcons[name] or "rbxassetid://0"
end

local function SafeClipboard(value)
    if type(setclipboard) ~= "function" then return false end
    return pcall(function() setclipboard(value) end)
end

local function GetExecutor()
    if type(identifyexecutor) == "function" then
        local success, name = pcall(identifyexecutor)
        if success and name then return tostring(name) end
    end
    return "Unknown"
end

local function GetDevice()
    local touch = UserInputService.TouchEnabled
    local keyboard = UserInputService.KeyboardEnabled
    local gamepad = UserInputService.GamepadEnabled
    if gamepad and not keyboard and not touch then return "Console" end
    if touch and not keyboard then return "Mobile" end
    if touch and keyboard then return "PC & Touch" end
    if keyboard then return "PC" end
    return "Unknown"
end

local function GetHWID()
    if type(gethwid) == "function" then
        local success, value = pcall(gethwid)
        if success and value and tostring(value) ~= "" then return tostring(value) end
    end
    local success, value = pcall(function() return RbxAnalyticsService:GetClientId() end)
    if success and value then return tostring(value) end
    return "Unavailable"
end

local function FormatNumber(value)
    local digits = tostring(math.floor(tonumber(value) or 0))
    local grouped = digits:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    return (grouped:gsub("^,", ""))
end

local function DisplayLink(link)
    return (tostring(link):gsub("^https?://", ""):gsub("/+$", ""))
end

local function GetRequestFunction()
    local found = nil
    pcall(function()
        found = (type(request) == "function" and request)
            or (type(http_request) == "function" and http_request)
            or (type(syn) == "table" and type(syn.request) == "function" and syn.request)
            or nil
    end)
    return found
end

local function FetchDiscordCounts(callback)
    local requestFunction = GetRequestFunction()
    local inviteCode = tostring(Config.DiscordLink):match("([%w%-]+)/*$")
    if not requestFunction or not inviteCode then return end
    task.spawn(function()
        local ok, response = pcall(requestFunction, {
            Url = "https://discord.com/api/v10/invites/" .. inviteCode .. "?with_counts=true",
            Method = "GET"
        })
        if not ok or type(response) ~= "table" or response.StatusCode ~= 200 or type(response.Body) ~= "string" then return end
        local decoded, data = pcall(function() return HttpService:JSONDecode(response.Body) end)
        if decoded and type(data) == "table" and tonumber(data.approximate_presence_count) then
            callback(tonumber(data.approximate_presence_count), tonumber(data.approximate_member_count) or 0)
        end
    end)
end

local function MakeIcon(parent, size, iconName, color, holderProperties)
    local properties = holderProperties or {}
    properties.Size = UDim2.fromOffset(size, size)
    properties.BackgroundTransparency = 1
    properties.Parent = parent
    local holder = New("Frame", properties)
    GlowImage({
        Name = "Glow",
        Size = UDim2.fromScale(2.2, 2.2),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ImageColor3 = color,
        ImageTransparency = 0.86,
        ZIndex = holder.ZIndex,
        Parent = holder
    })
    local image = New("ImageLabel", {
        Name = "Icon",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Image = GetAsset(iconName),
        ImageColor3 = color,
        ZIndex = holder.ZIndex + 1,
        Parent = holder
    })
    return image, holder
end

local function TintIcon(image, color, duration)
    PlayTween(image, duration or 0.22, {ImageColor3 = color})
    local glow = image.Parent and image.Parent:FindFirstChild("Glow")
    if glow then PlayTween(glow, duration or 0.22, {ImageColor3 = color}) end
end

local ExecutorName = GetExecutor()
local DeviceName = GetDevice()
local FullHWID = GetHWID()

do
    local logoReady = false
    task.spawn(function() PrepareLogo(); logoReady = true end)
    local logoDeadline = os.clock() + 4
    while not logoReady and os.clock() < logoDeadline do task.wait() end
end

local function ResolveLayout()
    local choice = Config.Layout
    pcall(function()
        local override = rawget(getgenv(), "VantaLayout")
        if type(override) == "string" then choice = override end
    end)
    choice = tostring(choice or "auto"):lower()
    if choice == "pc" or choice == "mobile" then return choice end
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then return "mobile" end
    return "pc"
end

local IsMobile = ResolveLayout() == "mobile"

local L
if IsMobile then
    L = {
        W = 480, H = 260, HeaderH = 70,
        Logo = {Size = 40, X = 22, Y = 38},
        Title = {X = 72, Y = 16, W = 200, Size = 20},
        Subtitle = {X = 72, Y = 39, Size = 12},
        Close = {Size = 28, X = -14, Y = 14, Anchor = Vector2.new(1, 0)},
        Body = {X = 22, Y = 70, W = 246, H = 170},
        LabelRow = {Y = 2},
        -- REMOVED: key input row kept as spacer, no key UI rendered
        Status = {Y = 24, H = 44},
        Launch = {X = 0, Y = 78, W = 246, H = 42},
        Decor = {
            {380, 140, 240, 266, 0.82, 270},
            {100, 46, -8, 252, 0.72, 90},
            {400, 184, 480, 8, 0.88, 90},
            {70, 138, 5, -5, 0.74, 90}
        }
    }
else
    L = {
        W = 360, H = 390, HeaderH = 82,
        Logo = {Size = 46, X = 20, Y = 41},
        Title = {X = 80, Y = 19, W = 210, Size = 21},
        Subtitle = {X = 80, Y = 45, Size = 13},
        Close = {Size = 30, X = -20, Y = 41, Anchor = Vector2.new(1, 0.5)},
        Body = {X = 20, Y = 82, W = 320, H = 308},
        LabelRow = {Y = 58},
        -- REMOVED: key input/redeem/acquire layout replaced with single launch button
        Status = {Y = 0, H = 44},
        Launch = {X = 0, Y = 58, W = 320, H = 46},
        Decor = {
            {300, 130, 180, 400, 0.8, 270},
            {90, 44, -6, 380, 0.72, 90},
            {320, 170, 360, 4, 0.86, 90},
            {70, 130, 4, -4, 0.76, 90}
        }
    }
end

local INTRO_SIZE = 84
local MORPH_W, MORPH_H = 300, 62
local PANEL_WIDTH, PANEL_GAP = 200, 10
local PANEL_OPEN_WIDTH = L.W + PANEL_GAP + PANEL_WIDTH

local guiParent = CoreGui
if type(gethui) == "function" then
    local success, result = pcall(gethui)
    if success and result then guiParent = result end
end

local function DestroyExistingKeySystem(parent)
    if not parent then return end
    local previousGui = parent:FindFirstChild("VantaKeySystem")
    if previousGui then previousGui:Destroy() end
end

pcall(function()
    DestroyExistingKeySystem(guiParent)
    if guiParent ~= CoreGui then DestroyExistingKeySystem(CoreGui) end
end)

pcall(function()
    local oldBlur = Lighting:FindFirstChild("VantaBlur")
    if oldBlur then oldBlur:Destroy() end
end)

local ScreenGui = New("ScreenGui", {
    Name = "VantaKeySystem",
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    DisplayOrder = 999999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

local parented = pcall(function() ScreenGui.Parent = guiParent end)
if not parented then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local VantaBlur = New("BlurEffect", {Name = "VantaBlur", Size = 0, Parent = Lighting})

local Backdrop = New("Frame", {
    Name = "Backdrop",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Colors.White,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 0,
    NoFade = true,
    Parent = ScreenGui
})
Gradient(Backdrop, {Color3.fromRGB(16, 10, 36), Color3.fromRGB(0, 0, 0)}, 90)

local GlowAlpha = New("NumberValue", {Name = "GlowAlpha", Value = 0, Parent = ScreenGui})

local connections = {}
local function Connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(connections, connection)
    return connection
end

local closing = false
local isAuthenticating = false
local isUserPanelOpen = false
local statusLoading = false
local successActive = false
local introActive = true
local introSpinning = false
local contentRevealed = false
local morphActive = false
local clockRunning = true
local buttonLocks = {}

local function UseCooldown(name, duration)
    if buttonLocks[name] then return false end
    buttonLocks[name] = true
    task.delay(duration or 0.65, function() buttonLocks[name] = nil end)
    return true
end

local function DisconnectAll()
    clockRunning = false
    for _, connection in ipairs(connections) do
        pcall(function() connection:Disconnect() end)
    end
    connections = {}
end

local function IsReady()
    return contentRevealed and not closing
end

local animators = {}
local function OnFrame(callback) table.insert(animators, callback) end

local animationClock = os.clock()
Connect(RunService.Heartbeat, function(deltaTime)
    if not ScreenGui.Parent then
        closing = true
        DisconnectAll()
        if VantaBlur and VantaBlur.Parent then VantaBlur:Destroy() end
        return
    end
    local t = os.clock() - animationClock
    for _, callback in ipairs(animators) do callback(t, deltaTime) end
end)

local TOAST_WIDTH = 300

local NotificationContainer = New("Frame", {
    Name = "Notifications",
    Size = UDim2.new(0, TOAST_WIDTH, 1, -40),
    Position = UDim2.new(1, -20, 1, -20),
    AnchorPoint = Vector2.new(1, 1),
    BackgroundTransparency = 1,
    ZIndex = 100,
    Parent = ScreenGui
})

local ActiveNotifications = {}

local NotifyStyles = {
    Success = {Color = Colors.Success, Icon = "check"},
    Info = {Color = Colors.AccentSoft, Icon = "shield"},
    Warn = {Color = Colors.Warn, Icon = "alert-circle"},
    Error = {Color = Colors.Error, Icon = "x"}
}

local function MeasureTextHeight(text, size, width)
    local ok, bounds = pcall(function()
        return TextService:GetTextSize(text, size, Enum.Font.GothamMedium, Vector2.new(width, 1000))
    end)
    if ok and bounds then return bounds.Y end
    return size * 2
end

local function RestackNotifications()
    local accumulated = 0
    for _, notification in ipairs(ActiveNotifications) do
        if notification.Frame and notification.Frame.Parent then
            PlayTween(notification.Frame, 0.4, {Position = UDim2.new(0, 0, 1, -accumulated)}, Enum.EasingStyle.Quint)
            accumulated = accumulated + notification.Height + 10
        end
    end
end

local function Notify(title, message, notificationType, duration)
    if closing then return end
    duration = duration or 3.5
    title = tostring(title)
    message = tostring(message)
    local style = NotifyStyles[notificationType] or NotifyStyles.Success
    local accent = style.Color
    local messageHeight = math.max(MeasureTextHeight(message, 12, TOAST_WIDTH - 66), 14)
    local height = math.max(58, 46 + messageHeight)

    local toast = New("Frame", {
        Size = UDim2.new(1, 0, 0, height),
        Position = UDim2.new(1, TOAST_WIDTH + 40, 1, 0),
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = Colors.White,
        BorderSizePixel = 0,
        ZIndex = 101,
        Parent = NotificationContainer
    })
    Corner(toast, 12)
    Gradient(toast, {Colors.SecondaryBG:Lerp(accent, 0.16), Colors.SecondaryBG}, 0)
    Stroke(toast, accent, 1, 0.55)

    local chip = New("Frame", {
        Size = UDim2.fromOffset(32, 32),
        Position = UDim2.fromOffset(12, 12),
        BackgroundColor3 = accent,
        BackgroundTransparency = 0.84,
        BorderSizePixel = 0,
        ZIndex = 102,
        Parent = toast
    })
    Corner(chip, 9)

    New("ImageLabel", {
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = GetAsset(style.Icon),
        ImageColor3 = accent,
        ZIndex = 103,
        Parent = chip
    })

    New("TextLabel", {
        Size = UDim2.new(1, -66, 0, 16),
        Position = UDim2.fromOffset(54, 12),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Colors.TextPrimary,
        Typeface = "Heading",
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 102,
        Parent = toast
    })

    New("TextLabel", {
        Size = UDim2.new(1, -66, 0, messageHeight),
        Position = UDim2.fromOffset(54, 31),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = Colors.TextSecondary,
        Typeface = "Body",
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 102,
        Parent = toast
    })

    local track = New("Frame", {
        Size = UDim2.new(1, -24, 0, 2),
        Position = UDim2.new(0, 12, 1, -6),
        BackgroundColor3 = accent,
        BackgroundTransparency = 0.85,
        BorderSizePixel = 0,
        ZIndex = 102,
        Parent = toast
    })
    Corner(track, 2)
    local progress = New("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        ZIndex = 103,
        Parent = track
    })
    Corner(progress, 2)

    local data = {Frame = toast, Height = height, Closed = false}
    table.insert(ActiveNotifications, 1, data)

    while #ActiveNotifications > 4 do
        local oldest = table.remove(ActiveNotifications, #ActiveNotifications)
        if oldest and oldest.Frame then
            oldest.Closed = true
            local frame = oldest.Frame
            PlayTween(frame, 0.25, {Position = UDim2.new(1, TOAST_WIDTH + 40, 1, frame.Position.Y.Offset)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            FadeOutTree(frame, 0.22)
            task.delay(0.26, function() if frame then frame:Destroy() end end)
        end
    end

    RestackNotifications()
    PlayTween(toast, 0.5, {Position = UDim2.new(0, 0, 1, toast.Position.Y.Offset)}, Enum.EasingStyle.Back)
    PlayTween(progress, duration, {Size = UDim2.fromScale(0, 1)}, Enum.EasingStyle.Linear)

    local function dismiss()
        if data.Closed then return end
        data.Closed = true
        for index, notification in ipairs(ActiveNotifications) do
            if notification == data then table.remove(ActiveNotifications, index); break end
        end
        PlayTween(toast, 0.3, {Position = UDim2.new(1, TOAST_WIDTH + 40, 1, toast.Position.Y.Offset)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        FadeOutTree(toast, 0.25)
        task.delay(0.31, function() if toast and toast.Parent then toast:Destroy() end end)
        RestackNotifications()
    end

    local dismissButton = New("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 104,
        Parent = toast
    })
    Connect(dismissButton.MouseButton1Click, dismiss)
    task.delay(duration, dismiss)
end

local UI = {}

UI.Root = New("Frame", {
    Name = "Root",
    Size = UDim2.fromOffset(L.W, L.H),
    Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1,
    Visible = false,
    ZIndex = 2,
    Parent = ScreenGui
})
UI.Scale = New("UIScale", {Scale = 1, Parent = UI.Root})

UI.CardFrame = New("Frame", {
    Name = "CardFrame",
    Size = UDim2.fromOffset(L.W, L.H),
    Position = UDim2.fromOffset(L.W / 2, L.H / 2),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1,
    ZIndex = 1,
    Parent = UI.Root
})

UI.CardGlow = ShadowImage({
    Name = "Glow",
    Size = UDim2.new(1, 110, 1, 110),
    Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5),
    SliceScale = 6,
    ImageColor3 = Colors.Accent,
    ImageTransparency = 1,
    ZIndex = 0,
    NoFade = true,
    Parent = UI.CardFrame
})

UI.CardShadow = ShadowImage({
    Name = "Shadow",
    Size = UDim2.new(1, 70, 1, 70),
    Position = UDim2.new(0.5, 0, 0.5, 8),
    AnchorPoint = Vector2.new(0.5, 0.5),
    ImageColor3 = Colors.Black,
    ImageTransparency = 0.3,
    ZIndex = 0,
    Parent = UI.CardFrame
})

UI.Card = New("Frame", {
    Name = "MainCard",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Colors.White,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 1,
    Parent = UI.CardFrame
})
UI.CardCorner = Corner(UI.Card, 14)
Gradient(UI.Card, {Colors.MainBGTop, Colors.MainBG}, 90)

UI.CardStroke = Stroke(UI.Card, Colors.White, 1.2, 0)
UI.CardStrokeGradient = New("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.Stroke),
        ColorSequenceKeypoint.new(0.32, Colors.AccentCyan),
        ColorSequenceKeypoint.new(0.5, Colors.Accent),
        ColorSequenceKeypoint.new(0.68, Colors.AccentGlow),
        ColorSequenceKeypoint.new(1, Colors.Stroke)
    }),
    Parent = UI.CardStroke
})

UI.Decor = New("CanvasGroup", {
    Name = "Decor",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    GroupTransparency = 1,
    ZIndex = 0,
    Parent = UI.Card
})
Corner(UI.Decor, 14)

do
    local inner = New("Frame", {
        Size = UDim2.fromOffset(L.W, L.H),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Parent = UI.Decor
    })
    for _, spec in ipairs(L.Decor) do
        local glow = GlowImage({
            Size = UDim2.fromOffset(spec[1], spec[2]),
            Position = UDim2.fromOffset(spec[3], spec[4]),
            AnchorPoint = Vector2.new(0.5, 0.5),
            ImageColor3 = Colors.White,
            ImageTransparency = spec[5],
            Parent = inner
        })
        Gradient(glow, {Colors.AccentCyan, Colors.Accent, Colors.AccentGlow}, spec[6])
    end
end

UI.TopLight = New("Frame", {
    Name = "TopLight",
    Size = UDim2.new(1, -60, 0, 2),
    Position = UDim2.fromScale(0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0),
    BackgroundColor3 = Colors.White,
    BorderSizePixel = 0,
    ZIndex = 5,
    Parent = UI.Card
})
UI.TopLightGradient = Gradient(
    UI.TopLight,
    {Colors.AccentCyan, Colors.Accent, Colors.AccentGlow},
    0,
    Sequence(0, 1, 0.2, 0, 0.8, 0, 1, 1)
)

UI.IntroGlow = GlowImage({
    Size = UDim2.fromOffset(150, 150),
    Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5),
    ImageColor3 = Colors.Accent,
    ImageTransparency = 1,
    ZIndex = 5,
    Parent = UI.Card
})

UI.IntroLogo = New("ImageLabel", {
    Size = UDim2.fromOffset(56, 56),
    Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Colors.SecondaryBG,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Image = GetAsset("vanta"),
    ImageTransparency = 1,
    ZIndex = 6,
    Parent = UI.Card
})
Corner(UI.IntroLogo, 14)
UI.IntroLogoStroke = Stroke(UI.IntroLogo, Colors.White, 1.5, 1)
UI.IntroLogoGradient = Gradient(UI.IntroLogoStroke, {Colors.AccentCyan, Colors.Accent, Colors.AccentGlow}, 45)
UI.IntroLogoScale = New("UIScale", {Scale = 0.8, Parent = UI.IntroLogo})

UI.IntroSpinner = New("Frame", {
    Size = UDim2.fromOffset(26, 26),
    Position = UDim2.new(0.5, 0, 0.5, 38),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1,
    ZIndex = 6,
    Parent = UI.Card
})

do
    local _, trackStroke = Ring(UI.IntroSpinner, 24, 2.5, Colors.AccentSoft, 1, 6)
    local arc, arcStroke = Ring(UI.IntroSpinner, 24, 2.5, Colors.White, 1, 7)
    local comet = Comet(arcStroke)
    comet.Color = ColorSequence.new(Colors.AccentCyan, Colors.AccentGlow)
    UI.IntroTrackStroke = trackStroke
    UI.IntroArc = arc
    UI.IntroArcStroke = arcStroke
end

-- ============================================================
-- HEADER
-- ============================================================
do
    local header = New("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, L.HeaderH),
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = UI.Card
    })

    local logoGlow = ShadowImage({
        Size = UDim2.fromOffset(L.Logo.Size + 44, L.Logo.Size + 44),
        Position = UDim2.fromOffset(L.Logo.X + L.Logo.Size / 2, L.Logo.Y),
        AnchorPoint = Vector2.new(0.5, 0.5),
        SliceScale = 2.5,
        ImageColor3 = Colors.AccentCyan,
        ImageTransparency = 1,
        ZIndex = 2,
        NoFade = true,
        Parent = header
    })

    local serverIcon = New("ImageLabel", {
        Size = UDim2.fromOffset(L.Logo.Size, L.Logo.Size),
        Position = UDim2.fromOffset(L.Logo.X, L.Logo.Y),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Colors.SecondaryBG,
        BorderSizePixel = 0,
        Image = GetAsset("vanta"),
        ZIndex = 3,
        Parent = header
    })
    Corner(serverIcon, 12)
    local logoStroke = Stroke(serverIcon, Colors.White, 1.5, 0.1)
    local logoStrokeGradient = Gradient(logoStroke, {Colors.AccentCyan, Colors.Accent, Colors.AccentGlow}, 45)
    local logoScale = New("UIScale", {Scale = 1, Parent = serverIcon})

    local title = New("TextLabel", {
        Size = UDim2.fromOffset(L.Title.W, 24),
        Position = UDim2.fromOffset(L.Title.X, L.Title.Y),
        BackgroundTransparency = 1,
        RichText = true,
        Text = string.format('%s<font color="%s">%s</font>', Config.HeaderTitle, ToHex(Colors.AccentSoft), Config.HeaderAccent),
        TextColor3 = Colors.White,
        Typeface = "Title",
        TextSize = L.Title.Size,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = header
    })
    local titleShimmer = New("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(214, 216, 240)),
            ColorSequenceKeypoint.new(0.42, Color3.fromRGB(214, 216, 240)),
            ColorSequenceKeypoint.new(0.5, Colors.White),
            ColorSequenceKeypoint.new(0.58, Color3.fromRGB(214, 216, 240)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(214, 216, 240))
        }),
        Rotation = 15,
        Offset = Vector2.new(-1.2, 0),
        Parent = title
    })

    -- CHANGED: subtitle now shows "crack by c6r6"
    New("TextLabel", {
        Size = UDim2.fromOffset(L.Title.W, 16),
        Position = UDim2.fromOffset(L.Subtitle.X, L.Subtitle.Y),
        BackgroundTransparency = 1,
        Text = Config.Subtitle,
        TextColor3 = Colors.AccentSoft,
        Typeface = "BodyMedium",
        TextSize = L.Subtitle.Size,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = header
    })

    local closeButton = New("TextButton", {
        Size = UDim2.fromOffset(L.Close.Size, L.Close.Size),
        Position = UDim2.new(1, L.Close.X, 0, L.Close.Y),
        AnchorPoint = L.Close.Anchor,
        BackgroundColor3 = Colors.SecondaryBG,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 3,
        Parent = header
    })
    Corner(closeButton, 9)
    local closeStroke = Stroke(closeButton, Colors.Stroke, 1, 0)
    local closeIcon = New("ImageLabel", {
        Size = UDim2.fromOffset(13, 13),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = GetAsset("x"),
        ImageColor3 = Colors.TextSecondary,
        ZIndex = 4,
        Parent = closeButton
    })

    Connect(closeButton.MouseEnter, function()
        PlayTween(closeButton, 0.18, {BackgroundColor3 = Colors.Error})
        PlayTween(closeIcon, 0.25, {ImageColor3 = Colors.White, Rotation = 90})
        PlayTween(closeStroke, 0.18, {Color = Colors.Error})
    end)
    Connect(closeButton.MouseLeave, function()
        PlayTween(closeButton, 0.18, {BackgroundColor3 = Colors.SecondaryBG})
        PlayTween(closeIcon, 0.25, {ImageColor3 = Colors.TextSecondary, Rotation = 0})
        PlayTween(closeStroke, 0.18, {Color = Colors.Stroke})
    end)

    local logoGlowAlpha = 0
    OnFrame(function(t, deltaTime)
        logoStrokeGradient.Rotation = (t * 70) % 360
        titleShimmer.Offset = Vector2.new(-1.2 + ((t % 3.6) / 3.6) * 2.4, 0)
        logoScale.Scale = 1 + math.sin(t * 2.1) * 0.03
        local target = (contentRevealed and not closing) and GlowAlpha.Value or 0
        logoGlowAlpha = logoGlowAlpha + (target - logoGlowAlpha) * math.min(1, (deltaTime or 0.016) * 5)
        logoGlow.ImageTransparency = 1 - (0.32 + math.sin(t * 2.1) * 0.12) * logoGlowAlpha
    end)

    UI.Header = header
    UI.CloseButton = closeButton
end

-- ============================================================
-- BODY  (no key input, no redeem/acquire -- just status + launch)
-- ============================================================
UI.Body = New("Frame", {
    Name = "Body",
    Size = UDim2.fromOffset(L.Body.W, L.Body.H),
    Position = UDim2.fromOffset(L.Body.X, L.Body.Y),
    BackgroundTransparency = 1,
    ZIndex = 2,
    Parent = UI.Card
})

do
    local chipSize = L.Status.H - 16
    local status = New("Frame", {
        Name = "Status",
        Size = UDim2.new(1, 0, 0, L.Status.H),
        Position = UDim2.fromOffset(0, L.Status.Y),
        BackgroundColor3 = Colors.SecondaryBG,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = UI.Body
    })
    Corner(status, 10)
    UI.StatusStroke = Stroke(status, Colors.Stroke, 1, 0)

    UI.StatusChip = New("Frame", {
        Size = UDim2.fromOffset(chipSize, chipSize),
        Position = UDim2.new(0, 8, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Colors.AccentSoft,
        BackgroundTransparency = 0.85,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = status
    })
    Corner(UI.StatusChip, 8)

    UI.StatusIcon = New("ImageLabel", {
        Size = UDim2.fromOffset(15, 15),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = GetAsset("shield"),
        ImageColor3 = Colors.AccentSoft,
        ZIndex = 4,
        Parent = UI.StatusChip
    })
    UI.StatusIconScale = New("UIScale", {Parent = UI.StatusIcon})

    UI.StatusTextX = 8 + chipSize + 10
    UI.StatusText = New("TextLabel", {
        Size = UDim2.new(1, -(UI.StatusTextX + 10), 1, 0),
        Position = UDim2.fromOffset(UI.StatusTextX, 0),
        BackgroundTransparency = 1,
        Text = "Initializing...",
        TextColor3 = Colors.TextSecondary,
        Typeface = "BodyMedium",
        TextSize = IsMobile and 12 or 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 3,
        Parent = status
    })

    local loadingTrack = New("Frame", {
        Size = UDim2.new(1, -24, 0, 2),
        Position = UDim2.new(0, 12, 1, -3),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 3,
        Parent = status
    })
    UI.LoadingBar = New("Frame", {
        Size = UDim2.fromScale(0.35, 1),
        Position = UDim2.fromScale(-0.35, 0),
        BackgroundColor3 = Colors.White,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 4,
        NoFade = true,
        Parent = loadingTrack
    })
    Gradient(UI.LoadingBar, {Colors.AccentCyan, Colors.Accent, Colors.AccentGlow}, 0, Sequence(0, 1, 0.5, 0, 1, 1))

    UI.Status = status
end

-- LAUNCH BUTTON (replaces Redeem + Acquire)
do
    local rect = L.Launch
    local holder = New("Frame", {
        Size = UDim2.fromOffset(rect.W, rect.H),
        Position = UDim2.fromOffset(rect.X, rect.Y),
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = UI.Body
    })

    local glow = ShadowImage({
        Size = UDim2.new(1, 30, 1, 30),
        Position = UDim2.new(0.5, 0, 0.5, 4),
        AnchorPoint = Vector2.new(0.5, 0.5),
        SliceScale = 3,
        ImageColor3 = Colors.Accent,
        ImageTransparency = 0.72,
        ZIndex = 1,
        Parent = holder
    })

    local button = New("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(228, 228, 238),
        Text = "",
        AutoButtonColor = false,
        ZIndex = 2,
        Parent = holder
    })
    Corner(button, 10)
    local buttonStroke = Stroke(button, Colors.AccentSoft, 1, 0.45)
    local gradient = Gradient(button, {Color3.fromRGB(64, 132, 255), Colors.Accent, Color3.fromRGB(184, 52, 255)}, 0)
    local scale = New("UIScale", {Scale = 1, Parent = button})

    local shine = New("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Colors.White,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = button
    })
    Corner(shine, 10)
    local shineGradient = New("UIGradient", {
        Rotation = 20,
        Transparency = Sequence(0, 1, 0.4, 1, 0.5, 0.72, 0.6, 1, 1, 1),
        Offset = Vector2.new(-1, 0),
        Parent = shine
    })

    local flash = New("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Colors.White,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 2,
        NoFade = true,
        Parent = button
    })
    Corner(flash, 10)

    local content = New("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ZIndex = 3,
        Parent = button
    })
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = content
    })
    local launchIcon = MakeIcon(content, 16, "loader-2", Colors.White, {LayoutOrder = 1, ZIndex = 3})
    local launchLabel = New("TextLabel", {
        Size = UDim2.fromOffset(0, 20),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = "Launch",
        TextColor3 = Colors.White,
        Typeface = "Heading",
        TextSize = 13,
        LayoutOrder = 2,
        ZIndex = 3,
        Parent = content
    })

    Connect(button.MouseEnter, function()
        PlayTween(button, 0.2, {BackgroundColor3 = Colors.White})
        PlayTween(buttonStroke, 0.2, {Color = Colors.AccentGlow})
        PlayTween(scale, 0.2, {Scale = 1.02})
        PlayTween(glow, 0.25, {ImageTransparency = 0.5})
        shineGradient.Offset = Vector2.new(-1, 0)
        PlayTween(shineGradient, 0.65, {Offset = Vector2.new(1, 0)}, Enum.EasingStyle.Quad)
    end)
    Connect(button.MouseLeave, function()
        PlayTween(button, 0.2, {BackgroundColor3 = Color3.fromRGB(228, 228, 238)})
        PlayTween(buttonStroke, 0.2, {Color = Colors.AccentSoft})
        PlayTween(scale, 0.2, {Scale = 1})
        PlayTween(glow, 0.25, {ImageTransparency = 0.72})
    end)
    Connect(button.MouseButton1Down, function()
        PlayTween(scale, 0.08, {Scale = 0.97}, Enum.EasingStyle.Quad)
        flash.BackgroundTransparency = 0.82
        PlayTween(flash, 0.35, {BackgroundTransparency = 1}, Enum.EasingStyle.Quad)
    end)
    Connect(button.MouseButton1Up, function()
        PlayTween(scale, 0.18, {Scale = 1.02}, Enum.EasingStyle.Back)
    end)

    UI.LaunchButton = button
    UI.LaunchLabel = launchLabel
    UI.LaunchIcon = launchIcon
    UI.LaunchGradient = gradient
    UI.LaunchGlow = glow
    UI.LaunchScale = scale
    UI.LaunchHolder = holder
end

-- LINKS (pc only -- discord + website, no key-related links)
UI.Links = {}
local Panel = {}

if not IsMobile then
    UI.Divider = New("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.fromOffset(0, 118),
        BackgroundColor3 = Colors.StrokeBright,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = UI.Body
    })
    New("UIGradient", {Transparency = Sequence(0, 1, 0.5, 0.25, 1, 1), Parent = UI.Divider})

    UI.LinksContainer = New("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        Position = UDim2.fromOffset(0, 128),
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = UI.Body
    })
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = UI.LinksContainer
    })

    local linkCount = 0
    local function CreateLinkButton(text, iconName)
        linkCount = linkCount + 1
        local button = New("TextButton", {
            Size = UDim2.fromScale(0, 1),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = linkCount,
            ZIndex = 2,
            Parent = UI.LinksContainer
        })
        New("UIPadding", {PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), Parent = button})
        local scale = New("UIScale", {Scale = 1, Parent = button})
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 5),
            Parent = button
        })
        local icon = MakeIcon(button, 13, iconName, Colors.TextMuted, {LayoutOrder = 1, ZIndex = 2})
        local label = New("TextLabel", {
            Size = UDim2.fromOffset(0, 16),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Colors.TextSecondary,
            Typeface = "BodyMedium",
            TextSize = 12,
            LayoutOrder = 2,
            ZIndex = 2,
            Parent = button
        })
        local underline = New("Frame", {
            Size = UDim2.fromOffset(0, 1),
            Position = UDim2.new(0.5, 0, 1, 1),
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundColor3 = Colors.AccentSoft,
            BorderSizePixel = 0,
            ZIndex = 2,
            Parent = label
        })
        Connect(button.MouseEnter, function()
            TintIcon(icon, Colors.AccentSoft, 0.18)
            PlayTween(label, 0.18, {TextColor3 = Colors.TextPrimary})
            PlayTween(underline, 0.25, {Size = UDim2.new(1, 0, 0, 1)})
            PlayTween(scale, 0.18, {Scale = 1.04})
        end)
        Connect(button.MouseLeave, function()
            TintIcon(icon, Colors.TextMuted, 0.18)
            PlayTween(label, 0.18, {TextColor3 = Colors.TextSecondary})
            PlayTween(underline, 0.2, {Size = UDim2.fromOffset(0, 1)})
            PlayTween(scale, 0.18, {Scale = 1})
        end)
        Connect(button.MouseButton1Down, function()
            PlayTween(scale, 0.08, {Scale = 0.94}, Enum.EasingStyle.Quad)
        end)
        Connect(button.MouseButton1Up, function()
            PlayTween(scale, 0.16, {Scale = 1.04}, Enum.EasingStyle.Back)
        end)
        return button
    end

    -- REMOVED: ResetHWID, UserInfo, key-related links
    UI.Links.Discord = CreateLinkButton("Discord", "gamepad-2")
    UI.Links.Website = CreateLinkButton("Website", "external-link")
    UI.Links.UserInfo = CreateLinkButton("User Info", "user")

    -- USER PANEL (unchanged)
    local userPanel = New("Frame", {
        Name = "UserPanel",
        Size = UDim2.fromOffset(0, L.H),
        Position = UDim2.fromOffset(L.W + PANEL_GAP, 0),
        BackgroundColor3 = Colors.White,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 2,
        Parent = UI.Root
    })
    Corner(userPanel, 14)
    Gradient(userPanel, {Colors.MainBGTop, Colors.MainBG}, 90)
    local userPanelStroke = Stroke(userPanel, Colors.StrokeBright, 1, 1)

    local panelContent = New("Frame", {
        Size = UDim2.new(0, PANEL_WIDTH, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 21,
        Parent = userPanel
    })

    New("TextLabel", {
        Size = UDim2.new(1, -56, 0, 24),
        Position = UDim2.fromOffset(16, 14),
        BackgroundTransparency = 1,
        Text = "User Info",
        TextColor3 = Colors.TextPrimary,
        Typeface = "Heading",
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 22,
        Parent = panelContent
    })

    local panelClose = New("TextButton", {
        Size = UDim2.fromOffset(26, 26),
        Position = UDim2.new(1, -14, 0, 13),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = Colors.SecondaryBG,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 22,
        Parent = panelContent
    })
    Corner(panelClose, 8)
    local panelCloseStroke = Stroke(panelClose, Colors.Stroke, 1, 0)
    local panelCloseIcon = New("ImageLabel", {
        Size = UDim2.fromOffset(12, 12),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = GetAsset("x"),
        ImageColor3 = Colors.TextSecondary,
        ZIndex = 23,
        Parent = panelClose
    })

    local avatar = New("ImageLabel", {
        Size = UDim2.fromOffset(60, 60),
        Position = UDim2.new(0.5, 0, 0, 52),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Colors.TertiaryBG,
        BorderSizePixel = 0,
        Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150",
        ZIndex = 22,
        Parent = panelContent
    })
    Corner(avatar, 14)
    local avatarStroke = Stroke(avatar, Colors.White, 2, 0)
    local avatarGradient = Gradient(avatarStroke, {Colors.AccentCyan, Colors.Accent, Colors.AccentGlow}, 0)

    New("TextLabel", {
        Size = UDim2.new(1, -24, 0, 18),
        Position = UDim2.fromOffset(12, 120),
        BackgroundTransparency = 1,
        Text = LocalPlayer.DisplayName,
        TextColor3 = Colors.TextPrimary,
        Typeface = "Heading",
        TextSize = 14,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 22,
        Parent = panelContent
    })

    New("TextLabel", {
        Size = UDim2.new(1, -24, 0, 14),
        Position = UDim2.fromOffset(12, 139),
        BackgroundTransparency = 1,
        Text = "@" .. LocalPlayer.Name,
        TextColor3 = Colors.TextMuted,
        Typeface = "BodyMedium",
        TextSize = 12,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 22,
        Parent = panelContent
    })

    local function PanelDivider(y)
        local divider = New("Frame", {
            Size = UDim2.new(1, -28, 0, 1),
            Position = UDim2.fromOffset(14, y),
            BackgroundColor3 = Colors.StrokeBright,
            BorderSizePixel = 0,
            ZIndex = 22,
            Parent = panelContent
        })
        New("UIGradient", {Transparency = Sequence(0, 1, 0.5, 0.2, 1, 1), Parent = divider})
    end

    local function PanelRow(labelText, valueText, y, mono)
        New("TextLabel", {
            Size = UDim2.new(1, -28, 0, 12),
            Position = UDim2.fromOffset(14, y),
            BackgroundTransparency = 1,
            Text = labelText,
            TextColor3 = Colors.TextMuted,
            Typeface = "Label",
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 22,
            Parent = panelContent
        })
        return New("TextLabel", {
            Size = UDim2.new(1, -28, 0, 18),
            Position = UDim2.fromOffset(14, y + 14),
            BackgroundTransparency = 1,
            Text = valueText,
            TextColor3 = Colors.TextPrimary,
            Typeface = mono and "Mono" or "BodyBold",
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 22,
            Parent = panelContent
        })
    end

    PanelDivider(164)
    PanelRow("EXECUTOR", ExecutorName, 176)
    PanelRow("DEVICE", DeviceName, 216)
    local hwidValue = PanelRow("HWID", string.rep("•", 14), 256, true)
    hwidValue.Size = UDim2.new(1, -52, 0, 18)

    local copyButton = New("ImageButton", {
        Size = UDim2.fromOffset(18, 18),
        Position = UDim2.new(1, -15, 0, 270),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Image = GetAsset("copy"),
        ImageColor3 = Colors.TextSecondary,
        AutoButtonColor = false,
        ZIndex = 23,
        Parent = panelContent
    })
    local copyScale = New("UIScale", {Parent = copyButton})

    PanelDivider(304)

    local clockRow = New("Frame", {
        Size = UDim2.new(1, -28, 0, 20),
        Position = UDim2.fromOffset(14, 320),
        BackgroundTransparency = 1,
        ZIndex = 22,
        Parent = panelContent
    })
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 7),
        Parent = clockRow
    })
    MakeIcon(clockRow, 16, "clock", Colors.AccentSoft, {LayoutOrder = 1, ZIndex = 22})
    local clockTime = New("TextLabel", {
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = "00:00:00 AM",
        TextColor3 = Colors.TextPrimary,
        Typeface = "MonoBold",
        TextSize = 14,
        LayoutOrder = 2,
        ZIndex = 22,
        Parent = clockRow
    })
    local clockDate = New("TextLabel", {
        Size = UDim2.new(1, -28, 0, 16),
        Position = UDim2.fromOffset(14, 344),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Colors.TextSecondary,
        Typeface = "BodyMedium",
        TextSize = 12,
        ZIndex = 22,
        Parent = panelContent
    })

    task.spawn(function()
        while clockRunning and ScreenGui.Parent do
            local data = os.date("*t")
            local hour = data.hour % 12
            if hour == 0 then hour = 12 end
            local period = data.hour >= 12 and "PM" or "AM"
            clockTime.Text = string.format("%d:%02d:%02d %s", hour, data.min, data.sec, period)
            clockDate.Text = os.date("%A, %b %d %Y")
            task.wait(1)
        end
    end)

    local panelSnapshot = CaptureVisuals(TreeOf(panelContent, false))
    HideSnapshot(panelSnapshot)

    OnFrame(function(t)
        if isUserPanelOpen then avatarGradient.Rotation = (t * 90) % 360 end
    end)

    Connect(panelClose.MouseEnter, function()
        PlayTween(panelClose, 0.18, {BackgroundColor3 = Colors.ElevatedBG})
        PlayTween(panelCloseIcon, 0.25, {ImageColor3 = Colors.TextPrimary, Rotation = 90})
        PlayTween(panelCloseStroke, 0.18, {Color = Colors.StrokeBright})
    end)
    Connect(panelClose.MouseLeave, function()
        PlayTween(panelClose, 0.18, {BackgroundColor3 = Colors.SecondaryBG})
        PlayTween(panelCloseIcon, 0.25, {ImageColor3 = Colors.TextSecondary, Rotation = 0})
        PlayTween(panelCloseStroke, 0.18, {Color = Colors.Stroke})
    end)
    Connect(copyButton.MouseEnter, function()
        PlayTween(copyButton, 0.16, {ImageColor3 = Colors.AccentSoft})
        PlayTween(copyScale, 0.16, {Scale = 1.12})
    end)
    Connect(copyButton.MouseLeave, function()
        PlayTween(copyButton, 0.16, {ImageColor3 = Colors.TextSecondary})
        PlayTween(copyScale, 0.16, {Scale = 1})
    end)
    Connect(copyButton.MouseButton1Click, function()
        if not UseCooldown("copyhwid", 0.8) then return end
        if SafeClipboard(FullHWID) then
            PlayTween(copyButton, 0.15, {ImageColor3 = Colors.Success})
            copyScale.Scale = 0.8
            PlayTween(copyScale, 0.35, {Scale = 1}, Enum.EasingStyle.Back)
            Notify("Copied", "HWID copied to your clipboard.", "Info", 2.5)
            task.delay(0.6, function()
                if copyButton.Parent then PlayTween(copyButton, 0.2, {ImageColor3 = Colors.TextSecondary}) end
            end)
        else
            Notify("Unavailable", "Clipboard is not supported by this executor.", "Error", 3)
        end
    end)

    Panel.Frame = userPanel
    Panel.Stroke = userPanelStroke
    Panel.Content = panelContent
    Panel.Snapshot = panelSnapshot
    Panel.Close = panelClose

    UI.EntranceGroups = {UI.Header, UI.Status, UI.LaunchHolder, UI.Divider, UI.LinksContainer}
    UI.ContentGroups = {UI.Header, UI.Body}
else
    -- MOBILE: right panel kept, key cards replaced with info cards only
    UI.Right = New("Frame", {
        Name = "Right",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = UI.Card
    })

    UI.VDivider = New("Frame", {
        Size = UDim2.new(0, 1, 1, -40),
        Position = UDim2.fromOffset(290, 20),
        BackgroundColor3 = Colors.StrokeBright,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = UI.Right
    })
    New("UIGradient", {Rotation = 90, Transparency = Sequence(0, 1, 0.5, 0.25, 1, 1), Parent = UI.VDivider})

    local top = New("Frame", {
        Size = UDim2.fromOffset(153, 74),
        Position = UDim2.fromOffset(309, 22),
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = UI.Right
    })
    New("TextLabel", {
        Size = UDim2.fromOffset(110, 12),
        BackgroundTransparency = 1,
        Text = "CRACK BY C6R6",
        TextColor3 = Colors.AccentSoft,
        Typeface = "Label",
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
        Parent = top
    })

    local userCard = New("Frame", {
        Size = UDim2.fromOffset(153, 50),
        Position = UDim2.fromOffset(0, 22),
        BackgroundColor3 = Colors.SecondaryBG,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = top
    })
    Corner(userCard, 10)
    Stroke(userCard, Colors.Stroke, 1, 0)

    local avatar = New("ImageLabel", {
        Size = UDim2.fromOffset(34, 34),
        Position = UDim2.fromOffset(8, 8),
        BackgroundColor3 = Colors.TertiaryBG,
        BorderSizePixel = 0,
        Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150",
        ZIndex = 3,
        Parent = userCard
    })
    Corner(avatar, 9)
    local avatarStroke = Stroke(avatar, Colors.White, 1.5, 0)
    local avatarGradient = Gradient(avatarStroke, {Colors.AccentCyan, Colors.Accent, Colors.AccentGlow}, 0)

    New("TextLabel", {
        Size = UDim2.fromOffset(96, 16),
        Position = UDim2.fromOffset(50, 9),
        BackgroundTransparency = 1,
        Text = LocalPlayer.DisplayName,
        TextColor3 = Colors.TextPrimary,
        Typeface = "Heading",
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 3,
        Parent = userCard
    })
    New("TextLabel", {
        Size = UDim2.fromOffset(96, 14),
        Position = UDim2.fromOffset(50, 26),
        BackgroundTransparency = 1,
        Text = "@" .. LocalPlayer.Name,
        TextColor3 = Colors.TextMuted,
        Typeface = "BodyMedium",
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 3,
        Parent = userCard
    })

    local rows = New("Frame", {
        Size = UDim2.fromOffset(153, 34),
        Position = UDim2.fromOffset(309, 104),
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = UI.Right
    })
    local function InfoRow(y, labelText, valueText)
        New("TextLabel", {
            Size = UDim2.fromOffset(60, 14),
            Position = UDim2.fromOffset(0, y),
            BackgroundTransparency = 1,
            Text = labelText,
            TextColor3 = Colors.TextMuted,
            Typeface = "BodyMedium",
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2,
            Parent = rows
        })
        New("TextLabel", {
            Size = UDim2.fromOffset(90, 14),
            Position = UDim2.fromOffset(63, y),
            BackgroundTransparency = 1,
            Text = valueText,
            TextColor3 = Colors.TextPrimary,
            Typeface = "BodyBold",
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Right,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 2,
            Parent = rows
        })
    end
    InfoRow(0, "Executor", ExecutorName)
    InfoRow(18, "Device", DeviceName)

    local rightDivider = New("Frame", {
        Size = UDim2.fromOffset(153, 1),
        Position = UDim2.fromOffset(309, 146),
        BackgroundColor3 = Colors.StrokeBright,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = UI.Right
    })
    New("UIGradient", {Transparency = Sequence(0, 1, 0.5, 0.25, 1, 1), Parent = rightDivider})

    local scroll = New("ScrollingFrame", {
        Size = UDim2.fromOffset(159, L.H - 160),
        Position = UDim2.fromOffset(307, 152),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 2 + 2 * 44 - 6 + 2),
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ElasticBehavior = Enum.ElasticBehavior.Never,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Colors.TextMuted,
        ScrollBarImageTransparency = 0.45,
        VerticalScrollBarInset = Enum.ScrollBarInset.None,
        ZIndex = 2,
        Parent = UI.Right
    })

    local function CreateInfoCard(index, titleText, subtitleText, iconName)
        local card = New("TextButton", {
            Size = UDim2.fromOffset(153, 38),
            Position = UDim2.fromOffset(2, 2 + (index - 1) * 44),
            BackgroundColor3 = Colors.SecondaryBG,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 2,
            Parent = scroll
        })
        Corner(card, 9)
        local cardStroke = Stroke(card, Colors.Stroke, 1, 0)
        local scale = New("UIScale", {Parent = card})
        local icon = MakeIcon(card, 16, iconName, Colors.AccentSoft, {Position = UDim2.fromOffset(11, 11), ZIndex = 3})
        New("TextLabel", {
            Size = UDim2.fromOffset(110, 14),
            Position = UDim2.fromOffset(36, 5),
            BackgroundTransparency = 1,
            Text = titleText,
            TextColor3 = Colors.TextPrimary,
            Typeface = "BodyBold",
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 3,
            Parent = card
        })
        local subtitle = New("TextLabel", {
            Size = UDim2.fromOffset(110, 13),
            Position = UDim2.fromOffset(36, 20),
            BackgroundTransparency = 1,
            RichText = true,
            Text = subtitleText,
            TextColor3 = Colors.TextMuted,
            Typeface = "Body",
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 3,
            Parent = card
        })
        Connect(card.MouseEnter, function()
            PlayTween(card, 0.18, {BackgroundColor3 = Colors.ElevatedBG})
            PlayTween(cardStroke, 0.18, {Color = Colors.StrokeBright})
            TintIcon(icon, Colors.AccentCyan, 0.18)
        end)
        Connect(card.MouseLeave, function()
            PlayTween(card, 0.18, {BackgroundColor3 = Colors.SecondaryBG})
            PlayTween(cardStroke, 0.18, {Color = Colors.Stroke})
            TintIcon(icon, Colors.AccentSoft, 0.18)
        end)
        Connect(card.MouseButton1Down, function()
            PlayTween(scale, 0.08, {Scale = 0.96}, Enum.EasingStyle.Quad)
        end)
        Connect(card.MouseButton1Up, function()
            PlayTween(scale, 0.18, {Scale = 1}, Enum.EasingStyle.Back)
        end)
        return card, subtitle
    end

    -- REMOVED: key/HWID reset cards; kept discord + website only
    local discordCard, discordSubtitle = CreateInfoCard(1, "Discord", DisplayLink(Config.DiscordLink), "gamepad-2")
    UI.Links.Discord = discordCard
    UI.Links.Website = CreateInfoCard(2, "Website", DisplayLink(Config.WebsiteLink), "external-link")

    FetchDiscordCounts(function(online)
        if discordSubtitle.Parent then
            discordSubtitle.Text = string.format('<font color="%s">●</font> %s online', ToHex(Colors.Success), FormatNumber(online))
        end
    end)

    OnFrame(function(t) avatarGradient.Rotation = (t * 90) % 360 end)

    UI.RightTop = top
    UI.RightRows = rows
    UI.RightDivider = rightDivider
    UI.CardScroll = scroll

    UI.EntranceGroups = {UI.Header, UI.LaunchHolder, UI.Status, UI.VDivider, UI.RightTop, UI.RightRows, UI.RightDivider, UI.CardScroll}
    UI.ContentGroups = {UI.Header, UI.Body, UI.Right}
end

-- ============================================================
-- SUCCESS SCREEN (kept, source label changed)
-- ============================================================
local Success = {}
do
    local S
    if IsMobile then
        S = {
            Center = UDim2.fromOffset(145, 68),
            Title = {22, 110, 246},
            Subtitle = {22, 134, 246},
            Footer = {22, 196, 246},
            Card = {304, 18, 162, 224},
            Stacked = true
        }
    else
        S = {
            Center = UDim2.new(0.5, 0, 0, 62),
            Title = {15, 106, L.W - 30},
            Subtitle = {15, 131, L.W - 30},
            Footer = {18, 342, L.W - 36},
            Card = {18, 158, L.W - 36, 172},
            Stacked = false
        }
    end

    local frame = New("Frame", {
        Name = "Success",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Colors.White,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 50,
        Parent = UI.Card
    })
    Corner(frame, 14)
    Gradient(frame, {Colors.MainBGTop, Colors.MainBG}, 90)

    local headerGlow = New("Frame", {
        Size = UDim2.new(1, 0, 0, 150),
        BackgroundColor3 = Colors.Success,
        BorderSizePixel = 0,
        ZIndex = 50,
        Parent = frame
    })
    Corner(headerGlow, 14)
    New("UIGradient", {Rotation = 90, Transparency = Sequence(0, 0.85, 1, 1), Parent = headerGlow})

    local topLight = New("Frame", {
        Size = UDim2.new(1, -60, 0, 2),
        Position = UDim2.fromScale(0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Colors.White,
        BorderSizePixel = 0,
        ZIndex = 51,
        Parent = frame
    })
    Gradient(topLight, {Colors.AccentCyan, Colors.Success, Colors.AccentCyan}, 0, Sequence(0, 1, 0.2, 0, 0.8, 0, 1, 1))

    local baseObjects = {frame, headerGlow, topLight}
    if IsMobile then
        local divider = New("Frame", {
            Size = UDim2.new(0, 1, 1, -40),
            Position = UDim2.fromOffset(290, 20),
            BackgroundColor3 = Colors.Stroke:Lerp(Colors.Success, 0.4),
            BorderSizePixel = 0,
            ZIndex = 51,
            Parent = frame
        })
        New("UIGradient", {Rotation = 90, Transparency = Sequence(0, 1, 0.5, 0.2, 1, 1), Parent = divider})
        table.insert(baseObjects, divider)
    end

    local halo = New("Frame", {
        Size = UDim2.fromOffset(72, 72),
        Position = S.Center,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Colors.Success,
        BackgroundTransparency = 0.86,
        BorderSizePixel = 0,
        ZIndex = 51,
        Parent = frame
    })
    Corner(halo, "full")
    local haloStroke = Stroke(halo, Colors.Success, 1.5, 0.5)
    local haloScale = New("UIScale", {Parent = halo})

    local checkHolder = New("Frame", {
        Size = UDim2.fromOffset(72, 72),
        Position = S.Center,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        ZIndex = 53,
        Parent = frame
    })
    local checkBars = {
        MakeCheckBar(checkHolder, Vector2.new(-13, 1), Vector2.new(-4, 10), Colors.Success),
        MakeCheckBar(checkHolder, Vector2.new(-4, 10), Vector2.new(14, -9), Colors.Success)
    }

    local title = New("TextLabel", {
        Size = UDim2.fromOffset(S.Title[3], 24),
        Position = UDim2.fromOffset(S.Title[1], S.Title[2]),
        BackgroundTransparency = 1,
        Text = "Access Granted",
        TextColor3 = Colors.TextPrimary,
        Typeface = "Title",
        TextSize = 19,
        ZIndex = 52,
        Parent = frame
    })
    local subtitle = New("TextLabel", {
        Size = UDim2.fromOffset(S.Subtitle[3], 16),
        Position = UDim2.fromOffset(S.Subtitle[1], S.Subtitle[2]),
        BackgroundTransparency = 1,
        Text = "crack by c6r6",  -- CHANGED
        TextColor3 = Colors.AccentSoft,
        Typeface = "BodyMedium",
        TextSize = IsMobile and 12 or 13,
        ZIndex = 52,
        Parent = frame
    })

    local card = New("Frame", {
        Size = UDim2.fromOffset(S.Card[3], S.Card[4]),
        Position = UDim2.fromOffset(S.Card[1], S.Card[2]),
        BackgroundColor3 = Colors.SecondaryBG,
        BorderSizePixel = 0,
        ZIndex = 51,
        Parent = frame
    })
    Corner(card, 12)
    local cardStroke = Stroke(card, Colors.Stroke:Lerp(Colors.Success, 0.35), 1, 0)

    local rows = {}
    local function CreateSuccessRow(name, index, valueColor, isLast)
        local row
        local value
        if S.Stacked then
            row = New("Frame", {
                Size = UDim2.new(1, -24, 0, 34),
                Position = UDim2.fromOffset(12, 8 + (index - 1) * 35),
                BackgroundTransparency = 1,
                ZIndex = 53,
                Parent = card
            })
            New("TextLabel", {
                Size = UDim2.new(1, 0, 0, 12),
                BackgroundTransparency = 1,
                Text = string.upper(name),
                TextColor3 = Colors.TextMuted,
                Typeface = "Label",
                TextSize = 9,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 53,
                Parent = row
            })
            value = New("TextLabel", {
                Size = UDim2.new(1, 0, 0, 16),
                Position = UDim2.fromOffset(0, 13),
                BackgroundTransparency = 1,
                Text = "",
                TextColor3 = valueColor or Colors.TextPrimary,
                Typeface = "BodyBold",
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 53,
                Parent = row
            })
            if not isLast then
                New("Frame", {
                    Size = UDim2.new(1, 0, 0, 1),
                    Position = UDim2.fromOffset(0, 32),
                    BackgroundColor3 = Colors.Stroke,
                    BackgroundTransparency = 0.3,
                    BorderSizePixel = 0,
                    ZIndex = 53,
                    Parent = row
                })
            end
        else
            row = New("Frame", {
                Size = UDim2.new(1, -28, 0, 26),
                Position = UDim2.fromOffset(14, 6 + (index - 1) * 27),
                BackgroundTransparency = 1,
                ZIndex = 53,
                Parent = card
            })
            New("TextLabel", {
                Size = UDim2.new(0.42, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = Colors.TextSecondary,
                Typeface = "BodyMedium",
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 53,
                Parent = row
            })
            value = New("TextLabel", {
                Size = UDim2.new(0.58, 0, 1, 0),
                Position = UDim2.fromScale(1, 0),
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Text = "",
                TextColor3 = valueColor or Colors.TextPrimary,
                Typeface = "BodyBold",
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Right,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 53,
                Parent = row
            })
            if not isLast then
                New("Frame", {
                    Size = UDim2.new(1, 0, 0, 1),
                    Position = UDim2.fromScale(0, 1),
                    BackgroundColor3 = Colors.Stroke,
                    BackgroundTransparency = 0.3,
                    BorderSizePixel = 0,
                    ZIndex = 53,
                    Parent = row
                })
            end
        end
        table.insert(rows, row)
        return value
    end

    -- CHANGED: 3 rows only, no key/expiry noise for cracked build
    Success.Executor = CreateSuccessRow("Executor", 1, Colors.AccentSoft)
    Success.Device   = CreateSuccessRow("Device",   2, nil)
    Success.Credit   = CreateSuccessRow("Credit",   3, Colors.AccentGlow, true)

    local footer = New("Frame", {
        Size = UDim2.fromOffset(S.Footer[3], 30),
        Position = UDim2.fromOffset(S.Footer[1], S.Footer[2]),
        BackgroundTransparency = 1,
        ZIndex = 52,
        Parent = frame
    })
    local loading = New("TextLabel", {
        Size = UDim2.new(1, -60, 0, 16),
        BackgroundTransparency = 1,
        Text = "Loading Vanta",
        TextColor3 = Colors.TextSecondary,
        Typeface = "BodyMedium",
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 52,
        Parent = footer
    })
    local countdown = New("TextLabel", {
        Size = UDim2.fromOffset(60, 16),
        Position = UDim2.fromScale(1, 0),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Text = tostring(Config.SuccessDelay) .. "s",
        TextColor3 = Colors.Success,
        Typeface = "MonoBold",
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 52,
        Parent = footer
    })
    local progressBG = New("Frame", {
        Size = UDim2.new(1, 0, 0, 4),
        Position = UDim2.fromOffset(0, 24),
        BackgroundColor3 = Colors.TertiaryBG,
        BorderSizePixel = 0,
        ZIndex = 52,
        Parent = footer
    })
    Corner(progressBG, 4)
    local progress = New("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Colors.White,
        BorderSizePixel = 0,
        ZIndex = 53,
        Parent = progressBG
    })
    Corner(progress, 4)
    Gradient(progress, {Colors.Success, Colors.AccentCyan}, 0)

    Success.Frame = frame
    Success.Center = S.Center
    Success.Stacked = S.Stacked
    Success.HaloScale = haloScale
    Success.CheckBars = checkBars
    Success.Title = title
    Success.Subtitle = subtitle
    Success.Card = card
    Success.Rows = rows
    Success.Footer = footer
    Success.Loading = loading
    Success.Countdown = countdown
    Success.Progress = progress
    Success.Pulse = false

    Success.BaseSnapshot = CaptureVisuals(baseObjects)
    Success.HaloSnapshot = CaptureVisuals({halo, haloStroke})
    Success.TitleSnapshot = CaptureVisuals({title})
    Success.SubtitleSnapshot = CaptureVisuals({subtitle})
    Success.CardSnapshot = CaptureVisuals({card, cardStroke})
    Success.FooterSnapshot = CaptureVisuals(TreeOf(footer, true))
    Success.RowSnapshots = {}
    for index, row in ipairs(rows) do
        Success.RowSnapshots[index] = CaptureVisuals(TreeOf(row, true))
    end

    for _, snapshot in ipairs({Success.BaseSnapshot, Success.HaloSnapshot, Success.TitleSnapshot, Success.SubtitleSnapshot, Success.CardSnapshot, Success.FooterSnapshot}) do
        HideSnapshot(snapshot)
    end
    for _, snapshot in ipairs(Success.RowSnapshots) do HideSnapshot(snapshot) end
end

-- ============================================================
-- MORPH LOADER
-- ============================================================
do
    local morph = New("Frame", {
        Name = "Morph",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 60,
        Parent = UI.Card
    })
    local bar = New("Frame", {
        Size = UDim2.new(0, 3, 1, -20),
        Position = UDim2.fromOffset(9, 10),
        BackgroundColor3 = Colors.Accent,
        BorderSizePixel = 0,
        ZIndex = 61,
        Parent = morph
    })
    Corner(bar, 2)
    local spinner = New("Frame", {
        Size = UDim2.fromOffset(24, 24),
        Position = UDim2.fromOffset(34, MORPH_H / 2),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        ZIndex = 61,
        Parent = morph
    })
    Ring(spinner, 22, 2.5, Colors.AccentSoft, 0.75, 61)
    local arc, arcStroke = Ring(spinner, 22, 2.5, Colors.Accent, 0, 62)
    Comet(arcStroke)
    local titleLabel = New("TextLabel", {
        Size = UDim2.fromOffset(MORPH_W - 66, 16),
        Position = UDim2.fromOffset(54, 13),
        BackgroundTransparency = 1,
        Text = "Loading Vanta",
        TextColor3 = Colors.TextPrimary,
        Typeface = "Heading",
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 61,
        Parent = morph
    })
    local hint = New("TextLabel", {
        Size = UDim2.fromOffset(MORPH_W - 66, 15),
        Position = UDim2.fromOffset(54, 32),
        BackgroundTransparency = 1,
        Text = "crack by c6r6",  -- CHANGED
        TextColor3 = Colors.AccentSoft,
        Typeface = "Body",
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 61,
        Parent = morph
    })
    UI.Morph = morph
    UI.MorphBar = bar
    UI.MorphArc = arc
    UI.MorphTitle = titleLabel
    UI.MorphHint = hint
    UI.MorphSnapshot = CaptureVisuals(TreeOf(morph, false))
    HideSnapshot(UI.MorphSnapshot)
end

local loadingDots = ""

OnFrame(function(t, deltaTime)
    UI.CardStrokeGradient.Rotation = (t * 45) % 360
    UI.TopLightGradient.Offset = Vector2.new(math.sin(t * 1.3) * 0.25, 0)
    UI.CardGlow.ImageTransparency = 1 - (0.3 + math.sin(t * 1.5) * 0.08) * GlowAlpha.Value

    if UI.LaunchGradient and UI.LaunchGradient.Enabled then
        UI.LaunchGradient.Offset = Vector2.new(math.sin(t * 0.9) * 0.18, 0)
    end

    local barTarget = (statusLoading and contentRevealed and not closing) and 0 or 1
    local barNow = UI.LoadingBar.BackgroundTransparency
    UI.LoadingBar.BackgroundTransparency = barNow + (barTarget - barNow) * math.min(1, (deltaTime or 0.016) * 12)

    if statusLoading then
        UI.StatusIcon.Rotation = (t * 420) % 360
        UI.LoadingBar.Position = UDim2.fromScale(-0.35 + ((t * 0.85) % 1) * 1.35, 0)
    end

    if introActive then UI.IntroLogoGradient.Rotation = (t * 70) % 360 end
    if introSpinning then UI.IntroArc.Rotation = (t * 400) % 360 end
    if morphActive then UI.MorphArc.Rotation = (t * 450) % 360 end

    if successActive then
        if Success.Pulse then
            Success.HaloScale.Scale = 1 + math.sin(t * 3) * 0.04
        end
        local dots = string.rep(".", math.floor(t * 2.5) % 4)
        if dots ~= loadingDots then
            loadingDots = dots
            Success.Loading.Text = "Loading Vanta" .. dots
        end
    end
end)

local function UpdateScale(animated)
    if closing then return end
    local camera = Workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    local targetWidth = (isUserPanelOpen and PANEL_OPEN_WIDTH or L.W) + 40
    local scale = math.clamp(math.min(viewport.X / targetWidth, viewport.Y / (L.H + 40)), 0.5, 1)
    if animated then
        PlayTween(UI.Scale, 0.3, {Scale = scale}, Enum.EasingStyle.Quint)
    else
        UI.Scale.Scale = scale
    end
end

local function ClosePanelTweens(duration)
    if not Panel.Frame then return end
    PlayTween(Panel.Frame, duration, {Size = UDim2.fromOffset(0, L.H)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    PlayTween(Panel.Stroke, duration * 0.7, {Transparency = 1})
    PlayTween(UI.Root, duration + 0.04, {Size = UDim2.fromOffset(L.W, L.H)}, Enum.EasingStyle.Quint)
end

local function ToggleUserPanel(forceState)
    if IsMobile or not Panel.Frame or closing then return end
    local target = forceState
    if type(target) ~= "boolean" then target = not isUserPanelOpen end
    if target == isUserPanelOpen then return end
    isUserPanelOpen = target
    if isUserPanelOpen then
        HideSnapshot(Panel.Snapshot)
        Panel.Content.Position = UDim2.fromOffset(16, 0)
        PlayTween(UI.Root, 0.45, {Size = UDim2.fromOffset(PANEL_OPEN_WIDTH, L.H)}, Enum.EasingStyle.Quint)
        PlayTween(Panel.Frame, 0.45, {Size = UDim2.fromOffset(PANEL_WIDTH, L.H)}, Enum.EasingStyle.Quint)
        PlayTween(Panel.Stroke, 0.3, {Transparency = 0.1})
        task.delay(0.1, function()
            if isUserPanelOpen and not closing then
                ShowSnapshot(Panel.Snapshot, 0.35)
                PlayTween(Panel.Content, 0.45, {Position = UDim2.fromOffset(0, 0)}, Enum.EasingStyle.Quint)
            end
        end)
    else
        ClosePanelTweens(0.32)
    end
    task.delay(0.46, function() UpdateScale(true) end)
end

local StatusStyles = {
    idle    = {Color = Colors.AccentSoft, Icon = "shield",       Text = Colors.TextSecondary, Stroke = Colors.Stroke},
    loading = {Color = Colors.AccentSoft, Icon = "loader-2",     Text = Colors.TextPrimary,   Stroke = Colors.Accent},
    success = {Color = Colors.Success,    Icon = "check",         Text = Colors.Success,       Stroke = Colors.Success},
    error   = {Color = Colors.Error,      Icon = "alert-circle",  Text = Colors.Error,         Stroke = Colors.Error},
    warn    = {Color = Colors.Warn,       Icon = "alert-circle",  Text = Colors.Warn,          Stroke = Colors.Warn}
}

local statusToken = 0
local function SetStatus(mode, text, instant)
    local style = StatusStyles[mode] or StatusStyles.idle
    statusToken = statusToken + 1
    local token = statusToken
    statusLoading = mode == "loading"
    if not statusLoading then UI.StatusIcon.Rotation = 0 end
    UI.StatusIcon.Image = GetAsset(style.Icon)
    local finalText = text or "Ready..."

    if instant or introActive then
        UI.StatusIcon.ImageColor3 = style.Color
        UI.StatusChip.BackgroundColor3 = style.Color
        UI.StatusStroke.Color = style.Stroke
        UI.StatusText.Text = finalText
        UI.StatusText.TextColor3 = style.Text
        return
    end

    PlayTween(UI.StatusIcon, 0.25, {ImageColor3 = style.Color})
    PlayTween(UI.StatusChip, 0.25, {BackgroundColor3 = style.Color})
    PlayTween(UI.StatusStroke, 0.25, {Color = style.Stroke})
    UI.StatusIconScale.Scale = 0.55
    PlayTween(UI.StatusIconScale, 0.4, {Scale = 1}, Enum.EasingStyle.Back)
    PlayTween(UI.StatusText, 0.1, {TextTransparency = 1, Position = UDim2.fromOffset(UI.StatusTextX, -5)}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    task.delay(0.1, function()
        if token ~= statusToken or not UI.StatusText.Parent then return end
        UI.StatusText.Text = finalText
        UI.StatusText.TextColor3 = style.Text
        UI.StatusText.Position = UDim2.fromOffset(UI.StatusTextX, 5)
        PlayTween(UI.StatusText, 0.25, {TextTransparency = 0, Position = UDim2.fromOffset(UI.StatusTextX, 0)}, Enum.EasingStyle.Quint)
    end)
end

local function CleanupImmediate()
    closing = true
    statusLoading = false
    successActive = false
    introSpinning = false
    morphActive = false
    DisconnectAll()
    if VantaBlur and VantaBlur.Parent then VantaBlur:Destroy() end
    if ScreenGui and ScreenGui.Parent then ScreenGui:Destroy() end
end

local function AnimateInterfaceOut(callback)
    if closing then return end
    closing = true
    isAuthenticating = true
    statusLoading = false
    introSpinning = false
    if isUserPanelOpen then
        isUserPanelOpen = false
        ClosePanelTweens(0.22)
    end
    local targetScale = math.max(UI.Scale.Scale * 0.92, 0.45)
    PlayTween(UI.Root, 0.4, {Position = OffsetPosition(UI.Root.Position, 0, 20)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    PlayTween(UI.Scale, 0.4, {Scale = targetScale}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    FadeOutTree(UI.Root, 0.32)
    PlayTween(UI.Decor, 0.3, {GroupTransparency = 1})
    FadeOutTree(NotificationContainer, 0.3)
    PlayTween(GlowAlpha, 0.3, {Value = 0})
    PlayTween(VantaBlur, 0.4, {Size = 0}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    PlayTween(Backdrop, 0.4, {BackgroundTransparency = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    task.delay(0.42, function()
        CleanupImmediate()
        if callback then callback() end
    end)
end

local function CloseInterface()
    AnimateInterfaceOut()
end

if Workspace.CurrentCamera then
    Connect(Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), function()
        UpdateScale(false)
    end)
end

local function MorphAndLoad()
    if closing then return end
    closing = true
    isAuthenticating = true
    statusLoading = false

    local scale = UI.Scale.Scale
    local viewport = ScreenGui.AbsoluteSize
    local targetX = viewport.X - 20 - MORPH_W * scale / 2
    local targetY = viewport.Y - 20 - MORPH_H * scale / 2

    FadeOutTree(NotificationContainer, 0.25)
    FadeOutTree(Success.Frame, 0.25)
    PlayTween(UI.Decor, 0.3, {GroupTransparency = 1})
    PlayTween(GlowAlpha, 0.4, {Value = 0})
    PlayTween(VantaBlur, 0.5, {Size = 0}, Enum.EasingStyle.Quad)
    PlayTween(Backdrop, 0.5, {BackgroundTransparency = 1}, Enum.EasingStyle.Quad)
    task.wait(0.27)
    Success.Frame.Visible = false
    successActive = false

    PlayTween(UI.Root, 0.7, {Position = UDim2.fromOffset(targetX, targetY)}, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)
    PlayTween(UI.CardFrame, 0.7, {Size = UDim2.fromOffset(MORPH_W, MORPH_H)}, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)
    PlayTween(UI.CardCorner, 0.7, {CornerRadius = UDim.new(0, 12)}, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)
    UI.Morph.Visible = true
    morphActive = true
    task.delay(0.4, function() ShowSnapshot(UI.MorphSnapshot, 0.3) end)
    task.wait(0.75)

    -- run loader, no key needed
    local ok, err = pcall(function()
        local source = game:HttpGet(Config.LoaderURL):gsub("^\239\187\191", ""):gsub("^%s+", "")
        local loader, compileError = verifiedLoadstring(source)
        if type(loader) ~= "function" then
            error(compileError or "loader compile failed", 0)
        end
        loader()
    end)

    task.wait(0.9)

    if not ok then
        UI.MorphTitle.Text = "Failed to load Vanta"
        UI.MorphHint.Text = tostring(err):sub(1, 60)
        PlayTween(UI.MorphTitle, 0.2, {TextColor3 = Colors.Error})
        PlayTween(UI.MorphBar, 0.2, {BackgroundColor3 = Colors.Error})
        task.wait(3.5)
    else
        UI.MorphTitle.Text = "Vanta loaded"
        UI.MorphHint.Text = "crack by c6r6"
        PlayTween(UI.MorphTitle, 0.2, {TextColor3 = Colors.Success})
        PlayTween(UI.MorphBar, 0.2, {BackgroundColor3 = Colors.Success})
        task.wait(0.9)
    end

    FadeOutTree(UI.Root, 0.3)
    task.wait(0.35)
    CleanupImmediate()
end

-- SHOW SUCCESS THEN LAUNCH (no key needed)
local function ShowSuccessAndLaunch()
    if closing then return end

    -- fill cracked rows
    Success.Executor.Text = ExecutorName
    Success.Device.Text   = DeviceName
    Success.Credit.Text   = "crack by c6r6"

    successActive = true
    Success.Pulse = false
    Success.Progress.Size = UDim2.fromScale(1, 1)
    Success.Countdown.Text = tostring(Config.SuccessDelay) .. "s"
    Success.HaloScale.Scale = 0.4
    for _, bar in ipairs(Success.CheckBars) do bar.Frame.Visible = false end
    Success.Frame.Visible = true

    ShowSnapshot(Success.BaseSnapshot, 0.35, Enum.EasingStyle.Quad)
    task.delay(0.4, function()
        if Success.Frame.Visible then
            for _, group in ipairs(UI.ContentGroups) do group.Visible = false end
        end
    end)

    task.spawn(function()
        task.wait(0.1)
        if closing then return end
        ShowSnapshot(Success.HaloSnapshot, 0.3)
        PlayTween(Success.HaloScale, 0.5, {Scale = 1}, Enum.EasingStyle.Back)
        task.wait(0.3)
        if closing then return end
        DrawCheckBar(Success.CheckBars[1], 0.14)
        task.wait(0.14)
        DrawCheckBar(Success.CheckBars[2], 0.22)
        task.wait(0.18)
        if closing then return end
        Success.Pulse = true

        local ParticleColors = {Colors.Success, Colors.AccentCyan, Colors.AccentSoft, Colors.AccentGlow}
        local function BurstRing(parent, center, color)
            local ring = New("Frame", {
                Size = UDim2.fromOffset(44, 44), Position = center,
                AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, ZIndex = 52, Parent = parent
            })
            Corner(ring, "full")
            local rs = Stroke(ring, color, 2, 0.1)
            PlayTween(ring, 0.75, {Size = UDim2.fromOffset(140, 140)}, Enum.EasingStyle.Quint)
            PlayTween(rs, 0.75, {Transparency = 1, Thickness = 0.5}, Enum.EasingStyle.Quint)
            task.delay(0.78, function() if ring then ring:Destroy() end end)
        end
        local function EmitParticles(parent, origin, count)
            for index = 1, count do
                local angle = (index / count) * math.pi * 2 + (math.random() - 0.5) * 0.5
                local distance = 46 + math.random() * 36
                local width = math.random(4, 7)
                local dot = New("Frame", {
                    Size = UDim2.fromOffset(width, math.random(3, 5)),
                    Position = origin, AnchorPoint = Vector2.new(0.5, 0.5),
                    Rotation = math.random(0, 360),
                    BackgroundColor3 = ParticleColors[(index % #ParticleColors) + 1],
                    BorderSizePixel = 0, ZIndex = 54, Parent = parent
                })
                Corner(dot, 2)
                local target = UDim2.new(origin.X.Scale, origin.X.Offset + math.cos(angle) * distance, origin.Y.Scale, origin.Y.Offset + math.sin(angle) * distance * 0.85 + 10)
                local life = 0.6 + math.random() * 0.3
                PlayTween(dot, life, {Position = target, Rotation = dot.Rotation + math.random(-240, 240)}, Enum.EasingStyle.Quint)
                task.delay(life * 0.55, function() PlayTween(dot, life * 0.7, {BackgroundTransparency = 1}) end)
                task.delay(life * 1.4 + 0.1, function() if dot then dot:Destroy() end end)
            end
        end

        BurstRing(Success.Frame, Success.Center, Colors.Success)
        task.delay(0.12, function()
            if not closing then BurstRing(Success.Frame, Success.Center, Colors.AccentCyan) end
        end)
        EmitParticles(Success.Frame, Success.Center, 18)
    end)

    RevealGroup(Success.Title, Success.TitleSnapshot, 0.3, 0, 8)
    RevealGroup(Success.Subtitle, Success.SubtitleSnapshot, 0.36, 0, 8)
    RevealGroup(Success.Card, Success.CardSnapshot, 0.42, Success.Stacked and 12 or 0, Success.Stacked and 0 or 12)
    for index, row in ipairs(Success.Rows) do
        RevealGroup(row, Success.RowSnapshots[index], 0.5 + index * 0.05, Success.Stacked and 0 or 10, Success.Stacked and 6 or 0, 0.35)
    end
    RevealGroup(Success.Footer, Success.FooterSnapshot, 0.55, 0, 8)

    task.delay(0.6, function()
        if not closing then
            PlayTween(Success.Progress, Config.SuccessDelay - 0.3, {Size = UDim2.fromScale(0, 1)}, Enum.EasingStyle.Linear)
        end
    end)
    task.spawn(function()
        for remaining = Config.SuccessDelay, 1, -1 do
            if closing or not Success.Countdown.Parent then return end
            Success.Countdown.Text = tostring(remaining) .. "s"
            task.wait(1)
        end
    end)

    task.wait(Config.SuccessDelay + 0.3)
    MorphAndLoad()
end

-- LAUNCH BUTTON: fires directly into the success screen, no key gate
Connect(UI.LaunchButton.MouseButton1Click, function()
    if not IsReady() or not UseCooldown("launch", 1.2) or isAuthenticating then return end
    isAuthenticating = true
    SetStatus("loading", "Preparing launch...")
    UI.LaunchLabel.Text = "Launching..."
    UI.LaunchIcon.Rotation = 0
    task.spawn(ShowSuccessAndLaunch)
end)

-- LINK ACTIONS (no key-related ones)
local LinkActions = {
    Discord = function()
        if SafeClipboard(Config.DiscordLink) then
            Notify("Discord Copied", "Vanta Discord invite copied.", "Info", 3)
        else
            Notify("Unavailable", "Clipboard not supported by this executor.", "Error", 3)
        end
    end,
    Website = function()
        if SafeClipboard(Config.WebsiteLink) then
            Notify("Website Copied", "Vanta website copied.", "Info", 3)
        else
            Notify("Unavailable", "Clipboard not supported by this executor.", "Error", 3)
        end
    end,
    UserInfo = function()
        ToggleUserPanel()
    end
}

for name, button in pairs(UI.Links) do
    local action = LinkActions[name]
    if action then
        Connect(button.MouseButton1Click, function()
            if not IsReady() or not UseCooldown(name, name == "UserInfo" and 0.45 or 0.9) then return end
            action()
        end)
    end
end

Connect(UI.CloseButton.MouseButton1Click, function()
    if IsReady() and UseCooldown("close", 1) then CloseInterface() end
end)

if Panel.Close then
    Connect(Panel.Close.MouseButton1Click, function()
        if UseCooldown("panelclose", 0.45) then ToggleUserPanel(false) end
    end)
end

-- ============================================================
-- INTRO ANIMATION + AUTO-LAUNCH
-- ============================================================
SetStatus("loading", "Connecting...", true)
UpdateScale(false)

local chromeSnapshot = CaptureVisuals({UI.Card, UI.CardStroke, UI.TopLight, UI.CardShadow})
HideSnapshot(chromeSnapshot)

local entranceSnapshots = {}
for index, group in ipairs(UI.EntranceGroups) do
    entranceSnapshots[index] = CaptureVisuals(TreeOf(group, true))
    HideSnapshot(entranceSnapshots[index])
end

UI.CardFrame.Size = UDim2.fromOffset(INTRO_SIZE - 20, INTRO_SIZE - 20)
UI.Root.Visible = true

task.spawn(function()
    PlayTween(Backdrop, 0.6, {BackgroundTransparency = 0.6}, Enum.EasingStyle.Quad)
    PlayTween(VantaBlur, 0.6, {Size = 14}, Enum.EasingStyle.Quint)
    ShowSnapshot(chromeSnapshot, 0.5, Enum.EasingStyle.Quad)
    PlayTween(UI.CardFrame, 0.6, {Size = UDim2.fromOffset(INTRO_SIZE, INTRO_SIZE)}, Enum.EasingStyle.Quint)
    PlayTween(UI.IntroLogo, 0.5, {ImageTransparency = 0, BackgroundTransparency = 0})
    PlayTween(UI.IntroLogoStroke, 0.5, {Transparency = 0.1})
    PlayTween(UI.IntroLogoScale, 0.6, {Scale = 1}, Enum.EasingStyle.Back)
    task.wait(0.75)
    if closing then return end

    PlayTween(UI.CardFrame, 0.85, {Size = UDim2.fromOffset(L.W, L.H)}, Enum.EasingStyle.Quint)
    PlayTween(UI.IntroLogo, 0.7, {Position = UDim2.new(0.5, 0, 0.5, -20)}, Enum.EasingStyle.Quint)
    UI.IntroGlow.Position = UDim2.new(0.5, 0, 0.5, -20)
    PlayTween(UI.IntroGlow, 0.9, {ImageTransparency = 0.5}, Enum.EasingStyle.Quad)
    PlayTween(GlowAlpha, 0.9, {Value = 1}, Enum.EasingStyle.Quad)
    task.wait(0.35)
    if closing then return end

    introSpinning = true
    PlayTween(UI.IntroTrackStroke, 0.35, {Transparency = 0.82})
    PlayTween(UI.IntroArcStroke, 0.35, {Transparency = 0})
    task.wait(0.9)
    if closing then return end

    PlayTween(UI.IntroTrackStroke, 0.25, {Transparency = 1})
    PlayTween(UI.IntroArcStroke, 0.25, {Transparency = 1})
    PlayTween(UI.IntroLogo, 0.3, {ImageTransparency = 1, BackgroundTransparency = 1})
    PlayTween(UI.IntroLogoStroke, 0.3, {Transparency = 1})
    PlayTween(UI.IntroGlow, 0.3, {ImageTransparency = 1})
    PlayTween(UI.IntroLogoScale, 0.3, {Scale = 0.85})
    task.wait(0.2)
    if closing then return end

    introSpinning = false
    introActive = false
    contentRevealed = true
    PlayTween(UI.Decor, 0.7, {GroupTransparency = 0}, Enum.EasingStyle.Quad)
    for index, group in ipairs(UI.EntranceGroups) do
        RevealGroup(group, entranceSnapshots[index], (index - 1) * 0.05, 0, 10)
    end

    SetStatus("idle", "crack by c6r6 — ready.")
    Notify("Vanta Hub", "crack by c6r6 — click Launch to continue.", "Info", 4)
end)
