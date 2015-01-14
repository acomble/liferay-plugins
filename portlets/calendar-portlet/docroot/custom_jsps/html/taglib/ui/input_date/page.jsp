<%--
/**
 * Copyright (c) 2000-2013 Liferay, Inc. All rights reserved.
 *
 * The contents of this file are subject to the terms of the Liferay Enterprise
 * Subscription License ("License"). You may not use this file except in
 * compliance with the License. You can obtain a copy of the License by
 * contacting Liferay, Inc. See the License for the specific language governing
 * permissions and limitations under the License, including but not limited to
 * distribution rights of the Software.
 *
 *
 *
 */
--%>

<%@ include file="/html/taglib/init.jsp" %>

<%
String randomNamespace = PortalUtil.generateRandomKey(request, "taglib_ui_input_date_page") + StringPool.UNDERLINE;

if (GetterUtil.getBoolean((String)request.getAttribute("liferay-ui:input-date:disableNamespace"))) {
	namespace = StringPool.BLANK;
}

boolean autoFocus = GetterUtil.getBoolean((String)request.getAttribute("liferay-ui:input-date:autoFocus"));
String cssClass = GetterUtil.getString((String)request.getAttribute("liferay-ui:input-date:cssClass"));
boolean disabled = GetterUtil.getBoolean((String)request.getAttribute("liferay-ui:input-date:disabled"));
String dayParam = namespace + request.getAttribute("liferay-ui:input-date:dayParam");
String dayParamId = namespace + request.getAttribute("liferay-ui:input-date:dayParamId");
int dayValue = GetterUtil.getInteger((String)request.getAttribute("liferay-ui:input-date:dayValue"));
int firstDayOfWeek = GetterUtil.getInteger((String)request.getAttribute("liferay-ui:input-date:firstDayOfWeek"));
String monthAndYearParam = namespace + request.getAttribute("liferay-ui:input-date:monthAndYearParam");
String monthParam = namespace + request.getAttribute("liferay-ui:input-date:monthParam");
String monthParamId = namespace + request.getAttribute("liferay-ui:input-date:monthParamId");
int monthValue = GetterUtil.getInteger((String)request.getAttribute("liferay-ui:input-date:monthValue"));
String name = GetterUtil.getString((String)request.getAttribute("liferay-ui:input-date:name"));
String yearParam = namespace + request.getAttribute("liferay-ui:input-date:yearParam");
String yearParamId = namespace + request.getAttribute("liferay-ui:input-date:yearParamId");
int yearValue = GetterUtil.getInteger((String)request.getAttribute("liferay-ui:input-date:yearValue"));

Calendar calendar = CalendarFactoryUtil.getCalendar(yearValue, monthValue, dayValue);

String mask = _MASK_MDY;
String simpleDateFormatPattern = _SIMPLE_DATE_FORMAT_PATTERN_MDY;

if (BrowserSnifferUtil.isMobile(request)) {
	simpleDateFormatPattern = _SIMPLE_DATE_FORMAT_PATTERN_HTML5;
}
else {
	DateFormat shortDateFormat = DateFormat.getDateInstance(DateFormat.SHORT, locale);

	SimpleDateFormat shortDateFormatSimpleDateFormat = (SimpleDateFormat)shortDateFormat;

	String shortDateFormatSimpleDateFormatPattern = shortDateFormatSimpleDateFormat.toPattern();

	if (shortDateFormatSimpleDateFormatPattern.indexOf("y") == 0) {
		mask = _MASK_YMD;
		simpleDateFormatPattern = _SIMPLE_DATE_FORMAT_PATTERN_YMD;
	}
	else if (shortDateFormatSimpleDateFormatPattern.indexOf("d") == 0) {
		mask = _MASK_DMY;
		simpleDateFormatPattern = _SIMPLE_DATE_FORMAT_PATTERN_DMY;
	}
}

Format format = FastDateFormatFactoryUtil.getSimpleDateFormat(simpleDateFormatPattern, locale);
%>

<span class="lfr-input-date <%= cssClass %>" id="<%= randomNamespace %>displayDate">
	<c:choose>
		<c:when test="<%= BrowserSnifferUtil.isMobile(request) %>">
			<input class="input-medium" <%= disabled ? "disabled=\"disabled\"" : "" %> id="<%= namespace + name %>" name="<%= namespace + name %>" type="date" value="<%= format.format(calendar.getTime()) %>" />
		</c:when>
		<c:otherwise>
			<input class="input-medium" <%= disabled ? "disabled=\"disabled\"" : "" %> id="<%= namespace + name %>" name="<%= namespace + name %>" placeholder="<%= StringUtil.toLowerCase(simpleDateFormatPattern) %>" type="text" value="<%= format.format(calendar.getTime()) %>" />
		</c:otherwise>
	</c:choose>

	<input <%= disabled ? "disabled=\"disabled\"" : "" %> id="<%= dayParamId %>" name="<%= dayParam %>" type="hidden" value="<%= dayValue %>" />
	<input <%= disabled ? "disabled=\"disabled\"" : "" %> id="<%= monthParamId %>" name="<%= monthParam %>" type="hidden" value="<%= monthValue %>" />
	<input <%= disabled ? "disabled=\"disabled\"" : "" %> id="<%= yearParamId %>" name="<%= yearParam %>" type="hidden" value="<%= yearValue %>" />
</span>

<aui:script use='<%= "aui-datepicker" + (BrowserSnifferUtil.isMobile(request) ? "-native" : StringPool.BLANK) %>'>
	Liferay.component(
		'<%= namespace + name %>DatePicker',
		function() {		
			var dateFormat = function () {
				var	token = /d{1,4}|m{1,4}|yy(?:yy)?|([HhMsTt])\1?|[LloSZ]|"[^"]*"|'[^']*'/g,
					timezone = /\b(?:[PMCEA][SDP]T|(?:Pacific|Mountain|Central|Eastern|Atlantic) (?:Standard|Daylight|Prevailing) Time|(?:GMT|UTC)(?:[-+]\d{4})?)\b/g,
					timezoneClip = /[^-+\dA-Z]/g,
					pad = function (val, len) {
						val = String(val);
						len = len || 2;
						while (val.length < len) val = "0" + val;
						return val;
					};
			
				// Regexes and supporting functions are cached through closure
				return function (date, mask, utc) {
					var dF = dateFormat;
			
					// You can't provide utc if you skip other args (use the "UTC:" mask prefix)
					if (arguments.length == 1 && Object.prototype.toString.call(date) == "[object String]" && !/\d/.test(date)) {
						mask = date;
						date = undefined;
					}
			
					// Passing date through Date applies Date.parse, if necessary
					date = date ? new Date(date) : new Date;
					if (isNaN(date)) throw SyntaxError("invalid date");
			
					mask = String(dF.masks[mask] || mask || dF.masks["default"]);
			
					// Allow setting the utc argument via the mask
					if (mask.slice(0, 4) == "UTC:") {
						mask = mask.slice(4);
						utc = true;
					}
			
					var	_ = utc ? "getUTC" : "get",
						d = date[_ + "Date"](),
						D = date[_ + "Day"](),
						m = date[_ + "Month"](),
						y = date[_ + "FullYear"](),
						H = date[_ + "Hours"](),
						M = date[_ + "Minutes"](),
						s = date[_ + "Seconds"](),
						L = date[_ + "Milliseconds"](),
						o = utc ? 0 : date.getTimezoneOffset(),
						flags = {
							d:    d,
							dd:   pad(d),
							ddd:  dF.i18n.dayNames[D],
							dddd: dF.i18n.dayNames[D + 7],
							m:    m + 1,
							mm:   pad(m + 1),
							mmm:  dF.i18n.monthNames[m],
							mmmm: dF.i18n.monthNames[m + 12],
							yy:   String(y).slice(2),
							yyyy: y,
							h:    H % 12 || 12,
							hh:   pad(H % 12 || 12),
							H:    H,
							HH:   pad(H),
							M:    M,
							MM:   pad(M),
							s:    s,
							ss:   pad(s),
							l:    pad(L, 3),
							L:    pad(L > 99 ? Math.round(L / 10) : L),
							t:    H < 12 ? "a"  : "p",
							tt:   H < 12 ? "am" : "pm",
							T:    H < 12 ? "A"  : "P",
							TT:   H < 12 ? "AM" : "PM",
							Z:    utc ? "UTC" : (String(date).match(timezone) || [""]).pop().replace(timezoneClip, ""),
							o:    (o > 0 ? "-" : "+") + pad(Math.floor(Math.abs(o) / 60) * 100 + Math.abs(o) % 60, 4),
							S:    ["th", "st", "nd", "rd"][d % 10 > 3 ? 0 : (d % 100 - d % 10 != 10) * d % 10]
						};
			
					return mask.replace(token, function ($0) {
						return $0 in flags ? flags[$0] : $0.slice(1, $0.length - 1);
					});
				};
			}();
			
			// Some common format strings
			dateFormat.masks = {
				"default":      "ddd mmm dd yyyy HH:MM:ss",
				shortDate:      "m/d/yy",
				mediumDate:     "mmm d, yyyy",
				longDate:       "mmmm d, yyyy",
				fullDate:       "dddd, mmmm d, yyyy",
				shortTime:      "h:MM TT",
				mediumTime:     "h:MM:ss TT",
				longTime:       "h:MM:ss TT Z",
				isoDate:        "yyyy-mm-dd",
				isoTime:        "HH:MM:ss",
				isoDateTime:    "yyyy-mm-dd'T'HH:MM:ss",
				isoUtcDateTime: "UTC:yyyy-mm-dd'T'HH:MM:ss'Z'"
			};
			
			// Internationalization strings
			dateFormat.i18n = {
				dayNames: [
					"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat",
					"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
				],
				monthNames: [
					"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
					"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
				]
			};
			
			// For convenience...
			Date.prototype.format = function (mask, utc) {
				return dateFormat(this, mask, utc);
			};
			var datePicker = new A.DatePicker<%= BrowserSnifferUtil.isMobile(request) ? "Native" : StringPool.BLANK %>(
				{
					container: '#<%= randomNamespace %>displayDate',
					mask: '<%= mask %>',
					on: {
						disabledChange: function(event) {
							var instance = this;

							var container = instance.get('container');

							var newVal = event.newVal;

							container.one('#<%= dayParamId %>').attr('disabled', newVal);
							container.one('#<%= monthParamId %>').attr('disabled', newVal);
							container.one('#<%= namespace + name %>').attr('disabled', newVal);
							container.one('#<%= yearParamId %>').attr('disabled', newVal);
						},
						selectionChange: function(event) {
							var instance = this;

							var container = instance.get('container');

							var date = event.newSelection[0];

							if (date) {
								container.one('#<%= dayParamId %>').val(date.getDate());
								container.one('#<%= monthParamId %>').val(date.getMonth());
								container.one('#<%= yearParamId %>').val(date.getFullYear());
								
								if ('<%= namespace + name %>DatePicker' == '_1_WAR_calendarportlet_startTimeDatePicker') {
									document.getElementById('_1_WAR_calendarportlet_endtimeday').value = date.getDate();
									document.getElementById('_1_WAR_calendarportlet_endtimemonth').value = date.getMonth();
									document.getElementById('_1_WAR_calendarportlet_endtimeyear').value = date.getFullYear();
									document.getElementById('_1_WAR_calendarportlet_endTime').value = date.format("dd/mm/yyyy");
								}
							}
						}
					},
					popover: {
						zIndex: Liferay.zIndex.TOOLTIP
					},
					trigger: '#<%= namespace + name %>'
				}
			);

			datePicker.getDate = function() {
				var instance = this;

				var container = instance.get('container');

				return new Date(container.one('#<%= yearParamId %>').val(), container.one('#<%= monthParamId %>').val(), container.one('#<%= dayParamId %>').val());
			};

			return datePicker;
		}
	);

	Liferay.component('<%= namespace + name %>DatePicker');
</aui:script>

<%!
private static final String _SIMPLE_DATE_FORMAT_PATTERN_DMY = "dd/MM/yyyy";

private static final String _SIMPLE_DATE_FORMAT_PATTERN_HTML5 = "yyyy-MM-dd";

private static final String _SIMPLE_DATE_FORMAT_PATTERN_MDY = "MM/dd/yyyy";

private static final String _SIMPLE_DATE_FORMAT_PATTERN_YMD = "yyyy/MM/dd";

private static final String _MASK_DMY = "%d/%m/%Y";

private static final String _MASK_MDY = "%m/%d/%Y";

private static final String _MASK_YMD = "%Y/%m/%d";
%>