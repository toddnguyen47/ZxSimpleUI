--- upvalues to prevent warnings
local LibStub = LibStub
local UnitPower, UnitPowerMax = UnitPower, UnitPowerMax
local UnitClass, UnitPowerType = UnitClass, UnitPowerType

--- include files
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local FramePool47 = ZxSimpleUI.FramePool47

local BarTemplateDefaults = ZxSimpleUI.prereqTables["BarTemplateDefaults"]
local BarTemplate = ZxSimpleUI.prereqTables["BarTemplate"]
local Utils47 = ZxSimpleUI.Utils47
local RegisterWatchHandler47 = ZxSimpleUI.RegisterWatchHandler47

local MODULE_NAME = "PetPower47"
local DECORATIVE_NAME = "Pet Power"
local PetPower47 = ZxSimpleUI:NewModule(MODULE_NAME)

PetPower47.MODULE_NAME = MODULE_NAME
PetPower47.DECORATIVE_NAME = DECORATIVE_NAME
PetPower47.unit = "pet"
PetPower47.PLAYER_ENGLISH_CLASS = string.upper(select(2, UnitClass("player")))

local _powerEventColorTable = {
  ["UNIT_MANA"] = {0.0, 0.0, 1.0, 1.0},
  ["UNIT_RAGE"] = {1.0, 0.0, 0.0, 1.0},
  ["UNIT_FOCUS"] = {1.0, 0.65, 0.0, 1.0},
  ["UNIT_ENERGY"] = {1.0, 1.0, 0.0, 1.0},
  ["UNIT_RUNIC_POWER"] = {0.0, 1.0, 1.0, 1.0}
}

local _unitPowerTypeTable = {
  ["MANA"] = 0,
  ["RAGE"] = 1,
  ["FOCUS"] = 2,
  ["ENERGY"] = 3,
  ["COMBOPOINTS"] = 4,
  ["RUNES"] = 5,
  ["RUNICPOWER"] = 6
}

local _defaults = {
  profile = {
    enabledToggle = PetPower47.PLAYER_ENGLISH_CLASS == "HUNTER" or
      PetPower47.PLAYER_ENGLISH_CLASS == "WARLOCK",
    showbar = false,
    width = 150,
    height = 20,
    xoffset = 0,
    yoffset = -2,
    fontsize = 14,
    font = "PT Sans Bold",
    fontcolor = {1.0, 1.0, 1.0},
    texture = "Skewed",
    color = _powerEventColorTable["UNIT_MANA"],
    border = "None",
    selfCurrentPoint = "TOPRIGHT",
    relativePoint = "BOTTOMRIGHT"
  }
}

function PetPower47:__init__()
  self.mainFrame = nil
  self.currentPowerColorEdited = _powerEventColorTable["UNIT_MANA"]

  self._timeSinceLastUpdate = 0
  self._prevPowerValue = UnitPowerMax(self.unit)
  self._playerClass = UnitClass(self.unit)
  self._powerType = 0
  self._powerTypeString = ""

  self._barTemplateDefaults = BarTemplateDefaults:new()
  self._newDefaults = self._barTemplateDefaults.defaults
  Utils47:replaceTableValue(self._newDefaults.profile, _defaults.profile)
end

function PetPower47:OnInitialize()
  self:__init__()

  self.db = ZxSimpleUI.db:RegisterNamespace(MODULE_NAME, self._newDefaults)
  self._curDbProfile = self.db.profile
  -- Always set the showbar option to false on initialize
  self._curDbProfile.showbar = _defaults.profile.showbar

  self.bars = BarTemplate:new(self.db)

  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(MODULE_NAME))
end

function PetPower47:OnEnable() self:handleOnEnable() end

function PetPower47:OnDisable() self:handleOnDisable() end

---@param frameToAnchorTo table
---@return table
function PetPower47:createBar(frameToAnchorTo)
  assert(frameToAnchorTo ~= nil)
  local curUnitPower = UnitPower(self.unit)
  local maxUnitPower = UnitPowerMax(self.unit)
  local percentage = ZxSimpleUI:calcPercentSafely(curUnitPower, maxUnitPower)

  self.bars.frameToAnchorTo = frameToAnchorTo
  self.mainFrame = self.bars:createBar(percentage)

  self:_setInitialOnUpdateColor()
  self:_registerEvents()
  self:_setOnShowOnHideHandlers()
  self:_enableAllScriptHandlers()

  RegisterWatchHandler47:setRegisterForWatch(self.mainFrame, self.unit)

  return self.mainFrame
end

function PetPower47:refreshConfig()
  self:handleEnableToggle()
  if self:IsEnabled() then self:handleOnEnable() end
end

function PetPower47:handleEnableToggle()
  ZxSimpleUI:setModuleEnabledState(MODULE_NAME, self._curDbProfile.enabledToggle)
end

function PetPower47:handleOnEnable()
  if self.mainFrame ~= nil then
    -- If the show option is currently selected
    if self._curDbProfile.showbar == true then
      self.mainFrame.statusBar:SetStatusBarColor(unpack(self.currentPowerColorEdited))
    else
      self.bars:refreshConfig()
    end
    self.mainFrame:Show()
  end
end

function PetPower47:handleOnDisable() if self.mainFrame ~= nil then self.mainFrame:Hide() end end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

---@param curFrame table
---@param elapsed number
function PetPower47:_onUpdateHandler(curFrame, elapsed)
  if not self.mainFrame:IsVisible() then return end
  self._timeSinceLastUpdate = self._timeSinceLastUpdate + elapsed
  if (self._timeSinceLastUpdate > ZxSimpleUI.UPDATE_INTERVAL_SECONDS) then
    local curUnitPower = UnitPower(self.unit)
    if (curUnitPower ~= self._prevPowerValue) then
      self:_setPowerValue(curUnitPower)
      self._prevPowerValue = curUnitPower
      self._timeSinceLastUpdate = 0
    end
  end
end

---@param curFrame table
---@param event string
---@param unit string
function PetPower47:_onEventHandler(curFrame, event, unit)
  local isSameEvent = Utils47:stringEqualsIgnoreCase(event, "UNIT_DISPLAYPOWER")
  local isSameUnit = Utils47:stringEqualsIgnoreCase(unit, self.unit)
  if isSameEvent and isSameUnit then self:_handlePowerChanged() end
end

---@param curUnitPower number
function PetPower47:_setPowerValue(curUnitPower)
  curUnitPower = curUnitPower or UnitPower(self.unit)
  local maxUnitPower = UnitPowerMax(self.unit)
  local powerPercent = ZxSimpleUI:calcPercentSafely(curUnitPower, maxUnitPower)
  self.bars:setStatusBarValue(powerPercent)
end

function PetPower47:_handlePowerChanged() self:refreshConfig() end

function PetPower47:_registerEvents()
  for powerEvent, _ in pairs(_powerEventColorTable) do
    self.mainFrame:RegisterEvent(powerEvent)
  end
  -- Register Druid's shapeshift form
  self.mainFrame:RegisterEvent("UNIT_DISPLAYPOWER")
end

function PetPower47:_setOnShowOnHideHandlers()
  self.mainFrame:SetScript("OnShow", function(curFrame, ...)
    if self:IsEnabled() then
      self:_enableAllScriptHandlers()
    else
      self.mainFrame:Hide()
    end
  end)

  self.mainFrame:SetScript("OnHide",
    function(curFrame, ...) self:_disableAllScriptHandlers() end)
end

function PetPower47:_enableAllScriptHandlers()
  self.mainFrame:SetScript("OnUpdate", function(curFrame, elapsed)
    self:_onUpdateHandler(curFrame, elapsed)
  end)
  self.mainFrame:SetScript("OnEvent", function(curFrame, event, unit)
    self:_onEventHandler(curFrame, event, unit)
  end)
end

function PetPower47:_disableAllScriptHandlers()
  self.mainFrame:SetScript("OnUpdate", nil)
  self.mainFrame:SetScript("OnEvent", nil)
end

function PetPower47:_setUnitPowerType()
  self._powerType, self._powerTypeString = UnitPowerType(self.unit)
end

function PetPower47:_setInitialColor()
  self:_setUnitPowerType()
  local upperType = string.upper(self._powerTypeString)
  local t1 = _powerEventColorTable["UNIT_" .. upperType]
  t1 = t1 or _powerEventColorTable["UNIT_MANA"]

  self._newDefaults.profile.color = t1
  self._curDbProfile.color = t1
  self.mainFrame.statusBar:SetStatusBarColor(unpack(t1))
end

function PetPower47:_setInitialOnUpdateColor()
  local tempFrame = FramePool47:getFrame()
  local tempTimeSinceLastUpdate = 0
  tempFrame:SetScript("OnUpdate", function(curFrame, elapsed)
    tempTimeSinceLastUpdate = tempTimeSinceLastUpdate + elapsed
    if (tempTimeSinceLastUpdate > 0.1) then
      tempTimeSinceLastUpdate = 0
      self:_setUnitPowerType()
      if self._powerTypeString ~= "" then
        self:_setInitialColor()
        tempFrame:SetScript("OnUpdate", nil)
        FramePool47:releaseFrame(tempFrame)
      end
    end
  end)
end
