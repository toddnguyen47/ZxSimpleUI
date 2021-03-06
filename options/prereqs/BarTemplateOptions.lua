local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local Utils47 = ZxSimpleUI.Utils47
local media = LibStub("LibSharedMedia-3.0")
local Locale = LibStub("AceLocale-3.0"):GetLocale(ZxSimpleUI.ADDON_NAME)

local BarTemplateOptions = {}
BarTemplateOptions.__index = BarTemplateOptions
BarTemplateOptions.OPTION_NAME = "BarTemplateOptions"
ZxSimpleUI.optionTables[BarTemplateOptions.OPTION_NAME] = BarTemplateOptions

---@param coreOptions47 table
function BarTemplateOptions:__init__(coreOptions47)
  self.options = {}
  self._coreOptions47 = coreOptions47
  self._currentModule = self._coreOptions47:getCurrentModule()
end

function BarTemplateOptions:new(...)
  local newInstance = setmetatable({}, self)
  newInstance:__init__(...)
  return newInstance
end

function BarTemplateOptions:registerModuleOptionsTable()
  ZxSimpleUI:registerModuleOptions(self._currentModule.MODULE_NAME, self:getOptionTable(),
    self._currentModule.DECORATIVE_NAME)
end

---@param optionTable table
function BarTemplateOptions:addOption(optionTable)
  if next(self.options) == nil then self.options = self:getOptionTable() end
  for k, v in pairs(optionTable) do self.options.args[k] = v end
end

---@return table
function BarTemplateOptions:getOptionTable()
  if next(self.options) == nil then
    self.options = {
      type = "group",
      name = self._currentModule.DECORATIVE_NAME,
      --- "Parent" get/set
      get = function(info) return self._coreOptions47:getOption(info) end,
      set = function(info, value) self._coreOptions47:setOption(info, value) end,
      args = {
        header = {
          type = "header",
          name = self._currentModule.DECORATIVE_NAME,
          order = ZxSimpleUI.HEADER_ORDER_INDEX
        },
        width = {
          name = "Bar Width",
          desc = "Bar Width Size",
          type = "range",
          min = 0,
          max = Utils47:floorToEven(ZxSimpleUI.SCREEN_WIDTH / 2),
          step = 1,
          order = self._coreOptions47:incrementOrderIndex()
        },
        height = {
          name = "Bar Height",
          desc = "Bar Height Size",
          type = "range",
          min = 0,
          max = Utils47:floorToEven(ZxSimpleUI.SCREEN_WIDTH / 2),
          step = 1,
          order = self._coreOptions47:incrementOrderIndex()
        },
        setpoint = {
          name = "Setpoints",
          type = "group",
          inline = true,
          order = self._coreOptions47:incrementOrderIndex(),
          args = {
            framePool = {
              type = "select",
              name = "Frame Pool",
              values = function(info)
                local t1 = {}
                for k, v in pairs(ZxSimpleUI.frameList) do
                  if k ~= self._currentModule.MODULE_NAME then
                    t1[k] = v["name"]
                  end
                end
                return t1
              end,
              order = 10
            },
            selfCurrentPoint = {
              name = "Point",
              desc = "Frame's Anchor Point",
              type = "select",
              order = 11,
              values = {
                ["TOP"] = "TOP",
                ["RIGHT"] = "RIGHT",
                ["BOTTOM"] = "BOTTOM",
                ["LEFT"] = "LEFT",
                ["TOPRIGHT"] = "TOPRIGHT",
                ["TOPLEFT"] = "TOPLEFT",
                ["BOTTOMLEFT"] = "BOTTOMLEFT",
                ["BOTTOMRIGHT"] = "BOTTOMRIGHT",
                ["CENTER"] = "CENTER"
              }
            },
            relativePoint = {
              name = "Relative Point",
              desc = "Relative Point: Frame to anchor to",
              type = "select",
              order = 12,
              values = {
                ["TOP"] = "TOP",
                ["RIGHT"] = "RIGHT",
                ["BOTTOM"] = "BOTTOM",
                ["LEFT"] = "LEFT",
                ["TOPRIGHT"] = "TOPRIGHT",
                ["TOPLEFT"] = "TOPLEFT",
                ["BOTTOMLEFT"] = "BOTTOMLEFT",
                ["BOTTOMRIGHT"] = "BOTTOMRIGHT",
                ["CENTER"] = "CENTER"
              }
            }
          }
        },
        xoffset = {
          name = "Bar X Offset",
          desc = "Bar X Offset",
          type = "range",
          min = -Utils47:floorToEven(ZxSimpleUI.SCREEN_WIDTH / 2),
          max = Utils47:floorToEven(ZxSimpleUI.SCREEN_WIDTH / 2),
          step = 1,
          order = self._coreOptions47:incrementOrderIndex()
        },
        zeroXOffset = {
          name = "Zero X Offset",
          type = "execute",
          func = function(...)
            self._currentModule.db.profile.xoffset = 0
            self._currentModule:refreshConfig()
          end,
          order = self._coreOptions47:incrementOrderIndex()
        },
        yoffset = {
          name = "Bar Y Offset",
          desc = "Bar Y Offset",
          type = "range",
          min = -Utils47:floorToEven(ZxSimpleUI.SCREEN_HEIGHT / 2),
          max = Utils47:floorToEven(ZxSimpleUI.SCREEN_HEIGHT / 2),
          step = 1,
          order = self._coreOptions47:incrementOrderIndex()
        },
        zeroYOffset = {
          name = "Zero Y Offset",
          type = "execute",
          func = function(...)
            self._currentModule.db.profile.yoffset = 0
            self._currentModule:refreshConfig()
          end,
          order = self._coreOptions47:incrementOrderIndex()
        },
        fontsize = {
          name = "Bar Font Size",
          desc = "Bar Font Size",
          type = "range",
          min = 10,
          max = 36,
          step = 1,
          order = self._coreOptions47:incrementOrderIndex()
        },
        -- LSM30_ is LibSharedMedia's custom controls
        font = {
          name = "Bar Font",
          desc = "Bar Font",
          type = "select",
          dialogControl = "LSM30_Font",
          values = media:HashTable("font"),
          order = self._coreOptions47:incrementOrderIndex()
        },
        fontcolor = {
          name = "Bar Font Color",
          desc = "Bar Font Color",
          type = "color",
          get = function(info) return self._coreOptions47:getOptionColor(info) end,
          set = function(info, r, g, b, a)
            self._coreOptions47:setOptionColor(info, r, g, b, a)
          end,
          hasAlpha = false,
          order = self._coreOptions47:incrementOrderIndex()
        },
        texture = {
          name = Locale["texture.name"],
          desc = Locale["texture.desc"],
          type = "select",
          dialogControl = "LSM30_Statusbar",
          values = media:HashTable("statusbar"),
          order = self._coreOptions47:incrementOrderIndex()
        },
        border = {
          name = "Bar Border",
          desc = "Bar Border",
          type = "select",
          dialogControl = "LSM30_Border",
          values = media:HashTable("border"),
          order = self._coreOptions47:incrementOrderIndex()
        },
        color = {
          name = "Bar Color",
          desc = "Bar Color",
          type = "color",
          get = function(info) return self._coreOptions47:getOptionColor(info) end,
          set = function(info, r, g, b, a)
            self._coreOptions47:setOptionColor(info, r, g, b, a)
          end,
          hasAlpha = true,
          order = self._coreOptions47:incrementOrderIndex()
        }
      }
    }
  end
  return self.options
end

---@return table
function BarTemplateOptions:getCurrentModule() return self._currentModule end

---@return table
function BarTemplateOptions:getCoreOptions47() return self._coreOptions47 end
