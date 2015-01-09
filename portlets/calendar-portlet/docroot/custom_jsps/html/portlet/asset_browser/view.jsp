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
long groupId = ParamUtil.getLong(request, FileEntryDisplayTerms.SELECTED_GROUP_ID);

String eventName = ParamUtil.getString(request, "eventName", liferayPortletResponse.getNamespace() + "selectAsset");

if (groupId == 0) {
	groupId = ParamUtil.getLong(request, "groupId");
}

Folder folder = (Folder)request.getAttribute(WebKeys.DOCUMENT_LIBRARY_FOLDER);

long folderId = BeanParamUtil.getLong(folder, request, "folderId", DLFolderConstants.DEFAULT_PARENT_FOLDER_ID);

if ((folder != null) && (folder.getGroupId() != groupId)) {
	folder = null;

	folderId = 0;
}

long searchFolderIds = ParamUtil.getLong(request, "searchFolderIds");

long[] folderIdsArray = null;

if (folderId > 0) {
	folderIdsArray = new long[] {folderId};

	folder = DLAppServiceUtil.getFolder(folderId);
}
else {
	long defaultFolderId = DLFolderConstants.getFolderId(groupId, DLFolderConstants.getDataRepositoryId(groupId, searchFolderIds));

	List<Long> folderIds = DLAppServiceUtil.getSubfolderIds(groupId, searchFolderIds);

	folderIds.add(0, defaultFolderId);

	folderIdsArray = StringUtil.split(StringUtil.merge(folderIds), 0L);
}

long repositoryId = groupId;

if (folder != null) {
	repositoryId = folder.getRepositoryId();

	DLUtil.addPortletBreadcrumbEntries(folder, request, renderResponse);
}

int entryStart = ParamUtil.getInteger(request, "entryStart");
int entryEnd = ParamUtil.getInteger(request, "entryEnd", PropsValues.SEARCH_CONTAINER_PAGE_DEFAULT_DELTA);

String keywords = ParamUtil.getString(request, "keywords");

PortletURL portletURL = renderResponse.createRenderURL();

portletURL.setParameter("struts_action", "/asset_browser/view");
portletURL.setParameter("groupId", String.valueOf(groupId));
portletURL.setParameter("folderId", String.valueOf(folderId));
portletURL.setParameter("eventName", eventName);
portletURL.setPortletMode(PortletMode.VIEW);
portletURL.setWindowState(LiferayWindowState.POP_UP);
%>

<aui:form method="post" name="selectAssetFm">

	<%
	FileEntrySearch fileEntrySearchContainer = new FileEntrySearch(renderRequest, portletURL);

	FileEntryDisplayTerms displayTerms = (FileEntryDisplayTerms)fileEntrySearchContainer.getDisplayTerms();

	displayTerms.setSelectedGroupId(groupId);
	%>

	<c:if test="<%= Validator.isNull(displayTerms.getKeywords()) %>">
		<liferay-ui:header
			title="folders"
		/>

		<c:if test="<%= folder != null %>">
		
			<% 
				List<Folder> ancestors = folder.getAncestors();
			%>
					
				<liferay-ui:icon
					image='folder'
					label="<%= true %>"
					message='<%= LanguageUtil.get(locale, "folder") %>'
				/>
				<%
				portletURL = renderResponse.createRenderURL();
				portletURL.setParameter("struts_action", "/asset_browser/view");
				portletURL.setParameter("groupId", String.valueOf(groupId));
				portletURL.setParameter("folderId", "0");
				portletURL.setParameter("eventName", eventName);
				portletURL.setPortletMode(PortletMode.VIEW);
				portletURL.setWindowState(LiferayWindowState.POP_UP);
				%>
				:&nbsp;<a href="<%=portletURL.toString()%>">Accueil</a>
			<%
				for (int i = 0; i < ancestors.size(); i++) {
			%>
					<%
					portletURL = renderResponse.createRenderURL();
					portletURL.setParameter("struts_action", "/asset_browser/view");
					portletURL.setParameter("groupId", String.valueOf(groupId));
					portletURL.setParameter("folderId", String.valueOf(ancestors.get(ancestors.size() - i - 1).getFolderId()));
					portletURL.setParameter("eventName", eventName);
					portletURL.setPortletMode(PortletMode.VIEW);
					portletURL.setWindowState(LiferayWindowState.POP_UP);
					%>
					&nbsp;&raquo;&nbsp;<a href="<%=portletURL.toString()%>"><%= ancestors.get(ancestors.size() - i - 1).getName() %></a>
			<%	
				}
			%>
			
			&nbsp;&raquo;&nbsp;<%= folder.getName() %>
		
		</c:if>

		<%
		List<String> headerNames = new ArrayList<String>();

		headerNames.add("folder");
		headerNames.add("num-of-folders");
		headerNames.add("num-of-documents");

		SearchContainer searchContainer = new SearchContainer(renderRequest, null, null, "cur1", SearchContainer.DEFAULT_DELTA, portletURL, headerNames, "there-are-no-folders");

		int total = DLAppServiceUtil.getFoldersCount(groupId, folderId);

		searchContainer.setTotal(total);

		List results = DLAppServiceUtil.getFolders(repositoryId, folderId, searchContainer.getStart(), searchContainer.getEnd());

		searchContainer.setResults(results);

		List resultRows = searchContainer.getResultRows();

		for (int i = 0; i < results.size(); i++) {
			Folder curFolder = (Folder)results.get(i);

			ResultRow row = new ResultRow(curFolder, curFolder.getFolderId(), i);

			PortletURL rowURL = renderResponse.createRenderURL();

			rowURL.setParameter("struts_action", "/asset_browser/view");
			rowURL.setParameter("groupId", String.valueOf(groupId));
			rowURL.setParameter("folderId", String.valueOf(curFolder.getFolderId()));
			rowURL.setParameter("eventName", eventName);
			rowURL.setPortletMode(PortletMode.VIEW);
			rowURL.setWindowState(LiferayWindowState.POP_UP);

			// Name

			StringBundler sb = new StringBundler(4);

			sb.append("<img align=\"left\" border=\"0\" src=\"");
			sb.append(HtmlUtil.escapeAttribute(themeDisplay.getPathThemeImages()));
			sb.append("/common/folder.png\">");
			sb.append(HtmlUtil.escape(curFolder.getName()));

			row.addText(sb.toString(), rowURL);

			// Statistics

			List<Long> subfolderIds = DLAppServiceUtil.getSubfolderIds(curFolder.getRepositoryId(), curFolder.getFolderId(), false);

			int foldersCount = subfolderIds.size();

			subfolderIds.clear();
			subfolderIds.add(curFolder.getFolderId());

			int fileEntriesCount = DLAppServiceUtil.getFoldersFileEntriesCount(curFolder.getRepositoryId(), subfolderIds, WorkflowConstants.STATUS_APPROVED);

			row.addText(String.valueOf(foldersCount), rowURL);
			row.addText(String.valueOf(fileEntriesCount), rowURL);

			// Add result row

			resultRows.add(row);
		}
		%>

		<liferay-ui:search-iterator searchContainer="<%= searchContainer %>" />

		<br />
	</c:if>

	<c:choose>
		<c:when test="<%= Validator.isNull(displayTerms.getKeywords()) %>">
			<liferay-ui:header
				title="documents"
			/>
		</c:when>
		<c:otherwise>

			<%
			PortletURL backURL = renderResponse.createRenderURL();

			backURL.setParameter("struts_action", "/asset_browser/view");
			backURL.setParameter("groupId", String.valueOf(groupId));
			backURL.setParameter("eventName", eventName);
			backURL.setPortletMode(PortletMode.VIEW);
			backURL.setWindowState(LiferayWindowState.POP_UP);
			%>

			<liferay-ui:header
				backURL="<%= backURL.toString() %>"
				title="documents"
			/>
		</c:otherwise>
	</c:choose>

	<%
	List<String> headerNames = new ArrayList<String>();

	headerNames.add("document");
	headerNames.add("author");
	headerNames.add(StringPool.BLANK);

	if (Validator.isNull(displayTerms.getKeywords())) {
		SearchContainer searchContainer = new SearchContainer(renderRequest, null, null, "cur2", SearchContainer.DEFAULT_DELTA, portletURL, headerNames, "there-are-no-documents-in-this-folder");

		int total = DLAppServiceUtil.getFileEntriesCount(groupId, folderId);

		searchContainer.setTotal(total);

		List results = DLAppServiceUtil.getFileEntries(repositoryId, folderId, searchContainer.getStart(), searchContainer.getEnd());

		searchContainer.setResults(results);

		List resultRows = searchContainer.getResultRows();
	%>

		<%@ include file="/html/portlet/asset_browser/select_document_library_search_results.jspf" %>

		<liferay-ui:search-iterator searchContainer="<%= searchContainer %>" />

	<%
	}
	else {
		PortletURL iteratorURL = renderResponse.createRenderURL();

		iteratorURL.setParameter("struts_action", "/asset_browser/view");
		iteratorURL.setParameter("groupId", String.valueOf(groupId));
		iteratorURL.setParameter("folderId", String.valueOf(folderId));
		iteratorURL.setParameter("eventName", eventName);
		iteratorURL.setPortletMode(PortletMode.VIEW);
		iteratorURL.setWindowState(LiferayWindowState.POP_UP);

		fileEntrySearchContainer = new FileEntrySearch(renderRequest, displayTerms, (FileEntrySearchTerms)fileEntrySearchContainer.getSearchTerms(), "cur2", SearchContainer.DEFAULT_DELTA, iteratorURL, headerNames, "there-are-no-documents-in-this-folder");

		try {
			SearchContext searchContext = SearchContextFactory.getInstance(request);

			searchContext.setAttribute("groupId", groupId);
			searchContext.setAttribute("paginationType", "regular");
			searchContext.setEnd(entryEnd);
			searchContext.setFolderIds(folderIdsArray);
			searchContext.setGroupIds(new long[] {groupId});
			searchContext.setKeywords(keywords);
			searchContext.setStart(entryStart);

			searchContext.setScopeStrict(false);

			Hits hits = DLAppServiceUtil.search(repositoryId, searchContext);

			fileEntrySearchContainer.setTotal(hits.getLength());

			List results = new ArrayList();

			Document[] docs = hits.getDocs();

			if (docs != null) {
				for (Document doc : docs) {
					long fileEntryId = GetterUtil.getLong(doc.get(Field.ENTRY_CLASS_PK));

					FileEntry fileEntry = null;

					try {
						fileEntry = DLAppLocalServiceUtil.getFileEntry(fileEntryId);
					}
					catch (Exception e) {
						if (_log.isWarnEnabled()) {
							_log.warn("Documents and Media search index is stale and contains file entry {" + fileEntryId + "}");
						}

						continue;
					}

					results.add(fileEntry);
				}

				if (docs.length == 0) {
					request.removeAttribute(WebKeys.DOCUMENT_LIBRARY_FOLDER);
				}
			}

			fileEntrySearchContainer.setResults(results);

			List resultRows = fileEntrySearchContainer.getResultRows();
	%>

			<%@ include file="/html/portlet/asset_browser/select_document_library_search_results.jspf" %>

	<%
		}
		catch (Exception e) {
			_log.error(e, e);
		}
	%>

		<liferay-ui:search-iterator searchContainer="<%= fileEntrySearchContainer %>" />

	<%
	}
	%>

</aui:form>

<%!
private static Log _log = LogFactoryUtil.getLog("portal-web.docroot.html.portlet.dynamic_data_mapping.select_document_library_jsp");
%>

<liferay-util:buffer var="removeLinkIcon">
	<liferay-ui:icon
		image="unlink"
		label="<%= true %>"
		message="remove"
	/>
</liferay-util:buffer>

<aui:script use="aui-base">
	var Util = Liferay.Util;

	A.one('#<portlet:namespace />selectAssetFm').delegate(
		'click',
		function(event) {
			var result = Util.getAttributes(event.currentTarget, 'data-');

			Util.getOpener().Liferay.fire('<%= HtmlUtil.escapeJS(eventName) %>', result);

			Util.getWindow().hide();
		},
		'.selector-button'
	);
</aui:script>

