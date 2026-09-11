/**
 * @LICENSE
 * Copyright 2026 RaoZiJun
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Runtime Library Exception to the Apache 2.0 License:
 *
 * As an exception, if you use this Software to compile your source code and
 * portions of this Software are embedded into the binary product as a result,
 * you may redistribute such product without providing attribution as would
 * otherwise be required by Sections 4(a), 4(b) and 4(d) of the License.
 *
 * @file[zh-cn] UiTable.cj — ImGui 表格组件
 * @brief[zh-cn] 封装 ImGui 表格 API：BeginTable/EndTable、行/列操作、列设置等
 * @explain[zh-cn] 提供 UiTable、UiTableRow、UiTableHeader、UiTableCell、UiTableSetupColumn、UiTableSetupScrollFreeze、UiTableHeadersRow 七个表格控件，支持列宽设置、排序、冻结行等。用法示例：
 *   UiTable("MyTable", columns: 3).draw({ =>
 *       UiTableRow({ => UiTableHeader("Name"); UiTableHeader("Value"); UiTableHeader("Action") })
 *       UiTableRow({ =>
 *           UiTableCell({ => UiText("Item 1") })
 *           UiTableCell({ => UiText("100") })
 *           UiTableCell({ => UiButton("Edit").draw() })
 *       })
 *   })
 *
 * @file[en] UiTable.cj — ImGui Table Components
 * @brief[en] Wrappers for ImGui table API: BeginTable/EndTable, row/column operations, column setup etc.
 * @explain[en] Provides UiTable, UiTableRow, UiTableHeader, UiTableCell, UiTableSetupColumn, UiTableSetupScrollFreeze, UiTableHeadersRow table widgets with column width, sorting, and freeze-row support.
 */
package three.window.ui

import std.core.*
import imgui4cj.imgui.*
import three.core.math.*

/**
 * @brief[zh-cn] 表格容器控件
 * @explain[zh-cn] 包装 ImGui BeginTable/EndTable，管理表格生命周期。
 *
 * @brief[en] Table container widget
 * @explain[en] Wraps ImGui BeginTable/EndTable and manages the table lifecycle.
 */
public class UiTable <: UiWidget {
    /// 表格标识
    private var _id: String
    /// 列数
    private var _columns: Int32
    /// 表格标志
    private var _flags: Int32
    /// 外部尺寸
    private var _outerSize: Vector2
    /// 内部宽度
    private var _innerWidth: Float32
    /// 内容绘制闭包
    private var _content: () -> Unit

    /**
     * @brief[zh-cn] 构造表格容器
     * @param[zh-cn] id 表格标识
     * @param[zh-cn] columns 列数（默认 1）
     * @param[zh-cn] flags 表格标志（默认 0）
     * @param[zh-cn] outerSize 外部尺寸（默认 0, 0）
     * @param[zh-cn] innerWidth 内部宽度（默认 0.0）
     * @param[zh-cn] content 内容绘制闭包
     *
     * @brief[en] Constructs a table container
     * @param[en] id Table identifier
     * @param[en] columns Number of columns (default 1)
     * @param[en] flags Table flags (default 0)
     * @param[en] outerSize Outer size (default 0, 0)
     * @param[en] innerWidth Inner width (default 0.0)
     * @param[en] content Content drawing closure
     */
    public init(id!: String, columns!: Int32 = 1, flags!: Int32 = 0,
                outerSize!: Vector2 = Vector2(0.0, 0.0),
                innerWidth!: Float32 = 0.0, content!: () -> Unit) {
        super()
        this._id = id
        this._columns = columns
        this._flags = flags
        this._outerSize = outerSize
        this._innerWidth = innerWidth
        this._content = content
    }

    /**
     * @brief[zh-cn] 绘制表格容器
     * @return[zh-cn] 表格是否可见
     *
     * @brief[en] Draws the table container
     * @return[en] Whether the table is visible
     */
    public override func draw(): Bool {
        let cs = unsafe { LibC.mallocCString(this._id) }
        let visible = igBeginTable_cj(cs, this._columns, this._flags,
                                       ImVec2(Float32(this._outerSize.x), Float32(this._outerSize.y)),
                                       this._innerWidth) != 0
        unsafe { LibC.free(cs) }
        if (visible) {
            this._content()
            igEndTable_cj()
        }
        return visible
    }
}

/**
 * @brief[zh-cn] 表格行控件
 * @explain[zh-cn] 包装 ImGui TableNextRow，用于在表格中创建一行。
 *
 * @brief[en] Table row widget
 * @explain[en] Wraps ImGui TableNextRow to create a row in the table.
 */
public class UiTableRow <: UiWidget {
    /// 最小行高
    private var _minRowHeight: Float32
    /// 行内容绘制闭包
    private var _content: () -> Unit

    /**
     * @brief[zh-cn] 构造表格行
     * @param[zh-cn] content 行内容绘制闭包
     * @param[zh-cn] minRowHeight 最小行高（默认 0.0）
     *
     * @brief[en] Constructs a table row
     * @param[en] content Row content drawing closure
     * @param[en] minRowHeight Minimum row height (default 0.0)
     */
    public init(content!: () -> Unit, minRowHeight!: Float32 = 0.0) {
        super()
        this._content = content
        this._minRowHeight = minRowHeight
    }

    /**
     * @brief[zh-cn] 绘制表格行
     * @return[zh-cn] 是否成功创建行
     *
     * @brief[en] Draws the table row
     * @return[en] Whether the row was created
     */
    public override func draw(): Bool {
        igTableNextRow_cj(0, this._minRowHeight)
        this._content()
        return false
    }
}

/**
 * @brief[zh-cn] 表格列头控件
 * @explain[zh-cn] 包装 ImGui TableHeader，用于显示列头文本。
 *
 * @brief[en] Table header widget
 * @explain[en] Wraps ImGui TableHeader to display column header text.
 */
public class UiTableHeader <: UiWidget {
    /// 列头文本
    private var _label: String

    /**
     * @brief[zh-cn] 构造表格列头
     * @param[zh-cn] label 列头文本
     *
     * @brief[en] Constructs a table header
     * @param[en] label Header label
     */
    public init(label!: String) { super(); this._label = label }

    /**
     * @brief[zh-cn] 绘制表格列头
     * @return[zh-cn] 是否完成绘制
     *
     * @brief[en] Draws the table header
     * @return[en] Whether drawing completed
     */
    public override func draw(): Bool {
        let cs = unsafe { LibC.mallocCString(this._label) }
        igTableHeader_cj(cs)
        unsafe { LibC.free(cs) }
        return false
    }
}

/**
 * @brief[zh-cn] 表格单元格控件
 * @explain[zh-cn] 包装 ImGui TableNextColumn，自动移动到下一列后绘制内容。
 *
 * @brief[en] Table cell widget
 * @explain[en] Wraps ImGui TableNextColumn to advance to the next column and draw content.
 */
public class UiTableCell <: UiWidget {
    /// 单元格内容绘制闭包
    private var _content: () -> Unit

    /**
     * @brief[zh-cn] 构造表格单元格
     * @param[zh-cn] content 单元格内容绘制闭包
     *
     * @brief[en] Constructs a table cell
     * @param[en] content Cell content drawing closure
     */
    public init(content!: () -> Unit) { super(); this._content = content }

    /**
     * @brief[zh-cn] 绘制表格单元格
     * @return[zh-cn] 是否完成绘制
     *
     * @brief[en] Draws the table cell
     * @return[en] Whether drawing completed
     */
    public override func draw(): Bool {
        igTableNextColumn_cj()
        this._content()
        return false
    }
}

/**
 * @brief[zh-cn] 表格列设置控件
 * @explain[zh-cn] 包装 ImGui TableSetupColumn，用于配置列的显示属性。
 *
 * @brief[en] Table column setup widget
 * @explain[en] Wraps ImGui TableSetupColumn to configure column display properties.
 */
public class UiTableSetupColumn <: UiWidget {
    /// 列标签
    private var _label: String
    /// 列标志
    private var _flags: Int32
    /// 初始宽度或权重
    private var _initWidthOrWeight: Float32
    /// 用户自定义 ID
    private var _userId: UInt32

    /**
     * @brief[zh-cn] 构造表格列设置
     * @param[zh-cn] label 列标签
     * @param[zh-cn] flags 列标志（默认 0）
     * @param[zh-cn] initWidthOrWeight 初始宽度或权重（默认 0.0）
     * @param[zh-cn] userId 用户自定义 ID（默认 0）
     *
     * @brief[en] Constructs a table column setup
     * @param[en] label Column label
     * @param[en] flags Column flags (default 0)
     * @param[en] initWidthOrWeight Initial width or weight (default 0.0)
     * @param[en] userId User-defined ID (default 0)
     */
    public init(label!: String, flags!: Int32 = 0,
                initWidthOrWeight!: Float32 = 0.0, userId!: UInt32 = 0) {
        super()
        this._label = label
        this._flags = flags
        this._initWidthOrWeight = initWidthOrWeight
        this._userId = userId
    }

    /**
     * @brief[zh-cn] 绘制列设置
     * @return[zh-cn] 是否完成绘制
     *
     * @brief[en] Draws the column setup
     * @return[en] Whether drawing completed
     */
    public override func draw(): Bool {
        let cs = unsafe { LibC.mallocCString(this._label) }
        igTableSetupColumn_cj(cs, this._flags, this._initWidthOrWeight, this._userId)
        unsafe { LibC.free(cs) }
        return false
    }
}

/**
 * @brief[zh-cn] 冻结列/行控件
 * @explain[zh-cn] 包装 ImGui TableSetupScrollFreeze，用于冻结指定数量的列和行。
 *
 * @brief[en] Scroll freeze widget
 * @explain[en] Wraps ImGui TableSetupScrollFreeze to freeze a number of columns and rows.
 */
public class UiTableSetupScrollFreeze <: UiWidget {
    /// 冻结列数
    private var _cols: Int32
    /// 冻结行数
    private var _rows: Int32

    /**
     * @brief[zh-cn] 构造冻结设置
     * @param[zh-cn] cols 冻结列数（默认 0）
     * @param[zh-cn] rows 冻结行数（默认 0）
     *
     * @brief[en] Constructs a scroll freeze setup
     * @param[en] cols Number of frozen columns (default 0)
     * @param[en] rows Number of frozen rows (default 0)
     */
    public init(cols!: Int32 = 0, rows!: Int32 = 0) {
        super()
        this._cols = cols
        this._rows = rows
    }

    /**
     * @brief[zh-cn] 绘制冻结设置
     * @return[zh-cn] 是否完成绘制
     *
     * @brief[en] Draws the scroll freeze setup
     * @return[en] Whether drawing completed
     */
    public override func draw(): Bool {
        igTableSetupScrollFreeze_cj(this._cols, this._rows)
        return false
    }
}

/**
 * @brief[zh-cn] 表头行控件
 * @explain[zh-cn] 包装 ImGui TableHeadersRow，自动提交所有已设置的列头。
 *
 * @brief[en] Table headers row widget
 * @explain[en] Wraps ImGui TableHeadersRow to automatically submit all configured column headers.
 */
public class UiTableHeadersRow <: UiWidget {
    /**
     * @brief[zh-cn] 构造表头行
     *
     * @brief[en] Constructs a table headers row
     */
    public init() { super() }

    /**
     * @brief[zh-cn] 绘制表头行
     * @return[zh-cn] 是否完成绘制
     *
     * @brief[en] Draws the table headers row
     * @return[en] Whether drawing completed
     */
    public override func draw(): Bool {
        igTableHeadersRow_cj()
        return false
    }
}
