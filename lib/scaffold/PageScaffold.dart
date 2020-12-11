import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide BackButton, CloseButton;
import 'package:flutter/services.dart';
import '../scaffold/NavigatorBar.dart';
import '../utils/ColorUtil.dart';

// 默认标题栏高度为44 TabBar高度为46 所以如果导航栏底部有TabBar的话高度应该设置为90
const double DEFAULT_APP_BAR_HEIGHT = 44;

class PageScaffold extends StatefulWidget {

  final String title; // string
  final Widget navigator; // 自定义导航栏
  final Key navigatorBarKey;
  final bool navigatorInitLoading;
  final Widget leading;
  final Widget body;
  final double height;
  final List<Widget> actions;
  final Widget bottom;
  final bool automaticallyImplyLeading;
  final Color navigatorBarBackgroundColor;
  final Color titleColor;
  final bool withShadow;
  final bool resizeToAvoidBottomInset;
  final bool resizeToAvoidBottomPadding;

  const PageScaffold({
    Key key,
    this.title,
    @required this.body,
    this.navigator,
    this.navigatorBarKey,
    this.navigatorInitLoading = false,
    this.leading,
    this.height = DEFAULT_APP_BAR_HEIGHT,
    this.actions,
    this.bottom,
    this.automaticallyImplyLeading = true,
    this.navigatorBarBackgroundColor = Colors.white,
    this.titleColor = ColorUtil.title,
    this.withShadow = false,
    this.resizeToAvoidBottomInset = true,
    this.resizeToAvoidBottomPadding = true
  }) : super(key: key);


  @override
  State<StatefulWidget> createState() {
    return _PageScaffoldState();
  }

}

class _PageScaffoldState extends State<PageScaffold> with AutomaticKeepAliveClientMixin {



  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      resizeToAvoidBottomPadding: widget.resizeToAvoidBottomPadding,
      appBar: NavigatorBar(
        key: widget.navigatorBarKey,
        title: widget.title,
        navigator: widget.navigator,
        leading: widget.leading,
        height: widget.height,
        actions: widget.actions,
        bottom: widget.bottom,
        automaticallyImplyLeading: widget.automaticallyImplyLeading,
        titleColor: widget.titleColor,
        backgroundColor: widget.navigatorBarBackgroundColor,
        withShadow: widget.withShadow,
        loading: widget.navigatorInitLoading,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            FocusManager.instance.primaryFocus.unfocus();
          }
        },
        child: widget.body,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

}

