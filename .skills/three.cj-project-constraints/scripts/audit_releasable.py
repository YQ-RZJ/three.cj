"""audit_releasable.py — C5 资源释放审计：找出疑似持有底层资源但未实现 IReleasable 的类。

用法：python audit_releasable.py <模块...>     # 无参数 = 全 src
启发式（仅提示，人工确认）：类体满足任一条件视为"疑似需手动释放"：
  - 含 CPointer< 字段
  - 含 *Handle 类型字段
  - 已自定义 func release
若类头未出现 IReleasable → 报 MISSING-IRELEASEABLE。
已正确实现（接口或自定义等价机制）→ 报 OK-IMPL，便于抽样核对 releasable/release 语义。
"""
import re
import sys
import scan_common as sc

CLASS_RE = re.compile(r'^(\s*)((?:public|internal|protected|private)\s+)?(abstract\s+|open\s+)*class\s+([A-Za-z_]\w*)')
FIELD_HANDLE_RE = re.compile(r'^\s*(?:private\s+|internal\s+|protected\s+|public\s+)?(?:let|var)\s+\w+\s*:\s*\w*Handle\b')
FIELD_PTR_RE = re.compile(r'^\s*(?:private\s+|internal\s+|protected\s+|public\s+)?(?:let|var)\s+\w+\s*:\s*CPointer\s*<')


def class_blocks(sf):
    """产出 (line, name, header_text, end_line)：按缩进界定类体范围。"""
    starts = []
    for i, ln in enumerate(sf.lines, 1):
        m = CLASS_RE.match(ln)
        if m and len(m.group(1)) == 0:  # 仅顶层类
            starts.append((i, m.group(4), ln.rstrip()))
    blocks = []
    for idx, (line, name, header) in enumerate(starts):
        end = starts[idx + 1][0] - 1 if idx + 1 < len(starts) else len(sf.lines)
        blocks.append((line, name, header, end))
    return blocks


def main():
    root = sc.find_repo_root()
    modules = sc.resolve_modules(root, sys.argv[1:])
    rows = []
    for prefix, files in modules:
        for sf in files:
            if not sf.rel.startswith('src/'):
                continue
            for line, name, header, end in class_blocks(sf):
                body = '\n'.join(sf.lines[line - 1:end])
                if 'IReleasable' in header:
                    tag = 'OK-IMPL'
                else:
                    has_release = re.search(r'\bfunc\s+release\s*\(', body) is not None
                    has_handle = bool(FIELD_HANDLE_RE.search(body))
                    has_ptr = bool(FIELD_PTR_RE.search(body))
                    if not (has_release or has_handle or has_ptr):
                        continue
                    why = []
                    if has_release: why.append('自定义 release')
                    if has_handle: why.append('Handle 字段')
                    if has_ptr: why.append('CPointer 字段')
                    tag = 'MISSING-IRELEASEABLE'
                    rows.append((tag, sf.rel, line, name, ','.join(why)))
                    continue
                rows.append((tag, sf.rel, line, name, ''))
    rows.sort()
    for tag, rel, line, name, why in rows:
        mark = '  ← 疑似需手动释放: ' + why if why else ''
        print('%-20s %-56s L%-6d %s%s' % (tag, rel, line, name, mark))
    from collections import Counter
    c = Counter(r[0] for r in rows)
    print('\n== 统计 ==  OK-IMPL=%d  MISSING-IRELEASEABLE=%d' % (c.get('OK-IMPL', 0), c.get('MISSING-IRELEASEABLE', 0)))
    print('MISSING 项人工确认后按 IReleasable 语义补齐：releasable prop + 幂等 release() + 级联释放。')


if __name__ == '__main__':
    main()
