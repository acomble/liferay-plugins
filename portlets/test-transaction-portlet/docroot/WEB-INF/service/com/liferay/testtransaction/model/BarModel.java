/**
 * Copyright (c) 2000-2012 Liferay, Inc. All rights reserved.
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

package com.liferay.testtransaction.model;

import com.liferay.portal.kernel.bean.AutoEscape;
import com.liferay.portal.model.BaseModel;
import com.liferay.portal.model.CacheModel;
import com.liferay.portal.service.ServiceContext;

import com.liferay.portlet.expando.model.ExpandoBridge;

import java.io.Serializable;

/**
 * The base model interface for the Bar service. Represents a row in the &quot;TestTransaction_Bar&quot; database table, with each column mapped to a property of this class.
 *
 * <p>
 * This interface and its corresponding implementation {@link com.liferay.testtransaction.model.impl.BarModelImpl} exist only as a container for the default property accessors generated by ServiceBuilder. Helper methods and all application logic should be put in {@link com.liferay.testtransaction.model.impl.BarImpl}.
 * </p>
 *
 * @author Brian Wing Shun Chan
 * @see Bar
 * @see com.liferay.testtransaction.model.impl.BarImpl
 * @see com.liferay.testtransaction.model.impl.BarModelImpl
 * @generated
 */
public interface BarModel extends BaseModel<Bar> {
	/*
	 * NOTE FOR DEVELOPERS:
	 *
	 * Never modify or reference this interface directly. All methods that expect a bar model instance should use the {@link Bar} interface instead.
	 */

	/**
	 * Returns the primary key of this bar.
	 *
	 * @return the primary key of this bar
	 */
	public long getPrimaryKey();

	/**
	 * Sets the primary key of this bar.
	 *
	 * @param primaryKey the primary key of this bar
	 */
	public void setPrimaryKey(long primaryKey);

	/**
	 * Returns the bar ID of this bar.
	 *
	 * @return the bar ID of this bar
	 */
	public long getBarId();

	/**
	 * Sets the bar ID of this bar.
	 *
	 * @param barId the bar ID of this bar
	 */
	public void setBarId(long barId);

	/**
	 * Returns the text of this bar.
	 *
	 * @return the text of this bar
	 */
	@AutoEscape
	public String getText();

	/**
	 * Sets the text of this bar.
	 *
	 * @param text the text of this bar
	 */
	public void setText(String text);

	public boolean isNew();

	public void setNew(boolean n);

	public boolean isCachedModel();

	public void setCachedModel(boolean cachedModel);

	public boolean isEscapedModel();

	public Serializable getPrimaryKeyObj();

	public void setPrimaryKeyObj(Serializable primaryKeyObj);

	public ExpandoBridge getExpandoBridge();

	public void setExpandoBridgeAttributes(BaseModel<?> baseModel);

	public void setExpandoBridgeAttributes(ExpandoBridge expandoBridge);

	public void setExpandoBridgeAttributes(ServiceContext serviceContext);

	public Object clone();

	public int compareTo(Bar bar);

	public int hashCode();

	public CacheModel<Bar> toCacheModel();

	public Bar toEscapedModel();

	public Bar toUnescapedModel();

	public String toString();

	public String toXmlString();
}