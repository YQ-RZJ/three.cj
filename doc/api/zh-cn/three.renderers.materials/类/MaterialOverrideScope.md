# 类
## class MaterialOverrideScope
```cj
public class MaterialOverrideScope
```
per-mesh材质替换器栈（回调注入式）

### func init\(\)
```cj
public init()
```
构造一个新的材质替换器栈

### func pushOverride\(IMesh,\(\)\->IMaterial,\(IMaterial\)\->Unit\)
```cj
public func pushOverride(mesh: IMesh, getter:() -> IMaterial, setter:(IMaterial) -> Unit): Unit
```
压入一条材质替换，先备份当前材质并记录setter回调

参数: 

|名称|类型|描述|
|---|---|---|
|mesh|IMesh|被替换材质的对象句柄getter 获取当前材质的回调setter 还原材质的回调|
|getter|()->IMaterial||
|setter|(IMaterial)->Unit||

### func restoreAll\(\)
```cj
public func restoreAll(): Unit
```
还原所有压入的材质替换（按入栈逆序），还原后清空栈帧

