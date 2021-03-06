local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local media = LibStub("LibSharedMedia-3.0")
local Locale = LibStub("AceLocale-3.0"):GetLocale(ZxSimpleUI.ADDON_NAME)

---@class Aura47Options
local Aura47Options = {}
Aura47Options.__index = Aura47Options
Aura47Options.OPTION_NAME = "Aura47Options"
ZxSimpleUI.optionTables[Aura47Options.OPTION_NAME] = Aura47Options

function Aura47Options:__init__()
  self.options = {}
  self._currentModule = self._coreOptions47:getCurrentModule()
end

---@param coreOptions47 CoreOptions47
---@return Aura47Options
function Aura47Options:new(coreOptions47)
  ---@type Aura47Options
  local newInstance = setmetatable({}, self)
  newInstance._coreOptions47 = coreOptions47
  newInstance:__init__()
  return newInstance
end

function Aura47Options:registerModuleOptionsTable()
  ZxSimpleUI:registerModuleOptions(self._currentModule.MODULE_NAME, self:getOptionTable(),
    self._currentModule.DECORATIVE_NAME)
end

---@return table
function Aura47Options:getOptionTable()
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
          width = "full",
          disabled = function(info) return self._currentModule.db.profile.showbar end
        },
        showbar = {
          name = "Show Debuff Bar",
          desc = "Show Debuff Bar",
          type = "toggle",
          order = ZxSimpleUI.HEADER_ORDER_INDEX + 2,
          disabled = function(info)
            return not self._currentModule.db.profile.enabledToggle
          end
        },
        height = {
          name = "Height",
          desc = "Height Size",
          type = "range",
          min = 10,
          max = 50,
          step = 1,
          order = self._coreOptions47:incrementOrderIndex()
        },
        yoffset = {
          name = "Y Offset",
          desc = "Y Offset",
          type = "range",
          min = -20,
          max = 20,
          step = 1,
          order = self._coreOptions47:incrementOrderIndex()
        },
        framePool = {
          type = "select",
          name = "Frame Pool",
          values = function(info)
            local t1 = {}
            for k, v in pairs(ZxSimpleUI.frameList) do
              if k ~= self._currentModule.MODULE_NAME then t1[k] = v["name"] end
            end
            return t1
          end,
          order = 10
        },
        buffsPerRow = {
          name = "Buffs Per Row",
          type = "range",
          min = 1,
          max = 10,
          step = 1,
          order = self._coreOptions47:incrementOrderIndex()
        },
        durationLeftFade = {
          name = "Duration To Fade",
          desc = "Duration left (in seconds) to start fading out",
          type = "range",
          min = 1,
          max = 30,
          step = 1,
          order = self._coreOptions47:incrementOrderIndex()
        }
      }
    }
  end
  return self.options
end
