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

<div>
	<div class="width100 asset-calendar-zone">
		<liferay-ui:icon
			image="../common/user_icon"
			message=""
		/>

		<%
		CalendarBooking calendarBooking = (CalendarBooking)request.getAttribute(WebKeys.CALENDAR_BOOKING);

		Calendar calendar = calendarBooking.getCalendar();
		%>
		<strong><%= HtmlUtil.escape(calendar.getName(locale)) %></strong>
	</div>

	<div class="width100">
		<div class="width100 fLeft">
			<liferay-ui:icon
				image="../common/revision"
				message="start-date"
				cssClass="fLeft mR5"
			/>
			<div class="fLeft pT1">
				<liferay-ui:message key="start-date" />&nbsp;:&nbsp;
			</div>
			<div class="fLeft pT1">
				<%
				java.util.Calendar startTimeJCalendar = JCalendarUtil.getJCalendar(calendarBooking.getStartTime(), user.getTimeZone());
				%>
				<%= dateFormatLongDate.format(startTimeJCalendar.getTime()) + " &agrave; " + hourFormat.format(startTimeJCalendar.getTime()) + "h" + minuteFormat.format(startTimeJCalendar.getTime()) %>
			</div>
		</div>
		
		<div class="width100 fLeft">
			<liferay-ui:icon
				image="../common/revision"
				message="end-date"
				cssClass="fLeft mR5"
			/>
			<span>
			<div class="fLeft pT1">
				<liferay-ui:message key="end-date" />&nbsp;:&nbsp;
			</div>
			<div class="fLeft pT1">
				<%
				java.util.Calendar endTimeJCalendar = JCalendarUtil.getJCalendar(calendarBooking.getEndTime(), user.getTimeZone());
				%>
				<%= dateFormatLongDate.format(endTimeJCalendar.getTime()) + " &agrave; " + hourFormat.format(endTimeJCalendar.getTime()) + "h" + minuteFormat.format(endTimeJCalendar.getTime()) %>
			</div>
		</div>
	</div>
</div>

<br />