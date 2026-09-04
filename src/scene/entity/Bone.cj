/**
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
@JsonAdapter[withSuperClass = Object3D]
public class Bone <: Object3D {
    /**
     * @brief[zh-cn] 构造一个新的骨
     *
     * @brief[en] Construct a new bone
     */
    public init() {
        super()
        this.kind = "Bone"
    }
}
