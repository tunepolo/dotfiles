#!/usr/bin/env python3
"""Pattern 3: Ring meter - pie-like circle segments"""
import json, sys

data = json.load(sys.stdin)

R = '\033[0m'
DIM = '\033[2m'
BOLD = '\033[1m'

RINGS = ['○', '◔', '◑', '◕', '●']

def gradient(pct):
    if pct < 50:
        r = int(pct * 5.1)
        return f'\033[38;2;{r};200;80m'
    else:
        g = int(200 - (pct - 50) * 4)
        return f'\033[38;2;255;{max(g, 0)};60m'

def ring(pct):
    idx = min(int(pct / 25), 4)
    return RINGS[idx]

def fmt(label, pct):
    p = round(pct)
    return f'{DIM}{label}{R} {gradient(pct)}{ring(pct)} {p}%{R}'

model = data.get('model', {}).get('display_name', 'Claude')
parts = [f'{BOLD}{model}{R}']

ctx = data.get('context_window', {}).get('used_percentage')
if ctx is not None:
    parts.append(fmt('ctx', ctx))

five = data.get('rate_limits', {}).get('five_hour', {}).get('used_percentage')
if five is not None:
    parts.append(fmt('5h', five))

week = data.get('rate_limits', {}).get('seven_day', {}).get('used_percentage')
if week is not None:
    parts.append(fmt('7d', week))

# Persist the latest rate-limit snapshot so long-running jobs can pause before the quota runs out.
if data.get('rate_limits'):
    import os, time
    path = os.path.expanduser('~/.cache/claude-usage.json')
    try:
        with open(path + '.tmp', 'w') as f:
            json.dump({'updated_at': int(time.time()), 'rate_limits': data['rate_limits']}, f)
        os.replace(path + '.tmp', path)
    except OSError:
        pass

print('  '.join(parts), end='')
