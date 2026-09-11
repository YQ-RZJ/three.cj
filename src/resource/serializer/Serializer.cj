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
 * @file[zh-cn] Serializer JSON 序列化子包重公开
 * @brief[zh-cn] JSON 序列化子包：重公开 cjfast_json（fastjson）全部公开 API
 * @explain[zh-cn] 设计目标：外部使用 three.cj 时，只需 import three.resource.serializer.* 即可获得完整的 JSON 序列化/反序列化能力，无需直接接触 fastjson 包。重公开范围包括 fastjson 包的 JsonUtil、异常类、IStreamJsonAdapter<T> 接口，以及 fastjson.stream 包的 JsonStreamReader、JsonStreamWriter、WriteConfig、JsonStreamSerializable、JsonStreamDeserializable<T> 接口等。注解宏由宏包子包 three.resource.serializer.macros 重公开。
 *
 * @file[en] Serializer  JSON serialization sub-package re-export
 * @brief[en] JSON serialization sub-package: re-exports all public APIs of cjfast_json (fastjson)
 * @explain[en] Design goal: when using three.cj externally, simply import three.resource.serializer.* to get full JSON serialization/deserialization capabilities without directly accessing the fastjson package. Re-exported scope includes fastjson package's JsonUtil, exception classes, IStreamJsonAdapter<T> interface, and fastjson.stream package's JsonStreamReader, JsonStreamWriter, WriteConfig, JsonStreamSerializable, JsonStreamDeserializable<T> interfaces etc. Annotation macros are re-exported by macro sub-package three.resource.serializer.macros.
 */
package three.resource.serializer

// 重公开 fastjson 核心包：JsonUtil / 异常类 / IStreamJsonAdapter<T>
public import fastjson.*

// 重公开 fastjson.stream 包：JsonStreamReader / JsonStreamWriter / WriteConfig /
// JsonStreamSerializable / JsonStreamDeserializable / JsonToken
public import fastjson.stream.*
