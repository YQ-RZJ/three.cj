# 类
## class AdditiveAnimationBuilder
```cj
public class AdditiveAnimationBuilder
```
叠加动画构建器

### func invoke\(RawAnimation,RawAnimation\)
```cj
public func invoke(base: RawAnimation, target: RawAnimation): Option < RawAnimation >
```
从基础和目标动画构建叠加动画

参数: 

|名称|类型|描述|
|---|---|---|
|base|RawAnimation|基础动画（休息姿势 / idle）|
|target|RawAnimation|目标动画（要叠加的动作）|

返回: 

- 叠加动画（delta）

