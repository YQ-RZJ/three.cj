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
 * @file[zh-cn] Loader 加载器基类
 * @brief[zh-cn] 所有具体加载器的抽象基类
 * @explain[zh-cn] 提供管理器、路径、跨域等公共配置，所有具体加载器（FileLoader、ImageLoader、TextureLoader 等）的基类。
 *
 * @file[en] Loader  Base loader class
 * @brief[en] Abstract base class for all concrete loaders
 * @explain[en] Provides common configuration such as manager, path, cross-origin, serving as the base class for all concrete loaders (FileLoader, ImageLoader, TextureLoader, etc.).
 */
package three.resource.loader

import std.collection.*
import three.core.interfaces.ILoadResult

/**
 * @brief[zh-cn] 加载器抽象基类
 * @explain[zh-cn] 所有具体加载器（FileLoader、ImageLoader、TextureLoader 等）的基类，提供管理器、路径、跨域等公共配置。
 *
 * @brief[en] Abstract base class for loaders
 * @explain[en] Base class for all concrete loaders (FileLoader, ImageLoader, TextureLoader, etc.), providing common configuration such as manager, path, cross-origin.
 */
public open class Loader {
    /** 加载管理器 */
    public var manager: LoadingManager
    /** 跨域设置 */
    public var crossOrigin: String
    /** 是否带凭据 */
    public var withCredentials: Bool
    /** 基础路径 */
    public var path: String
    /** 资源路径 */
    public var resourcePath: String
    /** 请求头 */
    public var requestHeader: HashMap<String, Any>

    public init(manager!: LoadingManager) {
        this.manager = manager
        this.crossOrigin = "anonymous"
        this.withCredentials = false
        this.path = ""
        this.resourcePath = ""
        this.requestHeader = HashMap<String, Any>()
    }

    public init() {
        this.manager = LoadingManager()
        this.crossOrigin = "anonymous"
        this.withCredentials = false
        this.path = ""
        this.resourcePath = ""
        this.requestHeader = HashMap<String, Any>()
    }

    /**
     * @param[zh-cn] url 资源 URL
     * @param[zh-cn] onLoad 加载完成回调
     * @param[zh-cn] onProgress 加载进度回调
     * @param[zh-cn] onError 加载错误回调
     *
     * @param[en] url Resource URL
     * @param[en] onLoad Load complete callback
     * @param[en] onProgress Load progress callback
     * @param[en] onError Load error callback
     *
     * 加载资源（抽象方法，子类实现）
     */
    public open func load(url: String, onLoad: (ILoadResult) -> Unit, onProgress: (Int64) -> Unit, onError: (String) -> Unit): Unit {}

    /**
     * @param[zh-cn] path 路径
     * @return[zh-cn] 自身引用（链式调用）
     *
     * @param[en] path Path
     * @return[en] Self reference (for chaining)
     *
     * 设置基础路径
     */
    public func setPath(path: String): Loader {
        this.path = path
        return this
    }

    /**
     * @param[zh-cn] resourcePath 资源路径
     * @return[zh-cn] 自身引用
     *
     * @param[en] resourcePath Resource path
     * @return[en] Self reference
     *
     * 设置资源路径
     */
    public func setResourcePath(resourcePath: String): Loader {
        this.resourcePath = resourcePath
        return this
    }

    /**
     * @param[zh-cn] crossOrigin 跨域值
     * @return[zh-cn] 自身引用
     *
     * @param[en] crossOrigin Cross-origin value
     * @return[en] Self reference
     *
     * 设置跨域设置
     */
    public func setCrossOrigin(crossOrigin: String): Loader {
        this.crossOrigin = crossOrigin
        return this
    }

    /**
     * @param[zh-cn] withCredentials 是否带凭据
     * @return[zh-cn] 自身引用
     *
     * @param[en] withCredentials Whether to include credentials
     * @return[en] Self reference
     *
     * 设置是否带凭据
     */
    public func setWithCredentials(withCredentials: Bool): Loader {
        this.withCredentials = withCredentials
        return this
    }

    /**
     * @param[zh-cn] requestHeader 请求头对象
     * @return[zh-cn] 自身引用
     *
     * @param[en] requestHeader Request header object
     * @return[en] Self reference
     *
     * 设置请求头
     */
    public func setRequestHeader(requestHeader: HashMap<String, Any>): Loader {
        this.requestHeader = requestHeader
        return this
    }

    /**
     * @return[zh-cn] 自身引用
     *
     * @return[en] Self reference
     *
     * 中止进行中的请求
     * 仓颉侧本地文件系统读取为同步操作，无可中止的异步请求，保持默认行为。
     */
    public open func abort(): Loader {
        return this
    }
}

/**
 * 加载器创建材质时使用的默认材质名
 */
public let LOADER_DEFAULT_MATERIAL_NAME: String = "__DEFAULT"