#!/usr/bin/env bash
# Rails Wars instructor dashboard: latest grade per learner repo.
#
# Usage:
#   grader/status.sh owner/repo [owner/repo ...]
#   grader/status.sh -f repos.txt          # one owner/repo per line, # comments ok
#
# Needs the gh CLI, authenticated (gh auth login) with read access to the repos.
set -euo pipefail

repos=()
if [[ "${1:-}" == "-f" ]]; then
  [[ -f "${2:-}" ]] || { echo "usage: $0 -f repos.txt" >&2; exit 2; }
  while IFS= read -r line; do
    line="${line%%#*}"; line="$(echo "$line" | xargs)"
    [[ -n "$line" ]] && repos+=("$line")
  done < "$2"
else
  repos=("$@")
fi
[[ ${#repos[@]} -gt 0 ]] || { echo "usage: $0 owner/repo [owner/repo ...] | -f repos.txt" >&2; exit 2; }

printf "%-45s %-12s %s\n" "REPO" "GRADE" "WHEN"
for repo in "${repos[@]}"; do
  json=$(gh run list -R "$repo" --workflow grade -L 1 \
           --json conclusion,updatedAt -q '.[0] // empty' 2>/dev/null || true)
  if [[ -z "$json" ]]; then
    printf "%-45s %-12s %s\n" "$repo" "no runs" "-"
    continue
  fi
  conclusion=$(echo "$json" | grep -o '"conclusion":"[^"]*"' | cut -d'"' -f4)
  updated=$(echo "$json" | grep -o '"updatedAt":"[^"]*"' | cut -d'"' -f4)
  case "$conclusion" in
    success) grade="green" ;;
    failure) grade="RED" ;;
    *)       grade="${conclusion:-running}" ;;
  esac
  printf "%-45s %-12s %s\n" "$repo" "$grade" "$updated"
done
