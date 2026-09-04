/**
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
