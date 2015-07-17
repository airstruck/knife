package = "knife"
version = "1.0-1"
source = { url = "knife", dir = "knife" }
description = {
summary = "Swiss army knife for Lua",
detailed = [[A collection of micro-modules providing an ECS,
a class-like OOP framework, a memoize function, and a testing framework.]],
homepage = "https://github.com/airstruck/knife",
license = "MIT"
}
dependencies = { "lua >= 5.1" }
build = {
type = "builtin",
modules = {
["knife.base"] = "base.lua",
["knife.base.common"] = "base/common.lua",
["knife.event"] = "event.lua",
["knife.memoize"] = "memoize.lua",
["knife.system"] = "system.lua",
["knife.test"] = "test.lua",
}
}
