/**
 * @file imgui4cj 包入口
 * @brief imgui4cj 根包声明
 * @explain imgui4cj 是将 ImGui (v1.92.3) 封装到仓颉生态系统的项目。
 *         提供以下子包：
 *         - imgui4cj.imgui — ImGui 核心 API 绑定（生命周期、帧控制、Widget 等）
 *
 * 说明：
 *   - 渲染后端：bgfx（CherryGrove's imgui_impl_bgfx，header-only C++）
 *   - 平台后端：SDL3（imgui_impl_sdl3）
 *   - C wrapper 层：cxx/imgui_cj_wrapper.cpp 提供纯 C 接口
 *   - 线程模型：NewFrame + 事件处理 + Widget 在 pump 线程；RenderDrawData 在 bgfx 渲染线程
 */
protected package three._vendor.imgui4cj
