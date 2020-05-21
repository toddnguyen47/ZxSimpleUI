local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local Utils47 = ZxSimpleUI.Utils47

local _MODULE_NAME = "Combo47"
local _DECORATIVE_NAME = "Combo Points Display"
local Combo47 = ZxSimpleUI:NewModule(_MODULE_NAME)
local media = LibStub("LibSharedMedia-3.0")

--- upvalues to prevent warnings
local LibStub = LibStub
local UIParent, CreateFrame = UIParent, CreateFrame
local MAX_COMBO_POINTS, GetComboPoints = MAX_COMBO_POINTS, GetComboPoints
local UnitName = UnitName
local UnitHealth, UnitPowerType = UnitHealth, UnitPowerType
local ToggleDropDownMenu, TargetFrameDropDown = ToggleDropDownMenu, TargetFrameDropDown
local unpack = unpack

Combo47.MODULE_NAME = _MODULE_NAME
Combo47.bars = nil
Combo47.unit = "target"

local _defaults = {profile = {texture = "Blizzard"}}

function Combo47:OnInitialize()
  self.db = ZxSimpleUI.db:RegisterNamespace(_MODULE_NAME, _defaults)
  self._curDbProfile = self.db.profile

  self:__init__()

  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(_MODULE_NAME))
  ZxSimpleUI:registerModuleOptions(_MODULE_NAME, self:_getOptionTable(), _DECORATIVE_NAME)
end

function Combo47:OnEnable()
end

function Combo47:__init__()
  self.options = {}
  self.mainFrame = nil

  self._orderIndex = ZxSimpleUI.DEFAULT_ORDER_INDEX
  self._comboPointsTable = {}
  self._allComboPointsHidden = true
  self._shownOption = true

  self._MEDIUM_COMBO_POINTS = 3
  self._yellowColor = {1.0, 1.0, 0.0, 1.0}
  self._orangeColor = {1.0, 0.65, 0.0, 1.0}
  self._redColor = {1.0, 0.0, 0.0, 1.0}

end

---@param frameToAttachTo table
function Combo47:createBar(frameToAttachTo)
  assert(frameToAttachTo ~= nil)
  local horizGap = 15
  local totalNumberOfGaps = horizGap * (MAX_COMBO_POINTS - 1)
  local comboWidth = (frameToAttachTo:GetWidth() - totalNumberOfGaps) / MAX_COMBO_POINTS
  local comboHeight = 8

  self.mainFrame = CreateFrame("Frame", nil, frameToAttachTo)
  self.mainFrame:SetFrameLevel(ZxSimpleUI.DEFAULT_FRAME_LEVEL + 2)
  self.mainFrame:SetWidth(frameToAttachTo:GetWidth())
  self.mainFrame:SetHeight(comboHeight)
  self.mainFrame:SetPoint("BOTTOMLEFT", frameToAttachTo, "TOPLEFT", 0, 0)

  self:_createIndividualComboPointsDisplay(frameToAttachTo)
  self:_registerEvents()
  self:_setOnShowOnHideHandlers()
  self:_enableAllScriptHandlers()

  return self.mainFrame
end

function Combo47:refreshConfig()
  if self:IsEnabled() then self:_refreshStatusBar() end
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

---@param frameToAttachTo table
function Combo47:_createIndividualComboPointsDisplay(frameToAttachTo)
  local horizGap = 15
  local totalNumberOfGaps = horizGap * (MAX_COMBO_POINTS - 1)
  local comboWidth = (frameToAttachTo:GetWidth() - totalNumberOfGaps) / MAX_COMBO_POINTS
  local comboHeight = 8
  -- Create all MAX_COMBO_POINTS frames
  for i = 1, MAX_COMBO_POINTS do
    local parentFrame, anchorDirection = nil, nil
    local xoffset, yoffset = 0, 0
    if i == 1 then
      parentFrame = self.mainFrame
      anchorDirection = "BOTTOMLEFT"
      xoffset = 0
      yoffset = 0
    else
      parentFrame = self._comboPointsTable[i - 1]
      anchorDirection = "BOTTOMRIGHT"
      xoffset = horizGap
      yoffset = 0
    end
    local comboTexture = self.mainFrame:CreateTexture(nil, "OVERLAY")
    comboTexture:ClearAllPoints()
    comboTexture:SetWidth(comboWidth)
    comboTexture:SetHeight(comboHeight)
    comboTexture:SetPoint("BOTTOMLEFT", parentFrame, anchorDirection, xoffset, yoffset)
    comboTexture:SetTexture(media:Fetch("statusbar", self._curDbProfile.texture))
    comboTexture:SetVertexColor(unpack(self._yellowColor))
    comboTexture:Hide()
    self._comboPointsTable[i] = comboTexture
  end
end

function Combo47:_registerEvents()
  self.mainFrame:RegisterEvent("UNIT_COMBO_POINTS")
  self.mainFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
end

function Combo47:_setOnShowOnHideHandlers()
  self.mainFrame:SetScript(
    "OnShow", function(argsTable, ...)
      if self:IsEnabled() then
        self:_enableAllScriptHandlers()
      else
        self.mainFrame:Hide()
      end
    end)

  self.mainFrame:SetScript(
    "OnHide", function(argsTable, ...)
      self:_disableAllScriptHandlers()
    end)
end

function Combo47:_enableAllScriptHandlers()
  self.mainFrame:SetScript(
    "OnEvent", function(argsTable, event, unit)
      self:_onEventHandler(argsTable, event, unit)
    end)
end

function Combo47:_disableAllScriptHandlers()
  -- Do not disable OnEvent in Combo Points since we are not using RegisterUnitWatch to display
  -- self.mainFrame:SetScript("OnEvent", nil)
end

function Combo47:_onEventHandler(argsTable, event, unit)
  if Utils47:stringEqualsIgnoreCase(event, "PLAYER_TARGET_CHANGED") then
    self:_handlePlayerTargetChanged()
  elseif Utils47:stringEqualsIgnoreCase(event, "UNIT_COMBO_POINTS") then
    self:_handleComboPoints()
  end
end

---@return table
function Combo47:_getOptionTable()
  if next(self.options) == nil then
    self.options = {
      type = "group",
      name = _DECORATIVE_NAME,
      get = function(infoTable)
        return self:_getOption(infoTable)
      end,
      set = function(infoTable, value)
        self:_setOption(infoTable, value)
      end,
      args = {
        header = {
          type = "header",
          name = _DECORATIVE_NAME,
          order = self:_incrementOrderIndex()
        },
        showbar = {
          type = "execute",
          name = "Show Display",
          desc = "Show/Hide the Combo Points Display",
          order = self:_incrementOrderIndex(),
          func = function(curFrame, button, isUp)
            if self._shownOption then
              self.mainFrame:Show()
              self:_showAllComboPoints()
            else
              self.mainFrame:Hide()
              self:_hideAllComboPoints()
            end
            self._shownOption = not self._shownOption
          end
        },
        texture = {
          name = "Bar Texture",
          desc = "Bar Texture",
          type = "select",
          dialogControl = "LSM30_Statusbar",
          values = media:HashTable("statusbar"),
          order = self:_incrementOrderIndex()
        }
      }
    }
  end
  return self.options
end

---@param infoTable table
function Combo47:_getOption(infoTable)
  -- Not sure how this gets the key... but it does
  local key = infoTable[#infoTable]
  return self._curDbProfile[key]
end

---@param infoTable table
---@param value any
function Combo47:_setOption(infoTable, value)
  -- Not sure how this gets the key... but it does
  local key = infoTable[#infoTable]
  self._curDbProfile[key] = value
  self:refreshConfig()
end

---@param infoTable table
function Combo47:_getOptionColor(infoTable)
  return unpack(self:_getOption(infoTable))
end

---@param infoTable table
function Combo47:_setOptionColor(infoTable, r, g, b, a)
  self:_setOption(infoTable, {r, g, b, a})
end

function Combo47:_incrementOrderIndex()
  local i = self._orderIndex
  self._orderIndex = self._orderIndex + 1
  return i
end

function Combo47:_hideAllComboPoints()
  for i = 1, MAX_COMBO_POINTS do self._comboPointsTable[i]:Hide() end
end

function Combo47:_showAllComboPoints()
  for i = 1, MAX_COMBO_POINTS do self._comboPointsTable[i]:Show() end
end

---@param comboPoints integer
---@param currentTexture table
function Combo47:_setComboPointsColor(comboPoints, currentTexture)
  if comboPoints >= MAX_COMBO_POINTS then
    currentTexture:SetVertexColor(unpack(self._redColor))
  elseif comboPoints >= self._MEDIUM_COMBO_POINTS then
    currentTexture:SetVertexColor(unpack(self._orangeColor))
  else
    currentTexture:SetVertexColor(unpack(self._yellowColor))
  end
end

function Combo47:_handleComboPoints()
  local comboPoints = GetComboPoints("player", self.unit)
  if not self._allComboPointsHidden and comboPoints == 0 then
    self:_hideAllComboPoints()
    self._allComboPointsHidden = true
  else
    for i = 1, comboPoints do
      local currentTexture = self._comboPointsTable[i]
      self:_setComboPointsColor(comboPoints, currentTexture)
      currentTexture:Show()
      self._allComboPointsHidden = false
    end
  end
end

function Combo47:_handlePlayerTargetChanged()
  local targetName = UnitName(self.unit)
  if targetName ~= nil and targetName ~= "" then self:_handleComboPoints() end
end

function Combo47:_refreshStatusBar()
  for _, texture in pairs(self._comboPointsTable) do
    texture:SetTexture(media:Fetch("statusbar", self._curDbProfile.texture), "BORDER")
  end
  -- self.mainFrame.statusBar:SetStatusBarColor(unpack(self._curDbProfile.color))
end