-- Auto Block OrionLib Script (Converted from Rayfield)
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({
    Name = "Auto Block Hub", 
    HidePremium = false, 
    SaveConfig = true, 
    IntroEnabled = false,
    ConfigFolder = "AutoBlockHub"
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local PlayerGui = lp:WaitForChild("PlayerGui")
local Humanoid, Animator
local StarterGui = game:GetService("StarterGui")
local TestService = game:GetService("TestService")
local Debris = game:GetService("Debris")

-- Create Tabs
local AutoBlockTab = Window:MakeTab({
    Name = "Auto Block",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local BDTab = Window:MakeTab({
    Name = "Better Detection",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local PredictiveTab = Window:MakeTab({
    Name = "Predictive Block",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local FakeBlockTab = Window:MakeTab({
    Name = "Fake Block",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local AutoPunchTab = Window:MakeTab({
    Name = "Auto Punch",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local CustomAnimationsTab = Window:MakeTab({
    Name = "Custom Animations",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Audio-based Auto Block IDs
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

local autoBlockTriggerAnims = {
    "126830014841198", "126355327951215", "121086746534252", "18885909645",
    "98456918873918", "105458270463374", "83829782357897", "125403313786645",
    "118298475669935", "82113744478546", "70371667919898", "99135633258223",
    "97167027849946", "109230267448394", "139835501033932", "126896426760253",
    "109667959938617", "126681776859538", "129976080405072", "121293883585738",
    "81639435858902", "137314737492715", "92173139187970"
}

-- State Variables
local autoBlockOn = false
local autoBlockAudioOn = false
local doubleblocktech = false
local looseFacing = true
local detectionRange = 18
local facingCheckEnabled = true
local antiFlickOn = false
local antiFlickParts = 4
local antiFlickBaseOffset = 2.7
local antiFlickOffsetStep = 0
local antiFlickDelay = 0
local stagger = 0.02
local blockPartsSizeMultiplier = 1
local predictionStrength = 1
local predictionTurnStrength = 1
local autoAdjustDBTFBPS = false
local predictiveBlockOn = false
local edgeKillerDelay = 3
local killerInRangeSince = nil
local predictiveCooldown = 0
local autoPunchOn = false
local flingPunchOn = false
local flingPower = 10000
local hiddenfling = false
local aimPunch = false
local predictionValue = 4
local customBlockEnabled = false
local customBlockAnimId = ""
local customPunchEnabled = false
local customPunchAnimId = ""
local customChargeEnabled = false
local customChargeAnimId = ""
local infiniteStamina = false
local espEnabled = false
local facingVisualOn = false
local killerCirclesVisible = false

-- Cached UI references
local cachedPlayerGui = PlayerGui
local cachedPunchBtn, cachedBlockBtn, cachedCharges, cachedCooldown = nil, nil, nil, nil
local detectionRangeSq = detectionRange * detectionRange

local KillersFolder = workspace:WaitForChild("Players"):WaitForChild("Killers")
local killerNames = {"c00lkidd", "Jason", "JohnDoe", "1x1x1x1", "Noli", "Slasher"}

-- Animation IDs
local blockAnimIds = {"72722244508749", "96959123077498"}
local punchAnimIds = {
    "87259391926321", "140703210927645", "136007065400978", "129843313690921",
    "86709774283672", "108807732150251", "138040001965654", "86096387000557"
}
local chargeAnimIds = {"106014898528300"}

-- Helper Functions
local function refreshUIRefs()
    cachedPlayerGui = lp:FindFirstChild("PlayerGui") or PlayerGui
    local main = cachedPlayerGui and cachedPlayerGui:FindFirstChild("MainUI")
    if main then
        local ability = main:FindFirstChild("AbilityContainer")
        cachedPunchBtn = ability and ability:FindFirstChild("Punch")
        cachedBlockBtn = ability and ability:FindFirstChild("Block")
        cachedCharges = cachedPunchBtn and cachedPunchBtn:FindFirstChild("Charges")
        cachedCooldown = cachedBlockBtn and cachedBlockBtn:FindFirstChild("CooldownTime")
    else
        cachedPunchBtn, cachedBlockBtn, cachedCharges, cachedCooldown = nil, nil, nil, nil
    end
end

-- ESP Functions
local function addESP(obj)
    if not obj:IsA("Model") then return end
    if not obj:FindFirstChild("HumanoidRootPart") then return end

    local plr = Players:GetPlayerFromCharacter(obj)
    if not plr then return end

    -- Prevent duplicates
    if obj:FindFirstChild("ESP_Highlight") then return end

    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = obj
    highlight.Parent = obj

    -- Billboard
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard"
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.Adornee = obj:FindFirstChild("HumanoidRootPart")
    billboard.Parent = obj

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "ESP_Text"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Text = obj.Name
    textLabel.Parent = billboard
end

local function clearESP(obj)
    if obj:FindFirstChild("ESP_Highlight") then
        obj.ESP_Highlight:Destroy()
    end
    if obj:FindFirstChild("ESP_Billboard") then
        obj.ESP_Billboard:Destroy()
    end
end

local function refreshESP()
    if not espEnabled then
        for _, killer in pairs(KillersFolder:GetChildren()) do
            clearESP(killer)
        end
        return
    end

    for _, killer in pairs(KillersFolder:GetChildren()) do
        addESP(killer)
    end
end

local function fireRemoteBlock()
    local args = {"UseActorAbility", "Block"}
    ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end

local function fireRemotePunch()
    local args = {"UseActorAbility", "Punch"}
    ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end

local function isFacing(localRoot, targetRoot)
    if not facingCheckEnabled then
        return true
    end
    local dir = (localRoot.Position - targetRoot.Position).Unit
    local dot = targetRoot.CFrame.LookVector:Dot(dir)
    return looseFacing and dot > -0.3 or dot > 0
end

-- Initialize UI references
refreshUIRefs()

-- ESP Event Connections
KillersFolder.ChildAdded:Connect(function(child)
    if espEnabled then
        task.wait(0.1) -- wait for HRP
        addESP(child)
    end
end)

KillersFolder.ChildRemoved:Connect(function(child)
    clearESP(child)
end)

-- Distance updater for ESP
RunService.RenderStepped:Connect(function()
    if not espEnabled then return end
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _, killer in pairs(KillersFolder:GetChildren()) do
        local billboard = killer:FindFirstChild("ESP_Billboard")
        if billboard and billboard:FindFirstChild("ESP_Text") and killer:FindFirstChild("HumanoidRootPart") then
            local dist = (killer.HumanoidRootPart.Position - hrp.Position).Magnitude
            billboard.ESP_Text.Text = string.format("%s\n[%d]", killer.Name, dist)
        end
    end
end)

-- Auto Block Tab
AutoBlockTab:AddLabel("Auto Block System")

AutoBlockTab:AddToggle({
    Name = "Auto Block (Animation)",
    Default = false,
    Callback = function(Value)
        autoBlockOn = Value
    end
})

AutoBlockTab:AddToggle({
    Name = "Auto Block (Audio)",
    Default = false,
    Callback = function(Value)
        autoBlockAudioOn = Value
    end
})

AutoBlockTab:AddToggle({
    Name = "Double Punch Tech",
    Default = false,
    Callback = function(Value)
        doubleblocktech = Value
    end
})

AutoBlockTab:AddToggle({
    Name = "Enable Facing Check",
    Default = true,
    Callback = function(Value)
        facingCheckEnabled = Value
    end
})

AutoBlockTab:AddDropdown({
    Name = "Facing Check Mode",
    Default = "Loose",
    Options = {"Loose", "Strict"},
    Callback = function(Value)
        looseFacing = (Value == "Loose")
    end
})

AutoBlockTab:AddTextbox({
    Name = "Detection Range",
    Default = "18",
    TextDisappear = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num then
            detectionRange = num
            detectionRangeSq = detectionRange * detectionRange
        end
    end
})

AutoBlockTab:AddToggle({
    Name = "Range Visual",
    Default = false,
    Callback = function(Value)
        killerCirclesVisible = Value
        -- Add visual circle logic here
    end
})

AutoBlockTab:AddToggle({
    Name = "Facing Check Visual",
    Default = false,
    Callback = function(Value)
        facingVisualOn = Value
        -- Add facing visual logic here
    end
})

-- Better Detection Tab
BDTab:AddLabel("Better Detection System")
BDTab:AddParagraph("Notice", "BD or Better Detection delays on coolkid, use normal detection against coolkid.")

BDTab:AddToggle({
    Name = "Better Detection (doesn't use detectrange)",
    Default = false,
    Callback = function(Value)
        antiFlickOn = Value
    end
})

BDTab:AddSlider({
    Name = "Block Parts Count",
    Min = 1,
    Max = 16,
    Default = 4,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "parts",
    Callback = function(Value)
        antiFlickParts = math.max(1, math.floor(Value))
    end
})

BDTab:AddSlider({
    Name = "Block Parts Size Multiplier",
    Min = 0.1,
    Max = 5,
    Default = 1,
    Color = Color3.fromRGB(255,255,255),
    Increment = 0.1,
    ValueName = "x",
    Callback = function(Value)
        blockPartsSizeMultiplier = Value
    end
})

BDTab:AddSlider({
    Name = "Forward Prediction Strength",
    Min = 0,
    Max = 10,
    Default = 1,
    Color = Color3.fromRGB(255,255,255),
    Increment = 0.1,
    ValueName = "x",
    Callback = function(Value)
        predictionStrength = Value
    end
})

BDTab:AddSlider({
    Name = "Turn Prediction Strength",
    Min = 0,
    Max = 10,
    Default = 1,
    Color = Color3.fromRGB(255,255,255),
    Increment = 0.1,
    ValueName = "x",
    Callback = function(Value)
        predictionTurnStrength = Value
    end
})

BDTab:AddTextbox({
    Name = "Delay Before Block Parts Spawn",
    Default = "0",
    TextDisappear = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num then
            antiFlickDelay = math.max(0, num)
        end
    end
})

BDTab:AddTextbox({
    Name = "Delay Between Each Block Part",
    Default = "0.02",
    TextDisappear = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num then
            stagger = math.max(0, num)
        end
    end
})

BDTab:AddTextbox({
    Name = "Distance In Front of Killer",
    Default = "2.7",
    TextDisappear = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num then
            antiFlickBaseOffset = math.max(0, num)
        end
    end
})

BDTab:AddToggle({
    Name = "Auto-adjust DBTFBPS based on killer",
    Default = false,
    Callback = function(Value)
        autoAdjustDBTFBPS = Value
    end
})

-- Predictive Tab
PredictiveTab:AddLabel("Predictive Auto Block System")

PredictiveTab:AddToggle({
    Name = "Predictive Auto Block",
    Default = false,
    Callback = function(Value)
        predictiveBlockOn = Value
    end
})

PredictiveTab:AddTextbox({
    Name = "Detection Range",
    Default = "10",
    TextDisappear = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num then
            detectionRange = num
        end
    end
})

PredictiveTab:AddSlider({
    Name = "Edge Killer Delay",
    Min = 0,
    Max = 7,
    Default = 3,
    Color = Color3.fromRGB(255,255,255),
    Increment = 0.1,
    ValueName = "seconds",
    Callback = function(Value)
        edgeKillerDelay = Value
    end
})

PredictiveTab:AddParagraph("Edge Killer", "How many seconds until it blocks (resets when killer gets out of range)")

-- Fake Block Tab
FakeBlockTab:AddLabel("Fake Block System")

FakeBlockTab:AddButton({
    Name = "Load Fake Block",
    Callback = function()
        pcall(function()
            local fakeGui = PlayerGui:FindFirstChild("FakeBlockGui")
            if not fakeGui then
                local success, result = pcall(function()
                    return loadstring(game:HttpGet("https://raw.githubusercontent.com/skibidi399/Auto-block-script/refs/heads/main/fakeblock"))()
                end)
                if not success then
                    warn("Failed to load Fake Block GUI:", result)
                end
            else
                fakeGui.Enabled = true
                print("Fake Block GUI enabled")
            end
        end)
    end
})

-- Auto Punch Tab
AutoPunchTab:AddLabel("Auto Punch System")

AutoPunchTab:AddToggle({
    Name = "Auto Punch",
    Default = false,
    Callback = function(Value)
        autoPunchOn = Value
    end
})

AutoPunchTab:AddToggle({
    Name = "Fling Punch",
    Default = false,
    Callback = function(Value)
        flingPunchOn = Value
    end
})

AutoPunchTab:AddToggle({
    Name = "Punch Aimbot",
    Default = false,
    Callback = function(Value)
        aimPunch = Value
    end
})

AutoPunchTab:AddSlider({
    Name = "Aim Prediction",
    Min = 0,
    Max = 10,
    Default = 4,
    Color = Color3.fromRGB(255,255,255),
    Increment = 0.1,
    ValueName = "studs",
    Callback = function(Value)
        predictionValue = Value
    end
})

AutoPunchTab:AddSlider({
    Name = "Fling Power",
    Min = 5000,
    Max = 50000000,
    Default = 10000,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1000,
    ValueName = "power",
    Callback = function(Value)
        flingPower = Value
    end
})

-- Custom Animations Tab
CustomAnimationsTab:AddLabel("Custom Animation System")

CustomAnimationsTab:AddTextbox({
    Name = "Custom Block Animation ID",
    Default = "",
    TextDisappear = false,
    Callback = function(Text)
        customBlockAnimId = Text
    end
})

CustomAnimationsTab:AddToggle({
    Name = "Enable Custom Block Animation",
    Default = false,
    Callback = function(Value)
        customBlockEnabled = Value
    end
})

CustomAnimationsTab:AddTextbox({
    Name = "Custom Punch Animation ID",
    Default = "",
    TextDisappear = false,
    Callback = function(Text)
        customPunchAnimId = Text
    end
})

CustomAnimationsTab:AddToggle({
    Name = "Enable Custom Punch Animation",
    Default = false,
    Callback = function(Value)
        customPunchEnabled = Value
    end
})

CustomAnimationsTab:AddTextbox({
    Name = "Custom Charge Animation ID",
    Default = "",
    TextDisappear = false,
    Callback = function(Text)
        customChargeAnimId = Text
    end
})

CustomAnimationsTab:AddToggle({
    Name = "Enable Custom Charge Animation",
    Default = false,
    Callback = function(Value)
        customChargeEnabled = Value
    end
})

-- Misc Tab
MiscTab:AddLabel("Miscellaneous Features")

MiscTab:AddButton({
    Name = "Run Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})

MiscTab:AddParagraph("Tip", 'Run Infinite Yield and type "antifling" so punch fling works better.')

MiscTab:AddToggle({
    Name = "Infinite Stamina",
    Default = false,
    Callback = function(Value)
        infiniteStamina = Value
        if infiniteStamina then
            -- Enable infinite stamina logic
            local success, StaminaModule = pcall(function()
                return require(game.ReplicatedStorage.Systems.Character.Game.Sprinting)
            end)
            if success and StaminaModule then
                StaminaModule.StaminaLossDisabled = true
                task.spawn(function()
                    while infiniteStamina and StaminaModule do
                        task.wait(0.1)
                        StaminaModule.Stamina = StaminaModule.MaxStamina
                        StaminaModule.StaminaChanged:Fire()
                    end
                end)
            end
        end
    end
})

MiscTab:AddToggle({
    Name = "Killer ESP",
    Default = false,
    Callback = function(Value)
        espEnabled = Value
        refreshESP()
    end
})

-- Main detection loop (simplified version of the original)
RunService.RenderStepped:Connect(function()
    local gui = PlayerGui:FindFirstChild("MainUI")
    local punchBtn = gui and gui:FindFirstChild("AbilityContainer") and gui.AbilityContainer:FindFirstChild("Punch")
    local charges = punchBtn and punchBtn:FindFirstChild("Charges")
    local blockBtn = gui and gui:FindFirstChild("AbilityContainer") and gui.AbilityContainer:FindFirstChild("Block")
    local cooldown = blockBtn and blockBtn:FindFirstChild("CooldownTime")

    local myChar = lp.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    Humanoid = myChar:FindFirstChildOfClass("Humanoid")

    -- Auto Block: Trigger block if a valid animation is played by a killer
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local animTracks = hum and hum:FindFirstChildOfClass("Animator") and hum:FindFirstChildOfClass("Animator"):GetPlayingAnimationTracks()

            if hrp and myRoot and (hrp.Position - myRoot.Position).Magnitude <= detectionRange then
                for _, track in ipairs(animTracks or {}) do
                    local id = tostring(track.Animation.AnimationId):match("%d+")
                    if table.find(autoBlockTriggerAnims, id) then
                        if autoBlockOn and (hrp.Position - myRoot.Position).Magnitude <= detectionRange then
                            if isFacing(myRoot, hrp) then
                                if cooldown and cooldown.Text == "" then
                                    fireRemoteBlock()
                                end
                                if doubleblocktech == true and charges and charges.Text == "1" then
                                    fireRemotePunch()
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Auto Punch logic
    if autoPunchOn then
        if charges and charges.Text == "1" then
            for _, name in ipairs(killerNames) do
                local killer = workspace:FindFirstChild("Players")
                    and workspace.Players:FindFirstChild("Killers")
                    and workspace.Players.Killers:FindFirstChild(name)
                if killer and killer:FindFirstChild("HumanoidRootPart") then
                    local root = killer.HumanoidRootPart
                    if root and myRoot and (root.Position - myRoot.Position).Magnitude <= 10 then
                        fireRemotePunch()
                        
                        if flingPunchOn then
                            hiddenfling = true
                            local targetHRP = root
                            task.spawn(function()
                                local start = tick()
                                while tick() - start < 1 do
                                    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and targetHRP and targetHRP.Parent then
                                        local frontPos = targetHRP.Position + (targetHRP.CFrame.LookVector * 2)
                                        lp.Character.HumanoidRootPart.CFrame = CFrame.new(frontPos, targetHRP.Position)
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
    end
end)

OrionLib:Init()
