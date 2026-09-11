# 类
## class RawQuaternionTrack
```cj
public class RawQuaternionTrack
```
离线四元数通道数据

### func addKeyframe\(Float32,Float32,Float32,Float32,Float32\)
```cj
public func addKeyframe(time: Float32, x: Float32, y: Float32, z: Float32, w: Float32): Unit
```
添加关键帧

参数: 

|名称|类型|描述|
|---|---|---|
|time|Float32||
|x|Float32||
|y|Float32||
|z|Float32||
|w|Float32||

### func init\(String\)
```cj
public init(name: String)
```


参数: 

|名称|类型|描述|
|---|---|---|
|name|String||

### func numKeyframes\(\)
```cj
public func numKeyframes(): Int
```
获取关键帧数量

### func sortKeyframes\(\)
```cj
public func sortKeyframes(): Unit
```
排序关键帧（按时间升序）

### func validate\(\)
```cj
public func validate(): Bool
```
验证数据合法性

返回: 

- true 表示合法

### var keyframes
```cj
public var keyframes: ArrayList < RawQuaternionKeyframe >
```


### var name
```cj
public var name: String
```


