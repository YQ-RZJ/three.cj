# 类
## class ProgrammableStage
```cj
public open class ProgrammableStage
```
着色器可编程阶段描述

### func getCode\(\)
```cj
public func getCode(): String
```
获取着色器代码

返回: 

- 着色器代码

### func getStage\(\)
```cj
public func getStage(): String
```
获取着色器阶段

返回: 

- 着色器阶段

### func init\(String,String\)
```cj
public init(code: String, kind: String)
```
构造可编程阶段，指定代码和类型

参数: 

|名称|类型|描述|
|---|---|---|
|code|String|着色器代码kind 着色器类型|
|kind|String||

### var code
```cj
public var code: String
```
着色器代码

### var kind
```cj
public var kind: String
```
着色器类型（如 "vertex"、"fragment"、"compute"）

### var stage
```cj
public var stage: String
```
着色器阶段（默认与 kind 相同）

