#!/usr/bin/env bash
# scaffold-publication.sh — Append a publication to an existing module's publications file
# Usage: bash scripts/scaffold-publication.sh <entity> <publication-name> [--typescript]
# Example: bash scripts/scaffold-publication.sh tasks tasks.byOwner --typescript
set -euo pipefail

ENTITY=""
PUB_NAME=""
TYPESCRIPT=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --typescript) TYPESCRIPT=true; shift ;;
    *) if [ -z "$ENTITY" ]; then ENTITY="$1"; elif [ -z "$PUB_NAME" ]; then PUB_NAME="$1"; fi; shift ;;
  esac
done

if [ -z "$ENTITY" ] || [ -z "$PUB_NAME" ]; then
  echo "Usage: bash scripts/scaffold-publication.sh <entity> <publication-name> [--typescript]"
  echo "Example: bash scripts/scaffold-publication.sh tasks tasks.byOwner --typescript"
  exit 1
fi

if [ -f "tsconfig.json" ]; then TYPESCRIPT=true; fi

PascalName=$(echo "$ENTITY" | awk -F'-' '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1))substr($i,2); print}' OFS='')
PascalName=$(echo "$PascalName" | awk '{print toupper(substr($0,1,1))substr($0,2)}')
CollectionName="${PascalName}Collection"

if [ "$TYPESCRIPT" = true ]; then
  PUB_FILE="imports/api/${ENTITY}/publications.ts"
else
  PUB_FILE="imports/api/${ENTITY}/publications.js"
fi

if [ ! -f "$PUB_FILE" ]; then
  echo "Error: $PUB_FILE not found. Run scaffold-module.sh first."
  exit 1
fi

if grep -q "'${PUB_NAME}'" "$PUB_FILE"; then
  echo "Publication '${PUB_NAME}' already exists in $PUB_FILE"
  exit 0
fi

# Derive selector from publication name suffix
SUFFIX=$(echo "$PUB_NAME" | sed 's/.*\.//')

cat >> "$PUB_FILE" << EOF

Meteor.publish('${PUB_NAME}', async function (${SUFFIX}: string) {
  check(${SUFFIX}, String);
  if (!this.userId) return this.ready();
  return ${CollectionName}.find(
    { ${SUFFIX} },
    { projection: ${CollectionName}.publicFields }
  );
});
EOF

echo "Added publication '${PUB_NAME}' to $PUB_FILE"
echo ""
echo "Client subscribe: Meteor.subscribe('${PUB_NAME}', ${SUFFIX}Value);"
echo ""
echo "NOTE: The publication parameter and selector field are both derived from the"
echo "publication name suffix ('${SUFFIX}'). Verify the generated code matches your"
echo "actual field name and parameter semantics."