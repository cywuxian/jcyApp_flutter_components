import 'package:flutter/cupertino.dart';
import 'package:flutter_components/widgets.dart';
import 'package:flutter_components/SimpleTextField.dart';
import '../widget/TitleWidget.dart';

class ListGroupView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        TitleWidget(
          title: "List 列表",
        ),
        ListGroup(
          children: [
            ListItem(
              title: "标题名称",
              onPressed: () {},
            ),
            ListItem(
              title: "标题名称",
              trailing: CupertinoSwitch(
                value: false,
                activeColor:ThemeColorUtil.primaryColor(context),
              ),
              onPressed: () {},
            ),
            ListItem(
              title: "标题名称",
              trailing: CupertinoSwitch(
                value: true,
                activeColor:ThemeColorUtil.primaryColor(context),
              ),
              onPressed: () {},
            ),
            ListItem(
              title: "标题名称",
              trailing: ListItemTrailing(
                text: "详细内容",
                placeholder: "请输入内容",
              ),
            ),
            ListItem(
              title: "标题名称",
              trailing: ListItemTrailing(
                text: "详细内容",
                placeholder: "请输入内容",
              ),
              onPressed: () {},
            ),
            ListItem(
              title: "标题名称",
              trailing: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xffFF0000)
                ),
              ),
              onPressed: () {},
            ),
            ListItem(
              title: "标题名称",
              trailing: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: Color(0xffdddddd),
                ),
              ),
              onPressed: () {},
            ),

          ],
        ),
        SizedBox(height: 20,),
        ListGroup(
          children: [
            ListItem(
              leading: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Color(0xffdddddd),
                ),
              ),
              title: "标题名称",
            ),
            ListItem(
              leading: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Color(0xffdddddd),
                ),
              ),
              title: "手机号",
              trailing: ListItemTrailing(
                 text: "18655256672",
                 placeholder: "请输入手机号",
              ),
              onPressed: () {},
            ),
            ListItem(
              leading: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Color(0xffdddddd),
                ),
              ),
              title: "标题名称",
              trailing: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Color(0xffdddddd),
                ),
              ),
              onPressed: () {},
            ),
            ListItem(
              title: '输入',
              trailing: SimpleTextField(
                  placeholder:'请输入',
                  keyboardType:TextInputType.number
              ),
            )
          ],
        )
      ],
    );
  }

}