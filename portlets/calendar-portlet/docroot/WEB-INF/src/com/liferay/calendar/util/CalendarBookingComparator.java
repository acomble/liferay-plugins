package com.liferay.calendar.util;

import com.liferay.calendar.model.CalendarBooking;
import com.liferay.portal.kernel.util.OrderByComparator;

public class CalendarBookingComparator extends OrderByComparator {
	
	@Override
	public String getOrderBy() {
		return "startTime DESC";
	}

	@Override
	public int compare(Object obj1, Object obj2) {
		CalendarBooking calendarBooking1 = (CalendarBooking) obj1;
		CalendarBooking calendarBooking2 = (CalendarBooking) obj2;

		if (calendarBooking1.getStartTime() - calendarBooking2.getStartTime() > 0) {
			return 1;
		} else if (calendarBooking1.getStartTime() - calendarBooking2.getStartTime() < 0) {
			return -1;
		}
		return 0;
	}

}
