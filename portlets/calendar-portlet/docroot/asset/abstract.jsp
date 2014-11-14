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

<%@ page import="com.liferay.portlet.asset.service.AssetEntryLocalServiceUtil" %>
<%@ page import="com.liferay.portlet.asset.model.AssetEntry" %>

<div>
	<%
	CalendarBooking calendarBooking = (CalendarBooking)request.getAttribute(WebKeys.CALENDAR_BOOKING);

	Calendar calendar = calendarBooking.getCalendar();
	
	String location = calendarBooking.getLocation();
	
	final AssetEntry layoutAssetEntry = AssetEntryLocalServiceUtil.getEntry(CalendarBooking.class.getName(), calendarBooking.getCalendarBookingId());
	final long assetEntryId = layoutAssetEntry.getEntryId();
	
	%>
	<div class="width100 asset-calendar-zone">
		<liferay-ui:icon
			image="../common/user_icon"
			message=""
		/>

		<strong><%= HtmlUtil.escape(calendar.getName(locale)) %></strong>
		
	</div>
	
	<% if (assetEntryId > 0) { %>
	<div class="picto-file"></div>
	<% } %>

	<div class="width100">
		<div class="width100 fLeft">
			<div class="fLeft pT1">
				<%
				java.util.Calendar startTimeJCalendar = JCalendarUtil.getJCalendar(calendarBooking.getStartTime(), user.getTimeZone());
				%>
				<%= dateFormatLongDate.format(startTimeJCalendar.getTime()) + " &agrave; " + hourFormat.format(startTimeJCalendar.getTime()) + "h" + minuteFormat.format(startTimeJCalendar.getTime()) %>
				<% if (location != null && !location.equals("")) { %>
					&agrave;
					<%= location %>
				<% } %>
			</div>
		</div>
	</div>
</div>