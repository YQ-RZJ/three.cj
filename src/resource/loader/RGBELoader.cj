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
 * @file[zh-cn] RGBELoader Radiance RGBE HDR 纹理加载器
 * @brief[zh-cn] 对应 Three.js examples/jsm/loaders/RGBELoader.js 的仓颉侧实现
 * @explain[zh-cn] Radiance RGBE HDR 加载器。JS 侧 r180 起 RGBELoader 已弃用（改为 HDRLoader），此处保持同名兼容子类，行为与 HDRLoader 一致。
 *
 * @file[en] RGBELoader  Radiance RGBE HDR texture loader
 * @brief[en] Cangjie implementation corresponding to Three.js examples/jsm/loaders/RGBELoader.js
 * @explain[en] Radiance RGBE HDR loader. Since JS r180, RGBELoader is deprecated (replaced by HDRLoader); this keeps the same name as a compatibility subclass with identical behavior to HDRLoader.
 */
package three.resource.loader

import three.utils.constants.*

/**
 * @brief[zh-cn] RGBE 加载器（兼容旧名）
 * @explain[zh-cn] 继承 HDRLoader 的兼容子类（弃用，建议使用 HDRLoader）
 *
 * @brief[en] RGBE loader (legacy compatible name)
 * @explain[en] Compatibility subclass extending HDRLoader (deprecated, HDRLoader recommended)
 *
 * @extends HDRLoader
 */
public class RGBELoader <: HDRLoader {
    public init(manager: LoadingManager) {
        super(manager)
    }

    public init() {
        super()
    }

    /**
     * @brief[zh-cn] 设置纹理数据类型
     * @explain[zh-cn] 设置纹理数据类型。仓颉侧父类 HDRLoader.setDataType 返回 HDRLoader，此处不重定义（行为一致）。
     * @param[zh-cn] value FloatType 或 HalfFloatType
     *
     * @brief[en] Set texture data type
     * @explain[en] Sets texture data type. Cangjie side parent HDRLoader.setDataType returns HDRLoader; not redefined here (behavior identical).
     * @param[en] value FloatType or HalfFloatType
     */
    public func setRGBEDataType(value: Int64): Unit {
        this.`type` = value
    }
}
