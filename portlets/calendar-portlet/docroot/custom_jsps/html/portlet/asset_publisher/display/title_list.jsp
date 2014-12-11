<%--
/**
 * Copyright (c) 2000-2013 Liferay, Inc. All rights reserved.
 *
 * The contents of this file are subject to the terms of the Liferay Enterprise
 * Subscription License ("License"). You may not use this file except in
 * compliance with the License. You can obtain a copy of the License by
 * contacting Liferay, Inc. See the License for the specific language governing
 * permissions and limitations under the License, including but not limited to
 * distribution rights of the Software.
 *
 *
 *
 */
--%>

<%@ include file="/html/portlet/asset_publisher/init.jsp" %>

<%@page import="java.net.URL" %>
<%@page import="java.net.URI" %>

<%@page import="com.liferay.portlet.documentlibrary.model.DLFileEntry" %>
<%@page import="com.liferay.portal.kernel.repository.model.FileEntry" %>
<%@page import="com.liferay.portlet.documentlibrary.service.DLFileEntryLocalServiceUtil" %>
<%@page import="com.liferay.portlet.documentlibrary.util.DLUtil" %>
<%@page import="com.liferay.portlet.documentlibrary.service.DLAppLocalServiceUtil" %>

<%
List results = (List)request.getAttribute("view.jsp-results");

int assetEntryIndex = ((Integer)request.getAttribute("view.jsp-assetEntryIndex")).intValue();

AssetEntry assetEntry = (AssetEntry)request.getAttribute("view.jsp-assetEntry");
AssetRendererFactory assetRendererFactory = (AssetRendererFactory)request.getAttribute("view.jsp-assetRendererFactory");
AssetRenderer assetRenderer = (AssetRenderer)request.getAttribute("view.jsp-assetRenderer");

String title = (String)request.getAttribute("view.jsp-title");

if (Validator.isNull(title)) {
	title = assetRenderer.getTitle(locale);
}

boolean show = ((Boolean)request.getAttribute("view.jsp-show")).booleanValue();

request.setAttribute("view.jsp-showIconLabel", false);

PortletURL viewFullContentURL = renderResponse.createRenderURL();

viewFullContentURL.setParameter("struts_action", "/asset_publisher/view_content");
viewFullContentURL.setParameter("assetEntryId", String.valueOf(assetEntry.getEntryId()));
viewFullContentURL.setParameter("type", assetRendererFactory.getType());

if (Validator.isNotNull(assetRenderer.getUrlTitle())) {
	if (assetRenderer.getGroupId() != scopeGroupId) {
		viewFullContentURL.setParameter("groupId", String.valueOf(assetRenderer.getGroupId()));
	}

	viewFullContentURL.setParameter("urlTitle", assetRenderer.getUrlTitle());
}

String viewFullContentURLString = viewFullContentURL.toString();

viewFullContentURLString = HttpUtil.setParameter(viewFullContentURLString, "redirect", currentURL);

String viewURL = viewInContext ? assetRenderer.getURLViewInContext(liferayPortletRequest, liferayPortletResponse, viewFullContentURLString) : viewFullContentURLString;

viewURL = _checkViewURL(assetEntry, viewInContext, viewURL, currentURL, themeDisplay);

if (assetEntry.getClassNameId() == 10011) {
	final DLFileEntry dlFileEntry = DLFileEntryLocalServiceUtil.getFileEntry(assetEntry.getClassPK());
	FileEntry fileEntry = DLAppLocalServiceUtil.getFileEntry(dlFileEntry.getFileEntryId());
	fileEntry = fileEntry.toEscapedModel();
	final URL url = new URL(DLUtil.getPreviewURL(fileEntry, fileEntry.getFileVersion(), themeDisplay, ""));
	final URI uri = new URI(url.getProtocol(), url.getUserInfo(), url.getHost(), url.getPort(), url.getPath(), url.getQuery(), url.getRef());
	viewURL = uri.toURL().toString();
}
%>

	<c:if test="<%= assetEntryIndex == 0 %>">
		<ul class="title-list">
	</c:if>

	<li class="title-list <%= assetRendererFactory.getType() %>">
		<% if (assetEntry.getClassNameId() != 10011) { %>
		<liferay-ui:icon
			label="<%= true %>"
			message="<%= HtmlUtil.escape(title) %>"
			src="<%= assetRenderer.getIconPath(renderRequest) %>"
			url="<%= viewURL %>"
		/>
		<% } else { %>
		<a href="javascript:window.open('<%= viewURL %>','Voir le document','directories=no, height=720, location=no, menubar=no, resizable=yes, scrollbars=yes, status=no, toolbar=no, width=900');">
			<img alt="" src="<%= assetRenderer.getIconPath(renderRequest) %>" /> <%= HtmlUtil.escape(title) %>
		</a>
		<% } %>

		<liferay-util:include page="/html/portlet/asset_publisher/asset_actions.jsp" />

		<div class="asset-metadata">

			<%
			request.setAttribute("asset_metadata.jspf-filterByMetadata", true);
			%>

			<%@ include file="/html/portlet/asset_publisher/asset_metadata.jspf" %>
		</div>
	</li>

	<c:if test="<%= (assetEntryIndex + 1) == results.size() %>">
		</ul>
	</c:if>