(function(App) {

  'use strict';

  /**
   * Between the router and the controllers, there is the Dispatcher listening
   * for routing events. On such events, it loads the target controller,
   * creates an instance of it and calls the target action.
   * The action is actually a method of the controller.
   * The previously active controller is automatically disposed.
   */
  var Dispatcher = function() {
    this.initialize.apply(this, arguments);
  };

  _.extend(Dispatcher.prototype, {

    initialize: function() {
      this.router = new App.Router();
      this.router.on('route', this.runController);
    },

    /**
     * Facilitates mapping URLs to controller actions
     * based on a user-defined configuration file.
     * It is responsible for observing and acting upon URL changes.
     * @param  {String} routeName
     * @param  {Array} routeParams
     */
    runController: function(routeName, routeParams) {
      var routeSplited = routeName.split('#');
      var controllerName = routeSplited[0];
      var actionName = routeSplited[1];
      var params = (!!_.compact(routeParams).length) ? _.extend({id: routeParams[0]}, this.getParams(window.location.search)) : this.getParams(window.location.search);
      if (App.Controller[controllerName] &&
        App.Controller.hasOwnProperty(controllerName)) {
        var currentController = new App.Controller[controllerName]();
        // Checking if action exists
        if (currentController[actionName] &&
          typeof currentController[actionName] === 'function') {
          // Setting new params in model
          // this.updateParams(params);
          // Executing controller#action and passing url params
          currentController[actionName](params);
        } else {
          console.error('specified action doesn\'t exist');
        }
      } else {
        console.error('specified controller doesn\'t exist');
      }

    }

  });

  /**
   * App will be start when DOM is ready
   */
  function initApp() {
    new Dispatcher();
    // unbind all global events
    $(window).unbind();
    if (Backbone.History.started) {
      Backbone.history.stop();
    }

    // Start listening changes in routes
    Backbone.history.start({ pushState: true });
  }

  /*
   * As we will using turbolinks, we will listen to the turbolinks
   * load event and we will refresh the app each time the page loads.
   */
  document.addEventListener('turbolinks:load', initApp);

})(this.App);
