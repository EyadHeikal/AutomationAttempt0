hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
   hs.alert.show("Hello World!")
end)

local outputPref = {"HyperX Cloud III S Wireless - Bluetooth", "G522 Gaming Headset - Bluetooth", "HyperX Cloud III S Wireless", "G522 LIGHTSPEED - Wireless Mode", "MacBook Air Speakers"}
local inputPref  = {"HyperX Cloud III S Wireless - Bluetooth", "G522 Gaming Headset - Bluetooth", "HyperX Cloud III S Wireless", "G522 LIGHTSPEED - Wireless Mode", "MacBook Air Microphone"}

local function setPreferred()
  for _, name in ipairs(outputPref) do
    local d = hs.audiodevice.findOutputByName(name)
    if d then
      d:setDefaultOutputDevice()
      d:setDefaultEffectDevice()  -- For system sounds/notifications
      break
    end
  end
  for _, name in ipairs(inputPref) do
    local d = hs.audiodevice.findInputByName(name)
    if d then d:setDefaultInputDevice(); break end
  end
end

-- Volume/Gain limiter for built-in devices using device-specific watchers
-- mode: "exact" locks to the level, "max" caps at the level, "min" enforces minimum level
local function setupDeviceWatcher(deviceName, isInput, level, mode)
  local device = isInput and hs.audiodevice.findInputByName(deviceName) or hs.audiodevice.findOutputByName(deviceName)
  mode = mode or "exact"  -- default to exact mode
  
  if device then
    device:watcherCallback(function()
      local currentLevel = isInput and device:inputVolume() or device:volume()
      local shouldAdjust = false
      
      if mode == "exact" then
        shouldAdjust = currentLevel and currentLevel ~= level
      elseif mode == "max" then
        shouldAdjust = currentLevel and currentLevel > level
      elseif mode == "min" then
        shouldAdjust = currentLevel and currentLevel < level
      end
      
      if shouldAdjust then
        if isInput then
          device:setInputVolume(level)
        else
          device:setVolume(level)
        end
        local action = mode == "exact" and "Set" or (mode == "max" and "Capped" or "Raised")
        print(string.format("%s %s to %d (was %.1f)", action, deviceName, level, currentLevel))
      end
    end)
    device:watcherStart()
    
    -- Set/cap/raise to level immediately on setup if needed
    if isInput then
      local currentLevel = device:inputVolume()
      if (mode == "exact" and currentLevel ~= level) or 
         (mode == "max" and currentLevel > level) or
         (mode == "min" and currentLevel < level) then
        device:setInputVolume(level)
      end
    else
      local currentLevel = device:volume()
      if (mode == "exact" and currentLevel ~= level) or 
         (mode == "max" and currentLevel > level) or
         (mode == "min" and currentLevel < level) then
        device:setVolume(level)
      end
    end
  end
end

-- Setup watchers for built-in devices (exact mode - locked at 0)
setupDeviceWatcher("MacBook Air Speakers", false, 0, "exact")
setupDeviceWatcher("MacBook Air Microphone", true, 0, "exact")

-- Setup watchers for all other input devices with maximum gain cap
local maxInputGain = 100  -- Set your desired maximum input gain here (0-100)

local function setupAllInputDeviceWatchers()
  for _, device in ipairs(hs.audiodevice.allInputDevices()) do
    local deviceName = device:name()
    if deviceName ~= "MacBook Air Microphone" then
      setupDeviceWatcher(deviceName, true, maxInputGain, "exact")
    end
  end
end

-- Initial setup
setupAllInputDeviceWatchers()

-- Audio device watcher for device preference changes AND new devices
hs.audiodevice.watcher.setCallback(function(ev)
  if ev == "dev#" or ev == "dOut" or ev == "dIn" then
    hs.timer.doAfter(0.5, function()
      setPreferred()
      -- Also setup watchers for any newly added input devices
      if ev == "dev#" then  -- "dev#" = device list changed
        setupAllInputDeviceWatchers()
      end
    end)
  end
end)
hs.audiodevice.watcher.start()
setPreferred()


-- -- Helper: Press Cmd+Alt+Ctrl+I to show the current app name
-- -- Useful for identifying which apps to exclude from PaperWM
-- hs.hotkey.bind({"cmd", "alt", "ctrl"}, "I", function()
--     local app = hs.application.frontmostApplication()
--     if app then
--         local appName = app:name()
--         hs.alert.show("Current App: " .. appName, 3)
--         print("Current focused app: " .. appName)
--     end
-- end)

-- -- Helper: Press Cmd+Alt+Ctrl+D to show PaperWM debug info
-- hs.hotkey.bind({"cmd", "alt", "ctrl"}, "D", function()
--     if PaperWM then
--         local info = string.format(
--             "PaperWM Debug Info:\n" ..
--             "swipe_fingers: %d\n" ..
--             "swipe_gain: %.1f\n" ..
--             "Accessibility: %s",
--             PaperWM.swipe_fingers or 0,
--             PaperWM.swipe_gain or 0,
--             hs.accessibilityState() and "✓ Enabled" or "✗ DISABLED"
--         )
--         hs.alert.show(info, 5)
--         print(info)
--     else
--         hs.alert.show("PaperWM not loaded")
--     end
-- end)

-- -- Test gesture detection (Press Cmd+Alt+Ctrl+T to start, swipe to test, press again to stop)
-- local gestureTestWatcher = nil
-- hs.hotkey.bind({"cmd", "alt", "ctrl"}, "T", function()
--     if gestureTestWatcher then
--         gestureTestWatcher:stop()
--         gestureTestWatcher = nil
--         hs.alert.show("Gesture test stopped")
--         print("Gesture test stopped")
--     else
--         hs.alert.show("Gesture test started - Swipe with 2, 3, or 4 fingers")
--         print("Gesture test started - watching for trackpad gestures...")
--         gestureTestWatcher = hs.eventtap.new({ hs.eventtap.event.types.gesture }, function(event)
--             local touches = event:getTouches()
--             if touches and #touches > 0 then
--                 local msg = string.format("Detected %d-finger gesture!", #touches)
--                 hs.alert.show(msg, 1)
--                 print(msg)
--             end
--             return false
--         end)
--         gestureTestWatcher:start()
--     end
-- end)

-- -- Check Accessibility permissions (required for swipe gestures)
-- if not hs.accessibilityState() then
--     hs.alert.show("⚠️ Hammerspoon needs Accessibility permissions!\nGo to System Settings > Privacy & Security > Accessibility", 5)
-- end

-- -- Load PaperWM directly (install with: git clone https://github.com/mogenson/PaperWM.spoon.git ~/.hammerspoon/Spoons/PaperWM.spoon)
-- PaperWM = hs.loadSpoon("PaperWM")

-- if PaperWM then
--     -- Enable debug logging to troubleshoot swipe issues
--     PaperWM.logger.setLogLevel("debug")  -- Set to "info" to reduce verbosity
    
--     PaperWM.window_gap = 4
--     PaperWM.screen_margin = 10
    
--     -- Smooth scrolling with trackpad swipes
--     -- IMPORTANT REQUIREMENTS:
--     -- 1. Hammerspoon needs Accessibility permissions (System Settings > Privacy & Security > Accessibility)
--     -- 2. Disable conflicting gestures in System Settings > Trackpad:
--     --    - For 3-finger: Disable "Mission Control" and "App Exposé" 
--     --    - For 4-finger: Disable "Mission Control" and "Show Desktop"
--     -- Try different finger counts: 2, 3, or 4
--     PaperWM.swipe_fingers = 3  -- Try 3 first (change to 2 or 4 if not working)
    
--     -- Adjust swipe sensitivity (increase to move windows farther when swiping)
--     PaperWM.swipe_gain = 2.0  -- Increased for more visible response
    
--     -- Ignore apps that commonly use tabs to avoid "tabs not supported" error
--     -- Use Cmd+Alt+Ctrl+I on any window to identify the app name
--     -- Add any other apps you want to exclude from tiling
--     PaperWM.window_filter = PaperWM.window_filter or hs.window.filter.new()
    
--     -- Common apps that use tabs by default:
--     -- PaperWM.window_filter:rejectApp("Safari")
--     -- PaperWM.window_filter:rejectApp("Terminal")
--     -- PaperWM.window_filter:rejectApp("Finder")
--     -- PaperWM.window_filter:rejectApp("Arc")
--     -- PaperWM.window_filter:rejectApp("Google Chrome")
--     -- PaperWM.window_filter:rejectApp("Firefox")
--     -- PaperWM.window_filter:rejectApp("iTerm2")
--     -- PaperWM.window_filter:rejectApp("iTerm")
    
--     -- -- You can also exclude system apps or specific utilities:
--     -- PaperWM.window_filter:rejectApp("System Settings")
--     -- PaperWM.window_filter:rejectApp("Activity Monitor")

--     PaperWM:bindHotkeys({
--         -- move through windows
--         focus_left = {{"alt", "cmd"}, "left"},
--         focus_right = {{"alt", "cmd"}, "right"},
--         focus_up = {{"alt", "cmd"}, "up"},
--         focus_down = {{"alt", "cmd"}, "down"},

--         -- move windows around
--         swap_left = {{"alt", "cmd", "shift"}, "left"},
--         swap_right = {{"alt", "cmd", "shift"}, "right"},
--         swap_up = {{"alt", "cmd", "shift"}, "up"},
--         swap_down = {{"alt", "cmd", "shift"}, "down"},

--         -- resize windows
--         center_window = {{"alt", "cmd"}, "c"},
--         full_width = {{"alt", "cmd"}, "f"},
--         cycle_width = {{"alt", "cmd"}, "r"},
--         cycle_height = {{"alt", "cmd", "shift"}, "r"},

--         -- move window into / out of a column
--         slurp_in = {{"alt", "cmd"}, "i"},
--         barf_out = {{"alt", "cmd"}, "o"},

--         -- toggle floating
--         toggle_floating = {{"alt", "cmd", "shift"}, "escape"},

--         -- focus specific windows
--         focus_window_1 = {{"cmd", "shift"}, "1"},
--         focus_window_2 = {{"cmd", "shift"}, "2"},
--         focus_window_3 = {{"cmd", "shift"}, "3"},
--         focus_window_4 = {{"cmd", "shift"}, "4"},
--         focus_window_5 = {{"cmd", "shift"}, "5"},
--         focus_window_6 = {{"cmd", "shift"}, "6"},
--         focus_window_7 = {{"cmd", "shift"}, "7"},
--         focus_window_8 = {{"cmd", "shift"}, "8"},
--         focus_window_9 = {{"cmd", "shift"}, "9"},

--         -- switch to space
--         switch_space_l = {{"alt", "cmd"}, ","},
--         switch_space_r = {{"alt", "cmd"}, "."},
--         switch_space_1 = {{"alt", "cmd"}, "1"},
--         switch_space_2 = {{"alt", "cmd"}, "2"},
--         switch_space_3 = {{"alt", "cmd"}, "3"},
--         switch_space_4 = {{"alt", "cmd"}, "4"},
--         switch_space_5 = {{"alt", "cmd"}, "5"},
--         switch_space_6 = {{"alt", "cmd"}, "6"},
--         switch_space_7 = {{"alt", "cmd"}, "7"},
--         switch_space_8 = {{"alt", "cmd"}, "8"},
--         switch_space_9 = {{"alt", "cmd"}, "9"},

--         -- move window to space
--         move_window_1 = {{"alt", "cmd", "shift"}, "1"},
--         move_window_2 = {{"alt", "cmd", "shift"}, "2"},
--         move_window_3 = {{"alt", "cmd", "shift"}, "3"},
--         move_window_4 = {{"alt", "cmd", "shift"}, "4"},
--         move_window_5 = {{"alt", "cmd", "shift"}, "5"},
--         move_window_6 = {{"alt", "cmd", "shift"}, "6"},
--         move_window_7 = {{"alt", "cmd", "shift"}, "7"},
--         move_window_8 = {{"alt", "cmd", "shift"}, "8"},
--         move_window_9 = {{"alt", "cmd", "shift"}, "9"},
--     })

--     PaperWM:start()
    
--     -- Diagnostic: Confirm swipe is enabled
--     if PaperWM.swipe_fingers > 0 then
--         hs.alert.show(string.format("PaperWM started with %d-finger swipe enabled", PaperWM.swipe_fingers), 2)
--         print(string.format("PaperWM: Swipe enabled with %d fingers, gain: %.1f", PaperWM.swipe_fingers, PaperWM.swipe_gain))
--     else
--         hs.alert.show("PaperWM started (swipe disabled)", 2)
--     end
-- else
--     hs.alert.show("PaperWM not installed. Run: git clone https://github.com/mogenson/PaperWM.spoon.git ~/.hammerspoon/Spoons/PaperWM.spoon")
-- end
