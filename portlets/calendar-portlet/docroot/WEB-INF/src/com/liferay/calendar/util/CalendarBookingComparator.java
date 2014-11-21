package com.liferay.calendar.util;

import com.liferay.calendar.model.CalendarBooking;
import com.liferay.portal.kernel.util.OrderByComparator;

public class CalendarBookingComparator extends OrderByComparator {

	@Override
	public int compare(Object obj1, Object obj2) {
		CalendarBooking calendarBooking1 = (CalendarBooking)obj1;
		CalendarBooking calendarBooking2 = (CalendarBooking)obj2;
		
		return (int)(calendarBooking1.getStartTime() - calendarBooking2.getStartTime());
	}

}
