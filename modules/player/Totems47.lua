---upvalues
local LibStub, CreateFrame = LibStub, CreateFrame
local GetTime, MAX_TOTEMS, GetTotemInfo = GetTime, MAX_TOTEMS, GetTotemInfo
local UnitClass = UnitClass

---include files
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local Locale = LibStub("AceLocale-3.0"):GetLocale(ZxSimpleUI.ADDON_NAME)

-- #region
local MODULE_NAME = "Totems47"
local DECORATIVE_NAME = Locale["module.decName.totemsDisplay"]
local Totems47 = ZxSimpleUI:NewModule(MODULE_NAME)
local media = LibStub("LibSharedMedia-3.0")

Totems47.MODULE_NAME = MODULE_NAME
Totems47.DECORATIVE_NAME = DECORATIVE_NAME
Totems47.unit = "player"
-- #endregion

function Totems47:__init__()
  self.PLAYER_ENGLISH_CLASS = select(2, UnitClass("player"))
  self._eventTable = {"PLAYER_TOTEM_UPDATE"}
  self._defaults = {
    profile = {
      enabledToggle = Totems47.PLAYER_ENGLISH_CLASS == "SHAMAN",
      height = 35,
      yoffset = -2,
      font = "Lato Bold",
      fontsize = 14,
      fontcolor = {1.0, 1.0, 1.0},
      outline = true,
      thickoutline = false,
      monochrome = false,
      framePool = "PlayerPower47"
    }
  }

  ---Ref: https://wow.gamepedia.com/API_GetTotemInfo
  self.TOTEM_TABLE = {[1] = "Fire", [2] = "Earth", [3] = "Water", [4] = "Air"}
  self._totemTypeDisplayOrder = {2, 1, 3, 4}
  self.mainFrame = nil
  self._frameToAnchorTo = nil
  self._totemBarList = {}
end

---Do init tasks here, like loading the Saved Variables,
---Or setting up slash commands.
function Totems47:OnInitialize()
  self:__init__()
  self.db = ZxSimpleUI.db:RegisterNamespace(MODULE_NAME, self._defaults)

  -- Always set the showbar option to false on initialize
  self.db.profile.showbar = self._defaults.profile.showbar

  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(MODULE_NAME))
end

---Do more initialization here, that really enables the use of your addon.
---Register Events, Hook functions, Create Frames, Get information from
---the game that wasn't available in OnInitialize
function Totems47:OnEnable()
  if self.mainFrame == nil then self:createBar() end
  self:_registerAllEvents()
  self:_enableAllScriptHandlers()
  for i = 1, MAX_TOTEMS do self:_handlePlayerTotemUpdate(self._totemBarList[i], i) end
  self.mainFrame:Show()
end

---Unhook, Unregister Events, Hide frames that you created.
---You would probably only use an OnDisable if you want to
---build a "standby" mode, or be able to toggle modules on/off.
function Totems47:OnDisable()
  if self.mainFrame == nil then self:createBar() end
  self:_unregisterAllEvents()
  self:_disableAllScriptHandlers()
  self.mainFrame:Hide()
end

function Totems47:createBar()
  self._frameToAnchorTo = ZxSimpleUI:getFrameListFrame(self.db.profile.framePool)

  self.mainFrame = CreateFrame("Frame", nil, self._frameToAnchorTo)
  self.mainFrame.DECORATIVE_NAME = self.DECORATIVE_NAME
  self.mainFrame.frameToAnchorTo = self._frameToAnchorTo
  self.mainFrame:SetFrameLevel(ZxSimpleUI.DEFAULT_FRAME_LEVEL + 2)

  self:_createTotemFrames()
  ZxSimpleUI:addToFrameList(self.MODULE_NAME,
    {frame = self.mainFrame, name = self.DECORATIVE_NAME})
  return self.mainFrame
end

function Totems47:refreshConfig()
  self:handleEnableToggle()
  if self:IsEnabled() then self:_refreshAll() end
end

function Totems47:handleEnableToggle()
  ZxSimpleUI:setModuleEnabledState(MODULE_NAME, self.db.profile.enabledToggle)
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

function Totems47:_refreshAll()
  self:_refreshBarFrame()
  self:_refreshTotemBars()
end

function Totems47:_refreshBarFrame()
  self._frameToAnchorTo = ZxSimpleUI:getFrameListFrame(self.db.profile.framePool)

  self.mainFrame:SetWidth(self._frameToAnchorTo:GetWidth())
  self.mainFrame:SetHeight(self.db.profile.height)
  self.mainFrame:ClearAllPoints() -- Ref: https://wow.gamepedia.com/API_Region_SetPoint#Details
  self.mainFrame:SetPoint("TOPLEFT", self._frameToAnchorTo, "BOTTOMLEFT", 0,
    self.db.profile.yoffset)
end

function Totems47:_refreshTotemBars()
  local mainFrameWidth = self.mainFrame:GetWidth()
  local mainFrameHeight = self.mainFrame:GetHeight()
  local totalTotemWidth = mainFrameHeight * MAX_TOTEMS
  local horizGap = math.floor((mainFrameWidth - totalTotemWidth) / (MAX_TOTEMS - 1))

  for i = 1, #self._totemTypeDisplayOrder do
    local totemPos = self._totemTypeDisplayOrder[i]
    local totemFrame = self._totemBarList[totemPos]
    totemFrame:SetWidth(mainFrameHeight)
    totemFrame:SetHeight(mainFrameHeight)
    totemFrame.durationText:SetFont(media:Fetch("font", self.db.profile.font),
      self.db.profile.fontsize, self:_getFontFlags())
    totemFrame.durationText:SetTextColor(unpack(self.db.profile.fontcolor))

    totemFrame:ClearAllPoints() -- Ref: https://wow.gamepedia.com/API_Region_SetPoint#Details
    if i == 1 then
      totemFrame:SetPoint("TOPLEFT", self._frameToAnchorTo, "BOTTOMLEFT", 0,
        self.db.profile.yoffset)
    else
      local leftTotemPos = self._totemTypeDisplayOrder[i - 1]
      totemFrame:SetPoint("TOPLEFT", self._totemBarList[leftTotemPos], "TOPRIGHT", horizGap, 0)
    end
  end
end

function Totems47:_createTotemFrames()
  for i = 1, MAX_TOTEMS do
    local totemFrame = CreateFrame("Frame", nil, self.mainFrame)
    totemFrame.lastUpdatedTime = 0
    totemFrame.parent = self.mainFrame
    totemFrame:SetFrameLevel(self.mainFrame:GetFrameLevel() + 1)

    totemFrame.texture = totemFrame:CreateTexture(nil, "OVERLAY")
    totemFrame.texture:SetAllPoints(totemFrame)

    totemFrame.durationText = totemFrame:CreateFontString(nil, "BORDER")
    totemFrame.durationText:SetPoint("TOP", totemFrame, "BOTTOM", 0, -2)
    totemFrame.durationText:SetFont(media:Fetch("font", self.db.profile.font),
      self.db.profile.fontsize, self:_getFontFlags())

    totemFrame:Hide()
    self._totemBarList[i] = totemFrame
  end
end

function Totems47:_registerAllEvents()
  for _, event in pairs(self._eventTable) do self.mainFrame:RegisterEvent(event) end
end

function Totems47:_unregisterAllEvents()
  for _, event in pairs(self._eventTable) do self.mainFrame:UnregisterEvent(event) end
end

function Totems47:_enableAllScriptHandlers()
  self.mainFrame:SetScript("OnEvent", function(curFrame, event, arg1, arg2, arg3, ...)
    self:_onEventHandler(curFrame, event, arg1, arg2, arg3, ...)
  end)
end

function Totems47:_disableAllScriptHandlers() self.mainFrame:SetScript("OnEvent", nil) end

function Totems47:_onEventHandler(curFrame, event, arg1, arg2, arg3, ...)
  if event == "PLAYER_TOTEM_UPDATE" then self:_handlePlayerTotemUpdate(curFrame, arg1) end
end

---@param curFrame table
---@param totemSlot integer 1-4, see TOTEM_TABLE
function Totems47:_handlePlayerTotemUpdate(curFrame, totemSlot)
  ---Ref: https://wow.gamepedia.com/API_GetTotemInfo
  local haveTotem, totemName, startTime, duration, icon = GetTotemInfo(totemSlot)
  local totemFrame = self._totemBarList[totemSlot]
  if totemName ~= nil and totemName ~= "" then
    ---Ref: https://wow.gamepedia.com/API_Texture_SetTexture
    totemFrame.texture:SetTexture(icon)
    totemFrame.texture:SetAlpha(1.0) -- this is needed, otherwise alpha might be stuck at 0.4
    local timeLeft = self:_getTimeLeft(startTime, duration)
    self:_setDurationText(totemFrame, timeLeft)
    totemFrame:Show()
    totemFrame:SetScript("OnUpdate", function(curFrame, elapsedTime)
      curFrame.lastUpdatedTime = curFrame.lastUpdatedTime + elapsedTime
      -- Only update once every 500ms until the last 3 seconds
      timeLeft = self:_getTimeLeft(startTime, duration)
      -- If time is greater than 60s, update once a second
      if (timeLeft > 60 and curFrame.lastUpdatedTime < 1.0) then return end
      -- If time is less than 60s, update once every half second
      if (timeLeft > 3 and curFrame.lastUpdatedTime < 0.5) then return end

      curFrame.lastUpdatedTime = 0

      self:_setDurationText(curFrame, timeLeft)
      if timeLeft < 2 then curFrame.texture:SetAlpha(0.4) end
      if timeLeft <= 0 then self:_handleTotemDurationComplete(curFrame) end
    end)
  else
    self:_handleTotemDurationComplete(totemFrame)
  end
end

---@param totemFrame table
function Totems47:_handleTotemDurationComplete(totemFrame)
  totemFrame.texture:SetTexture(nil)
  totemFrame.durationText:SetText("")
  totemFrame:SetScript("OnUpdate", nil)
  totemFrame:Hide()
end

---@param totemFrame table
---@param timeLeft integer
function Totems47:_setDurationText(totemFrame, timeLeft)
  local formatString = ""
  if timeLeft > 60 then
    timeLeft = math.ceil(timeLeft / 60)
    formatString = "%dm"
  elseif timeLeft > 1.0 then
    formatString = "%.0fs"
  else
    formatString = "%.1fs"
  end
  totemFrame.durationText:SetText(string.format(formatString, timeLeft))
end

function Totems47:_getTimeLeft(startTime, duration)
  local currentTime = GetTime()
  local endTime = startTime + duration
  local timeLeft = endTime - currentTime
  return timeLeft
end

---@return string
function Totems47:_getFontFlags()
  local s = ""
  if self.db.profile.outline then s = s .. "OUTLINE, " end
  if self.db.profile.thickoutline then s = s .. "THICKOUTLINE, " end
  if self.db.profile.monochrome then s = s .. "MONOCHROME, " end
  if s ~= "" then s = string.sub(s, 0, (string.len(s) - 2)) end
  return s
end
