#!/usr/bin/env bash
# scaffold-blaze-template.sh — Generate a Blaze template (html + js)
# Usage: bash scripts/scaffold-blaze-template.sh <template_name>
# Example: bash scripts/scaffold-blaze-template.sh task_item
set -euo pipefail

TEMPLATE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    *) TEMPLATE="$1"; shift ;;
  esac
done

if [ -z "$TEMPLATE" ]; then
  echo "Usage: bash scripts/scaffold-blaze-template.sh <template_name>"
  echo "Example: bash scripts/scaffold-blaze-template.sh task_item"
  exit 1
fi

# Determine target directory based on naming convention
# task_item -> imports/ui/tasks/task_item (if tasks module exists)
# Otherwise -> imports/ui/components/
if [ -d "imports/ui/$(echo "$TEMPLATE" | cut -d'_' -f1)" ]; then
  DIR="imports/ui/$(echo "$TEMPLATE" | cut -d'_' -f1)"
else
  DIR="imports/ui/components"
fi

mkdir -p "$DIR"

HTML_FILE="${DIR}/${TEMPLATE}.html"
JS_FILE="${DIR}/${TEMPLATE}.js"

cat > "$HTML_FILE" << EOF
<template name="${TEMPLATE}">
  <div class="${TEMPLATE}">
    {{! Your template content here }}
  </div>
</template>
EOF

cat > "$JS_FILE" << EOF
import { Template } from 'meteor/templating';
import { ReactiveDict } from 'meteor/reactive-dict';
import './${TEMPLATE}.html';

Template.${TEMPLATE}.onCreated(function () {
  this.state = new ReactiveDict();
});

Template.${TEMPLATE}.helpers({
  // data: () => Template.instance().data,
});

Template.${TEMPLATE}.events({
  // 'click .action'(event, instance) {
  //   Meteor.callAsync('action', { _id: this._id });
  // },
});
EOF

echo "Created:"
echo "  $HTML_FILE"
echo "  $JS_FILE"