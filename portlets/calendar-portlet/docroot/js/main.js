function manageEventDetailDisplay(instance) {
	document.getElementById(instance.get('portletNamespace') + 'calendar-portlet-column-details').style.display = 'block';
	document.getElementById(instance.get('portletNamespace') + 'calendar-portlet-column-details').className = '';
	
	document.getElementById(instance.get('portletNamespace') + 'calendar-portlet-column-details').style.width='25%';

	var optionsVisible = document.getElementById(instance.get('portletNamespace') + 'columnToggler').innerHTML.indexOf('icon-caret-right');
	if (optionsVisible == -1) {
		document.getElementById(instance.get('portletNamespace') + 'columnGrid').style.width = '47%';
	} else {
		document.getElementById(instance.get('portletNamespace') + 'columnGrid').style.width = '70%';
	}
}

function manageEventDetailHide(instance) {
	document.getElementById(instance.get('portletNamespace') + 'calendar-portlet-column-details').style.display = 'none';
	document.getElementById(instance.get('portletNamespace') + 'calendar-portlet-column-details').className = 'hide';
	
	var optionsVisible = document.getElementById(instance.get('portletNamespace') + 'columnToggler').innerHTML.indexOf('icon-caret-right');
	
	if (optionsVisible == -1) {
		document.getElementById(instance.get('portletNamespace') + 'columnGrid').style.width = '74%';
	} else {
		document.getElementById(instance.get('portletNamespace') + 'columnGrid').style.width = '95%';
	}
}