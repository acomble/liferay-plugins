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

import com.liferay.calendar.model.CalendarNotificationTemplate;
import com.liferay.calendar.util.NotificationUtil;
import com.liferay.portal.kernel.util.GetterUtil;
import com.liferay.portal.kernel.util.StringUtil;

import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Map;

/**
 * @author Eduardo Lundgren
 */
public class NotificationTemplateRenderer {

	private static final SimpleDateFormat	SDF_DATE	= new SimpleDateFormat("EEEE dd MMMM yyyy");
	private static final SimpleDateFormat	SDF_HOUR	= new SimpleDateFormat("HH");
	private static final SimpleDateFormat	SDF_MINUTE	= new SimpleDateFormat("mm");

	public static String render(NotificationTemplateContext notificationTemplateContext, NotificationField notificationField) throws Exception {

		CalendarNotificationTemplate calendarNotificationTemplate = notificationTemplateContext.getCalendarNotificationTemplate();
		NotificationType notificationType = notificationTemplateContext.getNotificationType();
		NotificationTemplateType notificationTemplateType = notificationTemplateContext.getNotificationTemplateType();

		String notificationTemplate = NotificationUtil.getTemplate(calendarNotificationTemplate, notificationType, notificationTemplateType, notificationField);

		return replaceTokens(notificationTemplate, notificationTemplateContext);
	}

	protected static String replaceTokens(String notificationTemplate, NotificationTemplateContext notificationTemplateContext) throws Exception {

		Map<String, Serializable> attributes = notificationTemplateContext.getAttributes();

		final Date endDate = (Date) attributes.get("endDate");
		final Date startDate = (Date) attributes.get("startDate");

		return StringUtil.replace(
				notificationTemplate,
				new String[] { 
						"[$EVENT_END_DATE$]", 
						"[$EVENT_LOCATION$]", 
						"[$EVENT_START_DATE$]", 
						"[$EVENT_TITLE$]", 
						"[$EVENT_URL$]", 
						"[$FROM_ADDRESS$]", 
						"[$FROM_NAME$]", 
						"[$PORTAL_URL$]",
						"[$PORTLET_NAME$]", 
						"[$TO_ADDRESS$]", 
						"[$TO_NAME$]" 
				},
				new String[] { 
						GetterUtil.getString(SDF_DATE.format(endDate) + " ра " + SDF_HOUR.format(endDate) + "h" + SDF_MINUTE.format(endDate)), 
						GetterUtil.getString(attributes.get("location")),
						GetterUtil.getString(SDF_DATE.format(startDate) + " ра " + SDF_HOUR.format(startDate) + "h" + SDF_MINUTE.format(startDate)), 
						GetterUtil.getString(attributes.get("title")),
						GetterUtil.getString(attributes.get("url")), 
						GetterUtil.getString(notificationTemplateContext.getFromAddress()),
						GetterUtil.getString(notificationTemplateContext.getFromName()), 
						GetterUtil.getString(attributes.get("portalURL")), 
						GetterUtil.getString(attributes.get("portletName")),
						GetterUtil.getString(notificationTemplateContext.getToAddress()), 
						GetterUtil.getString(notificationTemplateContext.getToName()) 
				}
			);
	}

}