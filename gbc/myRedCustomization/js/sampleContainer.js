/// FOURJS_START_COPYRIGHT(D,2016)
/// Property of Four Js*
/// (c) Copyright Four Js 2016, 2018. All Rights Reserved.
/// * Trademark of Four Js Development Tools Europe Ltd
///   in the United States and elsewhere
/// 
/// This file can be modified by licensees according to the
/// product manual.
/// FOURJS_END_COPYRIGHT

"use strict";

// Declare the dependency to inheritedWidget (here WidgetBase) module
modulum('containerSample', ['WidgetBase', 'WidgetFactory'],
  function(context, cls) {

    cls.containerSample = context.oo.Class(cls.WidgetBase, function($super) {
      return {
        __name: "containerSample"

        /* your custom code */
      };
    });
    /*
       Uncomment the 'cls.WidgetFactory.register' line below to register your custom widget
	   first parameter 'widgetType' is usually the name of the corresponding node in the AUI tree
	   second parameter 'widgetStyle' is optional and corresponds to the value of the STYLE attribute
       in your Genero form. For example:
         EDIT myedit = formonly.edt, STYLE='mystyle';
       third parameter is your custom widget constructor 
	   then you would replace 'widgetStyle' by 'mystyle'
    */
    //cls.WidgetFactory.registerBuilder('widgetType.widgetStyle', cls.containerSample);
});
