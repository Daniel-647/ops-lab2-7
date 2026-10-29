#!/usr/bin/env bash
# 读取 deploy/queries-o3-dashboard.txt 中的 9 条查询，拼出在 Prometheus Web UI 一次打开“三行九格”全部 9 个图表（g0～g8）的 URL。
#
# 用法：
#   scripts/o3-dashboard-url.sh [时间窗，默认 1h]
#   PROM=http://127.0.0.1:9090 scripts/o3-dashboard-url.sh 30m
set -euo pipefail

PROM=${PROM:-http://127.0.0.1:9090}
RANGE=${1:-1h}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
QFILE="$ROOT/deploy/queries-o3-dashboard.txt"

python3 - "$PROM" "$RANGE" "$QFILE" <<'PY'
import sys, urllib.parse

prom, rng, qfile = sys.argv[1].rstrip("/"), sys.argv[2], sys.argv[3]
params = []
idx = 0
with open(qfile, encoding="utf-8") as f:
    for raw in f:
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        parts = line.split(None, 1)
        if len(parts) < 2:
            continue
        _, expr = parts
        params.append((f"g{idx}.expr", expr))
        params.append((f"g{idx}.tab", "0"))
        params.append((f"g{idx}.range_input", rng))
        idx += 1

print(f"{prom}/graph?{urllib.parse.urlencode(params)}")
PY
