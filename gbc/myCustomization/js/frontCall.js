"use strict";

modulum('FrontCallService.modules.mymodule', ['FrontCallService'],
	/**
	 * @param {gbc} context
	 * @param {classes} cls
	 */
	function(context, cls) {
		context.FrontCallService.modules.mymodule = {

			setTextById: function (id,value) {
				if (id === undefined || id.length === 0) {
					return ["No ID!"];
				}

				var elt = document.getElementById(id);
				if (value === undefined || value.length === 0) {
					elt.textContent = "";
				} else {
					elt.textContent = value;
				}

				return ["Okay"];
			},

		};
	}
);
