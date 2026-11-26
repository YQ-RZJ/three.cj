/**
 * @file sdl4cj 包入口
 * @brief sdl4cj 根包声明
 * @explain sdl4cj 是将 C 库 SDL3 封装到仓颉生态系统的项目。
 *         提供以下子包：
 *         - sdl4cj.sdl — SDL3 公共 API 绑定（初始化、窗口、事件、输入设备等）
 *
 * 说明：
 *   - 本封装基于 SDL3 (v3.5.0)，与 cxx/SDL 源码对应。
 *   - 通过宏剔除的功能（AUDIO / CAMERA / RENDER / GPU / DIALOG / TRAY /
 *     NOTIFICATION）不在封装范围内，其余公共 API 均完整 FFI 到仓颉侧。
 *   - 所有仓颉侧导出的结构体、函数、常量、枚举均带注释。
 */
protected package three._vendor.sdl4cj
