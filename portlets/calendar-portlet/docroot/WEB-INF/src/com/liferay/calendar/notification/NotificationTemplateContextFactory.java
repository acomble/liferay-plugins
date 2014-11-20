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

package com.liferay.calendar.notification;

import com.liferay.calendar.model.Calendar;
import com.liferay.calendar.model.CalendarBooking;
import com.liferay.calendar.model.CalendarNotificationTemplate;
import com.liferay.calendar.service.CalendarNotificationTemplateLocalServiceUtil;
import com.liferay.calendar.util.PortletKeys;
import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.exception.SystemException;
import com.liferay.portal.kernel.language.LanguageUtil;
import com.liferay.portal.kernel.util.FastDateFormatFactoryUtil;
import com.liferay.portal.kernel.util.HttpUtil;
import com.liferay.portal.kernel.util.StringPool;
import com.liferay.portal.model.Company;
import com.liferay.portal.model.Group;
import com.liferay.portal.model.Layout;
import com.liferay.portal.model.User;
import com.liferay.portal.service.CompanyLocalServiceUtil;
import com.liferay.portal.service.LayoutLocalServiceUtil;
import com.liferay.portal.util.PortalUtil;

import java.io.Serializable;

import java.text.Format;

import java.util.HashMap;
import java.util.Map;
import java.util.TimeZone;

import javax.portlet.PortletConfig;
import javax.portlet.WindowState;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;

/**
 * @author Eduardo Lundgren
 */
public class NotificationTemplateContextFactory {
	
	protected static Log	_log	= LogFactoryUtil.getLog(NotificationTemplateContextFactory.class);

	public static NotificationTemplateContext getInstance(
			NotificationType notificationType,
			NotificationTemplateType notificationTemplateType,
			CalendarBooking calendarBooking, User user)
		throws Exception {
		
		_log.debug("NotificationTemplateContextFactory.getInstance");

		CalendarBooking parentCalendarBooking =
			calendarBooking.getParentCalendarBooking();
		
		_log.debug("before parentCalendarBooking");

		Calendar calendar = parentCalendarBooking.getCalendar();

		NotificationTemplateContext notificationTemplateContext =
			new NotificationTemplateContext();

		CalendarNotificationTemplate calendarNotificationTemplate =
			CalendarNotificationTemplateLocalServiceUtil.
				fetchCalendarNotificationTemplate(
					calendar.getCalendarId(), notificationType,
					notificationTemplateType);
		
		_log.debug("before calendarNotificationTemplate");

		notificationTemplateContext.setCalendarNotificationTemplate(
			calendarNotificationTemplate);

		notificationTemplateContext.setCompanyId(
			calendarBooking.getCompanyId());
		notificationTemplateContext.setGroupId(calendarBooking.getGroupId());
		notificationTemplateContext.setCalendarId(calendar.getCalendarId());
		notificationTemplateContext.setNotificationTemplateType(
			notificationTemplateType);
		notificationTemplateContext.setNotificationType(notificationType);
		
		_log.debug("before Attributes");

		// Attributes

		Map<String, Serializable> attributes =
			new HashMap<String, Serializable>();

		TimeZone userTimezone = user.getTimeZone();

		Format dateFormatDateTime = FastDateFormatFactoryUtil.getDateTime(
			user.getLocale(), userTimezone);

		String userTimezoneDisplayName = userTimezone.getDisplayName(
			false, TimeZone.SHORT, user.getLocale());

		String endTime =
			dateFormatDateTime.format(calendarBooking.getEndTime()) +
				StringPool.SPACE + userTimezoneDisplayName;

		attributes.put("endTime", endTime);

		attributes.put("location", calendarBooking.getLocation());
		
		Group group = user.getGroup();

		String portalURL = _getPortalURL(
			group.getCompanyId(), group.getGroupId());

		attributes.put("portalURL", portalURL);
		attributes.put(
			"portletName",
			LanguageUtil.get(
				getPortletConfig(), user.getLocale(),
				"javax.portlet.title.".concat(PortletKeys.CALENDAR)));

		String startTime =
			dateFormatDateTime.format(calendarBooking.getStartTime()) +
				StringPool.SPACE + userTimezoneDisplayName;

		attributes.put("startTime", startTime);

		attributes.put("title", calendarBooking.getTitle(user.getLocale()));
		
		_log.debug("before calendarBookingURL");

		String calendarBookingURL = _getCalendarBookingURL(parentCalendarBooking.getGroupId(), group.getCompanyId(), user, calendarBooking.getCalendarBookingId());
		
		_log.debug("calendarBookingURL : " + calendarBookingURL);

		attributes.put("url", calendarBookingURL);
		
		java.util.Calendar calendar2 = java.util.Calendar.getInstance();
		calendar2.setTimeInMillis(calendarBooking.getStartTime());
		attributes.put("startDate",  calendar2.getTime());
		
		calendar2 = java.util.Calendar.getInstance();
		calendar2.setTimeInMillis(calendarBooking.getEndTime());
		attributes.put("endDate",  calendar2.getTime());
		
		attributes.put("calendarBookingId", calendarBooking.getCalendarBookingId());

		notificationTemplateContext.setAttributes(attributes);

		return notificationTemplateContext;
	}

	public static PortletConfig getPortletConfig() {
		return _portletConfig;
	}

	public static void setPortletConfig(PortletConfig portletConfig) {
		_portletConfig = portletConfig;
	}

	private static String _getCalendarBookingURL(
			Long calendarBookingGroupId, Long companyId, User user, long calendarBookingId)
		throws PortalException, SystemException {
		
		_log.debug("_getCalendarBookingURL");

//		Group group = user.getGroup();
//
//		Layout layout = LayoutLocalServiceUtil.getLayout(
//			group.getDefaultPrivatePlid());
		
		_log.debug("calendarBookingGroupId : " + calendarBookingGroupId);

		Layout layout = LayoutLocalServiceUtil.getFriendlyURLLayout(calendarBookingGroupId, false, "/mes-rendez-vous");
		
		_log.debug("_getCalendarBookingURL layout : " + layout);

		String portalURL = _getPortalURL(
			companyId, calendarBookingGroupId);
		
		_log.debug("_getCalendarBookingURL portalURL : " + portalURL);

		String layoutActualURL = PortalUtil.getLayoutActualURL(layout);

		String url = portalURL + layoutActualURL;

		String namespace = PortalUtil.getPortletNamespace(PortletKeys.CALENDAR);

		url = HttpUtil.addParameter(
			url, namespace + "mvcPath", "/view_calendar.jsp");
		url = HttpUtil.addParameter(url, "p_p_id", PortletKeys.CALENDAR);
		url = HttpUtil.addParameter(url, "p_p_lifecycle", "0");
		url = HttpUtil.addParameter(
			url, "p_p_state", WindowState.MAXIMIZED.toString());
		url = HttpUtil.addParameter(
			url, namespace + "calendarBookingId", calendarBookingId);
		
		_log.debug("_getCalendarBookingURL url : " + url);

		return url;
	}

	private static String _getPortalURL(long companyId, long groupId)
		throws PortalException, SystemException {

		Company company = CompanyLocalServiceUtil.getCompany(companyId);

		String portalURL = company.getPortalURL(groupId);

		portalURL = HttpUtil.protocolize(
			portalURL, PortalUtil.getPortalPort(false), false);

		return portalURL;
	}

	private static PortletConfig _portletConfig;

}