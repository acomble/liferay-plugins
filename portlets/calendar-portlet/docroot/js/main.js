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

function manageEventAttendAnswers(portletNamespace, status) {
	// Reinitialize buttons
    document.getElementById(portletNamespace + 'accept').disabled = false;
    document.getElementById(portletNamespace + 'accept').className = 'btn btn-orange';
    document.getElementById(portletNamespace + 'maybe').disabled = false;
    document.getElementById(portletNamespace + 'maybe').className = 'btn btn-orange';
    if (status == 0) {
    	// user has accepted the invitation
    	document.getElementById(portletNamespace + 'accept').disabled = true;
	    document.getElementById(portletNamespace + 'accept').className = 'btn btn-orange disabled';
    } else if (status == 9) {
    	// user has answered maybe
    	document.getElementById(portletNamespace + 'maybe').disabled = true;
	    document.getElementById(portletNamespace + 'maybe').className = 'btn btn-orange disabled';
    } else if (status == 4) {
    	// user has declined the invitation
    	// the buttons are not displayed
    }
}

function manageEventDetailDisplay(portletNamespace, activeView) {
	document.getElementById(portletNamespace + 'calendar-portlet-column-details').style.display = 'block';
	document.getElementById(portletNamespace + 'calendar-portlet-column-details').className = '';
	
	var optionsVisible = document.getElementById(portletNamespace + 'columnToggler').innerHTML.indexOf('icon-caret-right');
	
	if (activeView == "scheduler-view-day") {
		if (optionsVisible == -1) {
			document.getElementById(portletNamespace + 'calendar-portlet-column-details').style.width='25%';
			document.getElementById(portletNamespace + 'columnGrid').style.width = '47%';
		} else {
			document.getElementById(portletNamespace + 'calendar-portlet-column-details').style.width='47%';
			document.getElementById(portletNamespace + 'columnGrid').style.width = '47%';
		}
	} else {
		if (optionsVisible == -1) {
			document.getElementById(portletNamespace + 'columnGrid').style.width = '47%';
		} else {
			document.getElementById(portletNamespace + 'columnGrid').style.width = '70%';
		}
		document.getElementById(portletNamespace + 'calendar-portlet-column-details').style.width='25%';
	}
}