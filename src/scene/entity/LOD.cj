/**
 * @file[zh-cn] LOD 细节层级
 * @brief[zh-cn] 根据物体到相机距离切换不同精度层级对象的场景节点
 * @explain[zh-cn] 各 level 是 (子对象, 距离阈值) 元组，渲染时按相机距离选最合适的层。
 * 0 距离最高精度，远距离用粗化几何降开销。
 *
 * @file[en] LOD  Level of Detail
 * @brief[en] Scene node that switches between different detail level objects based on distance to camera
 * @explain[en] Each level is a (child object, distance threshold) tuple; rendering selects the most appropriate level by camera distance.
 * Zero distance is highest detail; greater distances use coarser geometry for lower cost.
 */
package three.scene.entity
import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.rendering.cameras.*
import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] LOD 细节层级节点，根据相机距离切换不同精度层级
 *
 * @brief[en] LOD (Level of Detail) node that switches between detail levels based on camera distance
 */
@JsonAdapter[withSuperClass = Object3D]
public class LOD <: Object3D {
    /**
     * @brief[zh-cn] 是否自动更新（渲染器内部使用）
     *
     * @brief[en] Whether to auto-update (used internally by renderer)
     */
    public var autoUpdate: Bool

    // 距离切换的滞后量，避免在阈值边界来回切换引起闪烁。
    public var hysteresis: Float64

    // 层级数组，每项为 (子对象, 距离阈值)，按距离升序。
    // 仓颉版用元组 (Object3D, Float64) 替代 JS 的 {distance, object} 对象。
    // （元组类型 fastjson 不支持，序列化忽略）
    @JsonIgnore
    public var levels: ArrayList<(Object3D, Float64)>

    // 当前激活的层级索引（渲染器内部使用，私有，不参与序列化）。
    @JsonIgnore
    private var _currentLevel: Int64

    // 构造一个新的 LOD。
    public init() {
        super()
        this.autoUpdate = true
        this.hysteresis = 0.0
        this.kind = "LOD"
        this.levels = ArrayList<(Object3D, Float64)>()
        this._currentLevel = -1
    }

    // 添加一个 LOD 层级。
    // object - 该距离阈值使用的子对象。
    // distance - 距离阈值（米）。
    public func addLevel(object: Object3D, distance!: Float64 = 0.0): Unit {
        // 按 distance 升序插入，保证 levels 始终有序。
        // 仓颉 ArrayList 无 insert，故用 add + 手动后移实现有序插入。
        var i = 0
        var found = false
        for (lvl in this.levels) {
            if ((!found) && distance < lvl[1]) {
                found = true
            }
            if (found) {
                // 跳过：此处仅用于推进 i 计数到插入位置
            }
            i += 1
        }
        // 重新计算插入位置（升序）
        var insertIdx = 0
        for (lvl in this.levels) {
            if (distance < lvl[1]) { break }
            insertIdx += 1
        }
        // 重建 levels：把新元素插入到 insertIdx 位置
        var newLevels = ArrayList<(Object3D, Float64)>()
        var j = 0
        for (lvl in this.levels) {
            if (j == insertIdx) {
                newLevels.add((object, distance))
            }
            newLevels.add(lvl)
            j += 1
        }
        if (j == insertIdx) {
            newLevels.add((object, distance))
        }
        this.levels = newLevels
        
        // 渲染管线 _collectRenderObjects 遍历收集；此前缺失导致 LOD 子球不可见。
        this.add(object)
    }

    // 返回当前距离应使用的子对象。
    // distance - 相机距离。
    public func getObjectForDistance(distance: Float64): Object3D {
        if (this.levels.size > 0) {
            // 与 JS side 一致：返回最后一个 distance <= 给定距离的 level.object
            var result: Object3D = this.levels[0][0]
            for (lvl in this.levels) {
                if (distance >= lvl[1]) {
                    result = lvl[0]
                } else {
                    break
                }
            }
            return result
        }
        return this
    }

    // 仅用于用户代码：手动通知 LOD 哪个层级应激活（不直接由渲染调用）。
    // 渲染器内部以 update(camera) 自动判定，与 JS side 一致。
    public func setCurrentLevel(level: Int64): Unit {
        this._currentLevel = level
    }

    // 获取当前激活的层级索引。对照 JS: LOD.js getCurrentLevel() { return this._currentLevel; }
    public func getCurrentLevel(): Int64 {
        return this._currentLevel
    }

    // 按距离阈值移除一个层级。对照 JS: LOD.js removeLevel( distance )。
    // 找到 distance 匹配的层级并从 levels 与场景子对象中移除，成功返回 true。
    // 仓颉 ArrayList 无 splice/remove，参考 addLevel 的重建模式实现。
    public func removeLevel(distance: Float64): Bool {
        var idx = -1
        for (i in 0..this.levels.size) {
            if (this.levels[i][1] == distance) {
                idx = i
                break
            }
        }
        if (idx < 0) { return false }
        let obj = this.levels[idx][0]
        var newLevels = ArrayList<(Object3D, Float64)>()
        for (i in 0..this.levels.size) {
            if (i != idx) {
                newLevels.add(this.levels[i])
            }
        }
        this.levels = newLevels
        this.remove(obj)
        return true
    }

    // 按相机位置自动切换激活层级。与 JS side 一致含 hysteresis 判断。
    // camera - 渲染当前相机。
    public func update(camera: Camera): Unit {
        // 与 JS side 一致：用相机世界位置到本对象世界位置的距离判定
        let dist = this.getWorldPosition(Vector3()).distanceTo(camera.position)
        // 计算滞后后的距离阈值
        // 找到第一个 level 的 distance + hysteresis 大于 dist 的索引
        var levelIndex = -1
        for (i in 0..this.levels.size) {
            let lvl = this.levels[i]
            if (dist < lvl[1] + this.hysteresis) {
                levelIndex = i - 1
                break
            }
            levelIndex = i
        }
        if (levelIndex < 0) { levelIndex = 0 }
        // 标记激活层级，渲染器内部据此显示/隐藏对应子对象。
        this._currentLevel = levelIndex
        
        // levels[i-1].visible=false）——只有当前层级可见，其余隐藏。
        for (i in 0..this.levels.size) {
            let lvl = this.levels[i]
            lvl[0].visible = (i == levelIndex)
        }
    }

    // 是否可见（受 LOD 自动更新影响；渲染器内会按 _currentLevel 显隐各子对象）。
    public func visibleAtDistance(distance: Float64): Bool {
        return this.getObjectForDistance(distance).uuid != this.uuid
    }

    // 释放本实例及其各层级子对象的 GPU 资源。
    // 注意：JS LOD 没有 dispose() 方法，此为仓颉侧补充的清理功能
    public func dispose(): Unit {
        this.levels.clear()
        this.dispatchEvent(Event("dispose"))
    }

    // 将给定 LOD 实例的值复制到本实例。
    public override func copy(source: Object3D, recursive: Bool): Object3D {
        super.copy(source, recursive)
        match (source) {
            case s: LOD =>
                this.autoUpdate = s.autoUpdate
                this.hysteresis = s.hysteresis
                // 重建 levels：克隆各子对象，保留距离
                this.levels.clear()
                for (lvl in s.levels) {
                    this.levels.add((lvl[0].clone(), lvl[1]))
                }
            case _ => ()
        }
        return this
    }

    // 返回一个与本实例值相同的新 LOD 实例。
    public override func clone(): Object3D {
        let obj = LOD()
        return obj.copy(this, true)
    }
}
