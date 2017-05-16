(function(App) {

  'use strict';

  App.View = App.View || {};

  App.View.FormVerticalNav = Backbone.View.extend({

    el: '.c-vertical-nav',

    events: {
      'click .js-form-block-anchor' : '_onClickGoToBlockForm'
    },

    options: {
      isFixed: false,
      selectedClass: "-selected",
      fixedClass: "-fixed"
    },

    initialize: function() {
      this._cache();

      this.scrollHandler = new App.Helper.ScrollHandler();
      this._loadStickyEvent();
    },

    _cache: function() {
      this.forms = $('.c-form');
      this.offsetTop = this.$el.offset().top;
    },

    _onClickGoToBlockForm: function (e) {
      var target = $(e.currentTarget);

      this.scrollHandler.scrollTo($('[data-block-key="' + target.data('block-belongs') + '"]'));
      $('.js-form-block-anchor.' + this.options.selectedClass).removeClass(this.options.selectedClass);
      target.addClass(this.options.selectedClass);
    },

    _loadStickyEvent: function () {
      $(window).scroll(function () {
        var scrollTop = $(window).scrollTop();

        if(!this.options.isFixed && scrollTop >= this.offsetTop) {
          this.$el.addClass(this.options.fixedClass);
          this.options.isFixed = true;
        } else if(this.options.isFixed && scrollTop < this.offsetTop) {
          this.$el.removeClass(this.options.fixedClass);
          this.options.isFixed = false;
        }

        _.each(this.forms, function(item) {
          var form = $(item);
          var offset = form.offset();
          var scrollPositionTop = offset.top;
          var scrollPositionBottom = scrollPositionTop + form.height();

          if (scrollTop >= scrollPositionTop && scrollTop <= scrollPositionBottom) {
            $('.js-form-block-anchor.' + this.options.selectedClass).removeClass(this.options.selectedClass);
            $('.js-form-block-anchor[data-block-belongs="' + form.data('block-key') + '"]').addClass(this.options.selectedClass);
          }
        }.bind(this));
      }.bind(this));
    },
  });

})(this.App);
