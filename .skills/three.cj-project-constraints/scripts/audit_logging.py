"""audit_logging.py — C6 日志合规审计：找出绕过日志宏的裸输出。

用法：python audit_logging.py            # 全 src 扫描
规则：src/ 业务代码中的诊断输出必须使用 LogMacros.cj 的宏
     （@LogError/@LogWarn/@LogWarnOnce/@LogInfo/@LogDebug/@LogTrace），
     禁止裸 println / print。
豁免目录：src/main.cj（启动早期）、src/utils/log/**（Logger 本体与宏包）、
          任意 */macros/**（纯宏包内部实现）。
"""
import re
import sys
import scan_common as sc

PRINT_RE = re.compile(r'(?<![.\w])(println|print)\s*\(')


def is_exempt(rel):
    if rel == 'src/main.cj':
        return True
    if rel.startswith('src/utils/log/'):
        return True
    if '/macros/' in rel or rel.endswith('/macros.cj'):
        return True
    return False


def main():
    root = sc.find_repo_root()
    sources = [sf for sf in sc.load_sources(root, include_test=False)
               if sf.rel.startswith('src/') and not is_exempt(sf.rel)]
    rows = []
    for sf in sources:
        for i, line in enumerate(sf.lines, 1):
            # 跳过注释行，避免文档示例误报
            t = line.strip()
            if t.startswith('//') or t.startswith('*'):
                continue
            m = PRINT_RE.search(line)
            if m:
                rows.append((sf.rel, i, m.group(1), t[:110]))
    rows.sort()
    for rel, line, fn, text in rows:
        print('VIOLATION  %-52s L%-6d %s\n%-12s %s' % (rel, line, fn, '', ' ' * 12 + text))
    print('\n== 统计：裸输出违规 %d 处 ==' % len(rows))
    print('改写为日志宏：@LogDebug(["标签", "内容 ${x}"]) / @LogWarn / @LogError / ...，'
          '编译期档位门控（THREE_LOG_LEVEL），release 零开销。')


if __name__ == '__main__':
    main()
