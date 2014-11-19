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

<%@ page import="com.liferay.portlet.asset.service.AssetLinkLocalServiceUtil" %>
<%@ page import="com.liferay.portlet.asset.model.AssetLink" %>
<%@ page import="com.liferay.portlet.asset.AssetRendererFactoryRegistryUtil" %>
<%@ page import="com.liferay.portlet.asset.model.AssetRendererFactory" %>
<%@ page import="com.liferay.portlet.asset.model.AssetRenderer" %>

<%@ page import="com.liferay.calendar.util.SurveyUtil" %>

<%@ page import="com.liferay.portal.kernel.util.PropsUtil" %>
<%@ page import="com.liferay.portal.util.PortletKeys" %>
<%@ page import="com.liferay.portal.util.PortalUtil" %>

<%@ page import="com.liferay.portal.model.Layout" %>
<%@ page import="com.liferay.portal.service.LayoutLocalServiceUtil" %>
<%@ page import="com.liferay.portlet.PortletURLFactoryUtil" %>

<%@ page import="javax.portlet.PortletRequest" %>
<%@ page import="javax.portlet.WindowState" %>
<%@ page import="javax.portlet.PortletMode" %>



	<%
	int assetEntryIndex = ((Integer)request.getAttribute("view.jsp-assetEntryIndex")).intValue();
	
	final User currentUser = PortalUtil.getUser(request);
	final String currentUserFullName = currentUser.getFullName();

	final String mesDocumentsURL = PropsUtil.get("espace.elus.mes.documents.url");
	
	final CalendarBooking calendarBooking = (CalendarBooking)request.getAttribute(WebKeys.CALENDAR_BOOKING);

	final Calendar calendar = calendarBooking.getCalendar();
	
	final String location = calendarBooking.getLocation();
	
	final AssetEntry layoutAssetEntry = AssetEntryLocalServiceUtil.getEntry(CalendarBooking.class.getName(), calendarBooking.getCalendarBookingId());
	final long assetEntryId = layoutAssetEntry.getEntryId();
	
	final String className = PortalUtil.getClassName(layoutAssetEntry.getClassNameId());
	final AssetRendererFactory assetRendererFactory = AssetRendererFactoryRegistryUtil.getAssetRendererFactoryByClassName(className);
	final AssetRenderer assetRenderer = assetRendererFactory.getAssetRenderer(layoutAssetEntry.getClassPK());
	
	java.util.Calendar startTimeJCalendar = JCalendarUtil.getJCalendar(calendarBooking.getStartTime(), user.getTimeZone());
	
	boolean allAnswered = false;
	final String surveyId = (String)calendarBooking.getExpandoBridge().getAttribute("surveyId");
	if (surveyId != null && !surveyId.isEmpty()) {
		allAnswered = SurveyUtil.hasAnsweredAllQuestions(Integer.parseInt(surveyId), currentUserFullName);
	}
	
	final Integer nbDaysHurryUp =  (Integer)calendarBooking.getExpandoBridge().getAttribute("NbDaysHurryUp");
	int diffInDays = (int)( (java.util.Calendar.getInstance().getTimeInMillis() - startTimeJCalendar.getTimeInMillis()) / (1000 * 60 * 60 * 24) );

	PortletURL portletURL = null;
	final List<AssetLink> assetLinks = AssetLinkLocalServiceUtil.getDirectLinks(assetEntryId);
	if (assetLinks != null && assetLinks.size() > 0) { 
		AssetEntry assetLinkEntry;
		if (assetLinks.get(0).getEntryId1() == assetEntryId) {
			assetLinkEntry = AssetEntryLocalServiceUtil.getEntry(assetLinks.get(0).getEntryId2());
		}
		else {
			assetLinkEntry = AssetEntryLocalServiceUtil.getEntry(assetLinks.get(0).getEntryId1());
		}
		assetLinkEntry = assetLinkEntry.toEscapedModel();
		final Layout layout2 = LayoutLocalServiceUtil.getFriendlyURLLayout(themeDisplay.getLayout().getGroupId(), false, (mesDocumentsURL == null || mesDocumentsURL.isEmpty()) ? "/mes-documents" : mesDocumentsURL);
		portletURL = PortletURLFactoryUtil.create(request, PortletKeys.DOCUMENT_LIBRARY_DISPLAY, layout2.getPlid(), PortletRequest.RENDER_PHASE);
		portletURL.setWindowState(WindowState.MAXIMIZED);
		portletURL.setPortletMode(PortletMode.VIEW);
		portletURL.setParameter("struts_action", "document_library_display/view_file_entry");
		portletURL.setParameter("fileEntryId", String.valueOf(assetLinkEntry.getClassPK()));
		portletURL.setParameter("redirect", currentURL);
	
	}
	
	String cssClass = "";
	if (assetEntryIndex % 2 == 0) {
		cssClass = "yui-dt-even";
	}
	
	%>
	
	<tr class="<%= cssClass %>" style="border: 1px solid #ccc;border-bottom: 0px;font-weight: bold;">
		<td data-id="event-picto" style="width: 7% !important;"><img alt="" src="<%= assetRenderer.getIconPath(renderRequest) %>" /></td>
		<td data-id="event-title" style="width: 70% !important;text-align: left;"><%= HtmlUtil.escape(calendarBooking.getTitle(locale)) %></td>
		<td data-id="event-file" style="width: 7% !important;">
			<% if (portletURL != null) { %>
			<div title="Voir le document joint" onclick="javascript:document.location.href='<%= portletURL %>';" class="picto-file-pdf"></div>
			<% } %>
		</td>
		<td data-id="event-questionnaire" style="width: 7% !important;">
			<% if (allAnswered) {%>
			<div title="Vous avez répondu au questionnaire" class="picto-answered"></div>
			<% } else { %>
				<% if (java.util.Calendar.getInstance().before(startTimeJCalendar) && diffInDays <= nbDaysHurryUp) { %>
				<div title="Vous n'avez pas répondu au questionnaire" class="picto-urgent"></div>
				<% } %>
				<% if (java.util.Calendar.getInstance().before(startTimeJCalendar) && diffInDays <= nbDaysHurryUp) { %>
				<div title="Vous n'avez pas répondu au questionnaire" class="picto-nonanswered"></div>
				<% } %>
				<% if (java.util.Calendar.getInstance().after(startTimeJCalendar)) { %>
					B
				<% } %>
			<% } %>
		</td>
	</tr>
	<tr class="<%= cssClass %>" style="border-left: 1px solid #ccc; border-right: 1px solid #ccc;border-bottom: 1px solid #ccc;">
		<td colspan="4" data-id="event-date" style="padding-left: 10px; text-align: left;">
			<%= dateFormatLongDate.format(startTimeJCalendar.getTime()) + " &agrave; " + hourFormat.format(startTimeJCalendar.getTime()) + "h" + minuteFormat.format(startTimeJCalendar.getTime()) %>
			<% if (location != null && !location.equals("")) { %>
				&agrave;
				<%= location %>
			<% } %>
		</td>
	</tr>
