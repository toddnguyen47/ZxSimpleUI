---Interface class. All modules should have the following functions:
local InterfaceModule = {}

function InterfaceModule:__init__() end
function InterfaceModule:new() end

function InterfaceModule:OnInitialization() end
function InterfaceModule:refreshConfig() end

function InterfaceModule:OnEnable() end
function InterfaceModule:OnDisable() end
function InterfaceModule:handleOnEnable() end
function InterfaceModule:handleOnDisable() end

function InterfaceModule:createBar() end
function InterfaceModule:handleEnableToggle() end
function InterfaceModule:handleShownOption() end
function InterfaceModule:handleShownHideOption() end
function InterfaceModule:getExtraOptions() end

function InterfaceModule:_refreshAll() end
function InterfaceModule:_registerAllEvents() end
function InterfaceModule:_unregisterAllEvents() end
