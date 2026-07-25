# Routing

Client-side routing for Meteor apps. Recommended: `ostrio:flow-router-extra` (maintained fork of Flow Router).

## Setup

```bash
meteor add ostrio:flow-router-extra
meteor add kadira:blaze-layout  # for Blaze
```

## Defining Routes

```js
import { FlowRouter } from 'meteor/ostrio:flow-router-extra';
import { BlazeLayout } from 'meteor/kadira:blaze-layout';

FlowRouter.route('/lists/:_id', {
  name: 'Lists.show',
  action(params, queryParams) {
    BlazeLayout.render('App_body', { main: 'Lists_show_page' });
  },
});

FlowRouter.route('/', {
  name: 'index',
  waitOn() {
    return import('/imports/client/index.js'); // dynamic module loading
  },
  action() {
    BlazeLayout.render('App_body', { main: 'index' });
  },
});
```

## React with `react-router`

```bash
meteor npm install react-router-dom
```

```tsx
import { createBrowserRouter, RouterProvider } from 'react-router-dom';

const router = createBrowserRouter([
  { path: '/', element: <Home /> },
  { path: '/tasks/:listId', element: <TaskListPage /> },
]);

Meteor.startup(() => {
  render(<RouterProvider router={router} />, document.getElementById('react-target'));
});
```

## Route Parameters

```js
FlowRouter.route('/lists/:_id', {
  action(params) {
    console.log(params._id); // URL param
  },
});

FlowRouter.route('/search', {
  action(params, queryParams) {
    console.log(queryParams.q); // ?q=value
  },
});
```

## Reactive Route Access

```js
const routeName = FlowRouter.getRouteName();
const listId = FlowRouter.getParam('_id');
const query = FlowRouter.getQueryParam('sort');
```

## Navigation

```js
FlowRouter.go('Lists.show', { _id: listId });
FlowRouter.setParams({ _id: newListId });
FlowRouter.setQueryParams({ sort: 'desc' });
```

## Groups & Triggers

```js
const adminGroup = FlowRouter.group({
  prefix: '/admin',
  triggersEnter: [(context, redirect) => {
    if (!Roles.userIsInRole(Meteor.userId(), 'admin')) {
      redirect('/');
    }
  }],
});

adminGroup.route('/users', {
  action() { BlazeLayout.render('Admin_body', { main: 'Admin_users' }); },
});
```

## Auth Wrappers (Blaze)

```html
<template name="App_forceLoggedIn">
  {{#if currentUser}}
    {{> Template.contentBlock}}
  {{else}}
    Please log in to see this page.
  {{/if}}
</template>
```

```html
<template name="Lists_show_page">
  {{#App_forceLoggedIn}}
    {{> Lists_show}}
  {{/App_forceLoggedIn}}
</template>
```

## Dynamic Module Loading (Code Splitting)

```js
FlowRouter.route('/heavy', {
  name: 'heavy',
  waitOn() {
    return import('/imports/client/heavy-page.js');
  },
  action() {
    BlazeLayout.render('App_body', { main: 'heavy_page' });
  },
});
```

## Not Found

```js
FlowRouter.notFound = {
  action() {
    BlazeLayout.render('App_body', { main: 'App_notFound' });
  },
};
```

## Server-Side Routing

### REST with `WebApp.handlers` (Express 5)

```js
import { WebApp } from 'meteor/webapp';
import { Meteor } from 'meteor/meteor';

const app = WebApp.express();
app.use(express.json());

app.get('/api/tasks', Meteor.bindEnvironment(async (req, res) => {
  const tasks = await TasksCollection.find({}).fetchAsync();
  res.json(tasks);
}));

app.post('/api/tasks', Meteor.bindEnvironment(async (req, res) => {
  const { text } = req.body;
  const id = await TasksCollection.insertAsync({ text, createdAt: new Date() });
  res.status(201).json({ _id: id });
}));

WebApp.handlers.use('/api', app);
```

### `accounts-express` for authenticated routes (3.5+)

```js
app.get('/api/profile', Accounts.auth(), async (req, res) => {
  const user = await Meteor.userAsync();
  res.json(user);
});
```

## Storing Data in URLs

```js
const encoded = encodeURIComponent(EJSON.stringify(data));
FlowRouter.setQueryParams({ data: encoded });

// Read
const data = EJSON.parse(decodeURIComponent(FlowRouter.getQueryParam('data')));
```
