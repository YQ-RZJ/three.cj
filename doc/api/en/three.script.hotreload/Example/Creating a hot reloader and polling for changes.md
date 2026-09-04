let hr = LuaHotReload(vm, "game/config.lua")
hr.load()                 // 首次加载并执行
// ... 运行中编辑 config.lua ...
let changed = hr.poll()   // 检测文件变化并自动重新加载