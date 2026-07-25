// imports/startup/client/index.js — Client startup module
// Register all API modules (for client-side collections/methods)
import '/imports/api/tasks';
// import '/imports/api/lists';
// import '/imports/api/users';

// Configure accounts
import './useraccounts-configuration';

// Set up routes
import './routes';