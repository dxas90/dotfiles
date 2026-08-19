#!/usr/bin/env python
# -*- coding: utf-8 -*-
# {{_author_}} <{{_email_}}>
# Copyright (c) {{_date_}}
# When I wrote this, only God and I understood what I was doing
# Now, God only knows
import sys

getline = lambda: sys.stdin.readline().strip()

cache = {}
def _cache(n,fun = int, cache = cache):
    try:
        return cache[n]
    except KeyError:
        cache[n] = fun(n)
        return cache[n]

MAXV = 1000

if __name__ == '__main__':
    try:
        if 'MY_FLAG' in sys.argv:
            sys.stdin=open('/tmp/input')
      {{_cursor_}}
    except Exception:
        exit

# ex: ts=4 sw=4 et filetype=python

