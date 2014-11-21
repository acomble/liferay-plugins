<%--
/**
 * Copyright (c) 2000-present Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
--%>

<%@ include file="/init.jsp" %>

<%
List<Calendar> groupCalendars = null;
if (groupCalendarResource != null) {
	groupCalendars = CalendarServiceUtil.search(themeDisplay.getCompanyId(), null, new long[] {groupCalendarResource.getCalendarResourceId()}, null, true, QueryUtil.ALL_POS, QueryUtil.ALL_POS, (OrderByComparator)null);
}

String calendarIds = "";
for (Calendar c : groupCalendars) {
	calendarIds += "," + c.getCalendarId();
}
%>


<portlet:resourceURL id="serveCalendarBookingsAsset" var="url1">
	<portlet:param name="portletId" value="1_WAR_calendarportlet" />
	<portlet:param name="calendarIds" value="<%= calendarIds %>"/>
	<portlet:param name="redirect" value="<%= currentURL %>"/>
</portlet:resourceURL>

<span class="aqua">
	<h1 class="portlet-title-spec">&Eacute;v&egrave;nements &agrave; venir</h1>
	<span class="tgl"></span>
</span>

<div id="calendar-booking-list" class="aqua"></div>

<script type="text/javascript">

var DateDiff = {

	inDays: function(d1, d2) {
	    var t2 = d2.getTime();
	    var t1 = d1.getTime();
	
	    return parseInt((t2-t1)/(24*3600*1000));
	},
	
	inWeeks: function(d1, d2) {
	    var t2 = d2.getTime();
	    var t1 = d1.getTime();
	
	    return parseInt((t2-t1)/(24*3600*1000*7));
	},
	
	inMonths: function(d1, d2) {
	    var d1Y = d1.getFullYear();
	    var d2Y = d2.getFullYear();
	    var d1M = d1.getMonth();
	    var d2M = d2.getMonth();
	
	    return (d2M+12*d2Y)-(d1M+12*d1Y);
	},
	
	inYears: function(d1, d2) {
	    return d2.getFullYear()-d1.getFullYear();
	}
}

</script>

<aui:script use="aui-io-request">
	function syncCalendarBookings() {
	    A.io.request(
			'<%= url1 %>',
			{
				dataType: 'json',
				on: {
					success: function() {
						var calendarBookings = this.get('responseData');
						if (calendarBookings && calendarBookings.length > 0) {
							var resultHTML = '';
							for (var i = 0; i < calendarBookings.length; i++) {
								var cssClass = '';
								if (i % 2 == 0) {
									cssClass = 'yui-dt-even';
								}
								resultHTML += '<tr class="' + cssClass + '" style="border: 1px solid #ccc;border-bottom: 0px;font-weight: bold;">';
								
								var calendarBooking = calendarBookings[i];
								var today = new Date();
								var startDate = new Date(calendarBooking.startTime);
								var endDate = new Date(calendarBooking.endTime);
								var title = calendarBooking.title;
								var emplacement = calendarBooking.location;
								
								// Calendar picto
								var pictoHTML = '<td data-id="event-picto" style="width: 7% !important;">picto</td>';
								
								// Title
								var titleHTML = '<td data-id="event-title" onclick="javascript:document.location.href=\'' + calendarBooking.calendarBookingURL + '\';" style="cursor: pointer;width: 70% !important;text-align: left;">' + title + '</td>';
								
								// Detail
								var locationHTML = '<tr class="' + cssClass + '" style="border-left: 1px solid #ccc; border-right: 1px solid #ccc;border-bottom: 1px solid #ccc;">';
								locationHTML += '<td colspan="4" data-id="event-date" style="padding-left: 10px; text-align: left;">';
								locationHTML += startDate + ' &agrave; ' + emplacement;
								locationHTML += '</td>';
								locationHTML += '</tr>';
								
								// hurry up or not
								var nbDaysHurryUp = calendarBooking.nbDaysHurryUp;
								var diffInDays = DateDiff.inDays(today, startDate);
							
								// Questionnaire status
								var allAnswered = calendarBooking.allAnswered;
								var pictoTitle = '';
								var pictoCssClass = '';
								if (allAnswered) {
									pictoTitle = 'Vous avez répondu au questionnaire';
									pictoCssClass = "picto-answered";
								} else {
									if (today < startDate && diffInDays <= nbDaysHurryUp) {
										pictoCssClass = "picto-urgent";
										pictoTitle = "Vous n'avez pas encore répondu au questionnaire";
									} else if (today < startDate && diffInDays > nbDaysHurryUp) {
										pictoCssClass = "picto-nonanswered";
										pictoTitle = "Vous n'avez pas répondu au questionnaire";	
									} else if (today > startDate) {
										pictoCssClass = "picto-nonanswered";
										pictoTitle = "L'évènement est passé. Vous n'avez pas répondu au questionnaire";
									}
								}
								
								// View calendarBooking
								var viewCalendarBookingHTML = '<td data-id="event-questionnaire" style="width: 7% !important;">';
								viewCalendarBookingHTML += '<div title="' + pictoTitle + '" class="' + pictoCssClass + '" onclick="' + calendarBooking.calendarBookingURL + '">';
								viewCalendarBookingHTML += '</div>';
								viewCalendarBookingHTML += '</td>';
								
								// View file
								var fileHTML = '<td data-id="event-file" style="width: 7% !important;"></td>';
								
								resultHTML += pictoHTML + titleHTML + fileHTML + viewCalendarBookingHTML + '</tr>';	
								resultHTML += locationHTML;
							}
							document.getElementById('calendar-booking-list').innerHTML = '<table><tbody>' + resultHTML + '</tbody></table>';
						}
					}
				},
				sync: true
			}
	    );
	}
	syncCalendarBookings();
</aui:script>