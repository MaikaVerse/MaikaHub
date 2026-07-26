if game.PlaceId ~= 93978595733734 then
    warn("[Project ESP] Place ID mismatch. Script terminated.")
    print("This script is exclusively built for PlaceID: 93978595733734")
    return
end

print("[System] Loading Maika Hub...")

if getgenv().ProjectESP_Library then
    pcall(function() getgenv().ProjectESP_Library:Unload() end)
    task.wait(0.1)
end


-- ==========================================
-- BUNDLED LIBRARIES
-- ==========================================

-- ==========================================
-- File: lib/esp.lua
-- ==========================================
getgenv().ESP_Settings = {
    Enabled = false,
    ShowName = false,
    ShowTeam = false,
    PlayerColor = Color3.fromRGB(255, 0, 0),
    UseTeamColor = true,
    
    ShowGenerators = false,
    ShowGeneratorDistance = false,
    GeneratorColor = Color3.fromRGB(255, 255, 0),
    PlayerTransparency = 1,
    GeneratorTransparency = 0.5,
    
    ShowPallets = false,
    ShowPalletDistance = false,
    PalletColor = Color3.fromRGB(0, 255, 255),
    PalletTransparency = 0.5
}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local espObjects = {}
local genObjects = {}
local genNames = {"Gens", "gens", "Generators", "Generator", "generators", "generator", "new Generator", "new Generators"}
local palletObjects = {}

local function getGeneratorFolders()
    local folders = {}
    local map = workspace:FindFirstChild("Map")
    if map then
        for _, name in ipairs(genNames) do
            local folder = map:FindFirstChild(name)
            if folder then table.insert(folders, folder) end
        end
    end
    return folders
end

local function createGenEsp(genModel)
    if genObjects[genModel] then return end
    
    local text = Drawing.new("Text")
    text.Visible = false
    text.Center = true
    text.Outline = true
    text.Font = 2
    text.Size = 14
    
    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    local success = pcall(function()
        highlight.Parent = CoreGui
    end)
    if not success then
        highlight.Parent = workspace
    end
    
    genObjects[genModel] = {
        Text = text,
        Highlight = highlight
    }
end

local function removeGenEsp(genModel)
    if genObjects[genModel] then
        if genObjects[genModel].Text then genObjects[genModel].Text:Remove() end
        if genObjects[genModel].Highlight then genObjects[genModel].Highlight:Destroy() end
        genObjects[genModel] = nil
    end
end

local function isPallet(obj)
    if obj:IsA("Model") then
        local name = string.lower(obj.Name)
        if string.find(name, "crate") or string.find(name, "palletcrate") then return false end
        
        if string.find(name, "pallet") or name == "palletwrong" then
            return true
        end
    end
    return false
end

local function createPalletEsp(palletModel)
    if palletObjects[palletModel] then return end
    
    local text = Drawing.new("Text")
    text.Visible = false
    text.Center = true
    text.Outline = true
    text.Font = 2
    text.Size = 14
    
    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    local success = pcall(function()
        highlight.Parent = CoreGui
    end)
    if not success then
        highlight.Parent = workspace
    end
    
    palletObjects[palletModel] = {
        Text = text,
        Highlight = highlight
    }
end

local function removePalletEsp(palletModel)
    if palletObjects[palletModel] then
        if palletObjects[palletModel].Text then palletObjects[palletModel].Text:Remove() end
        if palletObjects[palletModel].Highlight then palletObjects[palletModel].Highlight:Destroy() end
        palletObjects[palletModel] = nil
    end
end

task.spawn(function()
    while task.wait(5) do
        local folders = getGeneratorFolders()
        for _, folder in ipairs(folders) do
            for _, gen in ipairs(folder:GetChildren()) do
                if gen:IsA("Model") or gen:IsA("Folder") then
                    createGenEsp(gen)
                end
            end
            
            if not folder:GetAttribute("EspHooked") then
                folder:SetAttribute("EspHooked", true)
                folder.ChildAdded:Connect(function(child)
                    if child:IsA("Model") or child:IsA("Folder") then
                        createGenEsp(child)
                    end
                end)
                folder.ChildRemoved:Connect(removeGenEsp)
            end
        end
        
        local map = workspace:FindFirstChild("Map")
        if map then
            if not map:GetAttribute("PalletEspHooked") then
                map:SetAttribute("PalletEspHooked", true)
                for _, obj in ipairs(map:GetDescendants()) do
                    if isPallet(obj) then
                        createPalletEsp(obj)
                    else
                        removePalletEsp(obj)
                    end
                end
                
                map.DescendantAdded:Connect(function(descendant)
                    if isPallet(descendant) then
                        createPalletEsp(descendant)
                    end
                end)
                map.DescendantRemoving:Connect(removePalletEsp)
            else
                -- Continuous check to remove invalid pallets that were already hooked
                for pallet, _ in pairs(palletObjects) do
                    if not isPallet(pallet) then
                        removePalletEsp(pallet)
                    end
                end
            end
        end
    end
end)

local function createEsp(player)
    local text = Drawing.new("Text")
    text.Visible = false
    text.Center = true
    text.Outline = true
    text.Font = 2
    text.Size = 15
    text.Color = Color3.new(1, 1, 1)
    
    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    

    local success = pcall(function()
        highlight.Parent = CoreGui
    end)
    if not success then
        highlight.Parent = workspace
    end
    
    espObjects[player] = {
        Text = text,
        Highlight = highlight
    }
end

local function removeEsp(player)
    if espObjects[player] then
        if espObjects[player].Text then espObjects[player].Text:Remove() end
        if espObjects[player].Highlight then espObjects[player].Highlight:Destroy() end
        espObjects[player] = nil
    end
end

for i, v in pairs(Players:GetPlayers()) do
    if v ~= LocalPlayer then
        createEsp(v)
    end
end

Players.PlayerAdded:Connect(function(v)
    if v ~= LocalPlayer then
        createEsp(v)
    end
end)
Players.PlayerRemoving:Connect(removeEsp)

RunService.RenderStepped:Connect(function()
    for player, objs in pairs(espObjects) do
        local text = objs.Text
        local highlight = objs.Highlight
        
        if getgenv().ESP_Settings.Enabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            
            highlight.Adornee = player.Character
            highlight.Enabled = true
            highlight.FillTransparency = getgenv().ESP_Settings.PlayerTransparency
            if getgenv().ESP_Settings.UseTeamColor and player.TeamColor then
                highlight.OutlineColor = player.TeamColor.Color
                highlight.FillColor = player.TeamColor.Color
            else
                highlight.OutlineColor = getgenv().ESP_Settings.PlayerColor
                highlight.FillColor = getgenv().ESP_Settings.PlayerColor
            end
            
            local hrp = player.Character.HumanoidRootPart
            local vector, onScreen = camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local displayText = ""
                if getgenv().ESP_Settings.ShowName then
                    displayText = displayText .. player.Name .. "\n"
                end
                if getgenv().ESP_Settings.ShowTeam then
                    if player.Team then
                        displayText = displayText .. "[" .. player.Team.Name .. "]"
                    else
                        displayText = displayText .. "[Neutral]"
                    end
                end
                if getgenv().ESP_Settings.UseTeamColor and player.TeamColor then
                    text.Color = player.TeamColor.Color
                else
                    text.Color = getgenv().ESP_Settings.PlayerColor
                end
                text.Text = displayText
                text.Position = Vector2.new(vector.X, vector.Y - 40)
                text.Visible = (displayText ~= "")
            else
                text.Visible = false
            end
        else
            text.Visible = false
            highlight.Enabled = false
        end
    end
    
    local function isGenActive(gen)
        for _, v in ipairs(gen:GetDescendants()) do
            if string.find(v.Name, "GeneratorPoint") then
                return true
            end
        end
        return false
    end
    
    for gen, objs in pairs(genObjects) do
        local text = objs.Text
        local highlight = objs.Highlight
        
        if getgenv().ESP_Settings.Enabled and getgenv().ESP_Settings.ShowGenerators and isGenActive(gen) then
            highlight.FillColor = getgenv().ESP_Settings.GeneratorColor
            highlight.OutlineColor = getgenv().ESP_Settings.GeneratorColor
            highlight.FillTransparency = getgenv().ESP_Settings.GeneratorTransparency
            highlight.Adornee = gen
            highlight.Enabled = true
            
            if getgenv().ESP_Settings.ShowGeneratorDistance then
                local part = (gen:IsA("Model") and gen.PrimaryPart) or gen:FindFirstChildWhichIsA("BasePart", true)
                if part then
                    local vector, onScreen = camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local distance = math.floor((camera.CFrame.Position - part.Position).Magnitude)
                        

                        local progStr = ""
                        local attributes = gen:GetAttributes()
                        local prog = attributes.Progress or attributes.progress or attributes.RepairProgress or attributes.Percentage or attributes.percentage
                        
                        if not prog then
                            local progObj = gen:FindFirstChild("Progress") or gen:FindFirstChild("progress") or gen:FindFirstChild("RepairProgress") or gen:FindFirstChild("Percentage")
                            if progObj and (progObj:IsA("NumberValue") or progObj:IsA("IntValue")) then
                                prog = progObj.Value
                            end
                        end
                        
                        if prog then
                            if type(prog) == "number" then
                                if prog <= 1 then
                                    progStr = string.format(" (%.0f%%)", prog * 100)
                                else
                                    if prog > 100 then prog = 100 end
                                    progStr = string.format(" (%.0f%%)", prog)
                                end
                            else
                                progStr = " (" .. tostring(prog) .. ")"
                            end
                        end
                        
                        text.Text = string.format("[%dm]%s", distance, progStr)
                        text.Position = Vector2.new(vector.X, vector.Y)
                        text.Color = getgenv().ESP_Settings.GeneratorColor
                        text.Visible = true
                    else
                        text.Visible = false
                    end
                else
                    text.Visible = false
                end
            else
                text.Visible = false
            end
        else
            highlight.Enabled = false
            text.Visible = false
        end
    end
    
    for pallet, objs in pairs(palletObjects) do
        local text = objs.Text
        local highlight = objs.Highlight
        
        if getgenv().ESP_Settings.Enabled and getgenv().ESP_Settings.ShowPallets then
            highlight.FillColor = getgenv().ESP_Settings.PalletColor
            highlight.OutlineColor = getgenv().ESP_Settings.PalletColor
            highlight.FillTransparency = getgenv().ESP_Settings.PalletTransparency
            highlight.Adornee = pallet
            highlight.Enabled = true
            
            if getgenv().ESP_Settings.ShowPalletDistance then
                local part = pallet.PrimaryPart or pallet:FindFirstChildWhichIsA("BasePart")
                if part then
                    local vector, onScreen = camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local distance = math.floor((camera.CFrame.Position - part.Position).Magnitude)
                        text.Text = string.format("Pallet [%dm]", distance)
                        text.Position = Vector2.new(vector.X, vector.Y)
                        text.Color = getgenv().ESP_Settings.PalletColor
                        text.Visible = true
                    else
                        text.Visible = false
                    end
                else
                    text.Visible = false
                end
            else
                text.Visible = false
            end
        else
            highlight.Enabled = false
            text.Visible = false
        end
    end
end)

local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.F12 then
        getgenv().ESP_Settings.Enabled = not getgenv().ESP_Settings.Enabled
    end
end)

-- ==========================================
-- File: lib/skillcheck.lua
-- ==========================================
getgenv().Survivor_Settings = getgenv().Survivor_Settings or {
    AutoSkillCheck = false
}

local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local isPressing = false

RunService.RenderStepped:Connect(function()
    if getgenv().Survivor_Settings.AutoSkillCheck then
        local gui = LocalPlayer.PlayerGui:FindFirstChild("SkillCheckPromptGui")
        if gui and gui:FindFirstChild("Check") and gui.Check.Visible then
            local check = gui.Check
            local line = check:FindFirstChild("Line")
            local goal = check:FindFirstChild("Goal")
            
            if line and goal then
                local currentRot = line.Rotation
                local targetRot = goal.Rotation
                
                -- Zona Great/Success
                local minHit = 102 + targetRot
                local maxHit = 116 + targetRot
                
                -- Margin diperlebar agar tidak ter-skip saat frame drop / lag
                if currentRot >= minHit and currentRot <= maxHit then
                    if not isPressing then
                        isPressing = true
                        
                        -- Menggunakan task.spawn agar tidak memblokir RenderStepped
                        task.spawn(function()
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                            task.wait(0.02)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                        end)
                        
                        -- Cooldown
                        task.delay(0.5, function()
                            isPressing = false
                        end)
                    end
                else
                    -- Reset flag jika jarum mereset posisinya
                    if currentRot < minHit - 50 or currentRot > maxHit + 50 then
                        isPressing = false
                    end
                end
            end
        else
            -- Pastikan isPressing direset ketika GUI hilang
            isPressing = false
        end
    end
end)


-- ==========================================
-- File: lib/silentaim.lua
-- ==========================================
if getgenv().SilentAimLoaded then return end
getgenv().SilentAimLoaded = true

getgenv().SilentAim_Settings = {
    Enabled = false,
    ShowFOV = false,
    FOVColor = Color3.fromRGB(255, 255, 255),
    ShowCrosshair = false,
    FOV = 80,
    TargetTeam = "Killer",
    TargetPart = "Head"
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Mouse = LocalPlayer:GetMouse()

local FOVCircle = Drawing.new("Circle")
FOVCircle.Filled = false
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64

local CrosshairH = Drawing.new("Line")
CrosshairH.Thickness = 1.5
CrosshairH.Color = Color3.fromRGB(0, 255, 0)

local CrosshairV = Drawing.new("Line")
CrosshairV.Thickness = 1.5
CrosshairV.Color = Color3.fromRGB(0, 255, 0)

local function isTargetValid(player)
    if player == LocalPlayer then return false end
    if not (player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0) then return false end
    
    local targetTeam = getgenv().SilentAim_Settings.TargetTeam
    if targetTeam == "Both" then
        return true
    elseif targetTeam == "Team" then
        return player.Team == LocalPlayer.Team
    else
        return player.Team ~= LocalPlayer.Team
    end
end

local function getNearestTarget()
    local nearestDist = getgenv().SilentAim_Settings.FOV
    local nearestPlayer = nil
    local centerPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if isTargetValid(player) then
            local partName = getgenv().SilentAim_Settings.TargetPart
            local targetPart = player.Character:FindFirstChild(partName) or player.Character:FindFirstChild("HumanoidRootPart")
            if targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - centerPos).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearestPlayer = player
                    end
                end
            end
        end
    end
    return nearestPlayer
end

RunService.RenderStepped:Connect(function()
    local centerPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    FOVCircle.Radius = getgenv().SilentAim_Settings.FOV
    FOVCircle.Color = getgenv().SilentAim_Settings.FOVColor
    FOVCircle.Visible = getgenv().SilentAim_Settings.ShowFOV
    FOVCircle.Position = centerPos
    
    CrosshairH.Visible = getgenv().SilentAim_Settings.ShowCrosshair
    CrosshairV.Visible = getgenv().SilentAim_Settings.ShowCrosshair
    
    if getgenv().SilentAim_Settings.ShowCrosshair then
        local crosshairSize = 10
        CrosshairH.From = Vector2.new(centerPos.X - crosshairSize, centerPos.Y)
        CrosshairH.To = Vector2.new(centerPos.X + crosshairSize, centerPos.Y)
        CrosshairV.From = Vector2.new(centerPos.X, centerPos.Y - crosshairSize)
        CrosshairV.To = Vector2.new(centerPos.X, centerPos.Y + crosshairSize)
    end
    
end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    
    if not checkcaller() then
        if method == "FireServer" or method == "InvokeServer" or method == "fireServer" then
            if self.Name == "Fire" and getgenv().SilentAim_Settings.Enabled then
                local target = getNearestTarget()
                if target and target.Character then
                    local partName = getgenv().SilentAim_Settings.TargetPart
                    local targetPart = target.Character:FindFirstChild(partName) or target.Character:FindFirstChild("HumanoidRootPart")
                    if targetPart then
                        local targetPos = targetPart.Position
                        
                        -- Menggunakan Kepala karakter sebagai titik awal agar akurat di Third Person
                        local originPos = Camera.CFrame.Position
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
                            originPos = LocalPlayer.Character.Head.Position
                        end
                        
                        local direction = (targetPos - originPos).Unit
                        
                        local args = {...}
                        local count = select("#", ...)
                        local replaced = false
                        
                        for i = 1, count do
                            if typeof(args[i]) == "Vector3" then
                                -- Mencegah pisau mental/mengenai diri sendiri:
                                -- Jika Vector3 aslinya adalah arah (Magnitude ~ 1)
                                if math.abs(args[i].Magnitude - 1) < 0.05 then
                                    args[i] = direction
                                else
                                    -- Jika Vector3 aslinya adalah posisi kordinat (Hit Position)
                                    args[i] = targetPos
                                end
                                replaced = true
                            elseif typeof(args[i]) == "CFrame" then
                                args[i] = CFrame.lookAt(Camera.CFrame.Position, targetPos)
                                replaced = true
                            end
                        end
                        
                        if replaced then
                            setnamecallmethod(method)
                            return oldNamecall(self, unpack(args, 1, count))
                        end
                    end
                end
            end
        end
    end
    
    setnamecallmethod(method)
    return oldNamecall(self, ...)
end)

local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() and getgenv().SilentAim_Settings.Enabled then
        if key == "Hit" or key == "TargetSurface" or key == "Target" then
            if self == Mouse then
                local target = getNearestTarget()
                if target and target.Character then
                    local targetPart = target.Character:FindFirstChild(getgenv().SilentAim_Settings.TargetPart) or target.Character:FindFirstChild("HumanoidRootPart")
                    if targetPart then
                        if key == "Hit" or key == "TargetSurface" then
                            local targetPos = targetPart.Position
                            return CFrame.lookAt(Camera.CFrame.Position, targetPos)
                        elseif key == "Target" then
                            return targetPart
                        end
                    end
                end
            end
        end
    end
    return oldIndex(self, key)
end)


-- ==========================================
-- File: lib/veilaim.lua
-- ==========================================
if getgenv().VeilAimLoaded then return end
getgenv().VeilAimLoaded = true

getgenv().VeilAim_Settings = {
    Enabled = false,
    TargetPart = "HumanoidRootPart"
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local TargetIndicator = Drawing.new("Circle")
TargetIndicator.Filled = false
TargetIndicator.Thickness = 2
TargetIndicator.Color = Color3.fromRGB(255, 0, 0)
TargetIndicator.Radius = 15
TargetIndicator.Visible = false

local TargetLine = Drawing.new("Line")
TargetLine.Thickness = 2
TargetLine.Color = Color3.fromRGB(255, 0, 0)
TargetLine.Visible = false

local PredictionDot = Drawing.new("Circle")
PredictionDot.Filled = true
PredictionDot.Thickness = 1
PredictionDot.Color = Color3.fromRGB(0, 255, 0)
PredictionDot.Radius = 4
PredictionDot.Visible = false

local PredictionLine = Drawing.new("Line")
PredictionLine.Thickness = 1.5
PredictionLine.Color = Color3.fromRGB(0, 255, 0)
PredictionLine.Visible = false

local function isPlayerKiller(player)
    if player and player.Team then
        local tName = string.lower(player.Team.Name)
        return string.match(tName, "killer") or string.match(tName, "beast") or string.match(tName, "slasher")
    end
    return false
end

local function isTargetValid(player)
    if player == LocalPlayer then return false end
    if not (player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0) then return false end
    return not isPlayerKiller(player) -- Veil selalu menargetkan Survivor
end

local function getNearestTarget()
    local nearestDist = math.huge
    local nearestPlayer = nil
    local centerPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if isTargetValid(player) then
            local targetPart = player.Character:FindFirstChild(getgenv().VeilAim_Settings.TargetPart) or player.Character:FindFirstChild("HumanoidRootPart")
            if targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - centerPos).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearestPlayer = player
                    end
                end
            end
        end
    end
    return nearestPlayer
end

local IsCharging = false

UserInputService.InputBegan:Connect(function(input, gpe)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        IsCharging = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        IsCharging = false
    end
end)

local function SolveTrajectory(origin, targetPos, targetVel, projectileSpeed, gravity)
    -- Jika power terlampau kecil (misal baru di-klik), hindari pembagian nol
    projectileSpeed = math.max(projectileSpeed, 1)
    
    local distance = (targetPos - origin).Magnitude
    local t = distance / projectileSpeed
    
    -- Iterative Solver (5 langkah) untuk menyempurnakan kalkulasi waktu tempuh (t)
    -- Memperbaiki masalah panah/tombak meluncur ke bawah karena jarak lengkungan jauh lebih besar dari jarak lurus
    for i = 1, 5 do
        local futurePos = targetPos
        if targetVel then
            futurePos = futurePos + (targetVel * t)
        end
        local drop = 0.5 * gravity * (t ^ 2)
        local aimPos = futurePos + Vector3.new(0, drop, 0)
        t = (aimPos - origin).Magnitude / projectileSpeed
    end
    
    local finalFuturePos = targetPos
    if targetVel then
        finalFuturePos = finalFuturePos + (targetVel * t)
    end
    local finalDrop = 0.5 * gravity * (t ^ 2)
    local finalAimPos = finalFuturePos + Vector3.new(0, finalDrop, 0)
    
    return finalAimPos, t
end

RunService.RenderStepped:Connect(function()
    local amIKiller = isPlayerKiller(LocalPlayer)
    if not (amIKiller and getgenv().VeilAim_Settings.Enabled) then
        TargetIndicator.Visible = false
        TargetLine.Visible = false
        PredictionDot.Visible = false
        PredictionLine.Visible = false
        return
    end

    local centerPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local target = getNearestTarget()
    
    if target and target.Character then
        local targetPart = target.Character:FindFirstChild(getgenv().VeilAim_Settings.TargetPart) or target.Character:FindFirstChild("HumanoidRootPart")
        if targetPart then
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if onScreen then
                TargetIndicator.Position = Vector2.new(screenPos.X, screenPos.Y)
                TargetIndicator.Visible = true
                
                TargetLine.From = centerPos
                TargetLine.To = Vector2.new(screenPos.X, screenPos.Y)
                TargetLine.Visible = true
                
                local originPos = Camera.CFrame.Position
                
                if not IsCharging then
                    local aimPos = SolveTrajectory(originPos, targetPart.Position, targetPart.Velocity or Vector3.zero, 165, workspace.Gravity)
                    getgenv().VeilLastLockedAimPos = aimPos
                end
                
                local aimPosToUse = getgenv().VeilLastLockedAimPos or targetPart.Position
                local aimScreenPos, aimOnScreen = Camera:WorldToViewportPoint(aimPosToUse)
                
                if aimOnScreen then
                    PredictionDot.Position = Vector2.new(aimScreenPos.X, aimScreenPos.Y)
                    PredictionDot.Visible = true
                    
                    PredictionLine.From = centerPos
                    PredictionLine.To = PredictionDot.Position
                    PredictionLine.Visible = true
                else
                    PredictionDot.Visible = false
                    PredictionLine.Visible = false
                end
            else
                TargetIndicator.Visible = false
                TargetLine.Visible = false
                PredictionDot.Visible = false
                PredictionLine.Visible = false
            end
        else
            TargetIndicator.Visible = false
            TargetLine.Visible = false
            PredictionDot.Visible = false
            PredictionLine.Visible = false
        end
    else
        TargetIndicator.Visible = false
        TargetLine.Visible = false
        PredictionDot.Visible = false
        PredictionLine.Visible = false
    end
end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    
    if not checkcaller() then
        if (method == "FireServer" or method == "InvokeServer" or method == "fireServer") and self.Name == "Spearthrow" then
            local amIKiller = isPlayerKiller(LocalPlayer)
            
            if amIKiller and getgenv().VeilAim_Settings.Enabled then
                local target = getNearestTarget()
                if target and target.Character then
                    local targetPart = target.Character:FindFirstChild(getgenv().VeilAim_Settings.TargetPart) or target.Character:FindFirstChild("HumanoidRootPart")
                    if targetPart then
                        local originPos = Camera.CFrame.Position
                        local args = {...}
                        
                        -- Mengambil power lemparan secara dinamis dari server args (args[2]), 
                        -- jika gagal maka fallback ke Max Power (165)
                        local power = 165
                        if typeof(args[2]) == "number" then
                            power = args[2]
                        end
                        
                        local aimPos = SolveTrajectory(originPos, targetPart.Position, targetPart.Velocity or Vector3.zero, power, workspace.Gravity)
                        local direction = (aimPos - originPos).Unit
                        
                        local args = {...}
                        if typeof(args[1]) == "Vector3" then
                            args[1] = direction
                            setnamecallmethod(method)
                            return oldNamecall(self, unpack(args))
                        end
                    end
                end
            end
        end
    end
    
    return oldNamecall(self, ...)
end)


-- ==========================================
-- File: lib/autoparry.lua
-- ==========================================
if getgenv().AutoParryLoaded then return end
getgenv().AutoParryLoaded = true

getgenv().AutoParry_Settings = {
    Enabled = false,
    Mode = "Legit",
    Distance = 10,
    Sensitivity = 0,
    ShowCircle = false,
    CircleColor = Color3.fromRGB(255, 255, 255),
    CircleTransparency = 0
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local parryPart = Instance.new("Part")
parryPart.Name = "AutoParryRange"
parryPart.Anchored = true
parryPart.CanCollide = false
parryPart.CanQuery = false
parryPart.CastShadow = false
parryPart.Massless = true
parryPart.Transparency = 1
parryPart.Parent = workspace.Terrain

local surfaceGui = Instance.new("SurfaceGui")
surfaceGui.Name = "RangeGui"
surfaceGui.Face = Enum.NormalId.Top
surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
surfaceGui.CanvasSize = Vector2.new(1000, 1000)
surfaceGui.LightInfluence = 0
surfaceGui.AlwaysOnTop = false
surfaceGui.Parent = parryPart

local frame = Instance.new("Frame")
frame.Size = UDim2.new(1, 0, 1, 0)
frame.Position = UDim2.new(0, 0, 0, 0)
frame.Parent = surfaceGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0.5, 0)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Thickness = 3
stroke.Parent = frame

local function isEnemy(player)
    if player == LocalPlayer then return false end
    if not (player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0) then return false end
    return player.Team ~= LocalPlayer.Team
end

-- Hanya digunakan untuk mode Legit
local function isAttackingAnim(character)
    if character:GetAttribute("IsStunned") or character:GetAttribute("Immobile") or character:GetAttribute("isBreakingPallet") or character:GetAttribute("isBreakingGen") or character:GetAttribute("isVaulting") or character:GetAttribute("IsVaulting") or character:GetAttribute("IsBreaking") or character:GetAttribute("spearmode") then
        return false
    end
    
    local hum = character:FindFirstChild("Humanoid")
    if hum then
        local animator = hum:FindFirstChild("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                if (track.Priority == Enum.AnimationPriority.Action or track.Priority == Enum.AnimationPriority.Action2 or track.Priority == Enum.AnimationPriority.Action3 or track.Priority == Enum.AnimationPriority.Action4) then
                    if not track.Looped and track.Speed > 0 then
                        return true
                    end
                    
                    if track.Animation then
                        local animName = string.lower(track.Animation.Name or "")
                        local trackName = string.lower(track.Name)
                        local animId = track.Animation.AnimationId or ""
                        
                        if string.find(animName, "lunge") or string.find(trackName, "lunge") or string.find(animName, "hold") or string.find(trackName, "hold") then
                            return true
                        end
                        
                        if string.find(animId, "105374834496520") or string.find(animId, "138720291317243") or string.find(animId, "115244153053858") or string.find(animId, "117070354890871") or string.find(animId, "129784271201071") or string.find(animId, "122812055447896") or string.find(animId, "135002183282873") then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

RunService.RenderStepped:Connect(function()
    if getgenv().AutoParry_Settings.ShowCircle and getgenv().AutoParry_Settings.Enabled then
        local radius = getgenv().AutoParry_Settings.Distance
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local color = getgenv().AutoParry_Settings.CircleColor
            local fillTransparency = getgenv().AutoParry_Settings.CircleTransparency
            parryPart.Size = Vector3.new(radius * 2, 0.05, radius * 2)
            parryPart.CFrame = CFrame.new(hrp.Position - Vector3.new(0, 2.9, 0))
            frame.BackgroundColor3 = color
            frame.BackgroundTransparency = fillTransparency
            stroke.Color = color
            frame.BackgroundTransparency = fillTransparency >= 1 and 1 or fillTransparency
            parryPart.Transparency = 1
            surfaceGui.Enabled = true
        else
            surfaceGui.Enabled = false
        end
    else
        surfaceGui.Enabled = false
    end
end)

local isParrying = false

local function executeParry(enemyHrp, myHrp)
    if isParrying then return end
    isParrying = true
    
    -- Memaksa karakter menghadap ke Killer dengan kuat menggunakan BodyGyro
    task.spawn(function()
        if myHrp and enemyHrp then
            local bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(0, math.huge, 0)
            bg.P = 10000
            bg.D = 100
            bg.CFrame = CFrame.new(myHrp.Position, Vector3.new(enemyHrp.Position.X, myHrp.Position.Y, enemyHrp.Position.Z))
            bg.Parent = myHrp
            
            local startTime = tick()
            while tick() - startTime < 0.4 and isParrying do
                if myHrp and myHrp.Parent and enemyHrp and enemyHrp.Parent then
                    bg.CFrame = CFrame.new(myHrp.Position, Vector3.new(enemyHrp.Position.X, myHrp.Position.Y, enemyHrp.Position.Z))
                end
                task.wait()
            end
            bg:Destroy()
        end
    end)
    
    pcall(function()
        if mouse2press and mouse2release then
            mouse2press()
            task.wait(0.05)
            mouse2release()
        else
            VIM:SendMouseButtonEvent(0, 0, 1, true, game, 0)
            task.wait(0.05)
            VIM:SendMouseButtonEvent(0, 0, 1, false, game, 0)
        end
    end)
    
    task.wait(0.8)
    isParrying = false
end

-- Mengecek jarak dan parry jika kondisi terpenuhi
local function checkAndParry(isStrictBlatant)
    if not getgenv().AutoParry_Settings.Enabled then return end
    
    -- Jangan lakukan parry jika sedang menjadi Killer
    if LocalPlayer.Team and (string.find(string.lower(LocalPlayer.Team.Name), "killer") or string.find(string.lower(LocalPlayer.Team.Name), "hunter")) then return end
    
    local myChar = LocalPlayer.Character
    if not myChar then return end
    
    -- Cegah parry jika kita sedang knocked, digendong, digantung, dll
    if myChar:GetAttribute("Immobile") or myChar:GetAttribute("IsStunned") or myChar:GetAttribute("IsCarried") or myChar:GetAttribute("IsHooked") or myChar:GetAttribute("Carried") then return end
    
    local myHum = myChar:FindFirstChild("Humanoid")
    if myHum and (myHum.Health <= 0 or myHum.WalkSpeed <= 0 or myHum.PlatformStand or myHum.Sit) then return end
    
    local myHrp = myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end
    
    local baseRadius = getgenv().AutoParry_Settings.Distance
    
    for _, player in ipairs(Players:GetPlayers()) do
        if isEnemy(player) then
            local enemyHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if enemyHrp then
                local dist = (myHrp.Position - enemyHrp.Position).Magnitude
                
                -- Jika dalam jangkauan
                if dist <= baseRadius then
                    
                    -- Jika mode Blatant (ketat), pastikan Killer benar-benar menghadap ke kita (Lunge asli)
                    -- agar tidak ke-trigger oleh killer yang serangannya meleset arah atau membelakangi kita
                    if isStrictBlatant then
                        local killerLook = enemyHrp.CFrame.LookVector
                        local dirToMe = (myHrp.Position - enemyHrp.Position).Unit
                        local dot = killerLook:Dot(dirToMe)
                        
                        -- Dot > 0.5 berarti killer menghadap ke arah kita kurang lebih 60 derajat FOV
                        if dot < 0.5 then
                            continue -- Lewati, ini fake/bait lunge
                        end
                    end
                    
                    local delayMs = getgenv().AutoParry_Settings.Sensitivity or 0
                    if delayMs > 0 then
                        task.delay(delayMs / 1000, function()
                            executeParry(enemyHrp, myHrp)
                        end)
                    else
                        executeParry(enemyHrp, myHrp)
                    end
                end
            end
        end
    end
end

-- Deteksi Serangan Asli via Remote Event (Kunci dari Mode Blatant)
local remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
if remotes then
    local attacks = remotes:WaitForChild("Attacks", 5)
    if attacks then
        -- LungeDetect dan AfterAttack seringkali adalah indikator serangan asli yang didaftarkan server, bukan sekedar start animasi
        for _, remoteName in ipairs({"BasicAttack", "Lunge", "LungeDetect", "TrailEvent"}) do
            local remote = attacks:FindFirstChild(remoteName)
            if remote and remote:IsA("RemoteEvent") then
                remote.OnClientEvent:Connect(function()
                    -- Saat remote tembak dari server, paksa parry (Blatant = true flag)
                    checkAndParry(getgenv().AutoParry_Settings.Mode == "Blatant")
                end)
            end
        end
    end
    
    local killers = remotes:FindFirstChild("Killers")
    if killers then
        for _, remote in ipairs(killers:GetDescendants()) do
            if remote:IsA("RemoteEvent") and (string.find(string.lower(remote.Name), "m2") or string.find(string.lower(remote.Name), "attack")) then
                remote.OnClientEvent:Connect(function()
                    checkAndParry(getgenv().AutoParry_Settings.Mode == "Blatant")
                end)
            end
        end
    end
end

-- Deteksi Frame-by-Frame via Animasi (Hanya untuk Mode Legit)
task.spawn(function()
    while task.wait(0.05) do
        if getgenv().AutoParry_Settings.Enabled and getgenv().AutoParry_Settings.Mode == "Legit" then
            local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if myHrp then
                local baseRadius = getgenv().AutoParry_Settings.Distance
                for _, player in ipairs(Players:GetPlayers()) do
                    if isEnemy(player) then
                        local enemyHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if enemyHrp then
                            local dist = (myHrp.Position - enemyHrp.Position).Magnitude
                            -- Di mode Legit, asal jarak cukup dan animasi mulai, langsung eksekusi (rentan fake/bait)
                            if dist <= baseRadius and isAttackingAnim(player.Character) then
                                checkAndParry(false) -- False karena mode Legit tidak butuh strict check
                            end
                        end
                    end
                end
            end
        end
    end
end)


-- ==========================================
-- File: lib/fastvault.lua
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

getgenv().Survivor_Settings = getgenv().Survivor_Settings or {}
getgenv().Survivor_Settings.FastVault = false

RunService.Heartbeat:Connect(function()
    if getgenv().Survivor_Settings.FastVault then
        local char = LocalPlayer.Character
        if char then
            -- Force the 'Flowstate' attribute to true
            -- According to the game's vault script, having Flowstate while sprinting > 15.25 speed
            -- triggers the 'finessevault' animation and completely bypasses the hardcoded task.wait delays!
            char:SetAttribute("Flowstate", true)
        end
    end
end)


-- ==========================================
-- File: lib/autosprint.lua
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")

getgenv().Global_Settings = getgenv().Global_Settings or {}

local isHoldingShift = false

-- 1. Auto Sprint (Simulate holding Shift)
RunService.RenderStepped:Connect(function()
    if getgenv().Global_Settings.AutoSprint then
        local char = Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            -- If moving, hold shift. If standing still, release shift.
            if char.Humanoid.MoveDirection.Magnitude > 0.1 then
                if not UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    VIM:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
                    isHoldingShift = true
                end
            else
                if isHoldingShift then
                    VIM:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
                    isHoldingShift = false
                end
            end
        end
    else
        if isHoldingShift then
            VIM:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
            isHoldingShift = false
        end
    end
end)

-- 2. Speed Boost Slider (Bypassing penalties)
local oldNewIndex
oldNewIndex = hookmetamethod(game, "__newindex", function(self, key, value)
    if not checkcaller() then
        if key == "WalkSpeed" and self:IsA("Humanoid") then
            local character = self.Parent
            if character and character == Players.LocalPlayer.Character then
                local boost = getgenv().Global_Settings.WalkSpeedBoost or 0
                
                -- Only apply boost if we are actually allowed to move (value > 0)
                if type(value) == "number" and value > 0 and boost > 0 then
                    -- Add the raw slider value to whatever speed the game wants us to go
                    value = value + boost
                end
            end
        end
    end
    return oldNewIndex(self, key, value)
end)


-- ==========================================
-- File: lib/genbypass.lua
-- ==========================================
getgenv().GenBypass_Settings = getgenv().GenBypass_Settings or {
    Enabled = false
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RepairEvent

local function getRepairEvent()
    if RepairEvent then return RepairEvent end
    
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        local genFolder = remotes:FindFirstChild("Generator")
        if genFolder then
            RepairEvent = genFolder:FindFirstChild("RepairEvent")
        end
    end
    
    return RepairEvent
end

local activePoints = {}

-- Fungsi ini dipanggil dari main.lua saat toggle dimatikan,
-- atau saat player berhenti memperbaiki secara normal.
getgenv().CancelAllRepairs = function()
    local repEvent = getRepairEvent()
    if repEvent then
        for _, point in ipairs(activePoints) do
            if point and typeof(point) == "Instance" and point.Parent then
                pcall(function()
                    repEvent:FireServer(point, false)
                end)
            end
        end
    end
    activePoints = {}
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() then
        if method == "FireServer" or method == "fireServer" or method == "InvokeServer" then
            local repEvent = getRepairEvent()
            if repEvent and self == repEvent then
                local targetPoint = args[1]
                local status = args[2]
                
                if typeof(targetPoint) == "Instance" and targetPoint:IsA("BasePart") then
                    if status == true and getgenv().GenBypass_Settings.Enabled then
                        local generator = targetPoint.Parent
                        
                        -- Mencari model "Generator" utamanya
                        while generator and generator.Name ~= "Generator" and generator ~= game.Workspace do
                            generator = generator.Parent
                        end
                        
                        if generator and generator.Name == "Generator" then
                            -- Auto-fire ke titik lain di background
                            task.spawn(function()
                                for _, v in ipairs(generator:GetDescendants()) do
                                    if v:IsA("BasePart") and string.find(v.Name, "GeneratorPoint") and v ~= targetPoint then
                                        table.insert(activePoints, v)
                                        pcall(function()
                                            repEvent:FireServer(v, true)
                                        end)
                                    end
                                end
                            end)
                        end
                    elseif status == false then
                        -- Saat player batal/berhenti, bersihkan semua titik hantu (ghost points)
                        -- Ini akan selalu berjalan meskipun toggle sudah dimatikan, agar tidak nge-bug stuck.
                        getgenv().CancelAllRepairs()
                    end
                end
            end
        end
    end
    
    return oldNamecall(self, ...)
end)



-- ==========================================
-- File: lib/stalker.lua
-- ==========================================
if getgenv().StalkerHackLoaded then return end
getgenv().StalkerHackLoaded = true

getgenv().Stalker_Settings = {
    AutoStalkThroughWalls = false
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local StartStalking, StopStalking

task.spawn(function()
    local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
    if not Remotes then return end
    local Killers = Remotes:WaitForChild("Killers", 10)
    if not Killers then return end
    local Stalker = Killers:WaitForChild("Stalker", 10)
    if not Stalker then return end

    StartStalking = Stalker:WaitForChild("StartStalking", 10)
    StopStalking = Stalker:WaitForChild("StopStalking", 10)
end)

-- Auto Stalk Logic
local isStalking = false
local stalkTarget = nil

local function getTargetPlayer()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local bestTarget = nil
    local shortestDist = 100 -- Maksimal jarak bawaan game

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local targetHrp = p.Character:FindFirstChild("HumanoidRootPart")
            local targetHum = p.Character:FindFirstChild("Humanoid")

            if targetHrp and targetHum and targetHum.Health > 0 then
                -- Cek apakah target sedang di Hook/Digendong
                if not p.Character:GetAttribute("IsHooked") and not p.Character:GetAttribute("IsDead") then
                    local dist = (targetHrp.Position - hrp.Position).Magnitude
                    
                    if dist <= 100 then
                        -- Hanya gunakan pengecekan FOV Kamera (Arah pandang)
                        local lookVec = Camera.CFrame.LookVector.Unit
                        local dirToTarget = (targetHrp.Position - Camera.CFrame.Position).Unit
                        local dot = lookVec:Dot(dirToTarget)

                        if dot > 0.8 and dist < shortestDist then
                            bestTarget = p
                            shortestDist = dist
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

-- Menyadap saat player menahan klik kanan (Stalk)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if not getgenv().Stalker_Settings.AutoStalkThroughWalls then return end
    
    -- Cek jika kita sedang jadi Killer (Stalker)
    if not (LocalPlayer.Team and LocalPlayer.Team.Name == "Killer") then return end
    if not StartStalking or not StopStalking then return end

    if input.UserInputType == Enum.UserInputType.MouseButton2 or (input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.ButtonL1) then
        isStalking = true
        
        task.spawn(function()
            while isStalking do
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("CheckInterractable") then break end
                
                -- Jika karakter sedang melakukan aksi atau max stage, berhenti
                if char:GetAttribute("Stage") == 2 or char:GetAttribute("Stage") == 3 then break end
                
                local target = getTargetPlayer()
                if target then
                    if stalkTarget ~= target then
                        stalkTarget = target
                        StartStalking:FireServer(stalkTarget)
                    end
                else
                    if stalkTarget then
                        StopStalking:FireServer()
                        stalkTarget = nil
                    end
                end
                
                task.wait(0.1)
            end
            
            -- Jika loop selesai / tombol dilepas
            if stalkTarget then
                StopStalking:FireServer()
                stalkTarget = nil
            end
        end)
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if input.UserInputType == Enum.UserInputType.MouseButton2 or (input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.ButtonL1) then
        isStalking = false
    end
end)

-- Modifikasi untuk mobile UI Button
task.spawn(function()
    while task.wait(1) do
        if getgenv().Stalker_Settings.AutoStalkThroughWalls then
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            if pg then
                local slasherMob = pg:FindFirstChild("Slasher-mob")
                if slasherMob and slasherMob:FindFirstChild("Controls") then
                    local move1 = slasherMob.Controls:FindFirstChild("move1")
                    if move1 and not move1:GetAttribute("StalkerHackHooked") then
                        move1:SetAttribute("StalkerHackHooked", true)
                        
                        move1.MouseButton1Down:Connect(function()
                            if getgenv().Stalker_Settings.AutoStalkThroughWalls and LocalPlayer.Team and LocalPlayer.Team.Name == "Killer" then
                                if not StartStalking or not StopStalking then return end
                                isStalking = true
                                -- Same loop logic as above
                                task.spawn(function()
                                    while isStalking do
                                        local char = LocalPlayer.Character
                                        if not char or not char:FindFirstChild("CheckInterractable") then break end
                                        if char:GetAttribute("Stage") == 2 or char:GetAttribute("Stage") == 3 then break end
                                        
                                        local target = getTargetPlayer()
                                        if target then
                                            if stalkTarget ~= target then
                                                stalkTarget = target
                                                StartStalking:FireServer(stalkTarget)
                                            end
                                        else
                                            if stalkTarget then
                                                StopStalking:FireServer()
                                                stalkTarget = nil
                                            end
                                        end
                                        task.wait(0.1)
                                    end
                                    if stalkTarget then StopStalking:FireServer(); stalkTarget = nil end
                                end)
                            end
                        end)
                        
                        UserInputService.InputEnded:Connect(function(input, gpe)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                isStalking = false
                            end
                        end)
                    end
                end
            end
        end
    end
end)


-- ==========================================
-- END BUNDLED LIBRARIES
-- ==========================================

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
getgenv().ProjectESP_Library = Library
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
	Title = "Maika Hub",
	Footer = "version: 1.0",
	Icon = 122601226403829,
	NotifySide = "Right",
	ShowCustomCursor = true,
})

local Tabs = {
	Global = Window:AddTab("Global", "globe"),
	Visuals = Window:AddTab("Visuals", "eye"),
	Survivor = Window:AddTab("Survivor", "shield"),
	Killer = Window:AddTab("Killer", "swords"),
	Misc = Window:AddTab("Misc", "wrench"),
	["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

local GlobalGroup = Tabs.Global:AddLeftGroupbox("Global Settings", "globe")

GlobalGroup:AddToggle("ToggleAutoSprint", {
	Text = "Auto Sprint",
	Tooltip = "Automatically holds sprint key",
	Default = false,
	Callback = function(Value)
		getgenv().Global_Settings = getgenv().Global_Settings or {}
		getgenv().Global_Settings.AutoSprint = Value
	end,
})

GlobalGroup:AddSlider("WalkSpeedSlider", {
	Text = "Speed Boost",
	Default = 0,
	Min = 0,
	Max = 100,
	Rounding = 0,
	Compact = false,
	Callback = function(Value)
		getgenv().Global_Settings = getgenv().Global_Settings or {}
		getgenv().Global_Settings.WalkSpeedBoost = Value
	end,
})


local SilentAimGroup = Tabs.Survivor:AddLeftGroupbox("Silent Aim", "crosshair")
SilentAimGroup:AddToggle("ToggleSilentAim", {
	Text = "Enable Silent Aim",
	Tooltip = "Redirect bullets automatically to target",
	Default = false,
	Callback = function(Value)
		getgenv().SilentAim_Settings.Enabled = Value
	end,
})
local VeilGroup = Tabs.Survivor:AddRightGroupbox("Killer Veil", "spear")
VeilGroup:AddToggle("ToggleVeilAim", {
	Text = "Veil Spear Aimbot",
	Tooltip = "Aimbot for Killer Veil spear throw",
	Default = false,
	Callback = function(Value)
		getgenv().VeilAim_Settings.Enabled = Value
	end,
})

SilentAimGroup:AddDropdown("SilentAimTargetTeam", {
	Values = { "Killer", "Team", "Both" },
	Default = "Killer",
	Multi = false,
	Text = "Target Type",
	Callback = function(Value)
		getgenv().SilentAim_Settings.TargetTeam = Value
	end,
})

SilentAimGroup:AddDropdown("SilentAimTargetPart", {
	Values = { "Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso", "Right Arm", "Left Arm", "Right Leg", "Left Leg" },
	Default = "HumanoidRootPart",
	Multi = false,
	Text = "Target Part",
	Callback = function(Value)
		getgenv().SilentAim_Settings.TargetPart = Value
	end,
})

SilentAimGroup:AddToggle("ToggleFOV", {
	Text = "Show FOV Circle",
	Default = false,
	Callback = function(Value)
		getgenv().SilentAim_Settings.ShowFOV = Value
	end,
}):AddColorPicker("FOVColorPicker", {
	Default = Color3.fromRGB(255, 255, 255),
	Title = "FOV Color",
	Callback = function(Value)
		getgenv().SilentAim_Settings.FOVColor = Value
	end,
})

SilentAimGroup:AddSlider("FOVSlider", {
	Text = "FOV Radius",
	Default = 100,
	Min = 10,
	Max = 800,
	Rounding = 0,
	Compact = false,
	Callback = function(Value)
		getgenv().SilentAim_Settings.FOV = Value
	end,
})

local CrosshairGroup = Tabs.Survivor:AddRightGroupbox("Crosshair", "crosshair")
CrosshairGroup:AddToggle("ToggleCrosshair", {
	Text = "Show Crosshair",
	Default = false,
	Callback = function(Value)
		getgenv().SilentAim_Settings.ShowCrosshair = Value
	end,
})

local AutoParryGroup = Tabs.Survivor:AddRightGroupbox("Auto Parry", "shield")
AutoParryGroup:AddToggle("ToggleAutoParry", {
	Text = "Enable Auto Parry",
	Tooltip = "Automatically parry killer attacks",
	Default = false,
	Callback = function(Value)
		getgenv().AutoParry_Settings.Enabled = Value
	end,
})

AutoParryGroup:AddDropdown("AutoParryMode", {
	Values = { "Legit", "Blatant" },
	Default = "Legit",
	Multi = false,
	Text = "Parry Mode",
	Tooltip = "Legit is fast but vulnerable to bait. Blatant is strictly accurate.",
	Callback = function(Value)
		getgenv().AutoParry_Settings.Mode = Value
	end,
})

AutoParryGroup:AddSlider("AutoParryDistance", {
	Text = "Parry Distance",
	Default = 10,
	Min = 5,
	Max = 30,
	Rounding = 1,
	Compact = false,
	Callback = function(Value)
		getgenv().AutoParry_Settings.Distance = Value
	end,
})

AutoParryGroup:AddSlider("AutoParrySensitivity", {
	Text = "Parry Delay",
	Default = 0,
	Min = 0,
	Max = 1000,
	Rounding = 0,
	Compact = false,
	Callback = function(Value)
		getgenv().AutoParry_Settings.Sensitivity = Value
	end,
})

AutoParryGroup:AddToggle("ToggleParryCircle", {
	Text = "Show Distance Circle",
	Default = false,
	Callback = function(Value)
		getgenv().AutoParry_Settings.ShowCircle = Value
	end,
}):AddColorPicker("ParryCircleColor", {
	Default = Color3.fromRGB(255, 255, 255),
	Title = "Circle Color",
	Transparency = 0,
	Callback = function(Value, Transparency)
		getgenv().AutoParry_Settings.CircleColor = Value
        if type(Transparency) == "number" then
		    getgenv().AutoParry_Settings.CircleTransparency = Transparency
        end
	end,
})

Options.ParryCircleColor:OnChanged(function()
	getgenv().AutoParry_Settings.CircleColor = Options.ParryCircleColor.Value
	getgenv().AutoParry_Settings.CircleTransparency = Options.ParryCircleColor.Transparency
end)

local PlayerEspGroup = Tabs.Visuals:AddLeftGroupbox("Player ESP", "eye")

PlayerEspGroup:AddToggle("ToggleESP", {
	Text = "Enabled",
	Tooltip = "Master switch for player ESP",
	Default = false,
	Callback = function(Value)
		getgenv().ESP_Settings.Enabled = Value
	end,
})

PlayerEspGroup:AddToggle("ToggleName", {
	Text = "Show Names",
	Default = false,
	Callback = function(Value)
		getgenv().ESP_Settings.ShowName = Value
	end,
})

PlayerEspGroup:AddToggle("ToggleTeam", {
	Text = "Show Teams",
	Default = false,
	Callback = function(Value)
		getgenv().ESP_Settings.ShowTeam = Value
	end,
})

PlayerEspGroup:AddToggle("ToggleUseTeamColor", {
	Text = "Use Team Color",
	Tooltip = "Use team color instead of custom color",
	Default = true,
	Callback = function(Value)
		getgenv().ESP_Settings.UseTeamColor = Value
	end,
}):AddColorPicker("PlayerColorPicker", {
	Default = Color3.fromRGB(255, 0, 0),
	Title = "Custom Color",
	Transparency = 1,
	Callback = function(Value, Transparency)
		getgenv().ESP_Settings.PlayerColor = Value
        if type(Transparency) == "number" then
		    getgenv().ESP_Settings.PlayerTransparency = Transparency
        end
	end,
})

local GenEspGroup = Tabs.Visuals:AddRightGroupbox("Generator ESP", "zap")

GenEspGroup:AddToggle("ToggleGenerators", {
	Text = "Show Generators",
	Tooltip = "Draw ESP for generators",
	Default = false,
	Callback = function(Value)
		getgenv().ESP_Settings.ShowGenerators = Value
	end,
}):AddColorPicker("GenColorPicker", {
	Default = Color3.fromRGB(255, 255, 0),
	Title = "Generator Color",
	Transparency = 0.5,
	Callback = function(Value, Transparency)
		getgenv().ESP_Settings.GeneratorColor = Value
        if type(Transparency) == "number" then
		    getgenv().ESP_Settings.GeneratorTransparency = Transparency
        end
	end,
})

GenEspGroup:AddToggle("ToggleGenDistance", {
	Text = "Show Distance",
	Tooltip = "Show distance to generator",
	Default = false,
	Callback = function(Value)
		getgenv().ESP_Settings.ShowGeneratorDistance = Value
	end,
})

Options.PlayerColorPicker:OnChanged(function()
	getgenv().ESP_Settings.PlayerColor = Options.PlayerColorPicker.Value
	getgenv().ESP_Settings.PlayerTransparency = Options.PlayerColorPicker.Transparency
end)

Options.GenColorPicker:OnChanged(function()
	getgenv().ESP_Settings.GeneratorColor = Options.GenColorPicker.Value
	getgenv().ESP_Settings.GeneratorTransparency = Options.GenColorPicker.Transparency
end)

local PalletEspGroup = Tabs.Visuals:AddRightGroupbox("Pallet ESP", "square")

PalletEspGroup:AddToggle("TogglePallets", {
	Text = "Show Pallets",
	Tooltip = "Draw ESP for pallets",
	Default = false,
	Callback = function(Value)
		getgenv().ESP_Settings.ShowPallets = Value
	end,
}):AddColorPicker("PalletColorPicker", {
	Default = Color3.fromRGB(0, 255, 255),
	Title = "Pallet Color",
	Transparency = 0.5,
	Callback = function(Value, Transparency)
		getgenv().ESP_Settings.PalletColor = Value
        if type(Transparency) == "number" then
		    getgenv().ESP_Settings.PalletTransparency = Transparency
        end
	end,
})

PalletEspGroup:AddToggle("TogglePalletDistance", {
	Text = "Show Distance",
	Tooltip = "Show distance to pallet",
	Default = false,
	Callback = function(Value)
		getgenv().ESP_Settings.ShowPalletDistance = Value
	end,
})

Options.PalletColorPicker:OnChanged(function()
	getgenv().ESP_Settings.PalletColor = Options.PalletColorPicker.Value
	getgenv().ESP_Settings.PalletTransparency = Options.PalletColorPicker.Transparency
end)

local AbilitiesGroup = Tabs.Survivor:AddLeftGroupbox("Abilities", "zap")
AbilitiesGroup:AddToggle("ToggleAutoSkillCheck", {
	Text = "Auto Skill Check",
	Tooltip = "Automatically hits Great",
	Default = false,
	Callback = function(Value)
		getgenv().Survivor_Settings.AutoSkillCheck = Value
	end,
})

AbilitiesGroup:AddToggle("ToggleFastVault", {
	Text = "Fast Vault",
	Tooltip = "Always perform fastest vault animation",
	Default = false,
	Callback = function(Value)
		getgenv().Survivor_Settings.FastVault = Value
	end,
})

local BypassGroup = Tabs.Survivor:AddRightGroupbox("Exploits", "zap")
BypassGroup:AddToggle("ToggleGenBypass", {
	Text = "Multi Repair Bypass",
	Tooltip = "Repair multiple points while moving",
	Default = false,
	Callback = function(Value)
        getgenv().GenBypass_Settings = getgenv().GenBypass_Settings or {}
		getgenv().GenBypass_Settings.Enabled = Value
        
        if not Value and getgenv().CancelAllRepairs then
            getgenv().CancelAllRepairs()
        end
	end,
})



local StalkerGroup = Tabs.Killer:AddLeftGroupbox("Myers", "eye")

StalkerGroup:AddToggle("ToggleStalkWalls", {
	Text = "Stalk Through Walls",
	Tooltip = "Stalk survivors behind walls",
	Default = false,
	Callback = function(Value)
        getgenv().Stalker_Settings = getgenv().Stalker_Settings or {}
		getgenv().Stalker_Settings.AutoStalkThroughWalls = Value
	end,
})

local MiscGroup = Tabs.Misc:AddLeftGroupbox("Miscellaneous", "wrench")


MiscGroup:AddButton({
	Text = "Rejoin Server",
	Func = function()
		local ts = game:GetService("TeleportService")
		local p = game:GetService("Players").LocalPlayer
		if #game.Players:GetPlayers() <= 1 then
			p:Kick("Rejoining a 1-player server will fail because it shuts down.")
			task.wait()
		end
		ts:TeleportToPlaceInstance(game.PlaceId, game.JobId, p)
	end,
	DoubleClick = true,
	Tooltip = "Rejoin the exact same server"
})

MiscGroup:AddButton({
	Text = "Respawn Character",
	Func = function()
		local p = game:GetService("Players").LocalPlayer
		if p.Character and p.Character:FindFirstChild("Humanoid") then
			p.Character.Humanoid.Health = 0
		end
	end,
	DoubleClick = false,
	Tooltip = "Kill your character instantly"
})

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Open Keybind Menu",
	Callback = function(value)
		Library.KeybindFrame.Visible = value
	end,
})
MenuGroup:AddToggle("ShowCustomCursor", {
	Text = "Custom Cursor",
	Default = Library.ShowCustomCursor,
	Callback = function(Value)
		Library.ShowCustomCursor = Value
	end,
})
MenuGroup:AddDropdown("NotificationSide", {
	Values = { "Left", "Right" },
	Default = "Right",
	Text = "Notification Side",
	Callback = function(Value)
		Library:SetNotifySide(Value)
	end,
})
MenuGroup:AddDropdown("DPIDropdown", {
	Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
	Default = "100%",
	Text = "DPI Scale",
	Callback = function(Value)
		Value = Value:gsub("%%", "")
		local DPI = tonumber(Value)
		Library:SetDPIScale(DPI)
	end,
})
MenuGroup:AddSlider("UICornerSlider", {
	Text = "Corner Radius",
	Default = Library.CornerRadius,
	Min = 0,
	Max = 20,
	Rounding = 0,
	Callback = function(value)
		Window:SetCornerRadius(value)
	end
})
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightControl", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddButton("Unload", function()
	Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind 

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("ProjectESP")
SaveManager:SetFolder("ProjectESP/config")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()

task.spawn(function()
	local RunService = game:GetService("RunService")
	local Players = game:GetService("Players")
	
	RunService.RenderStepped:Connect(function()
		if getgenv().Survivor_Settings and getgenv().Survivor_Settings.AutoSprint then
			local p = Players.LocalPlayer
			if p and p.Character and p.Character:FindFirstChild("Humanoid") then
                local hum = p.Character.Humanoid
                if hum.Health > 0 and hum.MoveDirection.Magnitude > 0 then
                    hum.WalkSpeed = 16
                end
			end
		end
	end)
end)



print("[System] Maika Hub UI Successfully Loaded!")
