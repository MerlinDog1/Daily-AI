#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
TODAY=$(date -u +%F)
TMP=$(mktemp)

gh api "search/repositories?q=topic:artificial-intelligence+pushed:>${TODAY}&sort=stars&order=desc&per_page=5" \
  --jq '.items[] | {headline:.full_name,url:.html_url,note:(.description // "")}' > "$TMP" || true

TMPFILE="$TMP" python3 - <<'PY'
import json, os, pathlib
p=pathlib.Path('data/posts.json')
data=json.loads(p.read_text()) if p.exists() else []
today=os.popen('date -u +%F').read().strip()
if any(x.get('date')==today for x in data): raise SystemExit(0)
repos=[]
for line in pathlib.Path(os.environ['TMPFILE']).read_text().splitlines():
    line=line.strip()
    if not line: continue
    try: repos.append(json.loads(line))
    except: pass
entry={
  "date":today,
  "title":"Automated Daily Brief",
  "summary":"Daily AI digest generated in baseline long-form format. Include US labs, China AI, Open Source, Local vs API tools, and practical implementation notes.",
  "tags":["us-labs","china","open-source","github","openclaw","local-ai","api"],
  "stats":[],
  "sections":[
    {"name":"Breaking AI News","items":[]},
    {"name":"Open Source AI","items":[]},
    {"name":"Hot GitHub (Fresh Picks)","items":repos[:6]},
    {"name":"Run It Locally 🏠 LOCAL","items":[]},
    {"name":"API Tools ☁️ API","items":[]}
  ],
  "implementation":"Add 3 concrete experiments based on today’s developments.",
  "sources":[
    {"name":"Hacker News","url":"https://news.ycombinator.com/"},
    {"name":"GitHub Trending","url":"https://github.com/trending?since=daily"}
  ]
}
data.insert(0,entry)
p.write_text(json.dumps(data,indent=2))
PY

if ! git diff --quiet; then
  git add -A
  git commit -m "daily update: ${TODAY}" || true
  git push origin main
fi
