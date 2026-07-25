#!/usr/bin/env bash
# check-async.sh — Scan for old sync APIs that need migration to Meteor 3 async
# Usage: bash scripts/check-async.sh [directory...]
# Example: bash scripts/check-async.sh imports/ server/
set -euo pipefail

DIRS=("$@")
if [ ${#DIRS[@]} -eq 0 ]; then
  DIRS=("imports/" "server/" "client/")
fi

echo "Scanning for sync APIs that need migration to Meteor 3 async..."
echo "Target directories: ${DIRS[*]}"
echo ""

FOUND=0

# Build list of files to scan
FILES=""
for DIR in "${DIRS[@]}"; do
  if [ -d "$DIR" ]; then
    FILES="${FILES} $(find "$DIR" -type f \( -name '*.js' -o -name '*.ts' -o -name '*.jsx' -o -name '*.tsx' \) 2>/dev/null)"
  fi
done

if [ -z "$FILES" ]; then
  echo "No files found to scan."
  exit 0
fi

# Sync API patterns to flag
# Each entry: "sync_search|async_counterpart|description"
# The async_counterpart is used to skip the pattern if the async variant is also on the line
SYNC_APIS=(
  ".findOne(|findOneAsync|findOne not async"
  ".insert(|insertAsync|insert not async"
  ".update(|updateAsync|update not async"
  ".upsert(|upsertAsync|upsert not async"
  ".remove(|removeAsync|remove not async"
  ".fetch()|fetchAsync|fetch not async"
  ".count()|countAsync|count not async"
  ".forEach(|forEachAsync|forEach not async"
  ".map(|mapAsync|map not async"
  ".observe(|observeAsync|observe not async"
  "Meteor.call(|callAsync|Meteor.call not async"
  "Meteor.apply(|applyAsync|Meteor.apply not async"
  "Meteor.wrapAsync(|wrapAsync removed"
  "Meteor.user()|userAsync|Meteor.user not async (server only)"
  "Promise.await(|Promise.await removed"
  "HTTP.call(|HTTP deprecated, use fetch"
  "HTTP.get(|HTTP deprecated, use fetch"
  "HTTP.post(|HTTP deprecated, use fetch"
  "HTTP.put(|HTTP deprecated, use fetch"
  "HTTP.del(|HTTP deprecated, use fetch"
  "Email.send(|sendAsync|Email.send removed, use sendAsync"
  "Assets.getText(|getTextAsync|getText removed, use getTextAsync"
  "Assets.getBinary(|getBinaryAsync|getBinary removed, use getBinaryAsync"
  "Accounts.setPassword(|setPasswordAsync|setPassword removed, use setPasswordAsync"
  "Accounts.addEmail(|addEmailAsync|addEmail removed, use addEmailAsync"
  "WebApp.connectHandlers|WebApp.handlers|use WebApp.handlers"
  "WebApp.rawConnectHandlers|WebApp.rawHandlers|use WebApp.rawHandlers"
  "WebApp.connectApp|WebApp.expressApp|use WebApp.expressApp"
)

for file in $FILES; do
  while IFS=: read -r line_num line_content; do
    [ -z "$line_num" ] && continue

    # Skip comments
    trimmed=$(echo "$line_content" | sed 's/^[[:space:]]*//')
    case "$trimmed" in
      \#*|//*) continue ;;
    esac

    # Check each sync pattern individually against the line
    for entry in "${SYNC_APIS[@]}"; do
      search="${entry%%|*}"
      rest="${entry#*|}"
      async_variant="${rest%%|*}"
      desc="${rest#*|}"

      # Skip if the async counterpart is also on this line
      if [ -n "$async_variant" ] && echo "$line_content" | grep -qF "$async_variant"; then
        continue
      fi

      if echo "$line_content" | grep -qF "$search"; then
        printf "  %s:%s: %s  [%s]\n" "$file" "$line_num" "$(echo "$line_content" | sed 's/^[[:space:]]*//')" "$desc"
        FOUND=$((FOUND + 1))
        break
      fi
    done
  done < <(grep -n '.' "$file" 2>/dev/null)
done

echo ""
if [ "$FOUND" -gt 0 ]; then
  echo "Found ${FOUND} lines that may need migration to async APIs."
  echo ""
  echo "See: references/async-api-map.md for the complete mapping."
  echo "Or use the codemod: npx jscodeshift -t https://raw.githubusercontent.com/minhna/meteor-async-migration/main/transform.ts <files>"
else
  echo "No sync APIs found. Code looks Meteor 3-ready!"
fi

exit 0