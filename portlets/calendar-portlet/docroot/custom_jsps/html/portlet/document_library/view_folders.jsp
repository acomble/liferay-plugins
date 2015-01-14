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

<%@ include file="/html/portlet/document_library/init.jsp" %>

<%
Folder folder = (Folder)request.getAttribute("view.jsp-folder");

long folderId = GetterUtil.getLong((String)request.getAttribute("view.jsp-folderId"));

long repositoryId = GetterUtil.getLong((String)request.getAttribute("view.jsp-repositoryId"));

long parentFolderId = DLFolderConstants.DEFAULT_PARENT_FOLDER_ID;

boolean expandFolder = ParamUtil.getBoolean(request, "expandFolder");

Folder parentFolder = null;

if (folder != null) {
	parentFolderId = folder.getParentFolderId();

	if (expandFolder) {
		parentFolderId = folderId;
	}

	if ((parentFolderId == 0) && (repositoryId != scopeGroupId) || (folder.isRoot() && !folder.isDefaultRepository())) {
		if (folder.isMountPoint()) {
			parentFolderId = folderId;
		}
		else {
			parentFolderId = DLAppLocalServiceUtil.getMountFolder(repositoryId).getFolderId();

			folderId = parentFolderId;

			folder = DLAppServiceUtil.getFolder(folderId);
		}
	}

	if (parentFolderId != DLFolderConstants.DEFAULT_PARENT_FOLDER_ID) {
		try {
			parentFolder = DLAppServiceUtil.getFolder(folderId);
		}
		catch (NoSuchFolderException nsfe) {
			parentFolderId = DLFolderConstants.DEFAULT_PARENT_FOLDER_ID;
		}
	}
}

String browseBy = ParamUtil.getString(request, "browseBy");
long fileEntryTypeId = ParamUtil.getLong(request, "fileEntryTypeId", -1);

int entryStart = ParamUtil.getInteger(request, "entryStart");
int entryEnd = ParamUtil.getInteger(request, "entryEnd", entriesPerPage);

int folderStart = ParamUtil.getInteger(request, "folderStart");
int folderEnd = ParamUtil.getInteger(request, "folderEnd", SearchContainer.DEFAULT_DELTA);

int total = 0;

if (browseBy.equals("file-entry-type")) {
	total = DLFileEntryTypeServiceUtil.getFileEntryTypesCount(PortalUtil.getSiteAndCompanyGroupIds(themeDisplay));
}
else if ((folderId != rootFolderId) || expandFolder) {
	total = DLAppServiceUtil.getFoldersCount(repositoryId, parentFolderId, false);
}

PortletURL portletURL = liferayPortletResponse.createRenderURL();

portletURL.setParameter("struts_action", "/document_library/view");

SearchContainer searchContainer = new SearchContainer(liferayPortletRequest, null, null, "cur2", folderEnd / (folderEnd - folderStart), (folderEnd - folderStart), portletURL, null, null);

searchContainer.setTotal(total);

String parentTitle = LanguageUtil.get(pageContext, "home");

if (browseBy.equals("file-entry-type")) {
	parentTitle = LanguageUtil.get(pageContext, "browse-by-type");
}
else {
	if ((folderId != rootFolderId) && (parentFolderId > 0) && (folder != null) && (!folder.isMountPoint() || expandFolder)) {
		Folder grandParentFolder = DLAppServiceUtil.getFolder(parentFolderId);

		parentTitle = grandParentFolder.getName();
	}
	else if (((folderId != rootFolderId) && (parentFolderId == 0)) || ((folderId == rootFolderId) && (parentFolderId == 0) && expandFolder)) {
		parentTitle = LanguageUtil.get(pageContext, "home");
	}
}
%>

<c:choose>
	<c:when test='<%= (((folderId == rootFolderId) && !expandFolder) || ((folder != null) && (folder.isRoot() && !folder.isDefaultRepository() && !expandFolder))) && !browseBy.equals("file-entry-type") %>'>
		<div id="<portlet:namespace />listViewContainer">
			<div id="<portlet:namespace />folderContainer">
				<aui:nav cssClass="nav-list well">
					<c:if test="<%= Validator.isNotNull(parentTitle) %>">
						<li class="nav-header">
							<%= parentTitle %>
						</li>
					</c:if>
					
					<c:if test='<%=(folderId != rootFolderId)%>'>

						<liferay-portlet:renderURL varImpl="viewURL">
							<portlet:param name="struts_action" value="/document_library/view" />
							<portlet:param name="folderId" value="<%= String.valueOf(parentFolderId) %>" />
							<portlet:param name="entryStart" value="0" />
							<portlet:param name="entryEnd" value="<%= String.valueOf(entryEnd - entryStart) %>" />
							<portlet:param name="folderStart" value="0" />
							<portlet:param name="folderEnd" value="<%= String.valueOf(folderEnd - folderStart) %>" />
						</liferay-portlet:renderURL>
	
						<%
						Map<String, Object> dataView = new HashMap<String, Object>();
	
						dataView.put("folder-id", parentFolderId);
						dataView.put("repository-id", repositoryId);
						dataView.put("view-folders", Boolean.TRUE);
						%>
	
						<liferay-ui:app-view-navigation-entry
							dataView="<%= dataView %>"
							entryTitle='<%= LanguageUtil.get(pageContext, "up") %>'
							iconImage="icon-level-up"
							viewURL="<%= viewURL.toString() %>"
						/>
					
					</c:if>

				</aui:nav>
			</div>
		</div>
	</c:when>
	<c:when test='<%= browseBy.equals("file-entry-type") %>'>
	</c:when>
	<c:otherwise>
		<div id="<portlet:namespace />listViewContainer">
			<div id="<portlet:namespace />folderContainer">
				<aui:nav cssClass="nav-list well">
					<c:if test="<%= Validator.isNotNull(parentTitle) %>">
						<li class="nav-header">
							<%= parentTitle %>
						</li>
					</c:if>

					<liferay-portlet:renderURL varImpl="viewURL">
						<portlet:param name="struts_action" value="/document_library/view" />
						<portlet:param name="folderId" value="<%= String.valueOf(parentFolderId) %>" />
						<portlet:param name="entryStart" value="0" />
						<portlet:param name="entryEnd" value="<%= String.valueOf(entryEnd - entryStart) %>" />
						<portlet:param name="folderStart" value="0" />
						<portlet:param name="folderEnd" value="<%= String.valueOf(folderEnd - folderStart) %>" />
					</liferay-portlet:renderURL>

					<%
					Map<String, Object> dataView = new HashMap<String, Object>();

					dataView.put("folder-id", parentFolderId);
					dataView.put("repository-id", repositoryId);
					dataView.put("view-folders", Boolean.TRUE);
					%>

					<liferay-ui:app-view-navigation-entry
						dataView="<%= dataView %>"
						entryTitle='<%= LanguageUtil.get(pageContext, "up") %>'
						iconImage="icon-level-up"
						viewURL="<%= viewURL.toString() %>"
					/>

				</aui:nav>
			</div>
		</div>
	</c:otherwise>
</c:choose>

<%
request.setAttribute("view_folders.jsp-total", String.valueOf(total));

request.setAttribute("view_folders.jsp-folderEnd", searchContainer.getEnd());
request.setAttribute("view_folders.jsp-folderStart", searchContainer.getStart());
%>

<aui:script>
	Liferay.fire(
		'<portlet:namespace />pageLoaded',
		{
			pagination: {
				name: 'folderPagination',
				state: {
					page: <%= (total == 0) ? 0 : searchContainer.getCur() %>,
					rowsPerPage: <%= searchContainer.getDelta() %>,
					total: <%= total %>
				}
			}
		}
	);
</aui:script>

<%!
private static Log _log = LogFactoryUtil.getLog("portal-web.docroot.html.portlet.document_library.view_folders_jsp");
%>