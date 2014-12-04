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

package com.liferay.calendar.portlet;

import com.liferay.calendar.CalendarBookingDurationException;
import com.liferay.calendar.CalendarNameException;
import com.liferay.calendar.CalendarResourceCodeException;
import com.liferay.calendar.CalendarResourceNameException;
import com.liferay.calendar.DuplicateCalendarResourceException;
import com.liferay.calendar.NoSuchResourceException;
import com.liferay.calendar.model.Calendar;
import com.liferay.calendar.model.CalendarBooking;
import com.liferay.calendar.model.CalendarBookingConstants;
import com.liferay.calendar.model.CalendarNotificationTemplate;
import com.liferay.calendar.model.CalendarNotificationTemplateConstants;
import com.liferay.calendar.model.CalendarResource;
import com.liferay.calendar.notification.NotificationTemplateContextFactory;
import com.liferay.calendar.notification.NotificationTemplateType;
import com.liferay.calendar.notification.NotificationType;
import com.liferay.calendar.recurrence.Frequency;
import com.liferay.calendar.recurrence.PositionalWeekday;
import com.liferay.calendar.recurrence.Recurrence;
import com.liferay.calendar.recurrence.RecurrenceSerializer;
import com.liferay.calendar.recurrence.Weekday;
import com.liferay.calendar.service.CalendarBookingLocalServiceUtil;
import com.liferay.calendar.service.CalendarBookingServiceUtil;
import com.liferay.calendar.service.CalendarLocalServiceUtil;
import com.liferay.calendar.service.CalendarNotificationTemplateServiceUtil;
import com.liferay.calendar.service.CalendarResourceLocalServiceUtil;
import com.liferay.calendar.service.CalendarResourceServiceUtil;
import com.liferay.calendar.service.CalendarServiceUtil;
import com.liferay.calendar.service.impl.CalendarLocalServiceImpl;
import com.liferay.calendar.service.permission.CalendarPermission;
import com.liferay.calendar.util.ActionKeys;
import com.liferay.calendar.util.CalendarDataFormat;
import com.liferay.calendar.util.CalendarDataHandler;
import com.liferay.calendar.util.CalendarDataHandlerFactory;
import com.liferay.calendar.util.CalendarResourceUtil;
import com.liferay.calendar.util.CalendarUtil;
import com.liferay.calendar.util.ICSFileGenerator;
import com.liferay.calendar.util.JCalendarUtil;
import com.liferay.calendar.util.PortletKeys;
import com.liferay.calendar.util.RSSUtil;
import com.liferay.calendar.util.WebKeys;
import com.liferay.calendar.util.comparator.CalendarResourceNameComparator;
import com.liferay.calendar.workflow.CalendarBookingWorkflowConstants;
import com.liferay.portal.kernel.dao.orm.QueryUtil;
import com.liferay.portal.kernel.dao.search.SearchContainer;
import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.exception.SystemException;
import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.portlet.PortletResponseUtil;
import com.liferay.portal.kernel.repository.model.FileEntry;
import com.liferay.portal.kernel.servlet.SessionErrors;
import com.liferay.portal.kernel.upload.UploadPortletRequest;
import com.liferay.portal.kernel.util.CalendarFactoryUtil;
import com.liferay.portal.kernel.util.CharPool;
import com.liferay.portal.kernel.util.Constants;
import com.liferay.portal.kernel.util.ContentTypes;
import com.liferay.portal.kernel.util.FileUtil;
import com.liferay.portal.kernel.util.GetterUtil;
import com.liferay.portal.kernel.util.HttpUtil;
import com.liferay.portal.kernel.util.LocalizationUtil;
import com.liferay.portal.kernel.util.MimeTypesUtil;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.StringPool;
import com.liferay.portal.kernel.util.StringUtil;
import com.liferay.portal.kernel.util.Time;
import com.liferay.portal.kernel.util.TimeZoneUtil;
import com.liferay.portal.kernel.util.UnicodeProperties;
import com.liferay.portal.kernel.util.Validator;
import com.liferay.portal.kernel.uuid.PortalUUIDUtil;
import com.liferay.portal.model.Group;
import com.liferay.portal.model.User;
import com.liferay.portal.security.auth.PrincipalException;
import com.liferay.portal.security.permission.PermissionChecker;
import com.liferay.portal.service.GroupLocalServiceUtil;
import com.liferay.portal.service.ServiceContext;
import com.liferay.portal.service.ServiceContextFactory;
import com.liferay.portal.service.SubscriptionLocalServiceUtil;
import com.liferay.portal.service.UserLocalServiceUtil;
import com.liferay.portal.theme.ThemeDisplay;
import com.liferay.portal.util.PortalUtil;
import com.liferay.portal.util.comparator.UserFirstNameComparator;
import com.liferay.portlet.messageboards.model.MBMessage;
import com.liferay.portlet.messageboards.service.MBMessageServiceUtil;
import com.liferay.util.bridges.mvc.MVCPortlet;
import com.liferay.util.dao.orm.CustomSQLUtil;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.HashMap;
import java.util.TimeZone;
import java.io.OutputStream;
import java.net.URL;
import java.net.URI;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletException;
import javax.portlet.PortletPreferences;
import javax.portlet.PortletRequest;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;
import javax.portlet.ResourceRequest;
import javax.portlet.ResourceResponse;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.util.PropsUtil;
import com.liferay.portlet.asset.model.AssetEntry;
import com.liferay.portlet.asset.model.AssetLink;
import com.liferay.portlet.asset.model.AssetRenderer;
import com.liferay.portlet.asset.model.AssetRendererFactory;
import com.liferay.portlet.asset.service.AssetEntryLocalServiceUtil;
import com.liferay.portlet.asset.service.AssetLinkLocalServiceUtil;
import com.liferay.portlet.asset.AssetRendererFactoryRegistryUtil;
import com.liferay.portlet.documentlibrary.model.DLFileEntry;
import com.liferay.portlet.documentlibrary.service.DLFileEntryLocalServiceUtil;
import com.liferay.portlet.documentlibrary.util.DLUtil;
import com.liferay.portal.kernel.portlet.LiferayPortletURL;
import com.liferay.portal.kernel.portlet.LiferayWindowState;
import com.liferay.portal.kernel.portlet.LiferayPortletRequest;
import com.liferay.portal.kernel.portlet.LiferayPortletResponse;

import com.liferay.portlet.documentlibrary.service.DLAppLocalServiceUtil;

import javax.portlet.WindowState;

import com.liferay.portal.model.Layout;
import com.liferay.portal.service.LayoutLocalServiceUtil;

import javax.portlet.PortletURL;
import javax.portlet.PortletMode;

import org.apache.commons.lang.ArrayUtils;

import com.liferay.portlet.PortletURLFactoryUtil;
import com.liferay.util.portlet.PortletProps;
import com.liferay.portal.service.TeamLocalServiceUtil;
import com.liferay.portal.model.Team;
import com.liferay.calendar.util.CalendarBookingComparator;
import com.liferay.portal.service.UserGroupRoleLocalServiceUtil;

/**
 * @author Eduardo Lundgren
 * @author Fabio Pezzutto
 * @author Andrea Di Giorgi
 * @author Marcellus Tavares
 * @author Bruno Basto
 * @author Pier Paolo Ramon
 */
public class CalendarPortlet extends MVCPortlet {

	protected static Log	_log	= LogFactoryUtil.getLog(CalendarPortlet.class);

	public void deleteCalendar(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {

		long calendarId = ParamUtil.getLong(actionRequest, "calendarId");

		CalendarServiceUtil.deleteCalendar(calendarId);
	}

	public void deleteCalendarResource(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {

		long calendarResourceId = ParamUtil.getLong(actionRequest, "calendarResourceId");

		CalendarResourceServiceUtil.deleteCalendarResource(calendarResourceId);
	}

	@Override
	public void init() throws PortletException {
		super.init();

		NotificationTemplateContextFactory.setPortletConfig(getPortletConfig());
	}

	public void invokeTransition(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {

		long calendarBookingId = ParamUtil.getLong(actionRequest, "calendarBookingId");

		int status = ParamUtil.getInteger(actionRequest, "status");

		ServiceContext serviceContext = ServiceContextFactory.getInstance(CalendarBooking.class.getName(), actionRequest);

		CalendarBookingServiceUtil.invokeTransition(calendarBookingId, status, serviceContext);
	}

	public void moveCalendarBookingToTrash(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {

		long calendarBookingId = ParamUtil.getLong(actionRequest, "calendarBookingId");

		CalendarBookingServiceUtil.moveCalendarBookingToTrash(calendarBookingId);
	}

	@Override
	public void render(RenderRequest renderRequest, RenderResponse renderResponse) throws IOException, PortletException {

		try {
			getCalendar(renderRequest);
			getCalendarBooking(renderRequest);
			getCalendarResource(renderRequest);
		} catch (Exception e) {
			if (e instanceof NoSuchResourceException || e instanceof PrincipalException) {

				SessionErrors.add(renderRequest, e.getClass());
			} else {
				throw new PortletException(e);
			}
		}

		super.render(renderRequest, renderResponse);
	}

	@Override
	public void serveResource(ResourceRequest resourceRequest, ResourceResponse resourceResponse) throws PortletException {

		try {
			final String resourceID = resourceRequest.getResourceID();

			if ("calendarBookingInvitees".equals(resourceID)) {
				serveCalendarBookingInvitees(resourceRequest, resourceResponse);
			} else if ("calendarBookings".equals(resourceID)) {
				serveCalendarBookings(resourceRequest, resourceResponse);
			} else if ("calendarBookingsRSS".equals(resourceID)) {
				serveCalendarBookingsRSS(resourceRequest, resourceResponse);
			} else if ("calendarRenderingRules".equals(resourceID)) {
				serveCalendarRenderingRules(resourceRequest, resourceResponse);
			} else if ("calendarResources".equals(resourceID)) {
				serveCalendarResources(resourceRequest, resourceResponse);
			} else if ("exportCalendar".equals(resourceID)) {
				serveExportCalendar(resourceRequest, resourceResponse);
			} else if ("importCalendar".equals(resourceID)) {
				serveImportCalendar(resourceRequest, resourceResponse);
			} else if ("resourceCalendars".equals(resourceID)) {
				serveResourceCalendars(resourceRequest, resourceResponse);
			} else if ("calendarICS".equals(resourceID)) {
				serveICSCalendar(resourceRequest, resourceResponse);
			} else if ("calendarBookingQuestionnaire".equals(resourceID)) {
				// ///////////////////////////////
				// USER CLIQUE SUR UN EVENEMENT //
				// ///////////////////////////////

				final long calendarBookingId = ParamUtil.getLong(resourceRequest, "calendarBookingId");
				final CalendarBooking calendarBooking = CalendarBookingLocalServiceUtil.getCalendarBooking(calendarBookingId);
				// write as json
				final StringBuilder response = new StringBuilder();
				// Open JSON flux
				response.append("{");

				response.append("\"surveyId\" : \"" + calendarBooking.getExpandoBridge().getAttribute("surveyId") + "\"");

				// Close JSON flux
				response.append("}");
				resourceResponse.getPortletOutputStream().write(response.toString().getBytes());
			} else if ("calendarBookingPresence".equals(resourceID)) {
				// ////////////////////////////////////
				// USER ACCEPTE/DECLINE L'INVITATION //
				// ////////////////////////////////////
				long calendarBookingId = ParamUtil.getLong(resourceRequest, "calendarBookingId");
				int status = ParamUtil.getInteger(resourceRequest, "status");
				ServiceContext serviceContext = ServiceContextFactory.getInstance(CalendarBooking.class.getName(), resourceRequest);
				CalendarBookingServiceUtil.invokeTransition(calendarBookingId, status, serviceContext);
				// write as json
				final StringBuilder response = new StringBuilder();
				// Open JSON flux
				response.append("{");

				response.append("\"status\" : \"" + status + "\"");

				// Close JSON flux
				response.append("}");
				resourceResponse.getPortletOutputStream().write(response.toString().getBytes());
			} else if ("calendarBookingRelatedAsset".equals(resourceID)) {
				// /////////////////////
				// GET RELATED ASSETS //
				// /////////////////////

				final String mesDocumentsURL = GetterUtil.getString(PortletProps.get("espace.elus.mes.documents.url"));

				final ThemeDisplay themeDisplay = (ThemeDisplay) resourceRequest.getAttribute(WebKeys.THEME_DISPLAY);
				final long calendarBookingId = ParamUtil.getLong(resourceRequest, "calendarBookingId");
				final AssetEntry layoutAssetEntry = AssetEntryLocalServiceUtil.getEntry(CalendarBooking.class.getName(), calendarBookingId);
				final long assetEntryId = layoutAssetEntry.getEntryId();

				//
				if (assetEntryId > 0) {
					// write as json
					final StringBuilder response = new StringBuilder();

					// Open JSON flux
					response.append("{");

					response.append("\"entryId\" : \"" + assetEntryId + "\"");

					response.append(",");
					response.append("\"entries\": [");

					String urlsAsJSON = "";

					final List<AssetLink> assetLinks = AssetLinkLocalServiceUtil.getDirectLinks(assetEntryId);
					for (final AssetLink assetLink : assetLinks) {
						AssetEntry assetLinkEntry = null;
						if (assetLink.getEntryId1() == assetEntryId) {
							assetLinkEntry = AssetEntryLocalServiceUtil.getEntry(assetLink.getEntryId2());
						} else {
							assetLinkEntry = AssetEntryLocalServiceUtil.getEntry(assetLink.getEntryId1());
						}
						assetLinkEntry = assetLinkEntry.toEscapedModel();
//						final String className = PortalUtil.getClassName(assetLinkEntry.getClassNameId());
//						final AssetRendererFactory assetRendererFactory = AssetRendererFactoryRegistryUtil.getAssetRendererFactoryByClassName(className);
//						if (Validator.isNull(assetRendererFactory)) {
//							if (_log.isWarnEnabled()) {
//								_log.warn("No asset renderer factory found for class " + className);
//							}
//
//							continue;
//						}
//						final AssetRenderer assetRenderer = assetRendererFactory.getAssetRenderer(assetLinkEntry.getClassPK());
//						final String asseLinktEntryTitle = assetLinkEntry.getTitle(resourceRequest.getLocale());
//						Layout layout = LayoutLocalServiceUtil.getFriendlyURLLayout(themeDisplay.getLayout().getGroupId(), false,
//								(mesDocumentsURL == null || mesDocumentsURL.isEmpty()) ? "/mes-documents" : mesDocumentsURL);
//						PortletURL portletURL = PortletURLFactoryUtil.create(resourceRequest, PortletKeys.DOCUMENT_LIBRARY_DISPLAY, layout.getPlid(), PortletRequest.RENDER_PHASE);
//						portletURL.setWindowState(WindowState.MAXIMIZED);
//						portletURL.setPortletMode(PortletMode.VIEW);
//						portletURL.setParameter("struts_action", "document_library_display/view_file_entry");
//						// portletURL.setParameter("redirect", currentURL);
//						portletURL.setParameter("fileEntryId", String.valueOf(assetLinkEntry.getClassPK()));

						final DLFileEntry dlFileEntry = DLFileEntryLocalServiceUtil.getFileEntry(assetLinkEntry.getClassPK());
						FileEntry fileEntry = DLAppLocalServiceUtil.getFileEntry(dlFileEntry.getFileEntryId());
						fileEntry = fileEntry.toEscapedModel();
						final URL url = new URL(DLUtil.getPreviewURL(fileEntry, fileEntry.getFileVersion(), themeDisplay, ""));
						final URI uri = new URI(url.getProtocol(), url.getUserInfo(), url.getHost(), url.getPort(), url.getPath(), url.getQuery(), url.getRef());
						
						urlsAsJSON += "{";
						urlsAsJSON += "\"assetLinkEntry\" : " + "\"" + assetLinkEntry.getEntryId() + "\"" + ",";
						urlsAsJSON += "\"assetLinkEntryTitle\" : " + "\"" + assetLinkEntry.getTitle(resourceRequest.getLocale()) + "\"" + ",";
						urlsAsJSON += "\"assetLinkEntryURL\" : " + "\"" + uri.toURL().toString() + "\"";
						urlsAsJSON += "},";
					}

					if (!urlsAsJSON.equals("")) {
						response.append(urlsAsJSON.substring(0, urlsAsJSON.length() - 1));
					}

					response.append("]");

					// Close JSON flux
					response.append("}");

					resourceResponse.getPortletOutputStream().write(response.toString().getBytes());
				}
			} else if ("serveCalendarBookingsAsset".equals(resourceID)) {
				serveCalendarBookingsAsset(resourceRequest, resourceResponse);
			} else {
				super.serveResource(resourceRequest, resourceResponse);
			}
		} catch (final Exception e) {
			throw new PortletException(e);
		}
	}

	/**
	 * Generate ICS file with all events where current user is invited.
	 * ICS File name is user portal login.
	 * @param resourceRequest
	 * @param resourceResponse
	 * @throws SystemException
	 * @throws SystemException
	 * @throws SystemException
	 * @throws com.liferay.calendar.util.PortalException
	 * @throws com.liferay.calendar.util.SystemException
	 * @throws SystemException
	 * @throws IOException
	 */
	private void serveICSCalendar(ResourceRequest resourceRequest, ResourceResponse resourceResponse) throws Exception {
		final ThemeDisplay themeDisplay = (ThemeDisplay) resourceRequest.getAttribute(WebKeys.THEME_DISPLAY);
		final User user = themeDisplay.getUser();
		final List<Calendar> calendars = CalendarLocalServiceUtil.getCalendars(QueryUtil.ALL_POS, QueryUtil.ALL_POS);
		final List<CalendarBooking> userCalendarBookings = new ArrayList<CalendarBooking>();
		for (final Calendar c : calendars) {
			final List<CalendarBooking> calendarBookings = CalendarBookingLocalServiceUtil.getCalendarBookings(c.getCalendarId());
			for (final CalendarBooking cb : calendarBookings) {
				final List<CalendarBooking> childCalendarBookings = CalendarBookingLocalServiceUtil.getChildCalendarBookings(cb.getCalendarBookingId());
				final Collection<CalendarResource> calendarResources = CalendarUtil.getCalendarResources(childCalendarBookings);
				for (final CalendarResource calendarResource : calendarResources) {
					final Calendar defaultCalendar = calendarResource.getDefaultCalendar();
					if (calendarResource.isUser() && defaultCalendar.getUserId() == user.getUserId()) {
						_log.debug("user - userId : " + defaultCalendar.getUserId());
						_log.debug("user - userName : " + defaultCalendar.getUserName());
						_log.debug("event title : " + cb.getTitle(resourceRequest.getLocale()));
						userCalendarBookings.add(cb);
					}
				}
			}
		}
		// Generate ics file
		final String filePath = PropsUtil.get("dl.store.file.system.root.dir") + "/ics";
		final File icsFile = ICSFileGenerator.createCalEntry(filePath, user.getScreenName(), userCalendarBookings);
		if (icsFile != null) {
			resourceResponse.setContentType("text/Calendar");
			resourceResponse.setProperty("Content-Disposition", "attachment; filename=" + icsFile.getName());
			final OutputStream pos = resourceResponse.getPortletOutputStream();
			pos.write(ICSFileGenerator.getFileBytes(icsFile));
		} else {
			super.serveResource(resourceRequest, resourceResponse);
		}
	}

	public void updateCalendar(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {

		long calendarId = ParamUtil.getLong(actionRequest, "calendarId");

		long calendarResourceId = ParamUtil.getLong(actionRequest, "calendarResourceId");
		Map<Locale, String> nameMap = LocalizationUtil.getLocalizationMap(actionRequest, "name");
		Map<Locale, String> descriptionMap = LocalizationUtil.getLocalizationMap(actionRequest, "description");
		int color = ParamUtil.getInteger(actionRequest, "color");
		boolean defaultCalendar = ParamUtil.getBoolean(actionRequest, "defaultCalendar");
		boolean enableComments = ParamUtil.getBoolean(actionRequest, "enableComments");
		boolean enableRatings = ParamUtil.getBoolean(actionRequest, "enableRatings");

		ServiceContext serviceContext = ServiceContextFactory.getInstance(Calendar.class.getName(), actionRequest);

		Calendar calendar = null;

		if (calendarId <= 0) {
			CalendarResource calendarResource = CalendarResourceServiceUtil.getCalendarResource(calendarResourceId);

			calendar = CalendarServiceUtil.addCalendar(calendarResource.getGroupId(), calendarResourceId, nameMap, descriptionMap, color, defaultCalendar, enableComments, enableRatings,
					serviceContext);
		} else {
			calendar = CalendarServiceUtil.updateCalendar(calendarId, nameMap, descriptionMap, color, defaultCalendar, enableComments, enableRatings, serviceContext);
		}

		String redirect = getEditCalendarURL(actionRequest, actionResponse, calendar);

		actionRequest.setAttribute(WebKeys.REDIRECT, redirect);
	}

	public void updateCalendarBooking(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {

		final String questionnaireId = ParamUtil.getString(actionRequest, "questionnaireId");

		//
		ServiceContext serviceContext = ServiceContextFactory.getInstance(CalendarBooking.class.getName(), actionRequest);

		long calendarBookingId = ParamUtil.getLong(actionRequest, "calendarBookingId");

		long calendarId = ParamUtil.getLong(actionRequest, "calendarId");

		final Calendar calendar = CalendarLocalServiceUtil.getCalendar(calendarId);

		long[] childCalendarIds = ParamUtil.getLongValues(actionRequest, "childCalendarIds");
		Map<Locale, String> titleMap = LocalizationUtil.getLocalizationMap(actionRequest, "title");
		Map<Locale, String> descriptionMap = LocalizationUtil.getLocalizationMap(actionRequest, "description");
		String location = ParamUtil.getString(actionRequest, "location");
		java.util.Calendar startTimeJCalendar = getJCalendar(actionRequest, "startTime");
		java.util.Calendar endTimeJCalendar = getJCalendar(actionRequest, "endTime");
		boolean allDay = ParamUtil.getBoolean(actionRequest, "allDay");
		String recurrence = getRecurrence(actionRequest);
		long[] reminders = getReminders(actionRequest);
		String[] remindersType = getRemindersType(actionRequest);
		final int status = 0; // ParamUtil.getInteger(actionRequest, "status");

		final List<Calendar> userCalendarIds = new ArrayList<Calendar>();
		for (final long childCalendarId : childCalendarIds) {
			final Calendar childCalendar = CalendarLocalServiceUtil.getCalendar(childCalendarId);
			if (childCalendar.getCalendarResource().getClassNameId() == PortalUtil.getClassNameId(Team.class)) {
				final List<User> users = UserLocalServiceUtil.getTeamUsers(childCalendar.getCalendarResource().getClassPK());
				for (final User user : users) {
					final CalendarResource userCalendarResource = CalendarResourceUtil.getUserCalendarResource(user.getUserId(), serviceContext);
					if (userCalendarResource != null) {
						final List<Calendar> userCalendars = CalendarServiceUtil.search(calendar.getCompanyId(), null, new long[] { userCalendarResource.getCalendarResourceId() }, null, true,
								QueryUtil.ALL_POS, QueryUtil.ALL_POS, null);
						userCalendarIds.addAll(userCalendars);
					}
				}
			}
		}

		final long[] newChildCalendarIds = new long[userCalendarIds.size() + childCalendarIds.length];
		int index = 0;
		for (final long childCalendarId : childCalendarIds) {
			final Calendar childCalendar = CalendarLocalServiceUtil.getCalendar(childCalendarId);
			if (childCalendarId > 0 && childCalendar.getCalendarResource().getClassNameId() != PortalUtil.getClassNameId(Team.class)) {
				newChildCalendarIds[index] = childCalendarId;
				index++;
			}
		}
		for (final Calendar c : userCalendarIds) {
			if (c.getCalendarId() > 0) {
				newChildCalendarIds[index] = c.getCalendarId();
				index++;
			}
		}

		childCalendarIds = newChildCalendarIds;

		CalendarBooking calendarBooking = null;

		if (calendarBookingId <= 0) {
			calendarBooking = CalendarBookingServiceUtil.addCalendarBooking(calendarId, childCalendarIds, CalendarBookingConstants.PARENT_CALENDAR_BOOKING_ID_DEFAULT, titleMap, descriptionMap,
					location, startTimeJCalendar.getTimeInMillis(), endTimeJCalendar.getTimeInMillis(), allDay, recurrence, reminders[0], remindersType[0], reminders[1], remindersType[1],
					serviceContext);
		} else {
			int instanceIndex = ParamUtil.getInteger(actionRequest, "instanceIndex");

			boolean updateCalendarBookingInstance = ParamUtil.getBoolean(actionRequest, "updateCalendarBookingInstance");

			if (updateCalendarBookingInstance) {
				calendarBooking = CalendarBookingLocalServiceUtil.getCalendarBooking(calendarBookingId);

				boolean allFollowing = ParamUtil.getBoolean(actionRequest, "allFollowing");

				calendarBooking = CalendarBookingServiceUtil.updateCalendarBookingInstance(calendarBookingId, instanceIndex, calendarBooking.getCalendarId(), childCalendarIds, titleMap,
						descriptionMap, location, startTimeJCalendar.getTimeInMillis(), endTimeJCalendar.getTimeInMillis(), allDay, recurrence, allFollowing, reminders[0], remindersType[0],
						reminders[1], remindersType[1], status, serviceContext);
			} else {
				calendarBooking = CalendarBookingServiceUtil.getCalendarBookingInstance(calendarBookingId, instanceIndex);

				long duration = (endTimeJCalendar.getTimeInMillis() - startTimeJCalendar.getTimeInMillis());
				long offset = (startTimeJCalendar.getTimeInMillis() - calendarBooking.getStartTime());

				calendarBooking = CalendarBookingServiceUtil.getNewStartTimeAndDurationCalendarBooking(calendarBookingId, offset, duration);

				calendarBooking = CalendarBookingServiceUtil.updateCalendarBooking(calendarBookingId, calendarBooking.getCalendarId(), childCalendarIds, titleMap, descriptionMap, location,
						calendarBooking.getStartTime(), calendarBooking.getEndTime(), allDay, recurrence, reminders[0], remindersType[0], reminders[1], remindersType[1], status, serviceContext);
			}
		}

		calendarBooking.getExpandoBridge().setAttribute("surveyId", questionnaireId);

		final AssetEntry assetEntry = AssetEntryLocalServiceUtil.getEntry(PortalUtil.getClassName(10511L), calendarBooking.getCalendarBookingId());
		assetEntry.setVisible(true);
		AssetEntryLocalServiceUtil.updateAssetEntry(assetEntry);

		actionRequest.setAttribute(WebKeys.CALENDAR_BOOKING, calendarBooking);

		String redirect = getRedirect(actionRequest, actionResponse);

		redirect = HttpUtil.setParameter(redirect, actionResponse.getNamespace() + "calendarBookingId", calendarBooking.getCalendarBookingId());

		actionRequest.setAttribute(WebKeys.REDIRECT, redirect);
	}

	public void updateCalendarNotificationTemplate(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {

		long calendarNotificationTemplateId = ParamUtil.getLong(actionRequest, "calendarNotificationTemplateId");

		long calendarId = ParamUtil.getLong(actionRequest, "calendarId");
		NotificationType notificationType = NotificationType.parse(ParamUtil.getString(actionRequest, "notificationType"));
		NotificationTemplateType notificationTemplateType = NotificationTemplateType.parse(ParamUtil.getString(actionRequest, "notificationTemplateType"));
		String subject = ParamUtil.getString(actionRequest, "subject");
		String body = ParamUtil.getString(actionRequest, "body");

		ServiceContext serviceContext = ServiceContextFactory.getInstance(CalendarNotificationTemplate.class.getName(), actionRequest);

		if (calendarNotificationTemplateId <= 0) {
			CalendarNotificationTemplateServiceUtil.addCalendarNotificationTemplate(calendarId, notificationType, getNotificationTypeSettings(actionRequest, notificationType),
					notificationTemplateType, subject, body, serviceContext);
		} else {
			CalendarNotificationTemplateServiceUtil.updateCalendarNotificationTemplate(calendarNotificationTemplateId, getNotificationTypeSettings(actionRequest, notificationType), subject, body,
					serviceContext);
		}
	}

	public void updateCalendarResource(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {

		long calendarResourceId = ParamUtil.getLong(actionRequest, "calendarResourceId");

		long defaultCalendarId = ParamUtil.getLong(actionRequest, "defaultCalendarId");
		String code = ParamUtil.getString(actionRequest, "code");
		Map<Locale, String> nameMap = LocalizationUtil.getLocalizationMap(actionRequest, "name");
		Map<Locale, String> descriptionMap = LocalizationUtil.getLocalizationMap(actionRequest, "description");
		boolean active = ParamUtil.getBoolean(actionRequest, "active");

		_log.debug("calendarResourceId : " + calendarResourceId);
		_log.debug("code : " + code);
		_log.debug("name : " + nameMap.get(Locale.FRENCH));

		ServiceContext serviceContext = ServiceContextFactory.getInstance(CalendarResource.class.getName(), actionRequest);

		if (calendarResourceId <= 0) {
			CalendarResourceServiceUtil.addCalendarResource(serviceContext.getScopeGroupId(), PortalUtil.getClassNameId(CalendarResource.class), 0, PortalUUIDUtil.generate(), code, nameMap,
					descriptionMap, active, serviceContext);
		} else {
			CalendarResourceServiceUtil.updateCalendarResource(calendarResourceId, nameMap, descriptionMap, active, serviceContext);

			if (defaultCalendarId > 0) {
				CalendarLocalServiceUtil.updateCalendar(defaultCalendarId, true);
			}
		}
	}

	public void updateDiscussion(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {

		String cmd = ParamUtil.getString(actionRequest, Constants.CMD);

		if (cmd.equals(Constants.ADD) || cmd.equals(Constants.UPDATE)) {
			updateMessage(actionRequest);
		} else if (cmd.equals(Constants.DELETE)) {
			deleteMessage(actionRequest);
		} else if (cmd.equals(Constants.SUBSCRIBE_TO_COMMENTS)) {
			subscribeToComments(actionRequest, true);
		} else if (cmd.equals(Constants.UNSUBSCRIBE_FROM_COMMENTS)) {
			subscribeToComments(actionRequest, false);
		}
	}

	protected void addCalendarJSONObject(PortletRequest portletRequest, JSONArray jsonArray, long classNameId, long classPK) throws PortalException, SystemException {

		CalendarResource calendarResource = CalendarResourceUtil.getCalendarResource(portletRequest, classNameId, classPK);

		if (calendarResource == null) {
			_log.error("classPK : " + classPK + " / classNameId : " + classNameId);
			return;
		}

		ThemeDisplay themeDisplay = (ThemeDisplay) portletRequest.getAttribute(WebKeys.THEME_DISPLAY);

		PermissionChecker permissionChecker = themeDisplay.getPermissionChecker();

		List<Calendar> calendars = CalendarLocalServiceUtil.getCalendarResourceCalendars(calendarResource.getGroupId(), calendarResource.getCalendarResourceId());

		for (Calendar calendar : calendars) {
			if (!CalendarPermission.contains(permissionChecker, calendar, ActionKeys.VIEW)) {

				continue;
			}

			JSONObject jsonObject = CalendarUtil.toCalendarJSONObject(themeDisplay, calendar);

			jsonArray.put(jsonObject);
		}
	}

	protected void deleteMessage(ActionRequest actionRequest) throws Exception {
		long groupId = PortalUtil.getScopeGroupId(actionRequest);

		String className = ParamUtil.getString(actionRequest, "className");
		long classPK = ParamUtil.getLong(actionRequest, "classPK");
		String permissionClassName = ParamUtil.getString(actionRequest, "permissionClassName");
		long permissionClassPK = ParamUtil.getLong(actionRequest, "permissionClassPK");
		long permissionOwnerId = ParamUtil.getLong(actionRequest, "permissionOwnerId");

		long messageId = ParamUtil.getLong(actionRequest, "messageId");

		MBMessageServiceUtil.deleteDiscussionMessage(groupId, className, classPK, permissionClassName, permissionClassPK, permissionOwnerId, messageId);
	}

	@Override
	protected void doDispatch(RenderRequest renderRequest, RenderResponse renderResponse) throws IOException, PortletException {

		if (SessionErrors.contains(renderRequest, NoSuchResourceException.class.getName()) || SessionErrors.contains(renderRequest, PrincipalException.class.getName())) {

			include("/error.jsp", renderRequest, renderResponse);
		} else {
			super.doDispatch(renderRequest, renderResponse);
		}
	}

	protected void getCalendar(PortletRequest portletRequest) throws Exception {
		long calendarId = ParamUtil.getLong(portletRequest, "calendarId");

		if (calendarId <= 0) {
			return;
		}

		Calendar calendar = CalendarServiceUtil.getCalendar(calendarId);

		portletRequest.setAttribute(WebKeys.CALENDAR, calendar);
	}

	protected void getCalendarBooking(PortletRequest portletRequest) throws Exception {

		if (portletRequest.getAttribute(WebKeys.CALENDAR_BOOKING) != null) {
			return;
		}

		ThemeDisplay themeDisplay = (ThemeDisplay) portletRequest.getAttribute(WebKeys.THEME_DISPLAY);

		long calendarBookingId = ParamUtil.getLong(portletRequest, "calendarBookingId");

		if (calendarBookingId <= 0) {
			return;
		}

		CalendarBooking calendarBooking = CalendarBookingServiceUtil.getCalendarBooking(calendarBookingId);

		final AssetEntry layoutAssetEntry = AssetEntryLocalServiceUtil.getEntry(CalendarBooking.class.getName(), calendarBookingId);
		final long assetEntryId = layoutAssetEntry.getEntryId();

		portletRequest.setAttribute("CalendarBookingAssetEntryId", assetEntryId);

		Map<String, String> entries = new HashMap<String, String>();

		String mesDocumentsURL = null;

		final List<AssetLink> assetLinks = AssetLinkLocalServiceUtil.getDirectLinks(assetEntryId);
		for (final AssetLink assetLink : assetLinks) {
			AssetEntry assetLinkEntry = null;
			if (assetLink.getEntryId1() == assetEntryId) {
				assetLinkEntry = AssetEntryLocalServiceUtil.getEntry(assetLink.getEntryId2());
			} else {
				assetLinkEntry = AssetEntryLocalServiceUtil.getEntry(assetLink.getEntryId1());
			}
			assetLinkEntry = assetLinkEntry.toEscapedModel();
			final String className = PortalUtil.getClassName(assetLinkEntry.getClassNameId());
			final AssetRendererFactory assetRendererFactory = AssetRendererFactoryRegistryUtil.getAssetRendererFactoryByClassName(className);
			if (Validator.isNull(assetRendererFactory)) {
				if (_log.isWarnEnabled()) {
					_log.warn("No asset renderer factory found for class " + className);
				}

				continue;
			}
			final AssetRenderer assetRenderer = assetRendererFactory.getAssetRenderer(assetLinkEntry.getClassPK());
			final String asseLinktEntryTitle = assetLinkEntry.getTitle(portletRequest.getLocale());
			Layout layout = LayoutLocalServiceUtil.getFriendlyURLLayout(10184, false, (mesDocumentsURL == null || mesDocumentsURL.isEmpty()) ? "/mes-documents" : mesDocumentsURL);
			PortletURL portletURL = PortletURLFactoryUtil.create(portletRequest, PortletKeys.DOCUMENT_LIBRARY_DISPLAY, layout.getPlid(), PortletRequest.RENDER_PHASE);
			portletURL.setWindowState(WindowState.MAXIMIZED);
			portletURL.setPortletMode(PortletMode.VIEW);
			portletURL.setParameter("struts_action", "document_library_display/view_file_entry");
			portletURL.setParameter("fileEntryId", String.valueOf(assetLinkEntry.getClassPK()));

			entries.put(asseLinktEntryTitle, portletURL.toString());
		}

		portletRequest.setAttribute("calendarBookingEntries", entries);

		portletRequest.setAttribute(WebKeys.CALENDAR_BOOKING, calendarBooking);
	}

	protected void getCalendarResource(PortletRequest portletRequest) throws Exception {

		_log.debug("begin method getCalendarResource");

		long calendarResourceId = ParamUtil.getLong(portletRequest, "calendarResourceId");

		long classNameId = ParamUtil.getLong(portletRequest, "classNameId");
		long classPK = ParamUtil.getLong(portletRequest, "classPK");

		_log.debug("calendarResourceId : " + calendarResourceId);
		_log.debug("classNameId : " + classNameId);
		_log.debug("classPK : " + classPK);

		CalendarResource calendarResource = null;

		if (calendarResourceId > 0) {
			calendarResource = CalendarResourceServiceUtil.getCalendarResource(calendarResourceId);
		} else if ((classNameId > 0) && (classPK > 0)) {
			calendarResource = CalendarResourceUtil.getCalendarResource(portletRequest, classNameId, classPK);
		}

		portletRequest.setAttribute(WebKeys.CALENDAR_RESOURCE, calendarResource);

		_log.debug("end method getCalendarResource");
	}

	protected String getEditCalendarURL(ActionRequest actionRequest, ActionResponse actionResponse, Calendar calendar) throws Exception {

		ThemeDisplay themeDisplay = (ThemeDisplay) actionRequest.getAttribute(WebKeys.THEME_DISPLAY);

		String editCalendarURL = getRedirect(actionRequest, actionResponse);

		if (Validator.isNull(editCalendarURL)) {
			editCalendarURL = PortalUtil.getLayoutFullURL(themeDisplay);
		}

		String namespace = actionResponse.getNamespace();

		editCalendarURL = HttpUtil.setParameter(editCalendarURL, "p_p_id", PortletKeys.CALENDAR);
		editCalendarURL = HttpUtil.setParameter(editCalendarURL, namespace + "mvcPath", templatePath + "edit_calendar.jsp");
		editCalendarURL = HttpUtil.setParameter(editCalendarURL, namespace + "redirect", getRedirect(actionRequest, actionResponse));
		editCalendarURL = HttpUtil.setParameter(editCalendarURL, namespace + "backURL", ParamUtil.getString(actionRequest, "backURL"));
		editCalendarURL = HttpUtil.setParameter(editCalendarURL, namespace + "calendarId", calendar.getCalendarId());

		return editCalendarURL;
	}

	protected java.util.Calendar getJCalendar(PortletRequest portletRequest, String name) {

		int month = ParamUtil.getInteger(portletRequest, name + "Month");
		int day = ParamUtil.getInteger(portletRequest, name + "Day");
		int year = ParamUtil.getInteger(portletRequest, name + "Year");
		int hour = ParamUtil.getInteger(portletRequest, name + "Hour");
		int minute = ParamUtil.getInteger(portletRequest, name + "Minute");

		int amPm = ParamUtil.getInteger(portletRequest, name + "AmPm");

		if (amPm == java.util.Calendar.PM) {
			hour += 12;
		}

		return JCalendarUtil.getJCalendar(year, month, day, hour, minute, 0, 0, getTimeZone(portletRequest));
	}

	protected String getNotificationTypeSettings(ActionRequest actionRequest, NotificationType notificationType) {

		UnicodeProperties notificationTypeSettingsProperties = new UnicodeProperties(true);

		if (notificationType == NotificationType.EMAIL) {
			String fromAddress = ParamUtil.getString(actionRequest, "fromAddress");
			String fromName = ParamUtil.getString(actionRequest, "fromName");

			notificationTypeSettingsProperties.put(CalendarNotificationTemplateConstants.PROPERTY_FROM_ADDRESS, fromAddress);
			notificationTypeSettingsProperties.put(CalendarNotificationTemplateConstants.PROPERTY_FROM_NAME, fromName);
		}

		return notificationTypeSettingsProperties.toString();
	}

	protected String getRecurrence(ActionRequest actionRequest) {
		boolean repeat = ParamUtil.getBoolean(actionRequest, "repeat");

		if (!repeat) {
			return null;
		}

		Recurrence recurrence = new Recurrence();

		int count = 0;

		String ends = ParamUtil.getString(actionRequest, "ends");

		if (ends.equals("after")) {
			count = ParamUtil.getInteger(actionRequest, "count");
		}

		recurrence.setCount(count);

		Frequency frequency = Frequency.parse(ParamUtil.getString(actionRequest, "frequency"));

		recurrence.setFrequency(frequency);

		int interval = ParamUtil.getInteger(actionRequest, "interval");

		recurrence.setInterval(interval);

		java.util.Calendar untilJCalendar = null;

		if (ends.equals("on")) {
			int untilDateDay = ParamUtil.getInteger(actionRequest, "untilDateDay");
			int untilDateMonth = ParamUtil.getInteger(actionRequest, "untilDateMonth");
			int untilDateYear = ParamUtil.getInteger(actionRequest, "untilDateYear");

			untilJCalendar = CalendarFactoryUtil.getCalendar();

			untilJCalendar.set(java.util.Calendar.DATE, untilDateDay);
			untilJCalendar.set(java.util.Calendar.MONTH, untilDateMonth);
			untilJCalendar.set(java.util.Calendar.YEAR, untilDateYear);
		}

		recurrence.setUntilJCalendar(untilJCalendar);

		List<PositionalWeekday> positionalWeekdays = new ArrayList<PositionalWeekday>();

		if (frequency == Frequency.WEEKLY) {
			for (Weekday weekday : Weekday.values()) {
				boolean checked = ParamUtil.getBoolean(actionRequest, weekday.getValue());

				if (checked) {
					positionalWeekdays.add(new PositionalWeekday(weekday, 0));
				}
			}
		} else if ((frequency == Frequency.MONTHLY) || (frequency == Frequency.YEARLY)) {

			boolean repeatOnWeekday = ParamUtil.getBoolean(actionRequest, "repeatOnWeekday");

			if (repeatOnWeekday) {
				int position = ParamUtil.getInteger(actionRequest, "position");

				Weekday weekday = Weekday.parse(ParamUtil.getString(actionRequest, "weekday"));

				positionalWeekdays.add(new PositionalWeekday(weekday, position));
			}
		}

		recurrence.setPositionalWeekdays(positionalWeekdays);

		String[] exceptionDates = StringUtil.split(ParamUtil.getString(actionRequest, "exceptionDates"));

		for (String exceptionDate : exceptionDates) {
			recurrence.addExceptionDate(JCalendarUtil.getJCalendar(Long.valueOf(exceptionDate)));
		}

		return RecurrenceSerializer.serialize(recurrence);
	}

	protected long[] getReminders(PortletRequest portletRequest) {
		long firstReminder = ParamUtil.getInteger(portletRequest, "reminderValue0");
		long firstReminderDuration = ParamUtil.getInteger(portletRequest, "reminderDuration0");
		long secondReminder = ParamUtil.getInteger(portletRequest, "reminderValue1");
		long secondReminderDuration = ParamUtil.getInteger(portletRequest, "reminderDuration1");

		return new long[] { firstReminder * firstReminderDuration * Time.SECOND, secondReminder * secondReminderDuration * Time.SECOND };
	}

	protected String[] getRemindersType(PortletRequest portletRequest) {
		String firstReminderType = ParamUtil.getString(portletRequest, "reminderType0");
		String secondReminderType = ParamUtil.getString(portletRequest, "reminderType1");

		return new String[] { firstReminderType, secondReminderType };
	}

	protected TimeZone getTimeZone(PortletRequest portletRequest) {
		ThemeDisplay themeDisplay = (ThemeDisplay) portletRequest.getAttribute(WebKeys.THEME_DISPLAY);

		boolean allDay = ParamUtil.getBoolean(portletRequest, "allDay");

		if (allDay) {
			return TimeZoneUtil.getTimeZone(StringPool.UTC);
		}

		PortletPreferences preferences = portletRequest.getPreferences();

		User user = themeDisplay.getUser();

		String timeZoneId = preferences.getValue("timeZoneId", user.getTimeZoneId());

		if (Validator.isNull(timeZoneId)) {
			timeZoneId = user.getTimeZoneId();
		}

		return TimeZone.getTimeZone(timeZoneId);
	}

	@Override
	protected boolean isSessionErrorException(Throwable cause) {
		if (cause instanceof CalendarBookingDurationException || cause instanceof CalendarNameException || cause instanceof CalendarResourceCodeException
				|| cause instanceof CalendarResourceNameException || cause instanceof DuplicateCalendarResourceException || cause instanceof PrincipalException) {

			return true;
		}

		return false;
	}

	protected void serveCalendarBookingInvitees(ResourceRequest resourceRequest, ResourceResponse resourceResponse) throws Exception {

		ThemeDisplay themeDisplay = (ThemeDisplay) resourceRequest.getAttribute(WebKeys.THEME_DISPLAY);
		final User user = themeDisplay.getUser();
		final Long userId = user.getUserId();

		long parentCalendarBookingId = ParamUtil.getLong(resourceRequest, "parentCalendarBookingId");

		final CalendarBooking calendarBooking = CalendarBookingLocalServiceUtil.getCalendarBooking(parentCalendarBookingId);
		if (calendarBooking.getUserId() == userId) {

			JSONArray jsonArray = JSONFactoryUtil.createJSONArray();

			List<CalendarBooking> childCalendarBookings = CalendarBookingServiceUtil.getChildCalendarBookings(parentCalendarBookingId);

			Collection<CalendarResource> calendarResources = CalendarUtil.getCalendarResources(childCalendarBookings);

			for (CalendarResource calendarResource : calendarResources) {
				JSONObject jsonObject = CalendarUtil.toCalendarResourceJSONObject(themeDisplay, calendarResource);

				jsonArray.put(jsonObject);
			}

			writeJSON(resourceRequest, resourceResponse, jsonArray);
		}
	}

	protected void serveCalendarBookingsAsset(ResourceRequest resourceRequest, ResourceResponse resourceResponse) throws Exception {

		final ThemeDisplay themeDisplay = (ThemeDisplay) resourceRequest.getAttribute(WebKeys.THEME_DISPLAY);

		final String calendarIdsAsStr = ParamUtil.getString(resourceRequest, "calendarIds");
		_log.debug(calendarIdsAsStr);
		final String[] split = calendarIdsAsStr.split(",");
		final long[] calendarIds = new long[split.length - 1];
		int i = 0;
		for (final String s : split) {
			if (s != null && !s.isEmpty()) {
				calendarIds[i] = Long.valueOf(s);
				i++;
			}
		}

		final int[] statuses = new int[4];
		statuses[0] = 0;
		statuses[1] = 1;
		statuses[2] = 9;
		statuses[3] = 4;

		final java.util.Calendar startCalendar = java.util.Calendar.getInstance();
		startCalendar.add(java.util.Calendar.YEAR, -1);

		final java.util.Calendar endCalendar = java.util.Calendar.getInstance();
		endCalendar.add(java.util.Calendar.YEAR, 1);

		final List<CalendarBooking> calendarBookings = CalendarBookingServiceUtil.search(themeDisplay.getCompanyId(), new long[0], calendarIds, new long[0], -1, null, startCalendar.getTimeInMillis(),
				endCalendar.getTimeInMillis(), true, statuses, 0, 5, new CalendarBookingComparator());

		final JSONArray jsonArray = CalendarUtil.toCalendarBookingsJSONArray(themeDisplay, calendarBookings, getTimeZone(resourceRequest));

		writeJSON(resourceRequest, resourceResponse, jsonArray);
	}

	protected void serveCalendarBookings(ResourceRequest resourceRequest, ResourceResponse resourceResponse) throws Exception {

		final ThemeDisplay themeDisplay = (ThemeDisplay) resourceRequest.getAttribute(WebKeys.THEME_DISPLAY);

		final long currentUserId = themeDisplay.getUserId();
		
		final boolean isGestionnaireGlobal = UserGroupRoleLocalServiceUtil.hasUserGroupRole(currentUserId, themeDisplay.getScopeGroupId(), "gestionnaire-global", false);
		final boolean isGestionnaireSection = UserGroupRoleLocalServiceUtil.hasUserGroupRole(currentUserId, themeDisplay.getScopeGroupId(), "gestionnaire-section", false);

		final long[] calendarIds = ParamUtil.getLongValues(resourceRequest, "calendarIds");
		final long endTime = ParamUtil.getLong(resourceRequest, "endTime");
		final long startTime = ParamUtil.getLong(resourceRequest, "startTime");
		final int[] statuses = ParamUtil.getIntegerValues(resourceRequest, "statuses");

		final PermissionChecker permissionChecker = themeDisplay.getPermissionChecker();

		final List<CalendarBooking> calendarBookings = CalendarBookingServiceUtil.search(themeDisplay.getCompanyId(), new long[0], calendarIds, new long[0], -1, null, startTime, endTime, true, statuses,
				QueryUtil.ALL_POS, QueryUtil.ALL_POS, null);

		final List<CalendarBooking> calendarBookingsViewable = new ArrayList<CalendarBooking>();

		if (!permissionChecker.isOmniadmin() && !isGestionnaireGlobal && !isGestionnaireSection) {
			for (final CalendarBooking calendarBooking : calendarBookings) {
				final List<CalendarBooking> childCalendarBookings = calendarBooking.getChildCalendarBookings();
				for (final CalendarBooking childCalendarBooking : childCalendarBookings) {
					if (childCalendarBooking.getCalendarResource().getClassPK() == currentUserId) {
						calendarBookingsViewable.add(calendarBooking);
						break;
					}
				}
			}
		} else {
			// L'administrateur, le gestionnaire global et les gestionnaires de section peuvent voir les évènements même s'ils ne font pas partie des invités
			calendarBookingsViewable.addAll(calendarBookings);
		}

		JSONArray jsonArray = CalendarUtil.toCalendarBookingsJSONArray(themeDisplay, calendarBookingsViewable, getTimeZone(resourceRequest));

		writeJSON(resourceRequest, resourceResponse, jsonArray);
	}

	protected void serveCalendarBookingsRSS(ResourceRequest resourceRequest, ResourceResponse resourceResponse) throws Exception {

		if (!PortalUtil.isRSSFeedsEnabled()) {
			PortalUtil.sendRSSFeedsDisabledError(resourceRequest, resourceResponse);

			return;
		}

		ThemeDisplay themeDisplay = (ThemeDisplay) resourceRequest.getAttribute(WebKeys.THEME_DISPLAY);

		long calendarId = ParamUtil.getLong(resourceRequest, "calendarId");

		PortletPreferences portletPreferences = resourceRequest.getPreferences();

		long timeInterval = GetterUtil.getLong(portletPreferences.getValue("rssTimeInterval", StringPool.BLANK), RSSUtil.TIME_INTERVAL_DEFAULT);

		long startTime = System.currentTimeMillis();

		long endTime = startTime + timeInterval;

		int max = GetterUtil.getInteger(portletPreferences.getValue("rssDelta", StringPool.BLANK), SearchContainer.DEFAULT_DELTA);
		String rssFeedType = portletPreferences.getValue("rssFeedType", RSSUtil.FORMAT_DEFAULT);
		String type = RSSUtil.getFormatType(rssFeedType);
		double version = RSSUtil.getFeedTypeVersion(rssFeedType);
		String displayStyle = portletPreferences.getValue("rssDisplayStyle", RSSUtil.DISPLAY_STYLE_DEFAULT);

		String rss = CalendarBookingServiceUtil.getCalendarBookingsRSS(calendarId, startTime, endTime, max, type, version, displayStyle, themeDisplay);

		PortletResponseUtil.sendFile(resourceRequest, resourceResponse, null, rss.getBytes(), ContentTypes.TEXT_XML_UTF8);
	}

	protected void serveCalendarRenderingRules(ResourceRequest resourceRequest, ResourceResponse resourceResponse) throws Exception {

		ThemeDisplay themeDisplay = (ThemeDisplay) resourceRequest.getAttribute(WebKeys.THEME_DISPLAY);

		long[] calendarIds = ParamUtil.getLongValues(resourceRequest, "calendarIds");
		int[] statuses = { CalendarBookingWorkflowConstants.STATUS_APPROVED, CalendarBookingWorkflowConstants.STATUS_MAYBE, CalendarBookingWorkflowConstants.STATUS_PENDING };
		long startTime = ParamUtil.getLong(resourceRequest, "startTime");
		long endTime = ParamUtil.getLong(resourceRequest, "endTime");
		String ruleName = ParamUtil.getString(resourceRequest, "ruleName");

		if (calendarIds.length > 0) {
			JSONObject jsonObject = CalendarUtil.getCalendarRenderingRules(themeDisplay, calendarIds, statuses, startTime, endTime, ruleName, getTimeZone(resourceRequest));

			writeJSON(resourceRequest, resourceResponse, jsonObject);
		}
	}

	protected void serveCalendarResources(ResourceRequest resourceRequest, ResourceResponse resourceResponse) throws Exception {

		ThemeDisplay themeDisplay = (ThemeDisplay) resourceRequest.getAttribute(WebKeys.THEME_DISPLAY);
		
		final User currentUser = themeDisplay.getUser();
		
		final boolean isGestionnaireGlobal = UserGroupRoleLocalServiceUtil.hasUserGroupRole(currentUser.getUserId(), themeDisplay.getScopeGroupId(), "gestionnaire-global", false);
		final PermissionChecker permissionChecker = themeDisplay.getPermissionChecker();

		String keywords = ParamUtil.getString(resourceRequest, "keywords");

		JSONArray jsonArray = JSONFactoryUtil.createJSONArray();

		long classNameId = PortalUtil.getClassNameId(CalendarResource.class);

		List<CalendarResource> calendarResources = CalendarResourceServiceUtil.search(themeDisplay.getCompanyId(), new long[] { themeDisplay.getCompanyGroupId(), themeDisplay.getScopeGroupId() },
				new long[] { classNameId }, keywords, true, true, 0, SearchContainer.DEFAULT_DELTA, new CalendarResourceNameComparator());

		for (CalendarResource calendarResource : calendarResources) {
			addCalendarJSONObject(resourceRequest, jsonArray, calendarResource.getClassNameId(), calendarResource.getClassPK());
		}

		long groupClassNameId = PortalUtil.getClassNameId(Group.class);

		List<CalendarResource> companyCalendarResources = CalendarResourceServiceUtil.search(themeDisplay.getCompanyId(), new long[] { themeDisplay.getCompanyGroupId() },
				new long[] { groupClassNameId }, keywords, true, true, 0, SearchContainer.DEFAULT_DELTA, new CalendarResourceNameComparator());

		for (CalendarResource calendarResource : companyCalendarResources) {
			addCalendarJSONObject(resourceRequest, jsonArray, calendarResource.getClassNameId(), calendarResource.getClassPK());
		}

		String name = StringUtil.merge(CustomSQLUtil.keywords(keywords), StringPool.BLANK);

		LinkedHashMap<String, Object> params = new LinkedHashMap<String, Object>();

		params.put("usersGroups", themeDisplay.getUserId());

		// Groups
		List<Group> groups = GroupLocalServiceUtil.search(themeDisplay.getCompanyId(), name, name, params, true, 0, SearchContainer.DEFAULT_DELTA);
		for (Group group : groups) {
			addCalendarJSONObject(resourceRequest, jsonArray, groupClassNameId, group.getGroupId());
		}

		// Users
		long userClassNameId = PortalUtil.getClassNameId(User.class);
		// status = -1 to search all users even inactive
		List<User> users = UserLocalServiceUtil.search(themeDisplay.getCompanyId(), keywords, -1, null, 0, SearchContainer.DEFAULT_DELTA, new UserFirstNameComparator());
		for (User user : users) {
			addCalendarJSONObject(resourceRequest, jsonArray, userClassNameId, user.getUserId());
		}

		// TEAM ELUS
		final long[] currentUserTeamIds = currentUser.getTeamIds();
		long teamClassNameId = PortalUtil.getClassNameId(Team.class);
		List<Team> teams = TeamLocalServiceUtil.getTeams(-1, -1);
		for (Team team : teams) {
			_log.debug("team : " + team.getTeamId());
			if (team.getName().toUpperCase().contains(keywords.toUpperCase()) && (ArrayUtils.contains(currentUserTeamIds, team.getTeamId()) || isGestionnaireGlobal || permissionChecker.isOmniadmin())) {
				_log.debug("team added : " + team.getTeamId());
				addCalendarJSONObject(resourceRequest, jsonArray, teamClassNameId, team.getTeamId());
			}
		}

		writeJSON(resourceRequest, resourceResponse, jsonArray);
	}

	protected void serveExportCalendar(ResourceRequest resourceRequest, ResourceResponse resourceResponse) throws Exception {

		ThemeDisplay themeDisplay = (ThemeDisplay) resourceRequest.getAttribute(WebKeys.THEME_DISPLAY);

		long calendarId = ParamUtil.getLong(resourceRequest, "calendarId");

		Calendar calendar = CalendarLocalServiceUtil.getCalendar(calendarId);

		String fileName = calendar.getName(themeDisplay.getLocale()) + CharPool.PERIOD + String.valueOf(CalendarDataFormat.ICAL);

		CalendarDataHandler calendarDataHandler = CalendarDataHandlerFactory.getCalendarDataHandler(CalendarDataFormat.ICAL);

		String data = calendarDataHandler.exportCalendar(calendarId);

		String contentType = MimeTypesUtil.getContentType(fileName);

		PortletResponseUtil.sendFile(resourceRequest, resourceResponse, fileName, data.getBytes(), contentType);
	}

	protected void serveImportCalendar(ResourceRequest resourceRequest, ResourceResponse resourceResponse) throws Exception {

		UploadPortletRequest uploadPortletRequest = PortalUtil.getUploadPortletRequest(resourceRequest);

		ThemeDisplay themeDisplay = (ThemeDisplay) resourceRequest.getAttribute(WebKeys.THEME_DISPLAY);

		long calendarId = ParamUtil.getLong(uploadPortletRequest, "calendarId");

		File file = uploadPortletRequest.getFile("file");

		String data = FileUtil.read(file);

		JSONObject jsonObject = JSONFactoryUtil.createJSONObject();

		if (Validator.isNotNull(data)) {
			try {
				CalendarDataHandler calendarDataHandler = CalendarDataHandlerFactory.getCalendarDataHandler(CalendarDataFormat.ICAL);

				calendarDataHandler.importCalendar(calendarId, data);

				jsonObject.put("success", true);
			} catch (Exception e) {
				String message = themeDisplay.translate("an-unexpected-error-occurred-while-importing-your-" + "file");

				jsonObject.put("error", message);
			}
		} else {
			String message = themeDisplay.translate("failed-to-import-empty-file");

			jsonObject.put("error", message);
		}

		writeJSON(resourceRequest, resourceResponse, jsonObject);
	}

	protected void serveResourceCalendars(ResourceRequest resourceRequest, ResourceResponse resourceResponse) throws Exception {

		_log.debug("begin method serveResourceCalendars");

		ThemeDisplay themeDisplay = (ThemeDisplay) resourceRequest.getAttribute(WebKeys.THEME_DISPLAY);

		long calendarResourceId = ParamUtil.getLong(resourceRequest, "calendarResourceId");

		_log.debug("calendarResourceId : " + calendarResourceId);

		List<Calendar> calendars = CalendarServiceUtil.search(themeDisplay.getCompanyId(), null, new long[] { calendarResourceId }, null, true, QueryUtil.ALL_POS, QueryUtil.ALL_POS, null);

		JSONArray jsonObject = CalendarUtil.toCalendarsJSONArray(themeDisplay, calendars);

		_log.debug("jsonObject : " + jsonObject);

		writeJSON(resourceRequest, resourceResponse, jsonObject);
	}

	protected void subscribeToComments(ActionRequest actionRequest, boolean subscribe) throws Exception {

		ThemeDisplay themeDisplay = (ThemeDisplay) actionRequest.getAttribute(WebKeys.THEME_DISPLAY);

		String className = ParamUtil.getString(actionRequest, "className");
		long classPK = ParamUtil.getLong(actionRequest, "classPK");

		if (subscribe) {
			SubscriptionLocalServiceUtil.addSubscription(themeDisplay.getUserId(), themeDisplay.getScopeGroupId(), className, classPK);
		} else {
			SubscriptionLocalServiceUtil.deleteSubscription(themeDisplay.getUserId(), className, classPK);
		}
	}

	protected MBMessage updateMessage(ActionRequest actionRequest) throws Exception {

		ThemeDisplay themeDisplay = (ThemeDisplay) actionRequest.getAttribute(WebKeys.THEME_DISPLAY);

		String className = ParamUtil.getString(actionRequest, "className");
		long classPK = ParamUtil.getLong(actionRequest, "classPK");
		String permissionClassName = ParamUtil.getString(actionRequest, "permissionClassName");
		long permissionClassPK = ParamUtil.getLong(actionRequest, "permissionClassPK");
		long permissionOwnerId = ParamUtil.getLong(actionRequest, "permissionOwnerId");

		long messageId = ParamUtil.getLong(actionRequest, "messageId");

		long threadId = ParamUtil.getLong(actionRequest, "threadId");
		long parentMessageId = ParamUtil.getLong(actionRequest, "parentMessageId");
		String subject = ParamUtil.getString(actionRequest, "subject");
		String body = ParamUtil.getString(actionRequest, "body");

		ServiceContext serviceContext = ServiceContextFactory.getInstance(MBMessage.class.getName(), actionRequest);

		MBMessage message = null;

		if (messageId <= 0) {
			message = MBMessageServiceUtil.addDiscussionMessage(serviceContext.getScopeGroupId(), className, classPK, permissionClassName, permissionClassPK, permissionOwnerId, threadId,
					parentMessageId, subject, body, serviceContext);
		} else {
			message = MBMessageServiceUtil.updateDiscussionMessage(className, classPK, permissionClassName, permissionClassPK, permissionOwnerId, messageId, subject, body, serviceContext);
		}

		// Subscription

		boolean subscribe = ParamUtil.getBoolean(actionRequest, "subscribe");

		if (subscribe) {
			SubscriptionLocalServiceUtil.addSubscription(themeDisplay.getUserId(), themeDisplay.getScopeGroupId(), className, classPK);
		}

		return message;
	}

}