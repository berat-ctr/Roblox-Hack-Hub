-- [[ GELİŞMİŞ ÇOK SEKMELİ HUB - V5 (SERVER BLACKHOLE & UI FIX & OPTIMIZED) ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- 🛡️ GELİŞMİŞ GÜVENLİK SİSTEMİ (Anti-Kick & Anti-Ban)
task.spawn(function()
    pcall(function()
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        if setreadonly then setreadonly(mt, false) end

        mt.__namecall = newcclosure(function(self, ...)
            local method = tostring(getnamecallmethod()):lower()
            if method == "kick" or method == "ban" then
                warn("[🛡️ HUB KORUMASI]: Oyunun seni sunucudan atması engellendi!")
                return nil 
            end
            return oldNamecall(self, ...)
        end)

        if setreadonly then setreadonly(mt, true) end
    end)
end)

-- Hub Genel Ayarları
local Settings = {
    Fly = false, Noclip = false, Speed = false, Jump = false, ESP = false, Godmode = false, Freecam = false,
    InfiniteJump = false, Fullbright = false, FlySpeed = 50, WalkSpeed = 100, JumpPower = 100, 
    Aimlock = false, ClickTP = false, TargetPlayer = nil, Magnet = false, Spin = false, BlackHole = false
}

-- Varsayılan Değerler (Kapatınca geri dönmesi için)
local DefaultSpeed = 16
local DefaultJump = 50

-------------------------------------------------------------------
-- 1. ARAYÜZ (GUI) OLUŞTURMA
-------------------------------------------------------------------
local GuiParent = LocalPlayer:WaitForChild("PlayerGui")
pcall(function()
    if gethui then GuiParent = gethui() elseif game:GetService("CoreGui") then GuiParent = game:GetService("CoreGui") end
end)

if GuiParent:FindFirstChild("AdvancedHub") then GuiParent.AdvancedHub:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdvancedHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = GuiParent

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 560, 0, 400)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(45, 45, 45)
MainStroke.Thickness = 1.5

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

local SidebarTitle = Instance.new("TextLabel")
SidebarTitle.Size = UDim2.new(1, 0, 0, 50)
SidebarTitle.BackgroundTransparency = 1
SidebarTitle.Text = "H A C K\nMENU (P)"
SidebarTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
SidebarTitle.Font = Enum.Font.GothamBlack
SidebarTitle.TextSize = 16
SidebarTitle.Parent = Sidebar

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -140, 1, 0)
ContentFrame.Position = UDim2.new(0, 140, 0, 0)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local Tabs = {
    Genel = Instance.new("ScrollingFrame", ContentFrame),
    Attack = Instance.new("ScrollingFrame", ContentFrame),
    TP = Instance.new("ScrollingFrame", ContentFrame),
    Troll = Instance.new("ScrollingFrame", ContentFrame)
}

for name, frame in pairs(Tabs) do
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.ScrollBarThickness = 4
    frame.BorderSizePixel = 0
    frame.Visible = false
end
Tabs.Genel.Visible = true

local function SwitchTab(tabName)
    for name, frame in pairs(Tabs) do frame.Visible = (name == tabName) end
end

local function CreateTabButton(name, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.85, 0, 0, 36)
    btn.Position = UDim2.new(0.075, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        SwitchTab(name)
        for _, otherBtn in ipairs(Sidebar:GetChildren()) do
            if otherBtn:IsA("TextButton") then
                otherBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                otherBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        end
        btn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    return btn
end

local tab1 = CreateTabButton("Genel", 70)
tab1.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
tab1.TextColor3 = Color3.fromRGB(255, 255, 255)
CreateTabButton("Attack", 115)
CreateTabButton("TP", 160)
CreateTabButton("Troll", 205)

local function CreateToggleButton(parent, text, pos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.44, 0, 0, 34)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", btn).Color = Color3.fromRGB(60, 60, 60)

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 170, 120) or Color3.fromRGB(40, 40, 40)
        btn.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
        callback(state)
    end)
    return btn
end

local function FindPlayer(nameString)
    if not nameString or nameString == "" then return nil end
    for _, plr in ipairs(Players:GetPlayers()) do
        if string.lower(string.sub(plr.Name, 1, #nameString)) == string.lower(nameString) or 
           string.lower(string.sub(plr.DisplayName, 1, #nameString)) == string.lower(nameString) then
            return plr
        end
    end
    return nil
end

-------------------------------------------------------------------
-- 2. "GENEL" SEKMESİ (Hız/Zıplama Düzeltildi)
-------------------------------------------------------------------
local flyConn, noclipConn, bodyVel, bodyGyro, fcPart, fcConn

CreateToggleButton(Tabs.Genel, "Fly (Uçma)", UDim2.new(0.04, 0, 0, 20), function(state)
    Settings.Fly = state
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if state then
        if hum then hum.PlatformStand = true end 
        bodyVel = Instance.new("BodyVelocity", char.HumanoidRootPart)
        bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro = Instance.new("BodyGyro", char.HumanoidRootPart)
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        flyConn = RunService.RenderStepped:Connect(function()
            if not bodyGyro or not bodyVel then return end
            bodyGyro.CFrame = Camera.CFrame
            local moveDir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
            bodyVel.Velocity = moveDir * Settings.FlySpeed
        end)
    else
        if hum then hum.PlatformStand = false end 
        if flyConn then flyConn:Disconnect() end
        if bodyVel then bodyVel:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
    end
end)

local FlySpeedBox = Instance.new("TextBox", Tabs.Genel)
FlySpeedBox.Size = UDim2.new(0.44, 0, 0, 30)
FlySpeedBox.Position = UDim2.new(0.04, 0, 0, 60)
FlySpeedBox.Text = "Fly Hızı: " .. Settings.FlySpeed
FlySpeedBox.TextSize = 12
FlySpeedBox.Font = Enum.Font.GothamBold
FlySpeedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FlySpeedBox.TextColor3 = Color3.fromRGB(200, 200, 200)
Instance.new("UICorner", FlySpeedBox).CornerRadius = UDim.new(0, 6)
FlySpeedBox.FocusLost:Connect(function()
    local val = tonumber(FlySpeedBox.Text:match("%d+"))
    if val then Settings.FlySpeed = val end
    FlySpeedBox.Text = "Fly Hızı: " .. Settings.FlySpeed
end)

CreateToggleButton(Tabs.Genel, "Speedhack", UDim2.new(0.52, 0, 0, 20), function(state) Settings.Speed = state end)

local SpeedBox = Instance.new("TextBox", Tabs.Genel)
SpeedBox.Size = UDim2.new(0.44, 0, 0, 30)
SpeedBox.Position = UDim2.new(0.52, 0, 0, 60)
SpeedBox.Text = "Yürüme Hızı: " .. Settings.WalkSpeed
SpeedBox.TextSize = 12
SpeedBox.Font = Enum.Font.GothamBold
SpeedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SpeedBox.TextColor3 = Color3.fromRGB(200, 200, 200)
Instance.new("UICorner", SpeedBox).CornerRadius = UDim.new(0, 6)
SpeedBox.FocusLost:Connect(function()
    local val = tonumber(SpeedBox.Text:match("%d+"))
    if val then Settings.WalkSpeed = val end
    SpeedBox.Text = "Yürüme Hızı: " .. Settings.WalkSpeed
end)

CreateToggleButton(Tabs.Genel, "Jumphack", UDim2.new(0.04, 0, 0, 105), function(state) Settings.Jump = state end)

local JumpBox = Instance.new("TextBox", Tabs.Genel)
JumpBox.Size = UDim2.new(0.44, 0, 0, 30)
JumpBox.Position = UDim2.new(0.04, 0, 0, 145)
JumpBox.Text = "Zıplama Gücü: " .. Settings.JumpPower
JumpBox.TextSize = 12
JumpBox.Font = Enum.Font.GothamBold
JumpBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
JumpBox.TextColor3 = Color3.fromRGB(200, 200, 200)
Instance.new("UICorner", JumpBox).CornerRadius = UDim.new(0, 6)
JumpBox.FocusLost:Connect(function()
    local val = tonumber(JumpBox.Text:match("%d+"))
    if val then Settings.JumpPower = val end
    JumpBox.Text = "Zıplama Gücü: " .. Settings.JumpPower
end)

CreateToggleButton(Tabs.Genel, "Noclip", UDim2.new(0.52, 0, 0, 105), function(state)
    Settings.Noclip = state
    if state then
        noclipConn = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() end
    end
end)

local oldLighting = {
    Ambient = Lighting.Ambient, Brightness = Lighting.Brightness, FogEnd = Lighting.FogEnd, GlobalShadows = Lighting.GlobalShadows
}
CreateToggleButton(Tabs.Genel, "Fullbright", UDim2.new(0.52, 0, 0, 145), function(state)
    Settings.Fullbright = state
    if state then
        RunService:BindToRenderStep("FullbrightStep", 1000, function()
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.Brightness = 2
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.ClockTime = 14
        end)
    else
        RunService:UnbindFromRenderStep("FullbrightStep")
        Lighting.Ambient = oldLighting.Ambient
        Lighting.Brightness = oldLighting.Brightness
        Lighting.FogEnd = oldLighting.FogEnd
        Lighting.GlobalShadows = oldLighting.GlobalShadows
    end
end)

CreateToggleButton(Tabs.Genel, "Godmode", UDim2.new(0.04, 0, 0, 190), function(state) Settings.Godmode = state end)

CreateToggleButton(Tabs.Genel, "Freecam", UDim2.new(0.52, 0, 0, 190), function(state)
    Settings.Freecam = state
    if state then
        if not fcPart then
            fcPart = Instance.new("Part"); fcPart.Size = Vector3.new(1,1,1); fcPart.Anchored = true
            fcPart.CanCollide = false; fcPart.Transparency = 1; fcPart.Parent = workspace
        end
        fcPart.CFrame = Camera.CFrame
        Camera.CameraSubject = fcPart
        fcConn = RunService.RenderStepped:Connect(function()
            local moveDir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
            fcPart.CFrame = fcPart.CFrame + (moveDir * 2) 
        end)
    else
        if fcConn then fcConn:Disconnect() end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = LocalPlayer.Character.Humanoid
        end
    end
end)

CreateToggleButton(Tabs.Genel, "Sonsuz Zıplama", UDim2.new(0.04, 0, 0, 235), function(state) Settings.InfiniteJump = state end)

UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- *OPTİMİZE EDİLMİŞ HIZ VE ZIPLAMA DÖNGÜSÜ*
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            -- Kapatıldığında varsayılan değerlere otomatik döner
            hum.WalkSpeed = Settings.Speed and Settings.WalkSpeed or DefaultSpeed
            hum.UseJumpPower = true
            hum.JumpPower = Settings.Jump and Settings.JumpPower or DefaultJump
            
            if Settings.Godmode then
                hum.Health = hum.MaxHealth
                hum.BreakJointsOnDeath = false
                pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
            end
        end
    end
end)

-------------------------------------------------------------------
-- 3. "ATTACK" SEKMESİ 
-------------------------------------------------------------------
CreateToggleButton(Tabs.Attack, "Aimlock & Oto-Ateş", UDim2.new(0.04, 0, 0, 20), function(state) Settings.Aimlock = state end)

local espFolder = Instance.new("Folder", GuiParent)
espFolder.Name = "HubESP"

CreateToggleButton(Tabs.Attack, "ESP (Görüş)", UDim2.new(0.04, 0, 0, 65), function(state)
    Settings.ESP = state
    if not state then espFolder:ClearAllChildren() return end
    task.spawn(function()
        while Settings.ESP do
            espFolder:ClearAllChildren()
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local highlight = Instance.new("Highlight")
                    highlight.FillColor = (plr == Settings.TargetPlayer) and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(200, 50, 50)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.Parent = espFolder
                    highlight.Adornee = plr.Character
                end
            end
            task.wait(0.5)
        end
    end)
end)

-------------------------------------------------------------------
-- 4. "TP" SEKMESİ 
-------------------------------------------------------------------
local TpBox = Instance.new("TextBox", Tabs.TP)
TpBox.Size = UDim2.new(0.92, 0, 0, 40)
TpBox.Position = UDim2.new(0.04, 0, 0, 20)
TpBox.PlaceholderText = "Işınlanılacak Oyuncu Adı..."
TpBox.Text = ""
TpBox.TextSize = 13
TpBox.Font = Enum.Font.GothamBold
TpBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TpBox.TextColor3 = Color3.fromRGB(200, 200, 200)
Instance.new("UICorner", TpBox).CornerRadius = UDim.new(0, 6)

local TpBtn = Instance.new("TextButton", Tabs.TP)
TpBtn.Size = UDim2.new(0.92, 0, 0, 40)
TpBtn.Position = UDim2.new(0.04, 0, 0, 70)
TpBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
TpBtn.Text = "IŞINLAN"
TpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TpBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", TpBtn).CornerRadius = UDim.new(0, 6)

TpBtn.MouseButton1Click:Connect(function()
    local target = FindPlayer(TpBox.Text)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
    end
end)

CreateToggleButton(Tabs.TP, "Tıkla Işınlan (Click TP)", UDim2.new(0.04, 0, 0, 125), function(state) Settings.ClickTP = state end)

-------------------------------------------------------------------
-- 5. "TROLL" SEKMESİ (GELİŞMİŞ SERVER BRING & OPTİMİZE BLACKHOLE)
-------------------------------------------------------------------

local BringAllBtn = Instance.new("TextButton", Tabs.Troll)
BringAllBtn.Size = UDim2.new(0.92, 0, 0, 38)
BringAllBtn.Position = UDim2.new(0.04, 0, 0, 15)
BringAllBtn.BackgroundColor3 = Color3.fromRGB(130, 40, 180)
BringAllBtn.Text = "🌐 HERKESİ BANA TP'LE (SERVER PAKETİ)"
BringAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BringAllBtn.Font = Enum.Font.GothamBold
BringAllBtn.TextSize = 12
Instance.new("UICorner", BringAllBtn).CornerRadius = UDim.new(0, 6)

-- *YENİ: GELİŞMİŞ SERVER PAKET GÖNDERİCİ (HERKESİ ÇEKME)*
BringAllBtn.MouseButton1Click:Connect(function()
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local foundRemote = false
    -- Sunucudaki açık RemoteEvent'leri tara
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            local rName = remote.Name:lower()
            -- Genelde TP işlemi yapan paket isimleri
            if rName:find("tp") or rName:find("teleport") or rName:find("bring") or rName:find("move") or rName:find("spawn") then
                foundRemote = true
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character then
                        pcall(function()
                            -- Farklı oyunların farklı parametre istekleri olabilir, hepsini deniyoruz:
                            remote:FireServer(plr.Character, myRoot.CFrame)
                            remote:FireServer(plr.Character.HumanoidRootPart, myRoot.CFrame)
                            remote:FireServer(plr.Name, myRoot.Position)
                            remote:FireServer(myRoot.CFrame, plr.Character)
                        end)
                    end
                end
            end
        end
    end

    if not foundRemote then
        warn("[HUB]: Sunucuda açık TP RemoteEvent'i bulunamadı. Korumalı Oyun!")
        -- Eğer oyun korumalıysa mecburen sadece client tarafında (sende) çeker:
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                plr.Character.HumanoidRootPart.CFrame = myRoot.CFrame * CFrame.new(0, 0, -3)
            end
        end
    else
        warn("[HUB]: Paketler başarıyla sunucuya gönderildi!")
    end
end)

-- *YENİ: OPTİMİZE EDİLMİŞ KARA DELİK SİSTEMİ*
local BlackHoleBtn = CreateToggleButton(Tabs.Troll, "🌌 KARA DELİK (GERÇEK SERVER - ARABA/EŞYA/FLING)", UDim2.new(0.04, 0, 0, 65), function(state) 
    Settings.BlackHole = state 
end)
BlackHoleBtn.Size = UDim2.new(0.92, 0, 0, 42)
BlackHoleBtn.BackgroundColor3 = Color3.fromRGB(180, 20, 20)
BlackHoleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BlackHoleBtn.Font = Enum.Font.GothamBold

-- FPS Düşüşünü önlemek için parçaları önbelleğe (Cache) alıyoruz
local unanchoredParts = {}
task.spawn(function()
    while true do
        task.wait(2) -- Her 2 saniyede bir tarar (Eskiden saniyede 60 kere tarıyordu, FPS'i bitiriyordu)
        if Settings.BlackHole then
            table.clear(unanchoredParts)
            for _, part in ipairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(LocalPlayer.Character) then
                    if part.Parent and not part.Parent:FindFirstChildOfClass("Humanoid") then
                        table.insert(unanchoredParts, part)
                    end
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not Settings.BlackHole then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart

    -- Sadece önbellekteki eşyalara fizik uygular (0 LAG)
    for _, part in ipairs(unanchoredParts) do
        if part and part.Parent then
            local offset = (root.Position - part.Position)
            local dist = offset.Magnitude

            if dist < 350 then
                part.CanCollide = false 
                local orbitVector = Vector3.new(-offset.Z, 15, offset.X).Unit * 220
                local pullVector = offset.Unit * (dist * 12)

                part.AssemblyLinearVelocity = pullVector + orbitVector
                part.AssemblyAngularVelocity = Vector3.new(200, 200, 200)
            end
        end
    end
end)

local TrollBox = Instance.new("TextBox", Tabs.Troll)
TrollBox.Size = UDim2.new(0.92, 0, 0, 32)
TrollBox.Position = UDim2.new(0.04, 0, 0, 120)
TrollBox.PlaceholderText = "Fırlatılacak Oyuncu Adı..."
TrollBox.Text = ""
TrollBox.TextSize = 12
TrollBox.Font = Enum.Font.GothamBold
TrollBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TrollBox.TextColor3 = Color3.fromRGB(200, 200, 200)
Instance.new("UICorner", TrollBox).CornerRadius = UDim.new(0, 6)

local TrollBtn = Instance.new("TextButton", Tabs.Troll)
TrollBtn.Size = UDim2.new(0.92, 0, 0, 35)
TrollBtn.Position = UDim2.new(0.04, 0, 0, 160)
TrollBtn.BackgroundColor3 = Color3.fromRGB(200, 70, 30)
TrollBtn.Text = "FLING (SEÇİLEN OYUNCUYU UÇUR)"
TrollBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TrollBtn.Font = Enum.Font.GothamBold
TrollBtn.TextSize = 12
Instance.new("UICorner", TrollBtn).CornerRadius = UDim.new(0, 6)

TrollBtn.MouseButton1Click:Connect(function()
    local target = FindPlayer(TrollBox.Text)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myRoot, targetRoot = LocalPlayer.Character.HumanoidRootPart, target.Character.HumanoidRootPart
        local oldCFrame = myRoot.CFrame
        local bav = Instance.new("BodyAngularVelocity", myRoot)
        bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bav.AngularVelocity = Vector3.new(0, 99999, 0)
        local startTime = tick()
        local c
        c = RunService.Heartbeat:Connect(function()
            if tick() - startTime > 2.5 or not targetRoot or not targetRoot.Parent then
                c:Disconnect(); bav:Destroy(); myRoot.CFrame = oldCFrame; myRoot.Velocity = Vector3.zero
            else
                myRoot.CFrame = targetRoot.CFrame; myRoot.Velocity = Vector3.new(9999, 9999, 9999)
            end
        end)
    end
end)

-------------------------------------------------------------------
-- 6. MENÜ KONTROLÜ (P TUŞU)
-------------------------------------------------------------------
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.P then MainFrame.Visible = not MainFrame.Visible end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and Settings.ClickTP then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and Mouse.Hit then
            LocalPlayer.Character.HumanoidRootPart.CFrame = Mouse.Hit + Vector3.new(0, 3, 0)
        end
    end
end)
