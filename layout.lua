--[[
--
-- oUF_Tsigo
--
-- Custom layout for oUF.
-- Based on Caith's PitBull layout - http://www.bellum-potentiae.de/forum/viewtopic.php?t=3674
-- by tsigo@tsigo.org
--
--LibStub("AceConsole-2.0"):PrintLiteral(...)

TODO
--]]

-- Settings --------------------------------------------------------------------
local statusbarTexture, font
local borderTexture = "Interface\\AddOns\\oUF_Tsigo\\media\\border"
local fontSize = 16

--local LSM = LibStub("LibSharedMedia-3.0", true)
if LSM then
	statusbarTexture = LSM:Fetch("statusbar", "Armory")
	font = LSM:Fetch("font", "oUF_Rabbit")
else
	statusbarTexture = "Interface\\AddOns\\oUF_Tsigo\\media\\armory"
	font = "Interface\\AddOns\\oUF_Tsigo\\media\\font.ttf"
end

local playerClass = select(2, UnitClass("player")) -- combopoints for druid/rogue
local playerName = UnitName("player")

local menu = function(self)
	local unit = self.unit:sub(1, -2)
	local cunit = self.unit:gsub("(.)", string.upper, 1)

	if unit == "party" or unit == "partypet" then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor", 0, 0)
	elseif _G[cunit.."FrameDropDown"] then
		ToggleDropDownMenu(1, nil, _G[cunit.."FrameDropDown"], "cursor", 0, 0)
	end
end

local function ColorGradient(perc, ...)
	if perc >= 1 then
		local r, g, b = select(select('#', ...) - 2, ...)
		return r, g, b
	elseif perc <= 0 then
		local r, g, b = ...
		return r, g, b
	end
	
	local num = select('#', ...) / 3

	local segment, relperc = math.modf(perc*(num-1))
	local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)

	return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
end

local select = select
--local UnitName = UnitName
local UnitLevel = UnitLevel
local UnitClass = UnitClass
local UnitIsDead = UnitIsDead
local UnitIsGhost = UnitIsGhost
local UnitIsPlayer = UnitIsPlayer
local UnitIsTapped = UnitIsTapped
local UnitRace = UnitRace
local UnitReaction = UnitReaction
local UnitPowerType = UnitPowerType
local UnitIsConnected = UnitIsConnected
local UnitIsTappedByPlayer = UnitIsTappedByPlayer
local UnitClassification = UnitClassification
local UnitCreatureType = UnitCreatureType

-- Custom colors --------------------------------------------------------------

oUF.colors.class = {
    ["DEATHKNIGHT"] = { 196/255, 30/255,  59/255 },
	["DRUID"]       = { 255/255, 124/255, 10/255 },
	["HUNTER"]      = { 163/255, 251/255, 131/255 },
	["MAGE"]        = { 123/255, 203/255, 254/255 },
	["PALADIN"]     = { 245/255, 137/255, 186/255 },
	["PRIEST"]      = { 194/255, 252/255, 254/255 },
	["ROGUE"]       = { 255/255, 241/255, 106/255 },
	["SHAMAN"]      = { 0/255,   254/255, 255/255 },	-- Caith's Shaman color
	--["SHAMAN"]    = { 6/255,   60/255,  188/255 },	-- More traditional Shaman blue
	["WARLOCK"]     = { 187/255, 162/255, 254/255 },
	["WARRIOR"]     = { 210/255, 188/255, 149/255 },
}

oUF.colors.power = {
	['MANA'] = { 146/255, 196/255, 249/255 }, -- Mana
	['RAGE'] = { 160/255, 96/255,  97/255  }, -- Rage
	['FOCUS'] = { 202/255, 181/255, 126/255 }, -- Focus
	['ENERGY'] = { 228/255, 218/255, 167/255 }, -- Energy
	['FOCUS'] = { 0, 1, 1} -- Focus
}

local health = {
	[0] = { r = 255/255, g = 66/255,  b = 42/255 }, -- Red
	[1] = { r = 195/255, g = 252/255, b = 0/255 },  -- Yellow-ish
	[2] = { r = 34/255,  g = 250/255, b = 42/255 }, -- Green
}

local UnitReactionColor = {
	[1] = { 219/255, 48/255,  41/255 }, -- Hated
	[2] = { 219/255, 48/255,  41/255 }, -- Hostile
	[3] = { 219/255, 48/255,  41/255 }, -- Unfriendly
	[4] = { 218/255, 197/255, 92/255 }, -- Neutral
	[5] = { 75/255,  175/255, 76/255 }, -- Friendly
	[6] = { 75/255,  175/255, 76/255 }, -- Honored
	[7] = { 75/255,  175/255, 76/255 }, -- Revered
	[8] = { 75/255,  175/255, 76/255 }, -- Exalted
}

-- ----------------------------------------------------------------------------
-- Custom tags
-- ----------------------------------------------------------------------------

local verbosehp = "|cff00FF00%d|r |cffFFFFFF|||r |cff395A09%d|r"  -- 1234 | 5678 [colored green]
local verbosepp = "|cff5EAEF7%d|r |cffFFFFFF|||r |cff063C82%d|r"  -- 1234 | 5678 [colored blue]
local perhp     = "|cff%02x%02x%02x%s%%|r"						  -- 100% [colored gradient]

oUF.TagEvents["[verbosehp]"]   = "UNIT_HEALTH UNIT_MAXHEALTH"
oUF.TagEvents["[perhpgrad]"]   = "UNIT_HEALTH UNIT_MAXHEALTH"
oUF.TagEvents["[verbosepp]"]   = "UNIT_MAXENERGY UNIT_MAXFOCUS UNIT_MAXMANA UNIT_MAXRAGE UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE"
oUF.TagEvents["[verbosename]"] = "UNIT_NAME_UPDATE UNIT_HEALTH UNIT_TARGET"

oUF.Tags["[verbosehp]"] = function(u) local c, m = UnitHealth(u), UnitHealthMax(u) return (c <= 1 or not UnitIsConnected(u)) and "" or verbosehp:format(c, m) end
oUF.Tags["[verbosepp]"] = function(u) local c, m = UnitMana(u), UnitManaMax(u) return (c <= 1 or not UnitIsConnected(u)) and "" or verbosepp:format(c, m) end
oUF.Tags["[perhpgrad]"] = function(u)
	local v = oUF.Tags["[perhp]"](u)

	if v < 100 and v > 0 then
		-- Color health percent value in a gradient
		local r, g, b = ColorGradient(v / 100.00, -- Function expects a decimal
			health[0].r, health[0].g, health[0].b,
			health[1].r, health[1].g, health[1].b,
			health[2].r, health[2].g, health[2].b
		)
		return perhp:format(r * 255, g * 255, b * 255, v)
	end
	return ""
end

-- TODO: Clean the fuck up
oUF.Tags["[verbosename]"] = function(u)
	if u == "player" then return "" end
	
	local name = "%s |cff%02x%02x%02x%s|r %s"
	local classifications = {
		worldboss = "??",
		rareelite = "%s*+",
		rare = "%s*",
		elite = "%s+",
	}
	
	local _, c = UnitClass(u)
	local color = oUF.colors.class[c] or UnitReactionColor[4]
		
	if u == "target" then
		local cl = UnitClassification(u)
		local level = classifications[cl] and classifications[cl]:format(UnitLevel(u)) or UnitLevel(u)
		local n = UnitName(u) or ''
		local race = UnitRace(u) or UnitCreatureType(u) or ''
		return name:format(level, color[1] * 255, color[2] * 255, color[3] * 255, n, race)
	elseif u == "targettarget" then
		local n = UnitName(u) or ''
		if n == playerName then
			return "|cffFF0000<< You >>|r"
		else
			return name:format('', color[1] * 255, color[2] * 255, color[3] * 255, n, '')
		end
	else
		local n = UnitName(u) or ''
		local level = UnitLevel(u)
		return name:format(level, color[1] * 255, color[2] * 255, color[3] * 255, n, '')
	end
end

--[[
local grey = {0.5, 0.5, 0.5}
local white = {1, 1, 1}
]]

local function auraIcon(self, button)
	local t = button:CreateTexture(nil, "OVERLAY")
	t:SetTexture(borderTexture)
	t:SetAllPoints(button)
	t:SetVertexColor(0.25, 0.25, 0.35)
end

local backdrop = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", 
	insets = {left = -2, right = -2, top = -2, bottom = -2},
}

-- ----------------------------------------------------------------------------
-- Frame Creation
-- ----------------------------------------------------------------------------

local function createBarFrame(parent, height)
	local bar = CreateFrame("StatusBar")
	bar:SetHeight(height)
	bar:SetStatusBarTexture(statusbarTexture)
	bar:SetParent(parent)
	bar:SetPoint("LEFT")
	bar:SetPoint("RIGHT")
	
	return bar
end
local function createInfoBarFrame(parent)
	local bar = createBarFrame(parent, 17)
	bar:SetStatusBarColor(1, 1, 1, 0.1)
	bar:SetPoint("BOTTOM", parent, "BOTTOM", 0, 0)
	
	return bar
end
local function createHealthBarFrame(parent)
	local bar = createBarFrame(parent, 24)
	--bar:SetStatusBarColor(0, 0.5, 0)
	bar:SetPoint("TOP", 0, 1)
	bar:SetPoint("LEFT", -1, 0)
	bar:SetPoint("RIGHT", 1, 0)
	
	bar.colorTapping = true
	bar.colorHappiness = true
	bar.colorDisconnected = true
	bar.colorClass = true
	bar.colorClassNPC = false
	bar.colorReaction = true
	
	local bg = bar:CreateTexture(nil, "ARTWORK")
	bg:SetHeight(bar:GetHeight())
	bg:SetWidth(bar:GetWidth())
	bg:SetTexture(statusbarTexture)
	bg:SetPoint("LEFT")
	bg:SetPoint("RIGHT")
	
	bar.bg = bg
	
	return bar
end
local function createPowerBarFrame(parent)
	local bar = createBarFrame(parent, 5)
	--bar:SetStatusBarColor(.25, .25, .35)
	bar:SetPoint("TOP", parent, "BOTTOM", 0, -2)
	bar:SetPoint("LEFT")
	bar:SetPoint("RIGHT")
	
	bar.colorTapping = false
	bar.colorDisconnected = true
	bar.colorPower = true
	
	return bar
end

local function createString(parent, fontSize)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(font, fontSize)
	--fs:SetPoint("RIGHT", -4, 2)
	fs:SetShadowColor(0, 0, 0, 0.9)
	fs:SetShadowOffset(1, -1)
	
	return fs
end

local function createCombatFeedback(self, parent)
	if IsAddOnLoaded("oUF_CombatFeedback") then
		local cbft = parent:CreateFontString(nil, "OVERLAY")
		cbft:SetPoint("LEFT", 4, 0)
		cbft:SetFont(font, fontSize + 2)
		cbft:SetShadowColor(0, 0, 0, 0.9)
		cbft:SetShadowOffset(1, -1)
		
		self.CombatFeedbackText = cbft
		self.CombatFeedbackText.maxAlpha = .6
		
		self.CombatFeedbackText.ignoreHeal     = false
		self.CombatFeedbackText.ignoreImmune   = false
		self.CombatFeedbackText.ignoreDamage   = false
		self.CombatFeedbackText.ignoreEnergize = true
		self.CombatFeedbackText.ignoreOther    = true
	end
end
local function createPowerSpark(parent)
	if IsAddOnLoaded("oUF_PowerSpark") then
		local spark = parent:CreateTexture(nil, "OVERLAY")
		spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
		spark:SetVertexColor(1, 1, 1, 0.5)
		spark:SetBlendMode("ADD")
		spark:SetHeight(parent:GetHeight()*2)
		spark:SetWidth(parent:GetHeight())
		
		--spark.manatick = true
		return spark
	end
	
	return nil
end

-- Frame sizes
local width,  height  = 250, 49 -- Player and Target
local pwidth, pheight = 200, 20 -- Focus, Party and Party Pet
local twidth, theight = 150, 21 -- Target of Target

local func = function(settings, self, unit)
	self.unit = unit
	self.menu = menu
	
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	
	self:RegisterForClicks("anyup")
	self:SetAttribute("*type2", "menu")
	
	self:SetBackdrop(backdrop)
	self:SetBackdropColor(0, 0, 0, .9)
	
	-- Player ---------------------------------------------
	if unit == 'player' then
		local ib = createInfoBarFrame(self)		-- Info Bar
		local hp = createHealthBarFrame(self) 	-- Health Bar
		local pp = createPowerBarFrame(hp) 		-- Power Bar
		
		createCombatFeedback(self, hp)			-- Combat Feedback
		
		-- Health Values
		local hpv = createString(ib, fontSize)
		hpv:SetPoint("RIGHT", -4, 2)
		hpv:SetText("[dead][offline][verbosehp]")
		
		-- Power Values
		local ppv = createString(ib, fontSize)
		ppv:SetPoint("LEFT", 4, 2)
		ppv:SetText("[verbosepp]")
		
		self.Health = hp
		self.Power = pp

		self.TaggedStrings = {hpv, ppv}
		self.Spark = createPowerSpark(pp)
	-- Target ---------------------------------------------
	elseif unit == 'target' then
		local ib = createInfoBarFrame(self)		-- Info Bar
		local hp = createHealthBarFrame(self)	-- Health Bar
		local pp = createPowerBarFrame(hp)		-- Power Bar
		
		createCombatFeedback(self, hp)			-- Combat Feedback
		
		-- Name
		local name = createString(ib, fontSize)
		name:SetPoint("LEFT", 4, 2)
		name:SetJustifyH("LEFT")
		name:SetText("[verbosename]")
		
		-- Health string (absolute)
		local hpv = createString(ib, fontSize)
		hpv:SetPoint("RIGHT", -4, 2)
		hpv:SetText("[verbosehp]")
		
		-- Prevent the name from going through the health values
		name:SetPoint("RIGHT", hpv, "LEFT")
		
		-- Health string (percentage)
		local hpp = createString(hp, fontSize + 2)
		hpp:SetPoint("RIGHT", -4, 0)
		hpp:SetText("[perhpgrad]")
		
		-- Auras
		local auras = CreateFrame("Frame", nil, self)
		auras.size = width / 8
		auras:SetHeight(auras.size * 4)
		auras:SetWidth(width)
		auras:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 2)
		auras.numBuffs = 40
		auras.numDebuffs = 32
		auras.gap = true
		self.Auras = auras
		self.PostCreateAuraIcon = auraIcon
		
		-- Raid Icon TODO: Test
		local ricon = self:CreateTexture(nil, "OVERLAY")
		ricon:SetHeight(24)
		ricon:SetWidth(24)
		ricon:SetPoint("TOPLEFT", self, "TOPRIGHT", 4, 0)
		ricon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
		self.RaidIcon = ricon
		
		-- Combo Points
		--if playerClass == "ROGUE" or playerClass == "DRUID" then
			self.CPoints = createString(self, fontSize + 4)
			self.CPoints:SetPoint("LEFT", self, "RIGHT", 9, 3)
			self.CPoints:SetFont(font, 38, "OUTLINE")
			self.CPoints:SetJustifyH("RIGHT")
		--end
		
		self.Health = hp
		self.Power = pp
		
		self.TaggedStrings = {name, hpv, hpp}
	-- TargetTarget ---------------------------------------
	elseif unit == 'targettarget' then
		--local ib = createInfoBarFrame(self)			-- Info Bar
		local hp = createHealthBarFrame(self)		-- Health Bar
		local pp = createPowerBarFrame(hp)			-- Power Bar
		
		--ib:SetHeight(14)
		hp:SetHeight(16)
		hp.bg:SetHeight(16)
		pp:SetHeight(4)
		
		-- Name
		local name = createString(hp, fontSize)
		name:SetPoint("CENTER", 0, 2)
		name:SetJustifyH("CENTER")
		name:SetText("[name]")
		
		self.Health = hp
		self.Power = pp
		
		self.TaggedStrings = {name}
	-- Pet ---------------------------------------
	elseif unit == 'pet' or unit == 'vehicle' then
		--local ib = createInfoBarFrame(self)			-- Info Bar
		local hp = createHealthBarFrame(self)		-- Health Bar
		local pp = createPowerBarFrame(hp)			-- Power Bar
		
		--ib:SetHeight(14)
		hp:SetHeight(16)
		hp.bg:SetHeight(16)
		pp:SetHeight(4)
		
		self.Health = hp
		self.Power = pp
		
		self.TaggedStrings = {name}
	-- Focus ----------------------------------------------
	elseif unit == "focus" then
		local hp = createHealthBarFrame(self)		-- Health Bar
		local pp = createPowerBarFrame(hp)			-- Power Bar
		
		hp:SetHeight(16)
		hp.bg:SetHeight(16)
		pp:SetHeight(4)
		
		-- Name
		local name = createString(self, fontSize)
		name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 2)
		name:SetText("[verbosename]")
		
		-- Health Percent
		local hpp = createString(hp, fontSize-2)
		hpp:SetPoint("RIGHT", -4, 2)
		hpp:SetText("[perhpgrad]")
		
		-- Auras
		local auras = CreateFrame("Frame", nil, self)
		local s = pp:GetHeight() + hp:GetHeight()
		auras.size = s
		auras:SetHeight(s)
		auras:SetWidth(s * 4)
		auras:SetPoint("LEFT", self, "RIGHT", 4, 0)
		auras.initialAnchor = "TOPLEFT"
		auras.numBuffs = 1
		auras.numDebuffs = 3
		self.Auras = auras
		
		self.Health = hp
		self.Power = pp
		
		self.TaggedStrings = {name, hpp}
		self.PostCreateAuraIcon = auraIcon
	-- Party ----------------------------------------------
	elseif not unit then
		local hp = createHealthBarFrame(self)		-- Health Bar
		local pp = createPowerBarFrame(hp)			-- Power Bar
		
		hp:SetHeight(16)
		hp.bg:SetHeight(16)
		pp:SetHeight(4)
		
		-- Name
		local name = createString(self, fontSize)
		name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 2)
		name:SetText("[verbosename]")
		
		-- Health Deficit
		local hpd = createString(hp, fontSize-2)
		hpd:SetPoint("RIGHT", -4, 2)
		hpd:SetText("[missinghp]")
		
		-- Auras (Debuffs only)
		local debuffs = CreateFrame("Frame", nil, self)
		local s = pp:GetHeight() + hp:GetHeight()
		debuffs.size = s
		debuffs:SetHeight(s)
		debuffs:SetWidth(s * 4)
		debuffs:SetPoint("LEFT", self, "RIGHT", 4, 0)
		debuffs.initialAnchor = "TOPLEFT"
		debuffs.num = 4
		self.Debuffs = debuffs
		self.PostCreateAuraIcon = auraIcon
		
		-- Range Filtering
		self.Range = true
		self.inRangeAlpha = 1
		self.outsideRangeAlpha = .5
		
		self.Health = hp
		self.Power = pp
		
		self.TaggedStrings = {name, hpd}
	end

	--self:SetFrameStrata("BACKGROUND")
	--return self
end

oUF:RegisterStyle("tsigo", setmetatable({
	["initial-width"] = width,
	["initial-height"] = height,
}, {__call = func}))

oUF:RegisterStyle("tsigo_ToT", setmetatable({
	["initial-width"] = twidth,
	["initial-height"] = theight,
}, {__call = func}))

oUF:RegisterStyle("tsigo_Party", setmetatable({
	["initial-width"] = pwidth,
	["initial-height"] = pheight,
}, {__call = func}))

-- ----------------------------------------------------------------------------
-- Player, ToT, Target
-- ----------------------------------------------------------------------------

oUF:SetActiveStyle("tsigo")

local player = oUF:Spawn("player")
player:SetPoint("BOTTOM", -225, 65)

local target = oUF:Spawn("target")
target:SetPoint("BOTTOM", 225, 65)

oUF:SetActiveStyle("tsigo_ToT")

local tot = oUF:Spawn("targettarget")
tot:SetPoint("BOTTOM", 0, 65)

local pet = oUF:Spawn("pet")
pet:SetPoint("BOTTOM", tot, "TOP", 0, 5)

--[[
local toggleVehicle = CreateFrame("Frame")
toggleVehicle:RegisterEvent("UNIT_ENTERED_VEHICLE")
toggleVehicle:SetScript("OnEvent", function(self, event, arg1)
	if ( event == "UNIT_ENTERED_VEHICLE" and arg1 == "player" ) then
		local vehicle = oUF:Spawn("vehicle")
		vehicle:SetPoint("BOTTOM", tot, "TOP", 0, 5)
	end
end)
]]

-- ----------------------------------------------------------------------------
-- Focus, Party, Party Pets
-- ----------------------------------------------------------------------------

oUF:SetActiveStyle("tsigo_Party")

local focus = oUF:Spawn("focus")
focus:SetPoint("BOTTOMRIGHT", player, "TOPLEFT", -10, 75)

local party = oUF:Spawn("header", "oUF_Party")
party:SetPoint("BOTTOMLEFT", target, "TOPRIGHT", 15, 75)
party:SetAttribute("yOffset", pheight - (pheight * 2)) -- Grow up (does -pheight work?)
party:SetAttribute("showParty", true)

local partypet = oUF:Spawn("header", "oUF_PartyPets", true)
partypet:SetPoint("BOTTOM", party, "TOP", 0, pheight)
partypet:SetAttribute("yOffset", pheight - (pheight * 2)) -- Grow up (does -pheight work?)
partypet:SetAttribute("showParty", true)

local toggleParty = CreateFrame("Frame")
toggleParty:SetScript("OnEvent", function(self)
	if InCombatLockdown() then 
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		if GetNumRaidMembers() > 0 then
			party:Hide()
			partypet:Hide()
		elseif GetNumPartyMembers() > 0 then
			party:Show()
			partypet:Show()
			
			partypet:SetPoint("BOTTOM", party, "TOP", 0, GetNumPartyMembers() * pheight)
		end
	end
end)
toggleParty:RegisterEvent("PARTY_MEMBERS_CHANGED")
toggleParty:RegisterEvent("PARTY_LEADER_CHANGED")
toggleParty:RegisterEvent("RAID_ROSTER_UPDATE")
toggleParty:RegisterEvent("PLAYER_LOGIN")