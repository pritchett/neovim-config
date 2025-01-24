#!/usr/bin/env python3
import sys
from urllib.parse import unquote

for line in sys.stdin:
    print(unquote(line).strip())
