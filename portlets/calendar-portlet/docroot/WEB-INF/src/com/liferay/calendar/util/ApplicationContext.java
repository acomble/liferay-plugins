package com.liferay.calendar.util;

import org.springframework.beans.BeansException;
import org.springframework.context.support.ClassPathXmlApplicationContext;

public class ApplicationContext
{
	private final static ClassPathXmlApplicationContext ctx = new ClassPathXmlApplicationContext("applicationContext.xml");
	
	public static ClassPathXmlApplicationContext getApplicationContext()
	{
		ctx.refresh();
		return ctx;
	}
}
