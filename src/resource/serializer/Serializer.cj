/**
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
