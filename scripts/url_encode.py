#!/usr/bin/env python3
import sys
from urllib.parse import quote

if len(sys.argv) > 1:
    print(quote(sys.argv[1].strip()).strip())
else:
    for line in sys.stdin:
        print(quote(line.strip()).strip())
