<%@ page import="com.liferay.portal.service.LayoutLocalServiceUtil" %>
<%@ page import="com.liferay.portal.model.LayoutTypePortlet" %>
<%@ page import="com.liferay.portal.model.Layout" %>
<%@ page import="java.util.Map" %>
<%@page import="java.net.URLEncoder" %>
<%@page import="java.net.URL" %>
<%@page import="java.net.URI" %>

<%
String backURL = ParamUtil.getString(request, "backURL");

CalendarBooking calendarBooking = (CalendarBooking)request.getAttribute(WebKeys.CALENDAR_BOOKING);

int instanceIndex = BeanParamUtil.getInteger(calendarBooking, request, "instanceIndex");

calendarBooking = RecurrenceUtil.getCalendarBookingInstance(calendarBooking, instanceIndex);

Calendar calendar = calendarBooking.getCalendar();

long startTime = calendarBooking.getStartTime();

java.util.Calendar startTimeJCalendar = JCalendarUtil.getJCalendar(startTime, userTimeZone);

long endTime = calendarBooking.getEndTime();

java.util.Calendar endTimeJCalendar = JCalendarUtil.getJCalendar(endTime, userTimeZone);

boolean allDay = BeanParamUtil.getBoolean(calendarBooking, request, "allDay");

AssetEntry layoutAssetEntry = AssetEntryLocalServiceUtil.getEntry(CalendarBooking.class.getName(), calendarBooking.getCalendarBookingId());

final long parentCalendarBookingId = calendarBooking.getParentCalendarBookingId();
final long calendarBookingId = calendarBooking.getCalendarBookingId();

// Get surveyId attached to event
String surveyId = (String) calendarBooking.getExpandoBridge().getAttribute("surveyId");
if (calendarBookingId != parentCalendarBookingId) {
	final CalendarBooking parentCalendarBooking = CalendarBookingLocalServiceUtil.getCalendarBooking(parentCalendarBookingId);
	surveyId = (String) parentCalendarBooking.getExpandoBridge().getAttribute("surveyId");
}

// Get associated files
Map<String, String> entries = (Map) request.getAttribute("calendarBookingEntries");

String endTimeDay = endTimeJCalendar.get(java.util.Calendar.DAY_OF_YEAR) + "";
String endTimeHour = endTimeJCalendar.get(java.util.Calendar.HOUR_OF_DAY) + "";
String endTimeMinute = endTimeJCalendar.get(java.util.Calendar.MINUTE) + "";
int endTimeMonthTmp  = endTimeJCalendar.get(java.util.Calendar.MONTH) + 2;
String endTimeMonth = endTimeMonthTmp + "";
String endTimeYear = (endTimeJCalendar.get(java.util.Calendar.YEAR) - 1) + "";
String startTimeDay = startTimeJCalendar.get(java.util.Calendar.DAY_OF_YEAR) + "";
String startTimeHour = startTimeJCalendar.get(java.util.Calendar.HOUR_OF_DAY) + "";
String startTimeMinute = startTimeJCalendar.get(java.util.Calendar.MINUTE) + "";
int startTimeMonthTmp = startTimeJCalendar.get(java.util.Calendar.MONTH) + 2;
String startTimeMonth = startTimeMonthTmp  + "";
String startTimeYear = (startTimeJCalendar.get(java.util.Calendar.YEAR) - 1) + "";
String calendarBookingTitle = calendarBooking.getTitle(locale).replace("'","\\'");

%>

<aui:fieldset>

	<div id="event-detail" class="fLeft">
		<div class="fLeft event-detail-title width100" id="event-detail-title">
			<%= calendarBooking.getTitle(locale) %>
		</div>
		<div class="fLeft h30 width100" id="event-detail-startdate-zone">
			<span class="fLeft pT2">Du</span>
			<span class="fLeft pT2 event-detail-detail" id="event-detail-startdate">
				<%= dateFormatLongDate.format(startTimeJCalendar.getTime()) %>&nbsp;&agrave;&nbsp;<%= hourFormat.format(startTimeJCalendar.getTime()) %>h<%= minuteFormat.format(startTimeJCalendar.getTime()) %>
			</span>
		</div>
		<div class="fLeft h30 width100" id="event-detail-enddate-zone">
			<span class="fLeft pT2">Au</span>
			<span class="fLeft pT2 event-detail-detail" id="event-detail-enddate">
				<%= dateFormatLongDate.format(endTimeJCalendar.getTime()) %>&nbsp;&agrave;&nbsp;<%= hourFormat.format(endTimeJCalendar.getTime()) %>h<%= minuteFormat.format(endTimeJCalendar.getTime()) %>
			</span>
		</div>
		<div class="fLeft width100" id="event-detail-location-zone">
			<span class="fLeft pT2">Emplacement&nbsp;:</span>
			<span class="fLeft pT2 event-detail-detail location-zone" id="event-detail-location">
				<%= HtmlUtil.escape(calendarBooking.getLocation()) %>
			</span>
		</div>
		<div class="fLeft width100 pT5" id="event-detail-description-zone">
			<span class="fLeft pT2">Description&nbsp;:</span>
			<span class="fLeft pT2 event-detail-detail description-zone" id="event-detail-description">
				<%= calendarBooking.getDescription(locale) %>
			</span>
		</div>
		<div class="fLeft" id="event-detail-related-asset-zone">
			<span class="fLeft width100">Document(s) joint(s)&nbsp;:</span>
			<span class="fLeft pT2" id="event-detail-related-asset">
				<% for (Map.Entry<String, String> entry : entries.entrySet()) { %>
					<div class="width100 fLeft"><a href="<%= entry.getValue() %>" target="_blank"><%= entry.getKey() %></a></div>
				<% } %>
			</span>
		</div>
		<div class="fLeft pT5 width100" id="event-detail-more-zone">
			<% final String organizerEmailAddress = UserLocalServiceUtil.getUser(calendarBooking.getUserId()).getEmailAddress(); %>
			En cas de questions compl&eacute;mentaires, contactez <span id="event-detail-more-info"><a href="mailto:<%=organizerEmailAddress%>?subject=Cristal Union Espace Elus - Questions"><%=organizerEmailAddress%></a></span>
		</div>
		
		<div class="fLeft pT5 h35 width100 hide" id="event-detail-invitees-zone">
			<span class="fLeft pT2" style="width:50px;">Invités&nbsp;:</span>
			<span class="fLeft pT2 invitees-zone" id="event-detail-invitees"></span>
		</div>
		<c:if test="<%= isGestionnaireGlobal || isGestionnaireSection || permissionChecker.isOmniadmin() %>">
			<div class="fLeft h30 mT25 width100" id="event-detail-actions">
				<span>
						<button class="presence fLeft" id="event-detail-edit" name="event-detail-edit" value="edit">Modifier</button>
						<button class="presence fLeft" id="event-detail-delete" name="event-detail-delete" value="delete">Supprimer</button>
				</span>
			</div>
			
			<portlet:renderURL var="editCalendarBookingURL" windowState="<%= LiferayWindowState.POP_UP.toString() %>">
				<portlet:param name="mvcPath" value="/edit_calendar_booking.jsp" />
				<portlet:param name="activeView" value="<%=activeView%>" />
				<portlet:param name="allDay" value='<%= calendarBooking.isAllDay() + "" %>' />
				<portlet:param name="calendarBookingId" value='<%=calendarBookingId + ""%>' />
				<portlet:param name="calendarId" value='<%=calendar.getCalendarId() + ""%>' />
				<portlet:param name="date" value='<%=date + ""%>' />
				<portlet:param name="endTimeDay" value="<%=endTimeDay%>" />
				<portlet:param name="endTimeHour" value="<%=endTimeHour%>" />
				<portlet:param name="endTimeMinute" value="<%=endTimeMinute%>" />
				<portlet:param name="endTimeMonth" value="<%=endTimeMonth%>" />
				<portlet:param name="endTimeYear" value="<%=endTimeYear%>" />
				<portlet:param name="instanceIndex" value='<%=instanceIndex + ""%>' />
				<portlet:param name="startTimeDay" value="<%=startTimeDay%>" />
				<portlet:param name="startTimeHour" value="<%=startTimeHour%>" />
				<portlet:param name="startTimeMinute" value="<%=startTimeMinute%>" />
				<portlet:param name="startTimeMonth" value="<%=startTimeMonth%>" />
				<portlet:param name="startTimeYear" value="<%=startTimeYear%>" />
				<portlet:param name="titleCurrentValue" value="<%=calendarBookingTitle%>" />
			</portlet:renderURL>
			
			<%= "MONTH START DATE : " + startTimeMonth %><%= "----" %>
			
			<%
			
			URL url = new URL(editCalendarBookingURL);
			URI uri = new URI(url.getProtocol(), url.getUserInfo(), url.getHost(), url.getPort(), url.getPath(), url.getQuery(), url.getRef());
			url = uri.toURL();
			
			%>
			<aui:script use="aui-base">
				var editCalendarBookingElement = A.one('#event-detail-edit');
				editCalendarBookingElement.on(
					'click',
					function(event) {
						Liferay.Util.openWindow(
							{
								dialog: {
									after: {
										destroy: function(event) {
											document.location.href = "<%= currentURL %>";
										}
									},
									destroyOnHide: true,
									modal: true
								},
								refreshWindow: window,
								title: Liferay.Language.get('edit-calendar-booking'),
								uri: '<%= editCalendarBookingURL %>'
							}
						);
					}
				);
			</aui:script>
		</c:if>
		
		<div class="entry-categories">
			<liferay-ui:asset-categories-summary
				className="<%= CalendarBooking.class.getName() %>"
				classPK="<%= calendarBooking.getCalendarBookingId() %>"
			/>
		</div>
	
		<div class="entry-tags">
			<liferay-ui:asset-tags-summary
				className="<%= CalendarBooking.class.getName() %>"
				classPK="<%= calendarBooking.getCalendarBookingId() %>"
				message="tags"
			/>
		</div>
	</div>

</aui:fieldset>

<div id="event-questionnaire">
	<liferay-portlet:renderURL windowState="exclusive" portletName="<%= questionnairePortletId %>" var="url1">
		<liferay-portlet:param name="action" value="showQuestionsForUserForm"/>
		<liferay-portlet:param name="surveyID" value="<%= surveyId %>"/>
		<liferay-portlet:param name="redirect" value="<%= currentURL %>"/>
	</liferay-portlet:renderURL>
	<liferay-portlet:renderURL windowState="exclusive" portletName="<%= questionnairePortletId %>" var="url2">
		<liferay-portlet:param name="action" value="showQuestionsForUserForm"/>
		<liferay-portlet:param name="surveyID" value="<%= surveyId %>"/>
		<liferay-portlet:param name="redirect" value="<%= currentURL %>"/>
		<liferay-portlet:param name="update" value="update"/>
	</liferay-portlet:renderURL>
	<div id="event-questionnaire-questions" class="fLeft wdith100"></div>
	<div style="clear:both;"></div>
	<button class="fLeft presence" id="event-questionnaire-edit" name="event-questionnaire-edit" value="edit-questionnaire">Modifier</button>
</div>
<div style="clear:both;"></div>

<aui:script>
	function <portlet:namespace />invokeTransition(status) {
		document.<portlet:namespace />fm.<portlet:namespace />status.value = status;

		submitForm(document.<portlet:namespace />fm);
	}
</aui:script>

<aui:script use="aui-io-request">
	function getQuestionnaire(update) {
		var ajaxUrl;
		if (!update) {
	    	ajaxUrl = '<%= url1 %>';
	    } else {
	    	ajaxUrl = '<%= url2 %>';
	    }
	    
	    ajaxUrl = ajaxUrl.replace('/c/portal/layout', '<%= questionnairePortletFriendlyURL %>');
	    ajaxUrl = ajaxUrl.replace('/user/<%= currentUser.getScreenName() %>/home', '<%= questionnairePortletFriendlyURL %>');
	    ajaxUrl = ajaxUrl.replace('/mes-rendez-vous', '<%= questionnairePortletFriendlyURL %>');

	    A.io.request(
			ajaxUrl,
			{
				dataType: 'html',
				on: {
					success: function() {
						document.getElementById('event-questionnaire-questions').innerHTML = this.get('responseData');
						// Edit questionnaire button
						if (document.getElementById('event-questionnaire-submit')) {
							document.getElementById('event-questionnaire-edit').style.display = 'none';
						} else {
							document.getElementById('event-questionnaire-edit').style.display = 'block';
						}
					}
				},
				sync: true
			}
	    );
	}
	getQuestionnaire(false);
	var editQuestionnaireNode = A.one('#event-questionnaire-edit');
	editQuestionnaireNode.on(
		'click',
		function(event) {
			getQuestionnaire(true);
			editQuestionnaireNode.toggleClass('hide');
		}
	);
	<% if (java.util.Calendar.getInstance().after(startTimeJCalendar)) { %>
		if (document.getElementById('event-questionnaire-submit')) {
			document.getElementById('event-questionnaire-submit').style.display = 'none';
		}
		document.getElementById('event-questionnaire-edit').style.display = 'none';
	<% } %>
</aui:script>

<c:if test="<%= calendarBooking.isRecurring() %>">
	<aui:script use="liferay-calendar-recurrence-util">
		var summaryNode = A.one('#<portlet:namespace />recurrenceSummary');

		var endValue = 'never';
		var untilDate = null;

		<%
		Recurrence recurrence = calendarBooking.getRecurrenceObj();

		java.util.Calendar untilJCalendar = recurrence.getUntilJCalendar();
		%>

		<c:choose>
			<c:when test="<%= (untilJCalendar != null) %>">
				endValue = 'on';

				untilDate = new Date('<%= dateFormatLongDate.format(untilJCalendar.getTimeInMillis()) %>');
			</c:when>
			<c:when test="<%= (recurrence.getCount() > 0) %>">
				endValue = 'after';
			</c:when>
		</c:choose>

		<%
		JSONSerializer jsonSerializer = JSONFactoryUtil.createJSONSerializer();

		List<Weekday> weekdays = new ArrayList<Weekday>();

		for (PositionalWeekday positionalWeekday : recurrence.getPositionalWeekdays()) {
			weekdays.add(positionalWeekday.getWeekday());
		}
		%>

		var recurrence = {
			count: <%= recurrence.getCount() %>,
			endValue: endValue,
			frequency: '<%= String.valueOf(recurrence.getFrequency()) %>',
			interval: <%= recurrence.getInterval() %>,
			untilDate: untilDate,
			weekdays: <%= jsonSerializer.serialize(weekdays) %>
		}

		var recurrenceSummary = Liferay.RecurrenceUtil.getSummary(recurrence);

		summaryNode.html(recurrenceSummary);
	</aui:script>
</c:if>