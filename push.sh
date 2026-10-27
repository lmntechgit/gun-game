#!/usr/bin/env bash
set -euo pipefail
cd /opt/data/gun-game

PAT=$(grep -o 'github_pat_[A-Za-z0-9_]*' /opt/data/home/.hermes/.env | head -1)
API="https://api.github.com"

# 1. create repo (idempotent)
CODE=$(curl -s -o /tmp/createrepo.json -w "%{http_code}" -X POST \
  -H "Authorization: Bearer $PAT" \
  -H "Accept: application/vnd.github+json" \
  "$API/user/repos" \
  -d '{"name":"gun-game","description":"The People Are Guns","private":false}')
echo "create_repo_http=$CODE"
head -c 400 /tmp/createrepo.json; echo

# 2. push
rm -rf .git
git init -q -b main
printf 'test.py\n' > .gitignore
printf '# The People Are Guns\n\nArena shooter where anthropomorphic firearms fight. Canvas 2D, zero dependencies, single HTML file.\n\n## Controls\n- WASD/Arrows: move\n- Mouse: aim\n- Click/Space: fire\n- Shift: dash\n\nWaves of rogue guns attack. Every 5th wave is THE ARMORY boss.\n' > README.md
git add -A
git -c user.name=lmntechgit -c user.email=lmntechgit@users.noreply.github.com commit -q -m "The People Are Guns: canvas arena shooter"
git remote add origin "https://lmntechgit:${PAT}@github.com/lmntechgit/gun-game.git"
git push -q -u origin main 2>&1 | tail -5
echo "push_exit=$?"
git log --oneline -1
