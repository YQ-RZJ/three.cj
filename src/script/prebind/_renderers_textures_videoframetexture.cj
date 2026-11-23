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
 * @file[zh-cn] renderers_textures_videoframetexture VideoFrameTexture 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.textures.VideoFrameTexture 绑定为 Lua 类型
 * three.renderers.textures.VideoFrameTexture
 * @explain[zh-cn] 构造参数按位置映射：width / height 必填。复用 _prebindRtxTextureMembers
 * 登记 Texture 全部成员（update() 经虚分派命中 VideoTexture 的 override），并补充 setFrame
 * （Array<UInt8> 帧数据，经 prebindBytes 读取）。
 *
 * @file[en] renderers_textures_videoframetexture  Lua binding of VideoFrameTexture
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.textures.VideoFrameTexture as the Lua type
 * three.renderers.textures.VideoFrameTexture
 * @explain[en] Constructor arguments are mapped positionally: width / height, both required.
 * _prebindRtxTextureMembers registers all Texture members (update() is dispatched virtually to
 * VideoTexture's override); setFrame (Array<UInt8> frame data, read via prebindBytes) is added on
 * top.
 */
package three.script.prebind

import three.renderers.textures.VideoFrameTexture
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 VideoFrameTexture 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.textures.VideoFrameTexture）
 *
 * @brief[en] Installs the Lua binding of VideoFrameTexture
 * @param[en] vm The target virtual machine (class table installed at
 * three.renderers.textures.VideoFrameTexture)
 */
public func installVideoFrameTexture(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.textures.VideoFrameTexture")
    // ===== 构造 =====
    b.constructor {
        args => VideoFrameTexture(prebindInt(args, 0), prebindInt(args, 1))
    }
    _prebindRtxTextureMembers(b, vm)
    // ===== 帧数据 =====
    b.method("setFrame") {
        ref, args =>
            ref.cast<VideoFrameTexture>().setFrame(prebindBytes(vm, args, 0))
            Array<LuaValue>()
    }
    b.install(vm)
}
