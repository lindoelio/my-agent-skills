// imports/startup/client/routes.js — Client routing (Flow Router)
// For React, use react-router-dom instead.

import { FlowRouter } from 'meteor/ostrio:flow-router-extra';
import { BlazeLayout } from 'meteor/kadira:blaze-layout';

// Import layouts and pages
// import '../../ui/layouts/App_body.html';
// import '../../ui/pages/Home_page.html';

FlowRouter.route('/', {
  name: 'App.home',
  action() {
    // BlazeLayout.render('App_body', { main: 'App_home' });
    console.log('Home route');
  },
});

// FlowRouter.notFound = {
//   action() {
//     BlazeLayout.render('App_body', { main: 'App_notFound' });
//   },
// };