#!/usr/bin/env python3
"""
Renumber first numeric field in VALUES(...) for INSERTs in a SQL file (Emails.sql)
Usage: renumber_emails.py /path/to/Emails.sql start_id end_id
Creates a backup `Emails.sql.bak` before overwriting.
"""
import sys
import re
from pathlib import Path


def renumber_file(path: Path, start_id: int, end_id: int, table_name: str = None):
    if not path.exists():
        raise FileNotFoundError(path)
    text = path.read_text(encoding='utf-8')
    bak = path.with_suffix(path.suffix + '.bak')
    bak.write_text(text, encoding='utf-8')

    # If table_name provided, focus on INSERT INTO <table_name>, otherwise all INSERTs
    if table_name:
        pattern = re.compile(rf"(insert\s+into\s+{re.escape(table_name)}\b.*?values\s*\()(.*?)(\))", re.I | re.S)
    else:
        pattern = re.compile(r"(insert\s+into\s+\w+\b.*?values\s*\()(.*?)(\))", re.I | re.S)

    number_re = re.compile(r"\d+")
    new_parts = []
    last_end = 0
    current = start_id
    replaced = 0

    for m in pattern.finditer(text):
        if current > end_id:
            break
        new_parts.append(text[last_end:m.start(2)])
        inner = m.group(2)
        mm = number_re.search(inner)
        if mm:
            new_inner = inner[:mm.start()] + str(current) + inner[mm.end():]
            new_parts.append(new_inner)
            replaced += 1
            current += 1
        else:
            new_parts.append(inner)
        last_end = m.end(2)

    new_parts.append(text[last_end:])
    new_text = ''.join(new_parts)
    path.write_text(new_text, encoding='utf-8')
    last_assigned = current - 1 if replaced > 0 else None
    return replaced, start_id, last_assigned


def main():
    if len(sys.argv) < 4:
        print("Usage: renumber_emails.py /path/to/Emails.sql start_id end_id [tableName]")
        sys.exit(2)
    p = Path(sys.argv[1])
    start = int(sys.argv[2])
    end = int(sys.argv[3])
    table = sys.argv[4] if len(sys.argv) > 4 else None
    try:
        replaced, first, last = renumber_file(p, start, end, table)
        if replaced:
            print(f"Replaced {replaced} INSERTs in {p.name}. New ids: {first}..{last}.")
        else:
            print("No matching INSERTs found/modified.")
    except Exception as e:
        print("Error:", e)
        sys.exit(1)


if __name__ == '__main__':
    main()
