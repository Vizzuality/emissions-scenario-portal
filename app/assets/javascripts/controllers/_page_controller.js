(function(App) {

  'use strict';

  /**
   * Backbone way to create a Class
   * @param {Object} options
   */
  var Controller = function(options) {
    _.extend(this, options);
    this._instanceCommonViews();
    this.initialize.apply(this, arguments);
  };

  _.extend(Controller.prototype, Backbone.Events, {});

  Controller.extend = Backbone.Router.extend;

  /**
   * Page Controller Class
   */
  App.Controller = App.Controller || {};

  App.Controller.Page = Controller.extend({

    initialize: function() {
      new App.View.FormItem();
      new App.View.Tooltips();

      this.notifications = new App.View.Notifications();
      new App.View.NotificationsModal({
        notifications: this.notifications
      });
    },

    /**
     * Instance common and global view here
     * @return {[type]} [description]
     */
    _instanceCommonViews: function() {}

  });


})(this.App);
