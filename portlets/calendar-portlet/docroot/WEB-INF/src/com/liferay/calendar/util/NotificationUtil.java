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

import java.text.Normalizer;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;
import java.util.Locale;

import org.apache.commons.lang.StringUtils;
import org.apache.cxf.jaxrs.client.WebClient;
import org.apache.http.client.utils.URIUtils;
import org.springframework.web.util.UriUtils;

import com.damnhandy.uri.template.UriTemplate;
import com.damnhandy.uri.template.UriUtil;
import com.fasterxml.jackson.jaxrs.json.JacksonJsonProvider;
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
import com.liferay.portal.kernel.bean.BeanPropertiesUtil;
import com.liferay.portal.kernel.configuration.Filter;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.util.GetterUtil;
import com.liferay.portal.kernel.util.StringPool;
import com.liferay.portal.kernel.util.StringUtil;
import com.liferay.portal.kernel.util.Time;
import com.liferay.portal.kernel.util.UnicodeProperties;
import com.liferay.portal.model.Group;
import com.liferay.portal.model.Phone;
import com.liferay.portal.model.User;
import com.liferay.portal.service.GroupLocalServiceUtil;
import com.liferay.portal.service.UserLocalServiceUtil;
import com.liferay.portal.util.PortalUtil;
import com.liferay.util.ContentUtil;
import com.liferay.util.portlet.PortletProps;

import fr.cristalunion.authentification.ILiferayAuthentication;
import fr.cristalunion.authentification.factory.LiferayAuthenticationFactory;
import fr.cristalunion.hateoas.representation.Link;
import fr.cristalunion.rest.BaseJacksonJsonProvider;
import fr.cristalunion.technical.ILinkManager;
import fr.cristalunion.technical.factory.LinkManagerFactory;

/**
 * @author Eduardo Lundgren
 * @author Marcellus Tavares
 */
public class NotificationUtil {

	protected static Log					_log			= LogFactoryUtil.getLog(NotificationUtil.class);

	private static final SimpleDateFormat	SDF_DATE		= new SimpleDateFormat("dd/MM/yyyy");
	private static final SimpleDateFormat	SDF_HOUR		= new SimpleDateFormat("HH");
	private static final SimpleDateFormat	SDF_MINUTE		= new SimpleDateFormat("mm");

	private static final String				SMS_REMINDER	= "[$EVENT_TITLE$] [$EVENT_START_DATE$]";

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
			_log.error("notifyCalendarBookingRecipients notificationRecipient loop : " + user.getUserId() + "=>" + user.getFullName());
			NotificationTemplateContext notificationTemplateContext = NotificationTemplateContextFactory.getInstance(notificationType, notificationTemplateType, calendarBooking, user);
			notificationSender.sendNotification(notificationRecipient, notificationTemplateContext);
		}
		_log.debug("notifyCalendarBookingRecipients end");
	}

	public static void notifyCalendarBookingReminders(final CalendarBooking calendarBooking, final long nowTime) throws Exception {
		_log.debug("calendar booking title : " + calendarBooking.getCalendarBookingId());

		// Extract calendarBooking information
		final java.util.Calendar startCalendar = java.util.Calendar.getInstance();
		startCalendar.setTimeInMillis(calendarBooking.getStartTime());
		final Date startCalendarDate = startCalendar.getTime();
		final String eventStartDate = SDF_DATE.format(startCalendarDate) + " a " + SDF_HOUR.format(startCalendarDate) + "h" + SDF_MINUTE.format(startCalendarDate);
		final String title = calendarBooking.getTitle(Locale.FRANCE);
		final String eventCreator = calendarBooking.getUserName();

		final List<NotificationRecipient> notificationRecipients = _getNotificationRecipients(calendarBooking);
		for (final NotificationRecipient notificationRecipient : notificationRecipients) {
			final User user = notificationRecipient.getUser();
			_log.debug("user : " + user.getUserId() + " - " + user.getScreenName());
			final long startTime = calendarBooking.getStartTime();
			if (nowTime > startTime) {
				return;
			}
			NotificationType notificationType = null;
			long deltaTime = startTime - nowTime;
			_log.debug("deltaTime : " + deltaTime);
			if (_isInCheckInterval(deltaTime, calendarBooking.getFirstReminder())) {
				notificationType = calendarBooking.getFirstReminderNotificationType();
			}
			_log.debug(calendarBooking.getCalendarBookingId() + " => user : " + user.getFullName());
			if (notificationType == null) {
				continue;
			}

			String mobile = null;
			final List<Phone> phones = user.getPhones();
			for (final Phone phone : phones) {
				// Mobile
				if (phone.getTypeId() == 11008) {
					final String phoneNumber = phone.getNumber();
					mobile = phoneNumber.replace(".", "").replace("/", "");
				}
			}

			_log.debug("mobile number : " + mobile);

			if (mobile != null && mobile.matches("[0-9]+") && mobile.length() == 10) {
				// Authentification aupres des API
				final ILiferayAuthentication authentication = LiferayAuthenticationFactory.getLiferayAuthenticationImpl();
				final String token = authentication.authenticate();

				final ILinkManager linkManager = LinkManagerFactory.getLinkManagerImpl();
				final Link link = linkManager.getLinksByRels("envoisms").get("envoisms");

				// link
				_log.debug("link : " + link.getHref());

				String smsMessage = StringUtil.replace(SMS_REMINDER, new String[] { "[$EVENT_START_DATE$]", "[$EVENT_TITLE$]", "[$FROM_NAME$]", "[$TO_NAME$]" },
						new String[] { GetterUtil.getString(eventStartDate), GetterUtil.getString(title), GetterUtil.getString(eventCreator), GetterUtil.getString(user.getFullName()) });

				// Replace / to avoid notFound exception rest
				smsMessage = smsMessage.replace("/", "-");

				smsMessage = Normalizer.normalize(smsMessage, Normalizer.Form.NFD).replaceAll("\\p{InCombiningDiacriticalMarks}+", "");

				_log.debug("smsMessage : " + smsMessage);

				smsMessage = UriUtils.encodeQuery(smsMessage, "UTF-8");

				_log.debug("smsMessage after encodeQuery : " + smsMessage);

				link.setHref(UriTemplate.fromTemplate(link.getHref()).set("telephone", mobile).expand() + "?texte=" + smsMessage);

				_log.debug("link href : " + link.getHref());

				WebClient client = null;
				try {
					client = WebClient.create(link.getHref(), new LinkedList<JacksonJsonProvider>().add(new BaseJacksonJsonProvider()));
					final String response = client.header("Authorization", token).accept(link.getAccept()).invoke(link.getMethod().toUpperCase(), null, String.class);
					_log.debug("response : " + response);
				} catch (final Exception e) {
					// handle exception here
					_log.error(e.getMessage(), e);
				}
			}
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