(function(App) {

  'use strict';

  App.View = App.View || {};

  App.View.NotificationsModal = Backbone.View.extend({

    el: '.c-notifications-modal',

    events: {
      'click .js-notification-modal-close' : '_onClickCloseModal'
    },

    initialize: function(options) {
      this.notifications = options.notifications;

      this._cache();
    },

    _cache: function () {
      this.title = this.$el.find('.c-notifications-modal__title .f-ff3-m-bold').html();
    },

    _onClickCloseModal: function (e) {
      this.$el.hide();

      this.notifications.buildNotification({
        msg: this.title,
        buttonText: 'LEARN MORE',
        buttonAction: this.showModal.bind(this)
      });
    },

    showModal: function () {
      this.$el.show();
    }
  });

})(this.App);
