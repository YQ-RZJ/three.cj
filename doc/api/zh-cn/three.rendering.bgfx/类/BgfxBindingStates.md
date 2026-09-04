# 类
## class BgfxBindingStates
```cj
public class BgfxBindingStates
```
bgfx 顶点绑定状态管理

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放所有绑定状态

### func init\(\)
```cj
public init()
```


### func releaseStatesOfGeometry\(Int64\)
```cj
public func releaseStatesOfGeometry(geometryId: Int64): Unit
```
释放几何体的绑定状态

参数: 

|名称|类型|描述|
|---|---|---|
|geometryId|Int64|几何体 ID|

### func releaseStatesOfProgram\(Int64\)
```cj
public func releaseStatesOfProgram(programId: Int64): Unit
```
释放程序的绑定状态

参数: 

|名称|类型|描述|
|---|---|---|
|programId|Int64|程序 ID|

### func reset\(\)
```cj
public func reset(): Unit
```
重置绑定状态

### func setup\(Int64,Int64,Int64,Bool\)
```cj
public func setup(geometryId: Int64, objectId: Int64, programId: Int64, wireframe: Bool): BindingState
```
设置顶点绑定

参数: 

|名称|类型|描述|
|---|---|---|
|geometryId|Int64|几何体 IDobjectId 对象 IDprogramId 程序 IDwireframe 是否线框模式|
|objectId|Int64||
|programId|Int64||
|wireframe|Bool||

返回: 

- 绑定状态

