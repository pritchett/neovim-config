-- [nfnl] fnl/conjure-client-scala/stdio.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local M = define("conjure.client.scala.stdio")
local config = autoload("conjure.config")
local core = autoload("conjure.nfnl.core")
local str = autoload("conjure.nfnl.string")
local fs = autoload("conjure.nfnl.fs")
local stdio = autoload("conjure.remote.stdio")
local mapping = autoload("conjure.mapping")
local log = autoload("conjure.log")
local client = autoload("conjure.client")
M["buf-suffix"] = ".scala"
M["comment-prefix"] = "// "
M["context-pattern"] = "package (.*)$"
config.merge({client = {scala = {stdio = {command = "scala-cli", prompt_pattern = "scala>", load_repl_in_sbt_context = true, arguments = {}}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {scala = {stdio = {mapping = {start = "cs", stop = "cS", reset = "cr", interrupt = "ei"}}}}})
else
end
local cfg = config["get-in-fn"]({"client", "scala", "stdio"})
local state
local function _3_()
  return {repl = nil}
end
state = client["new-state"](_3_)
local function prep_code(code)
  return (code .. "\n")
end
local function log_append(msg)
  local function starts_with_comment_prefix_3f(str0)
    return string.match(str0, ("^" .. M["comment-prefix"]))
  end
  local function with_comment_prefix(str0)
    if starts_with_comment_prefix_3f(str0) then
      return str0
    else
      return (M["comment-prefix"] .. str0)
    end
  end
  if msg then
    local wrapped_msg
    if core["table?"](msg) then
      wrapped_msg = core.map(with_comment_prefix, msg)
    else
      wrapped_msg = {with_comment_prefix(msg)}
    end
    return log.append(wrapped_msg)
  else
    return nil
  end
end
local function with_repl(cb)
  local repl = state("repl")
  if repl then
    return cb(repl)
  else
    return log_append("REPL is not connected.")
  end
end
local function repl_send(msg, cb, opts)
  log.dbg(("scala.stdio.repl-send: opts='" .. core.str(opts) .. "'"))
  log.dbg(("scala.stdio.repl-send: msg='" .. core.str(msg) .. "'"))
  local function _8_(repl)
    return repl.send(msg, cb, opts)
  end
  return with_repl(_8_)
end
local function split_on_newline(string)
  return str.split(string, "\n")
end
local function repl_send_with_log_append(code)
  log.dbg(("scala.stdio.repl-send-with-log-append:" .. core.str(code)))
  local function _9_(msgs)
    log.dbg(("scala.stdio.repl-send-with-log-append callback:" .. core.str(msgs)))
    return log_append(M["format-msg"](msgs))
  end
  return repl_send(prep_code(code), _9_)
end
local function reset()
  return repl_send_with_log_append(":reset")
end
local function buildsbt_exist_3f(dir)
  return fs.findfile("build.sbt", dir)
end
M["on-load"] = function()
  return log.dbg("scala.stdio.on-load")
end
local function with_sbt_classpath(dir, cb)
  local function extract(sbt_output)
    local regex = "%[info%] %* Attributed%(([^%)]*)%)"
    local sbt_output_string
    do
      local output = ""
      for _, line in ipairs(sbt_output) do
        output = (output .. line)
      end
      sbt_output_string = output
    end
    local path
    do
      local classpath = ""
      for jar in string.gmatch(sbt_output_string, regex) do
        classpath = (classpath .. jar .. ":")
      end
      path = classpath
    end
    local classpath = string.gsub(path, ":$", "")
    return cb(classpath)
  end
  local stdin = nil
  local stdout = vim.uv.new_pipe(false)
  local stderr = vim.uv.new_pipe(false)
  local sbt_output = {}
  local on_error
  local function _10_(err, data)
    assert(not err, err)
    if data then
      return log.dbg(("Error: " .. vim.inspect(data)))
    else
      return log_append(data)
    end
  end
  on_error = _10_
  local on_exit
  local function _12_()
    return extract(sbt_output)
  end
  on_exit = client["schedule-wrap"](_12_)
  local concat_output
  local function _13_(err, data)
    if err then
      log.dbg(("ERROR: " .. err))
    else
    end
    if data then
      log.dbg(("getting data: " .. data))
      return table.insert(sbt_output, data)
    else
      return nil
    end
  end
  concat_output = _13_
  local handle, pid_or_error = vim.uv.spawn("sbt", {stdio = {stdin, stdout, stderr}, cwd = dir, args = {"show fullClasspath"}, text = true}, on_exit)
  if handle then
    log.dbg(("Retrieving classpath from sbt with pid " .. pid_or_error))
    stderr:read_start(client["schedule-wrap"](on_error))
    return stdout:read_start(client["schedule-wrap"](concat_output))
  else
    return nil
  end
end
M.start = function()
  log.dbg(("scala.stdio.start: prompt_pattern='" .. cfg({"prompt_pattern"}) .. "', cmd='" .. cfg({"command"}) .. "'"))
  log_append("Starting the REPL...")
  local function start(args)
    log.dbg(("scala.stdio.start.start: args='" .. core.str(args) .. "'"))
    local function on_exit(code, signal)
      if (("number" == type(code)) and (code > 0)) then
        log_append((M["comment-prefix"] .. "process exited with code " .. core.str(code)))
      else
      end
      if (("number" == type(signal)) and (signal > 0)) then
        log_append((M["comment-prefix"] .. "process exited with signal " .. core.str(signal)))
      else
      end
      local function _19_(repl)
        return repl.destroy()
      end
      with_repl(_19_)
      return core.assoc(state(), "repl", nil)
    end
    local function on_success()
      return log.dbg("scala.stdio.start.on-success")
    end
    local function on_error(err)
      log.dbg(("scala.stdio.start.on-error: " .. core.str(err)))
      return log_append(err)
    end
    local function on_stray_output(msg)
      log.dbg(("scala.stdio.start on-stray-output='" .. msg.out .. "'"))
      return log_append(M["format-msg"](msg))
    end
    local function _20_()
      local function _21_()
        log.dbg("scala.stdio.start: Starting REPL")
        local _22_
        do
          local full_command = (args or {})
          table.insert(full_command, "-color")
          table.insert(full_command, "never")
          table.insert(full_command, 1, cfg({"command"}))
          _22_ = full_command
        end
        return stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = _22_, ["on-success"] = on_success, ["on-error"] = on_error, ["on-exit"] = on_exit, ["on-stray-output"] = on_stray_output})
      end
      return core.assoc(state(), "repl", _21_())
    end
    return client.schedule(_20_)
  end
  if state("repl") then
    return log_append("REPL is already connected")
  else
    local cwd = vim.fn.getcwd()
    if (cfg({"load_repl_in_sbt_context"}) and buildsbt_exist_3f(cwd)) then
      log.dbg("scala.stdio.start: starting repl with sbt classpath")
      local function _23_(_241)
        return start({"--extra-jars", _241})
      end
      return with_sbt_classpath(cwd, _23_)
    else
      return start()
    end
  end
end
M.stop = function()
  log.dbg("scala.stdio.stop")
  local function _26_(repl)
    repl_send_with_log_append(":exit")
    log.dbg("scala.stdio.stop: Destroying repl")
    repl.destroy()
    return core.assoc(state(), "repl", nil)
  end
  return with_repl(_26_)
end
M["on-filetype"] = function()
  local function _27_()
    return M.start()
  end
  mapping.buf("ScalaStart", cfg({"mapping", "start"}), _27_, {desc = "Start the REPL"})
  local function _28_()
    return M.stop()
  end
  mapping.buf("ScalaStop", cfg({"mapping", "stop"}), _28_, {desc = "Stop the REPL"})
  local function _29_()
    return reset()
  end
  mapping.buf("ScalaReset", cfg({"mapping", "reset"}), _29_, {desc = "Reset the REPL"})
  local function _30_()
    return M.interrupt()
  end
  return mapping.buf("ScalaInterrupt", cfg({"mapping", "interrupt"}), _30_, {desc = "Interrupt the REPL"})
end
M["eval-str"] = function(opts)
  return repl_send_with_log_append(opts.code)
end
M["eval-file"] = function(opts)
  log.dbg(("scala.stdio.eval-file opts='" .. core.str(opts) .. "'"))
  local function _31_(_241)
    return log_append(M["format-msg"](_241))
  end
  return repl_send(prep_code((":load " .. opts["file-path"])), _31_)
end
M["on-exit"] = function()
  log.dbg("scala.stdio.on-exit")
  return M.stop()
end
M["format-msg"] = function(msg)
  local function _32_(_241)
    return (_241 == " ")
  end
  return core.remove(_32_, split_on_newline(core.get(msg, "out")))
end
M["form-node?"] = function(node)
  log.dbg("--------------------")
  log.dbg(("scala.stdio.form-node?: node:type = " .. core.str(node:type())))
  log.dbg(("scala.stdio.form-node?: node:parent = " .. core.str(node:parent())))
  if ("import_declaration" == node:type()) then
    return true
  elseif ("function_definition" == node:type()) then
    return true
  elseif ("trait_definition" == node:type()) then
    return true
  elseif ("object_definition" == node:type()) then
    return true
  elseif ("val_definition" == node:type()) then
    return true
  elseif ("call_expression" == node:type()) then
    return true
  else
    return false
  end
end
M.interrupt = function()
  local function _34_(repl)
    log_append({(M["comment-prefix"] .. "Sending interrupt signal.")}, {["break?"] = true})
    return repl["send-signal"]("sigint")
  end
  return with_repl(_34_)
end
return M
