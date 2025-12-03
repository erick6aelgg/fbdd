#!/usr/bin/env python3
"""
Renumber the id_persona_r column values in INSERTs into Registrar to a sequential range.

Usage: renumber_registrar_id_persona_r.py /path/to/Registrar.sql 4001 5000

This script:
- creates a backup Registrar.sql.bak
- finds INSERTs of the form: insert into Registrar (col1, col2, id_persona_r, ...) values (...)
- parses the column list to find the index of id_persona_r and replaces that value in the VALUES(...) tuple
- supports multiline INSERT and quoted strings when parsing commas
"""
import sys
import re
from pathlib import Path


def split_top_level_commas(s: str):
    """Split a string by commas at top-level (not inside quotes or parentheses)."""
    parts = []
    buf = []
    in_s = False
    in_d = False
    depth = 0
    i = 0
    while i < len(s):
        c = s[i]
        if c == "'" and not in_d:
            in_s = not in_s
            buf.append(c)
        elif c == '"' and not in_s:
            in_d = not in_d
            buf.append(c)
        elif not in_s and not in_d:
            if c == '(':
                depth += 1
                buf.append(c)
            elif c == ')':
                depth = max(0, depth-1)
                buf.append(c)
            elif c == ',' and depth == 0:
                parts.append(''.join(buf).strip())
                buf = []
            else:
                buf.append(c)
        else:
            buf.append(c)
        i += 1
    if buf:
        parts.append(''.join(buf).strip())
    return parts


def renumber(path: Path, start: int, end: int):
    if not path.exists():
        raise FileNotFoundError(path)
    text = path.read_text(encoding='utf-8')
    bak = path.with_suffix(path.suffix + '.bak')
    bak.write_text(text, encoding='utf-8')

    pattern = re.compile(r"(insert\s+into\s+Registrar\s*\((.*?)\)\s*values\s*\()(.*?)(\))", re.I | re.S)
    number_re = re.compile(r"\d+")

    new_parts = []
    last_end = 0
    current = start
    replaced = 0

    for m in pattern.finditer(text):
        if current > end:
            break
        new_parts.append(text[last_end:m.start(3)])
        cols_raw = m.group(2)
        cols = split_top_level_commas(cols_raw)
        # find index of id_persona_r
        idx = None
        for i, c in enumerate(cols):
            if c.strip().lower() == 'id_persona_r':
                idx = i
                break
        inner = m.group(3)
        # split inner values tuple top-level
        vals = split_top_level_commas(inner)
        if idx is not None and idx < len(vals) and current <= end:
            # replace first number inside vals[idx]
            token = vals[idx]
            mm = number_re.search(token)
            if mm:
                token_new = token[:mm.start()] + str(current) + token[mm.end():]
                vals[idx] = token_new
                replaced += 1
                current += 1
        # reconstruct inner
        new_inner = ', '.join(vals)
        new_parts.append(new_inner)
        last_end = m.end(3)

    new_parts.append(text[last_end:])
    new_text = ''.join(new_parts)
    path.write_text(new_text, encoding='utf-8')
    last_assigned = current - 1 if replaced > 0 else None
    return replaced, start, last_assigned


def main():
    if len(sys.argv) < 4:
        print("Usage: renumber_registrar_id_persona_r.py /path/to/Registrar.sql start end")
        sys.exit(2)
    p = Path(sys.argv[1])
    start = int(sys.argv[2])
    end = int(sys.argv[3])
    try:
        replaced, first, last = renumber(p, start, end)
        if replaced:
            print(f"Replaced {replaced} id_persona_r values. New ids: {first}..{last}.")
        else:
            print("No id_persona_r values changed.")
    except Exception as e:
        print('Error:', e)
        sys.exit(1)


if __name__ == '__main__':
    main()
