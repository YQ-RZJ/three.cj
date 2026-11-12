# [1.0.0]

## Feature

feat: 在资源模块加入解压相关能力；
docs: 更新 readme 的 "项目结构" 部分；
skills: 新增 `.skills\three.cj-project-guide` 技能用于AI快速检索当前项目相关信息；
skills: 新增 `.skills\three.cj-project-constraints` 技能用于约束项目代码，确保项目代码长期可维护；
docs: 全量更新 API 文档
feat: 加入自绘控件的案例；
docs: 合并 `dev manual` 和 `materials` 到 `references` 目录内；
feat: 加入坐标、光标相关能力；
feat: 统一ui使用的数据类型；
feat: 安全化ui的使用方法；
feat: 为 ui 加入更多公开方法
feat: 加入窗口引擎的声明式写法；
chore: 调整 test\windows\gui 测试项目用新的窗口声明式写法；
feat: 原子化 safe/Safe<T>
docs: readme.md 追加关于环境变量的设置介绍
feat: 为仓颉代码加入自动编译打包流程
docs: Update API documentation
feat: 统一使用 IReleasable 管理资源释放和有效性检查，以便于统一经由 Safe<T> 实现 GC 挂靠；
docs: 新增文档
feat: 加入 Safe<T> 泛型统一资源的安全处理，挂靠 GC 自动释放；
feat: 加入 IReleasable 接口，统一资源释放函数命名等；
Optimize: 渲染管线化 renderAsync/syncFrame
chore: 加入 二进制产物引用项目示例
chore: 更新构建脚本
feat: 全量动、静包编译

## Fix

fix: 优化项目公开修饰符，避免过度公开；
fix: 修正环境变量 EXTEND_*
fix: 将仓颉侧依赖包合并如deps.a的逻辑改为直接打包；

# [0.3.0]

## Feature

chore: 优化存量注释格式；
feat: 为后处理相关类加入终结器，确保使用安全（自动释放），提升程序健壮性；
docs: 增加内存泄漏判定规则；
docs: 加入标准的内存泄漏排查参考手册

## Fix

fix: 修复部分内存泄漏风险
fix: 对 vector 的私有成员补上 @JsonIgnore

# [0.2.0]

## Feature

docs: 更新相关文档；
chore: 引擎 match 解 Option 转为 if-let 写法；
Optimize: 优化测试项目呈现与计算；
Optimize: 优化性能（线程协作无锁化 SPSC，收尾）；
Optimize: 优化性能（线程协作无锁化 SPSC，物理线程）；
Optimize: 优化性能（线程协作无锁化 SPSC）；
Optimize: 优化性能（测试项目全量推进完成）；
Optimize: 优化性能（已推进至 sp_depth 测试项目）；
Optimize: 优化性能（已推进至 outputpass 测试项目）；
Optimize: 优化性能（已推进至 gui 测试项目）；
Optimize: 优化性能（已推进至 dotscreen 测试项目）；
Optimize: 渲染性能优化、文件加载优化；
Optimize: 音频相关部分优化；
Optimize: 优化性能（动画、Pass、编译等）；
feat: 增加内置的数据结构、测试覆盖等；
optimize: 优化性能；
Optimize: 优化性能（剔除优化）；
feat: 调整初始化渲染器时的参数，解开默认的垂直同步限制；
Optimize: 优化渲染性能（FPS）
chore: 性能调优测试项目加入fps和drawcall等信息...；
chore: 调整信息输出范式；
rm: comment
feat: 基本实现自动化性能调优所需的代码、辅助脚本等；
docs: 同步更新性能调优相关的文档；

## Fix

fix: 修复引擎实测"画面冻结"挂死：cjc 对紧邻 z 字段（偏移 24，对象共32 字节）的向量化读取会生成 movupd 16 字节加载，越过对象尾部8 字节。当该对象恰被 GC 分配在堆已提交区域最末尾时，越界读命中未映射页触发访问违例，且运行时异常处理器恢复后原地重试，形成永久异常循环（卡死现场：gdb 采样 RIP 恒为Triangle.computeBarycoord+56 movupd 0x18(%r9)，下一页0x...68000 不可读）。本字段把对象撑到 40 字节，使该 SIMD 读完整落在对象内部，从根上消除越界。帧率越高分配越频繁、堆前沿 越易被压实到页边界，故高性能路径必触发。

# [0.1.0]

## Feature

+ 完成对 渲染、物理、音频、网络、脚本、动画、场景、窗口与UI、性能剖面 等相关的功能封装和开发；
