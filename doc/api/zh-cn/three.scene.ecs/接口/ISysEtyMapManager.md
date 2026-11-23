# 接口
## interface ISysEtyMapManager < S, E >
```cj
public interface ISysEtyMapManager < S, E >
```
系统-实体映射管理接口

### func addEntity\(E\)
```cj
func addEntity(ety: E): Unit
```
将实体加入到各系统的记录区

参数: 

|名称|类型|描述|
|---|---|---|
|ety|E|实体|

### func addSystem\(S\)
```cj
func addSystem(sys: S): Unit
```
将系统加入记录区

参数: 

|名称|类型|描述|
|---|---|---|
|sys|S|系统|

### func bind\(HashMap<Int64,S>,HashMap<Int64,E>\)
```cj
func bind(systems: HashMap < Int64, S >, entitys: HashMap < Int64, E >): Unit
```
挂接系统表与实体表（引用共享，由 SystemManager 建立）

参数: 

|名称|类型|描述|
|---|---|---|
|systems|HashMap<Int64,S>|系统哈希表entitys 实体哈希表|
|entitys|HashMap<Int64,E>||

### func changeEntity\(Array<UInt8>,E\)
```cj
func changeEntity(oldMask: Array < UInt8 >, ety: E): Unit
```
实体组件变更，调整实体归属记录区

参数: 

|名称|类型|描述|
|---|---|---|
|oldMask|Array<UInt8>|旧组件掩码ety 实体|
|ety|E||

### func clear\(\)
```cj
func clear(): Unit
```
清理所有记录区

### func delEntity\(E\)
```cj
func delEntity(ety: E): Unit
```
将实体从所有系统记录区移除

参数: 

|名称|类型|描述|
|---|---|---|
|ety|E|实体|

### func delSystem\(S\)
```cj
func delSystem(sys: S): Unit
```
从记录区移除系统

参数: 

|名称|类型|描述|
|---|---|---|
|sys|S|系统|

### func getSystemEntitys\(S\)
```cj
func getSystemEntitys(sys: S):(Int64, Iterator < E >)
```
获取系统记录区的所有实体

参数: 

|名称|类型|描述|
|---|---|---|
|sys|S||

返回: 

- (总数, 当轮快照迭代器)

