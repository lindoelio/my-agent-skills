// imports/startup/server/index.js — Server startup module
// Register all API modules (collections, methods, publications)
import '/imports/api/tasks';
// import '/imports/api/lists';
// import '/imports/api/users';

// Configure accounts
import './useraccounts-configuration';

// Seed database
import './fixtures';

// Set up indexes
Meteor.startup(async () => {
  // Create indexes here
  // await TasksCollection.createIndexAsync({ owner: 1, createdAt: -1 });
});