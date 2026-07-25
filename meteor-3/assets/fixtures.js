// imports/startup/server/fixtures.js — Database seeding
// Runs on server startup to populate initial data.

import { Meteor } from 'meteor/meteor';
// import { TasksCollection } from '/imports/api/tasks/collection';

Meteor.startup(async () => {
  // if ((await TasksCollection.find().countAsync()) === 0) {
  //   await TasksCollection.insertAsync({
  //     text: 'Welcome to Meteor 3!',
  //     createdAt: new Date(),
  //   });
  // }
});