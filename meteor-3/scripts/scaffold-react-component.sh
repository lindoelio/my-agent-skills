#!/usr/bin/env bash
# scaffold-react-component.sh — Generate a React component with useTracker + useSubscribe
# Usage: bash scripts/scaffold-react-component.sh <ComponentName> [--typescript]
# Example: bash scripts/scaffold-react-component.sh TaskList --typescript
set -euo pipefail

COMPONENT=""
TYPESCRIPT=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --typescript) TYPESCRIPT=true; shift ;;
    *) COMPONENT="$1"; shift ;;
  esac
done

if [ -z "$COMPONENT" ]; then
  echo "Usage: bash scripts/scaffold-react-component.sh <ComponentName> [--typescript]"
  echo "Example: bash scripts/scaffold-react-component.sh TaskList --typescript"
  exit 1
fi

if [ -f "tsconfig.json" ]; then TYPESCRIPT=true; fi

# Lowercase component name for CSS class / publication name
componentLower=$(echo "$COMPONENT" | awk '{print tolower($0)}')

mkdir -p imports/ui/components

if [ "$TYPESCRIPT" = true ]; then
  FILE="imports/ui/components/${COMPONENT}.tsx"
  cat > "$FILE" << EOF
import React from 'react';
import { useTracker, useSubscribe } from 'meteor/react-meteor-data';

export const ${COMPONENT} = () => {
  const isLoading = useSubscribe('${componentLower}.all');
  const data = useTracker(() => {
    // Replace with your collection
    // return Collection.find({}).fetch();
    return [];
  });

  if (isLoading()) {
    return (
      <div className="loading">
        <p>Loading...</p>
      </div>
    );
  }

  return (
    <div className="${componentLower}">
      {/* Your content here */}
      <h2>${COMPONENT}</h2>
      <pre>{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
};
EOF
else
  FILE="imports/ui/components/${COMPONENT}.jsx"
  cat > "$FILE" << EOF
import React from 'react';
import { useTracker, useSubscribe } from 'meteor/react-meteor-data';

export const ${COMPONENT} = () => {
  const isLoading = useSubscribe('${componentLower}.all');
  const data = useTracker(() => {
    // Replace with your collection
    // return Collection.find({}).fetch();
    return [];
  });

  if (isLoading()) {
    return (
      <div className="loading">
        <p>Loading...</p>
      </div>
    );
  }

  return (
    <div className="${componentLower}">
      {/* Your content here */}
      <h2>${COMPONENT}</h2>
      <pre>{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
};
EOF
fi

echo "Created $FILE"