# Class
## class GfxStencilFlag
```cj
public class GfxStencilFlag
```
Stencil state bits (composition of the fstencil/bstencil bitfields of setStencil)

### let OP\_FAIL\_S\_KEEP
```cj
public static let OP_FAIL_S_KEEP: UInt32 = 0x00100000
```
模板测试失败时保持

### let OP\_FAIL\_Z\_KEEP
```cj
public static let OP_FAIL_Z_KEEP: UInt32 = 0x01000000
```
深度测试失败时保持

### let OP\_PASS\_Z\_KEEP
```cj
public static let OP_PASS_Z_KEEP: UInt32 = 0x10000000
```
深度测试通过时保持

### let OP\_PASS\_Z\_REPLACE
```cj
public static let OP_PASS_Z_REPLACE: UInt32 = 0x20000000
```
深度测试通过时替换为参考值

### let TEST\_ALWAYS
```cj
public static let TEST_ALWAYS: UInt32 = 0x00080000
```
测试：始终通过

### let TEST\_EQUAL
```cj
public static let TEST_EQUAL: UInt32 = 0x00030000
```
测试：等于（模板值 == 参考值）

