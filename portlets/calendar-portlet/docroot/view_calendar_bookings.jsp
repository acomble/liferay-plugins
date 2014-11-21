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

List<Calendar> userCalendars = null;

if (userCalendarResource != null) {
	userCalendars = CalendarServiceUtil.search(themeDisplay.getCompanyId(), null, new long[] {userCalendarResource.getCalendarResourceId()}, null, true, QueryUtil.ALL_POS, QueryUtil.ALL_POS, (OrderByComparator)null);
}

final List<Calendar> calendars = new ArrayList<Calendar>();
calendars.addAll(groupCalendars);
calendars.addAll(userCalendars);

final long[] calendarIds = new long[calendars.size()];
int i = 0;
for (Calendar c : calendars) {
	calendarIds[i] = c.getCalendarId();
	i++;
}
%>


<portlet:resourceURL id="serveCalendarBookingsAsset" portletName="1_WAR_calendarportlet" var="url1">
	<portlet:param name="calendarIds" value="<%= calendarIds %>"/>
	<portlet:param name="calendars" value="<%= calendars %>"/>
	<portlet:param name="redirect" value="<%= currentURL %>"/>
</portlet:resourceURL>


<aui:script use="aui-io-request">
	function syncCalendarBookings() {
	    A.io.request(
			<%= url1 %>,
			{
				dataType: 'json',
				on: {
					success: function() {
						console.error(this.get('responseData'));
					}
				},
				sync: true
			}
	    );
	}
	syncCalendarBookings();
</aui:script>