if getgenv().cuppink then warn("CupPibk Hub : Already executed!") return end
getgenv().cuppink = false

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()


local DeviceType = game:GetService("UserInputService").TouchEnabled and "Mobile" or "PC"
if DeviceType == "Mobile" then
    local ClickButton = Instance.new("ScreenGui")
    local ImageButton = Instance.new("ImageButton");
    local UICorner = Instance.new("UICorner");

    ClickButton.Name = "ClickButton"
    ClickButton.Parent = game.CoreGui
    ClickButton.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    ImageButton.Parent = ClickButton
    ImageButton.BackgroundColor3 = Color3.fromRGB(105,105,105)
    ImageButton.BackgroundTransparency = 0.8
    ImageButton.Position = UDim2.new(0.9,0,0.1,0)
    ImageButton.Size = UDim2.new(0,50,0,50)
    ImageButton.Image = "rbxassetid://119937569996752"
    --ImageButton.Draggable = true;
    ImageButton.Transparency = 1;
    UICorner.CornerRadius = UDim.new(0,200);
    UICorner.Parent = ImageButton;

    ImageButton.MouseButton1Click:Connect(function()
        game:GetService("VirtualInputManager"):SendKeyEvent(true, "LeftControl", false, game)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, "LeftControl", false, game)
    end)
end

local Window = Fluent:CreateWindow({
    Title = game:GetService("MarketplaceService"):GetProductInfo(16732694052).Name .." | CupPink - Premium",
    SubTitle = " (discord.gg/KyfvX2HB3v)",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Rose",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

-- // // // Services // // // --
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local CoreGui = game:GetService('StarterGui')
local ContextActionService = game:GetService('ContextActionService')
local UserInputService = game:GetService('UserInputService')
local RunService = game:GetService("RunService")
local TPService = game:GetService("TeleportService")
local RenderStepped = RunService.RenderStepped
local WaitForSomeone = RenderStepped.Wait

-- // // // Locals // // // --
local LocalPlayer = Players.LocalPlayer
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = LocalCharacter:FindFirstChild("HumanoidRootPart")
local UserPlayer = HumanoidRootPart:WaitForChild("user")
local ActiveFolder = Workspace:FindFirstChild("active")
local FishingZonesFolder = Workspace:FindFirstChild("zones"):WaitForChild("fishing")
local TpSpotsFolder = Workspace:FindFirstChild("world"):WaitForChild("spawns"):WaitForChild("TpSpots")
local NpcFolder = Workspace:FindFirstChild("world"):WaitForChild("npcs")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Mouse = LocalPlayer:GetMouse()

-- // // // Features List // // // --


-- // // // Variables // // // --
local CastMode = "Blatant"
local ShakeMode = "Navigation"
local ReelMode = "Blatant"
local CollectMode = "Teleports"
local teleportSpots = {}
local FreezeChar = false
local DayOnlyLoop = nil
local BypassGpsLoop = nil
local Noclip = false
local RunCount = false
local SelectedTotemDupe = nil
local Target
local ZoneCastValue = false
local fishtable = {}

-- // // // Functions // // // --
function ShowNotification(String)
    Fluent:Notify({
        Title = "CupPink Hub",
        Content = String,
        Duration = 5
    })
end

game.Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

local Ant1AFKConnection
local function autoAnt1AFK()
    game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("afk"):FireServer(false)
end
Ant1AFKConnection = RunService.RenderStepped:Connect(autoAnt1AFK)

-- // // // Data Buy Items // // // --
local AllItems = {
    ['Advanced Diving Gear'] = {Price = 15000, Type = 'Item'},
    ['Aurora Rod'] = {Price = 90000, Type = 'Rod'},
    ['Aurora Totem'] = {Price = 500000, Type = 'Item'},
    ['Bait Crate'] = {Price = 120, Type = 'Fish'},
    ['Basic Diving Gear'] = {Price = 3000, Type = 'Item'},
    ['Carbon Crate'] = {Price = 490, Type = 'Fish'},
    ['Carbon Rod'] = {Price = 2000, Type = 'Rod'},
    ['Common Crate'] = {Price = 128, Type = 'Fish'},
    ['Conception Conch'] = {Price = 444, Type = 'Item'},
    ['Coral Geode'] = {Price = 600, Type = 'Fish'},
    ['Crab Cage'] = {Price = 45, Type = 'Item'},
    ['Destiny Rod'] = {Price = 190000, Type = 'Rod'},
    ['Eclipse Totem'] = {Price = 250000, Type = 'Item'},
    ['Fast Rod'] = {Price = 4500, Type = 'Rod'},
    ['Firework'] = {Price = 130, Type = 'Item'},
    ['Fish Radar'] = {Price = 8000, Type = 'Item'},
    ['Flippers'] = {Price = 9000, Type = 'Item'},
    ['Fortune Rod'] = {Price = 12750, Type = 'Rod'},
    ['GPS'] = {Price = 100, Type = 'Item'},
    ['Glider'] = {Price = 900, Type = 'Item'},
    ['Kings Rod'] = {Price = 120000, Type = 'Rod'},
    ['Lucky Rod'] = {Price = 5250, Type = 'Rod'},
    ['Magnet Rod'] = {Price = 15000, Type = 'Rod'},
    ['Meteor Totem'] = {Price = 75000, Type = 'Item'},
    ['Midas Rod'] = {Price = 55000, Type = 'Rod'},
    ['Mythical Rod'] = {Price = 110000, Type = 'Rod'},
    ['Phoenix Rod'] = {Price = 40000, Type = 'Rod'},
    ['Plastic Rod'] = {Price = 900, Type = 'Rod'},
    ['Quality Bait Crate'] = {Price = 525, Type = 'Fish'},
    ['Rapid Rod'] = {Price = 14000, Type = 'Rod'},
    ['Rod Of The Depths'] = {Price = 750000, Type = 'Rod'},
    ['Scurvy Rod'] = {Price = 50000, Type = 'Rod'},
    ['Smokescreen Totem'] = {Price = 2000, Type = 'Item'},
    ['Steady Rod'] = {Price = 7000, Type = 'Rod'},
    ['Stone Rod'] = {Price = 3000, Type = 'Rod'},
    ['Sundial Totem'] = {Price = 2000, Type = 'Item'},
    ['Super Flippers'] = {Price = 30000, Type = 'Item'},
    ['Tempest Totem'] = {Price = 2000, Type = 'Item'},
    ['Tidebreaker'] = {Price = 80000, Type = 'Item'},
    ['Volcanic Geode'] = {Price = 600, Type = 'Fish'},
    ['Windset Totem'] = {Price = 2000, Type = 'Item'},
    ['Witches Ingredient'] = {Price = 10000, Type = 'Item'},
}

-- // // // Auto Cast // // // --
local autoCastEnabled = false
local function autoCast()
    if LocalCharacter then
        local tool = LocalCharacter:FindFirstChildOfClass("Tool")
        if tool then
            local hasBobber = tool:FindFirstChild("bobber")
            if not hasBobber then
                if CastMode == "Legit" then
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, LocalPlayer, 0)
                    HumanoidRootPart.ChildAdded:Connect(function()
                        if HumanoidRootPart:FindFirstChild("power") ~= nil and HumanoidRootPart.power.powerbar.bar ~= nil then
                            HumanoidRootPart.power.powerbar.bar.Changed:Connect(function(property)
                                if property == "Size" then
                                    if HumanoidRootPart.power.powerbar.bar.Size == UDim2.new(1, 0, 1, 0) then
                                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, LocalPlayer, 0)
                                    end
                                end
                            end)
                        end
                    end)
                elseif CastMode == "Blatant" then
                    local rod = LocalCharacter and LocalCharacter:FindFirstChildOfClass("Tool")
                    if rod and rod:FindFirstChild("values") and string.find(rod.Name, "Rod") then
                        task.wait(0.5)
                        local Random = math.random(90, 99)
                        rod.events.cast:FireServer(Random)
                    end
                end
            end
        end
        task.wait(0.5)
    end
end

-- // // // Auto Shake // // // --
local autoShakeEnabled = false
local autoShakeConnection
local function autoShake()
    if ShakeMode == "Navigation" then
        task.wait()
        xpcall(function()
            local shakeui = PlayerGui:FindFirstChild("shakeui")
            if not shakeui then return end
            local safezone = shakeui:FindFirstChild("safezone")
            local button = safezone and safezone:FindFirstChild("button")
            task.wait(0.2)
            GuiService.SelectedObject = button
            if GuiService.SelectedObject == button then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
            end
            task.wait(0.1)
            GuiService.SelectedObject = nil
        end,function (err)
        end)
    elseif ShakeMode == "Mouse" then
        task.wait()
        xpcall(function()
            local shakeui = PlayerGui:FindFirstChild("shakeui")
            if not shakeui then return end
            local safezone = shakeui:FindFirstChild("safezone")
            local button = safezone and safezone:FindFirstChild("button")
            local pos = button.AbsolutePosition
            local size = button.AbsoluteSize
            VirtualInputManager:SendMouseButtonEvent(pos.X + size.X / 2, pos.Y + size.Y / 2, 0, true, LocalPlayer, 0)
            VirtualInputManager:SendMouseButtonEvent(pos.X + size.X / 2, pos.Y + size.Y / 2, 0, false, LocalPlayer, 0)
        end,function (err)
        end)
    end
end

local function startAutoShake()
    if autoShakeConnection or not autoShakeEnabled then return end
    autoShakeConnection = RunService.RenderStepped:Connect(autoShake)
end

local function stopAutoShake()
    if autoShakeConnection then
        autoShakeConnection:Disconnect()
        autoShakeConnection = nil
    end
end

PlayerGui.DescendantAdded:Connect(function(descendant)
    if autoShakeEnabled and descendant.Name == "button" and descendant.Parent and descendant.Parent.Name == "safezone" then
        startAutoShake()
    end
end)

PlayerGui.DescendantAdded:Connect(function(descendant)
    if descendant.Name == "playerbar" and descendant.Parent and descendant.Parent.Name == "bar" then
        stopAutoShake()
    end
end)

if autoShakeEnabled and PlayerGui:FindFirstChild("shakeui") and PlayerGui.shakeui:FindFirstChild("safezone") and PlayerGui.shakeui.safezone:FindFirstChild("button") then
    startAutoShake()
end

-- // // // Auto Reel // // // --
local autoReelEnabled = false
local PerfectCatchEnabled = false
local autoReelConnection
local function autoReel()
    local reel = PlayerGui:FindFirstChild("reel")
    if not reel then return end
    local bar = reel:FindFirstChild("bar")
    local playerbar = bar and bar:FindFirstChild("playerbar")
    local fish = bar and bar:FindFirstChild("fish")
    if playerbar and fish then
        playerbar.Position = fish.Position
    end
end

local function noperfect()
    local reel = PlayerGui:FindFirstChild("reel")
    if not reel then return end
    local bar = reel:FindFirstChild("bar")
    local playerbar = bar and bar:FindFirstChild("playerbar")
    if playerbar then
        playerbar.Position = UDim2.new(0, 0, -35, 0)
        wait(0.2)
    end
end

local function startAutoReel()
    if ReelMode == "Legit" then
        if autoReelConnection or not autoReelEnabled then return end
        noperfect()
        task.wait(2)
        autoReelConnection = RunService.RenderStepped:Connect(autoReel)
    elseif ReelMode == "Blatant" then
        local reel = PlayerGui:FindFirstChild("reel")
        if not reel then return end
        local bar = reel:FindFirstChild("bar")
        local playerbar = bar and bar:FindFirstChild("playerbar")
        playerbar:GetPropertyChangedSignal('Position'):Wait()
        if failreelvalue then
            game.ReplicatedStorage:WaitForChild("events"):WaitForChild("reelfinished"):FireServer(50, false)
        else
            game.ReplicatedStorage:WaitForChild("events"):WaitForChild("reelfinished"):FireServer(100, false)
        end
        --game.ReplicatedStorage:WaitForChild("events"):WaitForChild("reelfinished"):FireServer(100, false)
    end
end

local function stopAutoReel()
    if autoReelConnection then
        autoReelConnection:Disconnect()
        autoReelConnection = nil
    end
end

PlayerGui.DescendantAdded:Connect(function(descendant)
    if autoReelEnabled and descendant.Name == "playerbar" and descendant.Parent and descendant.Parent.Name == "bar" then
        startAutoReel()
    end
end)

PlayerGui.DescendantRemoving:Connect(function(descendant)
    if descendant.Name == "playerbar" and descendant.Parent and descendant.Parent.Name == "bar" then
        stopAutoReel()
        if autoCastEnabled then
            task.wait(1)
            autoCast()
        end
    end
end)

if autoReelEnabled and PlayerGui:FindFirstChild("reel") and 
    PlayerGui.reel:FindFirstChild("bar") and 
    PlayerGui.reel.bar:FindFirstChild("playerbar") then
    startAutoReel()
end

-- // Find TpSpots // --
local TpSpotsFolder = Workspace:FindFirstChild("world"):WaitForChild("spawns"):WaitForChild("TpSpots")
for i, v in pairs(TpSpotsFolder:GetChildren()) do
    if table.find(teleportSpots, v.Name) == nil then
        table.insert(teleportSpots, v.Name)
    end
end

-- // // // Get Position // // // --
function GetPosition()
	if not game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		return {
			Vector3.new(0,0,0),
			Vector3.new(0,0,0),
			Vector3.new(0,0,0)
		}
	end
	return {
		game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position.X,
		game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position.Y,
		game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position.Z
	}
end

function ExportValue(arg1, arg2)
	return tonumber(string.format("%."..(arg2 or 1)..'f', arg1))
end

-- // // // Sell Item // // // --
function rememberPosition()
    spawn(function()
        local initialCFrame = HumanoidRootPart.CFrame
 
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Parent = HumanoidRootPart
 
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.D = 100
        bodyGyro.P = 10000
        bodyGyro.CFrame = initialCFrame
        bodyGyro.Parent = HumanoidRootPart
 
        while AutoFreeze do
            HumanoidRootPart.CFrame = initialCFrame
            task.wait(0.01)
        end
        if bodyVelocity then
            bodyVelocity:Destroy()
        end
        if bodyGyro then
            bodyGyro:Destroy()
        end
    end)
end
function SellHand()
    local currentPosition = HumanoidRootPart.CFrame
    local sellPosition = CFrame.new(464, 151, 232)
    local wasAutoFreezeActive = false
    if AutoFreeze then
        wasAutoFreezeActive = true
        AutoFreeze = false
    end
    HumanoidRootPart.CFrame = sellPosition
    task.wait(0.5)
    workspace:WaitForChild("world"):WaitForChild("npcs"):WaitForChild("Marc Merchant"):WaitForChild("merchant"):WaitForChild("sell"):InvokeServer()
    task.wait(1)
    HumanoidRootPart.CFrame = currentPosition
    if wasAutoFreezeActive then
        AutoFreeze = true
        rememberPosition()
    end
end
function SellAll()
    local currentPosition = HumanoidRootPart.CFrame
    local sellPosition = CFrame.new(464, 151, 232)
    local wasAutoFreezeActive = false
    if AutoFreeze then
        wasAutoFreezeActive = true
        AutoFreeze = false
    end
    HumanoidRootPart.CFrame = sellPosition
    task.wait(0.5)
    workspace:WaitForChild("world"):WaitForChild("npcs"):WaitForChild("Marc Merchant"):WaitForChild("merchant"):WaitForChild("sellall"):InvokeServer()
    task.wait(1)
    HumanoidRootPart.CFrame = currentPosition
    if wasAutoFreezeActive then
        AutoFreeze = true
        rememberPosition()
    end
end

-- // // // Noclip Stepped // // // --
NoclipConnection = RunService.Stepped:Connect(function()
    if Noclip == true then
        if LocalCharacter ~= nil then
            for i, v in pairs(LocalCharacter:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide == true then
                    v.CanCollide = false
                end
            end
        end
    end
end)

-- // // // Dupe // // // --
local DupeEnabled = false
local DupeConnection
local function autoDupe()
    local hud = LocalPlayer.PlayerGui:FindFirstChild("hud")
    if hud then
        local safezone = hud:FindFirstChild("safezone")
        if safezone then
            local bodyAnnouncements = safezone:FindFirstChild("bodyannouncements")
            if bodyAnnouncements then
                local offerFrame = bodyAnnouncements:FindFirstChild("offer")
                if offerFrame and offerFrame:FindFirstChild("confirm") then
                    firesignal(offerFrame.confirm.MouseButton1Click)
                end
            end
        end
    end
end

local function startAutoDupe()
    if DupeConnection or not DupeEnabled then return end
    DupeConnection = RunService.RenderStepped:Connect(autoDupe)
end

local function stopAutoDupe()
    if DupeConnection then
        DupeConnection:Disconnect()
        DupeConnection = nil
    end
end

PlayerGui.DescendantAdded:Connect(function(descendant)
    if DupeEnabled and descendant.Name == "confirm" and descendant.Parent and descendant.Parent.Name == "offer" then
        local hud = LocalPlayer.PlayerGui:FindFirstChild("hud")
        if hud then
            local safezone = hud:FindFirstChild("safezone")
            if safezone then
                local bodyAnnouncements = safezone:FindFirstChild("bodyannouncements")
                if bodyAnnouncements then
                    local offerFrame = bodyAnnouncements:FindFirstChild("offer")
                    if offerFrame and offerFrame:FindFirstChild("confirm") then
                        firesignal(offerFrame.confirm.MouseButton1Click)
                    end
                end
            end
        end
    end
end)


-- // // // ReduceGraphic // // // --
local function ReduceGraphic()
    local workspace = game.Workspace
    local lighting = game.Lighting
    local terrain = workspace.Terrain
    terrain.WaterWaveSize = 0
    terrain.WaterWaveSpeed = 0
    terrain.WaterReflectance = 0
    terrain.WaterTransparency = 0
    lighting.GlobalShadows = false
    lighting.FogEnd = 98989898
    lighting.Brightness = 0
    settings().Rendering.QualityLevel = "Level01"
    for i, v in pairs(game:GetDescendants()) do
        if (v:IsA("BasePart") or v:IsA("MeshPart")) then
            local Mesh = 0
            while true do
                if (Mesh == 1) then
                    v.CastShadow = false
                    break
                end
                if (Mesh == 0) then
                    v.Material = "SmoothPlastic"
                    v.Reflectance = 0
                    Mesh = 1
                end
            end
        elseif v:IsA("Decal") then
            v.Transparency = 1
        elseif (v:IsA("ParticleEmitter") or v:IsA("Trail")) then
            v.Lifetime = NumberRange.new(0)
        elseif v:IsA("Explosion") then
            local Explos = 0
            while true do
                if (Explos == (0)) then
                    v.BlastPressure = 1
                    v.BlastRadius = 1
                    break
                end
            end
        elseif (v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke")) then
            v.Enabled = false
        end
    end
    for i, v in pairs(lighting:GetChildren()) do
        if (v:IsA("PostEffect") or v:IsA("DepthOfFieldEffect")) then
            v.Enabled = false
        end
    end
end

-- // // // Trade // // // --
local PlayerList = {}
local function GetPlayersString()
	local PlayerList = Players:GetPlayers();
	for i = 1, #PlayerList do
		PlayerList[i] = PlayerList[i].Name;
	end;
	table.sort(PlayerList, function(str1, str2) return str1 < str2 end);
	return PlayerList;
end;
local allPlayerAround = GetPlayersString()

-- // // // Tabs Gui // // // --

local Tabs = { -- https://lucide.dev/icons/
    Home = Window:AddTab({ Title = "Home", Icon = "home" }),
    Exclusives = Window:AddTab({ Title = "Exclusives", Icon = "heart" }),
    Main = Window:AddTab({ Title = "Main", Icon = "list" }),
    Items = Window:AddTab({ Title = "Items", Icon = "box" }),
    Teleports = Window:AddTab({ Title = "Teleports", Icon = "map-pin" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "file-text" }),
    Trade = Window:AddTab({ Title = "Trade", Icon = "gift" }),
}

local Options = Fluent.Options

do
    Tabs.Home:AddButton({
        Title = "Copy Discord link",
        Description = "Join our main discord!",
        Callback = function()
            setclipboard("https://discord.gg/KyfvX2HB3v")
        end
    })

    -- // Exclusives Tab // --
    local sectionExclus = Tabs.Exclusives:AddSection("Exclusives Features")
    local EternalKingSpam = Tabs.Exclusives:AddToggle("EternalKingSpam", {Title = "Eternal King Spam", Default = false })
    EternalKingSpam:OnChanged(function()
        local RequireRodDepths = PlayerGui.hud.safezone.equipment.rods.scroll.safezone:FindFirstChild("Rod Of The Depths")
        local RequireRodEternal = PlayerGui.hud.safezone.equipment.rods.scroll.safezone:FindFirstChild("Rod Of The Eternal King")
        if not RequireRodDepths or not RequireRodEternal then return ShowNotification("Requirement Rod Of The Depths and Rod Of The Eternal King") end
        while Options.EternalKingSpam.Value do
            ReplicatedStorage.events.equiprod:FireServer("Rod Of The Depths")
            ReplicatedStorage.events.equiprod:FireServer("Rod Of The Eternal King")
            task.wait(0.03)
        end
    end)

    local WisdomSpam = Tabs.Exclusives:AddToggle("WisdomSpam", {Title = "Wisdom Spam", Default = false })
    WisdomSpam:OnChanged(function()
        local RequireRodDepths = PlayerGui.hud.safezone.equipment.rods.scroll.safezone:FindFirstChild("Rod Of The Depths")
        local RequireRodWisdom = PlayerGui.hud.safezone.equipment.rods.scroll.safezone:FindFirstChild("Wisdom Rod")
        if not RequireRodDepths or not RequireRodWisdom then return ShowNotification("Requirement Rod Of The Depths and Wisdom Rod") end
        while Options.WisdomSpam.Value do
            ReplicatedStorage.events.equiprod:FireServer("Rod Of The Depths")
            ReplicatedStorage.events.equiprod:FireServer("Wisdom Rod")
            task.wait(0.03)
        end
    end)

    -- // Main Tab // --
    local section = Tabs.Main:AddSection("Auto Fishing")
    local autoCast = Tabs.Main:AddToggle("autoCast", {Title = "Auto Cast", Default = false })
    autoCast:OnChanged(function()
        local RodName = ReplicatedStorage.playerstats[LocalPlayer.Name].Stats.rod.Value
        if Options.autoCast.Value == true then
            autoCastEnabled = true
            if LocalPlayer.Backpack:FindFirstChild(RodName) then
                LocalPlayer.Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild(RodName))
            end
            if LocalCharacter then
                local tool = LocalCharacter:FindFirstChildOfClass("Tool")
                if tool then
                    local hasBobber = tool:FindFirstChild("bobber")
                    if not hasBobber then
                        if CastMode == "Legit" then
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, LocalPlayer, 0)
                            HumanoidRootPart.ChildAdded:Connect(function()
                                if HumanoidRootPart:FindFirstChild("power") ~= nil and HumanoidRootPart.power.powerbar.bar ~= nil then
                                    HumanoidRootPart.power.powerbar.bar.Changed:Connect(function(property)
                                        if property == "Size" then
                                            if HumanoidRootPart.power.powerbar.bar.Size == UDim2.new(1, 0, 1, 0) then
                                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, LocalPlayer, 0)
                                            end
                                        end
                                    end)
                                end
                            end)
                        elseif CastMode == "Blatant" then
                            local rod = LocalCharacter and LocalCharacter:FindFirstChildOfClass("Tool")
                            if rod and rod:FindFirstChild("values") and string.find(rod.Name, "Rod") then
                                task.wait(0.5)
                                local Random = math.random(90, 99)
                                rod.events.cast:FireServer(Random)
                            end
                        end
                    end
                end
                task.wait(1)
            end
        else
            autoCastEnabled = false
        end
    end)
    local autoShake = Tabs.Main:AddToggle("autoShake", {Title = "Auto Shake", Default = false })
    autoShake:OnChanged(function()
        if Options.autoShake.Value == true then
            autoShakeEnabled = true
            startAutoShake()
        else
            autoShakeEnabled = false
            stopAutoShake()
        end
    end)
    local autoReel = Tabs.Main:AddToggle("autoReel", {Title = "Auto Reel", Default = false })
    autoReel:OnChanged(function()
        if Options.autoReel.Value == true then
            autoReelEnabled = true
            startAutoReel()
        else
            autoReelEnabled = false
            stopAutoReel()
        end
    end)
    local FreezeCharacter = Tabs.Main:AddToggle("FreezeCharacter", {Title = "Freeze Character", Default = false })
    FreezeCharacter:OnChanged(function()
        local oldpos = HumanoidRootPart.CFrame
        FreezeChar = Options.FreezeCharacter.Value
        task.wait()
        while WaitForSomeone(RenderStepped) do
            if FreezeChar and HumanoidRootPart ~= nil then
                task.wait()
                HumanoidRootPart.CFrame = oldpos
            else
                break
            end
        end
    end)

    local failreel = Tabs.Main:AddToggle("failreel", {Title = "Fail Reel (For Dupe Eternal King)", Default = false })
    failreel:OnChanged(function()
        if Options.failreel.Value == true then
            failreelvalue = true
		else
			failreelvalue = false
        end
    end)

    local perfectcatch = Tabs.Main:AddToggle("perfectcatch", {Title = "Perfect Catch (For Dupe Wisdom)", Default = false })
    perfectcatch:OnChanged(function()
        if Options.perfectcatch.Value == true then
            perfectcatchvalue = true
		else
			perfectcatchvalue = false
        end
    end)

    -- // Mode Tab // --
    local section = Tabs.Main:AddSection("Mode Fishing")
    local autoCastMode = Tabs.Main:AddDropdown("autoCastMode", {
        Title = "Auto Cast Mode",
        Values = {"Legit", "Blatant"},
        Multi = false,
        Default = CastMode,
    })
    autoCastMode:OnChanged(function(Value)
        CastMode = Value
    end)
    local autoShakeMode = Tabs.Main:AddDropdown("autoShakeMode", {
        Title = "Auto Shake Mode",
        Values = {"Navigation", "Mouse"},
        Multi = false,
        Default = ShakeMode,
    })
    autoShakeMode:OnChanged(function(Value)
        ShakeMode = Value
    end)
    local autoReelMode = Tabs.Main:AddDropdown("autoReelMode", {
        Title = "Auto Reel Mode",
        Values = {"Legit", "Blatant"},
        Multi = false,
        Default = ReelMode,
    })
    autoReelMode:OnChanged(function(Value)
        ReelMode = Value
    end)

    -- // Sell Tab // --
    local section = Tabs.Items:AddSection("Sell Items")
    Tabs.Items:AddButton({
        Title = "Sell Hand",
        Description = "",
        Callback = function()
            SellHand()
        end
    })
    Tabs.Items:AddButton({
        Title = "Sell All",
        Description = "",
        Callback = function()
            SellAll()
        end
    })

    local section = Tabs.Items:AddSection("Buy Items")
    local SelectedBuyItems = Tabs.Items:AddDropdown("SelectedBuyItems", {
        Title = "Item Selected",
        Values = {"Aurora Totem", "Sundial Totem", "Windset Totem", "Smokescreen Totem", "Tempest Totem", "Eclipse Totem", "Meteor Totem"},
        Multi = false,
        Default = nil,
    })
    SelectedBuyItems:OnChanged(function(Value)
        SelectedForBuy = Value
    end)
    local AmmountForBuy = Tabs.Items:AddInput("AmmountForBuy", {
        Title = "Item Ammount",
        Default = "1",
        Placeholder = "Ammount to purchase",
        Numeric = false,
        Finished = true,
        Callback = function(Value)
            Item_Ammount = Value
        end
    })
    Tabs.Items:AddButton({
        Title = "Purchase Item",
        Callback = function()
            ReplicatedStorage.events.purchase:FireServer(SelectedForBuy, 'Item', nil, Item_Ammount)
        end
    })

    -- // DupeTotem Tab // --
    local section = Tabs.Items:AddSection("Dupe Totem")
    local TotemDupe = Tabs.Items:AddDropdown("TotemDupe", {
        Title = "Use Totem not gone",
        Values = {"Aurora Totem", "Sundial Totem", "Windset Totem", "Smokescreen Totem", "Tempest Totem", "Eclipse Totem", "Meteor Totem"},
        Multi = false,
        Default = nil,
    })
    TotemDupe:OnChanged(function(Value)
        SelectedTotemDupe = Value
    end)
    Tabs.Items:AddButton({
        Title = "Use Totem",
        Description = "This still uses/consumes your totem but if you only have 1 you can infinitely use that 1 even if its gone from your inventory",
        Callback = function()
            for i, v in pairs(LocalPlayer.Backpack:GetChildren()) do 
                if v:FindFirstChild("rod/client") then
                    v.Parent = LocalPlayer.Character
                end
            end
            game.Players.LocalPlayer.Backpack:WaitForChild(SelectedTotemDupe).Parent = game.Players.LocalPlayer.Character
            game.Players.LocalPlayer.Character:WaitForChild(SelectedTotemDupe):Activate()
            task.wait(2)
            for i,v in pairs(LocalPlayer.Character:GetChildren()) do 
                if v:IsA("Tool") then
                    v.Parent = LocalPlayer.Backpack
                end
            end
        end
    })

    -- // Treasure Tab // --
    local section = Tabs.Items:AddSection("Treasure")
    Tabs.Items:AddButton({
        Title = "Teleport to Jack Marrow",
        Callback = function()
            HumanoidRootPart.CFrame = CFrame.new(-2824.359, 214.311, 1518.130)
        end
    })
    Tabs.Items:AddButton({
        Title = "Repair Map",
        Callback = function()
            for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do 
                if v.Name == "Treasure Map" then
                    game.Players.LocalPlayer.Character.Humanoid:EquipTool(v)
                    workspace.world.npcs["Jack Marrow"].treasure.repairmap:InvokeServer()
                end
            end
        end
    })
    Tabs.Items:AddButton({
        Title = "Collect Treasure",
        Callback = function()
            for i, v in pairs(workspace.world.chests:GetDescendants()) do
                if v:IsA("Part") and v:FindFirstChild("ChestSetup") then
                    for i,v in ipairs(game:GetService("Workspace"):GetDescendants()) do
                        if v.ClassName == "ProximityPrompt" then
                            v.HoldDuration = 0
                        end
                    end
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame
                    task.wait(1)
                    for _, v in pairs(workspace.world.chests:GetDescendants()) do
                        if v.Name == "ProximityPrompt" then
                            fireproximityprompt(v)
                        end
                    end
                    task.wait(1)
                end 
            end
        end
    })

    -- // Teleports Tab // --
    table.sort(teleportSpots)
    local section = Tabs.Teleports:AddSection("Select Teleport")
    local IslandTPDropdownUI = Tabs.Teleports:AddDropdown("IslandTPDropdownUI", {
        Title = "Area Teleport",
        Values = teleportSpots,
        Multi = false,
        Default = nil,
    })
    IslandTPDropdownUI:OnChanged(function(Value)
        if teleportSpots ~= nil and HumanoidRootPart ~= nil then
            xpcall(function()
                HumanoidRootPart.CFrame = TpSpotsFolder:FindFirstChild(Value).CFrame + Vector3.new(0, 5, 0)
                IslandTPDropdownUI:SetValue(nil)
            end,function (err)
            end)
        end
    end)

    -- // WorldEvent Tab // --
    local WorldEventTPDropdownUI = Tabs.Teleports:AddDropdown("WorldEventTPDropdownUI", {
        Title = "Select World Event",
        Values = {"Strange Whirlpool", "Great Hammerhead Shark", "Great White Shark", "Whale Shark", "The Depths - Serpent", "Megalodon"},
        Multi = false,
        Default = nil,
    })
    WorldEventTPDropdownUI:OnChanged(function(Value)
        SelectedWorldEvent = Value
        if SelectedWorldEvent == "Strange Whirlpool" then
            local offset = Vector3.new(25, 135, 25)
            local WorldEvent = game.Workspace.zones.fishing:FindFirstChild("Isonade")
            if not WorldEvent then WorldEventTPDropdownUI:SetValue(nil) return ShowNotification("Not found Strange Whirlpool") end
            HumanoidRootPart.CFrame = CFrame.new(game.Workspace.zones.fishing.Isonade.Position + offset)                           -- Strange Whirlpool
            WorldEventTPDropdownUI:SetValue(nil)
        elseif SelectedWorldEvent == "Great Hammerhead Shark" then
            local offset = Vector3.new(0, 135, 0)
            local WorldEvent = game.Workspace.zones.fishing:FindFirstChild("Great Hammerhead Shark")
            if not WorldEvent then WorldEventTPDropdownUI:SetValue(nil) return ShowNotification("Not found Great Hammerhead Shark") end
            HumanoidRootPart.CFrame = CFrame.new(game.Workspace.zones.fishing["Great Hammerhead Shark"].Position + offset)         -- Great Hammerhead Shark
            WorldEventTPDropdownUI:SetValue(nil)
        elseif SelectedWorldEvent == "Great White Shark" then
            local offset = Vector3.new(0, 135, 0)
            local WorldEvent = game.Workspace.zones.fishing:FindFirstChild("Great White Shark")
            if not WorldEvent then WorldEventTPDropdownUI:SetValue(nil) return ShowNotification("Not found Great White Shark") end
            HumanoidRootPart.CFrame = CFrame.new(game.Workspace.zones.fishing["Great White Shark"].Position + offset)               -- Great White Shark
            WorldEventTPDropdownUI:SetValue(nil)
        elseif SelectedWorldEvent == "Whale Shark" then
            local offset = Vector3.new(0, 135, 0)
            local WorldEvent = game.Workspace.zones.fishing:FindFirstChild("Whale Shark")
            if not WorldEvent then WorldEventTPDropdownUI:SetValue(nil) return ShowNotification("Not found Whale Shark") end
            HumanoidRootPart.CFrame = CFrame.new(game.Workspace.zones.fishing["Whale Shark"].Position + offset)                     -- Whale Shark
            WorldEventTPDropdownUI:SetValue(nil)
        elseif SelectedWorldEvent == "The Depths - Serpent" then
            local offset = Vector3.new(0, 50, 0)
            local WorldEvent = game.Workspace.zones.fishing:FindFirstChild("The Depths - Serpent")
            if not WorldEvent then WorldEventTPDropdownUI:SetValue(nil) return ShowNotification("Not found The Depths - Serpent") end
            HumanoidRootPart.CFrame = CFrame.new(game.Workspace.zones.fishing["The Depths - Serpent"].Position + offset)            -- The Depths - Serpent
            WorldEventTPDropdownUI:SetValue(nil)
        elseif SelectedWorldEvent == "Megalodon" then
            local offset = Vector3.new(0, 50, 0)
            local WorldEvent = game.Workspace.zones.fishing:FindFirstChild("Megalodon Default")
            if not WorldEvent then WorldEventTPDropdownUI:SetValue(nil) return ShowNotification("Not found The Megalodon") end
            HumanoidRootPart.CFrame = CFrame.new(game.Workspace.zones.fishing["Megalodon Default"].Position + offset)            -- The Depths - Serpent
            WorldEventTPDropdownUI:SetValue(nil)
        end
    end)

    -- // Fragment Tab // --
    local FragmentTP = Tabs.Teleports:AddDropdown("FragmentTP", {
        Title = "Fragment Teleport",
        Values = {"Ancient Fragment", "DeepSea Fragment", "Earth Fragment", "Solar Fragment"},
        Multi = false,
        Default = nil,
    })
    FragmentTP:OnChanged(function(Value)
        SelectedFragment = Value
        if SelectedFragment == "Ancient Fragment" then
            HumanoidRootPart.CFrame = CFrame.new(5798.764, 135.301, 403.875)
            FragmentTP:SetValue(nil)
        elseif SelectedFragment == "DeepSea Fragment" then
            HumanoidRootPart.CFrame = CFrame.new(5842.705, 77.997, 383.161)
            FragmentTP:SetValue(nil)
        elseif SelectedFragment == "Earth Fragment" then
            HumanoidRootPart.CFrame = CFrame.new(5972.025, 274.108, 846.023)
            FragmentTP:SetValue(nil)
        elseif SelectedFragment == "Solar Fragment" then
            HumanoidRootPart.CFrame = CFrame.new(6072.742, 443.945, 683.729)
            FragmentTP:SetValue(nil)
        end
    end)

    Tabs.Teleports:AddButton({
        Title = "Teleport to Traveler Merchant",
        Description = "Teleports to the Traveler Merchant.",
        Callback = function()
            local Merchant = game.Workspace.active:FindFirstChild("Merchant Boat")
            if not Merchant then return ShowNotification("Not found Merchant") end
            HumanoidRootPart.CFrame = CFrame.new(game.Workspace.active["Merchant Boat"].Boat["Merchant Boat"].r.HandlesR.Position)
        end
    })

    -- // Character Tab // --
    local section = Tabs.Misc:AddSection("Character")
    local WalkOnWater = Tabs.Misc:AddToggle("WalkOnWater", {Title = "Walk On Water", Default = false })
    WalkOnWater:OnChanged(function()
        for i,v in pairs(workspace.zones.fishing:GetChildren()) do
			if v.Name == WalkZone then
				v.CanCollide = Options.WalkOnWater.Value
                if v.Name == "Ocean" then
                    for i,v in pairs(workspace.zones.fishing:GetChildren()) do
                        if v.Name == "Deep Ocean" then
                            v.CanCollide = Options.WalkOnWater.Value
                        end
                    end
                end
			end
		end
    end)
    local WalkOnWaterZone = Tabs.Misc:AddDropdown("WalkOnWaterZone", {
        Title = "Walk On Water Zone",
        Values = {"Ocean", "Desolate Deep", "The Depths"},
        Multi = false,
        Default = "Ocean",
    })
    WalkOnWaterZone:OnChanged(function(Value)
        WalkZone = Value
    end)
    local WalkSpeedSliderUI = Tabs.Misc:AddSlider("WalkSpeedSliderUI", {
        Title = "Walk Speed",
        Min = 16,
        Max = 200,
        Default = 16,
        Rounding = 1,
    })
    WalkSpeedSliderUI:OnChanged(function(value)
        LocalPlayer.Character.Humanoid.WalkSpeed = value
    end)
    local JumpHeightSliderUI = Tabs.Misc:AddSlider("JumpHeightSliderUI", {
        Title = "Jump Height",
        Min = 50,
        Max = 200,
        Default = 50,
        Rounding = 1,
    })
    JumpHeightSliderUI:OnChanged(function(value)
        LocalPlayer.Character.Humanoid.JumpPower = value
    end)

    local InfJump = Tabs.Misc:AddToggle("InfJump", {Title = "Inf. Jump", Default = false })
    InfJump:OnChanged(function()
        if Options.InfJump.Value == true then
            Mouse.KeyDown:connect(function(key)
                if Options.InfJump.Value then
                    if key:byte() == 32 then
                        humanoid = game:GetService'Players'.LocalPlayer.Character:FindFirstChildOfClass('Humanoid')
                        humanoid:ChangeState('Jumping')
                        wait()
                        humanoid:ChangeState('Seated')
                    end
                end
            end)
        else
            
        end
    end)

    local DisableSwimming = Tabs.Misc:AddToggle("DisableSwimming", {Title = "No Swimming", Default = false })
    DisableSwimming:OnChanged(function()
        if Options.DisableSwimming.Value == true then
            game.Players.LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
        else
            game.Players.LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
        end
    end)

    local ToggleNoclip = Tabs.Misc:AddToggle("ToggleNoclip", {Title = "Noclip", Default = false })
    ToggleNoclip:OnChanged(function()
        Noclip = Options.ToggleNoclip.Value
    end)

    -- // Misc Tab // --
    local section = Tabs.Misc:AddSection("Misc")
    local FastClick = Tabs.Misc:AddToggle("FastClick", {Title = "Fast Click", Default = false })
    FastClick:OnChanged(function()
        while Options.FastClick.Value == true do
            task.wait(FastClickDelay)
            game:GetService'VirtualUser':Button1Down(Vector2.new(99,99))
            game:GetService'VirtualUser':Button1Up(Vector2.new(99,99))
        end
    end)
    local FastClick_Delay = Tabs.Misc:AddSlider("FastClick_Delay", {
        Title = "Fast Click Delay",
        Description = "",
        Default = 0.1,
        Min = 0,
        Max = 1,
        Rounding = 1,
        Callback = function(Value)
            FastClickDelay = Value
        end
    })
    local BypassRadar = Tabs.Misc:AddToggle("BypassRadar", {Title = "Bypass Fish Radar", Default = false })
    BypassRadar:OnChanged(function()
        for _, v in pairs(game:GetService("CollectionService"):GetTagged("radarTag")) do
			if v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
				v.Enabled = Options.BypassRadar.Value
			end
		end
    end)
    local BypassGPS = Tabs.Misc:AddToggle("BypassGPS", {Title = "Bypass GPS", Default = false })
    BypassGPS:OnChanged(function()
        if Options.BypassGPS.Value == true then
            local XyzClone = game:GetService("ReplicatedStorage").resources.items.items.GPS.GPS.gpsMain.xyz:Clone()
			XyzClone.Parent = game.Players.LocalPlayer.PlayerGui:WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("backpack")
			local Pos = GetPosition()
			local StringInput = string.format("%s, %s, %s", ExportValue(Pos[1]), ExportValue(Pos[2]), ExportValue(Pos[3]))
			XyzClone.Text = "<font color='#ff4949'>X</font><font color = '#a3ff81'>Y</font><font color = '#626aff'>Z</font>: "..StringInput
			BypassGpsLoop = game:GetService("RunService").Heartbeat:Connect(function()
				local Pos = GetPosition()
				StringInput = string.format("%s, %s, %s", ExportValue(Pos[1]), ExportValue(Pos[2]), ExportValue(Pos[3]))
				XyzClone.Text = "<font color='#ff4949'>X</font><font color = '#a3ff81'>Y</font><font color = '#626aff'>Z</font> : "..StringInput
			end)
		else
			if PlayerGui.hud.safezone.backpack:FindFirstChild("xyz") then
				PlayerGui.hud.safezone.backpack:FindFirstChild("xyz"):Destroy()
			end
			if BypassGpsLoop then
				BypassGpsLoop:Disconnect()
				BypassGpsLoop = nil
			end
        end
    end)
    local RemoveFog = Tabs.Misc:AddToggle("RemoveFog", {Title = "Remove Fog", Default = false })
    RemoveFog:OnChanged(function()
        if Options.RemoveFog.Value == true then
            if game:GetService("Lighting"):FindFirstChild("Sky") then
                game:GetService("Lighting"):FindFirstChild("Sky").Parent = game:GetService("Lighting").bloom
            end
        else
            if game:GetService("Lighting").bloom:FindFirstChild("Sky") then
                game:GetService("Lighting").bloom:FindFirstChild("Sky").Parent = game:GetService("Lighting")
            end
        end
    end)
    local DayOnly = Tabs.Misc:AddToggle("DayOnly", {Title = "Day Only", Default = false })
    DayOnly:OnChanged(function()
        if Options.DayOnly.Value == true then
            DayOnlyLoop = RunService.Heartbeat:Connect(function()
				game:GetService("Lighting").TimeOfDay = "12:00:00"
			end)
		else
			if DayOnlyLoop then
				DayOnlyLoop:Disconnect()
				DayOnlyLoop = nil
			end
        end
    end)

    local InfZoom = Tabs.Misc:AddToggle("InfZoom", {Title = "Inf. Zoom", Default = false })
    InfZoom:OnChanged(function()
        if Options.InfZoom.Value == true then
            LocalPlayer.CameraMaxZoomDistance = 100000
		else
			LocalPlayer.CameraMaxZoomDistance = 36
        end
    end)

    Tabs.Misc:AddButton({
        Title = "Reduce Graphic",
        Description = "Improves FPS by applying optimizations.",
        Callback = function()
            ReduceGraphic()
        end
    })
    Tabs.Misc:AddButton({
        Title = "Less Lag",
        Description = "Improves FPS Cr.AlluxHub",
        Callback = function()
            loadstring(game:HttpGet("https://pastebin.com/raw/v5cvqQ7r"))()
        end
    })
    local HoldDuration = Tabs.Misc:AddToggle("HoldDuration", {Title = "Hold Duration 0 sec", Default = false })
    HoldDuration:OnChanged(function()
        if Options.HoldDuration.Value == true then
            for i,v in ipairs(game:GetService("Workspace"):GetDescendants()) do
                if v.ClassName == "ProximityPrompt" then
                    v.HoldDuration = 0
                end
            end
        end
    end)

    local JustUI = Tabs.Misc:AddToggle("JustUI", {Title = "Disable UI", Default = false })
    JustUI:OnChanged(function()
        local UI = JustUI.Value
        if UI then
            PlayerGui.hud.safezone.Visible = false
        else
            PlayerGui.hud.safezone.Visible = true
        end
    end)

    local IdentityHiderUI = Tabs.Misc:AddToggle("IdentityHiderUI", {Title = "Protect Identity", Default = false })    
    IdentityHiderUI:OnChanged(function()
        while Options.IdentityHiderUI.Value == true do
            if UserPlayer:FindFirstChild("streak") then UserPlayer.streak.Text = "HIDDEN" end
            if UserPlayer:FindFirstChild("level") then UserPlayer.level.Text = "Level: HIDDEN" end
            if UserPlayer:FindFirstChild("level") then UserPlayer.user.Text = "HIDDEN" end
            local hud = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("hud"):WaitForChild("safezone")
            if hud:FindFirstChild("coins") then hud.coins.Text = "HIDDEN$" end
            if hud:FindFirstChild("lvl") then hud.lvl.Text = "HIDDEN LVL" end
            task.wait(0.01)
        end
    end)

    local DisableOxygen = Tabs.Misc:AddToggle("DisableOxygen", {Title = "Disable Oxygen", Default = true })
    DisableOxygen:OnChanged(function()
        LocalPlayer.Character.client.oxygen.Disabled = Options.DisableOxygen.Value
    end)

    Tabs.Misc:AddButton({
        Title = "Copy XYZ",
        Description = "Copy Clipboard",
        Callback = function()
            local XYZ = tostring(game.Players.LocalPlayer.Character.HumanoidRootPart.Position)
            setclipboard("game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(" .. XYZ .. ")")
        end
    })

    -- // Load Tab // --
    local section = Tabs.Misc:AddSection("Load Scripts")
    Tabs.Misc:AddButton({
        Title = "Load Infinite-Yield FE",
        Callback = function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
        end
    })
    Tabs.Misc:AddButton({
        Title = "Load RemoteSpy",
        Callback = function()
            loadstring(game:HttpGetAsync("https://github.com/richie0866/remote-spy/releases/latest/download/RemoteSpy.lua"))()
        end
    })

    local section = Tabs.Trade:AddSection("Trading")
    local SelectPlayer = Tabs.Trade:AddDropdown("SelectPlayer", {
        Title = "Select Player",
        Values = allPlayerAround,
        Multi = false,
        Default = nil,
    })
    SelectPlayer:OnChanged(function(Value)
        SelectedPlayer = Value
    end)
    Tabs.Trade:AddButton({
        Title = "Refresh Player List",
        Callback = function()
            GetPlayersString()
            SelectPlayer:SetValues(allPlayerAround)
        end
    })

    Tabs.Trade:AddButton({
        Title = "Trade Equipped Items",
        Callback = function()
            local target_player = game.Players:FindFirstChild(SelectedPlayer)
            if target_player then
                local equipped_tool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
                if equipped_tool and equipped_tool:FindFirstChild("offer") then
                    equipped_tool.offer:FireServer(target_player)
                end
            end
        end
    })

    Tabs.Trade:AddButton({
        Title = "Trade All Items",
        Callback = function()
            for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if item:IsA("Tool") then
                    if item:IsA("Tool") then
                        item.Parent = LocalPlayer.Character
    
                        local offer_event = item:FindFirstChild("offer")
                        if offer_event then
                            local args = {
                                [1] = SelectedPlayer
                            }
                            pcall(function()
                                offer_event:FireServer(unpack(args)) 
                            end)
                        end
                        item.Parent = LocalPlayer.Backpack
                    end
                end
            end
        end
    })

    local AutoTrade = Tabs.Trade:AddToggle("AutoTrade", {Title = "Auto Trade All Items", Default = false })    
    AutoTrade:OnChanged(function()
        while Options.AutoTrade.Value == true do
            for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if item:IsA("Tool") then
                    item.Parent = LocalPlayer.Character
                    local offer_event = item:FindFirstChild("offer")
                    if offer_event then
                        local args = {
                            [1] = SelectedPlayer
                        }
                        pcall(function()
                            offer_event:FireServer(unpack(args)) 
                        end)
                    end
                    item.Parent = LocalPlayer.Backpack
                end
            end
            task.wait()
        end
    end)

    local AutoAcceptTrade = Tabs.Trade:AddToggle("AutoAcceptTrade", {Title = "Auto Accept Trade", Default = false })    
    AutoAcceptTrade:OnChanged(function()
        while Options.AutoAcceptTrade.Value == true do
            local hud = LocalPlayer.PlayerGui:FindFirstChild("hud")
            if hud then
                local safezone = hud:FindFirstChild("safezone")
                if safezone then
                    local bodyAnnouncements = safezone:FindFirstChild("bodyannouncements")
                    if bodyAnnouncements then
                        local offerFrame = bodyAnnouncements:FindFirstChild("offer")
                        if offerFrame and offerFrame:FindFirstChild("confirm") then
                            firesignal(offerFrame.confirm.MouseButton1Click)
                        end
                    end
                end
            end
            task.wait()
        end
    end)
end

Window:SelectTab(1)
Fluent:Notify({
    Title = "CupPink",
    Content = "Executed!",
    Duration = 8
})
