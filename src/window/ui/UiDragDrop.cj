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
 * @file[zh-cn] UiDragDrop.cj — ImGui 拖放组件
 * @brief[zh-cn] 封装 ImGui 拖放 API：BeginDragDropSource/Target、Accept/Set/GetPayload
 * @explain[zh-cn] 提供 UiDragDropSource、UiDragDropTarget、UiSetDragDropPayload、UiAcceptDragDropPayload、UiGetDragDropPayload 五个拖放控件。用法示例：
 *   UiDragDropSource("DragItem").draw({ => UiText("Dragging this item") })
 *   UiDragDropTarget({ => payload => UiText("Drop here: " + payload.getType()) })
 *
 * @file[en] UiDragDrop.cj — ImGui Drag & Drop Components
 * @brief[en] Wrappers for ImGui drag & drop API: BeginDragDropSource/Target, Accept/Set/GetPayload
 * @explain[en] Provides UiDragDropSource, UiDragDropTarget, UiSetDragDropPayload, UiAcceptDragDropPayload, UiGetDragDropPayload drag-and-drop widgets.
 */
package three.window.ui

import std.core.*
import imgui4cj.imgui.*

/**
 * @brief[zh-cn] 拖拽源控件
 * @explain[zh-cn] 包装 ImGui BeginDragDropSource/EndDragDropSource，用于为子内容开启拖拽源。
 *
 * @brief[en] Drag source widget
 * @explain[en] Wraps ImGui BeginDragDropSource/EndDragDropSource to enable drag source for child content.
 */
public class UiDragDropSource <: UiWidget {
    /// 拖拽源标志
    private var _flags: Int32
    /// 子内容绘制闭包
    private var _content: () -> Unit

    /**
     * @brief[zh-cn] 构造拖拽源
     * @param[zh-cn] flags 拖拽源标志（默认 0）
     * @param[zh-cn] content 子内容绘制闭包
     *
     * @brief[en] Constructs a drag source
     * @param[en] flags Drag source flags (default 0)
     * @param[en] content Child content drawing closure
     */
    public init(flags!: Int32 = 0, content!: () -> Unit) {
        super()
        this._flags = flags
        this._content = content
    }

    /**
     * @brief[zh-cn] 绘制拖拽源
     * @return[zh-cn] 是否进入拖拽状态
     *
     * @brief[en] Draws the drag source
     * @return[en] Whether the drag source is active
     */
    public override func draw(): Bool {
        if (igBeginDragDropSource_cj(this._flags) != 0) {
            this._content()
            igEndDragDropSource_cj()
            return true
        }
        return false
    }
}

/**
 * @brief[zh-cn] 拖放目标控件
 * @explain[zh-cn] 包装 ImGui BeginDragDropTarget/EndDragDropTarget，用于接收拖放数据。
 *
 * @brief[en] Drag-and-drop target widget
 * @explain[en] Wraps ImGui BeginDragDropTarget/EndDragDropTarget to receive drag payloads.
 */
public class UiDragDropTarget <: UiWidget {
    /// 子内容绘制闭包
    private var _content: () -> Unit

    /**
     * @brief[zh-cn] 构造拖放目标
     * @param[zh-cn] content 子内容绘制闭包
     *
     * @brief[en] Constructs a drag-and-drop target
     * @param[en] content Child content drawing closure
     */
    public init(content!: () -> Unit) {
        super()
        this._content = content
    }

    /**
     * @brief[zh-cn] 绘制拖放目标
     * @return[zh-cn] 是否处于可接收拖放状态
     *
     * @brief[en] Draws the drag-and-drop target
     * @return[en] Whether the target is active
     */
    public override func draw(): Bool {
        if (igBeginDragDropTarget_cj() != 0) {
            this._content()
            igEndDragDropTarget_cj()
            return true
        }
        return false
    }
}

/**
 * @brief[zh-cn] 设置拖放数据控件
 * @explain[zh-cn] 包装 ImGui SetDragDropPayload，用于在拖拽源中设置当前拖拽数据类型。
 *
 * @brief[en] Set drag payload widget
 * @explain[en] Wraps ImGui SetDragDropPayload to set the current drag payload type inside a drag source.
 */
public class UiSetDragDropPayload <: UiWidget {
    /// 数据类型标识
    private var _type: String
    /// 拖放标志
    private var _flags: Int32

    /**
     * @brief[zh-cn] 构造拖放数据设置控件
     * @param[zh-cn] `type` 数据类型标识
     * @param[zh-cn] flags 拖放标志（默认 0）
     *
     * @brief[en] Constructs a drag payload setter
     * @param[en] `type` Payload type identifier
     * @param[en] flags Drag-and-drop flags (default 0)
     */
    public init(`type`!: String, flags!: Int32 = 0) {
        super()
        this._type = `type`
        this._flags = flags
    }

    /**
     * @brief[zh-cn] 设置当前拖拽数据
     * @return[zh-cn] 是否设置成功
     *
     * @brief[en] Sets the current drag payload
     * @return[en] Whether the payload was set
     */
    public override func draw(): Bool {
        let cs = unsafe { LibC.mallocCString(this._type) }
        let r = igSetDragDropPayload_cj(cs, CPointer<Unit>(), UIntNative(0), this._flags) != 0
        unsafe { LibC.free(cs) }
        return r
    }
}

/**
 * @brief[zh-cn] 接受拖放数据控件
 * @explain[zh-cn] 包装 ImGui AcceptDragDropPayload，用于在拖放目标中接收指定类型的数据。
 *
 * @brief[en] Accept drag payload widget
 * @explain[en] Wraps ImGui AcceptDragDropPayload to receive a payload of a specified type inside a drop target.
 */
public class UiAcceptDragDropPayload <: UiWidget {
    /// 期望的数据类型标识
    private var _type: String
    /// 接受标志
    private var _flags: Int32
    /// 接受成功时的回调
    private var _onAccept: Option<() -> Unit> = None

    /**
     * @brief[zh-cn] 构造拖放数据接受控件
     * @param[zh-cn] `type` 期望的数据类型标识
     * @param[zh-cn] flags 接受标志（默认 0）
     *
     * @brief[en] Constructs a drag payload acceptor
     * @param[en] `type` Expected payload type identifier
     * @param[en] flags Accept flags (default 0)
     */
    public init(`type`!: String, flags!: Int32 = 0) {
        super()
        this._type = `type`
        this._flags = flags
    }

    /**
     * @brief[zh-cn] 设置接受成功时的回调
     * @param[zh-cn] callback 回调函数
     * @return[zh-cn] 当前实例，支持链式调用
     *
     * @brief[en] Sets the callback invoked when a payload is accepted
     * @param[en] callback Callback function
     * @return[en] The current instance for chaining
     */
    public func onAccept(callback: () -> Unit): UiAcceptDragDropPayload {
        this._onAccept = Some(callback)
        return this
    }

    /**
     * @brief[zh-cn] 尝试接受拖放数据
     * @return[zh-cn] 是否成功接受数据
     *
     * @brief[en] Attempts to accept the drag payload
     * @return[en] Whether a payload was accepted
     */
    public override func draw(): Bool {
        let cs = unsafe { LibC.mallocCString(this._type) }
        let payload = igAcceptDragDropPayload_cj(cs, this._flags)
        unsafe { LibC.free(cs) }
        let accepted = !payload.isNull()
        if (accepted) {
            match (this._onAccept) {
                case Some(f) => f()
                case None => ()
            }
        }
        return accepted
    }
}

/**
 * @brief[zh-cn] 获取拖放数据控件
 * @explain[zh-cn] 包装 ImGui GetDragDropPayload，用于查询当前有效的拖放数据（当前帧有效）。
 *
 * @brief[en] Get drag payload widget
 * @explain[en] Wraps ImGui GetDragDropPayload to query the currently active drag payload (valid for the current frame).
 */
public class UiGetDragDropPayload <: UiWidget {
    /// 数据类型过滤（当前实现未使用）
    private var _type: String

    /**
     * @brief[zh-cn] 构造拖放数据获取控件
     * @param[zh-cn] `type` 数据类型标识（默认空字符串）
     *
     * @brief[en] Constructs a drag payload getter
     * @param[en] `type` Payload type identifier (default empty string)
     */
    public init(`type`!: String = "") { super(); this._type = `type` }

    /**
     * @brief[zh-cn] 获取当前拖拽数据
     * @return[zh-cn] 是否存在有效拖拽数据
     *
     * @brief[en] Gets the current drag payload
     * @return[en] Whether a valid payload exists
     */
    public override func draw(): Bool {
        let payload = igGetDragDropPayload_cj()
        if (!payload.isNull()) {
            // payload 是 ImGuiPayload 指针，可通过类型查询
        }
        return !payload.isNull()
    }
}
