/**
 * @file jolt4cj 包入口
 * @brief jolt4cj 根包声明
 * @explain jolt4cj 是将 C++ 物理引擎 JoltPhysics 封装到仓颉生态系统的项目。
 *         提供以下子包（通过完整包路径引用）：
 *         - jolt4cj.jolt — JoltPhysics C 接口层（jolt_capi.h）绑定，
 *           覆盖物理系统生命周期、形状创建、刚体操作与射线查询。
 *
 * C 侧依赖（由 cxx/build.py 交叉编译产出，链接时放入项目根 libs/ 目录）：
 *         - libjolt4cj.a — C 接口层（仓颉 CFFI 直接绑定的符号所在库）
 *         - libJolt.a           — JoltPhysics 本体（C++ 库）
 *         - libstdc++.a / libgcc_eh.a — mingw 下的 C++ 运行时（平台相关）
 */
protected package three._vendor.jolt4cj
