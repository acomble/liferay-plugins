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

import java.io.File;
import java.io.FileOutputStream;
import java.io.Serializable;
import java.net.URI;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.Map;

import com.liferay.calendar.model.Calendar;
import com.liferay.calendar.model.CalendarNotificationTemplate;
import com.liferay.calendar.model.CalendarNotificationTemplateConstants;
import com.liferay.calendar.service.CalendarLocalServiceUtil;
import com.liferay.calendar.util.NotificationUtil;
import com.liferay.mail.service.MailServiceUtil;
import com.liferay.portal.kernel.mail.MailMessage;
import com.liferay.portal.model.User;

import javax.mail.internet.InternetAddress;

import net.fortuna.ical4j.data.CalendarOutputter;
import net.fortuna.ical4j.model.DateTime;
import net.fortuna.ical4j.model.TimeZone;
import net.fortuna.ical4j.model.TimeZoneRegistry;
import net.fortuna.ical4j.model.TimeZoneRegistryFactory;
import net.fortuna.ical4j.model.component.VEvent;
import net.fortuna.ical4j.model.component.VTimeZone;
import net.fortuna.ical4j.model.property.CalScale;
import net.fortuna.ical4j.model.property.Organizer;
import net.fortuna.ical4j.model.property.ProdId;
import net.fortuna.ical4j.model.property.Uid;
import net.fortuna.ical4j.util.UidGenerator;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;

/**
 * @author Eduardo Lundgren
 */
public class EmailNotificationSender implements NotificationSender {
	
	protected static Log	_log	= LogFactoryUtil.getLog(EmailNotificationSender.class);

	@Override
	public void sendNotification(NotificationRecipient notificationRecipient, NotificationTemplateContext notificationTemplateContext) throws NotificationSenderException {

		//_log.debug("1sendNotification");

		try {
			CalendarNotificationTemplate calendarNotificationTemplate = notificationTemplateContext.getCalendarNotificationTemplate();

			Calendar calendar = CalendarLocalServiceUtil.getCalendar(notificationTemplateContext.getCalendarId());

			//_log.debug("calendar: " + calendar.getName());

			User defaultSenderUser = NotificationUtil.getDefaultSenderUser(calendar);

			String fromAddress = NotificationUtil.getTemplatePropertyValue(calendarNotificationTemplate, CalendarNotificationTemplateConstants.PROPERTY_FROM_ADDRESS,
					defaultSenderUser.getEmailAddress());
			String fromName = NotificationUtil.getTemplatePropertyValue(calendarNotificationTemplate, CalendarNotificationTemplateConstants.PROPERTY_FROM_NAME, defaultSenderUser.getFullName());

			notificationTemplateContext.setFromAddress(fromAddress);
			notificationTemplateContext.setFromName(fromName);
			notificationTemplateContext.setToAddress(notificationRecipient.getEmailAddress());
			notificationTemplateContext.setToName(notificationRecipient.getName());
			
			_log.debug("notificationRecipient.getEmailAddress() : " + notificationRecipient.getEmailAddress());
			_log.debug("notificationRecipient.getName() : " + notificationRecipient.getName());

			final Map<String, Serializable> attributes = notificationTemplateContext.getAttributes();
			for (Map.Entry<String, Serializable> attribute : attributes.entrySet()) {
				_log.debug("Attribut : " + attribute.getKey() + " = " + attribute.getValue());
			}

			String subject = NotificationTemplateRenderer.render(notificationTemplateContext, NotificationField.SUBJECT);
			String body = NotificationTemplateRenderer.render(notificationTemplateContext, NotificationField.BODY);
			
			_log.debug("body : " + body);

//			File file = createCalEntry((Long) attributes.get("calendarBookingId"), (java.util.Calendar) attributes.get("startDate"), (java.util.Calendar) attributes.get("endDate"),
//					(String) attributes.get("title"));
//			
//			notificationTemplateContext.setAttribute("icsFile", file);

			sendNotification(notificationTemplateContext.getFromAddress(), notificationTemplateContext.getFromName(), notificationRecipient, subject, body);
			
			_log.debug("End sendNotification");
			
//			file.delete();
		} catch (Exception e) {
			throw new NotificationSenderException(e);
		}
	}

	@Override
	public void sendNotification(String fromAddress, String fromName, NotificationRecipient notificationRecipient, String subject, String notificationMessage) throws NotificationSenderException {

		_log.debug("2sendNotification");

		try {
			InternetAddress fromInternetAddress = new InternetAddress(fromAddress, fromName);

			MailMessage mailMessage = new MailMessage(fromInternetAddress, subject, notificationMessage, true);
			
			mailMessage.setHTMLFormat(notificationRecipient.isHTMLFormat());

			InternetAddress toInternetAddress = new InternetAddress(notificationRecipient.getEmailAddress());
			
			_log.debug("toInternetAddress : " + toInternetAddress);

			mailMessage.setTo(toInternetAddress);

			MailServiceUtil.sendEmail(mailMessage);
		} catch (Exception e) {
			throw new NotificationSenderException("Unable to send mail message", e);
		}
	}

	private static File createCalEntry(long eventId, java.util.Calendar startTime, java.util.Calendar endTime, String title) {

		//_log.debug("3 - createCalEntry");
		
		// create a calendar object
		net.fortuna.ical4j.model.Calendar icsCalendar = new net.fortuna.ical4j.model.Calendar();

		// create a file object
		File calFile = new File("cristal-union" + eventId + ".ics");

		try {

			// Create a TimeZone
			TimeZoneRegistry registry = TimeZoneRegistryFactory.getInstance().createRegistry();
			TimeZone timezone = registry.getTimeZone("Europe/Paris");
			VTimeZone tz = ((net.fortuna.ical4j.model.TimeZone) timezone).getVTimeZone();

			// Start Date
			java.util.Calendar startDate = new GregorianCalendar();
			startDate.setTimeZone(timezone);
			startDate.set(java.util.Calendar.MONTH, java.util.Calendar.OCTOBER);
			startDate.set(java.util.Calendar.DAY_OF_MONTH, startTime.get(java.util.Calendar.DAY_OF_MONTH));
			startDate.set(java.util.Calendar.YEAR, startTime.get(java.util.Calendar.YEAR));
			startDate.set(java.util.Calendar.HOUR_OF_DAY, startTime.get(java.util.Calendar.HOUR_OF_DAY));
			startDate.set(java.util.Calendar.MINUTE, startTime.get(java.util.Calendar.MINUTE));
			startDate.set(java.util.Calendar.SECOND, 0);

			// End Date
			java.util.Calendar endDate = new GregorianCalendar();
			endDate.setTimeZone(timezone);
			endDate.set(java.util.Calendar.MONTH, java.util.Calendar.OCTOBER);
			endDate.set(java.util.Calendar.DAY_OF_MONTH, endDate.get(java.util.Calendar.DAY_OF_MONTH));
			endDate.set(java.util.Calendar.YEAR, endDate.get(java.util.Calendar.YEAR));
			endDate.set(java.util.Calendar.HOUR_OF_DAY, endDate.get(java.util.Calendar.HOUR_OF_DAY));
			endDate.set(java.util.Calendar.MINUTE, endDate.get(java.util.Calendar.MINUTE));
			endDate.set(java.util.Calendar.SECOND, 0);

			// Create the event props
			String eventName = title;
			DateTime start = new DateTime(startDate.getTime());
			DateTime end = new DateTime(endDate.getTime());

			// Create the event
			VEvent meeting = new VEvent(start, end, eventName);

			// create Organizer object and add it to vEvent
			// Organizer organizer = new Organizer(URI.create("mailto:antoine.comble@gmail.com"));
			// meeting.getProperties().add(organizer);

			// add timezone to vEvent
			meeting.getProperties().add(tz.getTimeZoneId());

			// generate unique identifier and add it to vEvent
			UidGenerator ug;
			ug = new UidGenerator("uidGen");
			Uid uid = ug.generateUid();
			meeting.getProperties().add(uid);

			// add attendees..
			/*
			 * Attendee dev1 = new Attendee(URI.create("someone@something")); dev1.getParameters().add(Role.REQ_PARTICIPANT); dev1.getParameters().add(new Cn("Developer 1"));
			 * meeting.getProperties().add(dev1);
			 */

			// assign props to calendar object
			icsCalendar.getProperties().add(new ProdId("-//Events Calendar//iCal4j 1.0//EN"));
			icsCalendar.getProperties().add(CalScale.GREGORIAN);

			// Add the event and print
			icsCalendar.getComponents().add(meeting);

			CalendarOutputter outputter = new CalendarOutputter();
			outputter.setValidating(false);

			FileOutputStream fout = new FileOutputStream(calFile);
			outputter.output(icsCalendar, fout);

			return calFile;

		} catch (Exception e) {
			_log.error("Error in method createCalEntry() " + e);
			return null;
		}
	}
}