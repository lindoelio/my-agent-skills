# Blaze Integration

Blaze is Meteor's reactive rendering engine. Community-maintained (blazejs.org). Still fully supported in Meteor 3.

## Setup

```bash
meteor create myapp --blaze
# or add to existing app:
meteor add blaze-html-templates jquery tracker reactive-var
```

## Templates

```html
<!-- task_item.html -->
<template name="task_item">
  <li class="{{#if this.completed}}checked{{/if}}">
    <button class="delete">×</button>
    <input type="checkbox" checked="{{this.completed}}" />
    <span>{{this.text}}</span>
  </li>
</template>
```

```js
// task_item.js
import { Template } from 'meteor/templating';
import { TasksCollection } from '/imports/api/tasks/collection';

Template.task_item.events({
  'click .toggle'(event, instance) {
    Meteor.callAsync('tasks.toggleComplete', { taskId: this._id });
  },
  'click .delete'(event, instance) {
    Meteor.callAsync('tasks.remove', { taskId: this._id });
  },
});
```

## Helpers

```js
Template.task_list.helpers({
  tasks() {
    return TasksCollection.find(
      { listId: this._id },
      { sort: { createdAt: -1 } }
    );
  },
  incompleteCount() {
    return TasksCollection.find({ listId: this._id, completed: false }).count();
  },
  isOwner() {
    return this.owner === Meteor.userId();
  },
});
```

## Template Instance State

```js
Template.task_list.onCreated(function () {
  this.state = new ReactiveDict();
  this.state.set('hideCompleted', false);
  this.subscribe('tasks.inList', this.data.listId);
});

Template.task_list.helpers({
  tasks() {
    const hideCompleted = Template.instance().state.get('hideCompleted');
    const filter = hideCompleted ? { completed: { $ne: true } } : {};
    return TasksCollection.find(filter, { sort: { createdAt: -1 } });
  },
});

Template.task_list.events({
  'change .hide-completed input'(event, instance) {
    instance.state.set('hideCompleted', event.target.checked);
  },
});
```

## Lifecycle Callbacks

| Callback | When |
|----------|------|
| `onCreated(fn)` | Template instance created (before first render) |
| `onRendered(fn)` | DOM inserted |
| `onDestroyed(fn)` | Template instance destroyed |

```js
Template.chart.onCreated(function () {
  this.autorun(() => {
    this.subscribe('chartData', this.data.chartId);
  });
});

Template.chart.onRendered(function () {
  const ctx = this.$('canvas')[0].getContext('2d');
  this.chart = new Chart(ctx, { type: 'bar', data: {} });
});

Template.chart.onDestroyed(function () {
  this.chart?.destroy();
});
```

## Subscriptions

```js
// In onCreated
Template.TaskList.onCreated(function () {
  this.subscribe('tasks.byOwner');
});

// Reactive readiness
Template.TaskList.helpers({
  isLoading() {
    return !this.subscriptionsReady();
  },
});
```

## Spacebars Syntax

| Syntax | Purpose |
|--------|---------|
| `{{ value }}` | Insert (escaped) |
| `{{{ html }}}` | Insert (unescaped — XSS risk!) |
| `{{#if cond}}...{{/if}}` | Conditional |
| `{{#if cond}}...{{else}}...{{/if}}` | If/else |
| `{{#each items}}...{{/each}}` | Loop |
| `{{#with obj}}...{{/with}}` | Set data context |
| `{{> TemplateName data}}` | Include template |
| `{{#TemplateContentBlock}}...{{/TemplateContentBlock}}` | Block helper |
| `{{> Template.contentBlock}}` | Render content block |
| `../parentValue` | Parent data context |

## Async Helpers (Blaze 2.7+ / Blaze 3)

Blaze supports async template helpers with pending/rejected/resolved states:

```handlebars
{{#let name=getNameAsync}}
  {{#if @pending 'name'}}
    Loading...
  {{/if}}
  {{#if @rejected 'name'}}
    Error!
  {{/if}}
  {{#if @resolved 'name'}}
    Hello, {{name}}!
  {{/if}}
{{/let}}
```

```js
Template.profile.helpers({
  getNameAsync() {
    return Meteor.callAsync('getName');
  },
});
```

### Async lists

```handlebars
{{#let users=getUsersAsync}}
  {{#if @pending 'users'}}
    Loading...
  {{/if}}
  {{#if @resolved 'users'}}
    {{#each user in users}}
      {{user.name}}
    {{/each}}
  {{/if}}
{{/let}}
```

### Async `if`/`unless`

```handlebars
{{#if isOkAsync}}
  Resolved and truthy.
{{else}}
  Resolved and falsy.
{{/if}}
```

## Blaze in Meteor 3 — Async Gotchas

- Tracker remains synchronous — reactive cursors (`Collection.find()`) still work in helpers without `fetchAsync`.
- Use `Collection.find().fetch()` (sync) in helpers for reactivity on the client.
- Use `await Meteor.callAsync(...)` only in event handlers, not in helpers (helpers are synchronous).
- For async data in helpers, use the `@pending`/`@resolved`/`@rejected` pattern.

## Render / Remove Programmatically

```js
import { Blaze } from 'meteor/blaze';

const view = Blaze.renderWithData(Template.taskItem, taskData, document.body);
Blaze.remove(view);
```

## Naming Conventions

- Templates named by path with underscores: `Lists_show`, `Lists_show_page`
- Co-locate files: `show.html`, `show.js`, `show.less`
- Page components: `*_page` (smart components that subscribe and pass data)
- Reusable components: no `_page` suffix
