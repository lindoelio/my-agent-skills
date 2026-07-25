# React Integration

React integration with Meteor via `react-meteor-data`.

## Setup

```bash
meteor npm install --save react react-dom
meteor add react-meteor-data
```

## Mounting

```tsx
import React from 'react';
import { render } from 'react-dom';
import { App } from '/imports/App';

Meteor.startup(() => {
  render(<App />, document.getElementById('react-target'));
});
```

## `useTracker` — Reactive Data Hook

```tsx
import { useTracker } from 'meteor/react-meteor-data';
import { TasksCollection } from '/imports/api/tasks/collection';

function TaskList() {
  const tasks = useTracker(() =>
    TasksCollection.find({}, { sort: { createdAt: -1 } }).fetch()
  );
  const user = useTracker(() => Meteor.user());

  return (
    <ul>
      {tasks.map(t => <li key={t._id}>{t.text}</li>)}
    </ul>
  );
}
```

### `useTracker` with async (Meteor 3)

`useTracker` expects synchronous functions. For async data, use the suspense variant from `react-meteor-data/suspense`:

```tsx
import { useTracker } from 'meteor/react-meteor-data/suspense';

function Profile() {
  const user = useTracker('user', () => Meteor.userAsync());
  // Suspense variant supports async functions — component suspends until resolved
}
```

### Suspense variant (Meteor 3.x)

```tsx
import { useTracker, useSubscribe } from 'meteor/react-meteor-data/suspense';
import { Suspense } from 'react';

function Tasks() { // this component will suspend
  useSubscribe('tasks');
  const { username } = useTracker('user', () => Meteor.userAsync());
  const tasks = useTracker('tasks', () =>
    TasksCollection.find({}, { sort: { createdAt: -1 } }).fetchAsync()
  );

  return tasks.map(t => <TaskItem key={t._id} task={t} />);
}

// Wrap in Suspense
function App() {
  return (
    <Suspense fallback={<Loading />}>
      <Tasks />
    </Suspense>
  );
}
```

## `useSubscribe` — Subscription Hook

```tsx
import { useSubscribe } from 'meteor/react-meteor-data';

function TaskList({ listId }) {
  const isLoading = useSubscribe('tasks.inList', listId);
  // isLoading is a function returning boolean

  const tasks = useTracker(() =>
    TasksCollection.find({ listId }).fetch()
  );

  if (isLoading()) return <Loading />;
  return tasks.map(t => <TaskItem key={t._id} task={t} />);
}
```

### With suspense

```tsx
import { useSubscribe } from 'meteor/react-meteor-data/suspense';

function TaskList({ listId }) {
  useSubscribe('tasks.inList', listId); // suspends until ready
  const tasks = useTracker(() => TasksCollection.find({ listId }).fetch());
  // no need for isLoading check — subscription is ready here
  return tasks.map(t => <TaskItem key={t._id} task={t} />);
}
```

## `useFind` — Cursor Hook

```tsx
import { useFind } from 'meteor/react-meteor-data';

function TaskList() {
  const tasks = useFind(() => TasksCollection.find({}, { sort: { createdAt: -1 } }));
  return tasks.map(t => <TaskItem key={t._id} task={t} />);
}
```

## Calling Methods

```tsx
import { Meteor } from 'meteor/meteor';

function AddTask() {
  const [text, setText] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!text.trim()) return;
    await Meteor.callAsync('tasks.insert', { text });
    setText('');
  };

  return (
    <form onSubmit={handleSubmit}>
      <input value={text} onChange={(e) => setText(e.target.value)} />
      <button type="submit">Add</button>
    </form>
  );
}
```

## Routing with `react-router`

```bash
meteor npm install --save react-router-dom
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

## React in Blaze (migration)

```bash
meteor add react-template-helper
```

```html
{{> React component=TaskList userId=_id}}
```

## Blaze in React (migration)

```bash
meteor add gadicc:blaze-react-component
```

```tsx
import Blaze from 'meteor/gadicc:blaze-react-component';

function App() {
  return <Blaze template="legacyTemplate" items={items} />;
}
```

## Fast Refresh

React Fast Refresh is enabled by default in Meteor when `hot-module-replacement` and `react-meteor-data` are installed. No configuration needed.

## TypeScript

```bash
meteor npm install --save-dev @types/react @types/react-dom
```

```tsx
import React, { FC } from 'react';
import { useTracker } from 'meteor/react-meteor-data';
import { Task } from '/imports/api/tasks/collection';

interface TaskListProps {
  listId: string;
}

export const TaskList: FC<TaskListProps> = ({ listId }) => {
  const tasks = useTracker<Task[]>(() =>
    TasksCollection.find({ listId }).fetch()
  );

  return <ul>{tasks.map(t => <li key={t._id}>{t.text}</li>)}</ul>;
};
```

## Component Libraries

Meteor is 100% npm-compatible. Any React library works unchanged:

```bash
meteor npm install @chakra-ui/react @emotion/react @emotion/styled framer-motion
```

## SSR with `server-render`

```bash
meteor add server-render
```

```tsx
import { onPageLoad } from 'meteor/server-render';
import { renderToPipeableStream } from 'react-dom/server';
import { App } from '/imports/App';

onPageLoad((sink) => {
  const stream = renderToPipeableStream(
    <App location={sink.request.url} />,
    {
      onShellReady() {
        sink.renderIntoElementById('react-target', stream);
      },
    }
  );
});
```
