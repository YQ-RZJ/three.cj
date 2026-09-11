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
 * @file[zh-cn] Bone 骨骼骨
 * @brief[zh-cn] 骨骼层次中的一根骨，对应一个变换节点
 * @explain[zh-cn] 与 Object3D 唯一区别：作为 Skeleton/SkinnedMesh 中的骨节点标识，无几何/材质
 *
 * @file[en] Bone  Bone
 * @brief[en] A single bone in the skeleton hierarchy, corresponding to a transform node
 * @explain[en] The only difference from Object3D: serves as a bone node identifier in Skeleton/SkinnedMesh, with no geometry/material
 */
package three.scene.entity
import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 骨骼骨，骨骼层次中的一根骨
 *
 * @brief[en] Bone, a single bone in the skeleton hierarchy
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; withSuperClass = Object3D]
public class Bone <: Object3D {
    /**
     * @brief[zh-cn] 构造一个新的骨
     *
     * @brief[en] Construct a new bone
     */
    public init() {
        super()
    }
}
