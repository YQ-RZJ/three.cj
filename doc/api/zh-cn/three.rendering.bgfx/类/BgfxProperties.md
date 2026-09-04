# 类
## class BgfxProperties
```cj
public class BgfxProperties
```
bgfx 属性存储

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放所有数据

### func get\(Object3D\)
```cj
public func get(obj: Object3D): HashMap < String, Any >
```
获取对象的关联数据映射

参数: 

|名称|类型|描述|
|---|---|---|
|obj|Object3D|对象|

返回: 

- 属性映射

### func has\(Object3D\)
```cj
public func has(obj: Object3D): Bool
```
检查对象是否有关联数据

参数: 

|名称|类型|描述|
|---|---|---|
|obj|Object3D|对象|

返回: 

- 是否有关联数据

### func init\(\)
```cj
public init()
```


### func remove\(Object3D\)
```cj
public func remove(obj: Object3D): Unit
```
删除对象的关联数据

参数: 

|名称|类型|描述|
|---|---|---|
|obj|Object3D|对象|

### func update\(Object3D,String,Any\)
```cj
public func update(obj: Object3D, key: String, value: Any): Unit
```
更新对象的某个属性

参数: 

|名称|类型|描述|
|---|---|---|
|obj|Object3D|对象key 属性键value 属性值|
|key|String||
|value|Any||

