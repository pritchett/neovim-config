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
local function wrap_call(fun)
  local wrapped = vim.schedule_wrap(fun)
  return wrapped()
end
local function log_append(msg)
  if msg then
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
  else
    return nil
  end
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
  local function _8_()
    return log.dbg("Resetting the REPL")
  end
  wrap_call(_8_)
  local function _9_(msgs)
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
  return repl_send(":reset\n", _9_, {["batch?"] = true})
end
local function buildsbt_exist_3f(dir)
  return fs.findfile("build.sbt", dir)
end
M["on-load"] = function()
  local function _11_()
    return log.dbg("Loading scala")
  end
  return wrap_call(_11_)
end
local function with_sbt_classpath(dir, co)
  local function extract_and_co(sbt_output)
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
    return coroutine.resume(co, classpath)
  end
  local stdin = nil
  local stdout = vim.uv.new_pipe(false)
  local stderr = vim.uv.new_pipe(false)
  local sbt_output = {}
  local on_error
  local function _12_(err, data)
    assert(not err, err)
    if data then
      return log.dbg(("Error: " .. vim.inspect(data)))
    else
      return log_append(data)
    end
  end
  on_error = vim.schedule_wrap(_12_)
  local on_exit
  local function _14_(_241, _242)
    return extract_and_co(sbt_output, _241, _242)
  end
  on_exit = _14_
  local concat_output
  local function _15_(err, data)
    if err then
      local function _16_()
        return log.dbg(("ERROR: " .. err))
      end
      wrap_call(_16_)
    else
    end
    if data then
      local function _18_()
        return log.dbg(("getting data: " .. data))
      end
      wrap_call(_18_)
      return table.insert(sbt_output, data)
    else
      return nil
    end
  end
  concat_output = _15_
  local handle, pid_or_error = vim.uv.spawn("sbt", {stdio = {stdin, stdout, stderr}, cwd = dir, args = {"show fullClasspath"}, text = true}, on_exit)
  if handle then
    log.dbg(("Retrieving classpath from sbt with pid " .. pid_or_error))
    stderr:read_start(on_error)
    return stdout:read_start(concat_output)
  else
    return nil
  end
end
M.start = function()
  log.dbg(("scala.stdio.start: prompt_pattern='" .. cfg({"prompt_pattern"}) .. "', cmd='" .. cfg({"command"}) .. "'"))
  local function start(args)
    local function on_exit(code, signal)
      local repl = state("repl")
      if repl then
        repl.destroy()
        return core.assoc(state(), "repl", nil)
      else
        return nil
      end
    end
    local function on_success()
      return log.dbg("REPL started successfully")
    end
    local function on_error(err)
      log.dbg(err)
      return log_append(err)
    end
    local function on_stray_output(msg)
      log.dbg(("scala.stdio.start on-stray-output='" .. msg.out .. "'"))
      for out in string.gmatch(msg.out, "([^\n]+)") do
        log_append(out)
      end
      return nil
    end
    local function _22_()
      local function _23_()
        log.dbg("Starting REPL")
        return stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"}), args = args, ["on-success"] = on_success, ["on-error"] = on_error, ["on-exit"] = on_exit, ["on-stray-output"] = on_stray_output})
      end
      return core.assoc(state(), "repl", _23_())
    end
    return wrap_call(_22_)
  end
  if state("repl") then
    return log_append("REPL is already connected")
  else
    local cwd = vim.fn.getcwd()
    if (cfg({"load_repl_in_sbt_context"}) and buildsbt_exist_3f(cwd)) then
      log.dbg("starting repl with sbt classpath")
      local function _24_(_241)
        return start({"--extra-jars", _241})
      end
      return with_sbt_classpath(cwd, coroutine.create(_24_))
    else
      return start()
    end
  end
end
M.stop = function()
  log.dbg("REPL stop")
  local repl = state("repl")
  if repl then
    log.dbg("Destroying repl")
    repl.destroy()
    return core.assoc(state(), "repl", nil)
  else
    return nil
  end
end
M["on-filetype"] = function()
  local function _28_()
    return M.start()
  end
  mapping.buf("ScalaStart", cfg({"mapping", "start"}), _28_, {desc = "Start the REPL"})
  local function _29_()
    return M.stop()
  end
  mapping.buf("ScalaStop", cfg({"mapping", "stop"}), _29_, {desc = "Stop the REPL"})
  local function _30_()
    return reset()
  end
  return mapping.buf("ScalaReset", cfg({"mapping", "reset"}), _30_, {desc = "Reset the REPL"})
end
M["eval-str"] = function(opts)
  return nil
end
M["eval-file"] = function(opts)
  return nil
end
M["on-exit"] = function()
  local function _31_()
    return M.stop()
  end
  return _31_
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
return M
