import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_components/widgets.dart';

import 'package:flutter_components/utils/DateUtil.dart';
import '../widget/TitleWidget.dart';

class TimePickerView extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _TimePickerView();
  }

}

class _TimePickerView extends State<TimePickerView> {

  String _currentDate = DateUtil.formatDate(new DateTime.now(), format: "yyyy年MM月dd日");
  String _currentTime = DateUtil.formatDate(new DateTime.now(),);
  String _currentMinute = DateUtil.formatDate(new DateTime.now(),);

  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        TitleWidget(title: "TimePicker 各类选择器" ),
        TitleWidget(title: "选择到日" ),
        Button(_currentDate,
          onPressed: () {
            DatePicker.showDatePicker(context,
                initialDateTime: DateUtil.getDateTime(_currentDate),
                maxDateTime: new DateTime.now(),
                onConfirm: (date, value, format) {
                    setState(() {
                      _currentDate = format;
                    });
                },);
          },),
        TitleWidget(title: "选择到秒" ),
        Button(_currentTime,
          onPressed: () {
            DatePicker.showDatePicker(context,
              initialDateTime: DateUtil.getDateTime(_currentTime),
              pickerMode: DateTimePickerMode.datetime,
              maxDateTime: new DateTime.now(),
              onConfirm: (date, value, format) {
                setState(() {
                  _currentTime = format;
                });
              },);
          },),
        TitleWidget(title: "选择到分" ),
        Button(_currentMinute,
          onPressed: () {
            DatePicker.showDatePicker(context,
              initialDateTime: DateUtil.getDateTime(_currentMinute),
              pickerMode: DateTimePickerMode.minute,
              maxDateTime: new DateTime.now(),
              onConfirm: (date, value, format) {
                setState(() {
                  _currentMinute = format;
                });
              },);
          },),
      ],
    );
  }
}
