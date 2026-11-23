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
 * @file[zh-cn] UniformsUtils uniform 数据工具
 * @brief[zh-cn] 纯 Array 工具的 uniform 合并/克隆函数（与后端无关）
 * @explain[zh-cn] 原定义在 bgfx 包 ShaderLibs.cj 中；因不依赖任何后端类型，
 * 迁至 renderers.common，供模块内外以抽象路径访问。
 *
 * @file[en] UniformsUtils uniform data utilities
 * @brief[en] Backend-agnostic uniform merge/clone helpers operating on plain Arrays
 * @explain[en] Originally defined in the bgfx package's ShaderLibs.cj; since it depends on no
 * backend type it moved to renderers.common and is reachable via the abstract path.
 *
 * @package three.renderers.common
 */
package three.renderers.common

/**
 * @brief[zh-cn] Uniforms 工具函数
 *
 * @brief[en] Uniform utility functions
 */
public class UniformsUtils {
    public static func merge(base: Array<Float64>, extra: Array<Float64>): Array<Float64> {
        let result = Array<Float64>(base.size + extra.size, {_ => 0.0})
        for (i in 0..base.size) {
            result[i] = base[i]
        }
        for (i in 0..extra.size) {
            result[base.size + i] = extra[i]
        }
        return result
    }

    public static func clone(uniforms: Array<Float64>): Array<Float64> {
        let result = Array<Float64>(uniforms.size, {_ => 0.0})
        for (i in 0..uniforms.size) {
            result[i] = uniforms[i]
        }
        return result
    }
}
