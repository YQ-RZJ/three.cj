/**
 * @file tracy4cj 包入口
 * @brief tracy4cj 根包声明
 * @explain tracy4cj 是将 Tracy Profiler 客户端（TracyC.h C 接口）封装到仓颉
 *         生态系统的项目。提供以下子包（通过完整包路径引用）：
 *         - tracy4cj.tracy — TracyC.h 全部公开 API 绑定
 *           包含：
 *           - types.cj — 结构体与枚举（TracyCZoneCtx / GPU 事件数据 / Plot 格式等）
 *           - constants.cj — 常量（TRACY_CALLSTACK / 消息级别等）
 *           - ffi.cj — foreign 函数声明（包级私有）
 *           - ffi_exports.cj — 公开包装函数（_cj 后缀，unsafe 封装）
 * @note C 侧库 libtracyc.a 由 cxx/build.py 从 TracyClient.cpp 编译产出（tracy4cj/libs/）。
 */
protected package three._vendor.tracy4cj
