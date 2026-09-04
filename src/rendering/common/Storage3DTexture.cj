/**
 * @file[zh-cn] 3D 存储纹理
 * @brief[zh-cn] 3D 存储纹理类，用于 GPU 计算/存储的 3D 纹理资源
 * @explain[zh-cn] Storage3DTexture 表示可在计算着色器中读写的三维纹理存储资源，kind 属性标识纹理类型。对照源码: three.js/src/renderers/common/Storage3DTexture.js
 *
 * @file[en] Storage 3D Texture
 * @brief[en] Storage 3D texture class, used for GPU compute/storage 3D texture resources
 * @explain[en] Storage3DTexture represents a 3D texture storage resource that can be read and written in compute shaders, with a kind property identifying the texture type. Reference: three.js/src/renderers/common/Storage3DTexture.js
 */
package three.rendering.common

/**
 * @brief[zh-cn] 3D 存储纹理类
 * @explain[zh-cn] 用于 GPU 计算管线的 3D 纹理存储资源，kind 属性标识纹理类型为 "Storage3DTexture"。
 *
 * @brief[en] Storage 3D texture class
 * @explain[en] 3D texture storage resource for GPU compute pipelines, kind property identifies the texture type as "Storage3DTexture".
 */
public open class Storage3DTexture {

    /**
     * @brief[zh-cn] 纹理类型标识
     *
     * @brief[en] Texture type identifier
     */
    public var kind: String

    /**
     * @brief[zh-cn] 构造器，初始化 kind 为 "Storage3DTexture"
     *
     * @brief[en] Constructor, initializes kind to "Storage3DTexture"
     */
    public init() {
        this.kind = "Storage3DTexture"
    }
}
