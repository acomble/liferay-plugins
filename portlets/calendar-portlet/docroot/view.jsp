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
String tabs1 = ParamUtil.getString(request, "tabs1", "calendar");

PortletURL portletURL = renderResponse.createRenderURL();

portletURL.setParameter("tabs1", tabs1);


User currentUser = PortalUtil.getUser(request);
long currentUserId = currentUser.getUserId();
boolean isGestionnaireGlobal = UserGroupRoleLocalServiceUtil.hasUserGroupRole(currentUserId, themeDisplay.getScopeGroupId(), "gestionnaire-global", false);
boolean isGestionnaireSection = UserGroupRoleLocalServiceUtil.hasUserGroupRole(currentUserId, themeDisplay.getScopeGroupId(), "gestionnaire-section", false);
boolean isPresidentCUN = UserGroupRoleLocalServiceUtil.hasUserGroupRole(currentUserId, themeDisplay.getScopeGroupId(), "president-cun", false);
boolean isGestionnaireCUN = UserGroupRoleLocalServiceUtil.hasUserGroupRole(currentUserId, themeDisplay.getScopeGroupId(), "gestionnaire-cun", false);

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

<c:if test="<%= isGestionnaireGlobal || isGestionnaireSection || permissionChecker.isOmniadmin() || isPresidentCUN || isGestionnaireCUN %>">
<div id="<portlet:namespace/>main" class="aqua" style="background:none; margin-bottom: 20px;">
	<div id="mainContainer">
		<a href="<%= questionnairePortletFriendlyURL %>" class="portlet-title-spec" style="background-color: #FF9966 !important; text-align: center;width: 80%;	display:block;	color:#FFF;">
			Administrer les formulaires
		</a>
	</div> 
</div>
</c:if>

<span class="aqua" style="color:#77b800 !important;">
	<h1 class="portlet-title-spec">Mes rendez-vous</h1>
	<span class="tgl"></span>
</span> 
<div class="alert alert-success hide" id="<portlet:namespace />alert">
	<button class="close" data-dismiss="alert" type="button">&times;</button>

	<span class="message-placeholder"></span>
</div>


<c:if test="<%= themeDisplay.isSignedIn() %>">
	<liferay-ui:tabs
		names="calendar"
		url="<%= portletURL.toString() %>"
	/>
</c:if>

<c:choose>
	<c:when test='<%= tabs1.equals("calendar") %>'>
		<liferay-util:include page="/view_calendar.jsp" servletContext="<%= application %>" />
	</c:when>
	<c:when test='<%= tabs1.equals("resources") %>'>
		<liferay-util:include page="/view_calendar_resources.jsp" servletContext="<%= application %>" />
	</c:when>
</c:choose>
