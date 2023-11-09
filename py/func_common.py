#!/usr/bin/env python3
import re

def ToSnakeCase(s):
    cust = s.replace('_', '')
    return re.sub(r'(?<!^)(?=[A-Z])', '_', cust).upper()