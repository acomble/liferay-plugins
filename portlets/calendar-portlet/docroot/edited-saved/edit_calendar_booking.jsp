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

<!-- This template corresponds to creation or updating event popup -->

<%@ include file="/init.jsp" %>

<%@ page import="com.liferay.calendar.util.SurveyUtil" %>
<%@ page import="com.liferay.calendar.util.Survey" %>

<%
String activeView = ParamUtil.getString(request, "activeView", defaultView);

CalendarBooking calendarBooking = (CalendarBooking)request.getAttribute(WebKeys.CALENDAR_BOOKING);
		 
String surveyId = null;
if (calendarBooking != null) {
	surveyId = (String) calendarBooking.getExpandoBridge().getAttribute("surveyId");
}

boolean allDay = BeanParamUtil.getBoolean(calendarBooking, request, "allDay");

TimeZone calendarBookingTimeZone = userTimeZone;

if (allDay) {
	calendarBookingTimeZone = utcTimeZone;
}

java.util.Calendar nowJCalendar = CalendarFactoryUtil.getCalendar(calendarBookingTimeZone);

long date = ParamUtil.getLong(request, "date", nowJCalendar.getTimeInMillis());

long calendarBookingId = BeanPropertiesUtil.getLong(calendarBooking, "calendarBookingId");

int instanceIndex = BeanParamUtil.getInteger(calendarBooking, request, "instanceIndex");

long calendarId = BeanParamUtil.getLong(calendarBooking, request, "calendarId", userDefaultCalendar.getCalendarId());

long startTime = BeanPropertiesUtil.getLong(calendarBooking, "startTime", nowJCalendar.getTimeInMillis());

java.util.Calendar startTimeJCalendar = JCalendarUtil.getJCalendar(startTime, calendarBookingTimeZone);

int startTimeYear = ParamUtil.getInteger(request, "startTimeYear", startTimeJCalendar.get(java.util.Calendar.YEAR));
int startTimeMonth = ParamUtil.getInteger(request, "startTimeMonth", startTimeJCalendar.get(java.util.Calendar.MONTH));
int startTimeDay = ParamUtil.getInteger(request, "startTimeDay", startTimeJCalendar.get(java.util.Calendar.DAY_OF_MONTH));
int startTimeHour = ParamUtil.getInteger(request, "startTimeHour", startTimeJCalendar.get(java.util.Calendar.HOUR_OF_DAY));
int startTimeMinute = ParamUtil.getInteger(request, "startTimeMinute", startTimeJCalendar.get(java.util.Calendar.MINUTE));

startTimeJCalendar = CalendarFactoryUtil.getCalendar(startTimeYear, startTimeMonth, startTimeDay, startTimeHour, startTimeMinute, 0, 0, calendarBookingTimeZone);

startTime = startTimeJCalendar.getTimeInMillis();

java.util.Calendar defaultEndTimeJCalendar = (java.util.Calendar)nowJCalendar.clone();

defaultEndTimeJCalendar.add(java.util.Calendar.HOUR, 1);

long endTime = BeanPropertiesUtil.getLong(calendarBooking, "endTime", defaultEndTimeJCalendar.getTimeInMillis());

java.util.Calendar endTimeJCalendar = JCalendarUtil.getJCalendar(endTime, calendarBookingTimeZone);

int endTimeYear = ParamUtil.getInteger(request, "endTimeYear", endTimeJCalendar.get(java.util.Calendar.YEAR));
int endTimeMonth = ParamUtil.getInteger(request, "endTimeMonth", endTimeJCalendar.get(java.util.Calendar.MONTH));
int endTimeDay = ParamUtil.getInteger(request, "endTimeDay", endTimeJCalendar.get(java.util.Calendar.DAY_OF_MONTH));
int endTimeHour = ParamUtil.getInteger(request, "endTimeHour", endTimeJCalendar.get(java.util.Calendar.HOUR_OF_DAY));
int endTimeMinute = ParamUtil.getInteger(request, "endTimeMinute", endTimeJCalendar.get(java.util.Calendar.MINUTE));

endTimeJCalendar = CalendarFactoryUtil.getCalendar(endTimeYear, endTimeMonth, endTimeDay, endTimeHour, endTimeMinute, 0, 0, calendarBookingTimeZone);

endTime = endTimeJCalendar.getTimeInMillis();

long firstReminder = BeanParamUtil.getLong(calendarBooking, request, "firstReminder");
String firstReminderType = BeanParamUtil.getString(calendarBooking, request, "firstReminderType", PortletPropsValues.CALENDAR_NOTIFICATION_DEFAULT_TYPE);
long secondReminder = BeanParamUtil.getLong(calendarBooking, request, "secondReminder");
String secondReminderType = BeanParamUtil.getString(calendarBooking, request, "secondReminderType", PortletPropsValues.CALENDAR_NOTIFICATION_DEFAULT_TYPE);

int status = BeanParamUtil.getInteger(calendarBooking, request, "status");

JSONArray acceptedCalendarsJSONArray = JSONFactoryUtil.createJSONArray();
JSONArray declinedCalendarsJSONArray = JSONFactoryUtil.createJSONArray();
JSONArray maybeCalendarsJSONArray = JSONFactoryUtil.createJSONArray();
JSONArray pendingCalendarsJSONArray = JSONFactoryUtil.createJSONArray();

boolean invitable = true;
Recurrence recurrence = null;
boolean recurring = false;

Calendar calendar = CalendarServiceUtil.fetchCalendar(calendarId);

if (calendarBooking != null) {
	acceptedCalendarsJSONArray = CalendarUtil.toCalendarBookingsJSONArray(themeDisplay, CalendarBookingServiceUtil.getChildCalendarBookings(calendarBooking.getParentCalendarBookingId(), CalendarBookingWorkflowConstants.STATUS_APPROVED));
	declinedCalendarsJSONArray = CalendarUtil.toCalendarBookingsJSONArray(themeDisplay, CalendarBookingServiceUtil.getChildCalendarBookings(calendarBooking.getParentCalendarBookingId(), CalendarBookingWorkflowConstants.STATUS_DENIED));
	maybeCalendarsJSONArray = CalendarUtil.toCalendarBookingsJSONArray(themeDisplay, CalendarBookingServiceUtil.getChildCalendarBookings(calendarBooking.getParentCalendarBookingId(), CalendarBookingWorkflowConstants.STATUS_MAYBE));
	pendingCalendarsJSONArray = CalendarUtil.toCalendarBookingsJSONArray(themeDisplay, CalendarBookingServiceUtil.getChildCalendarBookings(calendarBooking.getParentCalendarBookingId(), CalendarBookingWorkflowConstants.STATUS_PENDING));

	if (!calendarBooking.isMasterBooking()) {
		invitable = false;
	}

	if (calendarBooking.isRecurring()) {
		recurring = true;
	}

	recurrence = calendarBooking.getRecurrenceObj();
}
else if (calendar != null) {
	JSONObject calendarJSONObject = CalendarUtil.toCalendarJSONObject(themeDisplay, calendar);

	if (calendar.getUserId() == themeDisplay.getUserId()) {
		acceptedCalendarsJSONArray.put(calendarJSONObject);
	}
	else {
		pendingCalendarsJSONArray.put(calendarJSONObject);
	}
}

List<Survey> surveys = SurveyUtil.getSurveys();

List<Calendar> manageableCalendars = CalendarServiceUtil.search(themeDisplay.getCompanyId(), null, null, null, true, QueryUtil.ALL_POS, QueryUtil.ALL_POS, new CalendarNameComparator(true), ActionKeys.MANAGE_BOOKINGS);
%>

<liferay-portlet:actionURL name="updateCalendarBooking" var="updateCalendarBookingURL" />

<aui:form action="<%= updateCalendarBookingURL %>" method="post" name="fm" onSubmit='<%= "event.preventDefault(); " + renderResponse.getNamespace() + "updateCalendarBooking();" %>'>
	<aui:input name="mvcPath" type="hidden" value="/edit_calendar_booking.jsp" />

	<liferay-portlet:renderURL var="redirectURL">
		<liferay-portlet:param name="mvcPath" value="/edit_calendar_booking.jsp" />
		<liferay-portlet:param name="calendarBookingId" value="<%= String.valueOf(calendarBookingId) %>" />
	</liferay-portlet:renderURL>

	<aui:input name="redirect" type="hidden" value="<%= redirectURL %>" />
	<aui:input name="calendarBookingId" type="hidden" value="<%= calendarBookingId %>" />
	<aui:input name="instanceIndex" type="hidden" value="<%= instanceIndex %>" />
	<aui:input name="childCalendarIds" type="hidden" />
	<aui:input name="status" type="hidden" value ="<%= status %>" />
	<aui:input name="allFollowing" type="hidden" />
	<aui:input name="updateCalendarBookingInstance" type="hidden" />

	<liferay-ui:error exception="<%= CalendarBookingDurationException.class %>" message="please-enter-a-start-date-that-comes-before-the-end-date" />

	<liferay-ui:asset-categories-error />

	<liferay-ui:asset-tags-error />

	<aui:model-context bean="<%= calendarBooking %>" model="<%= CalendarBooking.class %>" />

	<aui:fieldset>
		<aui:input defaultLanguageId="<%= themeDisplay.getLanguageId() %>" name="title" />

		<div class="<%= allDay ? "allday-class-active" : "" %>" id="<portlet:namespace />startDateContainer">
			<aui:input ignoreRequestValue="<%= true %>" label="start-date" name="startTime" value="<%= startTimeJCalendar %>" />
		</div>

		<div class="<%= allDay ? "allday-class-active" : "" %>" id="<portlet:namespace />endDateContainer">
			<aui:input ignoreRequestValue="<%= true %>" label="end-date" name="endTime" value="<%= endTimeJCalendar %>" />
		</div>

		<aui:input checked="<%= allDay %>" name="allDay" />

		<aui:input defaultLanguageId="<%= themeDisplay.getLanguageId() %>" name="description" />
	</aui:fieldset>
	
	<aui:fieldset>
		<liferay-ui:panel-container extended="<%= true %>" id="calendarBookingQuestionnairesPanelContainer" persistState="<%= true %>">
			<liferay-ui:panel collapsible="<%= false %>" defaultState="closed" extended="<%= true %>" id="calendarBookingQuestionnairesPanel" persistState="<%= true %>" title="questionnaire">
				<aui:select label="S�lectionner le questionnaire" name="questionnaireId">
					<%
					for (final Survey survey : surveys) {
					%>
		
						<aui:option selected="<%= (surveyId != null && Long.parseLong(surveyId) == survey.getId()) ? true : false %>" value="<%= survey.getId() %>">
							<%= HtmlUtil.escape(survey.getName()) + " - " + HtmlUtil.escape(survey.getDescription()) %>
						</aui:option>
		
					<%
					}
					%>
				</aui:select>
			</liferay-ui:panel>
		</liferay-ui:panel-container>
	</aui:fieldset>

	<aui:fieldset>
		<liferay-ui:panel-container extended="<%= true %>" id="calendarBookingDetailsPanelContainer" persistState="<%= true %>">
			<liferay-ui:panel collapsible="<%= true %>" defaultState="closed" extended="<%= true %>" id="calendarBookingDetailsPanel" persistState="<%= true %>" title="details">
				<aui:select label="calendar" name="calendarId">

					<%
					for (Calendar curCalendar : manageableCalendars) {
						if ((calendarBooking != null) && (curCalendar.getCalendarId() != calendarId) && (CalendarBookingLocalServiceUtil.getCalendarBookingsCount(curCalendar.getCalendarId(), calendarBooking.getParentCalendarBookingId()) > 0)) {
							continue;
						}
					%>

						<aui:option selected="<%= curCalendar.getCalendarId() == calendarId %>" value="<%= curCalendar.getCalendarId() %>"><%= HtmlUtil.escape(curCalendar.getName(locale)) %></aui:option>

					<%
					}
					%>

				</aui:select>

				<aui:input name="location" />

			</liferay-ui:panel>

			<liferay-ui:panel collapsible="<%= true %>" defaultState='<%= BrowserSnifferUtil.isMobile(request) ? "closed" : "open" %>' extended="<%= false %>" id="calendarBookingInvitationPanel" persistState="<%= true %>" title="invitations">
				<c:if test="<%= invitable %>">
					<aui:input inputCssClass="calendar-portlet-invite-resources-input" label="" name="inviteResource" placeholder="add-people-groups-rooms" type="text" />

					<div class="separator"><!-- --></div>
				</c:if>

				<aui:layout cssClass="calendar-booking-invitations">
					<aui:column columnWidth="<%= (calendarBooking != null) ? 25 : 50 %>" first="true">
						<label class="field-label">
							<liferay-ui:message key="pending" /> (<span id="<portlet:namespace />pendingCounter"><%= pendingCalendarsJSONArray.length() %></span>)
						</label>

						<div class="calendar-portlet-calendar-list" id="<portlet:namespace />calendarListPending"></div>
					</aui:column>
					<aui:column columnWidth="<%= (calendarBooking != null) ? 25 : 50 %>">
						<label class="field-label">
							<liferay-ui:message key="accepted" /> (<span id="<portlet:namespace />acceptedCounter"><%= acceptedCalendarsJSONArray.length() %></span>)
						</label>

						<div class="calendar-portlet-calendar-list" id="<portlet:namespace />calendarListAccepted"></div>
					</aui:column>

					<c:if test="<%= calendarBooking != null %>">
						<aui:column columnWidth="25" last="true">
							<label class="field-label">
								<liferay-ui:message key="maybe" /> (<span id="<portlet:namespace />maybeCounter"><%= maybeCalendarsJSONArray.length() %></span>)
							</label>

							<div class="calendar-portlet-calendar-list" id="<portlet:namespace />calendarListMaybe"></div>
						</aui:column>
						<aui:column columnWidth="25" last="true">
							<label class="field-label">
								<liferay-ui:message key="declined" /> (<span id="<portlet:namespace />declinedCounter"><%= declinedCalendarsJSONArray.length() %></span>)
							</label>

							<div class="calendar-portlet-calendar-list" id="<portlet:namespace />calendarListDeclined"></div>
						</aui:column>
					</c:if>

				</aui:layout>
			</liferay-ui:panel>

			<liferay-ui:panel collapsible="<%= true %>" defaultState="closed" extended="<%= false %>" id="calendarBookingReminderPanel" persistState="<%= true %>" title="reminders">
				<div class="calendar-booking-reminders" id="<portlet:namespace />reminders"></div>
			</liferay-ui:panel>

			<liferay-ui:panel collapsible="<%= true %>" defaultState="closed" extended="<%= false %>" id="calendarBookingAssetLinksPanel" persistState="<%= true %>" title="related-assets">
				<liferay-ui:input-asset-links
					className="<%= CalendarBooking.class.getName() %>"
					classPK="<%= calendarBookingId %>"
				/>
			</liferay-ui:panel>
		</liferay-ui:panel-container>
	</aui:fieldset>

	<aui:button-row>
		<aui:button type="submit" />

		<c:if test="<%= calendarBooking != null %>">
			<liferay-security:permissionsURL
				modelResource="<%= CalendarBooking.class.getName() %>"
				modelResourceDescription="<%= calendarBooking.getTitle(locale) %>"
				resourceGroupId="<%= calendarBooking.getGroupId() %>"
				resourcePrimKey="<%= String.valueOf(calendarBooking.getCalendarBookingId()) %>"
				var="permissionsCalendarBookingURL"
			/>

			<aui:button href="<%= permissionsCalendarBookingURL %>" value="permissions" />
		</c:if>
	</aui:button-row>
</aui:form>

<aui:script>
	function <portlet:namespace />filterCalendarBookings(calendarBooking) {
		return <%= calendarBookingId %> !== calendarBooking.calendarBookingId;
	}

	function <portlet:namespace />getSuggestionsContent() {
		return document.<portlet:namespace />fm.<portlet:namespace />title.value + ' ' + window.<portlet:namespace />description.getHTML();
	}

	Liferay.provide(
		window,
		'<portlet:namespace />updateCalendarBooking',
		function() {
			var A = AUI();

			<c:if test="<%= invitable %>">
				var calendarId = A.one('#<portlet:namespace />calendarId').val();
				var childCalendarIds = A.Object.keys(Liferay.CalendarUtil.availableCalendars);

				A.Array.remove(childCalendarIds, A.Array.indexOf(childCalendarIds, calendarId));

				A.one('#<portlet:namespace />childCalendarIds').val(childCalendarIds.join(','));
			</c:if>

			<c:if test="<%= calendarBooking == null %>">
				submitForm(document.<portlet:namespace />fm);
			</c:if>

			<c:if test="<%= (calendarBooking != null) && (calendar != null) %>">
				<c:choose>
					<c:when test="<%= recurring %>">
						Liferay.RecurrenceUtil.openConfirmationPanel(
							'update',
							function() {
								A.one('#<portlet:namespace />updateCalendarBookingInstance').val('true');

								submitForm(document.<portlet:namespace />fm);
							},
							function() {
								A.one('#<portlet:namespace />allFollowing').val('true');
								A.one('#<portlet:namespace />updateCalendarBookingInstance').val('true');

								submitForm(document.<portlet:namespace />fm);
							},
							function() {
								submitForm(document.<portlet:namespace />fm);
							}
						);
					</c:when>
					<c:when test="<%= calendarBooking.isMasterBooking() %>">
						submitForm(document.<portlet:namespace />fm);
					</c:when>
					<c:otherwise>
						var content = [
							'<p class="calendar-portlet-confirmation-text">',
							A.Lang.sub(
								Liferay.Language.get('you-are-about-to-make-changes-that-will-only-affect-your-calendar-x'),
								['<%= HtmlUtil.escapeJS(calendar.getName(locale)) %>']
							),
							'</p>'
						].join('');

						Liferay.CalendarMessageUtil.confirm(
							content,
							'<liferay-ui:message key="save-changes" unicode="<%= true %>" />',
							'<liferay-ui:message key="do-not-change-the-event" unicode="<%= true %>" />',
							function() {
								submitForm(document.<portlet:namespace />fm);

								this.hide();
							},
							function() {
								this.hide();
							}
						);
					</c:otherwise>
				</c:choose>
			</c:if>
		},
		['liferay-calendar-message-util', 'json']
	);

	Liferay.Util.focusFormField(document.<portlet:namespace />fm.<portlet:namespace />title);

	<%
	String titleCurrentValue = ParamUtil.getString(request, "titleCurrentValue");
	%>

	<c:if test="<%= Validator.isNotNull(titleCurrentValue) && (calendarBooking == null || !Validator.equals(titleCurrentValue, calendarBooking.getTitle(locale))) %>">
		document.<portlet:namespace />fm.<portlet:namespace />title.value = '<%= HtmlUtil.escapeJS(titleCurrentValue) %>';
		document.<portlet:namespace />fm.<portlet:namespace />title_<%= themeDisplay.getLanguageId() %>.value = '<%= HtmlUtil.escapeJS(titleCurrentValue) %>';
	</c:if>
</aui:script>

<aui:script use="json,liferay-calendar-date-picker-util,liferay-calendar-list,liferay-calendar-recurrence-util,liferay-calendar-reminders,liferay-calendar-simple-menu">
	var defaultCalendarId = <%= calendarId %>;

	var scheduler = window.<portlet:namespace />scheduler;

	var removeCalendarResource = function(calendarList, calendar, menu) {
		calendarList.remove(calendar);

		if (menu) {
			menu.hide();
		}
	}

	var syncCalendarsMap = function() {
		Liferay.CalendarUtil.syncCalendarsMap(
			[
				window.<portlet:namespace />calendarListAccepted,

				<c:if test="<%= calendarBooking != null %>">
					window.<portlet:namespace />calendarListDeclined,
					window.<portlet:namespace />calendarListMaybe,
				</c:if>

				window.<portlet:namespace />calendarListPending
			]
		);

		A.each(
			Liferay.CalendarUtil.availableCalendars,
			function(item, index) {
				item.set('disabled', true);
			}
		);
	}

	window.<portlet:namespace />toggler = new A.Toggler(
		{
			after: {
				expandedChange: function(event) {
					if (event.newVal) {
						var activeView = scheduler.get('activeView');

						activeView._fillHeight();
					}
				}
			},
			animated: true,
			content: '#<portlet:namespace />schedulerContainer',
			expanded: false,
			header: '#<portlet:namespace />checkAvailability'
		}
	);

	var calendarsMenu = {
		items: [
			{
				caption: '<%= UnicodeLanguageUtil.get(pageContext, "check-availability") %>',
				fn: function(event) {
					var instance = this;

					A.each(
						Liferay.CalendarUtil.availableCalendars,
						function(item, index) {
							item.set('visible', false);
						}
					);

					var calendarList = instance.get('host');

					calendarList.activeItem.set('visible', true);

					<portlet:namespace />toggler.expand();

					instance.hide();

					return false;
				},
				id: 'check-availability'
			}
			<c:if test="<%= invitable %>">
				,{
					caption: '<%= UnicodeLanguageUtil.get(pageContext, "remove") %>',
					fn: function(event) {
						var instance = this;

						var calendarList = instance.get('host');

						removeCalendarResource(calendarList, calendarList.activeItem, instance);
					},
					id: 'remove'
				}
			</c:if>
		],
		<c:if test="<%= invitable %>">
			on: {
				visibleChange: function(event) {
					var instance = this;

					if (event.newVal) {
						var calendarList = instance.get('host');
						var calendar = calendarList.activeItem;

						var hiddenItems = [];

						if (calendar.get('calendarId') === defaultCalendarId) {
							hiddenItems.push('remove');
						}

						instance.set('hiddenItems', hiddenItems);
					}
				}
			}
		</c:if>
	}

	window.<portlet:namespace />calendarListPending = new Liferay.CalendarList(
		{
			after: {
				calendarsChange: function(event) {
					var instance = this;

					A.one('#<portlet:namespace />pendingCounter').html(event.newVal.length);

					syncCalendarsMap();

					scheduler.load();
				},
				'scheduler-calendar:visibleChange': syncCalendarsMap
			},
			boundingBox: '#<portlet:namespace />calendarListPending',
			calendars: <%= pendingCalendarsJSONArray %>,
			scheduler: <portlet:namespace />scheduler,
			simpleMenu: calendarsMenu,
			strings: {
				emptyMessage: '<liferay-ui:message key="no-pending-invites" />'
			}
		}
	).render();

	window.<portlet:namespace />calendarListAccepted = new Liferay.CalendarList(
		{
			after: {
				calendarsChange: function(event) {
					var instance = this;

					A.one('#<portlet:namespace />acceptedCounter').html(event.newVal.length);

					syncCalendarsMap();

					scheduler.load();
				},
				'scheduler-calendar:visibleChange': syncCalendarsMap
			},
			boundingBox: '#<portlet:namespace />calendarListAccepted',
			calendars: <%= acceptedCalendarsJSONArray %>,
			scheduler: <portlet:namespace />scheduler,
			simpleMenu: calendarsMenu,
			strings: {
				emptyMessage: '<liferay-ui:message key="no-accepted-invites" />'
			}
		}
	).render();

	<c:if test="<%= calendarBooking != null %>">
		window.<portlet:namespace />calendarListDeclined = new Liferay.CalendarList(
			{
				after: {
					calendarsChange: function(event) {
						var instance = this;

						A.one('#<portlet:namespace />declinedCounter').html(event.newVal.length);

						syncCalendarsMap();

						scheduler.load();
					},
					'scheduler-calendar:visibleChange': syncCalendarsMap
				},
				boundingBox: '#<portlet:namespace />calendarListDeclined',
				calendars: <%= declinedCalendarsJSONArray %>,
				scheduler: <portlet:namespace />scheduler,
				simpleMenu: calendarsMenu,
				strings: {
					emptyMessage: '<liferay-ui:message key="no-declined-invites" />'
				}
			}
		).render();

		window.<portlet:namespace />calendarListMaybe = new Liferay.CalendarList(
			{
				after: {
					calendarsChange: function(event) {
						var instance = this;

						A.one('#<portlet:namespace />maybeCounter').html(event.newVal.length);

						syncCalendarsMap();

						scheduler.load();
					},
					'scheduler-calendar:visibleChange': syncCalendarsMap
				},
				boundingBox: '#<portlet:namespace />calendarListMaybe',
				calendars: <%= maybeCalendarsJSONArray %>,
				scheduler: <portlet:namespace />scheduler,
				simpleMenu: calendarsMenu,
				strings: {
					emptyMessage: '<liferay-ui:message key="no-outstanding-invites" />'
				}
			}
		).render();
	</c:if>

	syncCalendarsMap();

	var formNode = A.one(document.<portlet:namespace />fm);

	window.<portlet:namespace />placeholderSchedulerEvent = new Liferay.SchedulerEvent(
		{
			after: {
				endDateChange: function(event) {
					Liferay.DatePickerUtil.syncUI(formNode, 'endTime', event.newVal);
				},
				startDateChange: function(event) {
					Liferay.DatePickerUtil.syncUI(formNode, 'startTime', event.newVal);
				}
			},
			borderColor: '#000',
			borderStyle: 'dashed',
			borderWidth: '2px',
			color: '#F8F8F8',
			content: '&nbsp;',
			editingEvent: true,
			endDate: Liferay.CalendarUtil.toLocalTime(new Date(<%= endTime %>)),
			on: {
				endDateChange: function(event) {
					event.stopPropagation();
				},
				startDateChange: function(event) {
					event.stopPropagation();
				}
			},
			preventDateChange: true,
			scheduler: scheduler,
			startDate: Liferay.CalendarUtil.toLocalTime(new Date(<%= startTime %>))
		}
	);

	Liferay.DatePickerUtil.linkToSchedulerEvent('#<portlet:namespace />endDateContainer', window.<portlet:namespace />placeholderSchedulerEvent, 'endTime');
	Liferay.DatePickerUtil.linkToSchedulerEvent('#<portlet:namespace />startDateContainer', window.<portlet:namespace />placeholderSchedulerEvent, 'startTime');

	scheduler.after(
		'*:load',
		function(event) {
			scheduler.addEvents(window.<portlet:namespace />placeholderSchedulerEvent);

			scheduler.syncEventsUI();
		}
	);

	<c:if test="<%= invitable %>">
		A.one('#<portlet:namespace />calendarId').on(
			'valueChange',
			function(event) {
				var calendarId = parseInt(event.target.val(), 10);
				var calendarJSON = Liferay.CalendarUtil.manageableCalendars[calendarId];

				A.Array.each(
					[
						<portlet:namespace />calendarListAccepted,

						 <c:if test="<%= calendarBooking != null %>">
							<portlet:namespace />calendarListDeclined, <portlet:namespace />calendarListMaybe,
						 </c:if>

						 <portlet:namespace />calendarListPending
					],
					function(calendarList) {
						calendarList.remove(calendarList.getCalendar(calendarId));
						calendarList.remove(calendarList.getCalendar(defaultCalendarId));
					}
				);

				<portlet:namespace />calendarListPending.add(calendarJSON);

				defaultCalendarId = calendarId;
			}
		);

		var inviteResourcesInput = A.one('#<portlet:namespace />inviteResource');

		<liferay-portlet:resourceURL copyCurrentRenderParameters="<%= false %>" id="calendarResources" var="calendarResourcesURL"></liferay-portlet:resourceURL>

		Liferay.CalendarUtil.createCalendarsAutoComplete(
			'<%= calendarResourcesURL %>',
			inviteResourcesInput,
			function(event) {
				var calendar = event.result.raw;

				calendar.disabled = true;

				<portlet:namespace />calendarListPending.add(calendar);

				inviteResourcesInput.val('');
			}
		);
	</c:if>

	window.<portlet:namespace />reminders = new Liferay.Reminders(
		{
			portletNamespace: '<portlet:namespace />',
			render: '#<portlet:namespace />reminders',
			values: [
				{
					interval: <%= firstReminder %>,
					type: '<%= HtmlUtil.escapeJS(firstReminderType) %>'
				},
				{
					interval: <%= secondReminder %>,
					type: '<%= HtmlUtil.escapeJS(secondReminderType) %>'
				}
			]
		}
	);

	var allDayCheckbox = A.one('#<portlet:namespace />allDayCheckbox');

	allDayCheckbox.after(
		'click',
		function() {
			var endDateContainer = A.one('#<portlet:namespace />endDateContainer');
			var startDateContainer = A.one('#<portlet:namespace />startDateContainer');

			var checked = allDayCheckbox.get('checked');

			if (checked) {
				window.<portlet:namespace />placeholderSchedulerEvent.set('allDay', true);
			}
			else {
				window.<portlet:namespace />placeholderSchedulerEvent.set('allDay', false);

				endDateContainer.show();
			}

			endDateContainer.toggleClass('allday-class-active', checked);
			startDateContainer.toggleClass('allday-class-active', checked);

			scheduler.syncEventsUI();
		}
	);

	scheduler.load();
</aui:script>