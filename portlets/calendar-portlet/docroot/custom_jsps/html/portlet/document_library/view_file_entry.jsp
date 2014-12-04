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
String tabs2 = ParamUtil.getString(request, "tabs2", "version-history");

String redirect = ParamUtil.getString(request, "redirect");

String referringPortletResource = ParamUtil.getString(request, "referringPortletResource");

String uploadProgressId = "dlFileEntryUploadProgress";

FileEntry fileEntry = (FileEntry)request.getAttribute(WebKeys.DOCUMENT_LIBRARY_FILE_ENTRY);

long fileEntryId = fileEntry.getFileEntryId();

long folderId = fileEntry.getFolderId();

if (Validator.isNull(redirect)) {
	PortletURL portletURL = renderResponse.createRenderURL();

	portletURL.setParameter("struts_action", "/document_library/view");
	portletURL.setParameter("folderId", String.valueOf(folderId));

	redirect = portletURL.toString();
}

Folder folder = fileEntry.getFolder();
FileVersion fileVersion = (FileVersion)request.getAttribute(WebKeys.DOCUMENT_LIBRARY_FILE_VERSION);

boolean versionSpecific = false;

if (fileVersion != null) {
	versionSpecific = true;
}
else if ((user.getUserId() == fileEntry.getUserId()) || DLFileEntryPermission.contains(permissionChecker, fileEntry, ActionKeys.UPDATE)) {
	fileVersion = fileEntry.getLatestFileVersion();
}
else {
	fileVersion = fileEntry.getFileVersion();
}

long fileVersionId = fileVersion.getFileVersionId();

long fileEntryTypeId = 0;

if (fileVersion.getModel() instanceof DLFileVersion) {
	DLFileVersion dlFileVersion = (DLFileVersion)fileVersion.getModel();

	fileEntryTypeId = dlFileVersion.getFileEntryTypeId();
}

Lock lock = fileEntry.getLock();

String[] conversions = new String[0];

if (PropsValues.DL_FILE_ENTRY_CONVERSIONS_ENABLED && PrefsPropsUtil.getBoolean(PropsKeys.OPENOFFICE_SERVER_ENABLED, PropsValues.OPENOFFICE_SERVER_ENABLED)) {
	conversions = (String[])DocumentConversionUtil.getConversions(fileVersion.getExtension());
}

long assetClassPK = 0;

if (!fileVersion.isApproved() && !fileVersion.getVersion().equals(DLFileEntryConstants.VERSION_DEFAULT) && !fileEntry.isInTrash()) {
	assetClassPK = fileVersion.getFileVersionId();
}
else {
	assetClassPK = fileEntry.getFileEntryId();
}

String webDavUrl = StringPool.BLANK;

if (portletDisplay.isWebDAVEnabled()) {
	webDavUrl = DLUtil.getWebDavURL(themeDisplay, folder, fileEntry);
}

boolean hasAudio = AudioProcessorUtil.hasAudio(fileVersion);
boolean hasImages = ImageProcessorUtil.hasImages(fileVersion);
boolean hasPDFImages = PDFProcessorUtil.hasImages(fileVersion);
boolean hasVideo = VideoProcessorUtil.hasVideo(fileVersion);

AssetEntry layoutAssetEntry = AssetEntryLocalServiceUtil.fetchEntry(DLFileEntryConstants.getClassName(), assetClassPK);

request.setAttribute(WebKeys.LAYOUT_ASSET_ENTRY, layoutAssetEntry);

request.setAttribute("view_file_entry.jsp-fileEntry", fileEntry);
%>

<div class="view">
	<aui:row>
		<aui:col cssClass="lfr-asset-column-details" width="<%= 100 %>">
			<liferay-util:buffer var="documentTitle">
				<%= fileVersion.getTitle() %>

				<c:if test="<%= versionSpecific %>">
					(<liferay-ui:message key="version" /> <%= fileVersion.getVersion() %>)
				</c:if>
			</liferay-util:buffer>

			<div class="body-row">

				<aui:model-context bean="<%= fileVersion %>" model="<%= DLFileVersion.class %>" />

				<div>

					<%
					int previewFileCount = 0;
					String previewFileURL = null;
					String[] previewFileURLs = null;
					String videoThumbnailURL = null;

					String previewQueryString = null;

					if (hasAudio) {
						previewQueryString = "&audioPreview=1";
					}
					else if (hasImages) {
						previewQueryString = "&imagePreview=1";
					}
					else if (hasPDFImages) {
						previewFileCount = PDFProcessorUtil.getPreviewFileCount(fileVersion);

						previewQueryString = "&previewFileIndex=";

						previewFileURL = DLUtil.getPreviewURL(fileEntry, fileVersion, themeDisplay, previewQueryString);
					}
					else if (hasVideo) {
						previewQueryString = "&videoPreview=1";

						videoThumbnailURL = DLUtil.getPreviewURL(fileEntry, fileVersion, themeDisplay, "&videoThumbnail=1");
					}

					if (Validator.isNotNull(previewQueryString)) {
						if (hasAudio) {
							previewFileURLs = new String[PropsValues.DL_FILE_ENTRY_PREVIEW_AUDIO_CONTAINERS.length];

							for (int i = 0; i < PropsValues.DL_FILE_ENTRY_PREVIEW_AUDIO_CONTAINERS.length; i++) {
								previewFileURLs[i] = DLUtil.getPreviewURL(fileEntry, fileVersion, themeDisplay, previewQueryString + "&type=" + PropsValues.DL_FILE_ENTRY_PREVIEW_AUDIO_CONTAINERS[i]);
							}
						}
						else if (hasVideo) {
							if (PropsValues.DL_FILE_ENTRY_PREVIEW_VIDEO_CONTAINERS.length > 0) {
								previewFileURLs = new String[PropsValues.DL_FILE_ENTRY_PREVIEW_VIDEO_CONTAINERS.length];

								for (int i = 0; i < PropsValues.DL_FILE_ENTRY_PREVIEW_VIDEO_CONTAINERS.length; i++) {
									previewFileURLs[i] = DLUtil.getPreviewURL(fileEntry, fileVersion, themeDisplay, previewQueryString + "&type=" + PropsValues.DL_FILE_ENTRY_PREVIEW_VIDEO_CONTAINERS[i]);
								}
							}
							else {
								previewFileURLs = new String[1];

								previewFileURLs[0] = videoThumbnailURL;
							}
						}
						else {
							previewFileURLs = new String[1];

							previewFileURLs[0] = DLUtil.getPreviewURL(fileEntry, fileVersion, themeDisplay, previewQueryString);
						}

						previewFileURL = previewFileURLs[0];

						if (!hasPDFImages) {
							previewFileCount = 1;
						}
					}

					request.setAttribute("view_file_entry.jsp-supportedAudio", String.valueOf(hasAudio));
					request.setAttribute("view_file_entry.jsp-supportedVideo", String.valueOf(hasVideo));

					request.setAttribute("view_file_entry.jsp-previewFileURLs", previewFileURLs);
					request.setAttribute("view_file_entry.jsp-videoThumbnailURL", videoThumbnailURL);
					%>

					<c:choose>
						<c:when test="<%= previewFileCount == 0 %>">
							<c:choose>
								<c:when test="<%= !DLProcessorRegistryUtil.isPreviewableSize(fileVersion) && (AudioProcessorUtil.isAudioSupported(fileVersion.getMimeType()) || ImageProcessorUtil.isImageSupported(fileVersion.getMimeType()) || PDFProcessorUtil.isDocumentSupported(fileVersion.getMimeType()) || VideoProcessorUtil.isVideoSupported(fileVersion.getMimeType())) %>">
									<div class="alert alert-info">
										<liferay-ui:message key="file-is-too-large-for-preview-or-thumbnail-generation" />
									</div>
								</c:when>
								<c:when test="<%= AudioProcessorUtil.isAudioSupported(fileVersion) || ImageProcessorUtil.isImageSupported(fileVersion) || PDFProcessorUtil.isDocumentSupported(fileVersion) || VideoProcessorUtil.isVideoSupported(fileVersion) %>">
									<div class="alert alert-info">
										<liferay-ui:message key="generating-preview-will-take-a-few-minutes" />
									</div>
								</c:when>
							</c:choose>
						</c:when>
						<c:otherwise>
							<c:choose>
								<c:when test="<%= hasAudio %>">
									<div class="lfr-preview-audio" id="<portlet:namespace />previewFile">
										<div class="lfr-preview-audio-content" id="<portlet:namespace />previewFileContent"></div>
									</div>

									<liferay-util:include page="/html/portlet/document_library/player.jsp" />
								</c:when>
								<c:when test="<%= hasImages %>">
									<div class="lfr-preview-file lfr-preview-image" id="<portlet:namespace />previewFile">
										<div class="lfr-preview-file-content lfr-preview-image-content" id="<portlet:namespace />previewFileContent">
											<div class="lfr-preview-file-image-current-column">
												<div class="lfr-preview-file-image-container">
													<img class="lfr-preview-file-image-current" src="<%= previewFileURL %>" />
												</div>
											</div>
										</div>
									</div>
								</c:when>
								<c:when test="<%= hasVideo %>">
									<div class="lfr-preview-file lfr-preview-video" id="<portlet:namespace />previewFile">
										<div class="lfr-preview-file-content lfr-preview-video-content">
											<div class="lfr-preview-file-video-current-column">
												<div id="<portlet:namespace />previewFileContent"></div>
											</div>
										</div>
									</div>

									<liferay-util:include page="/html/portlet/document_library/player.jsp" />
								</c:when>
								<c:otherwise>
									<div class="lfr-preview-file" id="<portlet:namespace />previewFile">
										<div class="lfr-preview-file-content" id="<portlet:namespace />previewFileContent">
											<div class="lfr-preview-file-image-current-column">
												<div class="lfr-preview-file-image-container">
													<img class="lfr-preview-file-image-current" id="<portlet:namespace />previewFileImage" src="<%= previewFileURL + "1" %>" />
												</div>
												<span class="lfr-preview-file-actions hide" id="<portlet:namespace />previewFileActions">
													<span class="lfr-preview-file-toolbar" id="<portlet:namespace />previewToolbar"></span>

													<span class="lfr-preview-file-info">
														<span class="lfr-preview-file-index" id="<portlet:namespace />previewFileIndex">1</span> of <span class="lfr-preview-file-count"><%= previewFileCount %></span>
													</span>
												</span>
											</div>

											<div class="lfr-preview-file-images" id="<portlet:namespace />previewImagesContent">
												<div class="lfr-preview-file-images-content"></div>
											</div>
										</div>
									</div>

									<aui:script use="liferay-preview">
										new Liferay.Preview(
											{
												actionContent: '#<portlet:namespace />previewFileActions',
												baseImageURL: '<%= previewFileURL %>',
												boundingBox: '#<portlet:namespace />previewFile',
												contentBox: '#<portlet:namespace />previewFileContent',
												currentPreviewImage: '#<portlet:namespace />previewFileImage',
												imageListContent: '#<portlet:namespace />previewImagesContent',
												maxIndex: <%= previewFileCount %>,
												previewFileIndexNode: '#<portlet:namespace />previewFileIndex',
												toolbar: '#<portlet:namespace />previewToolbar'
											}
										).render();
									</aui:script>
								</c:otherwise>
							</c:choose>
						</c:otherwise>
					</c:choose>
				</div>
			</div>
		</aui:col>

	</aui:row>
</div>

<aui:script>
	Liferay.provide(
		window,
		'<portlet:namespace />compare',
		function() {
			var A = AUI();

			var rowIds = A.all('input[name=<portlet:namespace />rowIds]:checked');
			var sourceVersion = A.one('input[name="<portlet:namespace />sourceVersion"]');
			var targetVersion = A.one('input[name="<portlet:namespace />targetVersion"]');

			var rowIdsSize = rowIds.size();

			if (rowIdsSize == 1) {
				if (sourceVersion) {
					sourceVersion.val(rowIds.item(0).val());
				}
			}
			else if (rowIdsSize == 2) {
				if (sourceVersion) {
					sourceVersion.val(rowIds.item(1).val());
				}

				if (targetVersion) {
					targetVersion.val(rowIds.item(0).val());
				}
			}

			submitForm(document.<portlet:namespace />fm1);
		},
		['aui-base', 'selector-css3']
	);

	Liferay.provide(
		window,
		'<portlet:namespace />initRowsChecked',
		function() {
			var A = AUI();

			var rowIds = A.all('input[name=<portlet:namespace />rowIds]');

			rowIds.each(
				function(item, index, collection) {
					if (index >= 2) {
						item.set('checked', false);
					}
				}
			);
		},
		['aui-base']
	);

	Liferay.provide(
		window,
		'<portlet:namespace />updateRowsChecked',
		function(element) {
			var A = AUI();

			var rowsChecked = A.all('input[name=<portlet:namespace />rowIds]:checked');

			if (rowsChecked.size() > 2) {
				var index = 2;

				if (rowsChecked.item(2).compareTo(element)) {
					index = 1;
				}

				rowsChecked.item(index).set('checked', false);
			}
		},
		['aui-base', 'selector-css3']
	);
</aui:script>

<c:if test="<%= DLFileEntryPermission.contains(permissionChecker, fileEntry, ActionKeys.VIEW) && DLUtil.isOfficeExtension(fileVersion.getExtension()) && portletDisplay.isWebDAVEnabled() && BrowserSnifferUtil.isIeOnWin32(request) %>">
	<%@ include file="/html/portlet/document_library/action/open_document_js.jspf" %>
</c:if>

<aui:script use="aui-base,aui-toolbar">
	var showURLFile = A.one('.show-url-file');
	var showWebDavFile = A.one('.show-webdav-url-file');

	if (showURLFile) {
		showURLFile.on(
			'click',
			function(event) {
				var URLFileContainer = A.one('.url-file-container');

				URLFileContainer.toggleClass('hide');
			}
		);
	}

	if (showWebDavFile) {
		showWebDavFile.on(
			'click',
			function(event) {
				var WebDavFileContainer = A.one('.webdav-url-file-container');

				WebDavFileContainer.toggleClass('hide');
			}
		);
	}

	<c:if test="<%= showActions %>">
		var buttonRow = A.one('#<portlet:namespace />fileEntryToolbar');

		var fileEntryButtonGroup = [];

		<c:if test="<%= DLFileEntryPermission.contains(permissionChecker, fileEntry, ActionKeys.VIEW) %>">
			fileEntryButtonGroup.push(
				{
					icon: 'icon-download',
					label: '<%= UnicodeLanguageUtil.get(pageContext, "download") %>',
					on: {
						click: function(event) {
							location.href = '<%= DLUtil.getPreviewURL(fileEntry, fileVersion, themeDisplay, StringPool.BLANK) %>';
						}
					}
				}
			);

			<%
			if (DLFileEntryPermission.contains(permissionChecker, fileEntry, ActionKeys.VIEW) && DLUtil.isOfficeExtension(fileVersion.getExtension()) && portletDisplay.isWebDAVEnabled() && BrowserSnifferUtil.isIeOnWin32(request)) {
			%>

				fileEntryButtonGroup.push(
					{
						label: '<%= UnicodeLanguageUtil.get(pageContext, "open-in-ms-office") %>',
						on: {
							click: function(event) {
								<portlet:namespace />openDocument('<%= DLUtil.getWebDavURL(themeDisplay, fileEntry.getFolder(), fileEntry, PropsValues.DL_FILE_ENTRY_OPEN_IN_MS_OFFICE_MANUAL_CHECK_IN_REQUIRED) %>');
							}
						}
					}
				);

			<%
			}
			%>

		</c:if>

		<c:if test="<%= DLFileEntryPermission.contains(permissionChecker, fileEntry, ActionKeys.UPDATE) && (!fileEntry.isCheckedOut() || fileEntry.hasLock()) %>">
			fileEntryButtonGroup.push(
				{

					<portlet:renderURL var="editURL">
						<portlet:param name="struts_action" value="/document_library/edit_file_entry" />
						<portlet:param name="redirect" value="<%= currentURL %>" />
						<portlet:param name="fileEntryId" value="<%= String.valueOf(fileEntry.getFileEntryId()) %>" />
					</portlet:renderURL>

					icon: 'icon-pencil',
					label: '<%= UnicodeLanguageUtil.get(pageContext, "edit") %>',
					on: {
						click: function(event) {
							location.href = '<%= editURL.toString() %>';
						}
					}
				},
				{

					<portlet:renderURL var="moveURL">
						<portlet:param name="struts_action" value="/document_library/move_file_entry" />
						<portlet:param name="redirect" value="<%= redirect %>" />
						<portlet:param name="fileEntryId" value="<%= String.valueOf(fileEntry.getFileEntryId()) %>" />
					</portlet:renderURL>

					icon: 'icon-move',
					label: '<%= UnicodeLanguageUtil.get(pageContext, "move") %>',
					on: {
						click: function(event) {
							location.href = '<%= moveURL.toString() %>';
						}
					}
				}
			);

			<c:if test="<%= !fileEntry.isCheckedOut() %>">
				fileEntryButtonGroup.push(
					{

						icon: 'icon-lock',
						label: '<%= UnicodeLanguageUtil.get(pageContext, "checkout[document]") %>',
						on: {
							click: function(event) {
								document.<portlet:namespace />fm.<portlet:namespace /><%= Constants.CMD %>.value = '<%= Constants.CHECKOUT %>';
								submitForm(document.<portlet:namespace />fm);
							}
						}
					}
				);
			</c:if>

			<c:if test="<%= fileEntry.isCheckedOut() && fileEntry.hasLock() %>">
				fileEntryButtonGroup.push(
					{

						icon: 'icon-undo',
						label: '<%= UnicodeLanguageUtil.get(pageContext, "cancel-checkout[document]") %>',
						on: {
							click: function(event) {
								document.<portlet:namespace />fm.<portlet:namespace /><%= Constants.CMD %>.value = '<%= Constants.CANCEL_CHECKOUT %>';
								submitForm(document.<portlet:namespace />fm);
							}
						}
					},
					{

						icon: 'icon-unlock',
						label: '<%= UnicodeLanguageUtil.get(pageContext, "checkin") %>',
						on: {
							click: function(event) {
								document.<portlet:namespace />fm.<portlet:namespace /><%= Constants.CMD %>.value = '<%= Constants.CHECKIN %>';
								submitForm(document.<portlet:namespace />fm);
							}
						}
					}
				);
			</c:if>
		</c:if>

		<c:if test="<%= DLFileEntryPermission.contains(permissionChecker, fileEntry, ActionKeys.PERMISSIONS) %>">
			fileEntryButtonGroup.push(
				{
					<liferay-security:permissionsURL
						modelResource="<%= DLFileEntryConstants.getClassName() %>"
						modelResourceDescription="<%= fileEntry.getTitle() %>"
						resourcePrimKey="<%= String.valueOf(fileEntry.getFileEntryId()) %>"
						var="permissionsURL"
						windowState="<%= LiferayWindowState.POP_UP.toString() %>"
					/>

					icon: 'icon-permissions',
					label: '<%= UnicodeLanguageUtil.get(pageContext, "permissions") %>',
					on: {
						click: function(event) {
							Liferay.Util.openWindow(
								{
									title: '<%= UnicodeLanguageUtil.get(pageContext, "permissions") %>',
									uri: '<%= permissionsURL.toString() %>',
								}
							);
						}
					}
				}
			);
		</c:if>

		<c:if test="<%= DLFileEntryPermission.contains(permissionChecker, fileEntry, ActionKeys.DELETE) && (fileEntry.getModel() instanceof DLFileEntry) && TrashUtil.isTrashEnabled(scopeGroupId) %>">
			fileEntryButtonGroup.push(
				{
					<portlet:renderURL var="viewFolderURL">
						<portlet:param name="struts_action" value="/document_library/view" />
						<portlet:param name="folderId" value="<%= String.valueOf(fileEntry.getFolderId()) %>" />
					</portlet:renderURL>

					icon: 'icon-trash',
					label: '<%= UnicodeLanguageUtil.get(pageContext, "move-to-the-recycle-bin") %>',
					on: {
						click: function(event) {
							document.<portlet:namespace />fm.<portlet:namespace /><%= Constants.CMD %>.value = '<%= Constants.MOVE_TO_TRASH %>';
							document.<portlet:namespace />fm.<portlet:namespace />redirect.value = '<%= viewFolderURL.toString() %>';
							submitForm(document.<portlet:namespace />fm);
						}
					}
				}
			);
		</c:if>

		<c:if test="<%= DLFileEntryPermission.contains(permissionChecker, fileEntry, ActionKeys.DELETE) && (!(fileEntry.getModel() instanceof DLFileEntry) || !TrashUtil.isTrashEnabled(scopeGroupId)) %>">
			fileEntryButtonGroup.push(
				{
					<portlet:renderURL var="viewFolderURL">
						<portlet:param name="struts_action" value="/document_library/view" />
						<portlet:param name="folderId" value="<%= String.valueOf(fileEntry.getFolderId()) %>" />
					</portlet:renderURL>

					icon: 'icon-delete',
					label: '<%= UnicodeLanguageUtil.get(pageContext, "delete") %>',
					on: {
						click: function(event) {
							if (confirm('<%= UnicodeLanguageUtil.get(pageContext, "are-you-sure-you-want-to-delete-this") %>')) {
								document.<portlet:namespace />fm.<portlet:namespace /><%= Constants.CMD %>.value = '<%= Constants.DELETE %>';
								document.<portlet:namespace />fm.<portlet:namespace />redirect.value = '<%= viewFolderURL.toString() %>';
								submitForm(document.<portlet:namespace />fm);
							}
						}
					}
				}
			);
		</c:if>

		var fileEntryToolbar = new A.Toolbar(
			{
				boundingBox: buttonRow,
				children: [fileEntryButtonGroup]
			}
		).render();

		buttonRow.setData('fileEntryToolbar', fileEntryToolbar);
	</c:if>

	<portlet:namespace />initRowsChecked();

	A.all('input[name=<portlet:namespace />rowIds]').on(
		'click',
		function(event) {
			<portlet:namespace />updateRowsChecked(event.currentTarget);
		}
	);
</aui:script>

<%
if (!portletId.equals(PortletKeys.TRASH)) {
	DLUtil.addPortletBreadcrumbEntries(fileEntry, request, renderResponse);
}
%>