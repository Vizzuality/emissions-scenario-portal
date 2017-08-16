(function(App) {

  'use strict';

  App.View = App.View || {};

  App.View.Notifications = Backbone.View.extend({

    el: '.c-notifications-list',

    events: {
      'click .js-notification' : '_onClickHideNotification',
      'click .js-upload-errors' : '_onClickUploadErrors'
    },

    buildNotification: function (data) {
      $('<li/>', {
        html: '<div class="c-notification -red -show-animation js-notification"><svg class="icon"><use xlink:href="#icon-alert"></use></svg><div class="f-ff1-s">' + data.msg + '<span class="c-notification__button f-ff1-m-bold">' + data.buttonText + '</span></div></div>'
      }).on('click', function (e) {
        if ($(e.target).hasClass('c-notification__button')) {
          data.buttonAction();
        }
      }).appendTo(this.$el);
    },

    _onClickHideNotification: function (e) {
      var target = $(e.currentTarget);
      var hideNotification = target.clone()
        .removeClass('-show-animation')
        .addClass('-hide-animation');

      target.before(hideNotification).remove();
    },

    _onClickUploadErrors: function (e) {
      var target = $(e.currentTarget);
      var a = document.body.appendChild(
        document.createElement('a')
      );
      a.download = 'upload_errors.csv';
      a.href='data:text/csv;charset=utf-8,' +
        escape(target.prev('.c-upload-errors-list').text());
      a.click();
    }
  });

})(this.App);
