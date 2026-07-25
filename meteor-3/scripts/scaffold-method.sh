#!/usr/bin/env bash
# scaffold-method.sh — Append a single async method to an existing module's methods file
# Usage: bash scripts/scaffold-method.sh <entity> <action> [--typescript]
# Example: bash scripts/scaffold-method.sh tasks archive --typescript
set -euo pipefail

ENTITY=""
ACTION=""
TYPESCRIPT=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --typescript) TYPESCRIPT=true; shift ;;
    *) if [ -z "$ENTITY" ]; then ENTITY="$1"; elif [ -z "$ACTION" ]; then ACTION="$1"; fi; shift ;;
  esac
done

if [ -z "$ENTITY" ] || [ -z "$ACTION" ]; then
  echo "Usage: bash scripts/scaffold-method.sh <entity> <action> [--typescript]"
  echo "Example: bash scripts/scaffold-method.sh tasks archive --typescript"
  exit 1
fi

if [ -f "tsconfig.json" ]; then TYPESCRIPT=true; fi

PascalName=$(echo "$ENTITY" | awk -F'-' '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1))substr($i,2); print}' OFS='')
PascalName=$(echo "$PascalName" | awk '{print toupper(substr($0,1,1))substr($0,2)}')
camelName=$(echo "$PascalName" | awk '{print tolower(substr($0,1,1))substr($0,2)}')
CollectionName="${PascalName}Collection"
METHOD_NAME="${camelName}.${ACTION}"

if [ "$TYPESCRIPT" = true ]; then
  METHODS_FILE="imports/api/${ENTITY}/methods.ts"
else
  METHODS_FILE="imports/api/${ENTITY}/methods.js"
fi

if [ ! -f "$METHODS_FILE" ]; then
  echo "Error: $METHODS_FILE not found. Run scaffold-module.sh first."
  exit 1
fi

# Check if method already exists
if grep -q "'${METHOD_NAME}'" "$METHODS_FILE"; then
  echo "Method '${METHOD_NAME}' already exists in $METHODS_FILE"
  exit 0
fi

# Append before the closing }); — we need to insert before the last line
# Use sed to remove the last line, append method, re-add closing
TMP=$(mktemp)
sed '$d' "$METHODS_FILE" > "$TMP"

if [ "$TYPESCRIPT" = true ]; then
  cat >> "$TMP" << EOF
  async '${METHOD_NAME}'(_id: string) {
    check(_id, String);
    if (!this.userId) throw new Meteor.Error('not-authorized', 'You must be logged in');
    return ${CollectionName}.updateAsync(_id, {
      \$set: { ${ACTION}At: new Date() },
    });
  },
});
EOF
else
  cat >> "$TMP" << EOF
  async '${METHOD_NAME}'(_id) {
    check(_id, String);
    if (!this.userId) throw new Meteor.Error('not-authorized', 'You must be logged in');
    return ${CollectionName}.updateAsync(_id, {
      \$set: { ${ACTION}At: new Date() },
    });
  },
});
EOF
fi

mv "$TMP" "$METHODS_FILE"
echo "Added method '${METHOD_NAME}' to $METHODS_FILE"
echo ""
echo "Client call: await Meteor.callAsync('${METHOD_NAME}', taskId);"