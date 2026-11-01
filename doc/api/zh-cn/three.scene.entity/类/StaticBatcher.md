# 类
## class StaticBatcher
```cj
public class StaticBatcher
```
CPU 静态合批工具（纯静态方法集）

### func mergeMeshes\(ArrayList<Mesh>\)
```cj
public static func mergeMeshes(meshes: ArrayList < Mesh >): Mesh
```
合并多个网格为单个静态网格

参数: 

|名称|类型|描述|
|---|---|---|
|meshes|ArrayList<Mesh>|待合并网格列表（非空）|

返回: 

- 合并后的新 Mesh（位于世界原点，isStatic=true）

### func process\(Object3D\)
```cj
public static func process(root: Object3D): ArrayList < Mesh >
```
遍历场景子树，自动分组合并静态网格

参数: 

|名称|类型|描述|
|---|---|---|
|root|Object3D|遍历根节点（通常为 Scene 或 Group）|

返回: 

- 合并生成的新 Mesh 列表（未加入场景，需调用方自行 add）

