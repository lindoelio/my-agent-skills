#!/usr/bin/env bash
# scaffold-migration.sh — Generate a migration file
# Usage: bash scripts/scaffold-migration.sh <version> <description>
# Example: bash scripts/scaffold-migration.sh 2 add-index-to-tasks
set -euo pipefail

VERSION=""
DESCRIPTION=""

while [[ $# -gt 0 ]]; do
  case $1 in
    *) if [ -z "$VERSION" ]; then VERSION="$1"; elif [ -z "$DESCRIPTION" ]; then DESCRIPTION="$1"; fi; shift ;;
  esac
done

if [ -z "$VERSION" ] || [ -z "$DESCRIPTION" ]; then
  echo "Usage: bash scripts/scaffold-migration.sh <version> <description>"
  echo "Example: bash scripts/scaffold-migration.sh 2 add-index-to-tasks"
  exit 1
fi

DIR="imports/api/migrations"
mkdir -p "$DIR"

FILENAME="${VERSION}_${DESCRIPTION}.js"
FILE="${DIR}/${FILENAME}"

cat > "$FILE" << EOF
import { Migrations } from 'meteor/percolate:migrations';

Migrations.add({
  version: ${VERSION},
  name: '${DESCRIPTION}',
  async up() {
    // Forward migration
    // Example: await Collection.createIndexAsync({ field: 1 });
  },
  async down() {
    // Rollback
    // Example: await Collection.dropIndexAsync({ field: 1 });
  },
});
EOF

echo "Created $FILE"
echo ""
echo "Run migrations: Migrations.migrateTo('latest') in meteor shell or startup"