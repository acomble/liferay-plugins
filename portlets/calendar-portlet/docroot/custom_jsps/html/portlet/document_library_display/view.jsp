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

<%@ include file="/html/portlet/document_library_display/init.jsp" %>

<%
String topLink = ParamUtil.getString(request, "topLink", "home");

String redirect = ParamUtil.getString(request, "redirect");

Folder folder = (Folder)request.getAttribute(WebKeys.DOCUMENT_LIBRARY_FOLDER);

long defaultFolderId = GetterUtil.getLong(portletPreferences.getValue("rootFolderId", StringPool.BLANK), DLFolderConstants.DEFAULT_PARENT_FOLDER_ID);

long folderId = BeanParamUtil.getLong(folder, request, "folderId", defaultFolderId);

boolean defaultFolderView = false;

if ((folder == null) && (defaultFolderId != DLFolderConstants.DEFAULT_PARENT_FOLDER_ID)) {
	defaultFolderView = true;
}

if (defaultFolderView) {
	try {
		folder = DLAppLocalServiceUtil.getFolder(folderId);
	}
	catch (NoSuchFolderException nsfe) {
		folderId = DLFolderConstants.DEFAULT_PARENT_FOLDER_ID;
	}
}

long repositoryId = scopeGroupId;

if (folder != null) {
	repositoryId = folder.getRepositoryId();
}

int status = WorkflowConstants.STATUS_APPROVED;

if (permissionChecker.isCompanyAdmin() || permissionChecker.isGroupAdmin(scopeGroupId)) {
	status = WorkflowConstants.STATUS_ANY;
}

int foldersCount = DLAppServiceUtil.getFoldersCount(repositoryId, folderId);
int fileEntriesCount = DLAppServiceUtil.getFileEntriesAndFileShortcutsCount(repositoryId, folderId, status);

long assetCategoryId = ParamUtil.getLong(request, "categoryId");
String assetTagName = ParamUtil.getString(request, "tag");

boolean useAssetEntryQuery = (assetCategoryId > 0) || Validator.isNotNull(assetTagName);

PortletURL portletURL = renderResponse.createRenderURL();

portletURL.setParameter("struts_action", "/document_library_display/view");
portletURL.setParameter("topLink", topLink);
portletURL.setParameter("folderId", String.valueOf(folderId));

request.setAttribute("view.jsp-folder", folder);

request.setAttribute("view.jsp-defaultFolderId", String.valueOf(defaultFolderId));

request.setAttribute("view.jsp-folderId", String.valueOf(folderId));

request.setAttribute("view.jsp-repositoryId", String.valueOf(repositoryId));

request.setAttribute("view.jsp-viewFolder", Boolean.TRUE.toString());

request.setAttribute("view.jsp-useAssetEntryQuery", String.valueOf(useAssetEntryQuery));
%>

<%

PortletPreferences preferences = renderRequest.getPreferences();
String portletCustomTitle = preferences.getValue("portletSetupTitle_fr_FR", "Mes documents");

%>

<span class="aqua">
	<h1 class="portlet-title-spec"><%=portletCustomTitle%></h1>
	<span class="tgl"></span>
</span>

<div class="aqua">

<aui:nav-bar>
	<liferay-portlet:renderURL varImpl="searchURL">
		<portlet:param name="struts_action" value="/document_library_display/search" />
	</liferay-portlet:renderURL>
	
	<aui:nav-bar-search cssClass="pull-right">
		<div class="form-search">
			<aui:form action="<%= searchURL %>" method="get" name="searchFm">
				<liferay-portlet:renderURLParams varImpl="searchURL" />
				<aui:input name="redirect" type="hidden" value="<%= currentURL %>" />
				<aui:input name="repositoryId" type="hidden" value="<%= repositoryId %>" />
				<aui:input name="folderId" type="hidden" value="<%= folderId %>" />
				<aui:input name="breadcrumbsFolderId" type="hidden" value="<%= folderId %>" />
				<aui:input name="searchFolderIds" type="hidden" value="<%= folderId %>" />
	
				<liferay-ui:input-search id="keywords1" />
			</aui:form>
		</div>
	</aui:nav-bar-search>
	
	<c:if test="<%= windowState.equals(WindowState.MAXIMIZED) %>">
		<aui:script>
			Liferay.Util.focusFormField(document.getElementById('<portlet:namespace />keywords1'));
		</aui:script>
	</c:if>
</aui:nav-bar>

<c:choose>
	<c:when test="<%= useAssetEntryQuery %>">
		<liferay-ui:categorization-filter
			assetType="documents"
			portletURL="<%= portletURL %>"
		/>

		<%@ include file="/html/portlet/document_library/view_file_entries.jspf" %>

	</c:when>
	<c:when test='<%= topLink.equals("home") %>'>
		<aui:row>
			<c:if test="<%= (folder != null) %>">
				<liferay-ui:header
					backURL="<%= redirect %>"
					localizeTitle="<%= false %>"
					title='<%= "Dossier : " + folder.getName() %>'
				/>
			</c:if>

			<aui:col cssClass="lfr-asset-column lfr-asset-column-details" width="<%= showFolderMenu ? 75 : 100 %>">
				<liferay-ui:panel-container extended="<%= false %>" id='<%= renderResponse.getNamespace() + "documentLibraryDisplayInfoPanelContainer" %>' persistState="<%= true %>">
					<%@ include file="/html/portlet/document_library_display/view_file_entries.jspf" %>
					
					<c:if test="<%= foldersCount > 0 %>">
						<liferay-ui:search-container
							curParam="cur1"
							delta="<%= foldersPerPage %>"
							deltaConfigurable="<%= false %>"
							headerNames="<%= StringUtil.merge(folderColumns) %>"
							iteratorURL="<%= portletURL %>"
							total="<%= foldersCount %>"
						>
							<liferay-ui:search-container-results
								results="<%= DLAppServiceUtil.getFolders(repositoryId, folderId, searchContainer.getStart(), searchContainer.getEnd()) %>"
							/>

							<liferay-ui:search-container-row
								className="com.liferay.portal.kernel.repository.model.Folder"
								escapedModel="<%= true %>"
								keyProperty="folderId"
								modelVar="curFolder"
								rowVar="row"
							>
								<liferay-portlet:renderURL varImpl="rowURL">
									<portlet:param name="struts_action" value="/document_library_display/view" />
									<portlet:param name="redirect" value="<%= currentURL %>" />
									<portlet:param name="folderId" value="<%= String.valueOf(curFolder.getFolderId()) %>" />
								</liferay-portlet:renderURL>

								<%@ include file="/html/portlet/document_library/folder_columns.jspf" %>
							</liferay-ui:search-container-row>

							<liferay-ui:search-iterator />
						</liferay-ui:search-container>
					</c:if>
				</liferay-ui:panel-container>
			</aui:col>
		</aui:row>

		<%
		if (folder != null) {
			DLUtil.addPortletBreadcrumbEntries(folder, request, renderResponse);

			if (!defaultFolderView) {
				PortalUtil.setPageSubtitle(folder.getName(), request);
				PortalUtil.setPageDescription(folder.getDescription(), request);
			}
		}
		%>

	</c:when>
</c:choose>

</div>

<%!
private static Log _log = LogFactoryUtil.getLog("portal-web.docroot.html.portlet.document_library.view_jsp");
%>