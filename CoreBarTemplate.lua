---References:
---https://wowwiki.fandom.com/wiki/SecureActionButtonTemplate
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local media = LibStub("LibSharedMedia-3.0")

--- upvalues to prevent warnings
local LibStub = LibStub
local UIParent, CreateFrame = UIParent, CreateFrame
local unpack, next = unpack, next

local CoreBarTemplate = {}
CoreBarTemplate.__index = CoreBarTemplate
ZxSimpleUI.CoreBarTemplate = CoreBarTemplate

function CoreBarTemplate:new(curDbProfile)
  local newInstance = setmetatable({}, CoreBarTemplate)
  newInstance:__init__(curDbProfile)
  return newInstance
end

function CoreBarTemplate:__init__(curDbProfile)
  -- Start order index at 10 so other modules can easily put options in front
  self._orderIndex = ZxSimpleUI.DEFAULT_ORDER_INDEX
  self._curDbProfile = curDbProfile
  self.mainFrame = nil

  self.defaults = {
    profile = {
      width = 200,
      height = 26,
      positionx = 400,
      positiony = 280,
      fontsize = 14,
      font = "Friz Quadrata TT",
      fontcolor = {1.0, 1.0, 1.0},
      texture = "Blizzard",
      color = {0.0, 1.0, 0.0, 1.0},
      border = "None"
    }
  }
  self.frameBackdropTable = {
    bgFile = "Interface\\DialogFrame\\UI-Tooltip-Background",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = {left = 4, right = 4, top = 4, bottom = 4}
  }
  self.options = {}
end

---@param percentValue number 0 to 1
---@return table
function CoreBarTemplate:createBar(percentValue)
  -- self.mainFrame = CreateFrame("Frame", nil, UIParent)
  self.mainFrame = CreateFrame("Button", nil, UIParent, "SecureUnitButtonTemplate")
  self.mainFrame:SetFrameLevel(ZxSimpleUI.DEFAULT_FRAME_LEVEL)
  self.mainFrame:SetBackdrop(self.frameBackdropTable)
  self.mainFrame:SetBackdropColor(1, 0, 0, 1)
  self.mainFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", self._curDbProfile.positionx,
    self._curDbProfile.positiony)

  self:_setMouseClicks()

  self.mainFrame.bgFrame = self.mainFrame:CreateTexture(nil, "BACKGROUND")
  self.mainFrame.bgFrame:SetTexture(0, 0, 0, 0.8)
  self.mainFrame.bgFrame:SetAllPoints()

  self.mainFrame.statusBar = CreateFrame("StatusBar", nil, self.mainFrame)
  self.mainFrame.statusBar:ClearAllPoints()
  self.mainFrame.statusBar:SetPoint("CENTER", self.mainFrame, "CENTER")
  local texture = media:Fetch("statusbar", self._curDbProfile.texture)
  self.mainFrame.statusBar:SetStatusBarTexture(texture, "BORDER")
  self.mainFrame.statusBar:GetStatusBarTexture():SetHorizTile(false)
  self.mainFrame.statusBar:GetStatusBarTexture():SetVertTile(false)
  self.mainFrame.statusBar:SetStatusBarColor(unpack(self._curDbProfile.color))
  self.mainFrame.statusBar:SetMinMaxValues(0, 1)
  self.mainFrame.statusBar:SetValue(percentValue)
  self:_setFrameWidthHeight()

  self.mainFrame.mainText = self.mainFrame.statusBar:CreateFontString(nil, "BORDER")
  self.mainFrame.mainText:SetFont(media:Fetch("font", self._curDbProfile.font),
    self._curDbProfile.fontsize, "OUTLINE")
  self.mainFrame.mainText:SetTextColor(unpack(self._curDbProfile.fontcolor))
  self.mainFrame.mainText:SetPoint("CENTER", self.mainFrame.statusBar, "CENTER", 0, 0)
  self.mainFrame.mainText:SetText(string.format("%.1f%%", percentValue * 100.0))

  self.mainFrame:Show()
  return self.mainFrame
end

---@return table
function CoreBarTemplate:getOptionTable(decorativeName)
  if next(self.options) == nil then
    self.options = {
      type = "group",
      name = decorativeName,
      get = function(infoTable)
        return self:_getOption(infoTable)
      end,
      set = function(infoTable, value)
        self:_setOption(infoTable, value)
      end,
      args = {
        header = {type = "header", name = decorativeName, order = self:_incrementOrderIndex()},
        width = {
          name = "Bar Width",
          desc = "Bar Width Size",
          type = "range",
          min = 0,
          max = math.floor(ZxSimpleUI.SCREEN_WIDTH / 2),
          step = 2,
          get = function(infoTable)
            return self:_getOption(infoTable)
          end,
          set = function(infoTable, value)
            self:_setOption(infoTable, value)
          end,
          order = self:_incrementOrderIndex()
        },
        height = {
          name = "Bar Height",
          desc = "Bar Height Size",
          type = "range",
          min = 0,
          max = math.floor(ZxSimpleUI.SCREEN_WIDTH / 2),
          step = 2,
          get = function(infoTable)
            return self:_getOption(infoTable)
          end,
          set = function(infoTable, value)
            self:_setOption(infoTable, value)
          end,
          order = self:_incrementOrderIndex()
        },
        positionx = {
          name = "Bar X",
          desc = "Bar X Position",
          type = "range",
          min = 0,
          max = ZxSimpleUI.SCREEN_WIDTH,
          step = 1,
          get = function(infoTable)
            return self:_getOption(infoTable)
          end,
          set = function(infoTable, value)
            self:_setOption(infoTable, value)
          end,
          order = self:_incrementOrderIndex()
        },
        positionx_center = {
          name = "Center Bar X",
          desc = "Center Bar X Position",
          type = "execute",
          func = function(...)
            self:handlePositionXCenter()
          end,
          order = self:_incrementOrderIndex()
        },
        positiony = {
          name = "Bar Y",
          desc = "Bar Y Position",
          type = "range",
          min = 0,
          max = ZxSimpleUI.SCREEN_HEIGHT,
          step = 1,
          get = function(infoTable)
            return self:_getOption(infoTable)
          end,
          set = function(infoTable, value)
            self:_setOption(infoTable, value)
          end,
          order = self:_incrementOrderIndex()
        },
        positiony_center = {
          name = "Center Bar Y",
          desc = "Center Bar Y Position",
          type = "execute",
          func = function(...)
            self:handlePositionYCenter()
          end,
          order = self:_incrementOrderIndex()
        },
        fontsize = {
          name = "Bar Font Size",
          desc = "Bar Font Size",
          type = "range",
          min = 10,
          max = 36,
          step = 1,
          get = function(infoTable)
            return self:_getOption(infoTable)
          end,
          set = function(infoTable, value)
            self:_setOption(infoTable, value)
          end,
          order = self:_incrementOrderIndex()
        },
        -- LSM30_ is LibSharedMedia's custom controls
        font = {
          name = "Bar Font",
          desc = "Bar Font",
          type = "select",
          dialogControl = "LSM30_Font",
          values = media:HashTable("font"),
          order = self:_incrementOrderIndex()
        },
        fontcolor = {
          name = "Bar Font Color",
          desc = "Bar Font Color",
          type = "color",
          get = function(infoTable)
            return self:_getOptionColor(infoTable)
          end,
          set = function(infoTable, r, g, b, a)
            self:_setOptionColor(infoTable, r, g, b, a)
          end,
          hasAlpha = false,
          order = self:_incrementOrderIndex()
        },
        texture = {
          name = "Bar Texture",
          desc = "Bar Texture",
          type = "select",
          dialogControl = "LSM30_Statusbar",
          values = media:HashTable("statusbar"),
          order = self:_incrementOrderIndex()
        },
        border = {
          name = "Bar Border",
          desc = "Bar Border",
          type = "select",
          dialogControl = "LSM30_Border",
          values = media:HashTable("border"),
          order = self:_incrementOrderIndex()
        },
        color = {
          name = "Bar Color",
          desc = "Bar Color",
          type = "color",
          get = function(infoTable)
            return self:_getOptionColor(infoTable)
          end,
          set = function(infoTable, r, g, b, a)
            self:_setOptionColor(infoTable, r, g, b, a)
          end,
          hasAlpha = true,
          order = self:_incrementOrderIndex()
        }
      }
    }
  end
  return self.options
end

function CoreBarTemplate:refreshConfig()
  self:_setFrameWidthHeight()
  self:_refreshBarFrame()
  self:_refreshStatusBar()
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

function CoreBarTemplate:_incrementOrderIndex()
  local i = self._orderIndex
  self._orderIndex = self._orderIndex + 1
  return i
end

---@param infoTable table
function CoreBarTemplate:_getOption(infoTable)
  -- Not sure how this gets the key... but it does
  local key = infoTable[#infoTable]
  return self._curDbProfile[key]
end

---@param infoTable table
---@param value any
function CoreBarTemplate:_setOption(infoTable, value)
  -- Not sure how this gets the key... but it does
  local key = infoTable[#infoTable]
  self._curDbProfile[key] = value
  self:refreshConfig()
end

---@param infoTable table
function CoreBarTemplate:_getOptionColor(infoTable)
  return unpack(self:_getOption(infoTable))
end

---@param infoTable table
function CoreBarTemplate:_setOptionColor(infoTable, r, g, b, a)
  self:_setOption(infoTable, {r, g, b, a})
end

function CoreBarTemplate:handlePositionXCenter()
  local width = self._curDbProfile.width

  local centerXPos = math.floor(ZxSimpleUI.SCREEN_WIDTH / 2 - width / 2)
  self._curDbProfile.positionx = centerXPos
  self:refreshConfig()
end

function CoreBarTemplate:handlePositionYCenter()
  local height = self._curDbProfile.height

  local centerYPos = math.floor(ZxSimpleUI.SCREEN_HEIGHT / 2 - height / 2)
  self._curDbProfile.positiony = centerYPos
  self:refreshConfig()
end

function CoreBarTemplate:_setFrameWidthHeight()
  self.mainFrame:SetWidth(self._curDbProfile.width)
  self.mainFrame:SetHeight(self._curDbProfile.height)
  self.mainFrame.bgFrame:SetWidth(self.mainFrame:GetWidth())
  self.mainFrame.bgFrame:SetHeight(self.mainFrame:GetHeight())
  self.mainFrame.statusBar:SetWidth(self.mainFrame:GetWidth())
  self.mainFrame.statusBar:SetHeight(self.mainFrame:GetHeight())
end

function CoreBarTemplate:_refreshBarFrame()
  self.mainFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", self._curDbProfile.positionx,
    self._curDbProfile.positiony)
  self.mainFrame:SetBackdrop(self.frameBackdropTable)

  self.frameBackdropTable.edgeFile = media:Fetch("border", self._curDbProfile.border)

  self.mainFrame.mainText:SetFont(media:Fetch("font", self._curDbProfile.font),
    self._curDbProfile.fontsize, "OUTLINE")
  self.mainFrame.mainText:SetTextColor(unpack(self._curDbProfile.fontcolor))
end

function CoreBarTemplate:_refreshStatusBar()
  local texture = media:Fetch("statusbar", self._curDbProfile.texture)
  self.mainFrame.statusBar:SetStatusBarTexture(texture, "BORDER")
  self.mainFrame.statusBar:SetStatusBarColor(unpack(self._curDbProfile.color))
end

---@param percentValue number from 0.0 to 1.0
function CoreBarTemplate:_setStatusBarValue(percentValue)
  self.mainFrame.mainText:SetText(string.format("%.1f%%", percentValue * 100.0))
  self.mainFrame.statusBar:SetValue(percentValue)
end

---@param strInput string
function CoreBarTemplate:_setTextOnly(strInput)
  self.mainFrame.mainText:SetText(strInput)
end

function CoreBarTemplate:_setMouseClicks()
  self.mainFrame:RegisterForClicks("AnyUp")
  -- Set left click
  self.mainFrame:SetAttribute("*type1", "target")
  -- Set right click
  self.mainFrame:SetAttribute("*type2", "menu")
end
