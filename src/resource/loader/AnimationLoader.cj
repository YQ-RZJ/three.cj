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
 * @file[zh-cn] AnimationLoader 动画加载器
 * @brief[zh-cn] 加载 JSON 格式的动画剪辑
 * @explain[zh-cn] 内部使用 FileLoader 加载 JSON 文件，使用 scope.parse(JSON.parse(text)) 解析动画数据，使用 try-catch 处理 JSON 解析错误。
 *
 * @file[en] AnimationLoader  Animation loader
 * @brief[en] Loads JSON-format animation clips
 * @explain[en] Internally uses FileLoader to load JSON files, parses animation data via scope.parse(JSON.parse(text)), and handles JSON parse errors with try-catch.
 */
package three.resource.loader

import three.core.interfaces.ILoadResult
import three.animation.clip.*
import std.collection.*
import fastjson.*
import fastjson.stream.*
import std.io.*

/**
 * @brief[zh-cn] 动画加载器，加载 JSON 格式的动画剪辑文件
 * @explain[zh-cn] 内部使用 FileLoader 加载 JSON 数据，然后解析为 AnimationClip 数组。
 *
 * @brief[en] Animation loader, loads JSON-format animation clip files
 * @explain[en] Internally uses FileLoader to load JSON data, then parses it into an AnimationClip array.
 *
 * @extends Loader
 */
public class AnimationLoader <: Loader {
    public init(manager: LoadingManager) {
        super(manager: manager)
    }

    public init() {
        super()
    }

    /**
     * @param[zh-cn] url 动画文件 URL
     * @param[zh-cn] onLoad 加载完成回调，参数为 Array<AnimationClip>
     * @param[zh-cn] onProgress 进度回调
     * @param[zh-cn] onError 错误回调
     *
     * @param[en] url Animation file URL
     * @param[en] onLoad Load complete callback, parameter is Array<AnimationClip>
     * @param[en] onProgress Progress callback
     * @param[en] onError Error callback
     *
     * 开始加载动画
     * JS 内部使用 FileLoader 加载文本，然后调用 scope.parse(JSON.parse(text))
     */
    public override func load(url: String, onLoad: (ILoadResult) -> Unit, onProgress: (Int64) -> Unit, onError: (String) -> Unit): Unit {
        
        //         loader.setPath(this.path);
        //         loader.setRequestHeader(this.requestHeader);
        //         loader.setWithCredentials(this.withCredentials);
        let loader = FileLoader(this.manager)
        loader.setPath(this.path)
        loader.setRequestHeader(this.requestHeader)
        loader.setWithCredentials(this.withCredentials)

        
        loader.load(url, { text =>
            
            try {
                let jsonStr = match (text) {
                    case s: String => s
                    case _ => ""
                }
                let jsonArray = this.parseJsonToArray(jsonStr)
                let clips = this.parse(jsonArray)
                onLoad(ClipsLoadResult(clips))
            } catch (e: Exception) {
                onError(e.toString())
            }
        }, onProgress, onError)
    }

    /**
     * @param[zh-cn] json JSON 数据
     * @return[zh-cn] 动画剪辑数组
     *
     * @param[en] json JSON data
     * @return[en] Animation clip array
     *
     * 解析 JSON 对象为动画剪辑数组
     */
    public func parse(json: Array<HashMap<String, Any>>): ArrayList<AnimationClip> {
        let animations = ArrayList<AnimationClip>()
        for (i in 0..json.size) {
            let clip = AnimationClip.parse(json[i])
            animations.add(clip)
        }
        return animations
    }

    /**
     * @param[zh-cn] jsonStr JSON 字符串
     * @return[zh-cn] 解析后的 Array<HashMap<String, Any>>
     *
     * @param[en] jsonStr JSON string
     * @return[en] Parsed Array<HashMap<String, Any>>
     *
     * 使用 cjfast_json 将 JSON 字符串解析为 Array<HashMap<String, Any>>
     * 对应 JS: JSON.parse(text)
     */
    public func parseJsonToArray(jsonStr: String): Array<HashMap<String, Any>> {
        try {
            let reader = JsonStreamReader(ByteBuffer(jsonStr.toArray()))
            let result = ArrayList<HashMap<String, Any>>()
            reader.startArray()
            while (let Some(v) <- reader.peek()) {
                if (v != JsonStreamEndArray) {
                    result.add(JsonUtil.streamFromJsonForHashMapAny(reader))
                } else {
                    break
                }
            }
            reader.endArray()
            return result.toArray()
        } catch (_: Exception) {
            // 解析失败时返回空数组
            return Array<HashMap<String, Any>>(0, { _ => HashMap<String, Any>() })
        }
    }
}