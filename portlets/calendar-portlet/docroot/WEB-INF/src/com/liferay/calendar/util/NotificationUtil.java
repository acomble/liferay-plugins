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

package com.liferay.calendar.util;

import com.liferay.calendar.model.Calendar;
import com.liferay.calendar.model.CalendarBooking;
import com.liferay.calendar.model.CalendarNotificationTemplate;
import com.liferay.calendar.model.CalendarResource;
import com.liferay.calendar.notification.NotificationField;
import com.liferay.calendar.notification.NotificationRecipient;
import com.liferay.calendar.notification.NotificationSender;
import com.liferay.calendar.notification.NotificationSenderFactory;
import com.liferay.calendar.notification.NotificationTemplateContext;
import com.liferay.calendar.notification.NotificationTemplateContextFactory;
import com.liferay.calendar.notification.NotificationTemplateType;
import com.liferay.calendar.notification.NotificationType;
import com.liferay.calendar.service.CalendarBookingLocalServiceUtil;
import com.liferay.calendar.service.permission.CalendarPermission;
import com.liferay.portal.kernel.bean.BeanPropertiesUtil;
import com.liferay.portal.kernel.configuration.Filter;
import com.liferay.portal.kernel.util.StringPool;
import com.liferay.portal.kernel.util.Time;
import com.liferay.portal.kernel.util.UnicodeProperties;
import com.liferay.portal.model.Group;
import com.liferay.portal.model.Role;
import com.liferay.portal.model.RoleConstants;
import com.liferay.portal.model.Team;
import com.liferay.portal.model.User;
import com.liferay.portal.security.permission.PermissionChecker;
import com.liferay.portal.security.permission.PermissionCheckerFactoryUtil;
import com.liferay.portal.service.ClassNameLocalServiceUtil;
import com.liferay.portal.service.GroupLocalServiceUtil;
import com.liferay.portal.service.RoleLocalServiceUtil;
import com.liferay.portal.service.UserLocalServiceUtil;
import com.liferay.portal.util.PortalUtil;
import com.liferay.util.ContentUtil;
import com.liferay.util.portlet.PortletProps;

import java.util.ArrayList;
import java.util.List;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;

/**
 * @author Eduardo Lundgren
 * @author Marcellus Tavares
 */
public class NotificationUtil {

	protected static Log	_log	= LogFactoryUtil.getLog(NotificationUtil.class);

	public static User getDefaultSenderUser(Calendar calendar) throws Exception {

		CalendarResource calendarResource = calendar.getCalendarResource();

		User user = UserLocalServiceUtil.getUser(calendarResource.getUserId());

		if (calendarResource.isGroup()) {
			Group group = GroupLocalServiceUtil.getGroup(calendarResource.getClassPK());

			user = UserLocalServiceUtil.getUser(group.getCreatorUserId());
		} else if (calendarResource.isUser()) {
			user = UserLocalServiceUtil.getUser(calendarResource.getClassPK());
		}

		return user;
	}

	public static String getDefaultTemplate(NotificationType notificationType, NotificationTemplateType notificationTemplateType, NotificationField notificationField) throws Exception {

		Filter filter = new Filter(notificationType.toString(), notificationTemplateType.toString());

		String propertyName = PortletPropsKeys.CALENDAR_NOTIFICATION_PREFIX + StringPool.PERIOD + notificationField.toString();

		String templatePath = PortletProps.get(propertyName, filter);

		return ContentUtil.get(templatePath);
	}

	public static String getTemplate(CalendarNotificationTemplate calendarNotificationTemplate, NotificationType notificationType, NotificationTemplateType notificationTemplateType,
			NotificationField notificationField) throws Exception {

		String defaultTemplate = getDefaultTemplate(notificationType, notificationTemplateType, notificationField);

		return BeanPropertiesUtil.getString(calendarNotificationTemplate, notificationField.toString(), defaultTemplate);
	}

	public static String getTemplatePropertyValue(CalendarNotificationTemplate calendarNotificationTemplate, String propertyName) {

		return getTemplatePropertyValue(calendarNotificationTemplate, propertyName, StringPool.BLANK);
	}

	public static String getTemplatePropertyValue(CalendarNotificationTemplate calendarNotificationTemplate, String propertyName, String defaultValue) {

		if (calendarNotificationTemplate == null) {
			return defaultValue;
		}

		UnicodeProperties notificationTypeSettingsProperties = calendarNotificationTemplate.getNotificationTypeSettingsProperties();

		return notificationTypeSettingsProperties.get(propertyName);
	}

	public static void notifyCalendarBookingRecipients(CalendarBooking calendarBooking, NotificationType notificationType, NotificationTemplateType notificationTemplateType) throws Exception {

		_log.debug("notifyCalendarBookingRecipients begin");

		NotificationSender notificationSender = NotificationSenderFactory.getNotificationSender(notificationType.toString());

		_log.debug("notifyCalendarBookingRecipients getNotificationSender");

		List<NotificationRecipient> notificationRecipients = _getNotificationRecipients(calendarBooking);

		_log.debug("notifyCalendarBookingRecipients _getNotificationRecipients");

		for (NotificationRecipient notificationRecipient : notificationRecipients) {

			User user = notificationRecipient.getUser();

			_log.debug("notifyCalendarBookingRecipients notificationRecipient loop : " + user.getUserId());

			NotificationTemplateContext notificationTemplateContext = NotificationTemplateContextFactory.getInstance(notificationType, notificationTemplateType, calendarBooking, user);

			notificationSender.sendNotification(notificationRecipient, notificationTemplateContext);
		}

		_log.debug("notifyCalendarBookingRecipients end");
	}

	public static void notifyCalendarBookingReminders(CalendarBooking calendarBooking, long nowTime) throws Exception {
		
		_log.debug("calendar booking title : " + calendarBooking.getTitle() + " / " + calendarBooking.getCalendarBookingId());
		
		List<NotificationRecipient> notificationRecipients = _getNotificationRecipients(calendarBooking);

		for (NotificationRecipient notificationRecipient : notificationRecipients) {

			User user = notificationRecipient.getUser();
			
			_log.debug("user : " + user.getFullName() + " / " + user.getUserId());

			long startTime = calendarBooking.getStartTime();

			if (nowTime > startTime) {
				return;
			}

			NotificationType notificationType = null;

			long deltaTime = startTime - nowTime;
			
			_log.debug("deltaTime : " + deltaTime);

			if (_isInCheckInterval(deltaTime, calendarBooking.getFirstReminder())) {

				notificationType = calendarBooking.getFirstReminderNotificationType();
			}
			// Commented for Espace Elus because only one reminder is enabled : sms
			/*
			 * else if (_isInCheckInterval(deltaTime, calendarBooking.getSecondReminder())) {
			 * notificationType = calendarBooking.getSecondReminderNotificationType(); 
			 * }
			 */
			
			_log.debug("notificationType : " + notificationType);

			if (notificationType == null) {
				continue;
			}

			// Commented for Espace Elus because only one reminder is enabled : sms and not email
			/*
			 * NotificationSender notificationSender = NotificationSenderFactory.getNotificationSender(notificationType.toString()); NotificationTemplateContext notificationTemplateContext =
			 * NotificationTemplateContextFactory.getInstance(notificationType, NotificationTemplateType.REMINDER, calendarBooking, user); notificationSender.sendNotification(notificationRecipient,
			 * notificationTemplateContext);
			 */
		}
	}

	private static List<NotificationRecipient> _getNotificationRecipients(CalendarBooking calendarBooking) throws Exception {
		final String userClassName = PortalUtil.getClassName(PortalUtil.getClassNameId(User.class));
		final List<NotificationRecipient> notificationRecipients = new ArrayList<NotificationRecipient>();
		
		CalendarBooking parentCalendarBooking = null;
		if (calendarBooking.getCalendarBookingId() == calendarBooking.getParentCalendarBookingId()) {
			parentCalendarBooking = calendarBooking;
		} else {
			parentCalendarBooking = CalendarBookingLocalServiceUtil.getCalendarBooking(calendarBooking.getParentCalendarBookingId());
		}
		
		_log.debug("parentCalendarBooking : " + parentCalendarBooking);
		
		final List<CalendarBooking> childCalendarBookings = parentCalendarBooking.getChildCalendarBookings();
		for (final CalendarBooking childCalendarBooking : childCalendarBookings) {
			_log.debug("childCalendarBooking : " + childCalendarBooking.getCalendarBookingId());
			final CalendarResource childCalendarResource = childCalendarBooking.getCalendarResource();
			_log.debug("childCalendarResource.getClassName() : " + childCalendarResource.getClassName());
			if (childCalendarResource.getClassName().equals(userClassName)) {
				final long userId = childCalendarResource.getClassPK();
				_log.debug("user recipient added : " + userId);
				notificationRecipients.add(new NotificationRecipient(UserLocalServiceUtil.getUser(userId)));
			}
		}
		return notificationRecipients;
	}

	private static boolean _isInCheckInterval(long deltaTime, long intervalStart) {

		long intervalEnd = intervalStart + _CHECK_INTERVAL;

		if ((intervalStart <= deltaTime) && (deltaTime < intervalEnd)) {
			return true;
		}

		return false;
	}

	private static final long	_CHECK_INTERVAL	= PortletPropsValues.CALENDAR_NOTIFICATION_CHECK_INTERVAL * Time.MINUTE;

}