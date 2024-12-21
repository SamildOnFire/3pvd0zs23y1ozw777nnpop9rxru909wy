if getgenv().cuppink then warn("CupPibk Hub : Already executed!") return end
getgenv().cuppink = true

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/SamildOnFire/scripts/main/FluentUI.lua"))()


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

local function playMusic()
    local Music = Instance.new("Sound")
    Music.SoundId = "rbxassetid://1839285890"
    Music.Volume = 0.5
    Music.Looped = false
    Music.PlayOnRemove = false
    Music.Parent = workspace
    Music:Play()
    Music.Ended:Connect(function()
        Music:Destroy()
    end)
end
playMusic()

local Window = Fluent:CreateWindow({
    Title = game:GetService("MarketplaceService"):GetProductInfo(16732694052).Name .." | CupPink - Premium",
    SubTitle = " v.0.1.0",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "DarkerPink",
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
local FindBaits = {}
local FreezeChar = false
local DayOnlyLoop = nil
local BypassGpsLoop = nil
local Noclip = false
local RunCount = false
local SelectedTotemDupe = nil
local Target
local ZoneCastValue = false
local fishtable = {}
local cons = {}

local Ancient = workspace.active["OceanPOI's"]["Ancient Isle"].POIHeader:Clone()
local Forsaken = workspace.active["OceanPOI's"]["Forsaken Shores"].POIHeader:Clone()
local Moosewood = workspace.active["OceanPOI's"].Moosewood.POIHeader:Clone()
local Mushgrove = workspace.active["OceanPOI's"].Mushgrove.POIHeader:Clone()
local Roslit = workspace.active["OceanPOI's"]["Roslit Bay"].POIHeader:Clone()
local Snowcap = workspace.active["OceanPOI's"]["Snowcap Island"].POIHeader:Clone()
local Statue = workspace.active["OceanPOI's"]["Statue Of Sovereignty"].POIHeader:Clone()
local Sunstone = workspace.active["OceanPOI's"]["Sunstone Island"].POIHeader:Clone()
local Terrapin = workspace.active["OceanPOI's"]["Terrapin Island"].POIHeader:Clone()

Ancient.Parent = workspace.active["OceanPOI's"]["Ancient Isle"]
Forsaken.Parent = workspace.active["OceanPOI's"]["Forsaken Shores"]
Moosewood.Parent = workspace.active["OceanPOI's"].Moosewood
Mushgrove.Parent = workspace.active["OceanPOI's"].Mushgrove
Roslit.Parent = workspace.active["OceanPOI's"]["Roslit Bay"]
Snowcap.Parent = workspace.active["OceanPOI's"]["Snowcap Island"]
Statue.Parent = workspace.active["OceanPOI's"]["Statue Of Sovereignty"]
Sunstone.Parent = workspace.active["OceanPOI's"]["Sunstone Island"]
Terrapin.Parent = workspace.active["OceanPOI's"]["Terrapin Island"]

Ancient.Name = "IslandName"
Forsaken.Name = "IslandName"
Moosewood.Name = "IslandName"
Mushgrove.Name = "IslandName"
Roslit.Name = "IslandName"
Snowcap.Name = "IslandName"
Statue.Name = "IslandName"
Sunstone.Name = "IslandName"
Terrapin.Name = "IslandName"

getgenv().config = {
    auto_cast = nil,
    auto_shake = nil,
    auto_reel = nil,
    reel_mode = "Normal",
    auto_nuke = nil,
}

-- // // // Functions // // // --
function ShowNotification(String)
    Fluent:Notify({
        Title = "CupPink Hub",
        Content = String,
        Duration = 5,
        Icon = "rbxassetid://119937569996752"
    })
end

game.Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

--[[
local Ant1AFKConnection
local function autoAnt1AFK()
    game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("afk"):FireServer(false)
end
Ant1AFKConnection = RunService.RenderStepped:Connect(autoAnt1AFK)
]]

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
            button.Selectable = true
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
        if getgenv().config.reel_mode == "Normal" then
            game.ReplicatedStorage:WaitForChild("events"):WaitForChild("reelfinished"):FireServer(100, false)
        elseif getgenv().config.reel_mode == "Perfect" then
            game.ReplicatedStorage:WaitForChild("events"):WaitForChild("reelfinished"):FireServer(100, true)
        elseif getgenv().config.reel_mode == "Fail" then
            game.ReplicatedStorage:WaitForChild("events"):WaitForChild("reelfinished"):FireServer(0)
        end
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

-- // Find Bait // --
local function RefreshBaits()
    FindBaits = {}
    local BaitFolder = PlayerGui:FindFirstChild("hud"):WaitForChild("safezone"):WaitForChild("equipment"):WaitForChild("bait"):WaitForChild("scroll"):WaitForChild("safezone")
    for i, v in pairs(BaitFolder:GetChildren()) do
        if v.ClassName == "Frame" then
            if table.find(FindBaits, v.Name) == nil then
                table.insert(FindBaits, v.Name)
            end
        end
    end
end
RefreshBaits()

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
    Exclusives = Window:AddTab({ Title = "Exclusives", Icon = "heart" }),
    Main = Window:AddTab({ Title = "Main", Icon = "list" }),
    FishSet = Window:AddTab({ Title = "Fishing Setting", Icon = "settings-2" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Items = Window:AddTab({ Title = "Items", Icon = "box" }),
    Teleports = Window:AddTab({ Title = "Teleports", Icon = "map-pin" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "file-text" }),
    Trade = Window:AddTab({ Title = "Trade", Icon = "gift" }),
}

local Options = Fluent.Options

do
    -- // Exclusives Tab // --
    local section = Tabs.Exclusives:AddSection("Exclusives Featues")

    -- // Main Tab // --
    local section = Tabs.Main:AddSection("Auto Fishing")
    local autoCast = Tabs.Main:AddToggle("autoCast", {Title = "Auto Cast", Default = false })
    autoCast:OnChanged(function(Value)
        getgenv().config.auto_cast = Value
        spawn(function()
            while getgenv().config.auto_cast do task.wait()
                local RodName = ReplicatedStorage.playerstats[LocalPlayer.Name].Stats.rod.Value
                local EquipRod = LocalPlayer.Character:FindFirstChild(RodName)
                local Backpack = LocalPlayer:WaitForChild("Backpack")
                if Backpack:FindFirstChild(RodName) and not EquipRod then task.wait(0.2)
                    LocalPlayer.Character.Humanoid:EquipTool(Backpack:FindFirstChild(RodName))
                end
                task.wait(0.1)
                if EquipRod then
                    if CastMode == "Legit" then
                        local hasBobber = EquipRod:FindFirstChild("bobber")
                        if not hasBobber then
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
                        end
                    elseif CastMode == "Blatant" then
                        local Random = math.random(90, 100)
                        EquipRod.events.cast:FireServer(Random)
                    end
                end
            end
        end)
    end)


    local autoShake = Tabs.Main:AddToggle("autoShake", {Title = "Auto Shake", Default = false })
    autoShake:OnChanged(function(Value)
        getgenv().config.auto_shake = Value
        if getgenv().config.auto_shake == true then
            autoShakeEnabled = true
            startAutoShake()
        else
            autoShakeEnabled = false
            stopAutoShake()
        end
    end)
    local autoReel = Tabs.Main:AddToggle("autoReel", {Title = "Auto Reel", Default = false })
    autoReel:OnChanged(function(Value)
        getgenv().config.auto_reel = Value
        if getgenv().config.auto_reel == true then
            autoReelEnabled = true
            startAutoReel()
        else
            autoReelEnabled = false
            stopAutoReel()
        end
    end)

    local AutoNuke = Tabs.Main:AddToggle("AutoNuke", {Title = "Auto Nuke MiniGame", Default = true })
    AutoNuke:OnChanged(function(Value)
        task.spawn(function()
            getgenv().config.auto_nuke = AutoNuke.Value
            local Player = game:GetService("Players").LocalPlayer
            local NukeMinigame = Player.PlayerGui:FindFirstChild("NukeMinigame")
            local catch = true -- Start with catch enabled
        
            local function pressButton(button)
                if button and button:IsA("GuiButton") then
                    local X = button.AbsolutePosition.X
                    local Y = button.AbsolutePosition.Y
                    local XS = button.AbsoluteSize.X
                    local YS = button.AbsoluteSize.Y
        
                    game:GetService("VirtualInputManager"):SendMouseButtonEvent(X + XS / 2, Y + YS / 2, 0, true, button, 1)
                    game:GetService("VirtualInputManager"):SendMouseButtonEvent(X + XS / 2, Y + YS / 2, 0, false, button, 1)
                end
            end
        
            while AutoNuke.Value do
                task.wait(0.1)
        
                if NukeMinigame and NukeMinigame.Enabled then
                    catch = false
        
                    local Pointer = NukeMinigame:FindFirstChild("Center") and NukeMinigame.Center.Marker.Pointer
                    local LeftButton = NukeMinigame.Center:FindFirstChild("Left")
                    local RightButton = NukeMinigame.Center:FindFirstChild("Right")
        
                    if Pointer and Pointer:IsA("GuiObject") then
                        local rotation = Pointer.Rotation
        
                        if rotation > 35 then
                            pressButton(LeftButton)
                        elseif rotation < -35 then
                            pressButton(RightButton)
                        end
                    end
                else
                    if not catch then
                        task.wait(2)
                        catch = true
                        local RodName = ReplicatedStorage.playerstats[LocalPlayer.Name].Stats.rod.Value
                        if RodName and Player.Character:FindFirstChild(RodName) then
                            local resetEvent = Player.Character[RodName].events:FindFirstChild("reset")
                            if resetEvent then
                                resetEvent:FireServer()
                            end
                        end
                    end
                end
            end
        end) 
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

    -- // Mode Tab // --
    local section = Tabs.FishSet:AddSection("Mode Fishing")
    local autoCastMode = Tabs.FishSet:AddDropdown("autoCastMode", {
        Title = "Auto Cast Mode",
        Values = {"Legit", "Blatant"},
        Multi = false,
        Default = CastMode,
    })
    autoCastMode:OnChanged(function(Value)
        CastMode = Value
    end)
    local autoShakeMode = Tabs.FishSet:AddDropdown("autoShakeMode", {
        Title = "Auto Shake Mode",
        Values = {"Navigation", "Mouse"},
        Multi = false,
        Default = ShakeMode,
    })
    autoShakeMode:OnChanged(function(Value)
        ShakeMode = Value
    end)
    local autoReelMode = Tabs.FishSet:AddDropdown("autoReelMode", {
        Title = "Auto Reel Mode",
        Values = {"Legit", "Blatant"},
        Multi = false,
        Default = ReelMode,
    })
    autoReelMode:OnChanged(function(Value)
        ReelMode = Value
    end)
    local ReelMode = Tabs.FishSet:AddDropdown("ReelMode", {
        Title = "Reel Mode",
        Values = {"Normal", "Perfect", "Fail"},
        Multi = false,
        Default = getgenv().config.reel_mode,
    })
    ReelMode:OnChanged(function(Value)
        getgenv().config.reel_mode = Value
    end)

    local section = Tabs.Visuals:AddSection("Visual Game")
    local BypassRadar = Tabs.Visuals:AddToggle("BypassRadar", {Title = "Bypass Fish Radar", Default = false })
    BypassRadar:OnChanged(function()
        for _, v in pairs(game:GetService("CollectionService"):GetTagged("radarTag")) do
			if v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
				v.Enabled = Options.BypassRadar.Value
			end
		end
        for i,v in ipairs(game:GetService("Workspace"):GetDescendants()) do
            if v.Name == "radar1" then
                if Options.BypassRadar.Value == true then
                    v.MaxDistance = math.huge
                else
                    v.MaxDistance = 250
                end
            end
        end
    end)
    local BypassGPS = Tabs.Visuals:AddToggle("BypassGPS", {Title = "Bypass GPS", Default = false })
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
    local RemoveFog = Tabs.Visuals:AddToggle("RemoveFog", {Title = "Remove Fog", Default = false })
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
    local DayOnly = Tabs.Visuals:AddToggle("DayOnly", {Title = "Day Only", Default = false })
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

    local InfZoom = Tabs.Visuals:AddToggle("InfZoom", {Title = "Inf. Zoom", Default = false })
    InfZoom:OnChanged(function()
        if Options.InfZoom.Value == true then
            LocalPlayer.CameraMaxZoomDistance = 100000
		else
			LocalPlayer.CameraMaxZoomDistance = 36
        end
    end)

    Tabs.Visuals:AddButton({
        Title = "Reduce Graphic",
        Description = "Improves FPS by applying optimizations.",
        Callback = function()
            ReduceGraphic()
        end
    })

    local section = Tabs.Visuals:AddSection("Lure Visual")
    local LureBobber = Tabs.Visuals:AddToggle("LureBobber", {Title = "Lure Bobber", Default = false })    
    LureBobber:OnChanged(function()
        while Options.LureBobber.Value == true do
            local RodName = ReplicatedStorage.playerstats[LocalPlayer.Name].Stats.rod.Value
            if LocalPlayer.Character:FindFirstChild(RodName) and LocalPlayer.Character:FindFirstChild(RodName):FindFirstChild("bobber") then
                for i,v in pairs(LocalPlayer.Character:FindFirstChild(RodName):GetChildren()) do
                    if v.Name == "bobber" then
                        if not v:FindFirstChild("LureESP") then
                            local BillboardGui = Instance.new("BillboardGui", lure)
                            BillboardGui.Parent = v
                            BillboardGui.Name = "LureESP"
                            BillboardGui.AlwaysOnTop = true
                            BillboardGui.Size = UDim2.new(12, 0, 2, 0)
                            BillboardGui.ExtentsOffset = Vector3.new(0, 0, 0)
                            BillboardGui.StudsOffset = Vector3.new(0, 2.25, 0)
                            local TextLabel = Instance.new('TextLabel')
                            TextLabel.Parent = BillboardGui
                            TextLabel.TextSize = 20
                            TextLabel.Font = 2
                            TextLabel.BackgroundTransparency = 1
                            TextLabel.Size = UDim2.new(1,0,1,0)
                            TextLabel.TextColor3 = Color3.fromRGB(255, 100, 245)
                            local lurerender
                            lurerender = RunService.RenderStepped:Connect(function()
                                if LocalPlayer.Character:FindFirstChild(RodName):FindFirstChild("bobber") and not LocalPlayer.Character:FindFirstChild(RodName).values.bite.Value then
                                    TextLabel.Text = "Lure ".. math.ceil(LocalPlayer.Character:FindFirstChild(RodName).values.lure.Value).. " %"
                                else
                                    TextLabel.Text = "FISHING!"
                                    lurerender:Disconnect()
                                end
                            end)
                        end
                    end
                end
            end
            task.wait()
        end
    end)

    local section = Tabs.Visuals:AddSection("Island Visual")
    local IslandVisual = Tabs.Visuals:AddToggle("IslandVisual", {Title = "Show Island Name", Default = false })    
    IslandVisual:OnChanged(function()
        if Options.IslandVisual.Value == true then
            for i,v in ipairs(workspace.active["OceanPOI's"]:GetDescendants()) do
                if v.Name == "IslandName" then
                    v.Enabled = true
                end
            end
        else
            for i,v in ipairs(workspace.active["OceanPOI's"]:GetDescendants()) do
                if v.Name == "IslandName" then
                    v.Enabled = false
                end
            end
        end
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

    local section = Tabs.Items:AddSection("Buy Totem")
    local SelectedBuyItems = Tabs.Items:AddDropdown("SelectedBuyItems", {
        Title = "Totem Selected",
        Values = {"Aurora Totem", "Sundial Totem", "Windset Totem", "Smokescreen Totem", "Tempest Totem", "Eclipse Totem", "Meteor Totem", "Avalanche Totem", "Blizzard Totem"},
        Multi = false,
        Default = nil,
    })
    SelectedBuyItems:OnChanged(function(Value)
        SelectedTotem = Value
    end)
    Tabs.Items:AddButton({
        Title = "Purchase Totem",
        Callback = function()
            ReplicatedStorage.events.purchase:FireServer(SelectedTotem, 'Item', nil, 1)
        end
    })

    local section = Tabs.Items:AddSection("Buy Crate")
    local SelectedBuyCrate = Tabs.Items:AddDropdown("SelectedBuyCrate", {
        Title = "Crate Selected",
        Values = {"Bait Crate", "Carbon Crate", "Common Crate", "Coral Geode", "Quality Bait Crate", "Volcanic Geode", "Festive Bait Crate"},
        Multi = false,
        Default = nil,
    })
    SelectedBuyCrate:OnChanged(function(Value)
        SelectedCrate = Value
    end)
    Tabs.Items:AddButton({
        Title = "Purchase Crate",
        Callback = function()
            ReplicatedStorage.events.purchase:FireServer(SelectedCrate, 'Fish', nil, 1)
        end
    })

    local section = Tabs.Items:AddSection("Buy Items")
    local SelectedBuyItems = Tabs.Items:AddDropdown("SelectedBuyItems", {
        Title = "Item Selected",
        Values = {"Advanced Glider", "Advanced Oxygen Tank", "Intermediate Oxygen Tank", "Beginner Oxygen Tank", "Pickaxe", "Winter Cloak", "Advanced Diving Gear", "Basic Diving Gear", "Conception Conch", "Crab Cage", "Firework", "Fish Radar", "Flippers", "GPS", "Glider", "Super Flippers", "Tidebreaker", "Witches Ingredient",},
        Multi = false,
        Default = nil,
    })
    SelectedBuyItems:OnChanged(function(Value)
        SelectedForBuy = Value
    end)
    Tabs.Items:AddButton({
        Title = "Purchase Item",
        Callback = function()
            ReplicatedStorage.events.purchase:FireServer(SelectedForBuy, 'Item', nil, 1)
        end
    })

    local section = Tabs.Items:AddSection("Buy Rod")
    local SelectedBuyRod = Tabs.Items:AddDropdown("SelectedBuyRod", {
        Title = "Rod Selected",
        Values = {"Aurora Rod", "Carbon Rod", "Destiny Rod", "Fast Rod", "Flimsy Rod", "Fortune Rod", "Kings Rod", "Long Rod", "Lucky Rod", "Midas Rod", "Mythical Rod", "Nocturnal Rod", "Phoenix Rod", "Plastic Rod", "Rapid Rod", "Reinforced Rod", "Rod Of The Depths", "Scurvy Rod", "Steady Rod", "Stone Rod", "Training Rod", "Trident Rod", "Midas", "Arctic Rod", "Avalanche Rod", "Summit Rod"},
        Multi = false,
        Default = nil,
    })
    SelectedBuyRod:OnChanged(function(Value)
        SelectedRod = Value
    end)
    Tabs.Items:AddButton({
        Title = "Purchase Rod",
        Callback = function()
            ReplicatedStorage.events.purchase:FireServer(SelectedRod, 'Rod', nil, 1)
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

    local TotemTPDropdownUI = Tabs.Teleports:AddDropdown("TotemTPDropdownUI", {
        Title = "Totem Teleport",
        Values = {"Aurora", "Sundial", "Windset", "Smokescreen", "Tempest", "Eclipse", "Meteor", "Avalanche", "Blizzard"},
        Multi = false,
        Default = nil,
    })
    TotemTPDropdownUI:OnChanged(function(Value)
        SelectedTotem = Value
        if SelectedTotem == "Aurora" then
            HumanoidRootPart.CFrame = CFrame.new(-1811, -137, -3282)
            TotemTPDropdownUI:SetValue(nil)
        elseif SelectedTotem == "Sundial" then
            HumanoidRootPart.CFrame = CFrame.new(-1148, 135, -1075)
            TotemTPDropdownUI:SetValue(nil)
        elseif SelectedTotem == "Windset" then
            HumanoidRootPart.CFrame = CFrame.new(2849, 178, 2702)
            TotemTPDropdownUI:SetValue(nil)
        elseif SelectedTotem == "Smokescreen" then
            HumanoidRootPart.CFrame = CFrame.new(2789, 140, -625)
            TotemTPDropdownUI:SetValue(nil)
        elseif SelectedTotem == "Tempest" then
            HumanoidRootPart.CFrame = CFrame.new(35, 133, 1943)
            TotemTPDropdownUI:SetValue(nil)
        elseif SelectedTotem == "Eclipse" then
            HumanoidRootPart.CFrame = CFrame.new(5966, 274, 840)
            TotemTPDropdownUI:SetValue(nil)
        elseif SelectedTotem == "Meteor" then
            HumanoidRootPart.CFrame = CFrame.new(-1944.4, 275.7, 230.9)
            TotemTPDropdownUI:SetValue(nil)
        elseif SelectedTotem == "Avalanche" then
            HumanoidRootPart.CFrame = CFrame.new(19708.6, 467.6, 6057.5)
            TotemTPDropdownUI:SetValue(nil)
        elseif SelectedTotem == "Blizzard" then
            HumanoidRootPart.CFrame = CFrame.new(20146.2, 742.9, 5805.0)
            TotemTPDropdownUI:SetValue(nil)
        end
    end)

    -- // WorldEvent Tab // --
    local WorldEventTPDropdownUI = Tabs.Teleports:AddDropdown("WorldEventTPDropdownUI", {
        Title = "WorldEvent Teleport",
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
                    for i,v in pairs(workspace.zones.fishing:GetChildren()) do
                        if v.Name == "Fischmas24" then
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
    local FastClick = Tabs.Misc:AddToggle("FastClick", {Title = "Fast Click (Bait Crate)", Default = false })
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

    local DisableOxygen = Tabs.Misc:AddToggle("DisableOxygen", {Title = "Disable Oxygen and Temperature", Default = true })
    DisableOxygen:OnChanged(function()
        LocalPlayer.Character.client.oxygen.Disabled = Options.DisableOxygen.Value
        LocalPlayer.Character.client["oxygen(peaks)"].Disabled = Options.DisableOxygen.Value
        LocalPlayer.Character.client.temperature.Disabled = Options.DisableOxygen.Value
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
    local section = Tabs.Misc:AddSection("Load Scripts For Dev")
    Tabs.Misc:AddButton({
        Title = "Load Infinite-Yield FE",
        Callback = function()
            --loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/BizcuitMild/scripts/main/InfiniteYield.lua'))()
        end
    })
    Tabs.Misc:AddButton({
        Title = "Load Dex",
        Callback = function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/BizcuitMild/scripts/main/Dex.lua'))()
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
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "CupPink",
    Text = "Executed!",
    Icon = "rbxassetid://119937569996752",
    Duration = 5
})
Fluent:Notify({
    Title = "CupPink",
    Content = "Executed!",
    Duration = 8
})
