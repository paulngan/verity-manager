	//
	//  In my case I want to load them onload, this is how you do it!
	// 
	Event.observe(window, 'load', loadAccordions, false);

	//
	//	Set up all accordions
	//
	function loadAccordions() {
		var topAccordion = new accordion('horizontal_container', {
			classNames : {
				toggle : 'horizontal_accordion_toggle',
				toggleActive : 'horizontal_accordion_toggle_active',
				content : 'horizontal_accordion_content'
			},
			defaultSize : {
				width : 525
			},
			direction : 'horizontal'
		});

		var bottomAccordion = new accordion('vertical_container');

		var nestedVerticalAccordion = new accordion('vertical_nested_container', {
		  classNames : {
				toggle : 'vertical_accordion_toggle',
				toggleActive : 'vertical_accordion_toggle_active',
				content : 'vertical_accordion_content'
			}
		});

		// Open first one
		bottomAccordion.activate($$('#vertical_container .accordion_toggle')[0]);

		// Open second one
		topAccordion.activate($$('#horizontal_container .horizontal_accordion_toggle')[2]);
	}
