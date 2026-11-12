"""audit_visibility.py — C2 可见性审计：对模块内全部 public 声明做全库交叉引用并分类。

用法：python audit_visibility.py <模块...>     # 如 animation / rendering/bgfx / core/math
输出标签：
  KEEP-INTERFACE          公共接口包中的声明，保持 public
  KEEP-OPEN               open 扩展点（open func / open class），默认保留，人工复核
  KEEP-EXTERNAL           模块外真实使用，保留 public
  KEEP-TEST               仅测试包使用，不可降级（protected/internal 会阻断测试）
  KEEP-PARITY?            零引用 + 同包使用，需人工过豁免清单（API parity/逃生舱/对称组）
  CANDIDATE-PROTECTED     仅同包使用，且声明带 open（子类扩展语义），可改 protected
  CANDIDATE-INTERNAL      仅同包使用且无子类语义，可改 internal
  DEAD-CHECK              全库零引用，先过 C1 死代码判定，再决定收窄或删除
"""
import sys
import scan_common as sc


def classify(sf, decl, outside):
    line, indent, kind, name, text, is_open = decl
    if sf.package.endswith('.interfaces') or '/interfaces/' in sf.rel:
        return 'KEEP-INTERFACE'
    test_use = sum(v for k, v in outside.items() if sc.is_test_pkg(k))
    external = sum(v for k, v in outside.items() if not sc.is_test_pkg(k))
    if is_open and indent > 0:
        return 'KEEP-OPEN'
    if external > 0:
        return 'KEEP-EXTERNAL'
    if test_use > 0:
        return 'KEEP-TEST'
    if indent > 0:
        return 'CANDIDATE-PROTECTED'
    return 'KEEP-PARITY?'


def main():
    root = sc.find_repo_root()
    modules = sc.resolve_modules(root, sys.argv[1:])
    sources = sc.precompute_word_counts(sc.load_sources(root, include_test=True))
    rows = []
    for prefix, files in modules:
        for sf in files:
            if not sf.rel.startswith('src/'):
                continue
            for decl in sc.public_decls(sf):
                outside = sc.usage_outside_file(sources, sf, decl[3])
                tag = classify(sf, decl, outside)
                rows.append((tag, sf.rel, decl[0], decl[2], decl[3]))
    order = ['KEEP-INTERFACE', 'KEEP-OPEN', 'KEEP-EXTERNAL', 'KEEP-TEST',
             'KEEP-PARITY?', 'CANDIDATE-PROTECTED', 'DEAD-CHECK']
    rows.sort(key=lambda r: (order.index(r[0]), r[1], r[2]))
    from collections import Counter
    stat = Counter(r[0] for r in rows)
    for r in rows:
        print('%-22s %-52s L%-6d %-9s %s' % r)
    print('\n== 统计 ==')
    for k in order:
        print('%-22s %d' % (k, stat.get(k, 0)))
    print('提示：CANDIDATE-* 与 KEEP-PARITY? 均须先过 SKILL.md「公开面保留豁免清单」，'
          '修改后用 EXTEND_LIBS_PATH_WIN_X64=<repo>/three.cj/three.cj/libs cjpm build 验证。')


if __name__ == '__main__':
    main()
