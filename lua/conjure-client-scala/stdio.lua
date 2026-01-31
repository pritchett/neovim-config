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
  local function _8_(msgs)
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
  return repl_send(":reset\n", _8_, {["batch?"] = true})
end
local function buildsbt_exist_3f(dir)
  return fs.findfile("build.sbt", dir)
end
M["on-load"] = function()
  return log.dbg("Loading scala")
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
  local function _10_()
    local function _11_(err, data)
      assert(not err, err)
      if data then
        return log.dbg(("Error: " .. vim.inspect(data)))
      else
        return log_append(data)
      end
    end
    return _11_
  end
  on_error = _10_
  local on_exit
  local function _13_()
    return extract(sbt_output)
  end
  on_exit = client["schedule-wrap"](_13_)
  local concat_output
  local function _14_(err, data)
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
  concat_output = _14_
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
    local function _19_()
      local function _20_()
        log.dbg("Starting REPL")
        return stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"}), args = args, ["on-success"] = on_success, ["on-error"] = on_error, ["on-exit"] = on_exit, ["on-stray-output"] = on_stray_output})
      end
      return core.assoc(state(), "repl", _20_())
    end
    return client.schedule(_19_)
  end
  if state("repl") then
    return log_append("REPL is already connected")
  else
    local cwd = vim.fn.getcwd()
    if (cfg({"load_repl_in_sbt_context"}) and buildsbt_exist_3f(cwd)) then
      log.dbg("starting repl with sbt classpath")
      local function _21_(_241)
        return start({"--extra-jars", _241})
      end
      return with_sbt_classpath(cwd, _21_)
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
  local function _25_()
    return M.start()
  end
  mapping.buf("ScalaStart", cfg({"mapping", "start"}), _25_, {desc = "Start the REPL"})
  local function _26_()
    return M.stop()
  end
  mapping.buf("ScalaStop", cfg({"mapping", "stop"}), _26_, {desc = "Stop the REPL"})
  local function _27_()
    return reset()
  end
  return mapping.buf("ScalaReset", cfg({"mapping", "reset"}), _27_, {desc = "Reset the REPL"})
end
M["eval-str"] = function(opts)
  log.dbg("scala.stdio.eval-str: opts='", core.str(opts), "'")
  local function _28_(msg)
    log_append(msg.out)
    return opts["on-result"](msg)
  end
  return repl_send(opts.code, _28_, {batch = true})
end
M["eval-file"] = function(opts)
  return nil
end
M["on-exit"] = function()
  local function _29_()
    return M.stop()
  end
  return _29_
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
