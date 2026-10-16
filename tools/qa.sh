#!/usr/bin/env bash
# Development loop helper: waits for the latest CI run on main, then fetches the QA results.
#   tools/qa.sh            → waits, fetches qa-results into ./qa-results, prints the summary
set -euo pipefail
cd "$(dirname "$0")/.."
repo=$(git remote get-url origin | sed -E 's#.*github.com[/:]([^/]+/[^/.]+)(\.git)?#\1#')
run=$(gh run list -R "$repo" --branch main --limit 1 --json databaseId --jq '.[0].databaseId')
echo "Watching run $run…"
gh run watch "$run" -R "$repo" --interval 30 > /dev/null 2>&1 || true
gh run view "$run" -R "$repo" --json jobs --jq '.jobs[] | "\(.name): \(.conclusion)"'
git fetch -q origin +qa-results:refs/remotes/origin/qa-results
rm -rf qa-results && mkdir qa-results
git archive origin/qa-results | tar -x -C qa-results
echo "QA for commit $(cat qa-results/commit.txt) (HEAD is $(git rev-parse HEAD))"
cat qa-results/summary.md
ls qa-results/screenshots 2>/dev/null || true
