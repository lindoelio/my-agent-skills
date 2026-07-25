#!/usr/bin/env bash
# scaffold-module.sh — Generate a complete API module (collection, methods, publications, schema, tests, index)
# Usage: bash scripts/scaffold-module.sh <entity-name> [--typescript] [--with-schema] [--with-tests]
# Example: bash scripts/scaffold-module.sh tasks --typescript --with-schema --with-tests
set -euo pipefail

ENTITY=""
TYPESCRIPT=false
WITH_SCHEMA=false
WITH_TESTS=false
PATH_OVERRIDE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --typescript) TYPESCRIPT=true; shift ;;
    --with-schema) WITH_SCHEMA=true; shift ;;
    --with-tests) WITH_TESTS=true; shift ;;
    --path) PATH_OVERRIDE="$2"; shift 2 ;;
    -*) echo "Unknown option: $1"; exit 1 ;;
    *) ENTITY="$1"; shift ;;
  esac
done

if [ -z "$ENTITY" ]; then
  echo "Usage: bash scripts/scaffold-module.sh <entity-name> [--typescript] [--with-schema] [--with-tests] [--path <dir>]"
  echo "Example: bash scripts/scaffold-module.sh tasks --typescript --with-schema --with-tests"
  exit 1
fi

# Detect TypeScript if tsconfig.json exists
if [ -f "tsconfig.json" ]; then
  TYPESCRIPT=true
fi

# Name transformations
PascalName=$(echo "$ENTITY" | awk -F'-' '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1))substr($i,2); print}' OFS='')
PascalName=$(echo "$PascalName" | awk '{print toupper(substr($0,1,1))substr($0,2)}')
camelName=$(echo "$PascalName" | awk '{print tolower(substr($0,1,1))substr($0,2)}')
CollectionName="${PascalName}Collection"
METHOD_NAMESPACE="${camelName}"

# Determine output directory
if [ -n "$PATH_OVERRIDE" ]; then
  BASE_DIR="${PATH_OVERRIDE}/${ENTITY}"
else
  BASE_DIR="imports/api/${ENTITY}"
fi

mkdir -p "$BASE_DIR"

if [ "$TYPESCRIPT" = true ]; then
  EXT="ts"
  # collection.ts
  cat > "$BASE_DIR/collection.ts" << EOF
import { Mongo } from 'meteor/mongo';

export type ${PascalName} = {
  _id?: string;
  createdAt: Date;
  updatedAt?: Date;
};

export const ${CollectionName} = new Mongo.Collection<${PascalName}, ${PascalName}>('${ENTITY}');

${CollectionName}.publicFields = {
  createdAt: 1,
  updatedAt: 1,
} as const;
EOF

  # schema.ts
  if [ "$WITH_SCHEMA" = true ]; then
    cat > "$BASE_DIR/schema.ts" << EOF
import SimpleSchema from 'simpl-schema';
import { ${CollectionName} } from './collection';

const ${PascalName}Schema = new SimpleSchema({
  createdAt: { type: Date, optional: true },
  updatedAt: { type: Date, optional: true },
});

${CollectionName}.attachSchema(${PascalName}Schema);

export { ${PascalName}Schema };
EOF
  fi

  # methods.ts
  cat > "$BASE_DIR/methods.ts" << EOF
import { Meteor } from 'meteor/meteor';
import { check } from 'meteor/check';
import { ${CollectionName} } from './collection';

Meteor.methods({
  async '${METHOD_NAMESPACE}.insert'(data: Partial<${PascalName}>) {
    if (!this.userId) throw new Meteor.Error('not-authorized', 'You must be logged in');
    return ${CollectionName}.insertAsync({
      ...data,
      createdAt: new Date(),
    } as ${PascalName});
  },

  async '${METHOD_NAMESPACE}.update'(_id: string, data: Partial<${PascalName}>) {
    check(_id, String);
    if (!this.userId) throw new Meteor.Error('not-authorized', 'You must be logged in');
    return ${CollectionName}.updateAsync(_id, {
      \$set: { ...data, updatedAt: new Date() },
    });
  },

  async '${METHOD_NAMESPACE}.remove'(_id: string) {
    check(_id, String);
    if (!this.userId) throw new Meteor.Error('not-authorized', 'You must be logged in');
    return ${CollectionName}.removeAsync(_id);
  },

  async '${METHOD_NAMESPACE}.findById'(_id: string) {
    check(_id, String);
    return ${CollectionName}.findOneAsync(_id);
  },
});
EOF

  # publications.ts
  cat > "$BASE_DIR/publications.ts" << EOF
import { Meteor } from 'meteor/meteor';
import { check } from 'meteor/check';
import { ${CollectionName} } from './collection';

Meteor.publish('${ENTITY}.all', async function () {
  if (!this.userId) return this.ready();
  return ${CollectionName}.find({}, { projection: ${CollectionName}.publicFields });
});

Meteor.publish('${ENTITY}.byId', async function (_id: string) {
  check(_id, String);
  if (!this.userId) return this.ready();
  return ${CollectionName}.find({ _id }, { projection: ${CollectionName}.publicFields });
});
EOF

  # index.ts
  cat > "$BASE_DIR/index.ts" << EOF
import './collection';
EOF
  [ "$WITH_SCHEMA" = true ] && echo "import './schema';" >> "$BASE_DIR/index.ts"
  cat >> "$BASE_DIR/index.ts" << EOF
import './methods';
import './publications';

export * from './collection';
EOF
  [ "$WITH_SCHEMA" = true ] && echo "export * from './schema';" >> "$BASE_DIR/index.ts"

  # tests
  if [ "$WITH_TESTS" = true ]; then
    cat > "$BASE_DIR/${ENTITY}.tests.ts" << EOF
import { Meteor } from 'meteor/meteor';
import { Random } from 'meteor/random';
import { assert } from 'chai';
import { ${CollectionName} } from './collection';

if (Meteor.isServer) {
  describe('${ENTITY}', () => {
    const userId = Random.id();
    const context = { userId };

    beforeEach(async () => {
      await ${CollectionName}.removeAsync({});
    });

    describe('methods', () => {
      it('can insert', async () => {
        const handler = Meteor.server.method_handlers['${METHOD_NAMESPACE}.insert'];
        const id = await handler.apply(context, [{ createdAt: new Date() }]);
        assert.isOk(id);
      });

      it('rejects without userId', async () => {
        const handler = Meteor.server.method_handlers['${METHOD_NAMESPACE}.insert'];
        try {
          await handler.apply({}, [{}]);
          assert.fail('should throw');
        } catch (err) {
          assert.strictEqual(err.error, 'not-authorized');
        }
      });

      it('can remove', async () => {
        const id = await ${CollectionName}.insertAsync({ createdAt: new Date() });
        const handler = Meteor.server.method_handlers['${METHOD_NAMESPACE}.remove'];
        await handler.apply(context, [id]);
        const count = await ${CollectionName}.find({}).countAsync();
        assert.equal(count, 0);
      });
    });

    describe('publications', () => {
      it('publishes all', async () => {
        await ${CollectionName}.insertAsync({ createdAt: new Date() });
        const handler = Meteor.server.publish_handlers['${ENTITY}.all'];
        // Use PublicationCollector for full testing
        assert.isOk(handler);
      });
    });
  });
}
EOF
  fi

else
  # JavaScript
  EXT="js"

  cat > "$BASE_DIR/collection.js" << EOF
import { Mongo } from 'meteor/mongo';

export const ${CollectionName} = new Mongo.Collection('${ENTITY}');

${CollectionName}.publicFields = {
  createdAt: 1,
  updatedAt: 1,
};
EOF

  if [ "$WITH_SCHEMA" = true ]; then
    cat > "$BASE_DIR/schema.js" << EOF
import SimpleSchema from 'simpl-schema';
import { ${CollectionName} } from './collection';

const ${PascalName}Schema = new SimpleSchema({
  createdAt: { type: Date, optional: true },
  updatedAt: { type: Date, optional: true },
});

${CollectionName}.attachSchema(${PascalName}Schema);

export { ${PascalName}Schema };
EOF
  fi

  cat > "$BASE_DIR/methods.js" << EOF
import { Meteor } from 'meteor/meteor';
import { check } from 'meteor/check';
import { ${CollectionName} } from './collection';

Meteor.methods({
  async '${METHOD_NAMESPACE}.insert'(data) {
    if (!this.userId) throw new Meteor.Error('not-authorized', 'You must be logged in');
    return ${CollectionName}.insertAsync({
      ...data,
      createdAt: new Date(),
    });
  },

  async '${METHOD_NAMESPACE}.update'(_id, data) {
    check(_id, String);
    if (!this.userId) throw new Meteor.Error('not-authorized', 'You must be logged in');
    return ${CollectionName}.updateAsync(_id, {
      \$set: { ...data, updatedAt: new Date() },
    });
  },

  async '${METHOD_NAMESPACE}.remove'(_id) {
    check(_id, String);
    if (!this.userId) throw new Meteor.Error('not-authorized', 'You must be logged in');
    return ${CollectionName}.removeAsync(_id);
  },

  async '${METHOD_NAMESPACE}.findById'(_id) {
    check(_id, String);
    return ${CollectionName}.findOneAsync(_id);
  },
});
EOF

  cat > "$BASE_DIR/publications.js" << EOF
import { Meteor } from 'meteor/meteor';
import { check } from 'meteor/check';
import { ${CollectionName} } from './collection';

Meteor.publish('${ENTITY}.all', async function () {
  if (!this.userId) return this.ready();
  return ${CollectionName}.find({}, { projection: ${CollectionName}.publicFields });
});

Meteor.publish('${ENTITY}.byId', async function (_id) {
  check(_id, String);
  if (!this.userId) return this.ready();
  return ${CollectionName}.find({ _id }, { projection: ${CollectionName}.publicFields });
});
EOF

  cat > "$BASE_DIR/index.js" << EOF
import './collection';
EOF
  [ "$WITH_SCHEMA" = true ] && echo "import './schema';" >> "$BASE_DIR/index.js"
  cat >> "$BASE_DIR/index.js" << EOF
import './methods';
import './publications';

export * from './collection';
EOF
  [ "$WITH_SCHEMA" = true ] && echo "export * from './schema';" >> "$BASE_DIR/index.js"

  if [ "$WITH_TESTS" = true ]; then
    cat > "$BASE_DIR/${ENTITY}.tests.js" << EOF
import { Meteor } from 'meteor/meteor';
import { Random } from 'meteor/random';
import { assert } from 'chai';
import { ${CollectionName} } from './collection';

if (Meteor.isServer) {
  describe('${ENTITY}', () => {
    const userId = Random.id();
    const context = { userId };

    beforeEach(async () => {
      await ${CollectionName}.removeAsync({});
    });

    describe('methods', () => {
      it('can insert', async () => {
        const handler = Meteor.server.method_handlers['${METHOD_NAMESPACE}.insert'];
        const id = await handler.apply(context, [{ createdAt: new Date() }]);
        assert.isOk(id);
      });

      it('rejects without userId', async () => {
        const handler = Meteor.server.method_handlers['${METHOD_NAMESPACE}.insert'];
        try {
          await handler.apply({}, [{}]);
          assert.fail('should throw');
        } catch (err) {
          assert.strictEqual(err.error, 'not-authorized');
        }
      });

      it('can remove', async () => {
        const id = await ${CollectionName}.insertAsync({ createdAt: new Date() });
        const handler = Meteor.server.method_handlers['${METHOD_NAMESPACE}.remove'];
        await handler.apply(context, [id]);
        const count = await ${CollectionName}.find({}).countAsync();
        assert.equal(count, 0);
      });
    });
  });
}
EOF
  fi
fi

echo "Created ${ENTITY} module in ${BASE_DIR}/"
ls -la "$BASE_DIR/"
echo ""
echo "Import this module in your server startup:"
echo "  import '/imports/api/${ENTITY}';"
echo ""
echo "Register publications in your client startup if needed."