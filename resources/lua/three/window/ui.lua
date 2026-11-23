-- three/window/ui.lua —— three.window.ui 绑定模块 + 声明式控件辅助函数
--
-- 返回 three.window.ui 全局命名空间。需引擎侧先安装 window 绑定：
--     LuaBindingFactory.installPackage(vm, "three.window")
--
-- 类表（PascalCase）由仓颉侧 install* 写入，本模块保持原样；下方新增的小写函数是
-- 面向 Lua 的声明式糖：一次调用完成「构造 + 绘制」，容器类接受 body 闭包，避免
-- Lua 侧出现 `Xxx.new(...):draw()` 与多层嵌套的样板代码。
--
--   local ui = require "three.window.ui"
--   ui.window("Panel", function()
--       ui.text("Hello")
--       if ui.button("OK") then ... end
--       local v = ui.f32v({ 0.5 })
--       ui.sliderFloat("Value", v, 0.0, 1.0)
--   end)
--
-- 数值缓冲：ImGui 的若干控件通过指针缓冲共享状态（复选框/滑条/拖拽/图表等）。
-- 本模块用已绑定的 PtrArray 类型提供缓冲工厂：
--   ui.i32(0), ui.f32(0.5), ui.f64(0.0), ui.i32v({1, 2}), ui.f32v({0.1, 0.2})
-- 读写：buf.value（单元素）、buf:get(i)/buf:set(i, v)、buf.values（整体）。
-- 注意：缓冲需在多次调用之间复用才能保留界面状态（声明式重建控件不影响缓冲）。

local ui = require("three").window.ui

local Memory = require("three").utils.memory
local Vector2 = require("three").core.math.Vector2

-- ===========================================================================
-- 数值缓冲
-- ===========================================================================

--- 创建单元素 Int32 缓冲
---@param value number? 初始值（默认 0）
---@return PtrArrayInt32
function ui.i32(value)
    local buf = Memory.PtrArrayInt32.new({ value or 0 })
    return buf
end

--- 创建单元素 Float32 缓冲
---@param value number? 初始值（默认 0.0）
---@return PtrArrayFloat32
function ui.f32(value)
    return Memory.PtrArrayFloat32.new({ value or 0.0 })
end

--- 创建单元素 Float64 缓冲
---@param value number? 初始值（默认 0.0）
---@return PtrArrayFloat64
function ui.f64(value)
    return Memory.PtrArrayFloat64.new({ value or 0.0 })
end

--- 创建多元素 Int32 缓冲
---@param values table 初始值数组
---@return PtrArrayInt32
function ui.i32v(values)
    return Memory.PtrArrayInt32.new(values)
end

--- 创建多元素 Float32 缓冲
---@param values table 初始值数组
---@return PtrArrayFloat32
function ui.f32v(values)
    return Memory.PtrArrayFloat32.new(values)
end

--- 创建多元素 Float64 缓冲
---@param values table 初始值数组
---@return PtrArrayFloat64
function ui.f64v(values)
    return Memory.PtrArrayFloat64.new(values)
end

-- ===========================================================================
-- 容器
-- ===========================================================================

--- 绘制窗口（Begin/End 由 draw 自动管理）
---@param title string 窗口标题
---@param body function 窗口内容
---@param opts table? { flags, open, x, y, w, h, collapsed, bgAlpha }
---@return boolean 窗口是否可见
function ui.window(title, body, opts)
    opts = opts or {}
    local W = ui.UiWindow
    if opts.x ~= nil or opts.y ~= nil then
        W.setNextWindowPos(opts.x or 0.0, opts.y or 0.0, opts.cond or 0,
            opts.pivotX or 0.0, opts.pivotY or 0.0)
    end
    if opts.w ~= nil or opts.h ~= nil then
        W.setNextWindowSize(opts.w or 0.0, opts.h or 0.0, opts.cond or 0)
    end
    if opts.collapsed ~= nil then
        W.setNextWindowCollapsed(opts.collapsed, opts.cond or 0)
    end
    if opts.bgAlpha ~= nil then
        W.setNextWindowBgAlpha(opts.bgAlpha)
    end
    if opts.focus then
        W.setNextWindowFocus()
    end
    local win
    if opts.open ~= nil then
        win = ui.UiWindow.new(title, opts.open, opts.flags or 0)
    else
        win = ui.UiWindow.new(title, opts.flags or 0)
    end
    return win:draw(body)
end

--- 子窗口（在窗口内使用）
---@param id string 子窗口 ID
---@param body function 内容
---@param opts table? { w, h, childFlags, windowFlags }
---@return boolean 是否可见
function ui.child(id, body, opts)
    opts = opts or {}
    local child = ui.UiChildWindow.new(id, opts.w or 0.0, opts.h or 0.0,
        opts.childFlags or 0, opts.windowFlags or 0)
    return child:draw(body)
end

--- 分组容器（BeginGroup/EndGroup）
---@param body function 组内内容
function ui.group(body)
    ui.UiGroup.new(body):draw()
end

--- 缩进 / 取消缩进
---@param w number? 缩进宽度（0 = ImGui 默认）
function ui.indent(w)
    ui.UiIndent.new(w or 0.0):draw()
end

--- 取消缩进
---@param w number? 缩进宽度（0 = ImGui 默认）
function ui.unindent(w)
    ui.UiUnindent.new(w or 0.0):draw()
end

--- 禁用状态容器
---@param disabled boolean? 是否禁用（默认 true）
---@param body function 内容
function ui.disabled(disabled, body)
    if type(disabled) == "function" then
        body = disabled
        disabled = true
    end
    ui.UiDisabledBlock.new(disabled ~= false, body):draw()
end

--- 列布局容器
---@param count number? 列数（默认 2）
---@param body function 内容
---@param opts table? { id, border }
function ui.columns(count, body, opts)
    if type(count) == "function" then
        body = count
        count = 2
    end
    opts = opts or {}
    ui.UiColumns.new(count or 2, opts.id or "", opts.border or false, body):draw()
end

--- ID 作用域（PushID/PopID）
---@param id string ID
---@param body function 内容
function ui.idScope(id, body)
    ui.UiIdScope.new(id, body):draw()
end

-- ===========================================================================
-- 文本与基础控件
-- ===========================================================================

--- 文本
---@param text string 文本
function ui.text(text)
    ui.UiText.new(text):draw()
end

--- 自动换行文本
---@param text string 文本
function ui.textWrapped(text)
    ui.UiTextWrapped.new(text):draw()
end

--- 彩色文本
---@param text string 文本
---@param color Color? 颜色（RGB 0~1）
function ui.textColored(text, color)
    ui.UiTextColored.new(text, color):draw()
end

--- 禁用样式文本
---@param text string 文本
function ui.textDisabled(text)
    ui.UiTextDisabled.new(text):draw()
end

--- 分隔线 / 文本分隔线
function ui.separator()
    ui.UiSeparator.new():draw()
end

--- 文本分隔线
---@param text string 文本
function ui.separatorText(text)
    ui.UiSeparatorText.new(text):draw()
end

--- 同行布局
function ui.sameLine()
    ui.UiSameLine.new():draw()
end

--- 间距
function ui.spacing()
    ui.UiSpacing.new():draw()
end

--- 换行
function ui.newLine()
    ui.UiNewLine.new():draw()
end

--- 项目符号
---@param body function? 符号后随内容
function ui.bullet(body)
    local b = ui.UiBullet.new()
    if body ~= nil then
        b:withContent(body)
    end
    b:draw()
end

--- 占位空白
---@param w number 宽
---@param h number 高
function ui.dummy(w, h)
    ui.UiDummy.new(Vector2.new(w, h)):draw()
end

--- 进度条
---@param fraction number 进度（0~1）
---@param w number? 宽度
---@param h number? 高度
---@param overlay string? 覆盖文本
function ui.progressBar(fraction, w, h, overlay)
    ui.UiProgressBar.new(fraction, Vector2.new(w or -1.0, h or 0.0), overlay or ""):draw()
end

--- 值显示
---@param prefix string 前缀
---@param value number 数值
---@param format string? 格式
function ui.value(prefix, value, format)
    ui.UiValue.new(prefix, value, format or ""):draw()
end

-- ===========================================================================
-- 交互控件
-- ===========================================================================

--- 按钮
---@param label string 文本
---@param onClick function? 点击回调
---@param size Vector2? 尺寸
---@return boolean 本帧是否点击
function ui.button(label, onClick, size)
    local btn = ui.UiButton.new(label, size)
    if onClick ~= nil then
        btn:onClick(onClick)
    end
    return btn:draw()
end

--- 小按钮（无边框）
---@param label string 文本
---@param onClick function? 点击回调
---@return boolean 本帧是否点击
function ui.smallButton(label, onClick)
    local btn = ui.UiSmallButton.new(label)
    if onClick ~= nil then
        btn:onClick(onClick)
    end
    return btn:draw()
end

--- 复选框
---@param label string 文本
---@param buf PtrArrayInt32 状态缓冲（ui.i32(0/1)）
---@return boolean 状态是否变化
function ui.checkbox(label, buf)
    return ui.UiCheckbox.new(label, buf):draw()
end

--- 单选按钮
---@param label string 文本
---@param active boolean 是否选中
---@return boolean 本帧是否点击
function ui.radioButton(label, active)
    return ui.UiRadioButton.new(label, active):draw()
end

--- 单选组（共享 value 缓冲）
---@param label string 文本
---@param buf PtrArrayInt32 选中值缓冲
---@param buttonValue number 本按钮代表的值
---@return boolean 本帧是否点击
function ui.radioButtonGroup(label, buf, buttonValue)
    return ui.UiRadioButtonGroup.new(label, buf, buttonValue):draw()
end

--- 可选中项
---@param label string 文本
---@param selected boolean? 是否选中
---@param flags number? 标志
---@return boolean 本帧是否点击
function ui.selectable(label, selected, flags)
    return ui.UiSelectable.new(label, selected or false, flags or 0):draw()
end

--- 滑条（Float）
---@param label string 文本
---@param buf PtrArrayFloat32 值缓冲
---@param min number 最小值
---@param max number 最大值
---@param format string? 格式
---@return boolean 值是否变化
function ui.sliderFloat(label, buf, min, max, format)
    return ui.UiSliderFloat.new(label, buf, min, max, format or "%.3f"):draw()
end

--- 滑条（Int）
---@param label string 文本
---@param buf PtrArrayInt32 值缓冲
---@param min number 最小值
---@param max number 最大值
---@param format string? 格式
---@return boolean 值是否变化
function ui.sliderInt(label, buf, min, max, format)
    return ui.UiSliderInt.new(label, buf, min, max, format or "%d"):draw()
end

--- 拖拽（Float）
---@param label string 文本
---@param buf PtrArrayFloat32 值缓冲
---@param speed number? 步进
---@param min number? 最小值
---@param max number? 最大值
---@return boolean 值是否变化
function ui.dragFloat(label, buf, speed, min, max)
    return ui.UiDragFloat.new(label, buf, speed or 1.0, min or 0.0, max or 0.0,
        "%.3f", 0):draw()
end

--- 拖拽（Int）
---@param label string 文本
---@param buf PtrArrayInt32 值缓冲
---@param speed number? 步进
---@param min number? 最小值
---@param max number? 最大值
---@return boolean 值是否变化
function ui.dragInt(label, buf, speed, min, max)
    return ui.UiDragInt.new(label, buf, speed or 1.0, min or 0, max or 0, "%d", 0):draw()
end

--- 文本输入框（状态保存在控件内，请复用返回对象）
---@param label string 文本
---@param hint string? 占位提示
---@param bufSize number? 缓冲字节数
---@return UiInputText 控件对象（:getText()/:setText()）
function ui.inputText(label, hint, bufSize)
    local w = ui.UiInputText.new(label, bufSize or 256, hint or "", 0)
    w:draw()
    return w
end

--- 数值输入（Float）
---@param label string 文本
---@param buf PtrArrayFloat32 值缓冲
---@param step number? 步进
---@param format string? 格式
---@return boolean 值是否变化
function ui.inputFloat(label, buf, step, format)
    return ui.UiInputFloat.new(label, buf, step or 0.1, 1.0, format or "%.3f"):draw()
end

--- 数值输入（Int）
---@param label string 文本
---@param buf PtrArrayInt32 值缓冲
---@param step number? 步进
---@return boolean 值是否变化
function ui.inputInt(label, buf, step)
    return ui.UiInputInt.new(label, buf, step or 1, 100, "%d"):draw()
end

--- 下拉框（items 数组，选中索引用 Int32 缓冲）
---@param label string 文本
---@param buf PtrArrayInt32 当前选中索引缓冲
---@param items table 字符串数组
---@return boolean 选中项是否变化
function ui.combo(label, buf, items)
    local text = table.concat(items, "\n")
    return ui.UiCombo.new(label, buf, text):draw()
end

--- 列表框（items 数组，选中索引用 Int32 缓冲）
---@param label string 文本
---@param buf PtrArrayInt32 当前选中索引缓冲
---@param items table 字符串数组
---@return boolean 选中项是否变化
function ui.listBox(label, buf, items)
    local text = table.concat(items, "\n")
    return ui.UiListBox.new(label, buf, text):draw()
end

--- 树节点（返回展开状态；展开时执行 body）
---@param label string 文本
---@param body function 子内容
---@return boolean 是否展开
function ui.treeNode(label, body)
    local open = ui.UiTreeNode.new(label):draw()
    if open and body ~= nil then
        body()
    end
    return open
end

--- 折叠标题（返回展开状态；展开时执行 body）
---@param label string 文本
---@param body function? 子内容
---@param flags number? 标志
---@return boolean 是否展开
function ui.collapsingHeader(label, body, flags)
    local open = ui.UiCollapsingHeader.new(label, flags or 0):draw()
    if open and body ~= nil then
        body()
    end
    return open
end

--- 工具提示（鼠标悬停在上一控件时显示）
---@param body function 提示内容
function ui.tooltip(body)
    ui.UiTooltip.new(body):draw()
end

--- 文本工具提示
---@param text string 提示文本
function ui.setTooltip(text)
    ui.UiSetTooltip.new(text):draw()
end

-- ===========================================================================
-- 菜单
-- ===========================================================================

--- 菜单栏
---@param body function 菜单内容
function ui.menuBar(body)
    ui.UiMenuBar.new(body):draw()
end

--- 主菜单栏
---@param body function 菜单内容
function ui.mainMenuBar(body)
    ui.UiMainMenuBar.new(body):draw()
end

--- 菜单
---@param label string 文本
---@param body function 菜单项
---@param enabled boolean? 是否可用（默认 true）
function ui.menu(label, body, enabled)
    ui.UiMenu.new(label, enabled ~= false, body):draw()
end

--- 菜单项
---@param label string 文本
---@param onClick function? 点击回调
---@param opts table? { shortcut, selected, enabled }
---@return boolean 本帧是否点击
function ui.menuItem(label, onClick, opts)
    opts = opts or {}
    local item = ui.UiMenuItem.new(label, opts.shortcut or "", opts.selected or false,
        opts.enabled ~= false)
    if onClick ~= nil then
        item:onClick(onClick)
    end
    return item:draw()
end

--- 菜单分隔线
function ui.menuSeparator()
    ui.UiMenuSeparator.new():draw()
end

-- ===========================================================================
-- 弹出层
-- ===========================================================================

--- 弹出层（BeginPopup/EndPopup 由 draw 自动管理）
---@param id string 弹出层 ID
---@param body function 内容
---@param opts table? { flags }
---@return boolean 是否可见
function ui.popup(id, body, opts)
    opts = opts or {}
    return ui.UiPopup.new(id, opts.flags or 0, body):draw()
end

--- 模态弹出层
---@param name string 名称
---@param body function 内容
---@param opts table? { flags, open }
---@return boolean 是否可见
function ui.modal(name, body, opts)
    opts = opts or {}
    local modal
    if opts.open ~= nil then
        modal = ui.UiPopupModal.new(name, opts.open, body, opts.flags or 0)
    else
        modal = ui.UiPopupModal.new(name, body, opts.flags or 0)
    end
    return modal:draw()
end

--- 打开弹出层
---@param id string 弹出层 ID
---@param flags number? 标志
function ui.openPopup(id, flags)
    ui.UiOpenPopup.new(id, flags or 0):draw()
end

--- 关闭当前弹出层
function ui.closeCurrentPopup()
    ui.UiCloseCurrentPopup.new():draw()
end

-- ===========================================================================
-- 标签页
-- ===========================================================================

--- 标签栏
---@param id string 标签栏 ID
---@param body function 标签内容
---@param flags number? 标志
function ui.tabBar(id, body, flags)
    ui.UiTabBar.new(id, flags or 0, body):draw()
end

--- 标签项
---@param label string 文本
---@param body function 内容
---@param opts table? { flags, open }
---@return boolean 是否可见
function ui.tabItem(label, body, opts)
    opts = opts or {}
    local item
    if opts.open ~= nil then
        item = ui.UiTabItem.new(label, opts.open, body, opts.flags or 0)
    else
        item = ui.UiTabItem.new(label, body, opts.flags or 0)
    end
    return item:draw()
end

-- ===========================================================================
-- 表格
-- ===========================================================================

--- 表格
---@param id string 表格 ID
---@param columns number 列数
---@param body function 内容
---@param opts table? { flags, outerSize, innerWidth }
function ui.table(id, columns, body, opts)
    opts = opts or {}
    ui.UiTable.new(id, columns, opts.flags or 0, opts.outerSize, opts.innerWidth or 0.0,
        body):draw()
end

--- 表格行
---@param body function 行内容
---@param minRowHeight number? 最小行高
function ui.tableRow(body, minRowHeight)
    ui.UiTableRow.new(body, minRowHeight or 0.0):draw()
end

--- 表头
---@param label string 文本
function ui.tableHeader(label)
    ui.UiTableHeader.new(label):draw()
end

--- 表格列定义（在 table 的 body 内调用）
---@param label string 列名
---@param flags number? 标志
---@param initWidthOrWeight number? 初始宽度/权重
function ui.tableSetupColumn(label, flags, initWidthOrWeight)
    ui.UiTableSetupColumn.new(label, flags or 0, initWidthOrWeight or 0.0, 0):draw()
end

--- 表头行
function ui.tableHeadersRow()
    ui.UiTableHeadersRow.new():draw()
end

--- 冻结行列
---@param cols number 冻结列数
---@param rows number 冻结行数
function ui.tableSetupScrollFreeze(cols, rows)
    ui.UiTableSetupScrollFreeze.new(cols, rows):draw()
end

return ui
