
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

<%@ page import="com.liferay.portal.model.User" %>
<%@ page import="com.liferay.portal.service.UserGroupRoleLocalServiceUtil" %>

<%
String activeView = ParamUtil.getString(request, "activeView", sessionClicksDefaultView);
long date = ParamUtil.getLong(request, "date", System.currentTimeMillis());

List<Calendar> groupCalendars = null;

if (groupCalendarResource != null) {
	groupCalendars = CalendarServiceUtil.search(themeDisplay.getCompanyId(), null, new long[] {groupCalendarResource.getCalendarResourceId()}, null, true, QueryUtil.ALL_POS, QueryUtil.ALL_POS, (OrderByComparator)null);
}

List<Calendar> userCalendars = null;

if (userCalendarResource != null) {
	userCalendars = CalendarServiceUtil.search(themeDisplay.getCompanyId(), null, new long[] {userCalendarResource.getCalendarResourceId()}, null, true, QueryUtil.ALL_POS, QueryUtil.ALL_POS, (OrderByComparator)null);
}

List<Calendar> otherCalendars = new ArrayList<Calendar>();

long[] calendarIds = StringUtil.split(SessionClicks.get(request, "calendar-portlet-other-calendars", StringPool.BLANK), 0L);

for (long calendarId : calendarIds) {
	Calendar calendar = CalendarServiceUtil.fetchCalendar(calendarId);

	if (calendar != null) {
		CalendarResource calendarResource = calendar.getCalendarResource();

		if (calendarResource.isActive()) {
			otherCalendars.add(calendar);
		}
	}
}

Calendar defaultCalendar = null;

List<Calendar> defaultCalendars = Collections.emptyList();

if ((groupCalendars != null) && (groupCalendars.size() > 0)) {
	defaultCalendars = groupCalendars;
}
else if (userCalendars != null) {
	defaultCalendars = userCalendars;
}

for (Calendar calendar : defaultCalendars) {
	if (calendar.isDefaultCalendar()) {
		defaultCalendar = calendar;

		break;
	}
}

JSONArray groupCalendarsJSONArray = CalendarUtil.toCalendarsJSONArray(themeDisplay, groupCalendars);
JSONArray userCalendarsJSONArray = CalendarUtil.toCalendarsJSONArray(themeDisplay, userCalendars);
JSONArray otherCalendarsJSONArray = CalendarUtil.toCalendarsJSONArray(themeDisplay, otherCalendars);

User currentUser = PortalUtil.getUser(request);
long currentUserId = currentUser.getUserId();
boolean isGestionnaireGlobal = UserGroupRoleLocalServiceUtil.hasUserGroupRole(currentUserId, themeDisplay.getScopeGroupId(), "gestionnaire-global", false);
boolean isGestionnaireSection = UserGroupRoleLocalServiceUtil.hasUserGroupRole(currentUserId, themeDisplay.getScopeGroupId(), "gestionnaire-section", false);

boolean columnOptionsVisible = false;
if (isGestionnaireGlobal || permissionChecker.isOmniadmin()) {
	columnOptionsVisible = true;
}


%>

<!-- begin view_calendar.jsp file -->

<aui:container cssClass="calendar-portlet-column-parent">
	<aui:row>
		<aui:col cssClass='<%= "calendar-portlet-column-options " + (columnOptionsVisible ? StringPool.BLANK : "hide") %>' id="columnOptions" span="<%= 3 %>">
			<div class="calendar-portlet-mini-calendar" id="<portlet:namespace />miniCalendarContainer"></div>

			<div id="<portlet:namespace />calendarListContainer">
				<!-- Do not show user calendar -->
				<c:if test="<%= themeDisplay.isSignedIn() %>">
					<div class="calendar-portlet-list-header toggler-header-expanded">
						<span class="calendar-portlet-list-arrow"></span>

						<span class="calendar-portlet-list-text"><liferay-ui:message key="my-calendars" /></span>

						<c:if test="<%= userCalendarResource != null %>">
							<span class="calendar-list-item-arrow" data-calendarResourceId="<%= userCalendarResource.getCalendarResourceId() %>" tabindex="0"><i class="icon-caret-down"></i></span>
						</c:if>
					</div>

					<div class="calendar-portlet-calendar-list" id="<portlet:namespace />myCalendarList"></div>
				</c:if>

				<!-- Do not show site calendar -->
				<!-- User cannot switch to another calendar -->
				<c:if test="<%= groupCalendarResource != null %>">
					<div class="calendar-portlet-list-header toggler-header-expanded">
						<span class="calendar-portlet-list-arrow"></span>

						<span class="calendar-portlet-list-text"><liferay-ui:message key="current-site-calendars" /></span>

						<c:if test="<%= CalendarResourcePermission.contains(permissionChecker, groupCalendarResource, ActionKeys.ADD_CALENDAR) %>">
							<span class="calendar-list-item-arrow" data-calendarResourceId="<%= groupCalendarResource.getCalendarResourceId() %>" tabindex="0"><i class="icon-caret-down"></i></span>
						</c:if>
					</div>

					<div class="calendar-portlet-calendar-list" id="<portlet:namespace />siteCalendarList"></div>
				</c:if>

				<!-- Do not show add calendars menu -->
				<c:if test="<%= themeDisplay.isSignedIn() %>">
					<div class="calendar-portlet-list-header toggler-header-expanded">
						<span class="calendar-portlet-list-arrow"></span>

						<span class="calendar-portlet-list-text"><liferay-ui:message key="other-calendars" /></span>
					</div>

					<div class="calendar-portlet-calendar-list" id="<portlet:namespace />otherCalendarList">
						<input class="calendar-portlet-add-calendars-input" id="<portlet:namespace />addOtherCalendar" placeholder="<liferay-ui:message key="add-other-calendars" />" type="text" />
					</div>
				</c:if>
			</div>

			<div id="<portlet:namespace />message"></div>
		
		</aui:col>
		

		<aui:col cssClass="calendar-portlet-column-grid" id="columnGrid" span="<%= columnOptionsVisible ? 9 : 12 %>">
			<div class="calendar-portlet-column-toggler" id="<portlet:namespace />columnToggler">
				<i class="<%= columnOptionsVisible ? "icon-caret-left" : "icon-caret-right" %>" id="<portlet:namespace />columnTogglerIcon"></i>
			</div>

			<liferay-util:include page="/scheduler.jsp" servletContext="<%= application %>">
				<liferay-util:param name="activeView" value="<%= activeView %>" />
				<liferay-util:param name="date" value="<%= String.valueOf(date) %>" />

				<portlet:renderURL var="editCalendarBookingURL" windowState="<%= LiferayWindowState.POP_UP.toString() %>">
					<portlet:param name="mvcPath" value="/edit_calendar_booking.jsp" />
					<portlet:param name="activeView" value="{activeView}" />
					<portlet:param name="allDay" value="{allDay}" />
					<portlet:param name="calendarBookingId" value="{calendarBookingId}" />
					<portlet:param name="calendarId" value="{calendarId}" />
					<portlet:param name="date" value="{date}" />
					<portlet:param name="endTimeDay" value="{endTimeDay}" />
					<portlet:param name="endTimeHour" value="{endTimeHour}" />
					<portlet:param name="endTimeMinute" value="{endTimeMinute}" />
					<portlet:param name="endTimeMonth" value="{endTimeMonth}" />
					<portlet:param name="endTimeYear" value="{endTimeYear}" />
					<portlet:param name="instanceIndex" value="{instanceIndex}" />
					<portlet:param name="startTimeDay" value="{startTimeDay}" />
					<portlet:param name="startTimeHour" value="{startTimeHour}" />
					<portlet:param name="startTimeMinute" value="{startTimeMinute}" />
					<portlet:param name="startTimeMonth" value="{startTimeMonth}" />
					<portlet:param name="startTimeYear" value="{startTimeYear}" />
					<portlet:param name="titleCurrentValue" value="{titleCurrentValue}" />
				</portlet:renderURL>

				<liferay-util:param name="editCalendarBookingURL" value="<%= editCalendarBookingURL %>" />

				<liferay-util:param name="readOnly" value="<%= String.valueOf(false) %>" />

				<liferay-security:permissionsURL
					modelResource="<%= CalendarBooking.class.getName() %>"
					modelResourceDescription="{modelResourceDescription}"
					resourceGroupId="{resourceGroupId}"
					resourcePrimKey="{resourcePrimKey}"
					var="permissionsCalendarBookingURL"
					windowState="<%= LiferayWindowState.POP_UP.toString() %>"
				/>

				<liferay-util:param name="permissionsCalendarBookingURL" value="<%= permissionsCalendarBookingURL %>" />

				<liferay-util:param name="showAddEventBtn" value="<%= String.valueOf((userDefaultCalendar != null) && CalendarPermission.contains(permissionChecker, userDefaultCalendar, ActionKeys.MANAGE_BOOKINGS)) %>" />

				<portlet:renderURL var="viewCalendarBookingURL" windowState="<%= LiferayWindowState.POP_UP.toString() %>">
					<portlet:param name="mvcPath" value="/view_calendar_booking.jsp" />
					<portlet:param name="calendarBookingId" value="{calendarBookingId}" />
					<portlet:param name="instanceIndex" value="{instanceIndex}" />
				</portlet:renderURL>

				<liferay-util:param name="viewCalendarBookingURL" value="<%= viewCalendarBookingURL %>" />
			</liferay-util:include>
			
			<!--  end of include scheduler.jsp -->
			
			<div style="margin-top: 10px;">
				<liferay-portlet:resourceURL id="calendarICS" var="calendarICSLink"></liferay-portlet:resourceURL>
				
				<a class="portlet-title-spec" 
					style="color:#FFF;background:#FF9966 !important;text-decoration:none;" 
					href="<%= calendarICSLink %>">
					T&eacute;l&eacute;charger le calendrier <!-- au format ics -->
				</a>
			</div>

		</aui:col>
		
		<aui:col id="calendar-portlet-column-details" style="margin-left: 10px;float: left;" cssClass="fLeft calendar-portlet-column-details hide">
			<div id="event-detail" class="fLeft">
				<div class="fLeft event-detail-title" id="event-detail-title"></div>
				<div class="fLeft h30" id="event-detail-startdate-zone">
					<span class="fLeft pT2">Du</span>
					<span class="fLeft pT2 event-detail-detail" id="event-detail-startdate"></span>
				</div>
				<div class="fLeft h30" id="event-detail-enddate-zone">
					<span class="fLeft pT2">Au</span>
					<span class="fLeft pT2 event-detail-detail" id="event-detail-enddate"></span>
				</div>
				<div class="fLeft h35" id="event-detail-invitees-zone">
					<span class="fLeft pT2" style="width:50px;">Invit�s</span>
					<span class="fLeft pT2 event-detail-detail invitees-zone" id="event-detail-invitees"></span>
				</div>
				<div class="fLeft mT25" id="event-detail-attend-zone hide">
					<div class="fLeft event-detail-attend-title" id="event-detail-attend-title">Serez-vous pr�sent ?</div>
					<div class="fLeft">
						<liferay-portlet:resourceURL id="calendarBookingPresence" var="invokeTransitionURL" />
						<aui:form action="javascript:void(0);" method="post" name="fm">
							<aui:input name="target" type="hidden" value="<%= invokeTransitionURL %>" />
							<aui:input name="calendarBookingId" type="hidden" value="" />
							<aui:input name="status" type="hidden" />
							<aui:button name="accept" cssClass="btn btn-orange" data-status-accept="0" value="accept" />
							<aui:button name="maybe" cssClass="btn btn-orange" data-status-maybe="9" value="maybe" />
							<aui:button name="decline" cssClass="btn btn-orange" data-status-decline="4" value="decline" />
						</aui:form>
					</div>
				</div>
				<div class="fLeft h30 mT25" id="event-detail-actions">
					<c:if test="<%= isGestionnaireGlobal || isGestionnaireSection || permissionChecker.isOmniadmin() %>">
					<span>
							<button class="presence" id="event-detail-edit" name="event-detail-edit" value="edit">Modifier</button>
							<button class="presence" id="event-detail-delete" name="event-detail-delete" value="delete">Supprimer</button>
					</span>
					</c:if>
				</div>
			</div>
			<div id="event-questionnaire" class="fLeft">
<!-- 				<div class="fLeft event-questionnaire-title" id="event-questionnaire-title"></div> -->
				<div id="event-questionnaire-questions" style="width: 100%;"></div>	
			</div>
		</aui:col>
	</aui:row>
</aui:container>

<!--  include view_calendar_menus.jspf -->
<%@ include file="/view_calendar_menus.jspf" %>

<aui:script use="aui-toggler,liferay-calendar-list,liferay-scheduler,liferay-store,json">

	var manageCalendarAttendee = function (status) {
		var calendarBookingId = A.one('#<portlet:namespace />calendarBookingId').val();
		var url = A.one('#<portlet:namespace />target').val();
		url += '&<portlet:namespace />calendarBookingId=' + calendarBookingId;
		url += '&<portlet:namespace />status=' + status;
		A.io.request(
			url,
			{
				dataType: 'json',
				on: {
					success: function() {
						var status = this.get('responseData').status;
						if (status == 9 || status == 4 || status == 0) {
							manageEventAttendAnswers('<portlet:namespace />', status);
							if (status == 4) {
								A.one('#portlet:namespace />event-detail-attend-zone').toggleClass('hide');
							}
						}
					}
				},
				sync: true
			}
	    );
	};

	A.one('#<portlet:namespace />accept').on(
		'click',
		function(event) {
			var status = A.one('#<portlet:namespace />accept').getData('status-accept');
			manageCalendarAttendee(status);
		}
	);
	A.one('#<portlet:namespace />maybe').on(
		'click',
		function(event) {
			var status = A.one('#<portlet:namespace />maybe').getData('status-maybe');
			manageCalendarAttendee(status);
		}
	);
	A.one('#<portlet:namespace />decline').on(
		'click',
		function(event) {
			var status = A.one('#<portlet:namespace />decline').getData('status-decline');
			manageCalendarAttendee(status);
		}
	);

	Liferay.CalendarUtil.USER_CLASS_NAME_ID = <%= PortalUtil.getClassNameId(User.class) %>;

	Liferay.CalendarUtil.INVITEES_URL = '<liferay-portlet:resourceURL copyCurrentRenderParameters="<%= false %>" id="calendarBookingInvitees" />';
	Liferay.CalendarUtil.RENDERING_RULES_URL = '<liferay-portlet:resourceURL copyCurrentRenderParameters="<%= false %>" id="calendarRenderingRules" />';
	Liferay.CalendarUtil.RESOURCE_CALENDARS_URL = '<liferay-portlet:resourceURL copyCurrentRenderParameters="<%= false %>" id="resourceCalendars" />';

	<c:if test="<%= defaultCalendar != null %>">
		Liferay.CalendarUtil.DEFAULT_USER_CALENDAR_ID = <%= defaultCalendar.getCalendarId() %>;
	</c:if>

	var syncCalendarsMap = function() {
		var calendarLists = [];

		<c:if test="<%= themeDisplay.isSignedIn() || (groupCalendarResource != null) %>">
			calendarLists.push(window.<portlet:namespace />myCalendarList);
		</c:if>

		<c:if test="<%= themeDisplay.isSignedIn() %>">
			calendarLists.push(window.<portlet:namespace />otherCalendarList);
		</c:if>

		<c:if test="<%= groupCalendarResource != null %>">
			calendarLists.push(window.<portlet:namespace />siteCalendarList);
		</c:if>

		Liferay.CalendarUtil.syncCalendarsMap(calendarLists);
	}

	window.<portlet:namespace />syncCalendarsMap = syncCalendarsMap;

	window.<portlet:namespace />calendarLists = {};

	<c:if test="<%= themeDisplay.isSignedIn() || (groupCalendarResource != null) %>">
		window.<portlet:namespace />myCalendarList = new Liferay.CalendarList(
			{
				after: {
					calendarsChange: syncCalendarsMap,
					'scheduler-calendar:visibleChange': function(event) {
						syncCalendarsMap();

						<portlet:namespace />refreshVisibleCalendarRenderingRules();
					}
				},
				boundingBox: '#<portlet:namespace />myCalendarList',

				<%
				updateCalendarsJSONArray(request, userCalendarsJSONArray);
				%>

				calendars: <%= userCalendarsJSONArray %>,
				scheduler: <portlet:namespace />scheduler,
				simpleMenu: window.<portlet:namespace />calendarsMenu,
				visible: <%= themeDisplay.isSignedIn() %>
			}
		).render();

		window.<portlet:namespace />calendarLists['<%= userCalendarResource.getCalendarResourceId() %>'] = window.<portlet:namespace />myCalendarList;
	</c:if>

	<c:if test="<%= themeDisplay.isSignedIn() %>">
		window.<portlet:namespace />otherCalendarList = new Liferay.CalendarList(
			{
				after: {
					calendarsChange: function(event) {
						syncCalendarsMap();

						<portlet:namespace />scheduler.load();

						var calendarIds = A.Array.invoke(event.newVal, 'get', 'calendarId');

						Liferay.Store('calendar-portlet-other-calendars', calendarIds.join());
					},
					'scheduler-calendar:visibleChange': function(event) {
						syncCalendarsMap();

						<portlet:namespace />refreshVisibleCalendarRenderingRules();
					}
				},
				boundingBox: '#<portlet:namespace />otherCalendarList',

				<%
				updateCalendarsJSONArray(request, otherCalendarsJSONArray);
				%>

				calendars: <%= otherCalendarsJSONArray %>,
				scheduler: <portlet:namespace />scheduler,
				simpleMenu: window.<portlet:namespace />calendarsMenu
			}
		).render();
	</c:if>

	<c:if test="<%= groupCalendarResource != null %>">
		window.<portlet:namespace />siteCalendarList = new Liferay.CalendarList(
			{
				after: {
					calendarsChange: syncCalendarsMap,
					'scheduler-calendar:visibleChange': function(event) {
						syncCalendarsMap();

						<portlet:namespace />refreshVisibleCalendarRenderingRules();
					}
				},
				boundingBox: '#<portlet:namespace />siteCalendarList',

				<%
				updateCalendarsJSONArray(request, groupCalendarsJSONArray);
				%>

				calendars: <%= groupCalendarsJSONArray %>,
				scheduler: <portlet:namespace />scheduler,
				simpleMenu: window.<portlet:namespace />calendarsMenu
			}
		).render();

		window.<portlet:namespace />calendarLists['<%= groupCalendarResource.getCalendarResourceId() %>'] = window.<portlet:namespace />siteCalendarList;
	</c:if>

	syncCalendarsMap();

	A.each(
		Liferay.CalendarUtil.availableCalendars,
		function(item, index) {
			item.on(
				{
					'visibleChange': function(event) {
						var instance = this;

						var calendar = event.currentTarget;

						Liferay.Store('calendar-portlet-calendar-' + calendar.get('calendarId') + '-visible', event.newVal);
					}
				}
			);
		}
	);

	window.<portlet:namespace />toggler = new A.TogglerDelegate(
		{
			animated: true,
			container: '#<portlet:namespace />calendarListContainer',
			content: '.calendar-portlet-calendar-list',
			header: '.calendar-portlet-list-header'
		}
	);

	<c:if test="<%= themeDisplay.isSignedIn() %>">
		var addOtherCalendarInput = A.one('#<portlet:namespace />addOtherCalendar');

		<liferay-portlet:resourceURL copyCurrentRenderParameters="<%= false %>" id="calendarResources" var="calendarResourcesURL" />

		Liferay.CalendarUtil.createCalendarsAutoComplete(
			'<%= calendarResourcesURL %>',
			addOtherCalendarInput,
			function(event) {
				window.<portlet:namespace />otherCalendarList.add(event.result.raw);

				<portlet:namespace />refreshVisibleCalendarRenderingRules();

				addOtherCalendarInput.val('');
			}
		);
	</c:if>

	A.one('#<portlet:namespace />columnToggler').on(
		'click',
		function(event) {
			var columnGrid = A.one('#<portlet:namespace />columnGrid');
			var columnOptions = A.one('#<portlet:namespace />columnOptions');
			var columnTogglerIcon = A.one('#<portlet:namespace />columnTogglerIcon');
			var eventDetail = A.one('#<portlet:namespace />calendar-portlet-column-details');

			Liferay.Store('calendar-portlet-column-options-visible', columnOptions.hasClass('hide'));

			columnGrid.toggleClass('span9').toggleClass('span12');

			columnOptions.toggleClass('hide');

			columnTogglerIcon.toggleClass('icon-caret-left').toggleClass('icon-caret-right');
			
			if (eventDetail.hasClass('hide')) {
				if (columnOptions.hasClass('hide')) {
					columnGrid.setStyle('width', '100%');
				} else {
					columnGrid.setStyle('width', '70%');
				}
			} else {
				if (columnOptions.hasClass('hide')) {
					columnGrid.setStyle('width', '70%');
				} else {
					columnGrid.setStyle('width', '47%');
				}
			}
		}
	);
</aui:script>

<aui:script use="aui-base,aui-datatype,calendar">
	var DateMath = A.DataType.DateMath;

	window.<portlet:namespace />refreshMiniCalendarSelectedDates = function() {
		<portlet:namespace />miniCalendar._clearSelection();

		var activeView = <portlet:namespace />scheduler.get('activeView');
		var viewDate = <portlet:namespace />scheduler.get('viewDate');

		var viewName = activeView.get('name');

		var total = 1;

		if (viewName == 'month') {
			total = A.Date.daysInMonth(viewDate);
		}
		else if (viewName == 'week') {
			total = 7;
		}

		var selectedDates = Liferay.CalendarUtil.getDatesList(viewDate, total);

		<portlet:namespace />miniCalendar.selectDates(selectedDates);

		<portlet:namespace />miniCalendar.set('date', viewDate);
	};

	window.<portlet:namespace />refreshVisibleCalendarRenderingRules = function() {
		var miniCalendarStartDate = DateMath.subtract(DateMath.toMidnight(window.<portlet:namespace />miniCalendar.get('date')), DateMath.WEEK, 1);

		var miniCalendarEndDate = DateMath.add(DateMath.add(miniCalendarStartDate, DateMath.MONTH, 1), DateMath.WEEK, 1);

		miniCalendarEndDate.setHours(23, 59, 59, 999);

		Liferay.CalendarUtil.getCalendarRenderingRules(
			A.Object.keys(Liferay.CalendarUtil.visibleCalendars),
			Liferay.CalendarUtil.toUTC(miniCalendarStartDate),
			Liferay.CalendarUtil.toUTC(miniCalendarEndDate),
			'busy',
			function(rulesDefinition) {
				window.<portlet:namespace />miniCalendar.set(
					'customRenderer',
					{
						filterFunction: function(date, node, rules) {
							node.addClass('lfr-busy-day');

							var selectedDates = this._getSelectedDatesList();

							DateMath.toMidnight(date);

							var selected = (selectedDates.length > 0) && A.Date.isInRange(date, selectedDates[0], selectedDates[selectedDates.length - 1]);

							if (A.DataType.DateMath.isToday(date)) {
								node.addClass('lfr-current-day');
							}

							node.toggleClass('yui3-calendar-day-selected', selected);
						},
						rules: rulesDefinition
					}
				);
			}
		);
	};

	window.<portlet:namespace />miniCalendar = new A.Calendar(
		{
			after: {
				dateChange: <portlet:namespace />refreshVisibleCalendarRenderingRules,
				dateClick: function(event) {
					<portlet:namespace />scheduler.setAttrs(
						{
							activeView: <portlet:namespace />dayView,
							date: event.date
						}
					);
				}
			},
			date: new Date(<%= String.valueOf(date) %>),
			locale: 'en',
			'strings.first_weekday': <%= weekStartsOn %>
		}
	).render('#<portlet:namespace />miniCalendarContainer');

	<portlet:namespace />scheduler.after(
		['*:add', '*:change', '*:load', '*:remove', '*:reset'],
		A.debounce(<portlet:namespace />refreshVisibleCalendarRenderingRules, 100)
	);

	<portlet:namespace />scheduler.after(
		['activeViewChange', 'dateChange'],
		<portlet:namespace />refreshMiniCalendarSelectedDates
	);

	<portlet:namespace />refreshVisibleCalendarRenderingRules();
	<portlet:namespace />refreshMiniCalendarSelectedDates();

	<portlet:namespace />scheduler.load();
</aui:script>

<%!
protected void updateCalendarsJSONArray(HttpServletRequest request, JSONArray calendarsJSONArray) {
	for (int i = 0; i < calendarsJSONArray.length(); i++) {
		JSONObject jsonObject = calendarsJSONArray.getJSONObject(i);

		long calendarId = jsonObject.getLong("calendarId");

		jsonObject.put("color", GetterUtil.getString(SessionClicks.get(request, "calendar-portlet-calendar-" + calendarId + "-color", jsonObject.getString("color"))));
		jsonObject.put("visible", GetterUtil.getBoolean(SessionClicks.get(request, "calendar-portlet-calendar-" + calendarId + "-visible", "true")));
	}
}
%>

<!--  end of view_calendar.jsp file -->