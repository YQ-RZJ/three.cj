"""audit_pointers.py — C4 原生指针暴露审计。

用法：python audit_pointers.py <模块...>     # 无参数 = 全 src
规则：CPointer<T> 等原生指针不得出现在 public 声明的持久暴露位（prop / 返回值 / 字段）。
输出标签：
  EXPOSED-PROP     public prop/let/var 持有或返回指针 —— 必须处理（改包装或降 internal）
  EXPOSED-RETURN   public func 返回指针 —— 必须处理
  PARAM-OK         指针仅出现在参数中（入参允许，但建议 doc 写明调用方生命周期责任）
  INTERNAL-OK      非 public 声明中出现指针 —— 放行（内部 FFI 热路径合法）
说明：签名可能跨行，本脚本聚合声明行至首个 "{" 或空行为止的文本做判断；结果仅供人工复核。
"""
import re
import sys
import scan_common as sc

PTR_RE = re.compile(r'\b(CPointer\s*<|UnsafePointer|PtrArray\s*<)\s*\w+')


def decl_block(sf, start_line):
    """从声明行聚合到首个 '{' 前或最多 6 行，返回签名文本。"""
    buf = []
    for i in range(start_line - 1, min(start_line + 5, len(sf.lines))):
        t = sf.lines[i]
        buf.append(t)
        if '{' in t or (i > start_line - 1 and t.rstrip().endswith(')')):
            break
    return '\n'.join(buf)


def classify(sig, is_public, kind, indent):
    if not PTR_RE.search(sig):
        return None
    if not is_public:
        return 'INTERNAL-OK'
    # 指针是否只出现在参数括号内
    before_ret = sig.split('):')[0]
    after_ret = sig.split('):', 1)[1] if '):' in sig else ''
    ptr_in_params = bool(PTR_RE.search(before_ret))
    ptr_after = bool(PTR_RE.search(after_ret))
    if kind in ('prop', 'let', 'var') or ptr_after:
        return 'EXPOSED-PROP' if kind in ('prop', 'let', 'var') else 'EXPOSED-RETURN'
    if ptr_in_params:
        return 'PARAM-OK'
    return 'EXPOSED-RETURN'


def main():
    root = sc.find_repo_root()
    modules = sc.resolve_modules(root, sys.argv[1:])
    rows = []
    for prefix, files in modules:
        for sf in files:
            if not sf.rel.startswith('src/'):
                continue
            for line, indent, kind, name, text, is_open in sc.public_decls(sf):
                if kind == 'class' or kind == 'interface':
                    # 类本身不含指针签名；其字段由成员声明覆盖
                    continue
                sig = decl_block(sf, line)
                tag = classify(sig, True, kind, indent)
                if tag:
                    rows.append((tag, sf.rel, line, kind, name, text.strip()[:110]))
    order = ['EXPOSED-PROP', 'EXPOSED-RETURN', 'PARAM-OK', 'INTERNAL-OK']
    rows.sort(key=lambda r: (order.index(r[0]), r[1], r[2]))
    for tag, rel, line, kind, name, text in rows:
        print('%-15s %-52s L%-6d %-9s %s\n%-15s %s' % (tag, rel, line, kind, name, '', ' ' * 17 + text))
    from collections import Counter
    c = Counter(r[0] for r in rows)
    print('\n== 统计 ==')
    for k in order:
        print('%-15s %d' % (k, c.get(k, 0)))


if __name__ == '__main__':
    main()
