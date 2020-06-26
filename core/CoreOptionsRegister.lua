local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local Utils47 = ZxSimpleUI.Utils47
---@type CoreFactory47
local CoreFactory47 = ZxSimpleUI.CoreFactory47

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")

---@class CoreOptionsRegister
local CoreOptionsRegister = ZxSimpleUI:NewModule("Options", nil)

-- PRIVATE functions and variables
---@param key string
local _OPEN_OPTION_APPNAME = "ZxSimpleGUI_OpenOption"

function CoreOptionsRegister:OnInitialize()
  self._curDbProfile = ZxSimpleUI.db.profile
  self._openOptionTable = {}
  self._options = {}
  self._printFrameOptionTable = {}
  self._frame = nil
  self:SetupOptions()
end

function CoreOptionsRegister:SetupOptions()
  ZxSimpleUI.blizOptionTable = {}
  AceConfigRegistry:RegisterOptionsTable(_OPEN_OPTION_APPNAME,
    function(...) return self:_getOpenOptionTable() end)
  AceConfigRegistry:RegisterOptionsTable(ZxSimpleUI.ADDON_NAME,
    function(...) return self:_getOptionTable() end)

  local frameRef = AceConfigDialog:AddToBlizOptions(_OPEN_OPTION_APPNAME,
                     ZxSimpleUI.DECORATIVE_NAME)
  ZxSimpleUI.blizOptionTable[ZxSimpleUI.ADDON_NAME] = frameRef
  -- Register slash commands as well
  for _, command in pairs(ZxSimpleUI.SLASH_COMMANDS) do
    ZxSimpleUI:RegisterChatCommand(command, function(...) self:_openOptionFrame() end)
  end

  -- Set profile options
  local profileTable = AceDBOptions:GetOptionsTable(ZxSimpleUI.db)
  local moduleName = "Profiles"
  CoreFactory47:disableEnabledToggleInCombat(moduleName, profileTable["args"])
  ZxSimpleUI:registerModuleOptions(moduleName, profileTable, moduleName)

  -- Set Print Frames option
  moduleName = "PrintFrames"
  local printFrameTable = self:_getPrintFrameOptionTable()
  CoreFactory47:disableEnabledToggleInCombat(moduleName, printFrameTable["args"])
  ZxSimpleUI:registerModuleOptions(moduleName, printFrameTable, "Print Frames")
end

-- ########################################
-- # "PRIVATE" functions
-- ########################################

---@return table
function CoreOptionsRegister:_getOpenOptionTable()
  if next(self._openOptionTable) == nil then
    self._openOptionTable = {
      type = "group",
      args = {
        openoptions = {
          name = "Open Options",
          type = "execute",
          func = function(curFrame, ...) self:_openOptionFrame() end
        },
        descriptionParagraph = {
          name = self:_getSlashCommandsString(),
          type = "description",
          fontSize = "medium"
        }
      }
    }
  end

  return self._openOptionTable
end

---@return table
function CoreOptionsRegister:_getPrintFrameOptionTable()
  if next(self._printFrameOptionTable) == nil then
    self._printFrameOptionTable = {
      type = "group",
      name = "Print Frames",
      args = {
        descDisplay = {name = "", type = "description", fontSize = "medium", order = 2},
        printFrameVisibility = {
          name = "Print Frame Visibility",
          type = "execute",
          order = 1,
          func = function(info, ...)
            local sortedKeys = {}
            local t1 = {}
            local s1 = "FRAMES VISIBILITY\n"
            for k, v in ZxSimpleUI:IterateModules() do
              table.insert(sortedKeys, k)
              t1[k] = v
            end
            table.sort(sortedKeys)

            for _, sortedKey in pairs(sortedKeys) do
              local curModule = t1[sortedKey]
              if curModule.mainFrame ~= nil then
                local s2 = (string.format("%s | %s", sortedKey,
                             Utils47:getIsShown(curModule.mainFrame)))
                print(s2)
                s1 = s1 .. s2 .. "\n"
              end
            end

            self._printFrameOptionTable.args.descDisplay.name = s1
          end
        }
      }
    }
  end

  return self._printFrameOptionTable
end

function CoreOptionsRegister:_getSlashCommandsString()
  local s1 = "You can also open the options frame with one of these commands:\n"
  for _, command in pairs(ZxSimpleUI.SLASH_COMMANDS) do s1 = s1 .. "    /" .. command .. "\n" end
  s1 = string.sub(s1, 0, string.len(s1) - 1)
  return s1
end

function CoreOptionsRegister:_openOptionFrame(info, value, ...)
  if not self._frame then
    self._frame = AceGUI:Create("Frame")
    self._frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    self._frame:SetTitle(ZxSimpleUI.DECORATIVE_NAME)
  end
  AceConfigDialog:Open(ZxSimpleUI.ADDON_NAME, self._frame)
end

function CoreOptionsRegister:_getOptionTable()
  if next(self._options) == nil then
    self._options = {type = "group", args = {}}
    self:_addModuleOptionTables()
  end
  return self._options
end

function CoreOptionsRegister:_addModuleOptionTables()
  local defaultOrderIndex = 7
  table.sort(ZxSimpleUI.moduleKeySorted)
  for _, moduleAppName in pairs(ZxSimpleUI.moduleKeySorted) do
    local optionTableOrFunc = ZxSimpleUI.moduleOptionsTable[moduleAppName]
    if type(optionTableOrFunc) == "function" then
      self._options.args[moduleAppName] = optionTableOrFunc()
    else
      self._options.args[moduleAppName] = optionTableOrFunc
    end

    if moduleAppName == "Profiles" then
      -- Make sure "Profiles" is the first option
      self._options.args[moduleAppName]["order"] = 1
    elseif moduleAppName == "PrintFrames" then
      -- Make sure "PrintFrames" is the second option
      self._options.args[moduleAppName]["order"] = 2
    else
      self._options.args[moduleAppName]["order"] = defaultOrderIndex
      defaultOrderIndex = defaultOrderIndex + 1
    end
  end
end
