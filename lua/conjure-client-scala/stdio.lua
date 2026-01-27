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
M["on-load"] = function()
  return log.dbg("Loading scala")
end
M.start = function()
  log.dbg(("scala.stdio.start: prompt_pattern='" .. cfg({"prompt_pattern"}) .. "', cmd='" .. cfg({"command"}) .. "'"))
  if state("repl") then
    return log.append({"repl already running"})
  else
    local function _4_()
      return log.dbg("REPL started successfully")
    end
    local function _5_(err)
      log.dbg(err)
      return log.append({(M["comment-prefix"] .. err)})
    end
    local function _6_(code, signal)
      log.dbg("on-exit")
      local repl = state("repl")
      if repl then
        repl.destroy()
        return core.assoc(state(), "repl", nil)
      else
        return nil
      end
    end
    local function _8_(msg)
      return log.append({(M["comment-prefix"] .. msg)})
    end
    return core.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"}), ["on-success"] = _4_, ["on-error"] = _5_, ["on-exit"] = _6_, ["on-stray-output"] = _8_}))
  end
end
M.stop = function()
  return log.dbg("REPL stop")
end
M["on-filetype"] = function()
  local function _10_()
    return M.start()
  end
  mapping.buf("ScalaStart", cfg({"mapping", "start"}), _10_, {desc = "Start the REPL"})
  local function _11_()
    return M.stop()
  end
  return mapping.buf("ScalaStop", cfg({"mapping", "stop"}), _11_, {desc = "Stop the REPL"})
end
M["eval-str"] = function(opts)
  return nil
end
M["eval-file"] = function(opts)
  return nil
end
M["on-exit"] = function()
  return nil
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
  local function _12_(_, _0)
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
  on_exit = _12_
  local concat_output
  local function _13_(_, data)
    if data then
      return table.insert(sbt_output, data)
    else
      return nil
    end
  end
  concat_output = _13_
  local handle, pid_or_error = vim.uv.spawn("sbt", {stdio = {stdin, stdout, stderr}, cwd = dir, args = {"show fullClasspath"}, text = true}, on_exit)
  if handle then
    return stdout:read_start(concat_output)
  else
    return nil
  end
end
return M
