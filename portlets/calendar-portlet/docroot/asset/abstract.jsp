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



<div>

	<%
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
	
	%>
	
	<div class="asset-title fLeft width100">
		<div class="fLeft"><img alt="" src="<%= assetRenderer.getIconPath(renderRequest) %>" /></div>
		<div class="fLeft mL5"><%= HtmlUtil.escape(calendarBooking.getTitle(locale)) %></div>			
	
		<% final List<AssetLink> assetLinks = AssetLinkLocalServiceUtil.getDirectLinks(assetEntryId); %>
		<% if (assetLinks != null && assetLinks.size() > 0) { 
			AssetEntry assetLinkEntry;
			if (assetLinks.get(0).getEntryId1() == assetEntryId) {
				assetLinkEntry = AssetEntryLocalServiceUtil.getEntry(assetLinks.get(0).getEntryId2());
			}
			else {
				assetLinkEntry = AssetEntryLocalServiceUtil.getEntry(assetLinks.get(0).getEntryId1());
			}
			assetLinkEntry = assetLinkEntry.toEscapedModel();
			final Layout layout2 = LayoutLocalServiceUtil.getFriendlyURLLayout(themeDisplay.getLayout().getGroupId(), false, (mesDocumentsURL == null || mesDocumentsURL.isEmpty()) ? "/mes-documents" : mesDocumentsURL);
			final PortletURL portletURL = PortletURLFactoryUtil.create(request, PortletKeys.DOCUMENT_LIBRARY_DISPLAY, layout2.getPlid(), PortletRequest.RENDER_PHASE);
			portletURL.setWindowState(WindowState.MAXIMIZED);
			portletURL.setPortletMode(PortletMode.VIEW);
			portletURL.setParameter("struts_action", "document_library_display/view_file_entry");
			portletURL.setParameter("fileEntryId", String.valueOf(assetLinkEntry.getClassPK()));
			portletURL.setParameter("redirect", currentURL);
		
		%>
			<div title="Voir le document joint" onclick="javascript:document.location.href='<%= portletURL %>';" class="fLeft picto-file-pdf"></div>
		<%}%>
		
		<%
		
		final String surveyId = (String)calendarBooking.getExpandoBridge().getAttribute("surveyId");
		if (surveyId != null && !surveyId.isEmpty()) {
			final boolean allAnswered = SurveyUtil.hasAnsweredAllQuestions(Integer.parseInt(surveyId), currentUserFullName);
			if (allAnswered) {
				%><div title="Vous avez répondu au questionnaire" class="fLeft picto-answered"></div><%
			} else {
				%><div title="Vous n'avez pas répondu au questionnaire" class="fLeft picto-nonanswered"></div><%
			}
		%>
		<%}%>
	
	</div>
	
	<div class="width100 asset-calendar-zone">
		<liferay-ui:icon
			image="../common/user_icon"
			message=""
		/>

		<strong><%= HtmlUtil.escape(calendar.getName(locale)) %></strong>
		
	</div>

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