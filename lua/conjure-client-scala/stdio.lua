-- [nfnl] fnl/conjure-client-scala/stdio.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local M = define("conjure.client.scala.stdio")
local config = autoload("conjure.config")
local core = autoload("conjure.nfnl.core")
local fs = autoload("conjure.nfnl.fs")
local stdio = autoload("conjure.remote.stdio")
local mapping = autoload("conjure.mapping")
local log = autoload("conjure.log")
local client = autoload("conjure.client")
M["buf-suffix"] = ".scala"
M["comment-prefix"] = "// "
M["context-pattern"] = "package (.*)$"
config.merge({client = {scala = {stdio = {command = "scala-cli repl", prompt_pattern = "scala>", load_repl_in_sbt_context = true, arguments = {}}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {scala = {stdio = {mapping = {start = "cs", stop = "cS", reset = "cr"}}}}})
else
end
local cfg = config["get-in-fn"]({"client", "scala", "stdio"})
local state
local function _3_()
  return {repl = nil}
end
state = client["new-state"](_3_)
local function log_append(msg)
  local wrapped_msg
  if (type(msg) == "table") then
    local tbl_26_ = {}
    local i_27_ = 0
    for _, m in ipairs(msg) do
      local val_28_ = (M["comment-prefix"] .. m)
      if (nil ~= val_28_) then
        i_27_ = (i_27_ + 1)
        tbl_26_[i_27_] = val_28_
      else
      end
    end
    wrapped_msg = tbl_26_
  else
    wrapped_msg = {(M["comment-prefix"] .. msg)}
  end
  return log.append(wrapped_msg)
end
local function repl_send(msg, cb, opts)
  local repl = state("repl")
  if repl then
    return repl.send(msg, cb, opts)
  else
    return nil
  end
end
local function reset()
  log.dbg("Resetting the REPL")
  local function _7_(msgs)
    local all_msgs
    do
      local tbl_26_ = {}
      local i_27_ = 0
      for _, msg in ipairs(msgs) do
        local val_28_ = msg.out
        if (nil ~= val_28_) then
          i_27_ = (i_27_ + 1)
          tbl_26_[i_27_] = val_28_
        else
        end
      end
      all_msgs = tbl_26_
    end
    return log_append(all_msgs)
  end
  return repl_send(":reset\n", _7_, {["batch?"] = true})
end
M["on-load"] = function()
  return log.dbg("Loading scala")
end
M.start = function()
  log.dbg(("scala.stdio.start: prompt_pattern='" .. cfg({"prompt_pattern"}) .. "', cmd='" .. cfg({"command"}) .. "'"))
  if state("repl") then
    return log_append("REPL already running")
  else
    local function _9_()
      log.dbg("REPL started successfully")
      return log_append("Scala repl is connected")
    end
    local function _10_(err)
      log.dbg(err)
      return log_append(err)
    end
    local function _11_(code, signal)
      log.dbg("on-exit")
      local repl = state("repl")
      if repl then
        repl.destroy()
        return core.assoc(state(), "repl", nil)
      else
        return nil
      end
    end
    local function _13_(msg)
      log.dbg(("scala.stdio.start on-stray-output='" .. msg .. "'"))
      return log_append(msg)
    end
    return core.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"}), ["on-success"] = _9_, ["on-error"] = _10_, ["on-exit"] = _11_, ["on-stray-output"] = _13_}))
  end
end
M.stop = function()
  log.dbg("REPL stop")
  local repl = state("repl")
  if repl then
    repl.destroy()
    return core.assoc(state(), "repl", nil)
  else
    return nil
  end
end
M["on-filetype"] = function()
  local function _16_()
    return M.start()
  end
  mapping.buf("ScalaStart", cfg({"mapping", "start"}), _16_, {desc = "Start the REPL"})
  local function _17_()
    return M.stop()
  end
  mapping.buf("ScalaStop", cfg({"mapping", "stop"}), _17_, {desc = "Stop the REPL"})
  local function _18_()
    return reset()
  end
  return mapping.buf("ScalaReset", cfg({"mapping", "reset"}), _18_, {desc = "Reset the REPL"})
end
M["eval-str"] = function(opts)
  return nil
end
M["eval-file"] = function(opts)
  return nil
end
M["on-exit"] = function()
  local function _19_()
    return M.stop()
  end
  return _19_
end
M["form-node?"] = function(opts)
  return false
end
M["format-msg"] = function(opts)
  return false
end
M.interrupt = function(opts)
  return false
end
local function buildsbt_exist_3f(dir)
  return fs.findfile("build.sbt", "/Users/brian/Development/scala-coding-challenge/")
end
local function get_sbt_classpath(dir)
  local stdin = vim.uv.new_pipe(false)
  local stdout = vim.uv.new_pipe(false)
  local stderr = vim.uv.new_pipe(false)
  local sbt_output = {}
  local on_exit
  local function _20_(_, _0)
    local regex = "%[info%] %* Attributed%(([^%)]*)%)"
    local sbt_output_string
    do
      local output = ""
      for _1, line in ipairs(sbt_output) do
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
    return string.gsub(path, ":$", "")
  end
  on_exit = _20_
  local concat_output
  local function _21_(_, data)
    if data then
      return table.insert(sbt_output, data)
    else
      return nil
    end
  end
  concat_output = _21_
  local handle, pid_or_error = vim.uv.spawn("sbt", {stdio = {stdin, stdout, stderr}, cwd = dir, args = {"show fullClasspath"}, text = true}, on_exit)
  if handle then
    return stdout:read_start(concat_output)
  else
    return nil
  end
end
return M
