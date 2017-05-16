(function(App) {

  'use strict';

  App.Helper = App.Helper || {};

  App.Helper.ScrollHandler = Backbone.View.extend({

    options: {
      animateDelay: 500
    },

    scrollTo: function(element, isAnimated) {
      if(typeof isAnimated === "undefined") {
        isAnimated = true;
      }
      var offsetTop = this._getElementTopOffset(element);

      if(isAnimated){
        this._animatedScroll(offsetTop);
      } else {
        this._unanimatedScroll(offsetTop);
      }
    },

    _getElementTopOffset: function(element) {
      return element.offset().top;
    },

    _animatedScroll: function(offsetTop) {
      $('html, body').animate({
        scrollTop: offsetTop
      }, this.options.animateDelay);
    },

    _unanimatedScroll: function(offsetTop) {
      $('html, body').scrollTop(offsetTop);
    },

  });

})(this.App);
