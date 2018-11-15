/// FOURJS_START_COPYRIGHT(D,2015)
/// Property of Four Js*
/// (c) Copyright Four Js 2015, 2018. All Rights Reserved.
/// * Trademark of Four Js Development Tools Europe Ltd
///   in the United States and elsewhere
/// 
/// This file can be modified by licensees according to the
/// product manual.
/// FOURJS_END_COPYRIGHT

"use strict";

modulum('MyHeaderBarWidget', ['WidgetBase', 'WidgetFactory'],
  function(context, cls) {

    /**
     * @class MyHeaderBarWidget
     * @memberOf classes
     * @extends classes.WidgetBase
     */
    cls.MyHeaderBarWidget = context.oo.Class(cls.WidgetBase, function($super) {
      return /** @lends classes.MyHeaderBarWidget.prototype */ {
        __name: "MyHeaderBarWidget",
        /** @type {classes.ModelHelper} */
        _model: null,
        /** @type {number} */
        _appsCount: null,

        constructor: function() {
          $super.constructor.call(this);
          this._appsCount = 0;
          this._model = new cls.ModelHelper(this);
          this._model.addNewApplicationListener(this.onNewApplication.bind(this));
          this._model.addCloseApplicationListener(this.onCloseApplication.bind(this));
          this._model.addCurrentWindowChangeListener(this.onCurrentWindowChanged.bind(this));
        },

        onNewApplication: function(application) {
          ++this._appsCount;
          var elt = this.getElement().querySelector(".MyHeaderBarWidget-counter");
          elt.textContent = this._appsCount.toString();
        },

        onCloseApplication: function(application) {
          --this._appsCount;
          var elt = this.getElement().querySelector(".MyHeaderBarWidget-counter");
          elt.textContent = this._appsCount.toString();
        },

        onCurrentWindowChanged: function(windowNode) {
          var elt = this.getElement().querySelector(".MyHeaderBarWidget-title");
          if (windowNode) {
            elt.textContent = windowNode.attribute('text');
          } else {
            elt.textContent = "<NONE>";
          }
        }
      };
    });
  }
);
