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
<%@ page import="com.liferay.portal.service.LayoutLocalServiceUtil" %>
<%@ page import="com.liferay.portal.model.LayoutTypePortlet" %>
<%@ page import="com.liferay.portal.model.Layout" %>

<%

User currentUser = (User) request.getAttribute("USER");

long currentUserId = currentUser.getUserId();
boolean isGestionnaireGlobal = UserGroupRoleLocalServiceUtil.hasUserGroupRole(currentUserId, themeDisplay.getScopeGroupId(), "gestionnaire-global", false);
boolean isGestionnaireSection = UserGroupRoleLocalServiceUtil.hasUserGroupRole(currentUserId, themeDisplay.getScopeGroupId(), "gestionnaire-section", false);
boolean isPresidentCUN = UserGroupRoleLocalServiceUtil.hasUserGroupRole(currentUserId, themeDisplay.getScopeGroupId(), "president-cun", false);

//Questionnaire Portlet Id
final String questionnairePortletId = "igiTakeSurvey_WAR_QuestionnairePortlet";
//Get url  to Questionnaire portlet dynamically
final List<Layout> playouts = LayoutLocalServiceUtil.getLayouts(-1, -1);
String questionnairePortletFriendlyURL = null;
for (final Layout lay: playouts){
	final Layout playout = LayoutLocalServiceUtil.getLayout(lay.getPlid());
	final LayoutTypePortlet playoutTypePortlet = (LayoutTypePortlet)playout.getLayoutType();
	final List <String> pallPortletIds = playoutTypePortlet.getPortletIds();
	if(pallPortletIds.contains(questionnairePortletId)){
		questionnairePortletFriendlyURL = lay.getFriendlyURL(themeDisplay.getLocale());
		break;
	}
}
%>

<input type="hidden" id="questionnairePortletFriendlyURL" name="questionnairePortletFriendlyURL" value="<%= questionnairePortletFriendlyURL %>" />

<%@ include file="./internal_view_calendar_booking.jsp" %>