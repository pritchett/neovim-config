local log = require('logger').log
local sock = require('posix.sys.socket')

local fd = sock.socket(sock.AF_UNIX, sock.SOCK_STREAM, 0)

local ok, file = pcall(vim.fn.readfile, "/Users/bpritchett/Development/aria-billing/services/project/target/active.json")
local uri = vim.fn.json_decode(file[1]).uri:gsub("^local://", "")

local res = sock.connect(fd, {
  family = sock.AF_UNIX,
  path = uri
})

local cmd = '{ "jsonrpc": "2.0", "id": 2, "method" : "sbt/exec", "params": { "commandLine": "accountApp / compile" } }\r\n\r\n'
sock.send(fd, cmd)
-- sock.send(fd, '{ "jsonrpc": "2.0", "id": 2, "method" : "sbt/shutdown", "params": {} }')
-- '{ "jsonrpc": "2.0", "id": 2, "method" : "sbt/completion", "params": { "query": "accountAp" } }'
local data = {}

local buf_size = 21
local loop = true
while loop do
  local b = sock.recv(fd, buf_size)
  -- local lines = vim.split(b, '\r\n', { trimempty = true })
  -- print(b)
  local lines
  local length = b:match("%d+")
  lines = vim.split(b, '\r\n', { trimempty = true })
  local content_length = lines[1]
  print("c: " .. content_length)
  -- print(length)
  if (tonumber(length) > buf_size) then
    b = b .. sock.recv(fd, length - buf_size)
    -- print(b)
    lines = vim.split(b, '\r\n', { trimempty = true })
  end
  print(b)
  for _, line in pairs(lines) do
    if line:find('{') then
      table.insert(data, line)
      -- print(line)
    end
    if line:find("shutdown") or line:find("shut") then
      loop = false
    end
  end
end
print(vim.inspect(data))
-- string.gmatch(b, "[^\r\n]+$")^\-- r\n]+$")
--   local data = lines()
-- print(b)
-- vim.inspect(lines)
-- print(data)
-- if not data or data:match("shutdown") then
--   break
-- end
-- end
-- print(b)

-- while true do
--   if not b or #b == 0 then
--     break
--   end
--   b = sock.recv(fd, 1024)
--   -- table.insert(data, b)
-- end
require 'posix.unistd'.close(fd)
-- data = table.concat(data)
-- print(data)
-- print(data)e.concat(data)
-- print(data)
