# Testing

Meteor testing with `meteortesting:mocha`.

## Setup

```bash
meteor add meteortesting:mocha
meteor npm install --save-dev chai @faker-js/faker
```

## Test Modes

```bash
# Unit/integration — only loads *.test[s].* / *.spec[s].* files
TEST_WATCH=1 meteor test --driver-package meteortesting:mocha

# Full-app — loads *.app-test[s].* / *.app-spec[s].* AND all app code
meteor test --full-app --driver-package meteortesting:mocha

# Run on separate port during dev
meteor test --driver-package meteortesting:mocha --port 3100

# CI — single run
meteor test --once --driver-package meteortesting:mocha
```

`Meteor.isTest` is `true` in test mode; `Meteor.isAppTest` in full-app mode.

## package.json scripts

```json
{
  "scripts": {
    "test": "meteor test --once --driver-package meteortesting:mocha",
    "test:watch": "TEST_WATCH=1 meteor test --driver-package meteortesting:mocha --port 3100",
    "test:app": "meteor test --full-app --once --driver-package meteortesting:mocha",
    "test:ci": "meteor test --once --driver-package meteortesting:mocha --port 3100"
  }
}
```

## Unit Tests — Methods

```js
// imports/api/tasks/tasks.tests.ts
import { Meteor } from 'meteor/meteor';
import { Random } from 'meteor/random';
import { assert } from 'chai';
import { TasksCollection } from './collection';

if (Meteor.isServer) {
  describe('tasks.methods', () => {
    const userId = Random.id();
    const context = { userId };

    beforeEach(async () => {
      await TasksCollection.removeAsync({});
    });

    it('can insert a task', async () => {
      const handler = Meteor.server.method_handlers['tasks.insert'];
      const result = await handler.apply(context, [{ text: 'Test task' }]);
      assert.isOk(result);
      const task = await TasksCollection.findOneAsync(result);
      assert.strictEqual(task.text, 'Test task');
      assert.strictEqual(task.owner, userId);
    });

    it('rejects insert without userId', async () => {
      const handler = Meteor.server.method_handlers['tasks.insert'];
      try {
        await handler.apply({}, [{ text: 'Test' }]);
        assert.fail('should have thrown');
      } catch (err) {
        assert.strictEqual(err.error, 'not-authorized');
      }
    });
  });
}
```

## Unit Tests — Publications

```js
import { Meteor } from 'meteor/meteor';
import { Random } from 'meteor/random';
import { assert } from 'chai';
import { PublicationCollector } from 'meteor/johanbrook:publication-collector';
import { TasksCollection } from './collection';

describe('tasks.publications', () => {
  const userId = Random.id();

  beforeEach(async () => {
    await TasksCollection.removeAsync({});
    await TasksCollection.insertAsync({ text: 'Task 1', owner: userId });
    await TasksCollection.insertAsync({ text: 'Task 2', owner: Random.id() });
  });

  it('publishes only own tasks', async () => {
    const collector = new PublicationCollector({ userId });
    const collections = await collector.collect('tasks.byOwner');
    assert.equal(collections.tasks.length, 1);
    assert.equal(collections.tasks[0].text, 'Task 1');
  });
});
```

## Factories

```bash
meteor npm install --save-dev dburles:factory @faker-js/faker
meteor add dburles:factory
```

```js
import { Factory } from 'meteor/dburles:factory';
import { faker } from '@faker-js/faker';
import { TasksCollection } from './collection';
import { ListsCollection } from '../lists/collection';

Factory.define('list', ListsCollection, {
  name: () => faker.lorem.words(3),
  userId: () => Random.id(),
});

Factory.define('task', TasksCollection, {
  listId: () => Factory.get('list'),
  text: () => faker.lorem.sentence(),
  completed: false,
  owner: () => Random.id(),
  createdAt: () => new Date(),
});

// Insert
const task = Factory.create('task');

// Build without insert
const task = Factory.build('task', { completed: true });
```

## Reset Database

```bash
meteor add xolvio:cleaner
```

```js
// Server
import { resetDatabase } from 'meteor/xolvio:cleaner';

beforeEach(async () => {
  await resetDatabase();
});

// Client
beforeEach((done) => {
  Meteor.call('xolvio:cleaner/resetDatabase', done);
});
```

## Stub Collections (Client)

```bash
meteor add hwillson:stub-collections
```

```js
import { StubCollections } from 'meteor/hwillson:stub-collections';
import { TasksCollection } from './collection';

beforeEach(() => StubCollections.add([TasksCollection]).stub());
afterEach(() => StubCollections.restore());
```

## Blaze Component Tests

```js
import { Blaze } from 'meteor/blaze';
import { Template } from 'meteor/templating';
import { Tracker } from 'meteor/tracker';

const withDiv = (callback) => {
  const el = document.createElement('div');
  document.body.appendChild(el);
  try { callback(el); } finally { document.body.removeChild(el); }
};

const withRenderedTemplate = (template, data, callback) => {
  withDiv((el) => {
    const view = Blaze.renderWithData(template, data, el);
    Tracker.flush();
    callback(el);
    Blaze.remove(view);
  });
};

describe('task_item', () => {
  it('renders task text', () => {
    withRenderedTemplate(Template.task_item, { text: 'My task' }, (el) => {
      assert.include(el.textContent, 'My task');
    });
  });
});
```

## Acceptance Tests — Cypress

```bash
meteor npm install --save-dev cypress
```

```js
// tests/cypress/integration/tasks.spec.js
describe('Tasks', () => {
  beforeEach(() => {
    cy.visit('http://localhost:3000');
  });

  it('adds a task', () => {
    cy.get('input[name=text]').type('My new task');
    cy.get('form').submit();
    cy.contains('My new task');
  });
});
```

## CI Pipeline

```yaml
# .github/workflows/test.yml
name: Test
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: meteorengine/setup-meteor@v1
        with:
          meteor-release: '3.5'
      - run: meteor npm install
      - run: meteor npm run test:ci
```

## Meteor 3 Async Test Tips

- All method/publication tests must `await` results.
- Use `async` test functions: `it('does X', async () => { ... })`.
- `Meteor.server.method_handlers['name']` — access method directly for testing.
- `Meteor.server.publish_handlers['name']` — access publication directly.
- Use `PublicationCollector` for publication tests.
- Call methods with `apply(context, [args])` to set `this.userId`.

## Test Mode Optimizations (Meteor 3.4+)

Use `Meteor.deferDev` to skip non-critical setup in test mode:

```js
Meteor.startup(async () => {
  if (Meteor.isTest || Meteor.isAppTest) return; // skip heavy setup
  await Meteor.deferDev(connectToExternalDB);
});
```

Rspack runs a single process in `meteor test --full-app` to reduce resource usage. HMR WebSocket is disabled in test modes to prevent console errors.

## `resolverType` for Testing

Use `resolverType: 'stub'` to keep isomorphic code in tests:

```js
const Greetings = new Mongo.Collection('greetUser', { resolverType: 'stub' });
await Greetings.insertAsync({ test: 1 });
// Data is available in Minimongo immediately
```
