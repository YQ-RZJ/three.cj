# 接口
## interface ICircularQueue < T >
```cj
public interface ICircularQueue < T > <: IQueue < T >
```
循环队列接口

### func next\(\)
```cj
func next():?T
```
循环获取下一个元素（不消耗）

返回: 

- 下一个元素；空时返回 None

