# 接口
## interface AttributeReader
```cj
public interface AttributeReader
```
顶点属性只读访问接口（getX/getY/getZ/getW + count）

### func getW\(Int64\)
```cj
func getW(index: Int64): Float64
```
读取指定索引的 w（第 3）分量

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|顶点索引|

返回: 

- 分量值

### func getX\(Int64\)
```cj
func getX(index: Int64): Float64
```
读取指定索引的 x（第 0）分量

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|顶点索引|

返回: 

- 分量值

### func getY\(Int64\)
```cj
func getY(index: Int64): Float64
```
读取指定索引的 y（第 1）分量

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|顶点索引|

返回: 

- 分量值

### func getZ\(Int64\)
```cj
func getZ(index: Int64): Float64
```
读取指定索引的 z（第 2）分量

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|顶点索引|

返回: 

- 分量值

### prop count: Int64
```cj
mut prop count: Int64
```
顶点数量

