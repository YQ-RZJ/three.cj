# 枚举
## enum PhysicsMotionType
```cj
public enum PhysicsMotionType
```
刚体运动类型（后端无关抽象，对应 JPH_MotionType）

### Dynamic
```cj
Dynamic
```
受重力/碰撞/力驱动（标准物理模拟对象）

### Kinematic
```cj
Kinematic
```
由用户控制位置/速度（不参与动力学求解）

### Static
```cj
Static
```
完全不动（地面/墙壁等静态物体）

