--[[
--
-- oUF_Tsigo
--
-- Custom layout for oUF.
-- Based on Caith's PitBull layout - http://www.bellum-potentiae.de/forum/viewtopic.php?t=3674
-- by tsigo@tsigo.org
--
--LibStub("AceConsole-2.0"):PrintLiteral(...)
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
local UnitName = UnitName
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

local RAID_CLASS_COLORS = {
	["DRUID"]   = { r = 255/255, g = 124/255, b = 10/255 },
	["HUNTER"]  = { r = 163/255, g = 251/255, b = 131/255 },
	["MAGE"]    = { r = 123/255, g = 203/255, b = 254/255 },
	["PALADIN"] = { r = 245/255, g = 137/255, b = 186/255 },
	["PRIEST"]  = { r = 194/255, g = 252/255, b = 254/255 },
	["ROGUE"]   = { r = 255/255, g = 241/255, b = 106/255 },
	["SHAMAN"]  = { r = 0/255,   g = 254/255, b = 255/255 },	-- Caith's Shaman color
	--["SHAMAN"]  = { r = 6/255,   g = 60/255,  b = 188/255 },	-- More traditional Shaman blue
	["WARLOCK"] = { r = 187/255, g = 162/255, b = 254/255 },
	["WARRIOR"] = { r = 210/255, g = 188/255, b = 149/255 },
}

local health = {
	[0] = { r = 255/255, g = 66/255,  b = 42/255 }, -- Red
	[1] = { r = 195/255, g = 252/255, b = 0/255 },  -- Yellow-ish
	[2] = { r = 34/255,  g = 250/255, b = 42/255 }, -- Green
}

local power = {
	[0] = { r = 146/255, g = 196/255, b = 249/255 }, -- Mana
	[1] = { r = 160/255, g = 96/255,  b = 97/255  }, -- Rage
	[2] = { r = 202/255, g = 181/255, b = 126/255 }, -- Focus
	[3] = { r = 228/255, g = 218/255, b = 167/255 }, -- Energy
	[4] = { r = 0,       g = 1,       b = 1}         -- Focus
}

local UnitReactionColor = {
	[1] = { r = 219/255, g = 48/255,  b = 41/255 }, -- Hated
	[2] = { r = 219/255, g = 48/255,  b = 41/255 }, -- Hostile
	[3] = { r = 219/255, g = 48/255,  b = 41/255 }, -- Unfriendly
	[4] = { r = 218/255, g = 197/255, b = 92/255 }, -- Neutral
	[5] = { r = 75/255,  g = 175/255, b = 76/255 }, -- Friendly
	[6] = { r = 75/255,  g = 175/255, b = 76/255 }, -- Honored
	[7] = { r = 75/255,  g = 175/255, b = 76/255 }, -- Revered
	[8] = { r = 75/255,  g = 175/255, b = 76/255 }, -- Exalted
}

oUF.colors.power = {
	['MANA'] = { 146/255, 196/255, 249/255 }, -- Mana
	['RAGE'] = { 160/255, 96/255,  97/255  }, -- Rage
	['FOCUS'] = { 202/255, 181/255, 126/255 }, -- Focus
	['ENERGY'] = { 228/255, 218/255, 167/255 }, -- Energy
	['FOCUS'] = { 0, 1, 1} -- Focus
}

-- ----------------------------------------------------------------------------
-- Custom tags
-- ----------------------------------------------------------------------------

--[[
oUF.TagEvents["[tsihp]"] = "UNIT_HEALTH UNIT_MAXHEALTH"
oUF.Tags["[tsimaxhp]"] = function(u) local m = UnitHealthMax(u) return "|cff395A09" .. m .. "|r" end
oUF.Tags["[tsihp]"] = function(u) local c, m = UnitHealth(u), UnitHealthMax(u) return (c <= 1 or not UnitIsConnected(u)) and "" or c >= m and oUF.Tags["[tsimaxhp]"](u)
	or UnitCanAttack("player", u) and oUF.Tags["[perhp]"](u).."%" or "-"..oUF.Tags["[missinghp]"](u) end
	
local barFormatMinMax_Health = "|cff00FF00%d|r |cffFFFFFF|||r |cff395A09%d|r" -- 1234 | 5678 [colored green]
]]

-- ----------------------------------------------------------------------------
-- Name Display
-- ----------------------------------------------------------------------------

--[[
local grey = {0.5, 0.5, 0.5}
local white = {1, 1, 1}
local name = "%s |cff%02x%02x%02x%s|r %s"
local classifications = {
	worldboss = "??",
	rareelite = "%s*+",
	rare = "%s*",
	elite = "%s+",
}
local function updateName(self, event, unit)
	if unit == "player" then return end
	if not self.Name then return end
	
	if self.unit == unit or (not unit and self.unit) then
		local u = unit or self.unit
		local _, c = UnitClass(u)
		local color = RAID_CLASS_COLORS[c] or UnitReactionColor[4]
		
		if unit == "target" then
			local cl = UnitClassification(u)
			local level = classifications[cl] and classifications[cl]:format(UnitLevel(u)) or UnitLevel(u)
			local n = UnitName(u)
			local race = UnitRace(u) or UnitCreatureType(u) or ''
			self.Name:SetText(name:format(level, color.r * 255, color.g * 255, color.b * 255, n, race)) -- format arg #6
		elseif unit == "targettarget" then
			local n = UnitName(u)
			if n == playerName then
				self.Name:SetText("|cffFF0000<< You >>|r")
			else
				self.Name:SetText(name:format('', color.r * 255, color.g * 255, color.b * 255, n, ''))
			end
		else
			local n = UnitName(u)
			local level = UnitLevel(u)
			self.Name:SetText(name:format(level, color.r * 255, color.g * 255, color.b * 255, n, ''))
		end

		local c = (not UnitIsConnected(u) or UnitIsGhost(u) or UnitIsDead(u)) and grey or white
		self.Name:SetTextColor(unpack(c))
	end
end

-- ----------------------------------------------------------------------------
-- Health / Power Formats
-- ----------------------------------------------------------------------------

local barFormatMinMax = "%d | %d"											  -- 1234 | 5678
local barFormatMinMax_Health = "|cff00FF00%d|r |cffFFFFFF|||r |cff395A09%d|r" -- 1234 | 5678 [colored green]
local barFormatMinMax_Power = "|cff5EAEF7%d|r |cffFFFFFF|||r |cff063C82%d|r"  -- 1234 | 5678 [colored blue]
local barFormatPerc = "%d%%"												  -- 100%
local barFormatPerc_Health = "|cff%02x%02x%02x%s%%|r"						  -- 100% [colored gradient]
local barFormatPercMinMax = barFormatPerc.." "..barFormatMinMax				  -- 100% 1234 | 5678
local barFormatDeficit = "|cffff8080%d|r"									  -- -1234 [colored red]

local function fmt_standard(bartype, txt, min, max)
	txt:SetFormattedText(barFormatMinMax, min, max)
end
local function fmt_perc(bartype, txt, min, max)
	local value = floor((min/max) * 100)
	local text = ''
	
	if bartype == 'health' and value < 100 then
		-- Color health percent value in a gradient
		local r, g, b = ColorGradient(min/max, -- Function expects a decimal
			health[0].r, health[0].g, health[0].b,
			health[1].r, health[1].g, health[1].b,
			health[2].r, health[2].g, health[2].b
		)
		text = barFormatPerc_Health:format(r * 255, g * 255, b * 255, value)
	elseif value < 100 then
		text = barFormatPerc:format(value)
	else
		text = ''
	end
	
	txt:SetText(text)
end
local function fmt_full(bartype, txt, min, max)
	local format = bartype == 'health' and barFormatMinMax_Health or barFormatMinMax_Power
	txt:SetFormattedText(format, min, max)
end
local function fmt_deficit(bartype, txt, min, max)
	local deficit = min - max
	if deficit < 0 then
		txt:SetFormattedText(barFormatDeficit, deficit)
	else
		txt:SetText('')
	end
end
local function fmt_percminmax(bartype, txt, min, max)
	txt:SetFormattedText(barFormatPercMinMax, floor(min/max*100), min, max)
end

local fmtmeta = { __index = function(self, key)
	if type(key) == "nil" then return nil end
	if not rawget(self, key) then
		rawset(self, key, fmt_standard)
		return self[key]
	end
end}
local formats = setmetatable({}, { 
	__index = function(self, key)
		if type(key) == "nil" then return nil end
		if not rawget(self, key) then
			if key:find("raidpet%d") then self[key] = self.raidpet
			elseif key:find("raidtarget%d") then self[key] = self.raidtarget
			elseif key:find("raid%d") then self[key] = self.raid
			elseif key:find("partypet%d") then self[key] = self.partypet
			elseif key:find("party%dtarget") then self[key] = self.partytarget
			elseif key:find("party%d") then self[key] = self.party
			else
				self[key] = {}
			end
		end
		return self[key]
	end,
	__newindex = function(self, key, value)
		rawset(self, key, setmetatable(value, fmtmeta))
	end,
})

formats.player.health = fmt_full
formats.player.power = fmt_full

formats.target.health = fmt_full
formats.target.health_perc = fmt_perc

formats.targettarget.health = fmt_perc
formats.focus.health = fmt_perc

formats.party.health = fmt_deficit
formats.partypet.health = fmt_deficit

-- ----------------------------------------------------------------------------
-- Health Updater
-- ----------------------------------------------------------------------------

local function updateHealth(self, event, unit, bar, min, max)
    if bar.percent then bar.percent:SetText("") end
    if bar.value then bar.value:SetText("") end
    
	if UnitIsDead(unit) then
		--bar.value:SetText("Dead")
		if bar.percent then bar.percent:SetText("Dead") end
		if bar.value then bar.value:SetTextColor(.5, .5, .5) end
	elseif UnitIsGhost(unit) then
		if bar.value then
			bar.value:SetText("Ghost")
			bar.value:SetTextColor(.5, .5, .5)
		end
	elseif not UnitIsConnected(unit) then
		if bar.value then
			bar.value:SetText("Off")
			bar.value:SetTextColor(.5, .5, .5)
		end
	else
		local curhp, maxhp = min, max
		
		if bar.value then
			formats[unit].health('health', bar.value, curhp, maxhp)
		end
		
		-- Update percent value for target
		if unit == "target" and bar.percent then
			formats[unit].health_perc('health', bar.percent, min, max)
		end
		
		if UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
			bar:SetStatusBarColor(.5, .5, .3)
		else
			local color
			if UnitIsPlayer(unit) then
				local _, c = UnitClass(unit)
				color = RAID_CLASS_COLORS[c]
			else
				color = UnitReactionColor[UnitReaction(unit, "player")]
			end

			--local color = UnitIsFriend(unit, "player") and UnitIsPlayer(unit) and RAID_CLASS_COLORS[c] or UnitReactionColor[UnitReaction(unit, "player")]
			if color then
				bar:SetStatusBarColor(color.r, color.g, color.b)
				
				if bar.bg then
					bar.bg:SetVertexColor(color.r, color.g, color.b, 0.3)
				end
			end
			self:UNIT_NAME_UPDATE(event, unit)
		end
	end
end

-- ----------------------------------------------------------------------------
-- Power Updater
-- ----------------------------------------------------------------------------

local function updatePower(self, event, unit, bar, min, max)
	if UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) or not UnitIsConnected(unit) then
		bar:SetStatusBarColor(.6, .6, .6)
	else
		if max == 0 or UnitIsDead(unit) or UnitIsGhost(unit) or not UnitIsConnected(unit) then
			bar:SetValue(0)
			if bar.value then
				bar.value:SetText()
			end
		elseif bar.value then
			formats[unit].power('power', bar.value, min, max)
		end
		
		local color = power[UnitPowerType(unit)]
		if color then
			bar:SetStatusBarColor(color.r, color.g, color.b)
		end
	end
end
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
	--bar:SetStatusBarColor(1, 1, 1, 0.1)
	bar:SetPoint("BOTTOM", parent, "BOTTOM", 0, 0)
	
	return bar
end
local function createHealthBarFrame(parent)
	local bar = createBarFrame(parent, 24)
	--bar:SetStatusBarColor(0, 0.5, 0)
	bar:SetPoint("TOP", 0, 1)
	bar:SetPoint("LEFT", -1, 0)
	bar:SetPoint("RIGHT", 1, 0)
	
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
local twidth, theight = 150, 37 -- Target of Target

local func = function(settings, self, unit)
	self.unit = unit
	self.menu = menu
	
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	
	self:RegisterForClicks("anyup")
	self:SetAttribute("*type2", "menu")
	
	self:SetBackdrop(backdrop)
	self:SetBackdropColor(0, 0, 0, .9)
	
	--[[ tek
	-- Health bar
	local hp = CreateFrame("StatusBar")
	hp:SetWidth(width)
	hp:SetHeight(bheight)
	hp:SetStatusBarTexture(statusbarTexture)
	
	hp:SetParent(self)
	hp:SetStatusBarColor(0, 0.5, 0)
	hp:SetPoint("TOP", 0, 1)
	hp:SetPoint("LEFT", -1, 0)
	hp:SetPoint("RIGHT", 1, 0)
	
	self.Health = hp
	--self.PostUpdateHealth = PostUpdateHealth
	
	local hpv = hp:CreateFontString(nil, "OVERLAY")
	hpv:SetFont(font, fontSize)
	hpv:SetText("[dead][offline][tsihp]")
	hpv:SetPoint("RIGHT", -4, 2)
	hpv:SetShadowColor(0, 0, 0, 0.9)
	hpv:SetShadowOffset(1, -1)
	
	self.TaggedStrings = {hpv}
	]]
	
	-- Player ---------------------------------------------
	if unit == 'player' then
		local ib = createInfoBarFrame(self)		-- Info Bar
		local hp = createHealthBarFrame(self) 	-- Health Bar
		local pp = createPowerBarFrame(hp) 		-- Power Bar
		
		createCombatFeedback(self, hp)			-- Combat Feedback
		
		-- Health Values
		local hpv = createString(ib, fontSize)
		hpv:SetPoint("RIGHT", -4, 2)
		hpv:SetText("[dead][offline][curhp] | [maxhp]")
		
		-- Power Values
		local ppv = createString(ib, fontSize)
		ppv:SetPoint("LEFT", 4, 2)
		ppv:SetText("[curpp] | [maxpp]")
		
		-- Health Properties
		hp.colorTapping = true
		hp.colorHappiness = true
		hp.colorDisconnected = true
		hp.colorClass = true
		hp.colorClassNPC = false
		hp.colorReaction = true
		self.Health = hp
		
		-- Power Properties
		pp.colorTapping = false
		pp.colorDisconnected = true
		pp.colorPower = true
		self.Power = pp

		self.TaggedStrings = {hpv, ppv}
		--self.Spark = createPowerSpark(pp)
		--self.OverrideUpdateHealth = updateHealth
		--self.OverrideUpdatePower = updatePower
	--[[
	-- Target ---------------------------------------------
	elseif unit == 'target' then
		-- Dimensions
		self:SetWidth(250)
		self:SetHeight(49)
		
		local ib = createInfoBarFrame(self)		-- Info Bar
		local hp = createHealthBarFrame(self)	-- Health Bar
		local pp = createPowerBarFrame(hp)		-- Power Bar
		
		createCombatFeedback(self, hp)			-- Combat Feedback
		
		-- Name
		local name = createString(ib, fontSize)
		name:SetPoint("LEFT", 4, 2)
		name:SetJustifyH("LEFT")
		
		-- Health string (absolute)
		local hpv = createString(ib, fontSize)
		hpv:SetPoint("RIGHT", -4, 2)
		
		-- Prevent the name from going through the health values
		name:SetPoint("RIGHT", hpv, "LEFT")
		
		-- Health string (percentage)
		local hpp = createString(hp, fontSize + 2)
		hpp:SetPoint("RIGHT", -4, 0)
		
		-- Auras
		local auras = CreateFrame("Frame", nil, self)
		auras.size = self:GetWidth() / 8
		auras:SetHeight(auras.size * 4)
		auras:SetWidth(self:GetWidth())
		auras:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 2)
		auras.numBuffs = 40
		auras.numDebuffs = 40
		auras.gap = true
		
		-- Raid Icon
		local ricon = self:CreateTexture(nil, "OVERLAY")
		ricon:SetHeight(24)
		ricon:SetWidth(24)
		ricon:SetPoint("TOPLEFT", self, "TOPRIGHT", 4, 0)
		ricon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
		self.RaidIcon = ricon
		
		-- Combo Points
		if playerClass == "ROGUE" or playerClass == "DRUID" then
			self.CPoints = createString(self, fontSize + 4)
			self.CPoints:SetPoint("LEFT", self, "RIGHT", 9, 3)
			self.CPoints:SetFont(font, 38, "OUTLINE")
			self.CPoints:SetJustifyH("RIGHT")
		end
		
		-- Properties
		self.Name = name
		self.Health = hp
		self.Power = pp
		self.Auras = auras
		
		hp.value = hpv
		hp.percent = hpp
		
		self.UNIT_NAME_UPDATE = updateName
		self.OverrideUpdateHealth = updateHealth
		self.OverrideUpdatePower = updatePower
		self.PostCreateAuraIcon = auraIcon
		
	-- TargetTarget ---------------------------------------
	elseif unit == 'targettarget' then
		-- Dimensions
		self:SetWidth(150)
		self:SetHeight(37)
		
		local ib = createInfoBarFrame(self)			-- Info Bar
		local hp = createHealthBarFrame(self)		-- Health Bar
		local pp = createPowerBarFrame(hp)			-- Power Bar
		
		ib:SetHeight(14)
		hp:SetHeight(16)
		hp.bg:SetHeight(16)
		pp:SetHeight(4)
		
		-- Name
		local name = createString(ib, fontSize)
		name:SetPoint("CENTER", 0, 2)
		name:SetJustifyH("CENTER")
		
		-- Properties
		self.Name = name
		self.Health = hp
		self.Power = pp
		
		self.UNIT_NAME_UPDATE = updateName
		self.OverrideUpdateHealth = updateHealth
		self.OverrideUpdatePower = updatePower
		
	-- Focus ----------------------------------------------
	elseif unit == "focus" then
		-- Dimensions
		self:SetWidth(200)
		self:SetHeight(20)
		
		local hp = createHealthBarFrame(self)		-- Health Bar
		local pp = createPowerBarFrame(hp)			-- Power Bar
		
		hp:SetHeight(16)
		hp.bg:SetHeight(16)
		pp:SetHeight(4)
		
		-- Name
		local name = createString(self, fontSize)
		name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 2)
		
		-- Health Percent
		local hpp = createString(hp, fontSize-2)
		hpp:SetPoint("RIGHT", -4, 2)
		
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
		
		-- Properties
		self.Name = name
		self.Health = hp
		self.Power = pp
		self.Auras = auras
		
		hp.percent = hpp
		
		self.UNIT_NAME_UPDATE = updateName
		self.OverrideUpdateHealth = updateHealth
		self.OverrideUpdatePower = updatePower
		self.PostCreateAuraIcon = auraIcon
	
	-- Party ----------------------------------------------
	elseif not unit then
		-- Dimensions
		--self:SetWidth(200)
		--self:SetHeight(20)
		
		local hp = createHealthBarFrame(self)		-- Health Bar
		local pp = createPowerBarFrame(hp)			-- Power Bar
		
		hp:SetHeight(16)
		hp.bg:SetHeight(16)
		pp:SetHeight(4)
		
		-- Name
		local name = createString(self, fontSize)
		name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 2)
		
		-- Health Deficit
		local hpd = createString(hp, fontSize-2)
		hpd:SetPoint("RIGHT", -4, 2)
		
		-- Auras (Debuffs only)
		local debuffs = CreateFrame("Frame", nil, self)
		local s = pp:GetHeight() + hp:GetHeight()
		debuffs.size = s
		debuffs:SetHeight(s)
		debuffs:SetWidth(s * 4)
		debuffs:SetPoint("LEFT", self, "RIGHT", 4, 0)
		debuffs.initialAnchor = "TOPLEFT"
		debuffs.num = 4
		
		-- Range Filtering
		self.Range = true
		self.inRangeAlpha = 1
		self.outsideRangeAlpha = .5
		
		-- Properties
		self.Name = name
		self.Health = hp
		self.Power = pp
		self.Debuffs = debuffs
		
		hp.value = hpd
		
		self.UNIT_NAME_UPDATE = updateName
		self.OverrideUpdateHealth = updateHealth
		self.OverrideUpdatePower = updatePower
		self.PostCreateAuraIcon = auraIcon
	]]
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

local partypet = oUF:Spawn("header", "oUF_PartyPet", true)
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