local MAX_COMBO_POINTS = MAX_COMBO_POINTS

local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local media = LibStub("LibSharedMedia-3.0")
local Locale = LibStub("AceLocale-3.0"):GetLocale(ZxSimpleUI.ADDON_NAME)

local Totems47Options = {}
Totems47Options.__index = Totems47Options
Totems47Options.OPTION_NAME = "Totems47Options"
ZxSimpleUI.optionTables[Totems47Options.OPTION_NAME] = Totems47Options

---@param coreOptions47 table
function Totems47Options:__init__(coreOptions47)
  self.options = {}
  self._coreOptions47 = coreOptions47
  self._currentModule = self._coreOptions47:getCurrentModule()
end

function Totems47Options:new(...)
  local newInstance = setmetatable({}, self)
  newInstance:__init__(...)
  return newInstance
end

function Totems47Options:registerModuleOptionsTable()
  ZxSimpleUI:registerModuleOptions(self._currentModule.MODULE_NAME, self:getOptionTable(),
    self._currentModule.DECORATIVE_NAME)
end

---@return table
function Totems47Options:getOptionTable()
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
        enabledToggle = {
          type = "toggle",
          name = Locale["enabledToggle.name"],
          desc = Locale["enabledToggle.desc"],
          order = ZxSimpleUI.HEADER_ORDER_INDEX + 1,
          width = "full"
        },
        height = {
          name = "Totem Height",
          desc = "Totem display height",
          type = "range",
          min = 2,
          max = 50,
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
            yoffset = {
              name = "Y Offset",
              desc = "Y Offset",
              type = "range",
              min = -30,
              max = 30,
              step = 1,
              order = 11
            }
          }
        },
        -- LSM30_ is LibSharedMedia's custom controls
        font = {
          name = "Totem Duration Font",
          desc = "Totem Duration Font",
          type = "select",
          dialogControl = "LSM30_Font",
          values = media:HashTable("font"),
          order = self._coreOptions47:incrementOrderIndex()
        },
        fontsize = {
          name = "Totem Duration Font Size",
          desc = "Totem Duration Font Size",
          type = "range",
          min = 10,
          max = 36,
          step = 1,
          order = self._coreOptions47:incrementOrderIndex()
        },
        fontflags = {
          name = "Font Flags",
          type = "group",
          inline = true,
          order = self._coreOptions47:incrementOrderIndex(),
          args = {
            outline = {name = "Outline", type = "toggle", order = 1},
            thickoutline = {name = "Thick Outline", type = "toggle", order = 2},
            monochrome = {name = "Monochrome", type = "toggle", order = 3}
          }
        },
        fontcolor = {
          name = "Totem Duration Color",
          desc = "Totem Duration Color",
          type = "color",
          get = function(info) return self._coreOptions47:getOptionColor(info) end,
          set = function(info, r, g, b, a)
            self._coreOptions47:setOptionColor(info, r, g, b, a)
          end,
          hasAlpha = false,
          order = self._coreOptions47:incrementOrderIndex()
        }
      }
    }
  end
  return self.options
end

