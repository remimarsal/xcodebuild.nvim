---@mod xcodebuild.integrations.tuist Tuist Integration
---@brief [[
---This module integrates Tuist with xcodebuild.nvim.
---
---It provides wrappers for xcodebuild commands that use Tuist instead.
---@brief ]]

local util = require("xcodebuild.util")
local notifications = require("xcodebuild.broadcasting.notifications")
local config = require("xcodebuild.core.config").options

local M = {}

---Returns whether Tuist integration is enabled.
---@return boolean
function M.is_enabled()
  return config.integrations.tuist and config.integrations.tuist.enabled
end

---Checks if Tuist is installed.
---@return boolean
function M.is_installed()
  local output = util.shell({ "which", "tuist" })
  return #output > 0 and output[1] ~= ""
end

---Wraps a command to use Tuist instead of xcodebuild when enabled.
---@param command table The xcodebuild command to wrap
---@return table The wrapped command
function M.wrap_command_if_needed(command)
  if not M.is_enabled() then
    return command
  end

  if not M.is_installed() then
    notifications.send_error("Tuist is not installed. Please install it first.")
    notifications.send("brew tap tuist/tuist && brew install tuist")
    return command
  end

  -- Map from xcodebuild command to tuist command
  -- Example: {"xcodebuild", "build", ...} -> {"tuist", "build", ...}
  local tuistCommand = M.convert_to_tuist_command(command)
  
  return tuistCommand
end

---Converts an xcodebuild command to a Tuist command.
---@param command table The xcodebuild command to convert
---@return table The Tuist command
function M.convert_to_tuist_command(command)
  -- Skip nil command or non-xcodebuild commands
  if not command or #command == 0 or command[1] ~= "xcodebuild" then
    return command
  end

  local result = { "tuist" }
  local skip_next = false
  local action = nil
  local scheme = nil
  local destination = nil

  -- Find the basic action (build, test, clean)
  for i = 2, #command do
    if skip_next then
      skip_next = false
    elseif command[i] == "build" or command[i] == "test" or command[i] == "clean" then
      action = command[i]
    elseif command[i] == "build-for-testing" then
      action = "build"
    elseif command[i] == "test-without-building" then
      action = "test"
    elseif command[i] == "-scheme" and i < #command then
      scheme = command[i + 1]
      skip_next = true
    elseif command[i] == "-destination" and i < #command then
      local dest_str = command[i + 1]
      if dest_str:find("id=") then
        destination = dest_str:match("id=([^,]+)")
      end
      skip_next = true
    end
  end

  -- Add the action
  if action then
    table.insert(result, action)
  else
    -- If we couldn't determine the action, fallback to xcodebuild
    notifications.send_warning("Could not determine Tuist action. Falling back to xcodebuild.")
    return command
  end

  -- Add the scheme
  if scheme then
    table.insert(result, "--scheme")
    table.insert(result, scheme)
  end

  -- Add the device (destination)
  if destination then
    table.insert(result, "--device")
    table.insert(result, destination)
  end

  -- Handle clean flag
  if util.contains(command, "clean") then
    if action == "build" then
      table.insert(result, "--clean")
    end
  end

  -- Handle test plan
  for i = 2, #command do
    if command[i] == "-testPlan" and i < #command then
      table.insert(result, "--test-plan")
      table.insert(result, command[i + 1])
      break
    end
  end

  -- Log the command transformation for debugging
  if config.integrations.tuist.debug then
    print("Converting xcodebuild command: " .. table.concat(command, " "))
    print("To tuist command: " .. table.concat(result, " "))
  end

  return result
end

---Runs the provided command using Tuist build cache if available and enabled.
---@param command table
---@return table
function M.use_tuist_cache_if_available(command)
  if not M.is_enabled() or not config.integrations.tuist.use_cache then
    return command
  end

  -- For Tuist commands, we don't need to modify if already handled by wrap_command_if_needed
  if command[1] == "tuist" then
    return command
  end
  
  -- For other commands, just return as is
  return command
end

return M