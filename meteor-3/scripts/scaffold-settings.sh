#!/usr/bin/env bash
# scaffold-settings.sh — Generate settings.json files for dev and prod
# Usage: bash scripts/scaffold-settings.sh
set -euo pipefail

mkdir -p settings

# Development settings
cat > "settings/development.json" << EOF
{
  "public": {
    "appName": "My App (Development)",
    "env": "development"
  },
  "packages": {
    "mongo": {
      "options": {}
    }
  }
}
EOF

# Production settings template
cat > "settings/production.json" << EOF
{
  "public": {
    "appName": "My App",
    "env": "production"
  },
  "packages": {
    "mongo": {
      "options": {
        "tls": true
      }
    }
  }
}
EOF

# Local settings (gitignored, for secrets)
if [ ! -f "settings/local.json" ]; then
  cat > "settings/local.json" << EOF
{
  "public": {},
  "facebook": {
    "appId": "YOUR_APP_ID",
    "secret": "YOUR_SECRET"
  },
  "google": {
    "clientId": "YOUR_CLIENT_ID",
    "secret": "YOUR_SECRET"
  }
}
EOF
fi

# Add settings/local.json to .gitignore if not already there
if [ -f ".gitignore" ]; then
  if ! grep -q "settings/local.json" ".gitignore"; then
    echo "" >> .gitignore
    echo "# Local settings (secrets)" >> .gitignore
    echo "settings/local.json" >> .gitignore
  fi
fi

echo "Created:"
echo "  settings/development.json"
echo "  settings/production.json"
echo "  settings/local.json (add to .gitignore — secrets!)"
echo ""
echo "Run with: meteor --settings settings/development.json"
echo "Deploy with: meteor deploy myapp.com --settings settings/production.json"
echo ""
echo "Meteor 3.5 tips:"
echo "  - Change streams are the default reactivity (MongoDB 6+ required)"
echo "  - Revert to oplog: set packages.mongo.reactivity to [\"oplog\", \"polling\"]"
echo "  - Enable modern build stack: add \"modern\": true to package.json meteor config"
echo "  - Enable Rspack: meteor add rspack"