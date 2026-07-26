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

-- ========================================================
-- [DIPERBAIKI] AUTO-DOWNLOAD LIBRARIES DARI GITHUB
-- ========================================================
local myRepo = "https://raw.githubusercontent.com/MaikaVerse/MaikaHub/refs/heads/main/"
local libs = {
    "lib/esp.lua",
    "lib/skillcheck.lua",
    "lib/silentaim.lua",
    "lib/veilaim.lua",
    "lib/autoparry.lua",
    "lib/fastvault.lua",
    "lib/autosprint.lua",
    "lib/genbypass.lua",
    "lib/stalker.lua"
}

for _, libPath in ipairs(libs) do
    local success, err = pcall(function()
        loadstring(game:HttpGet(myRepo .. libPath))()
    end)
    if not success then
        warn("[Maika Hub] Failed to load " .. libPath .. " | Error: " .. tostring(err))
    end
end
-- ========================================================


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
