/**
 * Copyright (c) 2000-2013 Liferay, Inc. All rights reserved.
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

package com.liferay.sync.engine.documentlibrary.event;

import com.liferay.sync.engine.documentlibrary.handler.BaseHandler;
import com.liferay.sync.engine.documentlibrary.handler.Handler;
import com.liferay.sync.engine.session.Session;
import com.liferay.sync.engine.session.SessionManager;

import java.util.Map;

/**
 * @author Shinn Lok
 */
public class BaseEvent implements Event {

	public BaseEvent(
		long syncAccountId, String urlPath, Map<String, Object> parameters) {

		_syncAccountId = syncAccountId;
		_urlPath = urlPath;
		_parameters = parameters;
	}

	public <T> T executeGet(String urlPath, Handler<? extends T> handler)
		throws Exception {

		Session session = SessionManager.getSession(_syncAccountId);

		return session.executeGet(urlPath, handler);
	}

	public <T> T executePost(
			String urlPath, Map<String, Object> parameters,
			Handler<? extends T> handler)
		throws Exception {

		Session session = SessionManager.getSession(_syncAccountId);

		return session.executePost(urlPath, parameters, handler);
	}

	@Override
	public Map<String, Object> getParameters() {
		return _parameters;
	}

	@Override
	public Object getParameterValue(String key) {
		return _parameters.get(key);
	}

	@Override
	public long getSyncAccountId() {
		return _syncAccountId;
	}

	@Override
	public void run() {
		try {
			processRequest();
		}
		catch (Exception e) {
			Handler<?> handler = getHandler();

			handler.handleException(e);
		}
	}

	protected Handler<?> getHandler() {
		return new BaseHandler(this);
	}

	protected void processRequest() throws Exception {
		executePost(_urlPath, _parameters, getHandler());
	}

	private Map<String, Object> _parameters;
	private long _syncAccountId;
	private String _urlPath;

}