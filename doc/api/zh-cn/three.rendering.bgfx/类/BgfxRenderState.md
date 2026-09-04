# 类
## class BgfxRenderState
```cj
public class BgfxRenderState
```
渲染状态

### func getLightCount\(\)
```cj
public func getLightCount(): Int64
```
获取光源数量

返回: 

- 光源数量

### func getLights\(\)
```cj
public func getLights(): ArrayList < Light >
```
获取光源列表

返回: 

- 光源列表

### func getShadowCount\(\)
```cj
public func getShadowCount(): Int64
```
获取阴影数量

返回: 

- 阴影数量

### func getShadows\(\)
```cj
public func getShadows(): ArrayList < LightShadow >
```
获取阴影列表

返回: 

- 阴影列表

### func init\(\)
```cj
public init()
```


### func pushLight\(Light\)
```cj
public func pushLight(light: Light): Unit
```
添加光源

参数: 

|名称|类型|描述|
|---|---|---|
|light|Light|光源对象|

### func pushShadow\(LightShadow\)
```cj
public func pushShadow(shadow: LightShadow): Unit
```
添加阴影

参数: 

|名称|类型|描述|
|---|---|---|
|shadow|LightShadow|阴影对象|

### func reset\(Int64\)
```cj
public func reset(sceneId: Int64): Unit
```
初始化渲染状态

参数: 

|名称|类型|描述|
|---|---|---|
|sceneId|Int64|场景 ID|

