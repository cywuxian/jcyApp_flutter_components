import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../utils/DateUtil.dart';
import '../../utils/Ui.dart';
import '../DateTimeFormatter.dart';
import '../DatePickerTheme.dart';
import '../DatePickerConstants.dart';
import '../i18n/date_picker_i18n.dart';
import 'date_picker_title_widget.dart';

/// Solar months of 31 days.
const List<int> _solarMonthsOf31Days = const <int>[1, 3, 5, 7, 8, 10, 12];

/// DatePicker widget.
///
/// @author dylan wu
/// @since 2019-05-10
class DateTimePickerWidget extends StatefulWidget {
  DateTimePickerWidget({
    Key key,
    this.minDateTime,
    this.maxDateTime,
    this.initialDateTime,
    this.dateFormat: DATETIME_PICKER_DATE_FORMAT,
    this.locale: DATETIME_PICKER_LOCALE_DEFAULT,
    this.pickerTheme: DateTimePickerTheme.Default,
    this.onCancel,
    this.onChange,
    this.onConfirm,
  }) : super(key: key) {
    DateTime minTime = minDateTime ?? DateTime.parse(DATE_PICKER_MIN_DATETIME);
    DateTime maxTime = maxDateTime ?? DateTime.parse(DATE_PICKER_MAX_DATETIME);
    assert(minTime.compareTo(maxTime) < 0);
  }

  final DateTime minDateTime, maxDateTime, initialDateTime;
  final String dateFormat;
  final DateTimePickerLocale locale;
  final DateTimePickerTheme pickerTheme;

  final DateVoidCallback onCancel;
  final DateValueCallback onChange, onConfirm;
  final int minuteDivider = 1;
  @override
  State<StatefulWidget> createState() => _DateTimePickerWidgetState(
      this.minDateTime, this.maxDateTime, this.initialDateTime, this.minuteDivider);
}

class _DateTimePickerWidgetState extends State<DateTimePickerWidget> {
  DateTime _minDateTime, _maxDateTime;
  int _currYear, _currMonth, _currDay;
  List<int> _yearRange, _monthRange, _dayRange;
  int _currHour, _currMinute, _currSecond;
  int _minuteDivider;
  List<int> _hourRange, _minuteRange, _secondRange;
  FixedExtentScrollController
      _hourScrollCtrl,
      _minuteScrollCtrl,
      _secondScrollCtrl;
  
  FixedExtentScrollController _yearScrollCtrl,
      _monthScrollCtrl,
      _dayScrollCtrl;

  Map<String, FixedExtentScrollController> _scrollCtrlMap;
  Map<String, List<int>> _valueRangeMap;

  bool _isChangeDateRange = false;
  bool _isChangeTimeRange = false;

  final DateTime _baselineDate = DateTime(1900, 1, 1);

  _DateTimePickerWidgetState(
      DateTime minDateTime, DateTime maxDateTime, DateTime initialDateTime, int minuteDivider) {
    // handle current selected year、month、day
    DateTime initDateTime = initialDateTime ?? DateTime.now();
    this._currYear = initDateTime.year;
    this._currMonth = initDateTime.month;
    this._currDay = initDateTime.day;
    this._currHour = initDateTime.hour;
    this._currMinute = initDateTime.minute;
    this._currSecond = initDateTime.second;
    this._minuteDivider = minuteDivider;

    // handle DateTime range
    this._minDateTime = minDateTime ?? DateTime.parse(DATE_PICKER_MIN_DATETIME);
    this._maxDateTime = maxDateTime ?? DateTime.parse(DATE_PICKER_MAX_DATETIME);

    // limit the range of year
    this._yearRange = _calcYearRange();
    this._currYear = min(max(_minDateTime.year, _currYear), _maxDateTime.year);

    // limit the range of month
    this._monthRange = _calcMonthRange();
    this._currMonth = min(max(_monthRange.first, _currMonth), _monthRange.last);

    // limit the range of day
    this._dayRange = _calcDayRange();
    this._currDay = min(max(_dayRange.first, _currDay), _dayRange.last);

    // limit the range of hour
    this._hourRange = _calcHourRange();
    this._currHour = min(max(_hourRange.first, _currHour), _hourRange.last);

    // limit the range of minute
    this._minuteRange = _calcMinuteRange();
    this._currMinute =
        min(max(_minuteRange.first, _currMinute), _minuteRange.last);

    // limit the range of second
    this._secondRange = _calcSecondRange();
    this._currSecond =
        min(max(_secondRange.first, _currSecond), _secondRange.last);
    
    // create scroll controller
    _yearScrollCtrl =
        FixedExtentScrollController(initialItem: _currYear - _yearRange.first);
    _monthScrollCtrl = FixedExtentScrollController(
        initialItem: _currMonth - _monthRange.first);
    _dayScrollCtrl =
        FixedExtentScrollController(initialItem: _currDay - _dayRange.first);
    _hourScrollCtrl =
        FixedExtentScrollController(initialItem: _currHour - _hourRange.first);
    _minuteScrollCtrl = FixedExtentScrollController(
        initialItem: (_currMinute - _minuteRange.first) ~/ _minuteDivider);
    _secondScrollCtrl = FixedExtentScrollController(
        initialItem: _currSecond - _secondRange.first);

    _scrollCtrlMap = {
      'y': _yearScrollCtrl,
      'M': _monthScrollCtrl,
      'd': _dayScrollCtrl,
      'H': _hourScrollCtrl,
      'm': _minuteScrollCtrl,
      's': _secondScrollCtrl
    };
    _valueRangeMap = {
      'y': _yearRange,
      'M': _monthRange,
      'd': _dayRange,
      'H': _hourRange,
      'm': _minuteRange,
      's': _secondRange
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Material(
          color: Colors.transparent, child: _renderPickerView(context)),
    );
  }

  /// render date picker widgets
  Widget _renderPickerView(BuildContext context) {
    Widget DateTimePickerWidget = _renderDateTimePickerWidget();

    // display the title widget
    if (widget.pickerTheme.title != null || widget.pickerTheme.showTitle) {
      Widget titleWidget = DatePickerTitleWidget(
        pickerTheme: widget.pickerTheme,
        locale: widget.locale,
        onCancel: () => _onPressedCancel(),
        onConfirm: () => _onPressedConfirm(),
      );
      return Column(children: <Widget>[titleWidget, DateTimePickerWidget]);
    }
    return DateTimePickerWidget;
  }

  /// pressed cancel widget
  void _onPressedCancel() {
    if (widget.onCancel != null) {
      widget.onCancel();
    }
    Navigator.pop(context);
  }

  /// pressed confirm widget
  void _onPressedConfirm() {
    if (widget.onConfirm != null) {
      DateTime dateTime = DateTime(
          _currYear, _currMonth, _currDay, _currHour, _currMinute, _currSecond);
      String format = DateUtil.formatDate(dateTime, format:  widget.dateFormat);
      widget.onConfirm(dateTime, _calcSelectIndexList(), format);
    }
    Navigator.pop(context);
  }

  /// notify selected date changed
  void _onSelectedChange() {
    if (widget.onChange != null) {
      DateTime dateTime = DateTime(
          _currYear, _currMonth, _currDay, _currHour, _currMinute, _currSecond);
      String format = DateUtil.formatDate(dateTime, format:  widget.dateFormat);
      widget.onChange(dateTime, _calcSelectIndexList(), format);
    }
  }

  /// find scroll controller by specified format
  FixedExtentScrollController _findScrollCtrl(String format) {
    FixedExtentScrollController scrollCtrl;
    _scrollCtrlMap.forEach((key, value) {
      if (format.contains(key)) {
        scrollCtrl = value;
      }
    });
    return scrollCtrl;
  }

  /// find item value range by specified format
  List<int> _findPickerItemRange(String format) {
    List<int> valueRange;
    _valueRangeMap.forEach((key, value) {
      if (format.contains(key)) {
        valueRange = value;
      }
    });
    return valueRange;
  }

  /// render the picker widget of year、month and day
  Widget _renderDateTimePickerWidget() {
    List<Widget> pickers = List<Widget>();
    List<String> formatArr =
    DateTimeFormatter.splitDateFormat(widget.dateFormat);
    formatArr.forEach((format) {
      List<int> valueRange = _findPickerItemRange(format);

      Widget pickerColumn = _renderDatePickerColumnComponent(
        scrollCtrl: _findScrollCtrl(format),
        valueRange: valueRange,
        format: format,
        valueChanged: (value) {
          if (format.contains('y')) {
            _changeYearSelection(value);
          } else if (format.contains('M')) {
            _changeMonthSelection(value);
          } else if (format.contains('d')) {
            _changeDaySelection(value);
          } else if (format.contains('H')) {
            _changeHourSelection(value);
          } else if (format.contains('m')) {
            _changeMinuteSelection(value);
          } else if (format.contains('s')) {
            _changeSecondSelection(value);
          }
        },
      );
      pickers.add(pickerColumn);
    });
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, children: pickers);
  }

  Widget _renderDatePickerColumnComponent({
    @required FixedExtentScrollController scrollCtrl,
    @required List<int> valueRange,
    @required String format,
    @required ValueChanged<int> valueChanged,
  }) {
    return Expanded(
      flex: 1,
      child: Container(
//        padding: EdgeInsets.all(8.0), // 每列之间的间隙
        height: widget.pickerTheme.pickerHeight,
        decoration: BoxDecoration(color: widget.pickerTheme.backgroundColor),
        child: CupertinoPicker.builder(
          backgroundColor: Ui.isDarkMode(context) ? Theme.of(context).scaffoldBackgroundColor : widget.pickerTheme.backgroundColor,
          scrollController: scrollCtrl,
          itemExtent: widget.pickerTheme.itemHeight,
          onSelectedItemChanged: valueChanged,
          childCount: valueRange.last - valueRange.first + 1,
          itemBuilder: (context, index) =>
              _renderDatePickerItemComponent(valueRange.first + index, format),
        ),
      ),
    );
  }

  Widget _renderDatePickerItemComponent(int value, String format) {
    return Container(
      height: widget.pickerTheme.itemHeight,
      alignment: Alignment.center,
      child: Text(
        DateTimeFormatter.formatDateTime(value, format, widget.locale),
        style:
        widget.pickerTheme.itemTextStyle.copyWith(
            color: Ui.isDarkMode(context) ? Colors.white : null
        ) ?? DATETIME_PICKER_ITEM_TEXT_STYLE.copyWith(
            color: Ui.isDarkMode(context) ? Colors.white : null
        ),
      ),
    );
  }

  /// change the selection of year picker
  void _changeYearSelection(int index) {
    int year = _yearRange.first + index;
    if (_currYear != year) {
      _currYear = year;
      _changeDateRange();
      _onSelectedChange();
    }
  }

  /// change the selection of month picker
  void _changeMonthSelection(int index) {
    int month = _monthRange.first + index;
    if (_currMonth != month) {
      _currMonth = month;
      _changeDateRange();
      _onSelectedChange();
    }
  }

  /// change the selection of day picker
  void _changeDaySelection(int index) {
    int dayOfMonth = _dayRange.first + index;
    if (_currDay != dayOfMonth) {
      _currDay = dayOfMonth;
      _onSelectedChange();
    }
  }

  /// change range of month and day
  void _changeDateRange() {
    if (_isChangeDateRange) {
      return;
    }
    _isChangeDateRange = true;

    List<int> monthRange = _calcMonthRange();
    bool monthRangeChanged = _monthRange.first != monthRange.first ||
        _monthRange.last != monthRange.last;
    if (monthRangeChanged) {
      // selected year changed
      _currMonth = max(min(_currMonth, monthRange.last), monthRange.first);
    }

    List<int> dayRange = _calcDayRange();
    bool dayRangeChanged =
        _dayRange.first != dayRange.first || _dayRange.last != dayRange.last;
    if (dayRangeChanged) {
      // day range changed, need limit the value of selected day
      _currDay = max(min(_currDay, dayRange.last), dayRange.first);
    }

    setState(() {
      _monthRange = monthRange;
      _dayRange = dayRange;

      _valueRangeMap['M'] = monthRange;
      _valueRangeMap['d'] = dayRange;
    });

    if (monthRangeChanged) {
      // CupertinoPicker refresh data not working (https://github.com/flutter/flutter/issues/22999)
      int currMonth = _currMonth;
      _monthScrollCtrl.jumpToItem(monthRange.last - monthRange.first);
      if (currMonth < monthRange.last) {
        _monthScrollCtrl.jumpToItem(currMonth - monthRange.first);
      }
    }

    if (dayRangeChanged) {
      // CupertinoPicker refresh data not working (https://github.com/flutter/flutter/issues/22999)
      int currDay = _currDay;
      _dayScrollCtrl.jumpToItem(dayRange.last - dayRange.first);
      if (currDay < dayRange.last) {
        _dayScrollCtrl.jumpToItem(currDay - dayRange.first);
      }
    }

    _isChangeDateRange = false;
  }

  /// calculate the count of day in current month
  int _calcDayCountOfMonth() {
    if (_currMonth == 2) {
      return isLeapYear(_currYear) ? 29 : 28;
    } else if (_solarMonthsOf31Days.contains(_currMonth)) {
      return 31;
    }
    return 30;
  }

  /// whether or not is leap year
  bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
  }

  /// calculate selected index list
  List<int> _calcSelectIndexList() {
    int yearIndex = _currYear - _minDateTime.year;
    int monthIndex = _currMonth - _monthRange.first;
    int dayIndex = _currDay - _dayRange.first;
    return [yearIndex, monthIndex, dayIndex];
  }

  /// calculate the range of year
  List<int> _calcYearRange() {
    return [_minDateTime.year, _maxDateTime.year];
  }

  /// calculate the range of month
  List<int> _calcMonthRange() {
    int minMonth = 1, maxMonth = 12;
    int minYear = _minDateTime.year;
    int maxYear = _maxDateTime.year;
    if (minYear == _currYear) {
      // selected minimum year, limit month range
      minMonth = _minDateTime.month;
    }
    if (maxYear == _currYear) {
      // selected maximum year, limit month range
      maxMonth = _maxDateTime.month;
    }
    return [minMonth, maxMonth];
  }

  /// calculate the range of day
  List<int> _calcDayRange({currMonth}) {
    int minDay = 1, maxDay = _calcDayCountOfMonth();
    int minYear = _minDateTime.year;
    int maxYear = _maxDateTime.year;
    int minMonth = _minDateTime.month;
    int maxMonth = _maxDateTime.month;
    if (currMonth == null) {
      currMonth = _currMonth;
    }
    if (minYear == _currYear && minMonth == currMonth) {
      // selected minimum year and month, limit day range
      minDay = _minDateTime.day;
    }
    if (maxYear == _currYear && maxMonth == currMonth) {
      // selected maximum year and month, limit day range
      maxDay = _maxDateTime.day;
    }
    return [minDay, maxDay];
  }
  
  
  // datetime
  /// calculate the range of hour
  List<int> _calcHourRange() {
    int minHour = 0, maxHour = 23;
    if (_currDay == _dayRange.first) {
      minHour = _minDateTime.hour;
    }
    if (_currDay == _dayRange.last) {
      maxHour = _maxDateTime.hour;
    }
    return [minHour, maxHour];
  }

  /// calculate the range of minute
  List<int> _calcMinuteRange({currHour}) {
    int minMinute = 0, maxMinute = 59;
    if (currHour == null) {
      currHour = _currHour;
    }

    if (_currDay == _dayRange.first && currHour == _minDateTime.hour) {
      // selected minimum day、hour, limit minute range
      minMinute = _minDateTime.minute;
    }
    if (_currDay == _dayRange.last && currHour == _maxDateTime.hour) {
      // selected maximum day、hour, limit minute range
      maxMinute = _maxDateTime.minute;
    }
    return [minMinute, maxMinute];
  }

  /// calculate the range of second
  List<int> _calcSecondRange({currHour, currMinute}) {
    int minSecond = 0, maxSecond = 59;

    if (currHour == null) {
      currHour = _currHour;
    }
    if (currMinute == null) {
      currMinute = _currMinute;
    }

    if (_currDay == _dayRange.first &&
        currHour == _minDateTime.hour &&
        currMinute == _minDateTime.minute) {
      // selected minimum hour and minute, limit second range
      minSecond = _minDateTime.second;
    }
    if (_currDay == _dayRange.last &&
        currHour == _maxDateTime.hour &&
        currMinute == _maxDateTime.minute) {
      // selected maximum hour and minute, limit second range
      maxSecond = _maxDateTime.second;
    }
    return [minSecond, maxSecond];
  }

  /// change the selection of hour picker
  void _changeHourSelection(int index) {
    int value = _hourRange.first + index;
    if (_currHour != value) {
      _currHour = value;
      _changeTimeRange();
      _onSelectedChange();
    }
  }

  /// change the selection of minute picker
  void _changeMinuteSelection(int index) {
    // TODO: copied from time_picker_widget - this looks like it would break date ranges but not taking into account _minuteRange.first
    int value = index * _minuteDivider;
//    int value = _minuteRange.first + index;
    if (_currMinute != value) {
      _currMinute = value;
      _changeTimeRange();
      _onSelectedChange();
    }
  }

  /// change the selection of second picker
  void _changeSecondSelection(int index) {
    int value = _secondRange.first + index;
    if (_currSecond != value) {
      _currSecond = value;
      _onSelectedChange();
    }
  }

  /// change range of minute and second
  void _changeTimeRange() {
    if (_isChangeTimeRange) {
      return;
    }
    _isChangeTimeRange = true;

    List<int> hourRange = _calcHourRange();
    bool hourRangeChanged = _hourRange.first != hourRange.first ||
        _hourRange.last != hourRange.last;
    if (hourRangeChanged) {
      // selected day changed
      _currHour = max(min(_currHour, hourRange.last), hourRange.first);
    }

    List<int> minuteRange = _calcMinuteRange();
    bool minuteRangeChanged = _minuteRange.first != minuteRange.first ||
        _minuteRange.last != minuteRange.last;
    if (minuteRangeChanged) {
      // selected hour changed
      _currMinute = max(min(_currMinute, minuteRange.last), minuteRange.first);
    }

    List<int> secondRange = _calcSecondRange();
    bool secondRangeChanged = _secondRange.first != secondRange.first ||
        _secondRange.last != secondRange.last;
    if (secondRangeChanged) {
      // second range changed, need limit the value of selected second
      _currSecond = max(min(_currSecond, secondRange.last), secondRange.first);
    }

    setState(() {
      _hourRange = hourRange;
      _minuteRange = minuteRange;
      _secondRange = secondRange;

      _valueRangeMap['H'] = hourRange;
      _valueRangeMap['m'] = minuteRange;
      _valueRangeMap['s'] = secondRange;
    });

    if (hourRangeChanged) {
      // CupertinoPicker refresh data not working (https://github.com/flutter/flutter/issues/22999)
      int currHour = _currHour;
      _hourScrollCtrl.jumpToItem(hourRange.last - hourRange.first);
      if (currHour < hourRange.last) {
        _hourScrollCtrl.jumpToItem(currHour - hourRange.first);
      }
    }

    if (minuteRangeChanged) {
      // CupertinoPicker refresh data not working (https://github.com/flutter/flutter/issues/22999)
      int currMinute = _currMinute;
      _minuteScrollCtrl.jumpToItem((minuteRange.last - minuteRange.first) ~/ _minuteDivider);
      if (currMinute < minuteRange.last) {
        _minuteScrollCtrl.jumpToItem(currMinute - minuteRange.first);
      }
    }

    if (secondRangeChanged) {
      // CupertinoPicker refresh data not working (https://github.com/flutter/flutter/issues/22999)
      int currSecond = _currSecond;
      _secondScrollCtrl.jumpToItem(secondRange.last - secondRange.first);
      if (currSecond < secondRange.last) {
        _secondScrollCtrl.jumpToItem(currSecond - secondRange.first);
      }
    }

    _isChangeTimeRange = false;
  }

}



