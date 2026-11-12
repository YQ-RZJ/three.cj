"""audit_deadcode.py — C1 死代码审计：找出模块内「其他文件零引用」的声明。

用法：python audit_deadcode.py <模块...>
判据（须人工复核，脚本只定位）：
  引擎内部无引用 且 对外部开发者无用 → 死代码，删除；
  对开发者有辅助作用（API parity / 逃生舱 / 库设施 / 对称 API 组 / 运行期多态调用）→ 不是死代码。
特别注意：
  - 事件回调、宏展开调用、script 绑定、序列化（*Json 属性）的调用点静态扫描看不见；
  - 新功能（尚未接线）会被误判，按保留处理并在报告中注明。
"""
import sys
from collections import Counter
import scan_common as sc

# 运行期多态/框架回调等高频误报名字，单独标注提示人工复核
POLYMORPHIC_HINT = {'run', 'update', 'release', 'releasable', 'invoke', 'onAdd',
                    'onRemove', 'onDispose', 'validate', 'apply', 'play', 'stop',
                    'reset', 'clear', 'clone', 'toString'}


def main():
    root = sc.find_repo_root()
    modules = sc.resolve_modules(root, sys.argv[1:])
    sources = sc.precompute_word_counts(sc.load_sources(root, include_test=True))
    rows = []
    for prefix, files in modules:
        for sf in files:
            if not sf.rel.startswith('src/'):
                continue
            for line, indent, kind, name, text, is_open in sc.public_decls(sf):
                outside = sc.usage_outside_file(sources, sf, name)
                if not outside:
                    hint = '  [运行期多态候选，人工复核]' if name in POLYMORPHIC_HINT else ''
                    rows.append((sf.rel, line, kind, name, hint))
    rows.sort()
    for rel, line, kind, name, hint in rows:
        print('DEAD-CANDIDATE  %-52s L%-6d %-9s %s%s' % (rel, line, kind, name, hint))
    print('\n== 统计：本模块零引用声明 %d 处 ==' % len(rows))
    print('每个候选先过 SKILL.md「公开面保留豁免清单」，确认死代码后删除并编译验证。')


if __name__ == '__main__':
    main()
