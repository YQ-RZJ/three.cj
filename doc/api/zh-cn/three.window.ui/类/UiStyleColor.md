# 类
## class UiStyleColor
```cj
public class UiStyleColor
```
样式色查询工具

### func fromU32\(UInt32,Float32\)
```cj
public static func fromU32(col: UInt32, alphaMul!: Float32 = 1.0): UInt32
```
按打包 U32 颜色取色（经样式透明度修饰）

参数: 

|名称|类型|描述|
|---|---|---|
|col|UInt32|IM_COL32 打包颜色|
|alphaMul|Float32|透明度乘数|

返回: 

- IM_COL32 格式颜色

### func fromVec4\(Color4\)
```cj
public static func fromVec4(col: Color4): UInt32
```
按自定义颜色取色（经样式透明度修饰）

参数: 

|名称|类型|描述|
|---|---|---|
|col|Color4|RGBA 颜色|

返回: 

- IM_COL32 格式颜色

### func getU32\(Int32,Float32\)
```cj
public static func getU32(col: Int32, alphaMul!: Float32 = 1.0): UInt32
```
按样式色索引取色

参数: 

|名称|类型|描述|
|---|---|---|
|col|Int32|ImGuiCol 索引|
|alphaMul|Float32|透明度乘数（1.0=不修改）|

返回: 

- IM_COL32 格式颜色

### func init\(\)
```cj
public init()
```
构造样式色查询工具（仅静态方法）

