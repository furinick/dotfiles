#!/usr/bin/env python3
import sys, re, json

failed = 0
for f in sys.argv[1:]:
    try:
        src = open(f).read()
        src = re.sub(r"//[^\n]*", "", src)
        src = re.sub(r"/\*.*?\*/", "", src, flags=re.DOTALL)
        json.loads(src)
        print(f"  ok: {f}")
    except json.JSONDecodeError as e:
        print(f"  fail: {f}: {e}")
        failed = 1

sys.exit(failed)
