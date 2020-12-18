
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './utils/ThemeColorUtil.dart';
import './utils/Ui.dart';

import 'utils/Gaps.dart';

class SimpleTextField extends StatefulWidget {

  const SimpleTextField({
    Key key,
    this.onChanged,
    this.maxLength,
    this.value,
    this.autoFocus = false,
    this.keyboardType = TextInputType.text,
    this.placeholder = '',
    this.focusNode,
    this.isInputPwd: false,
    this.keyName,
    this.trailing,
    this.bordered = true,
    this.textEditingController
  }): super(key: key);

  final ValueChanged<String> onChanged;
  final int maxLength;
  final bool autoFocus;
  final String value;
  final TextInputType keyboardType;
  final String placeholder;
  final FocusNode focusNode;
  final bool isInputPwd;
  final Widget trailing;
  final bool bordered;
  final TextEditingController textEditingController;

  final String keyName;

  @override
  SimpleTextFieldState createState() => SimpleTextFieldState();
}

class SimpleTextFieldState extends State<SimpleTextField> with WidgetsBindingObserver {
  bool _isShowPwd = false;
  bool _isShowDelete;
  StreamSubscription _subscription;
  TextEditingController controller;
  String _currentValue;
  FocusNode focusNode;

  @override
  void initState() {
    if(widget.focusNode != null) {
      this.focusNode = widget.focusNode;
    }else{
      this.focusNode = FocusNode();
    }
    _currentValue = widget.value != null ? widget.value : "";
    controller = widget.textEditingController != null? widget.textEditingController:new TextEditingController(
        text: widget.value
    );
    _isShowDelete = controller.text.isEmpty;
    controller.addListener(() {
      setState(() {
        if(!this.focusNode.hasFocus){
          _isShowDelete = true;
        }else {
          _isShowDelete = controller.text.isEmpty;
        }

      });
    });
    this.focusNode?.addListener(() {
      setState(() {
        if(this.focusNode.hasFocus) {
          _isShowDelete = !controller.text.isNotEmpty;
        }else {
          _isShowDelete = true;
        }
      });
    });
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }
 @override
  void didUpdateWidget(covariant SimpleTextField oldWidget) {
    if(controller.text != oldWidget.value) {
      _currentValue = oldWidget.value;
      controller.text = oldWidget.value;
    }
    super.didUpdateWidget(oldWidget);
  }
  @override
  void dispose() {
    _subscription?.cancel();
    controller?.removeListener(() {});
    controller?.dispose();
    this.focusNode?.removeListener(() {});
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    if(_currentValue != widget.value) {
      _currentValue = widget.value;
      controller.text = widget.value;
    }
    return Stack(
      alignment: Alignment.centerRight,
      children: <Widget>[
        TextField(
          focusNode: this.focusNode,
          maxLength: widget.maxLength,
          cursorColor: Ui.isDarkMode(context) ? Colors.white : Theme.of(context).primaryColor,
          obscureText: widget.isInputPwd ? !_isShowPwd : false,
          autofocus: widget.autoFocus,
          controller: controller,
          style: TextStyle(
              fontSize: 17
          ),
          textInputAction: TextInputAction.done,
          keyboardType: widget.keyboardType,
          inputFormatters: (widget.keyboardType == TextInputType.number || widget.keyboardType == TextInputType.phone) ?
          [WhitelistingTextInputFormatter(RegExp('[0-9]|[.]'))] : [],
          decoration: InputDecoration(
            isDense: false,
            contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
            hintText: widget.placeholder,
            hintStyle: TextStyle(
              color: Color(0xffCCCCCC),
              fontSize: 15.0
            ),
            counterText: '',
            focusedBorder: !widget.bordered ? InputBorder.none : UnderlineInputBorder(
              borderSide: BorderSide(
                color: ThemeColorUtil.primaryTextColor(context),
                width: 0.8
            )
            ),
            enabledBorder: !widget.bordered ? InputBorder.none :UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 0.8
              )
            )
          ),
          onChanged: (value) {
            if (_currentValue == value) return;
            widget.onChanged(value);
            _currentValue = value;
          },
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            controller.text?.length != 0 && focusNode.hasFocus? Semantics(
              label: '清空',
              hint: '清空输入框',
              child: GestureDetector(
                child: Container(
                  child: Icon(Icons.cancel, color: Color(0xffCBCBCB), size: 16,),
                  padding: EdgeInsets.only(top: 4),
                ),
                onTap: () {
                  controller.text = '';
                  widget.onChanged?.call('');
                },
              ),
            ):Gaps.empty ,
            !widget.isInputPwd ? Gaps.empty : Gaps.hGap15,
            // !widget.isInputPwd ? Gaps.empty : Semantics(
            //   label: '密码可见开关',
            //   hint: '密码是否可见',
            //   child: GestureDetector(
            //     child: Container(
            //       padding: EdgeInsets.only(right: 15),
            //       child: Image.asset(
            //         _isShowPwd ? "lib/ui/assets/password_visible.png" :
            //         "lib/ui/assets/password_invisible.png",
            //         width: 20,
            //         height: 20,
            //       ),
            //     ),
            //     onTap: () {
            //       setState(() {
            //         _isShowPwd = !_isShowPwd;
            //       });
            //     },
            //   ),
            // ),
            widget.trailing != null ? Theme(
                data: Theme.of(context).copyWith(
                  buttonTheme: ButtonThemeData(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    height: 26.0,
                    // minWidth: 76.0,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                child: widget.trailing
            ) : Gaps.empty
          ],
        )
      ],
    );
  }

  void setValue(String value) {
    if (_currentValue == value) return;
    _currentValue = value;
    controller.text = value;
    Future.delayed(Duration(milliseconds: 20), () {
      controller.selection = TextSelection.fromPosition(
          TextPosition(
              affinity: TextAffinity.downstream,
              offset: value.length
          )
      );
    });
    widget.onChanged(value);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      controller.text = _currentValue;
      controller.selection = TextSelection.fromPosition(
          TextPosition(
              affinity: TextAffinity.downstream,
              offset: _currentValue.length
          )
      );
    }
    super.didChangeAppLifecycleState(state);
  }

}
