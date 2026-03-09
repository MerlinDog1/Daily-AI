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
entry={"date":today,"title":"Automated Daily Brief","summary":"Auto-generated entry. For full lab/news coverage configure BRAVE_API_KEY.","tags":["github","open-source","openclaw"],"sections":[{"name":"Trending AI GitHub Repos","items":repos[:5]}],"implementation":"Pick one development and test practical use in active projects."}
data.insert(0,entry)
p.write_text(json.dumps(data,indent=2))
PY

if ! git diff --quiet -- data/posts.json; then
  git add data/posts.json
  git commit -m "daily update: ${TODAY}" || true
  git push origin main
fi
