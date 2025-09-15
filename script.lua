-- Ultimate Forsaken Hub by cbthedb
-- Complete compiled script with all features

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local Stats = game:GetService("Stats")
local lp = Players.LocalPlayer
local PlayerGui = lp:WaitForChild("PlayerGui")

-- Load Rayfield with error handling
local Rayfield
local success, err = pcall(function()
    Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)

if not success then
    warn("Failed to load Rayfield: " .. tostring(err))
    -- Try alternative URL
    success, err = pcall(function()
        Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()
    end)
    
    if not success then
        warn("Failed to load Rayfield from alternative URL: " .. tostring(err))
        -- Create a simple notification
        game.StarterGui:SetCore("SendNotification", {
            Title = "Ultimate Forsaken Hub";
            Text = "Failed to load Rayfield UI library";
            Duration = 5;
        })
        return
    end
end

-- Create Main Window
local Window = Rayfield:CreateWindow({
    Name = "Ultimate Forsaken Hub",
    LoadingTitle = "Ultimate Forsaken Hub",
    LoadingSubtitle = "by cbthedb",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "UltimateForsaken",
        FileName = "Settings"
    },
    Discord = {Enabled = false},
    KeySystem = false
})

-- Create Tabs
local DefenseTab = Window:CreateTab("Defense System", 4483362458)
local AutoPunchTab = Window:CreateTab("Auto Punch", 4483362458)
local CustomAnimTab = Window:CreateTab("Custom Animations", 4483362458)
local ESPTab = Window:CreateTab("ESP", 4483362458)
local AimbotTab = Window:CreateTab("Chance Aimbot", 4483362458)
local VoidRushTab = Window:CreateTab("Void Rush Control", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

-- Global Variables and Helper Functions
local KillersFolder = workspace:WaitForChild("Players"):WaitForChild("Killers")

-- =============================================================================
-- DEFENSE SYSTEM TAB (Consolidated)
-- =============================================================================

-- Ultra Instinct Variables
local ultraInstinctEnabled = false
local dodgeDistance = 7
local dodgeDirection = "Left"
local canDodge = true

-- Auto Block Variables
local autoBlockOn = false
local autoBlockAudioOn = false
local doubleblocktech = false
local detectionRange = 18
local facingCheckEnabled = true
local looseFacing = true

-- Better Detection Variables
local antiFlickOn = false
local antiFlickParts = 4
local antiFlickDelay = 0
local blockPartsSizeMultiplier = 1
local predictionStrength = 1
local predictionTurnStrength = 1

-- Predictive Block Variables
local predictiveBlockOn = false
local edgeKillerDelay = 3
local killerInRangeSince = nil
local predictiveCooldown = 0

-- Backstab Variables
local backstabEnabled = false
local backstabRange = 4
local backstabMode = "Behind"
local attackType = "Normal"
local matchFacing = false
local lastTarget = nil
local cooldown = false

local killerNames = {"Jason", "c00lkidd", "JohnDoe", "1x1x1x1", "Noli", "Slasher"}

local killerAnims = {
    "126830014841198", "126355327951215", "121086746534252", "18885909645",
    "98456918873918", "105458270463374", "83829782357897", "125403313786645",
    "118298475669935", "82113744478546", "70371667919898", "99135633258223",
    "97167027849946", "109230267448394", "139835501033932", "126896426760253",
    "109667959938617", "126681776859538", "129976080405072", "121293883585738"
}

local dodgeAnims = {
    Left = "rbxassetid://17096325697",
    Right = "rbxassetid://17096327600",
    Forward = "rbxassetid://17096329187",
    Backward = "rbxassetid://17096330733",
}

-- Auto Block IDs
local autoBlockTriggerAnims = {
    "126830014841198", "126355327951215", "121086746534252", "18885909645",
    "98456918873918", "105458270463374", "83829782357897", "125403313786645",
    "118298475669935", "82113744478546", "70371667919898", "99135633258223",
    "97167027849946", "109230267448394", "139835501033932", "126896426760253",
    "109667959938617", "126681776859538", "129976080405072", "121293883585738",
    "81639435858902", "137314737492715", "92173139187970"
}

local autoBlockTriggerSounds = {
    ["102228729296384"] = true,
    ["140242176732868"] = true,
    ["112809109188560"] = true,
    ["136323728355613"] = true,
    ["115026634746636"] = true,
    ["84116622032112"] = true,
    ["108907358619313"] = true,
    ["127793641088496"] = true,
    ["86174610237192"] = true,
    ["95079963655241"] = true,
    ["101199185291628"] = true,
    ["119942598489800"] = true,
    ["84307400688050"] = true,
    ["113037804008732"] = true,
    ["105200830849301"] = true,
    ["75330693422988"] = true,
    ["82221759983649"] = true,
    ["81702359653578"] = true,
    ["108610718831698"] = true,
    ["112395455254818"] = true,
    ["109431876587852"] = true,
    ["109348678063422"] = true,
    ["85853080745515"] = true,
    ["12222216"] = true,
}

-- Defense Tab UI Elements
DefenseTab:CreateSection({Name = "Ultra Instinct"})

DefenseTab:CreateToggle({
    Name = "Ultra Instinct",
    CurrentValue = false,
    Flag = "UltraInstinct",
    Callback = function(Value) ultraInstinctEnabled = Value end
})

DefenseTab:CreateInput({
    Name = "Dodge Distance",
    PlaceholderText = "7",
    RemoveTextAfterFocusLost = false,
    Flag = "DodgeDistance",
    Callback = function(Text) dodgeDistance = tonumber(Text) or 7 end
})

DefenseTab:CreateDropdown({
    Name = "Dodge Direction",
    Options = {"Left", "Right", "Forward", "Backward", "Random"},
    CurrentOption = "Left",
    Flag = "DodgeDirection",
    Callback = function(Option) dodgeDirection = Option end
})

DefenseTab:CreateSection({Name = "Auto Block"})

DefenseTab:CreateToggle({
    Name = "Auto Block (Animation)",
    CurrentValue = false,
    Flag = "AutoBlockAnimation",
    Callback = function(Value) autoBlockOn = Value end
})

DefenseTab:CreateToggle({
    Name = "Auto Block (Audio)",
    CurrentValue = false,
    Flag = "AutoBlockAudio",
    Callback = function(Value) autoBlockAudioOn = Value end
})

DefenseTab:CreateToggle({
    Name = "Double Punch Tech",
    CurrentValue = false,
    Flag = "DoublePunchTech",
    Callback = function(Value) doubleblocktech = Value end
})

DefenseTab:CreateToggle({
    Name = "Enable Facing Check",
    CurrentValue = true,
    Flag = "FacingCheck",
    Callback = function(Value) facingCheckEnabled = Value end
})

DefenseTab:CreateDropdown({
    Name = "Facing Check Mode",
    Options = {"Loose", "Strict"},
    CurrentOption = "Loose",
    Flag = "FacingMode",
    Callback = function(Option) looseFacing = (Option == "Loose") end
})

DefenseTab:CreateInput({
    Name = "Detection Range",
    PlaceholderText = "18",
    RemoveTextAfterFocusLost = false,
    Flag = "DetectionRange",
    Callback = function(Text) detectionRange = tonumber(Text) or 18 end
})

DefenseTab:CreateSection({Name = "Better Detection"})

DefenseTab:CreateToggle({
    Name = "Better Detection",
    CurrentValue = false,
    Flag = "BetterDetection",
    Callback = function(Value) antiFlickOn = Value end
})

DefenseTab:CreateSlider({
    Name = "Block Parts Count",
    Range = {1, 16},
    Increment = 1,
    Suffix = "parts",
    CurrentValue = 4,
    Flag = "BlockPartsCount",
    Callback = function(Value) antiFlickParts = Value end
})

DefenseTab:CreateSlider({
    Name = "Block Parts Size Multiplier",
    Range = {0.1, 5},
    Increment = 0.1,
    Suffix = "x",
    CurrentValue = 1,
    Flag = "BlockPartsSize",
    Callback = function(Value) blockPartsSizeMultiplier = Value end
})

DefenseTab:CreateInput({
    Name = "Delay Before Block Parts Spawn",
    PlaceholderText = "0",
    RemoveTextAfterFocusLost = false,
    Flag = "BlockPartsDelay",
    Callback = function(Text) antiFlickDelay = tonumber(Text) or 0 end
})

DefenseTab:CreateSection({Name = "Predictive Block"})

DefenseTab:CreateToggle({
    Name = "Predictive Auto Block",
    CurrentValue = false,
    Flag = "PredictiveBlock",
    Callback = function(Value) predictiveBlockOn = Value end
})

DefenseTab:CreateSlider({
    Name = "Edge Killer Delay",
    Range = {0, 7},
    Increment = 0.1,
    CurrentValue = 3,
    Flag = "EdgeKillerDelay",
    Callback = function(Value) edgeKillerDelay = Value end
})

DefenseTab:CreateSection({Name = "Fake Block"})

DefenseTab:CreateButton({
    Name = "Load Fake Block",
    Callback = function()
        pcall(function()
            local fakeGui = PlayerGui:FindFirstChild("FakeBlockGui")
            if not fakeGui then
                loadstring(game:HttpGet("https://raw.githubusercontent.com/skibidi399/Auto-block-script/refs/heads/main/fakeblock"))()
            else
                fakeGui.Enabled = true
            end
        end)
    end
})

DefenseTab:CreateSection({Name = "Backstab"})

DefenseTab:CreateToggle({
    Name = "Backstab",
    CurrentValue = false,
    Flag = "Backstab",
    Callback = function(Value) backstabEnabled = Value end
})

DefenseTab:CreateInput({
    Name = "Backstab Range",
    PlaceholderText = "4",
    RemoveTextAfterFocusLost = false,
    Flag = "BackstabRange",
    Callback = function(Text) backstabRange = tonumber(Text) or 4 end
})

DefenseTab:CreateDropdown({
    Name = "Backstab Mode",
    Options = {"Behind", "Around"},
    CurrentOption = "Behind",
    Flag = "BackstabMode",
    Callback = function(Option) backstabMode = Option end
})

DefenseTab:CreateDropdown({
    Name = "Backstab Type",
    Options = {"Normal", "Counter", "Legit"},
    CurrentOption = "Normal",
    Flag = "AttackType",
    Callback = function(Option) attackType = Option end
})

DefenseTab:CreateToggle({
    Name = "Legit Aimbot (Legit mode only)",
    CurrentValue = false,
    Flag = "MatchFacing",
    Callback = function(Value) matchFacing = Value end
})

-- =============================================================================
-- AUTO PUNCH TAB
-- =============================================================================

local autoPunchOn = false
local flingPunchOn = false
local flingPower = 10000
local hiddenfling = false
local aimPunch = false
local predictionValue = 4

AutoPunchTab:CreateToggle({
    Name = "Auto Punch",
    CurrentValue = false,
    Flag = "AutoPunch",
    Callback = function(Value) autoPunchOn = Value end
})

AutoPunchTab:CreateToggle({
    Name = "Fling Punch",
    CurrentValue = false,
    Flag = "FlingPunch",
    Callback = function(Value) flingPunchOn = Value end
})

AutoPunchTab:CreateToggle({
    Name = "Punch Aimbot",
    CurrentValue = false,
    Flag = "PunchAimbot",
    Callback = function(Value) aimPunch = Value end
})

AutoPunchTab:CreateSlider({
    Name = "Fling Power",
    Range = {5000, 50000000},
    Increment = 1000,
    CurrentValue = 10000,
    Flag = "FlingPower",
    Callback = function(Value) flingPower = Value end
})

-- =============================================================================
-- CUSTOM ANIMATIONS TAB
-- =============================================================================

local customBlockEnabled = false
local customBlockAnimId = ""
local customPunchEnabled = false
local customPunchAnimId = ""

CustomAnimTab:CreateToggle({
    Name = "Enable Custom Block Animation",
    CurrentValue = false,
    Flag = "CustomBlockEnabled",
    Callback = function(Value) customBlockEnabled = Value end
})

CustomAnimTab:CreateInput({
    Name = "Custom Block Animation ID",
    PlaceholderText = "AnimationId",
    RemoveTextAfterFocusLost = false,
    Flag = "CustomBlockAnimId",
    Callback = function(Text) customBlockAnimId = Text end
})

CustomAnimTab:CreateToggle({
    Name = "Enable Custom Punch Animation",
    CurrentValue = false,
    Flag = "CustomPunchEnabled",
    Callback = function(Value) customPunchEnabled = Value end
})

CustomAnimTab:CreateInput({
    Name = "Custom Punch Animation ID",
    PlaceholderText = "AnimationId",
    RemoveTextAfterFocusLost = false,
    Flag = "CustomPunchAnimId",
    Callback = function(Text) customPunchAnimId = Text end
})

-- =============================================================================
-- ESP TAB
-- =============================================================================

local espEnabled = false

ESPTab:CreateToggle({
    Name = "Killer ESP",
    CurrentValue = false,
    Flag = "KillerESP",
    Callback = function(Value) espEnabled = Value end
})

ESPTab:CreateButton({
    Name = "Load Item ESP",
    Callback = function()
        -- Load item ESP functionality
        for _, obj in Workspace:GetDescendants() do
            if obj:IsA("Tool") and not (obj.Name == "RedFlag" or obj.Name == "BlueFlag" or obj.Name == "Item") then
                if not obj:FindFirstChildOfClass("Highlight") then
                    local highlight = Instance.new("Highlight")
                    highlight.FillColor = Color3.new(1, 1, 0)
                    highlight.OutlineColor = Color3.new(1, 0, 0)
                    highlight.Parent = obj
                end
            end
        end
    end
})

-- =============================================================================
-- CHANCE AIMBOT TAB
-- =============================================================================

-- Chance Aimbot Variables
local chanceAimbotEnabled = false
local predictionMode = "Velocity"
local aimMode = "Normal"
local aimDuration = 1.7
local predictionAmount = 4
local spinDuration = 0.5
local messageWhenAim = false
local messageText = ""
local useCustomAnim = false
local customAnimId = ""
local autoCoinflip = false
local coinflipTargetCharge = "3"

-- Chance Aimbot State Variables
local aiming = false
local shooting = false
local messageSentThisAim = false
local Humanoid, HRP = nil, nil
local lastTriggerTime = 0
local originalWS, originalJP, originalAutoRotate = nil, nil, nil
local prevFlintVisibleAim = false
local prevFlintVisibleShoot = false
local movementThreshold = 0.5
local lastCoinflipTime = 0
local coinflipCooldown = 0.15
local loadedCustomAnimTrack = nil

local aimTargets = {"Slasher", "c00lkidd", "JohnDoe", "1x1x1x1", "Noli"}

AimbotTab:CreateToggle({
    Name = "Chance Aimbot",
    CurrentValue = false,
    Flag = "ChanceAimbot",
    Callback = function(Value) chanceAimbotEnabled = Value end
})

AimbotTab:CreateDropdown({
    Name = "Prediction Mode",
    Options = {"Velocity", "Ping", "Infront HRP", "Infront HRP (Ping Adjust)"},
    CurrentOption = "Velocity",
    Flag = "PredictionMode",
    Callback = function(Option) predictionMode = Option end
})

AimbotTab:CreateDropdown({
    Name = "Aim Behavior",
    Options = {"Normal", "360"},
    CurrentOption = "Normal",
    Flag = "AimBehavior",
    Callback = function(Option) aimMode = Option end
})

AimbotTab:CreateInput({
    Name = "Prediction Amount",
    PlaceholderText = "4",
    RemoveTextAfterFocusLost = false,
    Flag = "PredictionAmount",
    Callback = function(Text) predictionAmount = tonumber(Text) or 4 end
})

AimbotTab:CreateInput({
    Name = "Spin Duration (360 mode)",
    PlaceholderText = "0.5",
    RemoveTextAfterFocusLost = false,
    Flag = "SpinDuration",
    Callback = function(Text) spinDuration = tonumber(Text) or 0.5 end
})

AimbotTab:CreateToggle({
    Name = "Message When Aim",
    CurrentValue = false,
    Flag = "MessageWhenAim",
    Callback = function(Value) messageWhenAim = Value end
})

AimbotTab:CreateInput({
    Name = "Message Text",
    PlaceholderText = "Message to send when aiming",
    RemoveTextAfterFocusLost = false,
    Flag = "MessageText",
    Callback = function(Text) messageText = Text end
})

AimbotTab:CreateToggle({
    Name = "Custom Shoot Animation",
    CurrentValue = false,
    Flag = "CustomShootAnim",
    Callback = function(Value) useCustomAnim = Value end
})

AimbotTab:CreateInput({
    Name = "Custom Animation ID",
    PlaceholderText = "Enter Anim ID",
    RemoveTextAfterFocusLost = false,
    Flag = "CustomAnimID",
    Callback = function(Text) customAnimId = Text end
})

AimbotTab:CreateToggle({
    Name = "Auto Coinflip",
    CurrentValue = false,
    Flag = "AutoCoinflip",
    Callback = function(Value) autoCoinflip = Value end
})

AimbotTab:CreateDropdown({
    Name = "Coinflip Charges",
    Options = {"1", "2", "3"},
    CurrentOption = "3",
    Flag = "CoinflipCharges",
    Callback = function(Option) coinflipTargetCharge = Option end
})

-- =============================================================================
-- VOID RUSH CONTROL TAB
-- =============================================================================

local voidRushControlEnabled = false

VoidRushTab:CreateToggle({
    Name = "Void Rush Control",
    CurrentValue = false,
    Flag = "VoidRushControl",
    Callback = function(Value) voidRushControlEnabled = Value end
})

-- =============================================================================
-- MISC TAB
-- =============================================================================

local infiniteStamina = false

MiscTab:CreateToggle({
    Name = "Infinite Stamina",
    CurrentValue = false,
    Flag = "InfiniteStamina",
    Callback = function(Value) infiniteStamina = Value end
})

MiscTab:CreateButton({
    Name = "Run Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})

MiscTab:CreateButton({
    Name = "FPS Booster",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/JoshzzAlteregooo/JoshzzFpsBoosterVersion3/refs/heads/main/JoshzzNewFpsBooster"))()
    end
})

-- =============================================================================
-- HELPER FUNCTIONS
-- =============================================================================

local function fireRemoteBlock()
    local args = {"UseActorAbility", "Block"}
    ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end

local function fireRemotePunch()
    local args = {"UseActorAbility", "Punch"}
    ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end

local function isFacing(localRoot, targetRoot)
    if not facingCheckEnabled then return true end
    local dir = (localRoot.Position - targetRoot.Position).Unit
    local dot = targetRoot.CFrame.LookVector:Dot(dir)
    return looseFacing and dot > -0.3 or dot > 0
end

local function playDodge()
    if not canDodge then return end
    canDodge = false

    local char = lp.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    local dir = dodgeDirection
    if dir == "Random" then
        local options = {"Left", "Right", "Forward", "Backward"}
        dir = options[math.random(1, #options)]
    end

    local offset = Vector3.new()
    if dir == "Left" then
        offset = -hrp.CFrame.RightVector * dodgeDistance
    elseif dir == "Right" then
        offset = hrp.CFrame.RightVector * dodgeDistance
    elseif dir == "Forward" then
        offset = hrp.CFrame.LookVector * dodgeDistance
    elseif dir == "Backward" then
        offset = -hrp.CFrame.LookVector * dodgeDistance
    end

    local anim = Instance.new("Animation")
    anim.AnimationId = dodgeAnims[dir]
    local track = hum:LoadAnimation(anim)
    track:Play()

    char:PivotTo(CFrame.new(hrp.Position + offset))

    task.delay(2, function()
        canDodge = true
    end)
end

-- Chance Aimbot Helper Functions
local function setupCharacter(char)
    Humanoid = char:WaitForChild("Humanoid")
    HRP = char:WaitForChild("HumanoidRootPart")
end

if lp.Character then
    setupCharacter(lp.Character)
end
lp.CharacterAdded:Connect(setupCharacter)

local function getPingSeconds()
    local pingStat = Stats.Network.ServerStatsItem["Data Ping"]
    if pingStat then
        return pingStat:GetValue() / 1000
    end
    return 0.1
end

local function getValidTarget()
    local killersFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers")
    if killersFolder then
        for _, name in ipairs(aimTargets) do
            local target = killersFolder:FindFirstChild(name)
            if target and target:FindFirstChild("HumanoidRootPart") then
                return target.HumanoidRootPart, target:FindFirstChild("Humanoid")
            end
        end
    end
    return nil, nil
end

local function getPredictedAimPosPing(targetHRP, killerHumanoid)
    local ping = getPingSeconds()
    local velocity = targetHRP.Velocity

    if velocity.Magnitude <= movementThreshold then
        return targetHRP.Position
    end

    return targetHRP.Position + (velocity * ping)
end

local function getPredictedAimPosInfrontHRPPing(targetHRP)
    local ping = getPingSeconds()
    local studs = ping * 60

    if targetHRP.Velocity.Magnitude <= movementThreshold then
        return targetHRP.Position
    end

    return targetHRP.Position + (targetHRP.CFrame.LookVector * studs)
end

local function isFlintlockVisible()
    if not lp.Character then return false end
    local flint = lp.Character:FindFirstChild("Flintlock", true)
    if not flint then return false end

    if not (flint:IsA("BasePart") or flint:IsA("MeshPart") or flint:IsA("UnionOperation")) then
        flint = flint:FindFirstChildWhichIsA("BasePart", true)
        if not flint then return false end
    end

    if flint.Transparency >= 1 then
        return false
    end
    return true
end

local function sendChatMessage(text)
    if not text or text:match("^%s*$") then return end
    local TextChatService = game:GetService("TextChatService")
    local channel = TextChatService.TextChannels.RBXGeneral
    channel:SendAsync(text)
end

local function playCustomShootAnim()
    if not useCustomAnim or not Humanoid then return end

    local animId = tonumber(customAnimId)
    if not animId then return end

    for _, track in ipairs(Humanoid.Animator:GetPlayingAnimationTracks()) do
        track:Stop()
    end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. animId
    local track = Humanoid:FindFirstChild("Animator"):LoadAnimation(anim)
    loadedCustomAnimTrack = track
    track:Play()

    if track.Looped then
        delay(1.7, function()
            if track.IsPlaying then
                track:Stop()
            end
        end)
    end
end

local function readCoinflipChargesText()
    local ok, txt = pcall(function()
        local mainUI = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("MainUI")
        if not mainUI then return nil end
        local abil = mainUI:FindFirstChild("AbilityContainer")
        if not abil then return nil end
        local coin = abil:FindFirstChild("Reroll")
        if not coin then return nil end
        local chargesLabel = coin:FindFirstChild("Charges")
        if not chargesLabel then return nil end
        return tostring(chargesLabel.Text)
    end)
    if ok then return txt end
    return nil
end

-- =============================================================================
-- MAIN LOOPS
-- =============================================================================

-- Ultra Instinct Detection
RunService.Heartbeat:Connect(function()
    if not ultraInstinctEnabled then return end
    
    local char = lp.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local radius = 25

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (plr.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
            if dist <= radius then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                local animator = hum and hum:FindFirstChildOfClass("Animator")
                if animator then
                    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                        local animObj = track.Animation
                        if animObj and animObj.AnimationId then
                            local animId = tostring(animObj.AnimationId):match("%d+")
                            if animId and table.find(killerAnims, animId) then
                                if canDodge then
                                    playDodge()
                                end
                                return
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Chance Aimbot Main Loop
RunService.RenderStepped:Connect(function()
    if not chanceAimbotEnabled or not Humanoid or not HRP then return end

    -- Edge detection for aiming
    local isVisible = isFlintlockVisible()
    if isVisible and not prevFlintVisibleAim and not aiming then
        lastTriggerTime = tick()
        aiming = true
    end
    prevFlintVisibleAim = isVisible

    if aiming then
        local elapsed = tick() - lastTriggerTime

        if aimMode == "360" then
            if elapsed <= spinDuration then
                local spinProgress = elapsed / spinDuration
                local spinAngle = math.rad(360 * spinProgress)
                HRP.CFrame = CFrame.new(HRP.Position) * CFrame.Angles(0, spinAngle, 0)

            elseif elapsed <= spinDuration + 0.7 then
                if not originalWS then
                    originalWS = Humanoid.WalkSpeed
                    originalJP = Humanoid.JumpPower
                    originalAutoRotate = Humanoid.AutoRotate
                end

                Humanoid.AutoRotate = false
                HRP.AssemblyAngularVelocity = Vector3.zero

                local targetHRP, killerHumanoid = getValidTarget()
                if targetHRP then
                    local aimPos
                    if predictionMode == "Ping" then
                        aimPos = getPredictedAimPosPing(targetHRP, killerHumanoid)
                    elseif predictionMode == "Infront HRP" then
                        local studs = predictionAmount
                        if targetHRP.Velocity.Magnitude > movementThreshold then
                            aimPos = targetHRP.Position + (targetHRP.CFrame.LookVector * studs)
                        else
                            aimPos = targetHRP.Position + (targetHRP.Velocity * (predictionAmount / 60))
                        end
                    end

                    if aimPos then
                        local direction = (aimPos - HRP.Position).Unit
                        local yRot = math.atan2(-direction.X, -direction.Z)
                        HRP.CFrame = CFrame.new(HRP.Position) * CFrame.Angles(0, yRot, 0)
                    end
                end

            else
                aiming = false
                if originalWS and originalJP and originalAutoRotate ~= nil then
                    Humanoid.WalkSpeed = originalWS
                    Humanoid.JumpPower = originalJP
                    Humanoid.AutoRotate = originalAutoRotate
                    originalWS, originalJP, originalAutoRotate = nil, nil, nil
                end
            end

        else -- Normal mode
            if elapsed <= aimDuration then
                if not originalWS then
                    originalWS = Humanoid.WalkSpeed
                    originalJP = Humanoid.JumpPower
                    originalAutoRotate = Humanoid.AutoRotate
                end

                Humanoid.AutoRotate = false
                HRP.AssemblyAngularVelocity = Vector3.zero

                local targetHRP, killerHumanoid = getValidTarget()
                if targetHRP then
                    local aimPos
                    if predictionMode == "Ping" then
                        aimPos = getPredictedAimPosPing(targetHRP, killerHumanoid)
                    elseif predictionMode == "Infront HRP" then
                        local studs = predictionAmount
                        if targetHRP.Velocity.Magnitude > movementThreshold then
                            aimPos = targetHRP.Position + (targetHRP.CFrame.LookVector * studs)
                        else
                            aimPos = targetHRP.Position
                        end
                    elseif predictionMode == "Infront HRP (Ping Adjust)" then
                        aimPos = getPredictedAimPosInfrontHRPPing(targetHRP)
                    else -- Velocity mode
                        if targetHRP.Velocity.Magnitude <= movementThreshold then
                            aimPos = targetHRP.Position
                        else
                            aimPos = targetHRP.Position + (targetHRP.Velocity * (predictionAmount / 60))
                        end
                    end

                    if aimPos then
                        local direction = (aimPos - HRP.Position).Unit
                        local yRot = math.atan2(-direction.X, -direction.Z)
                        HRP.CFrame = CFrame.new(HRP.Position) * CFrame.Angles(0, yRot, 0)
                    end
                end
            else
                aiming = false
                if originalWS and originalJP and originalAutoRotate ~= nil then
                    Humanoid.WalkSpeed = originalWS
                    Humanoid.JumpPower = originalJP
                    Humanoid.AutoRotate = originalAutoRotate
                    originalWS, originalJP, originalAutoRotate = nil, nil, nil
                end
            end
        end
    end

    -- Auto Coinflip Logic
    if autoCoinflip then
        local charges = tonumber(readCoinflipChargesText())
        local target = tonumber(coinflipTargetCharge)

        if charges and target and charges < target then
            local now = tick()
            if now - lastCoinflipTime >= coinflipCooldown then
                lastCoinflipTime = now
                pcall(function()
                    ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack({
                        [1] = "UseActorAbility",
                        [2] = "CoinFlip",
                    }))
                end)
            end
        end
    end
end)

-- Chance Aimbot Shooting Detection
RunService.RenderStepped:Connect(function()
    if not chanceAimbotEnabled then return end
    
    local isVisible = isFlintlockVisible()
    if isVisible and not prevFlintVisibleShoot and not shooting then
        lastTriggerTime = tick()
        shooting = true
        messageSentThisAim = false
        if messageWhenAim then
            sendChatMessage(messageText)
            messageSentThisAim = true
        end
    end
    prevFlintVisibleShoot = isVisible
    
    if shooting then
        if useCustomAnim then
            playCustomShootAnim()
        end
        messageSentThisAim = false
        shooting = false
    end
end)

-- Main Defense and Auto Features Loop
RunService.RenderStepped:Connect(function()
    local myChar = lp.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local myHumanoid = myChar:FindFirstChildOfClass("Humanoid")

    -- Auto Block (Animation)
    if autoBlockOn then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                local animTracks = hum and hum:FindFirstChildOfClass("Animator") and hum:FindFirstChildOfClass("Animator"):GetPlayingAnimationTracks()

                if hrp and myRoot and (hrp.Position - myRoot.Position).Magnitude <= detectionRange then
                    for _, track in ipairs(animTracks or {}) do
                        local id = tostring(track.Animation.AnimationId):match("%d+")
                        if table.find(autoBlockTriggerAnims, id) then
                            if isFacing(myRoot, hrp) then
                                fireRemoteBlock()
                                if doubleblocktech then
                                    fireRemotePunch()
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Auto Block (Audio)
    if autoBlockAudioOn then
        for _, descendant in ipairs(workspace:GetDescendants()) do
            if descendant:IsA("Sound") and descendant.Playing then
                local soundId = tostring(descendant.SoundId):match("%d+")
                if soundId and autoBlockTriggerSounds[soundId] then
                    local soundParent = descendant.Parent
                    if soundParent and soundParent.Parent and soundParent.Parent:IsA("Model") then
                        local targetHRP = soundParent.Parent:FindFirstChild("HumanoidRootPart")
                        if targetHRP and myRoot then
                            local distance = (targetHRP.Position - myRoot.Position).Magnitude
                            if distance <= detectionRange and isFacing(myRoot, targetHRP) then
                                fireRemoteBlock()
                                if doubleblocktech then
                                    fireRemotePunch()
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Predictive Auto Block
    if predictiveBlockOn and tick() > predictiveCooldown then
        local killerInRange = false
        for _, killer in ipairs(KillersFolder:GetChildren()) do
            local hrp = killer:FindFirstChild("HumanoidRootPart")
            if hrp and myRoot then
                local dist = (myRoot.Position - hrp.Position).Magnitude
                if dist <= detectionRange then
                    killerInRange = true
                    break
                end
            end
        end

        if killerInRange then
            if not killerInRangeSince then
                killerInRangeSince = tick()
            elseif tick() - killerInRangeSince >= edgeKillerDelay then
                fireRemoteBlock()
                predictiveCooldown = tick() + 2
                killerInRangeSince = nil
            end
        else
            killerInRangeSince = nil
        end
    end

    -- Auto Punch
    if autoPunchOn then
        for _, name in ipairs(killerNames) do
            local killer = KillersFolder:FindFirstChild(name)
            if killer and killer:FindFirstChild("HumanoidRootPart") and myRoot then
                local root = killer.HumanoidRootPart
                if (root.Position - myRoot.Position).Magnitude <= 10 then
                    fireRemotePunch()
                    
                    if flingPunchOn then
                        hiddenfling = true
                        task.spawn(function()
                            local start = tick()
                            while tick() - start < 1 do
                                if myChar and myChar:FindFirstChild("HumanoidRootPart") and root and root.Parent then
                                    local frontPos = root.Position + (root.CFrame.LookVector * 2)
                                    myChar.HumanoidRootPart.CFrame = CFrame.new(frontPos, root.Position)
                                end
                                task.wait()
                            end
                            hiddenfling = false
                        end)
                    end
                    break
                end
            end
        end
    end

    -- Backstab Logic
    if backstabEnabled and not cooldown then
        for _, name in ipairs(killerNames) do
            local killer = KillersFolder:FindFirstChild(name)
            if killer and killer:FindFirstChild("HumanoidRootPart") and myRoot then
                local killerRoot = killer.HumanoidRootPart
                local distance = (killerRoot.Position - myRoot.Position).Magnitude
                
                if distance <= backstabRange then
                    local shouldAttack = false
                    
                    if backstabMode == "Behind" then
                        local toPlayer = (myRoot.Position - killerRoot.Position).Unit
                        local killerLook = killerRoot.CFrame.LookVector
                        local dot = killerLook:Dot(toPlayer)
                        shouldAttack = dot > 0.5 -- Behind
                    elseif backstabMode == "Around" then
                        shouldAttack = true -- Attack from any angle
                    end
                    
                    if shouldAttack then
                        if attackType == "Normal" then
                            fireRemotePunch()
                        elseif attackType == "Counter" then
                            fireRemoteBlock()
                            task.wait(0.1)
                            fireRemotePunch()
                        elseif attackType == "Legit" then
                            if matchFacing then
                                local lookDir = (killerRoot.Position - myRoot.Position).Unit
                                myRoot.CFrame = CFrame.lookAt(myRoot.Position, myRoot.Position + lookDir)
                            end
                            fireRemotePunch()
                        end
                        
                        cooldown = true
                        lastTarget = killer
                        task.delay(1, function() cooldown = false end)
                        break
                    end
                end
            end
        end
    end
end)

-- ESP System
RunService.Heartbeat:Connect(function()
    if espEnabled then
        for _, killer in ipairs(KillersFolder:GetChildren()) do
            if killer:FindFirstChild("Head") then
                local head = killer.Head
                if not head:FindFirstChild("ESPGui") then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "ESPGui"
                    billboard.Adornee = head
                    billboard.Size = UDim2.new(0, 200, 0, 50)
                    billboard.StudsOffset = Vector3.new(0, 2, 0)
                    
                    local frame = Instance.new("Frame")
                    frame.Size = UDim2.new(1, 0, 1, 0)
                    frame.BackgroundTransparency = 0.3
                    frame.BackgroundColor3 = Color3.new(1, 0, 0)
                    frame.Parent = billboard
                    
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.Text = killer.Name
                    label.TextColor3 = Color3.new(1, 1, 1)
                    label.TextScaled = true
                    label.Font = Enum.Font.SourceSansBold
                    label.Parent = frame
                    
                    billboard.Parent = head
                end
            end
        end
    else
        -- Remove ESP when disabled
        for _, killer in ipairs(KillersFolder:GetChildren()) do
            if killer:FindFirstChild("Head") and killer.Head:FindFirstChild("ESPGui") then
                killer.Head.ESPGui:Destroy()
            end
        end
    end
end)

-- Infinite Stamina
if infiniteStamina then
    RunService.Heartbeat:Connect(function()
        local char = lp.Character
        if char and char:FindFirstChild("Stamina") then
            char.Stamina.Value = char.Stamina.MaxValue or 100
        end
    end)
end

-- Load Configuration
Rayfield:LoadConfiguration().Position
                        end
                    elseif predictionMode == "Infront HRP (Ping Adjust)" then
                        aimPos = getPredictedAimPosInfrontHRPPing(targetHRP)
                    else
                        if targetHRP.Velocity.Magnitude <= movementThreshold then
                            aimPos = targetHRP.Position
                        else
                            aimPos = targetHRP
