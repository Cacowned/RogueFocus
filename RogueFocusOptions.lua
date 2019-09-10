----------------------------------------------------------------------------------------------------
-- Rogue Focus: Options
----------------------------------------------------------------------------------------------------
RogueFocusOptions = { };

local _G = getfenv(0);

----------------------------------------------------------------------------------------------------
-- Widgets Handlers
----------------------------------------------------------------------------------------------------
function RogueFocusOptions:Handler()
	if(RogueFocusOptionsFrame:IsVisible()) then
		HideUIPanel(RogueFocusOptionsFrame);
	else
		ShowUIPanel(RogueFocusOptionsFrame);
	end
end

----------------------------------------------------------------------------------------------------
-- Scaling
----------------------------------------------------------------------------------------------------
local function RogueFocusOptionsScaleSlider_Init(self)
	if(not RogueFocusOptions.scaleSliderLoaded) then
		local Text, Low, Full;
		Text = _G[self:GetName().."Text"];
		Low = _G[self:GetName().."Low"];
		High = _G[self:GetName().."High"];
		
		Text:SetText(ROGUEFOCUS_SCALE);
		Low:SetText(ROGUEFOCUS_LOW);
		High:SetText(ROGUEFOCUS_HIGH);
		
		self:SetMinMaxValues(1.0, 2.0);
		self:SetValueStep(.1);
		
		RogueFocusOptions.scaleSliderLoaded = true;
	end
	local value = format("%.1f", RogueFocusConfig.Scale);
	_G[self:GetName().."Value"]:SetText(value);
	RogueFocusFrame:SetScale(RogueFocusConfig.Scale);
end

function RogueFocusOptions:ScaleSlider_OnShow(self)
	RogueFocusOptionsScaleSlider_Init(self);
	self:SetValue(RogueFocusConfig.Scale);
end

function RogueFocusOptions:ScaleSlider_OnValueChanged(self)
	RogueFocusConfig.Scale = self:GetValue();
	RogueFocusOptionsScaleSlider_Init(self);
end

----------------------------------------------------------------------------------------------------
-- Combat
----------------------------------------------------------------------------------------------------
function RogueFocusOptions:CombatCheckButton_OnShow(self)
	self:SetChecked(RogueFocusConfig.InCombat);
end

function RogueFocusOptions:StealthCheckButton_OnShow(self)
	self:SetChecked(RogueFocusConfig.InStealth);
end

function RogueFocusOptions:OtherCheckButton_OnShow(self)
	self:SetChecked(RogueFocusConfig.InOther);
end

function RogueFocusOptions:CombatCheckButton_OnClick(self)
	if(self:GetChecked()) then
		RogueFocusConfig.InCombat = true;
	else
		RogueFocusConfig.InCombat = false;
	end
	RogueFocus:Toggle();
end

function RogueFocusOptions:StealthCheckButton_OnClick(self)
	if(self:GetChecked()) then
		RogueFocusConfig.InStealth = true;
	else
		RogueFocusConfig.InStealth = false;
	end
	RogueFocus:Toggle();
end

function RogueFocusOptions:OtherCheckButton_OnClick(self)
	if(self:GetChecked()) then
		RogueFocusConfig.InOther = true;
	else
		RogueFocusConfig.InOther = false;
	end
	RogueFocus:Toggle();
end

----------------------------------------------------------------------------------------------------
-- Audio & Locking
----------------------------------------------------------------------------------------------------

function RogueFocusOptions:AudioCheckButton_OnShow(self)
	self:SetChecked(RogueFocusConfig.Audible);
end

function RogueFocusOptions:AudioCheckButton_OnClick(self)
	if(self:GetChecked()) then
		RogueFocusConfig.Audible = true;
	else
		RogueFocusConfig.Audible = false;
	end
	RogueFocus:Toggle();
end

function RogueFocusOptions:LockCheckButton_OnShow(self)
	self:SetChecked(RogueFocusConfig.Locked);
end

function RogueFocusOptions:LockCheckButton_OnClick(self)
	if(self:GetChecked()) then
		RogueFocusConfig.Locked = true;
	else
		RogueFocusConfig.Locked = false;
	end
	RogueFocus:Toggle();
end
