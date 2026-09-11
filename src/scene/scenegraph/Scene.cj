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
 * @file[zh-cn] Scene
 * @brief[zh-cn] 场景，场景图根节点
 * @explain[zh-cn] 场景持有所有渲染对象（Object3D）、雾（Fog/FogExp2）、
 * 背景（background，可 Color/Texture/CubeTexture）、环境贴图（environment）。
 * 渲染器从 Scene 开始遍历场景图完成渲染；autoUpdate 控制是否自动更新场景图矩阵。
 *
 * @file[en] Scene
 * @brief[en] Scene, the root node of the scene graph
 * @explain[en] Scene holds all render objects (Object3D), fog (Fog/FogExp2),
 * background (can be Color/Texture/CubeTexture), and environment map (environment).
 * The renderer traverses the scene graph starting from Scene to complete rendering;
 * autoUpdate controls whether to automatically update the scene graph matrices.
 */
package three.scene.scenegraph
import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.rendering.materials.*
import three.rendering.textures.*
import three.core.interfaces.IBackground
import three.scene.interfaces.IScene
import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 场景，场景图根节点
 * @explain[zh-cn] 持有渲染对象、雾、背景、环境贴图等，实现 IScene 接口
 *
 * @brief[en] Scene, the root node of the scene graph
 * @explain[en] Holds render objects, fog, background, environment map, etc., implements IScene interface
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; withSuperClass = Object3D]
public class Scene <: Object3D & IScene {

    /**
     * @brief[zh-cn] 雾（线性雾）
     *
     * @brief[en] Linear fog
     */
    public var fog: Option<Fog>
    @JsonCustom["fog"]
    public open mut prop fogJson: String {
        get() {
            match (this.fog) {
                case Some(f) => f.toJson()
                case None => "null"
            }
        }
        set(v) {
            if (v == "null" || v.isEmpty()) {
                this.fog = None
            } else {
                this.fog = Some(Fog.fromJson(v))
            }
        }
    }

    /**
     * @brief[zh-cn] 雾（指数雾，与 fog 互斥）
     *
     * @brief[en] Exponential fog (mutually exclusive with fog)
     */
    @JsonIgnore
    public var fogExp2: Option<FogExp2>
    @JsonCustom["fogExp2"]
    public open mut prop fogExp2Json: String {
        get() {
            match (this.fogExp2) {
                case Some(f) => f.toJson()
                case None => "null"
            }
        }
        set(v) {
            if (v == "null" || v.isEmpty()) {
                this.fogExp2 = None
            } else {
                this.fogExp2 = Some(FogExp2.fromJson(v))
            }
        }
    }

    /**
     * @brief[zh-cn] 背景：Some(Color)/Some(Texture)/Some(CubeTexture) 或 None（无背景），默认 None
     *
     * @brief[en] Background: Some(Color)/Some(Texture)/Some(CubeTexture) or None (no background), default None
     */
    public var background: Option<IBackground>
    @JsonCustom["background"]
    public open mut prop backgroundJson: String {
        get() {
            match (this.background) {
                case Some(c: Color) =>
                    let stream = ByteBuffer()
                    let writer = JsonStreamWriter(stream)
                    writer.startObject()
                    writer.writeName("type")
                    "Color".toJson(writer)
                    writer.writeName("value")
                    c.toJson(writer)
                    writer.endObject()
                    writer.flush()
                    String.fromUtf8(readToEnd(stream))
                case Some(t: Texture) =>
                    let stream = ByteBuffer()
                    let writer = JsonStreamWriter(stream)
                    writer.startObject()
                    writer.writeName("type")
                    "Texture".toJson(writer)
                    writer.writeName("uuid")
                    t.uuid.toJson(writer)
                    writer.endObject()
                    writer.flush()
                    String.fromUtf8(readToEnd(stream))
                case _ => "null"
            }
        }
        set(v) {
            // 默认实现：不恢复背景，子类可覆盖
            this.background = None
        }
    }

    /**
     * @brief[zh-cn] 环境贴图（Texture/CubeTexture），默认 None
     *
     * @brief[en] Environment map (Texture/CubeTexture), default None
     */
    public var environment: Option<Texture>
    @JsonCustom["environment"]
    public open mut prop environmentJson: String {
        get() {
            match (this.environment) {
                case Some(t) => t.toJson()
                case None => "null"
            }
        }
        set(v) {
            if (v == "null" || v.isEmpty()) {
                this.environment = None
            } else {
                this.environment = Some(Texture.fromJson(v))
            }
        }
    }

    /**
     * @brief[zh-cn] 环境节点（运行时由 NodeManager 注入），渲染器用该节点替代 scene.environment 计算环境光照
     *
     * @brief[en] Environment node (injected at runtime by NodeManager), renderer uses it instead of scene.environment for environment lighting
     */
    @JsonIgnore
    public var environmentNode: Option<Any>

    /**
     * @brief[zh-cn] 背景模糊度（0=清晰，1=完全模糊），默认 0
     *
     * @brief[en] Background blurriness (0=sharp, 1=fully blurred), default 0
     */
    public var backgroundBlurriness: Float64

    /**
     * @brief[zh-cn] 背景强度（乘法因子），默认 1
     *
     * @brief[en] Background intensity (multiplication factor), default 1
     */
    public var backgroundIntensity: Float64

    /**
     * @brief[zh-cn] 背景旋转（Euler 角度），默认 Identity
     *
     * @brief[en] Background rotation (Euler angles), default Identity
     */
    public var backgroundRotation: Euler

    /**
     * @brief[zh-cn] 环境贴图强度，默认 1
     *
     * @brief[en] Environment map intensity, default 1
     */
    public var environmentIntensity: Float64

    /**
     * @brief[zh-cn] 环境贴图旋转，默认 Identity
     *
     * @brief[en] Environment map rotation, default Identity
     */
    public var environmentRotation: Euler

    /**
     * @brief[zh-cn] 覆盖材质（所有场景物体的材质被替换为此材质），默认 None
     *
     * @brief[en] Override material (all scene objects' materials replaced with this), default None
     */
    @JsonIgnore
    public var overrideMaterial: Option<Material>
    @JsonCustom["overrideMaterial"]
    public open mut prop overrideMaterialJson: String {
        get() {
            match (this.overrideMaterial) {
                case Some(m) => m.toJson()
                case None => "null"
            }
        }
        set(v) {
            if (v == "null" || v.isEmpty()) {
                this.overrideMaterial = None
            } else {
                this.overrideMaterial = Some(Material.fromJson(v))
            }
        }
    }

    /**
     * @brief[zh-cn] 背景节点（运行时由 NodeManager 注入），渲染器用该节点替代 scene.background 渲染背景
     *
     * @brief[en] Background node (injected at runtime by NodeManager), renderer uses it instead of scene.background
     */
    @JsonIgnore
    protected var backgroundNode: Option<Any>

    /**
     * @brief[zh-cn] 构造一个新的场景
     *
     * @brief[en] Construct a new scene
     */
    public init() {
        super()
        this.fog = None
        this.fogExp2 = None
        this.background = None
        this.environment = None
        this.environmentNode = None
        this.backgroundBlurriness = 0.0
        this.backgroundIntensity = 1.0
        this.backgroundRotation = Euler()
        this.environmentIntensity = 1.0
        this.environmentRotation = Euler()
        this.overrideMaterial = None
        this.backgroundNode = None
    }

    /**
     * @brief[zh-cn] 将给定场景实例的值复制到本实例
     * @param[zh-cn] source 源对象
     * recursive 是否递归复制子对象
     * @return[zh-cn] 返回 this
     *
     * @brief[en] Copy values from the given scene instance to this instance
     * @param[en] source Source object
     * recursive Whether to recursively copy children
     * @return[en] Returns this
     */
    public override func copy(source: Object3D, recursive: Bool): Object3D {
        super.copy(source, recursive)
        match (source) {
            case s: Scene =>
                match (s.fog) {
                    case Some(f) => this.fog = Some(f.clone())
                    case None => this.fog = None
                }
                match (s.fogExp2) {
                    case Some(f) => this.fogExp2 = Some(f.clone())
                    case None => this.fogExp2 = None
                }
                // background 深拷贝（对照 JS: source.background.clone()）
                match (s.background) {
                    case Some(b) => match (b) {
                        case c: Color => this.background = Some(c.clone())
                        case t: Texture => this.background = Some(t.clone())
                        case _ => this.background = s.background
                    }
                    case None => this.background = None
                }
                // environment 深拷贝（对照 JS: source.environment.clone()）
                match (s.environment) {
                    case Some(e) => this.environment = Some(e.clone())
                    case None => this.environment = None
                }
                this.backgroundBlurriness = s.backgroundBlurriness
                this.backgroundIntensity = s.backgroundIntensity
                this.backgroundRotation.copy(s.backgroundRotation)
                this.environmentIntensity = s.environmentIntensity
                this.environmentRotation.copy(s.environmentRotation)
                // overrideMaterial 深拷贝（对照 JS: source.overrideMaterial.clone()）
                match (s.overrideMaterial) {
                    case Some(m) => this.overrideMaterial = Some(m.clone())
                    case None => this.overrideMaterial = None
                }
                this.matrixAutoUpdate = s.matrixAutoUpdate
            case _ => ()
        }
        return this
    }

    /**
     * @brief[zh-cn] 返回一个与本实例值相同的新场景实例
     * @return[zh-cn] 新场景实例
     *
     * @brief[en] Return a new scene instance with the same values as this instance
     * @return[en] New scene instance
     */
    public override func clone(): Object3D {
        let obj = Scene()
        return obj.copy(this, true)
    }
}
