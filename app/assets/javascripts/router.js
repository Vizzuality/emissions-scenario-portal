(function(App) {

  'use strict';

  App.Router = Backbone.Router.extend({

    /**
     * Inspired by Rails, we have a routes file that specifies these routes
     * and any additional route parameters.
     * @type {Object}
     */
    routes: {
      '': 'Models#index',
      'models/:id': 'Models#show',
      'models/:id/edit': 'Models#edit',
      'models/:modelId/scenarios': 'Scenarios#index',
      'models/:modelId/scenarios/:id': 'Scenarios#show',
      'models/:modelId/scenarios/:id/edit': 'Scenarios#edit',
      'indicators': 'Indicators#index',
      'indicators/:id/edit': 'Indicators#edit',
      'teams': 'Teams#index',
      '*notFound': 'Error#index'
    },

    initialize: function() {
      // We are going to save params in model
      this.params = new (Backbone.Model.extend());
      // Listening events
      this.params.on('change', _.bind(this.updateUrl, this));
    },

    /**
     * Get URL params
     * @return {Object}
     */
    getParams: function(routeParams) {
      return this._unserializeParams(routeParams);
    },

    /**
     * Change URL with current params
     */
    updateUrl: function() {
      var url = location.pathname.slice(1) + this._serializeParams();
      this.navigate(url, { trigger: false });
    },

    /**
     * Transform URL string params to object
     * @param  {String} routeParams
     * @return {Object}
     * @example https://medialize.github.io/URI.js/docs.html
     */
    _unserializeParams: function(routeParams) {
      var params = {};
      if (typeof routeParams === 'string' && routeParams.length) {
        var uri = new URI('?' + routeParams);
        params = uri.search(true);
      }
      return params;
    },

    /**
     * Transform object params to URL string
     * @return {String}
     * @example https://medialize.github.io/URI.js/docs.html
     */
    _serializeParams: function() {
      var uri = new URI();
      uri.search(this.params.attributes);
      return uri.search();
    }

  });

})(this.App);
