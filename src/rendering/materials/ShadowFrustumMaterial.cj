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
 * @file[zh-cn] 阴影相机视锥可视化材质
 * @brief[zh-cn] 阴影相机视锥可视化材质（bgfx4cj扩展）
 * @explain[zh-cn] 
 * 对应 Three.js 无（bgfx4cj 扩展）。与 ShadowProjMaterial 共用思路（ShaderLibs 里复用 shadowproj 程序），
 * 用于 debug mode 5：把视锥顶点经 lightProj * lightView 变换后输出。
 * 实际 sp_shadowfrustum 项目通常用 LineSegments 几何直接绘制 box，此材质保留兼容入口。
 * 关联 ShaderLibs 程序名 "shadowfrustum"。
 *
 * @file[en] Shadow Frustum Material
 * @brief[en] Shadow camera frustum visualization material (bgfx4cj extension)
 * @explain[en] 
 * No Three.js counterpart (bgfx4cj extension). Shares approach with ShadowProjMaterial (reuses shadowproj program in ShaderLibs).
 * Used in debug mode 5: transforms frustum vertices via lightProj * lightView and outputs them.
 * In practice, sp_shadowfrustum projects typically use LineSegments geometry to draw the box directly;
 * this material is kept for compatibility.
 * Associated ShaderLibs program name "shadowfrustum".
 */
package three.rendering.materials

/**
 * @brief[zh-cn] 阴影相机视锥可视化材质
 * @explain[zh-cn] 
 * 对应 Three.js 无（bgfx4cj 扩展）。用于 debug mode 5：把视锥顶点经 lightProj * lightView 变换后输出。
 *
 * @brief[en] Shadow camera frustum visualization material
 * @explain[en] 
 * No Three.js counterpart (bgfx4cj extension). Used in debug mode 5: transforms frustum vertices via lightProj * lightView.
 */
public class ShadowFrustumMaterial <: Material {
    /**
     * @brief[zh-cn] 构造一个新的阴影相机视锥可视化材质
     *
     * @brief[en] Construct a new shadow frustum material
     */
    public init() {
        super()
        this.kind = "ShadowFrustumMaterial"
        this.transparent = false
    }

    /**
     * @brief[zh-cn] 将给定ShadowFrustumMaterial的属性复制到本实例
     * @param[zh-cn] source 源材质
     * @return[zh-cn] 本实例
     *
     * @brief[en] Copy the properties from the given ShadowFrustumMaterial to this instance
     * @param[en] source Source material
     * @return[en] This instance
     */
    public func copy(source: ShadowFrustumMaterial): ShadowFrustumMaterial {
        super.copy(source)
        return this
    }
}
