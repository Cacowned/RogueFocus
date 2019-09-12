----------------------------------------------------------------------------------------------------
-- Rogue Focus: Core
----------------------------------------------------------------------------------------------------
local _G = getfenv(0)

RogueFocus = {
	Version = "1.0.4",
	Lock = 1,
	Class = "",
	InCombat = false,
	InStealth = false,
	InOther = false,
	Registered = false
}

local RogueFocusFrames = {}
local RogueFocusStealth = {
	["Interface\\Icons\\Ability_Stealth"] = true,
	["Interface\\Icons\\Ability_Ambush"] = true,
	["Interface\\Icons\\ability_druid_prowl"] = true
}

local RogueFocus_Energy = {
	Length = 2,
	Alpha = 0.2,
	Start = 0,
	End = 0,
	Mana = nil,
}

local RogueFocus_Default = {
	Scale = 1.0,
	InCombat = true,
	InStealth = true,
	InOther = true,
	Audible = false,
	Locked = false,
}

----------------------------------------------------------------------------------------------------
-- Widgets Handlers
----------------------------------------------------------------------------------------------------
function RogueFocus:OnLoad()
	localizedClass, RogueFocus.Class = UnitClass("player")
	RogueFocus.Registered = RogueFocus:RegisterEvents()
	if((not RogueFocusConfig) or (not RogueFocusConfig.Version) or (RogueFocusConfig.Version ~= RogueFocus.Version)) then
		RogueFocusConfig = RogueFocus_Default
	end
	RogueFocus.InCombat = false
	RogueFocus.InStealth = RogueFocus:inStealth()
	function GetChildrenTree(Frame) --- Walk the frame hierarchy recursively adding children.
		if Frame:GetChildren() then
			for _,child in pairs({Frame:GetChildren()}) do
				if child:IsMouseEnabled() then
					tinsert(RogueFocusFrames,child)
				end
				GetChildrenTree(child)
			end 
		end
	end
	GetChildrenTree(RogueFocusFrame)
	
	RogueFocus:Toggle()
	-- It seems that all has gone well till now. Hi there!
	DEFAULT_CHAT_FRAME:AddMessage(ROGUEFOCUS_WELCOME)
	
end

function RogueFocus:OnEvent(eventArg)
	if(not RogueFocus.Registered) then return end
	if(eventArg == "VARIABLES_LOADED") then

		if(RogueFocus.Registered) then
			-- Scaling
			RogueFocusFrame:SetScale(RogueFocusConfig.Scale)
			-- Combo, Energy
			local Frame
			for i = 1, 5, 1 do
				Frame = _G["RogueFocusCombo"..i]
				Frame:SetStatusBarColor(1, 0, 0)
				Frame:SetMinMaxValues(0, 1)
				Frame:SetValue(0)
			end
			-- Energy ticks
			RogueFocus_Energy.Mana = UnitPower("player", Enum.PowerType.Energy)
			-- Energy ticks text
			RogueFocusEnergyTickText:SetText(ROGUEFOCUS_ENERGY)
			-- Create slash events
			SLASH_ROGUEFOCUS1 = "/rfc"
			SLASH_ROGUEFOCUS2 = "/roguefocus"
			SlashCmdList["ROGUEFOCUS"] = function() RogueFocusOptions:Handler() end
		end
		
	elseif (UnitIsDeadOrGhost("player")) then
		RogueFocus.InCombat = false
		RogueFocus:UpdateEnergyBar()
		RogueFocusFrame:Hide()

	elseif ((eventArg == "PLAYER_AURAS_CHANGED") 
		or ((eventArg == "UNIT_AURA") and (arg1 == "player"))
		or (eventArg == "UPDATE_SHAPESHIFT_FORMS")
		or (eventArg == "UPDATE_BONUS_ACTIONBAR")
		or (eventArg == "UNIT_DISPLAYPOWER")) then
		RogueFocus.InStealth = RogueFocus:inStealth()
		RogueFocus:Toggle()
	
	elseif (eventArg == "UNIT_POWER_UPDATE") then
		RogueFocus:UpdateComboBar()
		RogueFocus:UpdateEnergyBar()

	elseif(((eventArg == "UNIT_ENERGY") or (eventArg == "UNIT_MAXENERGY")) and (arg1 == "player")) then
		RogueFocus:UpdateEnergyBar()
		
	elseif(eventArg == "PLAYER_REGEN_DISABLED") then
		RogueFocus.InCombat = true 
		RogueFocus:Toggle()
		
	elseif(eventArg == "PLAYER_REGEN_ENABLED") then
		RogueFocus.InCombat = false 
		RogueFocus:Toggle()
		
	elseif(eventArg == "PLAYER_ENTERING_WORLD") then 
		RogueFocus:Toggle()
		
	elseif(eventArg == "PLAYER_DEAD") then
		RogueFocus.InCombat = false
		RogueFocus:Toggle()
		
	end
end

function RogueFocus:OnUpdate()
	if(RogueFocus.Registered) then
		local energy = UnitPower("player", Enum.PowerType.Energy)
		local currentTime = GetTime()
		local sparkPosition = 1
		
		if(energy > RogueFocus_Energy.Mana or currentTime >= RogueFocus_Energy.End) then
			RogueFocus_Energy.Mana = energy
			RogueFocus_Energy.Start = currentTime
			RogueFocus_Energy.End = currentTime + RogueFocus_Energy.Length
			if (RogueFocusConfig.Audible) then PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON ) end
		else
			if(RogueFocus_Energy.Mana ~= energy) then
				RogueFocus_Energy.Mana = energy
			end
			sparkPosition = ((currentTime - RogueFocus_Energy.Start) / (RogueFocus_Energy.End - RogueFocus_Energy.Start)) * 99
		end
		
		RogueFocusEnergyTickBar:SetMinMaxValues(RogueFocus_Energy.Start, RogueFocus_Energy.End)
		RogueFocusEnergyTickBar:SetValue(currentTime)
		if(sparkPosition < 1) then
			sparkPosition = 1
		end
		RogueFocusEnergyTickSpark:SetPoint("CENTER", "RogueFocusEnergyTickBar", "LEFT", sparkPosition, 0)
	end
end

----------------------------------------------------------------------------------------------------
-- Events Handlers
----------------------------------------------------------------------------------------------------
function RogueFocus:UpdateComboBar()
	local c = UnitPower("player", Enum.PowerType.ComboPoints)
	local comboBar = {0, 0, 0, 0, 0}
	local barColor = {[0] = {1, 0, 0}, {1, 0, 0}, {1, 0, 0}, {1, 1, 0}, {1, 1, 0}, {0, 1, 0}}
	local Frame
	for i = 1, c, 1 do
		comboBar[i] = 1
	end
	for i = 1, 5, 1 do
		Frame = _G["RogueFocusCombo"..i]
		Frame:SetStatusBarColor(barColor[c][1], barColor[c][2], barColor[c][3])
		Frame:SetValue(comboBar[i])
	end
end

-- Author: Masso
function RogueFocus:UpdateEnergyBar()
	local value, max =  UnitPower("player", Enum.PowerType.Energy), UnitPowerMax("player", Enum.PowerType.Energy)
	local text = value.." / "..max
	local Frame = _G["RogueFocusEnergyBar"]
	Frame:SetMinMaxValues(0, max)
	Frame:SetValue(value)
	RogueFocusEnergyText:SetText(text)
end

function RogueFocus:Toggle()
	-- first of all: is he a rogue or a druid cat? No? HIDE!
	if (not(RogueFocus:IsSupported())) then
		RogueFocusFrame:Hide()
	-- second: check the show cases. Is he in combat and the combat option is checked? SHOW!
	elseif (RogueFocus.InCombat and RogueFocusConfig.InCombat) then
		RogueFocusFrame:Show()
	-- third: check the show cases. Is he in stealth and the stealth option is checked? SHOW!
	elseif (RogueFocus.InStealth and RogueFocusConfig.InStealth) then
		RogueFocusFrame:Show()
	-- fourth: check the show cases. Now he's not in combat nor in stealth so he's in the other cases. Is the other cases option checked? SHOW!
	elseif (RogueFocusConfig.InOther and not(RogueFocus.InCombat) and not(RogueFocus.InStealth)) then
		RogueFocusFrame:Show()
	-- fifth: there are no more cases! So now? HIDE!
	else
		RogueFocusFrame:Hide()
	end
	-- check lock status and enable/disable mouse.
	if RogueFocusFrame:IsVisible() then
		if RogueFocusConfig.Locked then
			RogueFocusFrame:EnableMouse(false)
			for _,childframe in pairs (RogueFocusFrames) do
				childframe:EnableMouse(false)
			end
		else
			RogueFocusFrame:EnableMouse(true)
			for _,childframe in pairs (RogueFocusFrames) do
				childframe:EnableMouse(true)
			end		
		end
	end
end

----------------------------------------------------------------------------------------------------
-- Main
----------------------------------------------------------------------------------------------------
function RogueFocus:RegisterEvents()
	if(RogueFocus.Class ~= "ROGUE" and RogueFocus.Class ~= "DRUID") then
		-- self:UnregisterEvent("PLAYER_COMBO_POINTS")
		-- self:UnregisterEvent("PLAYER_AURAS_CHANGED")
		-- self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		-- self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		-- self:UnregisterEvent("PLAYER_DEAD")
		self:UnregisterEvent("UNIT_DISPLAYPOWER")
		-- self:UnregisterEvent("UNIT_MAXENERGY")
		-- self:UnregisterEvent("UNIT_AURA")
		-- self:UnregisterEvent("UPDATE_SHAPESHIFT_FORMS")
		-- self:UnregisterEvent("UPDATE_BONUS_ACTIONBAR")
		self:UnregisterEvent("UNIT_POWER_UPDATE")
		self:UnregisterEvent("VARIABLES_LOADED")
		return false
	else
		-- self:RegisterForDrag("LeftButton")
		-- RogueFocusFrame:RegisterEvent("PLAYER_COMBO_POINTS")
		-- RogueFocusFrame:RegisterEvent("PLAYER_AURAS_CHANGED")
		-- RogueFocusFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
		-- RogueFocusFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
		RogueFocusFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
		-- RogueFocusFrame:RegisterEvent("PLAYER_DEAD")
		RogueFocusFrame:RegisterEvent("UNIT_DISPLAYPOWER")
		-- RogueFocusFrame:RegisterEvent("UNIT_MAXENERGY")
		-- RogueFocusFrame:RegisterEvent("UNIT_AURA")
		-- RogueFocusFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
		-- RogueFocusFrame:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
		RogueFocusFrame:RegisterEvent("UNIT_POWER_UPDATE")
		RogueFocusFrame:RegisterEvent("VARIABLES_LOADED")
		return true
	end
end

function RogueFocus:IsSupported()
	 if ( UnitPowerType("player") == 3 ) then
   		return true
	else
		return false
	end
end

function RogueFocus:inStealth()
	return IsStealthed()
end
