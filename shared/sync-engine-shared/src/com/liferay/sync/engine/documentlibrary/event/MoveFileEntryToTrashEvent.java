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

import com.liferay.sync.engine.documentlibrary.handler.BaseJSONHandler;
import com.liferay.sync.engine.documentlibrary.handler.Handler;

import java.util.Map;

/**
 * @author Shinn Lok
 */
public class MoveFileEntryToTrashEvent extends BaseEvent {

	public MoveFileEntryToTrashEvent(
		long syncAccountId, Map<String, Object> parameters) {

		super(syncAccountId, _URL_PATH, parameters);
	}

	@Override
	protected Handler<?> getHandler() {
		return new BaseJSONHandler(this);
	}

	private static final String _URL_PATH =
		"/sync-web.syncdlobject/move-file-entry-to-trash";

}