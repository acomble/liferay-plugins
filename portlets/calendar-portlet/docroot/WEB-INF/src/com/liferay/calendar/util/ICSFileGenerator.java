package com.liferay.calendar.util;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.util.GregorianCalendar;
import java.util.List;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.lang.StringEscapeUtils;

import net.fortuna.ical4j.data.CalendarOutputter;
import net.fortuna.ical4j.model.Calendar;
import net.fortuna.ical4j.model.DateTime;
import net.fortuna.ical4j.model.TimeZone;
import net.fortuna.ical4j.model.TimeZoneRegistry;
import net.fortuna.ical4j.model.TimeZoneRegistryFactory;
import net.fortuna.ical4j.model.component.VEvent;
import net.fortuna.ical4j.model.component.VTimeZone;
import net.fortuna.ical4j.model.property.CalScale;
import net.fortuna.ical4j.model.property.Description;
import net.fortuna.ical4j.model.property.Location;
import net.fortuna.ical4j.model.property.Organizer;
import net.fortuna.ical4j.model.property.ProdId;
import net.fortuna.ical4j.model.property.Status;
import net.fortuna.ical4j.model.property.Uid;
import net.fortuna.ical4j.util.UidGenerator;

import com.liferay.calendar.model.CalendarBooking;
import com.liferay.portal.model.User;
import com.liferay.portal.service.UserLocalServiceUtil;

public class ICSFileGenerator {
	
	private static final Pattern REMOVE_TAGS = Pattern.compile("<.+?>");

	public static File createCalEntry(final String filePath, final String calendarName, final List<CalendarBooking> calendarBookings) {

		// create a calendar object
		final Calendar icsCalendar = new Calendar();

		// assign props to calendar object
		icsCalendar.getProperties().add(new ProdId("-//Events Calendar//iCal4j 1.0//EN"));
		icsCalendar.getProperties().add(CalScale.GREGORIAN);

		// create a file object
		final File calFile = new File(filePath + File.separatorChar + "CU_ESPACE-ELUS_" + calendarName + ".ics");

		try {

			// Create a TimeZone
			final TimeZoneRegistry registry = TimeZoneRegistryFactory.getInstance().createRegistry();
			final TimeZone timezone = registry.getTimeZone("Europe/Paris");
			final VTimeZone tz = ((net.fortuna.ical4j.model.TimeZone) timezone).getVTimeZone();

			for (final CalendarBooking calendarBooking : calendarBookings) {

				final java.util.Calendar startCalendar = java.util.Calendar.getInstance(Locale.FRANCE);
				startCalendar.setTimeInMillis(calendarBooking.getStartTime());

				// Start Date
				final java.util.Calendar startDate = new GregorianCalendar();
				startDate.setTimeZone(timezone);
				startDate.set(java.util.Calendar.MONTH, startCalendar.get(java.util.Calendar.MONTH));
				startDate.set(java.util.Calendar.DAY_OF_MONTH, startCalendar.get(java.util.Calendar.DAY_OF_MONTH));
				startDate.set(java.util.Calendar.YEAR, startCalendar.get(java.util.Calendar.YEAR));
				startDate.set(java.util.Calendar.HOUR_OF_DAY, startCalendar.get(java.util.Calendar.HOUR_OF_DAY));
				startDate.set(java.util.Calendar.MINUTE, startCalendar.get(java.util.Calendar.MINUTE));
				startDate.set(java.util.Calendar.SECOND, startCalendar.get(java.util.Calendar.SECOND));

				final java.util.Calendar endCalendar = java.util.Calendar.getInstance(Locale.FRANCE);
				endCalendar.setTimeInMillis(calendarBooking.getEndTime());

				// End Date
				final java.util.Calendar endDate = new GregorianCalendar();
				endDate.setTimeZone(timezone);
				endDate.set(java.util.Calendar.MONTH, endCalendar.get(java.util.Calendar.MONTH));
				endDate.set(java.util.Calendar.DAY_OF_MONTH, endCalendar.get(java.util.Calendar.DAY_OF_MONTH));
				endDate.set(java.util.Calendar.YEAR, endCalendar.get(java.util.Calendar.YEAR));
				endDate.set(java.util.Calendar.HOUR_OF_DAY, endCalendar.get(java.util.Calendar.HOUR_OF_DAY));
				endDate.set(java.util.Calendar.MINUTE, endCalendar.get(java.util.Calendar.MINUTE));
				endDate.set(java.util.Calendar.SECOND, endCalendar.get(java.util.Calendar.SECOND));

				// Create the event props
				final String eventName = calendarBooking.getTitle(Locale.FRANCE);
				final DateTime start = new DateTime(startDate.getTime());
				final DateTime end = new DateTime(endDate.getTime());

				// Create the event
				final VEvent meeting = new VEvent(start, end, eventName);

				// create Organizer object and add it to vEvent
				final User organizerUser = UserLocalServiceUtil.getUser(calendarBooking.getUserId());
				final Organizer organizer = new Organizer(URI.create("mailto:" + organizerUser.getEmailAddress()));
				meeting.getProperties().add(organizer);

				// add timezone to vEvent
				meeting.getProperties().add(tz.getTimeZoneId());
				
				// add location to vEvent
				meeting.getProperties().add(new Location(StringEscapeUtils.unescapeHtml(calendarBooking.getLocation())));
				
				// add status to vEvent
				meeting.getProperties().add(new Status("" + calendarBooking.getStatusByUserId()));
				
				// add description to vEvent
				meeting.getProperties().add(new Description(StringEscapeUtils.unescapeHtml(removeTags(calendarBooking.getDescription(Locale.FRANCE)))));

				// generate unique identifier and add it to vEvent
				final UidGenerator ug = new UidGenerator("uidGen");
				final Uid uid = ug.generateUid();
				meeting.getProperties().add(uid);

				// add attendees..
				/*
				 * Attendee dev1 = new Attendee(URI.create("someone@something")); dev1.getParameters().add(Role.REQ_PARTICIPANT); dev1.getParameters().add(new Cn("Developer 1"));
				 * meeting.getProperties().add(dev1);
				 */

				// Add the event and print
				icsCalendar.getComponents().add(meeting);
			}

			final CalendarOutputter outputter = new CalendarOutputter();
			outputter.setValidating(false);

			final FileOutputStream fout = new FileOutputStream(calFile);
			outputter.output(icsCalendar, fout);

			return calFile;

		} catch (Exception e) {
			e.printStackTrace();
			System.err.println("Error in method createCalEntry() " + e);
			return null;
		}
	}

	public static byte[] getFileBytes(final File file) throws IOException {
	    ByteArrayOutputStream ous = null;
	    InputStream ios = null;
	    try {
	        byte[] buffer = new byte[4096];
	        ous = new ByteArrayOutputStream();
	        ios = new FileInputStream(file);
	        int read = 0;
	        while ((read = ios.read(buffer)) != -1)
	            ous.write(buffer, 0, read);
	    } finally {
	        try {
	            if (ous != null)
	                ous.close();
	        } catch (IOException e) {
	            // swallow, since not that important
	        }
	        try {
	            if (ios != null)
	                ios.close();
	        } catch (IOException e) {
	            // swallow, since not that important
	        }
	    }
	    return ous.toByteArray();
	}
	
	private static String removeTags(final String string) {
	    if (string == null || string.length() == 0) {
	        return string;
	    }
	    final Matcher m = REMOVE_TAGS.matcher(string);
	    return m.replaceAll("");
	}
}
