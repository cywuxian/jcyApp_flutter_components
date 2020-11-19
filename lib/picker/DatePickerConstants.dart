/// Selected value of DatePicker.
typedef DateValueCallback(DateTime dateTime, List<int> selectedIndex, String format);

/// Pressed cancel callback.
typedef DateVoidCallback();

/// Default value of minimum datetime.
const String DATE_PICKER_MIN_DATETIME = "1900-01-01 00:00:00";

/// Default value of maximum datetime.
const String DATE_PICKER_MAX_DATETIME = "2100-12-31 23:59:59";

/// Default value of date format
const String DATETIME_PICKER_DATE_FORMAT = 'yyyy-MM-dd';

/// Default value of date format
const String DATETIME_PICKER_MONTH_FORMAT = 'yyyy-MM';

/// Default value of time format
const String DATETIME_PICKER_TIME_FORMAT = 'HH:mm:ss';

/// Default value of datetime format
const String DATETIME_PICKER_DATETIME_FORMAT = 'yyyy-MM-dd HH:mm:ss';
/// Default value of datetime format
const String DATETIME_PICKER_MINUTE_FORMAT = 'yyyy-MM-dd HH:mm';
